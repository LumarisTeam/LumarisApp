import 'package:workmanager/workmanager.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/system/notifications/task_executor.dart';

/// WorkManager 任务名称常量
const String kWidgetUpdateTask = 'widgetUpdate';
const String kCourseReminderTask = 'courseReminder';

/// WorkManager 后台任务回调（必须是顶层函数）
/// TaskExecutor 内部会自行调用 _ensureInitialized() 完成环境初始化
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case kWidgetUpdateTask:
          await TaskExecutor.updateWidget();
          AppLogger.debug('WorkManager: 小组件更新完成');
          break;
        case kCourseReminderTask:
          await TaskExecutor.checkAndSendCourseReminder();
          AppLogger.debug('WorkManager: 课程提醒检查完成');
          break;
        default:
          AppLogger.debug('WorkManager: 未知任务 $task');
      }
    } catch (e) {
      AppLogger.debug('WorkManager: 任务 $task 失败: $e');
    }

    return true;
  });
}

/// 统一的后台任务服务
/// 使用 workmanager 包，同时支持 Android (WorkManager) 和 iOS (BGTaskScheduler)
class WorkmanagerService {
  static const Duration _widgetInterval = Duration(minutes: 30);
  static const Duration _reminderInterval = Duration(hours: 2);
  static bool _isInitialized = false;

  /// 初始化 WorkManager
  /// 必须在 main isolate 中调用
  static Future<void> initialize() async {
    if (_isInitialized) return;
    await Workmanager().initialize(callbackDispatcher);
    _isInitialized = true;
    AppLogger.debug('WorkManager 初始化完成');
  }

  /// 启动小组件自动刷新（周期性）
  static Future<void> startWidgetRefresh() async {
    await Workmanager().registerPeriodicTask(
      kWidgetUpdateTask,
      kWidgetUpdateTask,
      frequency: _widgetInterval,
      constraints: Constraints(networkType: NetworkType.notRequired),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 10),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
    AppLogger.debug('WorkManager: 小组件刷新任务已注册，间隔: $_widgetInterval');
  }

  /// 启动课程提醒检查（周期性，作为前台预安排通知的补充）
  static Future<void> startReminderCheck() async {
    await Workmanager().registerPeriodicTask(
      kCourseReminderTask,
      kCourseReminderTask,
      frequency: _reminderInterval,
      constraints: Constraints(networkType: NetworkType.notRequired),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
    AppLogger.debug('WorkManager: 课程提醒检查任务已注册，间隔: $_reminderInterval');
  }

  /// 停止小组件刷新
  static Future<void> stopWidgetRefresh() async {
    await Workmanager().cancelByUniqueName(kWidgetUpdateTask);
    AppLogger.debug('WorkManager: 小组件刷新任务已取消');
  }

  /// 停止课程提醒检查
  static Future<void> stopReminderCheck() async {
    await Workmanager().cancelByUniqueName(kCourseReminderTask);
    AppLogger.debug('WorkManager: 课程提醒检查任务已取消');
  }

  /// 停止所有任务
  static Future<void> stopAll() async {
    await Workmanager().cancelAll();
    AppLogger.debug('WorkManager: 所有任务已取消');
  }
}
