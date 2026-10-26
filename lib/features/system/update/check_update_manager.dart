import 'package:ios_club_app/core/services/app_service.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';

/// 更新管理类
///
/// 支持两种更新机制：
/// 1. Gitee 发行版更新机制（默认）
/// 2. 应用商店更新机制（通过 --dart-define 构建变量启用）
///
/// 使用方式：
/// flutter build apk --dart-define=UPDATE_CHANNEL=appstore
class CheckUpdateManager {
  /// 检查是否应该执行更新检查
  ///
  /// 通过 --dart-define=UPDATE_CHANNEL 构建变量控制：
  /// 当 UPDATE_CHANNEL 设置为 'appstore' 时，
  /// 应用将跳过更新检查，适用于通过应用商店分发的版本
  static bool shouldCheckForUpdates() {
    // 在Web平台上总是不检查更新(使用Docker自更新)
    // 在iOS、MacOS、Windows平台中不更新(使用各平台的App Store)
    if (PlatformUtils.isWeb ||
        PlatformUtils.isIOS ||
        PlatformUtils.isMacOS ||
        PlatformUtils.isWindows) {
      return false;
    }

    const updateChannel = String.fromEnvironment(
      'UPDATE_CHANNEL',
      defaultValue: 'gitee',
    );
    if (updateChannel == 'appstore') {
      return false;
    }

    // 默认情况下检查更新
    return true;
  }

  /// 获取更新检查服务
  ///
  /// 根据环境变量决定返回哪种更新服务
  static Future<(bool, ReleaseModel)> checkForUpdates() async {
    if (shouldCheckForUpdates()) {
      return await AppService.isNeedUpdate();
    } else {
      // 返回不需要更新的结果
      return (false, ReleaseModel(name: '0.0.0', body: '0.0.0'));
    }
  }
}
