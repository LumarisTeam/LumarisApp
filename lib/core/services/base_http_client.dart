import 'package:dio/dio.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/core/services/retry_policy.dart';

/// 基础 HTTP 客户端
///
/// 提供统一的 HTTP 请求功能，包括：
/// - 自动重试（通过 RetryInterceptor）
/// - 缓存支持（通过 CacheInterceptor）
/// - 统一的错误处理
class BaseHttpClient {
  final Dio _dio;
  final RetryPolicy _retryPolicy;

  BaseHttpClient({
    Dio? dio,
    String? baseUrl,
    RetryPolicy retryPolicy = const RetryPolicy(),
    bool enableCache = true,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 10),
    Map<String, dynamic>? defaultHeaders,
  }) : _retryPolicy = retryPolicy,
       _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers:
          defaultHeaders ??
          {'Accept': 'application/json', 'Content-Type': 'application/json'},
    );

    // 添加重试拦截器
    if (_retryPolicy.maxRetries > 0) {
      _dio.interceptors.add(RetryInterceptor(dio: _dio, policy: _retryPolicy));
    }

    // 添加缓存拦截器
    if (enableCache) {
      _dio.interceptors.add(CacheInterceptor());
    }
  }

  /// 获取 Dio 实例（用于添加自定义拦截器）
  Dio get dio => _dio;

  /// GET 请求
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final requestTarget = _resolveRequestTarget(path, queryParameters);
      final response = await _dio.get(
        requestTarget.path,
        queryParameters: requestTarget.queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      DioErrorHandler.handleError(e);
    }
  }

  /// POST 请求
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final requestTarget = _resolveRequestTarget(path, queryParameters);
      final response = await _dio.post(
        requestTarget.path,
        data: data,
        queryParameters: requestTarget.queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      DioErrorHandler.handleError(e);
    }
  }

  /// PUT 请求
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final requestTarget = _resolveRequestTarget(path, queryParameters);
      final response = await _dio.put(
        requestTarget.path,
        data: data,
        queryParameters: requestTarget.queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      DioErrorHandler.handleError(e);
    }
  }

  /// DELETE 请求
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final requestTarget = _resolveRequestTarget(path, queryParameters);
      final response = await _dio.delete(
        requestTarget.path,
        data: data,
        queryParameters: requestTarget.queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      DioErrorHandler.handleError(e);
    }
  }

  /// 下载文件（返回字节数据）
  Future<List<int>> downloadBytes(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final requestTarget = _resolveRequestTarget(url, queryParameters);
      final response = await _dio.get<List<int>>(
        requestTarget.path,
        queryParameters: requestTarget.queryParameters,
        options: (options ?? Options()).copyWith(
          responseType: ResponseType.bytes,
        ),
      );
      return response.data ?? [];
    } on DioException catch (e) {
      DioErrorHandler.handleError(e);
    }
  }

  /// 关闭客户端
  void dispose() {
    _dio.close();
  }

  _ResolvedRequestTarget _resolveRequestTarget(
    String path,
    Map<String, dynamic>? queryParameters,
  ) {
    final uri = Uri.parse(path);
    final mergedQueryParameters = <String, dynamic>{
      ..._extractQueryParameters(uri),
      ...?queryParameters,
    };

    return _ResolvedRequestTarget(
      path: uri.hasQuery ? uri.replace(query: null).toString() : path,
      queryParameters: mergedQueryParameters.isEmpty
          ? null
          : mergedQueryParameters,
    );
  }

  Map<String, dynamic> _extractQueryParameters(Uri uri) {
    if (!uri.hasQuery) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{
      for (final entry in uri.queryParametersAll.entries)
        entry.key: entry.value.length == 1 ? entry.value.single : entry.value,
    };
  }
}

class _ResolvedRequestTarget {
  const _ResolvedRequestTarget({
    required this.path,
    required this.queryParameters,
  });

  final String path;
  final Map<String, dynamic>? queryParameters;
}
