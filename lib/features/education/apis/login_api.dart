import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/services/network_exception.dart';
import '../../../core/utils/app_logger.dart';
import '../models/api_response.dart';
import '../models/login_mode.dart';
import '../models/login_response.dart';
import '../services/edu_http_client.dart';
import '../services/edu_http_client_manager.dart';
import '../services/login_mode_service.dart';

/// Login相关API — v1.yaml tag: LoginV1
class LoginApi {
  static EduHttpClient? _clientForTest;
  static Future<LoginResponse> Function(String, String)? _loginOverrideForTest;

  /// POST /Login → ApiResponseOfLoginResponse
  ///
  /// [mode] 是登录页当前选中的系统类型。登录页必须显式传入（此时偏好里还是
  /// 上一次登录的值）；自动重登录不传，沿用 [LoginModeService.current]。
  static Future<LoginResponse> login(
    String username,
    String password, {
    LoginMode? mode,
  }) async {
    if (_loginOverrideForTest != null) {
      return _loginOverrideForTest!(username, password);
    }
    try {
      final client = _clientForTest ?? EduHttpClientManager.instance;
      final effectiveMode = mode ?? LoginModeService.current;
      final response = await client.post(
        '/Login',
        data: {'username': username, 'password': password},
        options: Options(
          headers: <String, dynamic>{
            LoginModeService.headerName: effectiveMode.value.toString(),
          },
        ),
      );
      Map<String, dynamic> responseData;
      if (response is String) {
        responseData = jsonDecode(response);
      } else if (response is Map<String, dynamic>) {
        responseData = response;
      } else {
        throw NetworkException('登录返回格式错误');
      }

      final ApiResponse<LoginResponse> apiResponse =
          ApiResponse<LoginResponse>.parsed(
            responseData,
            (data) =>
                LoginResponse.fromJson(Map<String, dynamic>.from(data as Map)),
          );
      final LoginResponse? loginResponse = apiResponse.data;
      if (loginResponse == null) {
        throw NetworkException('登录返回数据格式错误');
      }
      if (loginResponse.success == true &&
          ((loginResponse.studentId?.isEmpty ?? true) ||
              (loginResponse.cookie?.isEmpty ?? true))) {
        throw NetworkException('登录返回数据不完整');
      }
      return loginResponse;
    } on NetworkException {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error('处理登录请求失败', error: error, stackTrace: stackTrace);
      throw NetworkException('登录失败');
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
