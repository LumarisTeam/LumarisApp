import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/services/network_exception.dart';
import 'edu_http_client.dart';
import 'edu_http_client_manager.dart';

/// 登录服务
class LoginService {
  static EduHttpClient? _clientOverride;
  static Future<Map<String, dynamic>> Function(String, String)?
      _loginOverrideForTest;

  /// 登录
  /// [username] 用户名
  /// [password] 密码
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    if (_loginOverrideForTest != null) {
      return await _loginOverrideForTest!(username, password);
    }
    try {
      final client = _clientOverride ?? EduHttpClientManager.instance;
      final response = await client.post(
        '/Login',
        data: {
          'username': username,
          'password': password,
        },
        options: Options(
          extra: const <String, dynamic>{
            EduHttpClient.skipAuthRecoveryKey: true,
          },
        ),
      );
      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is String) {
        return jsonDecode(response);
      } else {
        throw NetworkException('登录返回格式错误', -1);
      }
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      } else {
        throw NetworkException('登录失败: $e', -1);
      }
    }
  }

  static void setLoginOverrideForTest(
      Future<Map<String, dynamic>> Function(String, String)? handler) {
    _loginOverrideForTest = handler;
  }

  static void setClientForTest(EduHttpClient client) {
    _clientOverride = client;
  }

  static void resetClientForTest() {
    _clientOverride?.dispose();
    _clientOverride = null;
  }
}
