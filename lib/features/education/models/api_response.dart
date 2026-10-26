import 'package:json_annotation/json_annotation.dart';

import '../../../core/services/network_exception.dart';

part 'api_response.g.dart';

/// Generic response envelope matching v1.yaml's `ApiResponseOf<T>` pattern:
/// `{ "data": T, "code": int|string, "message": string, "total": int|null }`
///
/// Also handles bare responses (no envelope) by treating the entire
/// JSON as [data] for backward compatibility with non-conformant APIs.
@JsonSerializable(
  explicitToJson: true,
  genericArgumentFactories: true,
  createFactory: false,
)
class ApiResponse<T> {
  final T? data;
  final dynamic code;
  final String? message;
  final int? total;

  const ApiResponse({this.data, this.code, this.message, this.total});

  /// True when the response indicates success.
  ///
  /// Per v1.yaml convention: null code, 0, "0", 200, or "200" means success.
  bool get isSuccess {
    if (code == null) return true;
    if (code == 0 || code == '0') return true;
    if (code == 200 || code == '200') return true;
    return false;
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    if (json.containsKey('data')) {
      return ApiResponse(
        data: json['data'] != null ? fromJsonT(json['data']) : null,
        code: json['code'],
        message: json['message']?.toString(),
        total: _parseTotal(json['total']),
      );
    }
    // Bare response — treat entire json as data for backward compatibility
    return ApiResponse(
      data: fromJsonT(json),
      code: null,
      message: null,
      total: null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  /// Parse a raw dynamic response into [ApiResponse<T>].
  ///
  /// Handles bare arrays and objects for backward compatibility with
  /// endpoints that don't use the envelope. If [rawResponse] is a [Map], it's
  /// parsed via [ApiResponse.fromJson] which checks for the `data` key. If
  /// [rawResponse] is a [List], it's treated as a bare `data` array.
  factory ApiResponse.parsed(
    dynamic rawResponse,
    T Function(Object? json) fromJsonT,
  ) {
    if (rawResponse == null) {
      return ApiResponse<T>(data: null, code: 0, message: null, total: null);
    }
    if (rawResponse is Map) {
      final Map<String, dynamic> json = Map<String, dynamic>.from(rawResponse);
      return ApiResponse<T>.fromJson(json, fromJsonT);
    }
    if (rawResponse is List) {
      return ApiResponse<T>(
        data: fromJsonT(rawResponse),
        code: null,
        message: null,
        total: null,
      );
    }
    throw NetworkException(
      'Response is not a JSON object or array, got ${rawResponse.runtimeType}',
      -1,
    );
  }

  static int? _parseTotal(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
