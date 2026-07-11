import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import 'package:ios_club_app/core/models/schedule_item.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/features/basic/services/school_config_cache.dart';
import 'package:ios_club_app/features/education/data/repositories/service_repository_adapters.dart';

class WidgetService {
  static const _timeRepository = EducationTimeRepositoryAdapter();
  static const String iOSWidgetGroupId = 'group.com.example.iosClubApp.widget';
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

  // 更新小组件数据
  @pragma('vm:entry-point')
  static Future<void> updateTodayCourses(
      List<ScheduleItem> todayCourses) async {
    await initialize();

    final now = DateTime.now();

    final weekResult = await _timeRepository.getWeek(
      weekStartDay: SchoolConfigCache.readWeekStartDay(),
    );
    if (!weekResult.isSuccess) return;
    final week = weekResult.data;
    const a = ['日', '一', '二', '三', '四', '五', '六', '日'];
    final weekNow = week.week;

    // 更新小组件
    await HomeWidget.saveWidgetData<String>(
        'flutter.date', '第$weekNow周 周${a[now.weekday]}');
    await HomeWidget.saveWidgetData<String>(
        'flutter.courses', jsonEncode(todayCourses));

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
      Map<String, List<ScheduleItem>> courses) async {
    await initialize();

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    await HomeWidget.saveWidgetData<String>(
        'flutter.tomorrow.courses', jsonEncode(courses['today'] ?? []));
    await HomeWidget.saveWidgetData<String>('flutter.tomorrow.tomorrowCourses',
        jsonEncode(courses['tomorrow'] ?? []));
    await HomeWidget.saveWidgetData<String>(
        'flutter.tomorrow.date', _formatMonthDayWeekday(now));
    await HomeWidget.saveWidgetData<String>(
        'flutter.tomorrow.tomorrowDate', _formatMonthDayWeekday(tomorrow));

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
