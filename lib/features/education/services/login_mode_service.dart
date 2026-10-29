import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/login_mode.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

/// 记录并读取当前教务系统类型。
///
/// 登录成功时写入偏好；之后 [EduHttpClient] 的请求拦截器会把它作为
/// `x-loginMode` 头带在每一个教务请求上。
class LoginModeService {
  const LoginModeService._();

  /// 与后端约定的通用头名称。
  static const String headerName = 'x-loginMode';

  /// 当前记录的系统类型；偏好尚未初始化或从未登录过时按本科生处理。
  static LoginMode get current {
    if (!PrefsService.isInitialized) {
      return LoginMode.undergraduate;
    }

    return LoginMode.fromValue(
      PrefsService.instance.getInt(PrefsKeys.LOGIN_MODE),
    );
  }

  /// 当前应发送的头值（"0"/"1"）。
  static String get currentHeaderValue => current.value.toString();

  /// 记录登录时选择的系统类型。
  ///
  /// 偏好未初始化时直接跳过（后台 isolate 等场景），不阻断登录本身。
  static Future<void> save(LoginMode mode) async {
    if (!PrefsService.isInitialized) {
      return;
    }

    await PrefsService.instance.setInt(PrefsKeys.LOGIN_MODE, mode.value);
  }
}
