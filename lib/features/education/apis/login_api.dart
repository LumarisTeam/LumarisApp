import 'dart:convert';

import '../../../core/services/network_exception.dart';
import '../models/api_response.dart';
import '../models/login_response.dart';
import '../services/edu_http_client.dart';
import '../services/edu_http_client_manager.dart';

/// Login相关API — v1.yaml tag: LoginV1
class LoginApi {
  static EduHttpClient? _clientForTest;
  static Future<LoginResponse> Function(String, String)? _loginOverrideForTest;

  /// POST /Login → ApiResponseOfLoginResponse
  static Future<LoginResponse> login(String username, String password) async {
    if (_loginOverrideForTest != null) {
      return _loginOverrideForTest!(username, password);
    }
    try {
      final client = _clientForTest ?? EduHttpClientManager.instance;
      final response = await client.post(
        '/Login',
        data: {'username': username, 'password': password},
      );
      Map<String, dynamic> responseData;
      if (response is String) {
        responseData = jsonDecode(response);
      } else if (response is Map<String, dynamic>) {
        responseData = response;
      } else {
        throw NetworkException('登录返回格式错误', -1);
      }

      final apiResponse = ApiResponse<LoginResponse>.parsed(
        responseData,
        (data) =>
            LoginResponse.fromJson(Map<String, dynamic>.from(data as Map)),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(apiResponse.message ?? '登录失败', -1);
      }
      final loginResponse = apiResponse.data;
      if (loginResponse == null) {
        throw NetworkException('登录返回数据为空', -1);
      }
      if (loginResponse.success == true &&
          ((loginResponse.studentId?.isEmpty ?? true) ||
              (loginResponse.cookie?.isEmpty ?? true))) {
        throw NetworkException('登录返回数据不完整', -1);
      }
      return loginResponse;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static void _handleError(dynamic e) {
    if (e is! NetworkException) {
      throw NetworkException('未知错误', -1);
    }
  }

  static void setClientForTest(EduHttpClient client) {
    _clientForTest = client;
  }

  static void resetClientForTest() {
    _clientForTest?.dispose();
    _clientForTest = null;
  }

  static void setLoginOverrideForTest(
    Future<LoginResponse> Function(String, String)? handler,
  ) {
    _loginOverrideForTest = handler;
  }
}
