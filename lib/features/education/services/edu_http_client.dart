import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../core/services/app_locale_service.dart';
import '../../../core/services/base_http_client.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/services/retry_policy.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/request_cache.dart';
import '../../../state/prefs_keys.dart';
import '../../basic/models/school.dart';
import 'auth_service.dart';
import 'auth_session_guard.dart';
import 'login_mode_service.dart';

typedef RelogFailedCallback = void Function(String reason);
typedef _RateLimitScope = (String, String, String);

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

/// 教务 API 的认证策略。
///
/// HTTP 传输、重试、缓存和错误转换由 [BaseHttpClient] 统一提供；此类只
/// 保留教务域特有的 Cookie、限流与重登录行为。
class EduHttpClient extends BaseHttpClient {
  static const String renewSessionKey = 'edu_renew_session';
  static const String _rateLimitMessage = '已被限流，请稍后再试';
  static const int _rateLimitCooldownMs = 5000;

  final AuthStateCallbacks _authStateCallbacks;
  final Map<_RateLimitScope, int> _rateLimitCooldowns = {};
  String _baseUrl;

  /// 最后一次登录失败的时间戳，用于防止频繁重试
  static (int, int)? _lastLoginFailure;

  /// 登录失败后的冷却时间（毫秒）
  static const int _loginCooldownMs = 5000;

  /// 同一请求因 401 重登录后只允许重试一次。
  ///
  /// 没有这道闸时，只要重登录本身成功、但原请求仍返回 401（研究生模式下访问
  /// 成绩/考试等尚未支持的接口就是这样），拦截器会「重登录 → 重试 → 再 401」
  /// 无限递归。
  static const String _reloginRetriedKey = 'edu_relogin_retried';
  static const String _sessionEpochKey = 'edu_session_epoch';
  static const String _rateLimitScopeKey = 'edu_rate_limit_scope';
  static const String _localRateLimitKey = 'edu_local_rate_limit';

  // Test hook: allows injecting deterministic login behavior in unit tests.
  static Future<Map<String, dynamic>> Function(String, String)?
  _loginHandlerForTest;
  static int Function()? _nowProviderForTest;

  EduHttpClient({
    super.dio,
    String? baseUrl,
    AuthStateCallbacks authStateCallbacks = AuthStateCallbacks.noop,
  }) : _authStateCallbacks = authStateCallbacks,
       _baseUrl = baseUrl ?? School.fallbackList.first.website,
       super(
         baseUrl: baseUrl ?? School.fallbackList.first.website,
         retryPolicy: const RetryPolicy(shouldRetry: _shouldRetry),
         defaultHeaders: const <String, dynamic>{
           'Accept': 'application/json',
           'Content-Type': 'application/json',
         },
       ) {
    _setupEducationInterceptors();
  }

  void _setupEducationInterceptors() {
    // 添加认证拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final int epoch =
              options.extra.putIfAbsent(
                    _sessionEpochKey,
                    () => AuthSessionGuard.epoch,
                  )
                  as int;
          if (!AuthSessionGuard.isCurrent(epoch)) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.cancel,
              ),
            );
            return;
          }

          // 自动添加认证cookie
          final session = _getSession();
          final cookie = session?['cookie'];
          if (cookie != null) {
            options.headers['Cookie'] = cookie;
            options.headers['xauat'] = cookie;
          }
          options.headers.putIfAbsent(
            'x-language',
            _resolveLanguageHeaderValue,
          );

          // 登录成功后记录的系统类型（本科生 0 / 研究生 1），随每个教务请求发出。
          // 登录请求自己在 Options 里显式传了本次选中的值，putIfAbsent 不会覆盖它。
          options.headers.putIfAbsent(
            LoginModeService.headerName,
            () => LoginModeService.currentHeaderValue,
          );
          final scope = _rateLimitScope(options, session);
          options.extra[_rateLimitScopeKey] = scope;
          final rateLimitException = _createRateLimitExceptionIfCoolingDown(
            options,
            scope,
          );
          if (rateLimitException != null) {
            handler.reject(rateLimitException);
            return;
          }
          handler.next(options);
        },
        onError: (DioException e, handler) async {
          final statusCode = e.response?.statusCode;

          // 只在认证相关错误（401/403）时尝试重登录
          if ((statusCode == 401 || statusCode == 403) &&
              !_isLogin(e.requestOptions)) {
            final int requestEpoch =
                e.requestOptions.extra[_sessionEpochKey] as int? ??
                AuthSessionGuard.epoch;
            if (!AuthSessionGuard.isCurrent(requestEpoch)) {
              handler.next(e);
              return;
            }
            if (e.requestOptions.extra[_reloginRetriedKey] == true) {
              _lastLoginFailure = (requestEpoch, _nowMs);
              AppLogger.debug('重登录后仍返回 $statusCode，放弃再次重登录');
              handler.next(e);
              return;
            }

            try {
              final cookie = _getSession()?['cookie'];
              final bool hasFreshCookie =
                  cookie != null &&
                  cookie != e.requestOptions.headers['Cookie'];
              if (!hasFreshCookie) {
                AppLogger.info('检测到认证失败($statusCode)，正在尝试重新登录...');
                _notifyRelogging();
              }
              if (hasFreshCookie || await _reLoginWithLock()) {
                if (!AuthSessionGuard.isCurrent(requestEpoch)) {
                  // 重登录期间用户已登出，不再继续重试原请求。
                  AppLogger.info('重登录期间会话已被清空，放弃本次重试');
                  handler.next(e);
                  return;
                }

                AppLogger.info('重新登录成功，正在重试原请求...');

                // 通知UI层重登录成功
                if (!hasFreshCookie) _notifyRelogSuccess();

                // 标记已重试，避免重试仍 401 时再次进入本分支
                final response = await dio.fetch<dynamic>(
                  e.requestOptions.copyWith(
                    extra: {
                      ...e.requestOptions.extra,
                      _reloginRetriedKey: true,
                    },
                  ),
                );
                return handler.resolve(response);
              } else {
                AppLogger.warning('重新登录失败，请检查账号密码');

                // 通知UI层重登录失败；已登出时不再提示，避免误导。
                if (AuthSessionGuard.isCurrent(requestEpoch)) {
                  _notifyRelogFailed('账号或密码错误');
                }
              }
            } catch (retryError) {
              if (retryError is DioException &&
                  retryError.response?.statusCode == 429) {
                handler.next(retryError);
                return;
              }
              // 重新请求失败，继续处理原错误
              AppLogger.debug('重登录后请求失败: $retryError');

              // 通知UI层重登录失败；已登出时不再提示，避免误导。
              if (AuthSessionGuard.isCurrent(requestEpoch)) {
                _notifyRelogFailed(retryError.toString());
              }
            }
          }

          // 处理其他错误
          handler.next(e);
        },
      ),
    );
  }

  /// 获取当前基础 URL
  String get baseUrl => _baseUrl;

  /// 暴露 Dio 实例，便于在测试中注入拦截器和验证请求。
  /// 更新基础 URL
  ///
  /// 用于切换学校时更新 API 地址
  void updateBaseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;
    dio.options.baseUrl = newBaseUrl;
  }

  static bool _isLogin(RequestOptions options) =>
      options.method == 'POST' &&
      options.uri.pathSegments.lastOrNull?.toLowerCase() == 'login';

  static bool _shouldRetry(DioException error) =>
      !_isLogin(error.requestOptions) && RetryPolicy.defaultShouldRetry(error);

  static bool _usesEducationAccount(Uri uri) {
    final String path = uri.path.toLowerCase();
    return const [
      '/course',
      '/exam',
      '/info/completion',
      '/program',
      '/program/getdic',
      '/score',
      '/score/semester',
      '/score/thissemester',
    ].any(path.endsWith);
  }

  Map<String, dynamic>? _getSession() {
    final String? stored = PrefsService.instance.getString(PrefsKeys.USER_DATA);
    if (stored == null) return null;
    try {
      final Object? session = jsonDecode(stored);
      return session is Map<String, dynamic> ? session : null;
    } on FormatException {
      return null;
    }
  }

  String _resolveLanguageHeaderValue() {
    final prefs = PrefsService.instance;
    final preference = prefs.getString(PrefsKeys.LOCALE_CODE);
    final localeCode = AppLocaleService.fromPreference(preference);
    final locale =
        AppLocaleService.localeOf(localeCode) ??
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

  _RateLimitScope _rateLimitScope(
    RequestOptions options,
    Map<String, dynamic>? session,
  ) {
    final Uri uri = options.uri;
    final data = options.data;
    final Object? storedStudentId = session?['studentId'];
    final String? studentId = storedStudentId is String
        ? storedStudentId.split(',').first.trim()
        : null;
    final Object? account;
    if (_isLogin(options) && data is Map) {
      final Object? username = data['username'];
      final String? storedUsername = PrefsService.instance.getString(
        PrefsKeys.USERNAME,
      );
      account =
          options.extra[renewSessionKey] == true || username == storedUsername
          ? studentId ?? username
          : username;
    } else {
      account = _usesEducationAccount(uri)
          ? studentId ?? options.queryParameters['studentId']
          : null;
    }
    final String identity = account is String && account.isNotEmpty
        ? 'account:${account.trim()}'
        : 'request:${options.method} ${uri.path}?${uri.query}';
    return (
      uri.origin,
      options.headers[LoginModeService.headerName].toString(),
      identity,
    );
  }

  DioException? _createRateLimitExceptionIfCoolingDown(
    RequestOptions options,
    _RateLimitScope scope,
  ) {
    final int now = _nowMs;
    _rateLimitCooldowns.removeWhere((_, cooldownUntil) => cooldownUntil <= now);
    if (!_rateLimitCooldowns.containsKey(scope)) return null;

    return DioException(
      requestOptions: options,
      response: Response<dynamic>(
        requestOptions: options,
        statusCode: 429,
        data: _rateLimitMessage,
        extra: {_localRateLimitKey: true},
      ),
      type: DioExceptionType.badResponse,
      message: _rateLimitMessage,
    );
  }

  void _recordRateLimit(DioException error, Response<dynamic> response) {
    if (response.extra[_localRateLimitKey] == true) return;
    final Object? scope = error.requestOptions.extra[_rateLimitScopeKey];
    if (scope is! _RateLimitScope) return;

    final int now = _nowMs;
    final int until = _retryUntil(response, now);
    if (until > (_rateLimitCooldowns[scope] ?? now)) {
      _rateLimitCooldowns[scope] = until;
    }
    AppLogger.warning('教务请求触发限流，冷却 ${until - now} 毫秒');
  }

  int _retryUntil(Response<dynamic> response, int now) {
    final String? retryAfter = response.headers['retry-after']?.firstOrNull;
    final int? seconds = int.tryParse(retryAfter?.trim() ?? '');
    if (seconds != null && seconds >= 0) return now + seconds * 1000;

    if (retryAfter != null && retryAfter.endsWith(' GMT')) {
      try {
        final DateTime deadline = DateFormat(
          'EEE, dd MMM yyyy HH:mm:ss',
          'en_US',
        ).parseStrict(retryAfter.substring(0, retryAfter.length - 4), true);
        return deadline.millisecondsSinceEpoch < now
            ? now
            : deadline.millisecondsSinceEpoch;
      } on FormatException {
        // 等待时间无法解析时使用默认冷却。
      }
    }
    final Object? body = response.data;
    final Object? bodySeconds = body is Map ? body['retryAfterSeconds'] : null;
    final int? retryAfterSeconds = int.tryParse(bodySeconds?.toString() ?? '');
    return now +
        (retryAfterSeconds != null && retryAfterSeconds >= 0
            ? retryAfterSeconds * 1000
            : _rateLimitCooldownMs);
  }

  static final Map<int, Future<bool>> _relogins = {};

  Future<bool> _reLoginWithLock() async {
    final int epoch = AuthSessionGuard.epoch;
    final failure = _lastLoginFailure;
    if (failure != null &&
        failure.$1 == epoch &&
        _nowMs - failure.$2 < _loginCooldownMs) {
      return false;
    }

    final existing = _relogins[epoch];
    if (existing != null) return existing;

    final login = _reLogin(epoch);
    _relogins[epoch] = login;
    try {
      final bool success = await login;
      if (!success && AuthSessionGuard.isCurrent(epoch)) {
        _lastLoginFailure = (epoch, _nowMs);
      }
      return success;
    } finally {
      _relogins.remove(epoch);
    }
  }

  Future<bool> _reLogin(int epoch) async {
    final loginHandler = _loginHandlerForTest;
    if (loginHandler == null) return AuthService.login();

    try {
      final secureStorage = SecureStorageService.instance;
      final username = await secureStorage.read(key: PrefsKeys.USERNAME);
      final password = await secureStorage.read(key: PrefsKeys.PASSWORD);
      if (username == null ||
          password == null ||
          !AuthSessionGuard.isCurrent(epoch)) {
        return false;
      }

      final loginResult = await loginHandler(username, password);
      if (loginResult['success'] != true) return false;
      return await _persistReLoginResult(jsonEncode(loginResult), epoch);
    } catch (e) {
      AppLogger.debug('重登录失败: $e');
      return false;
    }
  }

  /// 写入重登录结果。
  ///
  /// 写入前后校验代际，避免用户已登出后又被在途的重登录写回登录态。
  Future<bool> _persistReLoginResult(String json, int epoch) async {
    if (!AuthSessionGuard.isCurrent(epoch)) {
      AppLogger.info('重登录会话已失效，丢弃过期的登录结果');
      return false;
    }

    final prefs = PrefsService.instance;
    await prefs.setString(PrefsKeys.USER_DATA, json);

    if (!AuthSessionGuard.isCurrent(epoch)) {
      await prefs.remove(PrefsKeys.USER_DATA);
      AppLogger.info('重登录会话在写入期间失效，已回滚登录态');
      return false;
    }

    return true;
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
      final mergedOptions =
          options?.copyWith(
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
      final response = await dio.get(
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
      final response = await dio.post(
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
      final response = await dio.delete(
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
    final response = e.response;
    if (response != null && response.statusCode == 429) {
      _recordRateLimit(e, response);
    }
    DioErrorHandler.handleError(e);
  }

  static void setLoginHandlerForTest(
    Future<Map<String, dynamic>> Function(String, String)? handler,
  ) {
    _loginHandlerForTest = handler;
  }

  static void resetReloginStateForTest() {
    _relogins.clear();
    _lastLoginFailure = null;
    _loginHandlerForTest = null;
    _nowProviderForTest = null;
  }

  static void setLastLoginFailTimeForTest(int? timestampMs) {
    _lastLoginFailure = timestampMs == null
        ? null
        : (AuthSessionGuard.epoch, timestampMs);
  }

  static void setNowProviderForTest(int Function()? provider) {
    _nowProviderForTest = provider;
  }

  Future<bool> reLoginWithLockForTest() {
    return _reLoginWithLock();
  }
}
