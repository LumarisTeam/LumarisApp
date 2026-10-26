import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ios_club_app/core/models/result.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'error_logger.dart';

/// 统一的错误处理工具类
///
/// 提供异常映射、错误包装等功能，用于统一处理各种错误场景
class ErrorHandler {
  /// 将各种异常映射到AppError
  ///
  /// 支持的异常类型：
  /// - NetworkException及其子类
  /// - DioException
  /// - SocketException
  /// - TimeoutException
  /// - FormatException
  /// - 其他通用异常
  static AppError mapExceptionToAppError(
    Object error, [
    StackTrace? stackTrace,
  ]) {
    // 记录错误到日志
    ErrorLogger.logError(error, stackTrace);

    // 处理自定义网络异常
    if (error is NetworkException) {
      return _handleNetworkException(error);
    }

    // 处理Dio异常
    if (error is DioException) {
      return _handleDioException(error);
    }

    // 处理Socket异常
    if (error is SocketException) {
      return AppError.network('网络连接失败', originalError: error);
    }

    // 处理超时异常
    if (error is TimeoutException) {
      return AppError.network('请求超时，请检查网络连接', originalError: error);
    }

    // 处理格式异常（通常是JSON解析错误）
    if (error is FormatException) {
      return AppError.parsing('数据格式错误', originalError: error);
    }

    // 处理类型错误
    if (error is TypeError) {
      return AppError.parsing('数据类型错误', originalError: error);
    }

    // 未知错误
    return AppError.unknown(error.toString(), originalError: error);
  }

  /// 处理NetworkException及其子类
  static AppError _handleNetworkException(NetworkException error) {
    if (error is AuthenticationException) {
      return AppError.authentication(error.message, code: error.statusCode);
    }

    if (error is AuthorizationException) {
      return AppError.authorization(error.message);
    }

    if (error is NotFoundException) {
      return AppError.server(error.message, statusCode: error.statusCode);
    }

    if (error is ServerException) {
      return AppError.server(error.message, statusCode: error.statusCode);
    }

    if (error is TimeoutException) {
      return AppError.network('请求超时', originalError: error);
    }

    return AppError.network(error.message, originalError: error);
  }

  /// 处理DioException
  static AppError _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError.network('请求超时，请检查网络连接', originalError: error);

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          return _handleHttpStatusCode(statusCode, error);
        }
        return AppError.server('服务器响应错误', statusCode: statusCode);

      case DioExceptionType.cancel:
        return AppError.unknown('请求已取消', originalError: error);

      case DioExceptionType.connectionError:
        return AppError.network('网络连接失败，请检查网络设置', originalError: error);

      case DioExceptionType.badCertificate:
        return AppError.network('证书验证失败', originalError: error);

      case DioExceptionType.unknown:
        return AppError.network('网络请求失败', originalError: error);
    }
  }

  /// 根据HTTP状态码返回对应的AppError
  static AppError _handleHttpStatusCode(int statusCode, DioException error) {
    switch (statusCode) {
      case 400:
        return AppError.validation('请求参数错误');
      case 401:
        return AppError.authentication('认证失败，请重新登录');
      case 403:
        return AppError.authorization('权限不足');
      case 404:
        return AppError.server('请求的资源不存在', statusCode: statusCode);
      case 500:
        return AppError.server('服务器内部错误', statusCode: statusCode);
      case 502:
        return AppError.server('网关错误', statusCode: statusCode);
      case 503:
        return AppError.server('服务暂时不可用', statusCode: statusCode);
    }

    // 处理其他状态码
    if (statusCode >= 400 && statusCode < 500) {
      return AppError.validation('请求错误');
    } else if (statusCode >= 500) {
      return AppError.server('服务器错误', statusCode: statusCode);
    }
    return AppError.unknown('未知错误', originalError: error);
  }

  /// 包装异步操作为Result
  ///
  /// 自动捕获异常并转换为Result.failure
  ///
  /// 使用示例：
  /// ```dart
  /// final result = await ErrorHandler.wrapWithResult(() async {
  ///   return await apiService.getData();
  /// });
  /// ```
  static Future<Result<T>> wrapWithResult<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final data = await operation();
      return Result.success(data);
    } catch (e, stackTrace) {
      final error = mapExceptionToAppError(e, stackTrace);
      return Result.failure(error);
    }
  }

  /// 包装同步操作为Result
  ///
  /// 自动捕获异常并转换为Result.failure
  static Result<T> wrapWithResultSync<T>(T Function() operation) {
    try {
      final data = operation();
      return Result.success(data);
    } catch (e, stackTrace) {
      final error = mapExceptionToAppError(e, stackTrace);
      return Result.failure(error);
    }
  }
}
