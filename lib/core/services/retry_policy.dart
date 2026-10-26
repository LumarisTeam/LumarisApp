import 'package:dio/dio.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 重试策略配置
class RetryPolicy {
  /// 最大重试次数
  final int maxRetries;

  /// 重试延迟计算方式（指数退避）
  final Duration Function(int attempt) delayFactor;

  /// 判断是否应该重试的函数
  final bool Function(DioException error) shouldRetry;

  const RetryPolicy({
    this.maxRetries = 2,
    this.delayFactor = _defaultDelayFactor,
    this.shouldRetry = defaultShouldRetry,
  });

  /// 默认延迟计算：指数退避 (500ms, 1000ms, 1500ms, ...)
  static Duration _defaultDelayFactor(int attempt) {
    return Duration(milliseconds: 500 * (attempt + 1));
  }

  /// 默认重试判断逻辑
  static bool defaultShouldRetry(DioException e) {
    // 网络超时，应该重试
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return true;
    }

    // 服务器错误（5xx），可能是临时问题，应该重试
    final statusCode = e.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return true;
    }

    // 认证错误（401/403）和其他客户端错误（4xx）不重试
    return false;
  }

  /// 预定义策略：默认策略（2次重试）
  static const RetryPolicy defaultPolicy = RetryPolicy();

  /// 预定义策略：快速重试（3次重试，较短延迟）
  static const RetryPolicy fast = RetryPolicy(
    maxRetries: 3,
    delayFactor: _fastDelayFactor,
  );

  static Duration _fastDelayFactor(int attempt) {
    return Duration(milliseconds: 300 * (attempt + 1));
  }

  /// 预定义策略：无重试
  static const RetryPolicy none = RetryPolicy(maxRetries: 0);
}

/// 重试拦截器
///
/// 自动处理网络请求的重试逻辑，支持：
/// - 可配置的最大重试次数
/// - 指数退避延迟
/// - 自定义重试条件
class RetryInterceptor extends Interceptor {
  final RetryPolicy policy;
  final Dio dio;

  RetryInterceptor({required this.dio, this.policy = const RetryPolicy()});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = _getAttempt(err.requestOptions);

    if (attempt < policy.maxRetries && policy.shouldRetry(err)) {
      final delay = policy.delayFactor(attempt);
      AppLogger.debug(
        '请求失败，${delay.inMilliseconds}ms 后重试 (${attempt + 1}/${policy.maxRetries})',
      );

      await Future.delayed(delay);

      try {
        // 增加重试计数
        err.requestOptions.extra['retryAttempt'] = attempt + 1;

        final response = await dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
            contentType: err.requestOptions.contentType,
            responseType: err.requestOptions.responseType,
            extra: err.requestOptions.extra,
          ),
        );
        return handler.resolve(response);
      } on DioException catch (e) {
        // 重试失败，继续传递错误（可能触发下一次重试）
        return handler.next(e);
      }
    }

    handler.next(err);
  }

  int _getAttempt(RequestOptions options) {
    return options.extra['retryAttempt'] as int? ?? 0;
  }
}

/// 错误处理工具类
///
/// 提供统一的 Dio 错误处理方法
class DioErrorHandler {
  /// 处理 Dio 错误并抛出对应的 NetworkException
  static Never handleError(DioException e) {
    AppLogger.error('HTTP Error: ${e.message}');

    if (e.response != null) {
      handleErrorResponse(
        e.response!.statusCode ?? -1,
        e.response!.data?.toString() ?? '',
      );
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw TimeoutException();
    } else {
      throw NetworkException('网络连接失败: ${e.message}', -1);
    }
  }

  /// 根据 HTTP 状态码抛出对应的异常
  static Never handleErrorResponse(int statusCode, String body) {
    switch (statusCode) {
      case 401:
        throw AuthenticationException('认证失败');
      case 403:
        throw AuthorizationException('权限不足');
      case 404:
        throw NotFoundException('资源未找到');
      case 429:
        throw NetworkException('已被限流，请稍后再试', 429);
      case 500:
        throw ServerException('服务器内部错误');
      default:
        throw NetworkException('请求失败: $body', statusCode);
    }
  }
}
