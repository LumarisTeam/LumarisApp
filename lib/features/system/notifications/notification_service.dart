import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/services/app_locale_service.dart';
import 'package:ios_club_app/core/services/permission_service.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:intl/intl.dart';

import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/core/models/todo_item.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/data/repositories/service_repository_adapters.dart';
import 'package:ios_club_app/features/system/notifications/course_reminder_helper.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';

class NotificationService {
  static const _courseRepository = CourseRepositoryAdapter();
  static final NotificationService _instance = NotificationService._();
  static const String _courseChannelNameZh = '课程通知';
  static const String _courseChannelDescriptionZh = '进行每日课表的课程通知';
  static const String _todoChannelNameZh = '待办事务提醒';
  static const String _todoChannelDescriptionZh = '待办事务截止提醒';

  static NotificationService get instance => _instance;
  bool isInit = false;

  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  AppLocalizations get _l10n => AppLocaleService.currentL10n();

  static bool _isGranted(PermissionStatus status) {
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited ||
        status == PermissionStatus.provisional;
  }

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // 将时区注册为本地时区（后续调用 tz.local 就是本地时区）
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    final androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
      appName: _l10n.appName,
      appUserModelId: 'DA45F98E-38F0-F574-4192-36EB8C8DA0CA',
      guid: 'DA45F98E-38F0-F574-4192-36EB8C8DA0CA',
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      windows: initializationSettingsWindows,
      macOS: initializationSettingsDarwin,
    );

    await notifications.initialize(
      settings: initSettings,
    );

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(AndroidNotificationChannel(
          'ios_club_app_course_reminders',
          _courseChannelNameZh,
          description: _courseChannelDescriptionZh,
          importance: Importance.max,
        ));

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(AndroidNotificationChannel(
          'ios_club_app_todo_reminders',
          _todoChannelNameZh,
          description: _todoChannelDescriptionZh,
          importance: Importance.max,
        ));

    isInit = true;
  }

  /// 取消所有已排期的通知
  Future<void> cancelAllNotifications() async {
    await notifications.cancelAll();
    AppLogger.debug('所有通知已取消');
  }

  Future<void> scheduleCourseReminder(
      {required int id,
      required String title,
      required String body,
      required DateTime courseTime}) async {
    final prefs = PrefsService.instance;
    final notificationTime = prefs.getInt(PrefsKeys.NOTIFICATION_TIME) ?? 15;
    final now = DateTime.now();
    final reminderTime =
        courseTime.subtract(Duration(minutes: notificationTime));

    if (reminderTime.isBefore(now)) {
      AppLogger.debug('Cannot schedule notification for past reminder time');
      return;
    }

    final tzDateTime = tz.TZDateTime.from(reminderTime, tz.local);

    final android = notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final canScheduleExact = await android.canScheduleExactNotifications();
      if (canScheduleExact == null || !canScheduleExact) {
        AppLogger.debug('Exact alarm scheduling not allowed');
        return;
      }
    }

    AppLogger.debug('Scheduling notification at $tzDateTime with id=$id');
    final l10n = _l10n;

    try {
      // 增加安全检查：如果待处理通知接近 500 个，停止安排
      final pendingCount =
          (await notifications.pendingNotificationRequests()).length;
      if (pendingCount >= 450) {
        AppLogger.debug(
            'Warning: Approaching 500 alarm limit ($pendingCount). Skipping schedule.');
        return;
      }

      await notifications.zonedSchedule(
        id: id,
        title: title,
        body: '$body ${l10n.courseReminderStartsIn(notificationTime)}',
        scheduledDate: tzDateTime,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'ios_club_app_course_reminders',
            _courseChannelNameZh,
            channelDescription: _courseChannelDescriptionZh,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: 'ios_club_app_course_reminders',
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: 'ios_club_app_course_reminders',
          ),
          windows: WindowsNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      AppLogger.debug('Error scheduling notification: $e');
    }
  }

  /// 安排待办事项提醒
  Future<void> scheduleTodoNotification(
      TodoItem todo, bool todoRemindEnabled) async {
    // 如果提醒功能未启用，直接返回
    if (!todoRemindEnabled) return;

    // 如果待办事项已完成，取消提醒
    if (todo.isCompleted) {
      await notifications.cancel(id: todo.id.hashCode);
      return;
    }

    // 确保时区已初始化
    if (!isInit) {
      await initialize();
    }

    final android = notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final canScheduleExact = await android.canScheduleExactNotifications();
      if (canScheduleExact == null || !canScheduleExact) {
        AppLogger.debug('Exact alarm scheduling not allowed for todo reminder');
        return;
      }
    }

    // 解析截止日期
    DateTime? deadline;
    try {
      deadline = DateFormat('yyyy-MM-dd HH:mm').parse(todo.deadline);
    } catch (e) {
      try {
        deadline = DateFormat('yyyy-MM-dd').parse(todo.deadline);
      } catch (e) {
        try {
          deadline = DateTime.parse(todo.deadline);
        } catch (e) {
          // 如果解析失败，不设置提醒
          return;
        }
      }
    }

    // 如果没有截止日期或已经过期，不设置提醒
    if (deadline.isBefore(DateTime.now())) {
      return;
    }

    // 设置提醒
    final notificationTime =
        deadline; // deadline.subtract(const Duration(hours: 1));

    // 如果计算出的提醒时间已经过去，不设置提醒
    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    final tzNotificationTime = tz.TZDateTime.from(notificationTime, tz.local);

    try {
      final l10n = _l10n;
      await notifications.zonedSchedule(
        id: todo.id.hashCode, // 使用唯一ID作为通知ID
        title: l10n.todoReminderTitle,
        body: l10n.todoReminderBody(todo.title),
        scheduledDate: tzNotificationTime,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'ios_club_app_todo_reminders',
            _todoChannelNameZh,
            channelDescription: _todoChannelDescriptionZh,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: 'ios_club_app_todo_reminders',
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: 'ios_club_app_todo_reminders',
          ),
          windows: WindowsNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      AppLogger.debug('Error scheduling todo notification: $e');
    }
  }

  /// 更新待办事项提醒
  Future<void> updateTodoNotification(
      TodoItem todo, bool todoRemindEnabled) async {
    // 确保时区已初始化
    if (!isInit) {
      await initialize();
    }

    // 先取消之前的通知
    await notifications.cancel(id: todo.id.hashCode);
    // 再根据新状态决定是否重新安排通知
    await scheduleTodoNotification(todo, todoRemindEnabled);
  }

  static Future<bool> ensureReminderPermission(BuildContext context) async {
    final l10n = context.l10n;
    final status = await PermissionService.request(
      Permission.scheduleExactAlarm,
      context: context,
      dialogTitle: l10n.allowScheduleAlarm,
      dialogContent: l10n.allowScheduleAlarmContent,
      settingsText: l10n.goToSettings,
    );

    if (!_isGranted(status)) {
      return false;
    }

    // 在 Android 上进一步请求忽略电池优化权限，以确保后台任务存活
    if (PlatformUtils.isAndroid) {
      if (!context.mounted) {
        return false;
      }
      await PermissionService.request(
        Permission.ignoreBatteryOptimizations,
        context: context,
        dialogTitle: l10n.allowBackgroundRun,
        dialogContent: l10n.allowBackgroundRunContent,
        settingsText: l10n.goToSettings,
      );
    }

    await remind();
    return true;
  }

  static Future<void> set(BuildContext context) async {
    await ensureReminderPermission(context);
  }

  static Future<void> remind() async {
    if (!NotificationService.instance.isInit) {
      await NotificationService.instance.initialize();
    }

    final courseResult =
        await _courseRepository.getTodayOrTomorrowCourses(tomorrow: true);
    if (!courseResult.isSuccess) return;
    final a = courseResult.data;
    final targetDate =
        a.$1 ? DateTime.now().add(const Duration(days: 1)) : DateTime.now();

    await remindList(a.$2, targetDate: targetDate);
  }

  static Future<void> remindList(
    List<CourseModel> a, {
    DateTime? targetDate,
    Set<int>? existingIds,
  }) async {
    if (!NotificationService.instance.isInit) {
      await NotificationService.instance.initialize();
    }

    final effectiveDate = targetDate ?? DateTime.now();

    // 如果未提供 existingIds，则获取所有待处理的通知，用于去重
    final Set<int> idsToCompare;
    if (existingIds == null) {
      final pendingRequests = await NotificationService.instance.notifications
          .pendingNotificationRequests();
      idsToCompare = pendingRequests.map((r) => r.id).toSet();
    } else {
      idsToCompare = existingIds;
    }

    for (var course in a) {
      final target = CourseReminderHelper.buildTarget(
        course: course,
        courseDate: effectiveDate,
      );
      if (target == null) continue;

      // 如果通知已存在，跳过，避免重复调度引发通知闪烁或系统限制
      if (idsToCompare.contains(target.notificationId)) {
        continue;
      }

      await NotificationService.instance.scheduleCourseReminder(
        id: target.notificationId,
        title: NotificationService.instance._l10n.courseReminderTitle,
        body: course.courseName,
        courseTime: target.courseTime,
      );
    }
  }
}
