/// 统一的Result类型，用于封装操作结果
///
/// 使用示例：
/// ```dart
/// // 服务层
/// Future<Result<List<Article>>> getAllArticles() async {
///   try {
///     final response = await apiClient.get('/articles');
///     final articles = parseArticles(response);
///     return Result.success(articles);
///   } catch (e) {
///     return Result.failure(AppError.network(e.toString()));
///   }
/// }
///
/// // UI层
/// final result = await service.getAllArticles();
/// result.when(
///   success: (articles) => setState(() => _articles = articles),
///   failure: (error) => showError(error.userMessage),
/// );
/// ```
class Result<T> {
  final T? _data;
  final AppError? _error;
  final bool isSuccess;

  const Result._({T? data, AppError? error, required this.isSuccess})
    : _data = data,
      _error = error;

  /// 创建成功结果
  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }

  /// 创建失败结果
  factory Result.failure(AppError error) {
    return Result._(error: error, isSuccess: false);
  }

  /// 从异步操作创建Result
  static Future<Result<T>> fromAsync<T>(
    Future<T> Function() operation, {
    AppError Function(Object error)? errorMapper,
  }) async {
    try {
      final data = await operation();
      return Result.success(data);
    } catch (e) {
      final error = errorMapper?.call(e) ?? AppError.unknown(e.toString());
      return Result.failure(error);
    }
  }

  /// 获取数据（成功时）
  T get data {
    if (!isSuccess) {
      throw StateError('Cannot access data on failed Result');
    }
    return _data!;
  }

  /// 获取错误（失败时）
  AppError get error {
    if (isSuccess) {
      throw StateError('Cannot access error on successful Result');
    }
    return _error!;
  }

  /// 安全获取数据，失败时返回null
  T? get dataOrNull => _data;

  /// 获取数据或默认值
  T getOrDefault(T defaultValue) => _data ?? defaultValue;

  /// 获取数据或通过函数计算默认值
  T getOrElse(T Function() defaultValue) => _data ?? defaultValue();

  /// 模式匹配处理结果
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  }) {
    if (isSuccess) {
      return success(_data as T);
    } else {
      return failure(_error!);
    }
  }

  /// 异步模式匹配处理结果
  Future<R> whenAsync<R>({
    required Future<R> Function(T data) success,
    required Future<R> Function(AppError error) failure,
  }) async {
    if (isSuccess) {
      return await success(_data as T);
    } else {
      return await failure(_error!);
    }
  }

  /// 仅在成功时执行操作
  void onSuccess(void Function(T data) action) {
    if (isSuccess) {
      action(_data as T);
    }
  }

  /// 仅在失败时执行操作
  void onFailure(void Function(AppError error) action) {
    if (!isSuccess) {
      action(_error!);
    }
  }

  /// 转换数据类型
  Result<R> map<R>(R Function(T data) transform) {
    if (isSuccess) {
      try {
        return Result.success(transform(_data as T));
      } catch (e) {
        return Result.failure(AppError.unknown('Transform error: $e'));
      }
    } else {
      return Result.failure(_error!);
    }
  }

  /// 异步转换数据类型
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    if (isSuccess) {
      try {
        final result = await transform(_data as T);
        return Result.success(result);
      } catch (e) {
        return Result.failure(AppError.unknown('Transform error: $e'));
      }
    } else {
      return Result.failure(_error!);
    }
  }

  /// 链式调用（flatMap）
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    if (isSuccess) {
      return transform(_data as T);
    } else {
      return Result.failure(_error!);
    }
  }

  /// 异步链式调用
  Future<Result<R>> flatMapAsync<R>(
    Future<Result<R>> Function(T data) transform,
  ) async {
    if (isSuccess) {
      return await transform(_data as T);
    } else {
      return Result.failure(_error!);
    }
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'Result.success($_data)';
    } else {
      return 'Result.failure($_error)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Result<T> &&
        other.isSuccess == isSuccess &&
        other._data == _data &&
        other._error == _error;
  }

  @override
  int get hashCode => Object.hash(isSuccess, _data, _error);
}

/// 统一的错误类型
class AppError {
  final AppErrorType type;
  final String message;
  final String? technicalDetails;
  final int? errorCode;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.errorCode,
    this.originalError,
    this.stackTrace,
  });

  /// 网络错误
  factory AppError.network(String message, {dynamic originalError}) {
    return AppError(
      type: AppErrorType.network,
      message: message,
      technicalDetails: originalError?.toString(),
      originalError: originalError,
    );
  }

  /// 认证错误
  factory AppError.authentication(String message, {int? code}) {
    return AppError(
      type: AppErrorType.authentication,
      message: message,
      errorCode: code,
    );
  }

  /// 授权错误
  factory AppError.authorization(String message) {
    return AppError(type: AppErrorType.authorization, message: message);
  }

  /// 服务器错误
  factory AppError.server(String message, {int? statusCode}) {
    return AppError(
      type: AppErrorType.server,
      message: message,
      errorCode: statusCode,
    );
  }

  /// 数据解析错误
  factory AppError.parsing(String message, {dynamic originalError}) {
    return AppError(
      type: AppErrorType.parsing,
      message: message,
      technicalDetails: originalError?.toString(),
      originalError: originalError,
    );
  }

  /// 验证错误
  factory AppError.validation(String message, {String? field}) {
    return AppError(
      type: AppErrorType.validation,
      message: message,
      technicalDetails: field != null ? 'Field: $field' : null,
    );
  }

  /// 业务逻辑错误
  factory AppError.business(String message, {int? code}) {
    return AppError(
      type: AppErrorType.business,
      message: message,
      errorCode: code,
    );
  }

  /// 未知错误
  factory AppError.unknown(String message, {dynamic originalError}) {
    return AppError(
      type: AppErrorType.unknown,
      message: message,
      technicalDetails: originalError?.toString(),
      originalError: originalError,
    );
  }

  /// 获取用户友好的错误消息
  String get userMessage {
    switch (type) {
      case AppErrorType.network:
        return '网络连接失败，请检查网络设置';
      case AppErrorType.authentication:
        return message.isEmpty ? '登录失败，请检查用户名和密码' : message;
      case AppErrorType.authorization:
        return '您没有权限执行此操作';
      case AppErrorType.server:
        if (errorCode == 500) {
          return '服务器错误，请稍后重试';
        } else if (errorCode == 503) {
          return '服务暂时不可用，请稍后重试';
        }
        return message.isEmpty ? '服务请求失败' : message;
      case AppErrorType.parsing:
        return '数据格式错误，请联系技术支持';
      case AppErrorType.validation:
        return message;
      case AppErrorType.business:
        return message;
      case AppErrorType.unknown:
        return message.isEmpty ? '未知错误，请重试' : message;
    }
  }

  /// 是否应该重试
  bool get shouldRetry {
    switch (type) {
      case AppErrorType.network:
      case AppErrorType.server:
        return true;
      case AppErrorType.authentication:
      case AppErrorType.authorization:
      case AppErrorType.validation:
      case AppErrorType.parsing:
      case AppErrorType.business:
      case AppErrorType.unknown:
        return false;
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer('AppError(');
    buffer.write('type: $type, ');
    buffer.write('message: $message');
    if (errorCode != null) {
      buffer.write(', code: $errorCode');
    }
    if (technicalDetails != null) {
      buffer.write(', details: $technicalDetails');
    }
    buffer.write(')');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppError &&
        other.type == type &&
        other.message == message &&
        other.errorCode == errorCode;
  }

  @override
  int get hashCode => Object.hash(type, message, errorCode);
}

/// 错误类型枚举
enum AppErrorType {
  /// 网络错误（连接失败、超时等）
  network,

  /// 认证错误（登录失败、token过期等）
  authentication,

  /// 授权错误（权限不足）
  authorization,

  /// 服务器错误（5xx错误）
  server,

  /// 数据解析错误（JSON解析失败等）
  parsing,

  /// 验证错误（输入验证失败）
  validation,

  /// 业务逻辑错误
  business,

  /// 未知错误
  unknown,
}
