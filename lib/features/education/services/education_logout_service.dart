import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/system/notifications/notification_service.dart';
import 'package:ios_club_app/features/system/notifications/task_executor.dart';
import 'package:ios_club_app/features/system/widget_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

/// 登出时需要一并清理的账号相关数据。
///
/// 磁贴布局（[PrefsKeys.TILE_CONFIGURATIONS] / [PrefsKeys.TILES]）属于
/// UI 偏好，按产品要求保留。
class EducationLogoutService {
  EducationLogoutService._();

  static Future<void> clearAccountArtifacts() async {
    // 先清内存缓存，避免并发任务用旧课程把数据又写回磁盘。
    TaskExecutor.clearCache();

    await _run('取消课程通知', _cancelNotifications);
    await _run('清空小组件数据', WidgetService.clear);
    await _run('清除支付凭证', _clearPaymentCredentials);
    await _run('清除电费配置', _clearElectricityConfig);
    await _run('清除自定义/游客课程', _clearCustomCourses);
  }

  static Future<void> _cancelNotifications() async {
    try {
      await NotificationService.instance.cancelAllNotifications();
    } catch (e, stackTrace) {
      // 取消失败不影响后续清理，排期记录仍要删掉。
      AppLogger.error('登出时取消课程通知失败', error: e, stackTrace: stackTrace);
    }

    final prefs = PrefsService.instance;
    await prefs.remove(PrefsKeys.COURSE_REMINDER_PLAN);
    await prefs.remove(PrefsKeys.LAST_REMIND_DATE);
  }

  static Future<void> _clearPaymentCredentials() async {
    final prefs = PrefsService.instance;
    final secureStorage = SecureStorageService.instance;

    await secureStorage.delete(key: PrefsKeys.PAYMENT_PASSWORD);
    await prefs.remove(PrefsKeys.PAYMENT_PASSWORD);

    // 旧版本遗留的支付卡号。
    await secureStorage.delete(key: PrefsKeys.PAYMENT_NUM);
    await prefs.remove(PrefsKeys.PAYMENT_NUM);
  }

  static Future<void> _clearElectricityConfig() async {
    final prefs = PrefsService.instance;
    await prefs.remove(PrefsKeys.ELECTRICITY_URL);
    await prefs.remove(PrefsKeys.ELECTRICITY_SUBSCRIPTION_EMAIL);
  }

  static Future<void> _clearCustomCourses() async {
    final prefs = PrefsService.instance;
    await prefs.remove(PrefsKeys.CUSTOM_COURSE_DATA);
    await prefs.remove(PrefsKeys.GUEST_COURSE_DATA);
  }

  static Future<void> _run(String label, Future<void> Function() action) async {
    try {
      await action();
    } catch (e, stackTrace) {
      AppLogger.error('登出清理失败: $label', error: e, stackTrace: stackTrace);
    }
  }
}
