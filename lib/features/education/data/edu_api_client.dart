import 'package:dio/dio.dart';

/// School-scoped transport used by education remote data sources.
///
/// Keeping this interface independent from Dio construction allows repositories
/// to use a deterministic fake in tests while production keeps the existing
/// interceptors, cache and retry behaviour.
abstract interface class EduApiClient {
  String get baseUrl;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool bypassCache,
  });

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  void updateBaseUrl(String newBaseUrl);

  void dispose();
}
