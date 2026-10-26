import 'package:ios_club_app/features/basic/models/school.dart';
import 'edu_http_client.dart';

/// 教务系统 HTTP 客户端管理器
///
/// 提供全局单例的 EduHttpClient，支持动态切换学校配置。
/// 这是普通 Dart 服务管理器，不依赖 GetX 容器。
class EduHttpClientManager {
  EduHttpClientManager._({
    School? school,
    AuthStateCallbacks authStateCallbacks = AuthStateCallbacks.noop,
  }) : _authStateCallbacks = authStateCallbacks {
    _initializeClient(school ?? School.fallbackList.first);
  }

  static EduHttpClientManager? _shared;

  late EduHttpClient _client;
  late School _school;
  AuthStateCallbacks _authStateCallbacks;

  /// 初始化全局 HTTP 客户端管理器。
  static EduHttpClientManager initialize({
    School? school,
    AuthStateCallbacks authStateCallbacks = AuthStateCallbacks.noop,
  }) {
    _shared?.dispose();
    _shared = EduHttpClientManager._(
      school: school,
      authStateCallbacks: authStateCallbacks,
    );
    return _shared!;
  }

  /// 获取当前管理器；如果尚未初始化，则使用默认学校配置。
  static EduHttpClientManager get current {
    return _shared ??= EduHttpClientManager._();
  }

  /// 获取当前的 HTTP 客户端实例。
  static EduHttpClient get instance => current._client;

  /// 当前学校配置；如果管理器尚未初始化，则返回 null。
  static School? get currentSchoolOrNull => _shared?._school;

  /// 重置全局管理器，主要用于测试隔离。
  static void resetForTest() {
    _shared?.dispose();
    _shared = null;
  }

  void _initializeClient(School school) {
    _school = school;
    _client = EduHttpClient(
      baseUrl: school.website,
      authStateCallbacks: _authStateCallbacks,
    );
  }

  /// 更新学校配置。
  ///
  /// 当切换学校时调用此方法更新 API 基础 URL。
  void updateSchoolConfig(School school) {
    _school = school;
    _client.updateBaseUrl(school.website);
  }

  /// 重新初始化客户端。
  ///
  /// 用于完全重置客户端实例（例如在登出后）。
  void reinitialize({School? school, AuthStateCallbacks? authStateCallbacks}) {
    _client.dispose();
    if (authStateCallbacks != null) {
      _authStateCallbacks = authStateCallbacks;
    }
    _initializeClient(school ?? _school);
  }

  void dispose() {
    _client.dispose();
  }
}
