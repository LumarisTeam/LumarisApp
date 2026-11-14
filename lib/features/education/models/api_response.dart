import 'package:json_annotation/json_annotation.dart';

import '../../../core/services/network_exception.dart';
import 'edu_api_codes.dart';

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
  bool get isSuccess => _isSuccessCode(code);

  static bool _isSuccessCode(Object? code) =>
      code == null ||
      code == EduApiCodes.success ||
      code == '${EduApiCodes.success}' ||
      code == 200 ||
      code == '200';

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    if (json.containsKey('data') ||
        json.containsKey('errorCode') ||
        (json.containsKey('code') &&
            (json.containsKey('message') || json.length == 1))) {
      final Object? code =
          NetworkException.readApiCode(json) ??
          json['errorCode'] ??
          json['code'];
      return ApiResponse(
        data: _isSuccessCode(code) && json['data'] != null
            ? fromJsonT(json['data'])
            : null,
        code: code,
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
  /// endpoints that don't use the envelope. Failed envelopes throw a
  /// [NetworkException] with the API code before decoding the payload.
  factory ApiResponse.parsed(
    dynamic rawResponse,
    T Function(Object? json) fromJsonT,
  ) {
    if (rawResponse == null) {
      return ApiResponse<T>(code: EduApiCodes.success);
    }
    if (rawResponse is Map) {
      final Map<String, dynamic> json = Map<String, dynamic>.from(rawResponse);
      final ApiResponse<T> response = ApiResponse<T>.fromJson(json, fromJsonT);
      if (!response.isSuccess) {
        throw NetworkException(
          '请求失败',
          null,
          NetworkException.readApiCode(json),
        );
      }
      return response;
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
