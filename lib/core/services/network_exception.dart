import 'dart:convert';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final int? apiCode;

  NetworkException(this.message, [this.statusCode, this.apiCode]);

  /// Accept both fields used by API clients and JSON sent as text by proxies.
  static int? readApiCode(Object? body) {
    Object? data = body;
    if (body is String) {
      try {
        data = jsonDecode(body);
      } on FormatException {
        return null;
      }
    }
    if (data is! Map) return null;
    return _parseCode(data['errorCode']) ?? _parseCode(data['code']);
  }

  static int? _parseCode(Object? value) => switch (value) {
    final int code => code,
    final String code => int.tryParse(code),
    _ => null,
  };

  @override
  String toString() {
    final String status = statusCode == null
        ? ''
        : ' (Status code: $statusCode)';
    final String code = apiCode == null ? '' : ' (API code: $apiCode)';
    return 'NetworkException: $message$status$code';
  }
}

class AuthenticationException extends NetworkException {
  AuthenticationException(String message, [int? apiCode])
    : super(message, 401, apiCode);
}

class AuthorizationException extends NetworkException {
  AuthorizationException(String message, [int? apiCode])
    : super(message, 403, apiCode);
}

class NotFoundException extends NetworkException {
  NotFoundException(String message, [int? apiCode])
    : super(message, 404, apiCode);
}

class ServerException extends NetworkException {
  ServerException(String message, [int? apiCode])
    : super(message, 500, apiCode);
}

class ConnectionException extends NetworkException {
  ConnectionException() : super('网络连接失败', -1);
}

class TimeoutException extends NetworkException {
  TimeoutException() : super('Request timeout', 408);
}
