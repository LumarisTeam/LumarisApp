import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:ios_club_app/core/services/app_locale_service.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import '../../../state/prefs_keys.dart';
import '../../../core/utils/request_cache.dart';
import '../../../core/services/retry_policy.dart';
import '../../basic/models/school.dart';
import '../data/edu_api_client.dart';
import 'login_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';

typedef RelogFailedCallback = void Function(String reason);

class AuthStateCallbacks {
  const AuthStateCallbacks({
    this.onRelogging,
    this.onRelogSuccess,
    this.onRelogFailed,
  });

  static const noop = AuthStateCallbacks();

  final void Function()? onRelogging;
  final void Function()? onRelogSuccess;
  final RelogFailedCallback? onRelogFailed;
}

class EduHttpClient implements EduApiClient {
  static const String skipAuthRecoveryKey = 'skip_auth_recovery';
  static const String _rateLimitMessage = '已被限流，请稍后再试';
  static const int _rateLimitCooldownMs = 5000;

  final Dio _dio;
  final AuthStateCallbacks _authStateCallbacks;
  final Map<String, int> _rateLimitCooldowns = <String, int>{};
  String _baseUrl;

  /// 全局登录锁，确保同一时间只有一个登录请求
  static Completer<bool>? _loginCompleter;

  /// 最后一次登录失败的时间戳，用于防止频繁重试
  static int? _lastLoginFailTime;

  /// 登录失败后的冷却时间（毫秒）
  static const int _loginCooldownMs = 5000;

  // Test hook: allows injecting deterministic login behavior in unit tests.
  static Future<Map<String, dynamic>> Function(String, String)?
      _loginHandlerForTest;
  static int Function()? _nowProviderForTest;

  EduHttpClient({
    Dio? dio,
    String? baseUrl,
    AuthStateCallbacks authStateCallbacks = AuthStateCallbacks.noop,
  })  : _dio = dio ?? Dio(),
        _authStateCallbacks = authStateCallbacks,
        _baseUrl = baseUrl ?? School.fallbackList.first.website {
    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      // 增加超时时间以适应重登录场景
      // 重登录可能需要3-5秒，加上原请求时间，总共需要更长的超时
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    );

    // 添加重试拦截器（使用统一的重试策略）
    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      policy: const RetryPolicy(maxRetries: 2),
    ));

    // 添加缓存拦截器
    _dio.interceptors.add(CacheInterceptor());

    // 添加认证拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final rateLimitException = _createRateLimitExceptionIfCoolingDown(
          options,
        );
        if (rateLimitException != null) {
          handler.reject(rateLimitException);
          return;
        }

        // 自动添加认证cookie
        final cookie = await _getCookie();
        if (cookie != null) {
          options.headers['Cookie'] = cookie;
          options.headers['xauat'] = cookie;
        }
        options.headers.putIfAbsent('x-language', _resolveLanguageHeaderValue);
        handler.next(options);
      },
      onError: (DioException e, handler) async {
        final statusCode = e.response?.statusCode;

        if (e.requestOptions.extra[skipAuthRecoveryKey] == true) {
          handler.next(e);
          return;
        }

        if (statusCode == 429) {
          _recordRateLimit(e.requestOptions);
          handler.next(
            _buildRateLimitException(
              e.requestOptions,
              response: e.response,
            ),
          );
          return;
        }

        // 只在认证相关错误（401/403）时尝试重登录
        if (statusCode == 401 || statusCode == 403) {
          try {
            AppLogger.info('检测到认证失败($statusCode)，正在尝试重新登录...');

            // 通知UI层开始重登录
            _notifyRelogging();

            // 使用全局登录锁，确保同一时间只有一个登录请求
            if (await _reLoginWithLock()) {
              AppLogger.info('重新登录成功，正在重试原请求...');

              // 通知UI层重登录成功
              _notifyRelogSuccess();

              // 重登录成功，重新发送请求
              final cookie = await _getCookie();
              if (cookie != null) {
                e.requestOptions.headers['Cookie'] = cookie;
                e.requestOptions.headers['xauat'] = cookie;
              }
              final response = await _dio.request(
                e.requestOptions.path,
                options: Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                  contentType: e.requestOptions.contentType,
                ),
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
              );
              return handler.resolve(response);
            } else {
              AppLogger.warning('重新登录失败，请检查账号密码');

              // 通知UI层重登录失败
              _notifyRelogFailed('账号或密码错误');
            }
          } catch (retryError) {
            // 重新请求失败，继续处理原错误
            AppLogger.debug('重登录后请求失败: $retryError');

            // 通知UI层重登录失败
            _notifyRelogFailed(retryError.toString());
          }
        }

        // 处理其他错误
        handler.next(e);
      },
    ));
  }

  /// 获取当前基础 URL
  @override
  String get baseUrl => _baseUrl;

  /// 暴露 Dio 实例，便于在测试中注入拦截器和验证请求。
  Dio get dio => _dio;

  /// 更新基础 URL
  ///
  /// 用于切换学校时更新 API 地址
  @override
  void updateBaseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;
    _dio.options.baseUrl = newBaseUrl;
  }

  Future<String?> _getCookie() async {
    final prefs = PrefsService.instance;
    final userDataJson = prefs.getString(PrefsKeys.USER_DATA);
    if (userDataJson != null) {
      final userData = jsonDecode(userDataJson);
      return userData['cookie'];
    }
    return null;
  }

  String _resolveLanguageHeaderValue() {
    final prefs = PrefsService.instance;
    final preference = prefs.getString(PrefsKeys.LOCALE_CODE);
    final localeCode = AppLocaleService.fromPreference(preference);
    final locale = AppLocaleService.localeOf(localeCode) ??
        PlatformDispatcher.instance.locale;
    return _languageCodeFromLocale(locale);
  }

  String _languageCodeFromLocale(Locale locale) {
    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hant') {
      return AppLocaleService.zhHantPreferenceValue;
    }
    return locale.languageCode;
  }

  int get _nowMs =>
      _nowProviderForTest?.call() ?? DateTime.now().millisecondsSinceEpoch;

  DioException? _createRateLimitExceptionIfCoolingDown(RequestOptions options) {
    _cleanupExpiredRateLimitCooldowns();
    final requestKey = _buildRequestFingerprint(options);
    final cooldownUntil = _rateLimitCooldowns[requestKey];
    if (cooldownUntil == null || cooldownUntil <= _nowMs) {
      return null;
    }

    AppLogger.debug('请求命中限流冷却: $requestKey');
    return _buildRateLimitException(options);
  }

  void _recordRateLimit(RequestOptions options) {
    final requestKey = _buildRequestFingerprint(options);
    _rateLimitCooldowns[requestKey] = _nowMs + _rateLimitCooldownMs;
    AppLogger.warning('请求触发限流，进入冷却: $requestKey');
  }

  void _cleanupExpiredRateLimitCooldowns() {
    final now = _nowMs;
    _rateLimitCooldowns.removeWhere((_, cooldownUntil) => cooldownUntil <= now);
  }

  String _buildRequestFingerprint(RequestOptions options) {
    return jsonEncode(<String, dynamic>{
      'method': options.method,
      'path': options.path,
      'queryParameters': _normalizeRequestValue(options.queryParameters),
      'data': _normalizeRequestValue(options.data),
    });
  }

  dynamic _normalizeRequestValue(dynamic value) {
    if (value is Map) {
      final sortedEntries = value.entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      return <String, dynamic>{
        for (final entry in sortedEntries)
          entry.key.toString(): _normalizeRequestValue(entry.value),
      };
    }
    if (value is List) {
      return value.map(_normalizeRequestValue).toList();
    }
    if (value is FormData) {
      return <String, dynamic>{
        'fields': value.fields
            .map((field) => <String, dynamic>{
                  'key': field.key,
                  'value': field.value,
                })
            .toList(),
        'files': value.files
            .map((file) => <String, dynamic>{
                  'key': file.key,
                  'filename': file.value.filename,
                  'contentType': file.value.contentType?.toString(),
                })
            .toList(),
      };
    }
    return value;
  }

  DioException _buildRateLimitException(
    RequestOptions options, {
    Response<dynamic>? response,
  }) {
    final effectiveResponse = response ??
        Response<dynamic>(
          requestOptions: options,
          statusCode: 429,
          data: _rateLimitMessage,
        );
    return DioException(
      requestOptions: options,
      response: effectiveResponse,
      type: DioExceptionType.badResponse,
      message: _rateLimitMessage,
    );
  }

  /// 带全局锁的重登录方法
  ///
  /// 确保同一时间只有一个登录请求在执行，其他请求等待并复用结果
  Future<bool> _reLoginWithLock() async {
    // 检查是否在冷却期内（防止频繁重试）
    if (_lastLoginFailTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastLoginFailTime! < _loginCooldownMs) {
        AppLogger.debug('登录冷却中，跳过重登录');
        return false;
      }
    }

    // 如果已有登录请求在进行中，等待其完成（最多等待15秒）
    if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
      AppLogger.debug('等待其他登录请求完成...');
      try {
        return await _loginCompleter!.future.timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            AppLogger.warning('等待登录超时，放弃等待');
            return false;
          },
        );
      } catch (e) {
        AppLogger.error('等待登录失败', error: e);
        return false;
      }
    }

    // 创建新的登录 Completer
    _loginCompleter = Completer<bool>();
    AppLogger.debug('开始重登录...');

    try {
      // 添加超时保护：登录最多15秒
      final success = await _reLogin().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          AppLogger.warning('重登录超时');
          return false;
        },
      );

      if (success) {
        AppLogger.debug('重登录成功');
        _lastLoginFailTime = null; // 清除失败时间戳
      } else {
        AppLogger.debug('重登录失败');
        _lastLoginFailTime = DateTime.now().millisecondsSinceEpoch;
      }

      // 完成 Completer，通知所有等待的请求
      _loginCompleter!.complete(success);
      return success;
    } catch (e) {
      AppLogger.error('重登录异常', error: e);
      _lastLoginFailTime = DateTime.now().millisecondsSinceEpoch;

      // 确保 Completer 被完成，即使发生异常
      if (!_loginCompleter!.isCompleted) {
        _loginCompleter!.complete(false);
      }
      return false;
    } finally {
      // 延迟清理 Completer，给其他等待的请求一点时间获取结果
      Future.delayed(const Duration(milliseconds: 100), () {
        _loginCompleter = null;
      });
    }
  }

  Future<bool> _reLogin() async {
    try {
      final prefs = PrefsService.instance;
      final secureStorage = SecureStorageService.instance;
      final username = await secureStorage.read(key: PrefsKeys.USERNAME);
      final password = await secureStorage.read(key: PrefsKeys.PASSWORD);

      if (username == null || password == null) {
        return false;
      }

      final loginResult = _loginHandlerForTest != null
          ? await _loginHandlerForTest!(username, password)
          : await LoginService.login(username, password);

      if (loginResult['success'] == true) {
        await prefs.setString(PrefsKeys.USER_DATA, jsonEncode(loginResult));
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.debug('重登录失败: $e');
      return false;
    }
  }

  /// 通知UI层开始重登录
  void _notifyRelogging() {
    try {
      _authStateCallbacks.onRelogging?.call();
    } catch (e) {
      // 忽略通知失败
      AppLogger.debug('通知重登录状态失败: $e');
    }
  }

  /// 通知UI层重登录成功
  void _notifyRelogSuccess() {
    try {
      _authStateCallbacks.onRelogSuccess?.call();
    } catch (e) {
      AppLogger.debug('通知重登录成功失败: $e');
    }
  }

  /// 通知UI层重登录失败
  void _notifyRelogFailed(String reason) {
    try {
      _authStateCallbacks.onRelogFailed?.call(reason);
    } catch (e) {
      AppLogger.debug('通知重登录失败失败: $e');
    }
  }

  // 通用GET请求方法
  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool bypassCache = false,
  }) async {
    try {
      final mergedOptions = options?.copyWith(
            extra: <String, dynamic>{
              ...?options.extra,
              if (bypassCache) CacheInterceptor.bypassCacheKey: true,
            },
          ) ??
          Options(
            extra: bypassCache
                ? <String, dynamic>{CacheInterceptor.bypassCacheKey: true}
                : null,
          );
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: mergedOptions,
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  // 通用POST请求方法
  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  // 通用DELETE请求方法
  @override
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Never _handleDioException(DioException e) {
    if (e.response?.statusCode == 429) {
      _recordRateLimit(e.requestOptions);
      DioErrorHandler.handleError(_buildRateLimitException(e.requestOptions));
    }
    DioErrorHandler.handleError(e);
  }

  @override
  void dispose() {
    _dio.close();
  }

  static void setLoginHandlerForTest(
      Future<Map<String, dynamic>> Function(String, String)? handler) {
    _loginHandlerForTest = handler;
  }

  static void resetReloginStateForTest() {
    _loginCompleter = null;
    _lastLoginFailTime = null;
    _loginHandlerForTest = null;
    _nowProviderForTest = null;
  }

  static void setLastLoginFailTimeForTest(int? timestampMs) {
    _lastLoginFailTime = timestampMs;
  }

  static void setNowProviderForTest(int Function()? provider) {
    _nowProviderForTest = provider;
  }

  Future<bool> reLoginWithLockForTest() {
    return _reLoginWithLock();
  }
}
