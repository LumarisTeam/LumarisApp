import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';

/// 缓存策略配置
class CachePolicy {
  final Duration maxAge;
  final bool allowStale;

  const CachePolicy({
    this.maxAge = const Duration(minutes: 5),
    this.allowStale = false,
  });

  // 常用缓存策略
  static const CachePolicy defaultPolicy = CachePolicy();
  static const CachePolicy shortTerm =
      CachePolicy(maxAge: Duration(minutes: 1));
  static const CachePolicy mediumTerm =
      CachePolicy(maxAge: Duration(minutes: 15));
  static const CachePolicy longTerm = CachePolicy(maxAge: Duration(hours: 1));
  static const CachePolicy veryLongTerm =
      CachePolicy(maxAge: Duration(days: 1));
}

/// 缓存条目模型
class CacheEntry {
  final dynamic data;
  final int expiryTime; // millisecondsSinceEpoch
  final String? requestUrl;

  CacheEntry({
    required this.data,
    required this.expiryTime,
    this.requestUrl,
  });

  Map<String, dynamic> toJson() => {
        'data': data,
        'expiryTime': expiryTime,
        if (requestUrl != null) 'requestUrl': requestUrl,
      };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
        data: json['data'],
        expiryTime: json['expiryTime'] as int,
        requestUrl: json['requestUrl'] as String?,
      );

  bool get isExpired => DateTime.now().millisecondsSinceEpoch > expiryTime;
}

/// 请求缓存工具类
class RequestCache {
  /// 单例实例
  static final RequestCache instance = RequestCache._internal();

  /// 工厂构造函数
  factory RequestCache() => instance;

  /// 内部构造函数
  RequestCache._internal();

  /// Hive Box
  Box? _box;

  /// 标记是否已初始化
  bool _isInitialized = false;

  /// URL模式到缓存策略的映射（按优先级从高到低排列，默认策略通过方法兜底）
  final Map<RegExp, CachePolicy> _urlCachePolicies = {
    // 课程相关API - 中短期缓存
    RegExp(r'.*/course.*', caseSensitive: false): CachePolicy.mediumTerm,
    // 成绩相关API - 长期缓存
    RegExp(r'.*/score.*', caseSensitive: false): CachePolicy.longTerm,
    // 校巴相关API - 短期缓存
    RegExp(r'.*/bus.*', caseSensitive: false): CachePolicy.shortTerm,
    // 饭卡相关API - 短期缓存
    RegExp(r'.*/payment.*', caseSensitive: false): CachePolicy.shortTerm,
    // 学生信息/时间相关API - 短期缓存
    RegExp(r'.*/info.*', caseSensitive: false): CachePolicy.shortTerm,
    // 电费相关API - 短期缓存
    RegExp(r'.*/electric.*', caseSensitive: false): CachePolicy.shortTerm,
    // 考试相关API - 长期缓存
    RegExp(r'.*/exam.*', caseSensitive: false): CachePolicy.longTerm,
    // 培养方案相关API - 超长期缓存
    RegExp(r'.*/program.*', caseSensitive: false): CachePolicy.veryLongTerm,
    // App信息相关API - 中短期缓存
    RegExp(r'.*/app.*', caseSensitive: false): CachePolicy.mediumTerm,
  };

  /// 初始化缓存
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _box =
          await HiveManager.instance.openBox(HiveManager.requestCacheBoxName);
      _isInitialized = true;

      // 尝试迁移旧数据
      await _migrateFromSharedPreferences();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize RequestCache box',
          error: e, stackTrace: stackTrace);
    }
  }

  /// 从 SharedPreferences 迁移数据到 Hive
  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = PrefsService.instance;
      final keys = prefs.getKeys();
      final cacheKeys = keys
          .where(
              (k) => k.startsWith('request_cache_') && !k.endsWith('_expiry'))
          .toList();

      if (cacheKeys.isEmpty) return;

      AppLogger.info(
          'Migrating ${cacheKeys.length} cache entries from SharedPreferences to Hive...');

      int migratedCount = 0;
      for (final key in cacheKeys) {
        final expiryKey = '${key}_expiry';
        final dataStr = prefs.getString(key);
        final expiryStr = prefs.getString(expiryKey);

        if (dataStr != null && expiryStr != null) {
          try {
            final data = jsonDecode(dataStr);
            final expiryTime = DateTime.parse(expiryStr).millisecondsSinceEpoch;
            final legacyRequest = _parseLegacyCacheKey(key);
            if (legacyRequest == null) {
              AppLogger.warning('Failed to parse legacy cache key: $key');
            } else {
              final migratedKey = _generateCacheKey(
                legacyRequest.url,
                params: legacyRequest.params,
              );
              final entry = CacheEntry(
                data: data,
                expiryTime: expiryTime,
                requestUrl: legacyRequest.url,
              );
              await _box?.put(migratedKey, entry.toJson());
              migratedCount++;
            }
          } catch (e) {
            AppLogger.warning('Failed to migrate cache entry: $key', error: e);
          }
        }

        // 无论迁移成功与否，都删除旧数据
        await prefs.remove(key);
        await prefs.remove(expiryKey);
      }

      AppLogger.info('Migrated $migratedCount cache entries to Hive.');
    } catch (e, stackTrace) {
      AppLogger.error('Error during cache migration',
          error: e, stackTrace: stackTrace);
    }
  }

  /// 根据URL获取缓存策略
  CachePolicy _getCachePolicyForUrl(String url) {
    for (final entry in _urlCachePolicies.entries) {
      if (entry.key.hasMatch(url)) {
        return entry.value;
      }
    }
    return CachePolicy.defaultPolicy;
  }

  /// 生成缓存键
  String _generateCacheKey(String url, {Map<String, dynamic>? params}) {
    final requestIdentity = _buildRequestIdentity(url, params: params);
    return '$_cacheKeyPrefix${_hashRequestIdentity(requestIdentity)}';
  }

  /// 旧版缓存键生成逻辑，用于兼容读取历史缓存
  String _generateLegacyCacheKey(String url, {Map<String, dynamic>? params}) {
    // 空 map 与 null 视为等价，统一序列化为空字符串，避免 key 不一致
    final paramsString =
        (params != null && params.isNotEmpty) ? jsonEncode(params) : '';
    return '$_cacheKeyPrefix${Uri.encodeComponent(url)}_${Uri.encodeComponent(paramsString)}';
  }

  static const String _cacheKeyPrefix = 'request_cache_';

  String _buildRequestIdentity(String url, {Map<String, dynamic>? params}) {
    final paramsString =
        (params != null && params.isNotEmpty) ? jsonEncode(params) : '';
    return '$url::$paramsString';
  }

  String _hashRequestIdentity(String requestIdentity) {
    const int fnvOffsetBasis = 0xcbf29ce484222325;
    const int fnvPrime = 0x100000001b3;
    const int fnv64Mask = 0xFFFFFFFFFFFFFFFF;

    int hash = fnvOffsetBasis;
    for (final byte in utf8.encode(requestIdentity)) {
      hash ^= byte;
      hash = (hash * fnvPrime) & fnv64Mask;
    }

    return hash.toRadixString(16).padLeft(16, '0');
  }

  ({String key, dynamic rawData})? _findRawCacheEntry(
    String url, {
    Map<String, dynamic>? params,
  }) {
    final cacheKey = _generateCacheKey(url, params: params);
    final rawData = _box?.get(cacheKey);
    if (rawData != null) {
      return (key: cacheKey, rawData: rawData);
    }

    final legacyKey = _generateLegacyCacheKey(url, params: params);
    final legacyRawData = _box?.get(legacyKey);
    if (legacyRawData != null) {
      return (key: legacyKey, rawData: legacyRawData);
    }

    return null;
  }

  Future<void> _migrateLegacyEntryIfNeeded(
    String currentKey,
    String url,
    CacheEntry entry, {
    Map<String, dynamic>? params,
  }) async {
    final cacheKey = _generateCacheKey(url, params: params);
    if (currentKey == cacheKey) return;

    final migratedEntry = CacheEntry(
      data: entry.data,
      expiryTime: entry.expiryTime,
      requestUrl: entry.requestUrl ?? url,
    );

    await _box?.put(cacheKey, migratedEntry.toJson());
    await _box?.delete(currentKey);
  }

  ({String url, Map<String, dynamic>? params})? _parseLegacyCacheKey(
      String key) {
    if (!key.startsWith(_cacheKeyPrefix)) return null;

    final rawKey = key.substring(_cacheKeyPrefix.length);
    final separatorIndexes = <int>[];
    for (int i = 0; i < rawKey.length; i++) {
      if (rawKey[i] == '_') {
        separatorIndexes.add(i);
      }
    }

    for (final separatorIndex in separatorIndexes.reversed) {
      final encodedUrl = rawKey.substring(0, separatorIndex);
      final encodedParams = rawKey.substring(separatorIndex + 1);

      try {
        final decodedUrl = Uri.decodeComponent(encodedUrl);
        if (!decodedUrl.startsWith('http://') &&
            !decodedUrl.startsWith('https://')) {
          continue;
        }

        if (encodedParams.isEmpty) {
          return (url: decodedUrl, params: null);
        }

        final decodedParams = Uri.decodeComponent(encodedParams);
        final parsedParams = jsonDecode(decodedParams);
        if (parsedParams is Map<String, dynamic>) {
          return (url: decodedUrl, params: parsedParams);
        }
        if (parsedParams is Map) {
          return (
            url: decodedUrl,
            params: Map<String, dynamic>.from(parsedParams),
          );
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  /// 获取缓存数据
  Future<T?> get<T>(String url,
      {Map<String, dynamic>? params, Duration? maxAge}) async {
    if (!_isInitialized) await initialize();

    final foundEntry = _findRawCacheEntry(url, params: params);
    if (foundEntry == null) return null;

    final cacheKey = foundEntry.key;
    final rawData = foundEntry.rawData;

    try {
      // Hive 中存储的是 Map (json)
      final entry = CacheEntry.fromJson(Map<String, dynamic>.from(rawData));

      if (entry.isExpired) {
        await _box?.delete(cacheKey);
        return null;
      }

      await _migrateLegacyEntryIfNeeded(cacheKey, url, entry, params: params);

      final data = entry.data;

      if (data is T) {
        return data;
      }

      // 尝试类型转换
      if (T == Map && data is List) {
        return {'data': data} as T;
      }

      return data as T?;
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Cache entry parse failed for url="$url" key="$cacheKey" '
        'dataType=${rawData.runtimeType}',
        error: e,
        stackTrace: stackTrace,
      );
      await _box?.delete(cacheKey);
      return null;
    }
  }

  /// 设置缓存数据
  Future<void> set<T>(String url, T data,
      {Map<String, dynamic>? params, Duration? maxAge}) async {
    if (!_isInitialized) await initialize();

    final cacheKey = _generateCacheKey(url, params: params);

    // 使用指定的maxAge或根据URL获取默认策略
    final effectiveMaxAge = maxAge ?? _getCachePolicyForUrl(url).maxAge;

    // 计算过期时间
    final expiryTime =
        DateTime.now().add(effectiveMaxAge).millisecondsSinceEpoch;

    // 存储
    final entry = CacheEntry(
      data: data,
      expiryTime: expiryTime,
      requestUrl: url,
    );
    await _box?.put(cacheKey, entry.toJson());
  }

  /// 删除缓存数据
  Future<void> delete(String url, {Map<String, dynamic>? params}) async {
    if (!_isInitialized) await initialize();
    final cacheKey = _generateCacheKey(url, params: params);
    final legacyKey = _generateLegacyCacheKey(url, params: params);
    await _box?.delete(cacheKey);
    await _box?.delete(legacyKey);
  }

  /// 删除匹配URL模式的所有缓存
  Future<void> deleteByPattern(RegExp pattern) async {
    if (!_isInitialized) await initialize();

    final keys = _box?.keys.cast<String>() ?? [];
    for (final key in keys) {
      final rawData = _box?.get(key);
      if (rawData == null) {
        continue;
      }

      try {
        final entry = CacheEntry.fromJson(Map<String, dynamic>.from(rawData));
        final requestUrl = entry.requestUrl ?? _parseLegacyCacheKey(key)?.url;
        if (requestUrl != null && pattern.hasMatch(requestUrl)) {
          await _box?.delete(key);
        }
      } catch (e) {
        AppLogger.debug('解析缓存键失败: $e');
      }
    }
  }

  /// 清除所有缓存
  Future<void> clear() async {
    if (!_isInitialized) await initialize();
    await _box?.clear();
  }

  /// 清除所有已过期的缓存条目
  Future<int> clearExpired() async {
    if (!_isInitialized) await initialize();

    final keys = _box?.keys.cast<String>().toList() ?? [];
    int removed = 0;
    for (final key in keys) {
      final rawData = _box?.get(key);
      if (rawData == null) continue;
      try {
        final entry = CacheEntry.fromJson(Map<String, dynamic>.from(rawData));
        if (entry.isExpired) {
          await _box?.delete(key);
          removed++;
        }
      } catch (e, stackTrace) {
        // 无法解析的条目视为损坏，一并清除
        AppLogger.warning('Corrupt cache entry removed: key="$key"',
            error: e, stackTrace: stackTrace);
        await _box?.delete(key);
        removed++;
      }
    }
    AppLogger.info('Cleared $removed expired cache entries.');
    return removed;
  }

  /// 获取缓存大小 (字节数 - 估算)
  Future<int> getCacheSize() async {
    if (!_isInitialized) await initialize();

    // Hive 不直接提供字节大小，这里只能返回条目数或者做一个粗略估算
    // 为了兼容旧接口，我们尽量返回一个有意义的数字
    // 这里简单返回条目数 * 平均大小(假设1KB)
    return (_box?.length ?? 0) * 1024;
  }

  /// 添加自定义URL缓存策略
  void addUrlCachePolicy(RegExp urlPattern, CachePolicy policy) {
    _urlCachePolicies[urlPattern] = policy;
  }
}

/// 缓存拦截器
class CacheInterceptor extends Interceptor {
  final RequestCache _cache = RequestCache();
  static const String bypassCacheKey = 'bypassCache';

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final bypassCache = options.extra[bypassCacheKey] == true;

    // 只有GET请求才使用缓存
    if (options.method == 'GET' && !bypassCache) {
      try {
        final cachedData = await _cache.get(
          options.uri.toString(),
          params: options.queryParameters,
        );
        if (cachedData != null) {
          final response = Response(
            data: cachedData,
            requestOptions: options,
            statusCode: 200,
            statusMessage: 'OK (from cache)',
          );
          return handler.resolve(response);
        }
      } catch (error) {
        // Cache availability must never prevent the network request. This also
        // keeps isolated widget hosts independent from Hive initialization.
        AppLogger.warning('Request cache unavailable; bypassing cache',
            error: error);
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // 只有GET请求才缓存
    if (response.requestOptions.method == 'GET' && response.statusCode == 200) {
      try {
        await _cache.set(
          response.requestOptions.uri.toString(),
          response.data,
          params: response.requestOptions.queryParameters,
        );
      } catch (error) {
        AppLogger.warning('Request cache unavailable; response not cached',
            error: error);
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 如果网络错误且允许使用过期缓存，可以考虑返回过期缓存
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      // 只有GET请求才尝试使用过期缓存
      if (err.requestOptions.method == 'GET') {
        final policy =
            _cache._getCachePolicyForUrl(err.requestOptions.uri.toString());
        if (policy.allowStale) {
          // 尝试获取过期缓存
          final cacheKey = _cache._generateCacheKey(
            err.requestOptions.uri.toString(),
            params: err.requestOptions.queryParameters,
          );

          if (!_cache._isInitialized) await _cache.initialize();
          final rawData = _cache._box?.get(cacheKey) ??
              _cache._box?.get(
                _cache._generateLegacyCacheKey(
                  err.requestOptions.uri.toString(),
                  params: err.requestOptions.queryParameters,
                ),
              );

          if (rawData != null) {
            try {
              final entry =
                  CacheEntry.fromJson(Map<String, dynamic>.from(rawData));
              // 不检查过期时间，直接使用
              final response = Response(
                data: entry.data,
                requestOptions: err.requestOptions,
                statusCode: 200,
                statusMessage: 'OK (from stale cache)',
              );
              return handler.resolve(response);
            } catch (e) {
              // 解析失败，继续处理错误
            }
          }
        }
      }
    }
    handler.next(err);
  }
}
