import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import 'package:ios_club_app/core/models/schedule_item.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/features/basic/services/school_config_cache.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/services/edu_time_service.dart';
import 'package:ios_club_app/features/system/widget_schedule_snapshot.dart';

class WidgetService {
  static const String iOSWidgetGroupId = 'group.com.example.iosClubApp.widget';

  /// iOS 小组件读取整学期课表快照的 key。
  static const String iOSScheduleSnapshotKey = 'flutter.schedule';
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    if (!PlatformUtils.isIOS && !PlatformUtils.isAndroid) {
      _isInitialized = true;
      return;
    }

    try {
      await HomeWidget.setAppGroupId(iOSWidgetGroupId);
      _isInitialized = true;
      AppLogger.debug('iOS 小组件 App Group 初始化完成');
    } catch (e) {
      AppLogger.warning('iOS 小组件 App Group 初始化失败', error: e);
    }
  }

  /// 清空小组件展示的数据（登出时调用）。
  ///
  /// 只删除 App 写入的 key，再主动刷新一次，避免桌面继续显示上一个账号的课表。
  static Future<void> clear() async {
    if (!PlatformUtils.isIOS && !PlatformUtils.isAndroid) {
      return;
    }

    await initialize();

    const keys = <String>[
      iOSScheduleSnapshotKey,
      'flutter.date',
      'flutter.courses',
      'flutter.tomorrow.courses',
      'flutter.tomorrow.tomorrowCourses',
      'flutter.tomorrow.date',
      'flutter.tomorrow.tomorrowDate',
    ];

    for (final key in keys) {
      await HomeWidget.saveWidgetData<String>(key, null);
    }

    if (PlatformUtils.isIOS) {
      await HomeWidget.updateWidget(iOSName: 'ScheduleWidget');
      return;
    }

    await HomeWidget.updateWidget(
      name: 'TodayCoursesWidgetProvider',
      androidName: 'TodayCoursesWidgetProvider',
      qualifiedAndroidName:
          'com.example.ios_club_app.TodayCoursesWidgetProvider',
    );
    await HomeWidget.updateWidget(
      name: 'TomorrowCoursesWidgetProvider',
      androidName: 'TomorrowCoursesWidgetProvider',
      qualifiedAndroidName:
          'com.example.ios_club_app.TomorrowCoursesWidgetProvider',
    );
  }

  /// 推送整学期课表快照（仅 iOS）。
  ///
  /// 小组件拿到快照后自行推算今日/明日课表并生成多条 timeline entry，
  /// App 不在前台也能按节次自动切换，不再依赖 App 反复写入当天课程。
  static Future<void> updateScheduleSnapshot({
    required List<CourseModel> courses,
    required List<ScheduleTable> tables,
    required String? semesterStart,
    required String? semesterEnd,
    required int weekStartDay,
  }) async {
    if (!PlatformUtils.isIOS) {
      return;
    }

    await initialize();

    final snapshot = WidgetScheduleSnapshot.build(
      courses: courses,
      tables: tables,
      semesterStart: semesterStart,
      semesterEnd: semesterEnd,
      weekStartDay: weekStartDay,
    );

    await HomeWidget.saveWidgetData<String>(
      iOSScheduleSnapshotKey,
      jsonEncode(snapshot),
    );

    await HomeWidget.updateWidget(iOSName: 'ScheduleWidget');
    AppLogger.debug('iOS 小组件课表快照更新完成');
  }

  // 更新小组件数据
  @pragma('vm:entry-point')
  static Future<void> updateTodayCourses(
    List<ScheduleItem> todayCourses,
  ) async {
    await initialize();

    final now = DateTime.now();

    final week = await EduTimeService.getWeek(
      weekStartDay: SchoolConfigCache.readWeekStartDay(),
    );
    const a = ['日', '一', '二', '三', '四', '五', '六', '日'];
    final weekNow = week.week;

    // 更新小组件
    await HomeWidget.saveWidgetData<String>(
      'flutter.date',
      '第$weekNow周 周${a[now.weekday]}',
    );
    await HomeWidget.saveWidgetData<String>(
      'flutter.courses',
      jsonEncode(todayCourses),
    );

    AppLogger.debug('小组件数据更新完成');

    // 刷新小组件
    await HomeWidget.updateWidget(
      name: 'TodayCoursesWidgetProvider',
      androidName: 'TodayCoursesWidgetProvider',
      iOSName: 'ScheduleWidget',
      qualifiedAndroidName:
          'com.example.ios_club_app.TodayCoursesWidgetProvider',
    );
  }

  @pragma('vm:entry-point')
  static Future<void> updateTodayAndTomorrowCourses(
    Map<String, List<ScheduleItem>> courses,
  ) async {
    await initialize();

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    await HomeWidget.saveWidgetData<String>(
      'flutter.tomorrow.courses',
      jsonEncode(courses['today'] ?? []),
    );
    await HomeWidget.saveWidgetData<String>(
      'flutter.tomorrow.tomorrowCourses',
      jsonEncode(courses['tomorrow'] ?? []),
    );
    await HomeWidget.saveWidgetData<String>(
      'flutter.tomorrow.date',
      _formatMonthDayWeekday(now),
    );
    await HomeWidget.saveWidgetData<String>(
      'flutter.tomorrow.tomorrowDate',
      _formatMonthDayWeekday(tomorrow),
    );

    AppLogger.debug('小组件数据更新完成');

    // 刷新小组件
    await HomeWidget.updateWidget(
      name: 'TomorrowCoursesWidgetProvider',
      androidName: 'TomorrowCoursesWidgetProvider',
      iOSName: 'ScheduleWidget',
      qualifiedAndroidName:
          'com.example.ios_club_app.TomorrowCoursesWidgetProvider',
    );
  }

  static String _formatMonthDayWeekday(DateTime date) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month月$day日 ${weekdays[date.weekday - 1]}';
  }
}
