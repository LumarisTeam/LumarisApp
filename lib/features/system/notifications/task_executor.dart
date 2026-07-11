import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:ios_club_app/core/models/schedule_item.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/basic/services/school_config_cache.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/time_info.dart';
import 'package:ios_club_app/features/education/data/repositories/service_repository_adapters.dart';
import 'package:ios_club_app/core/utils/week_start_utils.dart';
import 'package:ios_club_app/features/system/notifications/notification_service.dart';
import 'package:ios_club_app/features/system/widget_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

/// 任务执行器 - 实际的业务逻辑
@pragma('vm:entry-point')
class TaskExecutor {
  static const _courseRepository = CourseRepositoryAdapter();
  static const _timeRepository = EducationTimeRepositoryAdapter();

  /// 标记是否正在执行任务，避免重复执行
  static bool _isExecuting = false;

  /// 缓存的课程数据
  static List<CourseModel>? _cachedCourses;
  static TimeInfo? _cachedTime;
  static int _cachedWeekStartDay = DateTime.sunday;
  static DateTime? _cacheTimestamp;

  /// 缓存有效期（5分钟）
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  /// 检查缓存是否有效
  static bool _isCacheValid() {
    if (_cachedCourses == null ||
        _cachedTime == null ||
        _cacheTimestamp == null) {
      return false;
    }
    return DateTime.now().difference(_cacheTimestamp!) < _cacheValidDuration;
  }

  /// 预加载数据到缓存
  static Future<void> _preloadData() async {
    if (_isCacheValid()) {
      _cachedWeekStartDay = SchoolConfigCache.readWeekStartDay();
      return;
    }

    try {
      // 并行获取课程和时间数据
      final results = await Future.wait([
        _courseRepository.getAllCourses(),
        _timeRepository.getTime(),
      ]).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('预加载数据超时');
        },
      );

      final courseResult = results[0];
      if (!courseResult.isSuccess) throw courseResult.error;
      _cachedCourses = courseResult.data as List<CourseModel>;
      final timeResult = results[1];
      if (!timeResult.isSuccess) throw timeResult.error;
      _cachedTime = timeResult.data as TimeInfo;
      _cachedWeekStartDay = SchoolConfigCache.readWeekStartDay();
      _cacheTimestamp = DateTime.now();
      AppLogger.debug('后台任务数据预加载完成');
    } catch (e) {
      AppLogger.debug('预加载数据失败: $e');
      // 不再清空缓存，以便在离线或弱网环境下仍能使用旧缓存更新小组件
    }
  }

  /// 从缓存获取今日或明日课程
  static (bool, List<CourseModel>) _getTodayOrTomorrowCourseFromCache(
      {bool isTomorrow = false}) {
    if (_cachedCourses == null || _cachedTime == null) {
      return (false, <CourseModel>[]);
    }

    final time = _cachedTime!;
    var now = DateTime.now();
    if (time.startTime == null) {
      return (false, <CourseModel>[]);
    }

    final startTime = DateTime.parse(time.startTime!);
    var weekNow = WeekStartUtils.getWeekIndexByStartTime(
      now,
      startTime,
      weekStartDay: _cachedWeekStartDay,
    );
    var filteredCourses = _cachedCourses!.where((course) {
      return course.weekIndexes.contains(weekNow) &&
          course.weekday == now.weekday;
    }).toList();

    if (filteredCourses.isEmpty) {
      if (isTomorrow) {
        final tomorrow = now.add(const Duration(days: 1));
        var weekTomorrow = WeekStartUtils.getWeekIndexByStartTime(
          tomorrow,
          startTime,
          weekStartDay: _cachedWeekStartDay,
        );
        var tomorrowWeekday = tomorrow.weekday;

        filteredCourses = _cachedCourses!.where((course) {
          return course.weekIndexes.contains(weekTomorrow) &&
              course.weekday == tomorrowWeekday;
        }).toList();
        filteredCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));
        return (true, filteredCourses);
      } else {
        return (false, filteredCourses);
      }
    }

    filteredCourses = filteredCourses.where((course) {
      final courseTime = TimeService.getStartAndEnd(course);
      final l = courseTime.end.split(':');
      var end = DateTime(
          now.year, now.month, now.day, int.parse(l[0]), int.parse(l[1]), 0);
      return now.isBefore(end);
    }).toList();

    filteredCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));
    return (false, filteredCourses);
  }

  /// 从缓存获取今日和明日课程
  static Map<String, List<CourseModel>> _getTodayAndTomorrowCoursesFromCache() {
    if (_cachedCourses == null || _cachedTime == null) {
      return {'today': <CourseModel>[], 'tomorrow': <CourseModel>[]};
    }

    final time = _cachedTime!;
    var now = DateTime.now();

    if (time.startTime == null) {
      return {'today': <CourseModel>[], 'tomorrow': <CourseModel>[]};
    }

    final startTime = DateTime.parse(time.startTime!);
    var weekNow = WeekStartUtils.getWeekIndexByStartTime(
      now,
      startTime,
      weekStartDay: _cachedWeekStartDay,
    );

    // 获取今天的课程
    var todayCourses = _cachedCourses!.where((course) {
      return course.weekIndexes.contains(weekNow) &&
          course.weekday == now.weekday;
    }).toList();

    // 过滤掉已经结束的课程
    todayCourses = todayCourses.where((course) {
      final courseTime = TimeService.getStartAndEnd(course);
      final l = courseTime.end.split(':');
      var end = DateTime(
          now.year, now.month, now.day, int.parse(l[0]), int.parse(l[1]), 0);
      return now.isBefore(end);
    }).toList();

    todayCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

    // 计算明天日期和周数
    final tomorrow = now.add(const Duration(days: 1));
    var weekTomorrow = WeekStartUtils.getWeekIndexByStartTime(
      tomorrow,
      startTime,
      weekStartDay: _cachedWeekStartDay,
    );
    var tomorrowWeekday = tomorrow.weekday;

    // 获取明天的课程
    var tomorrowCourses = _cachedCourses!.where((course) {
      return course.weekIndexes.contains(weekTomorrow) &&
          course.weekday == tomorrowWeekday;
    }).toList();

    tomorrowCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

    return {'today': todayCourses, 'tomorrow': tomorrowCourses};
  }

  /// 确保后台环境已初始化（防重复调用）
  static bool _backgroundInitialized = false;

  static Future<void> _ensureInitialized() async {
    if (_backgroundInitialized) return;
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    await HiveManager.init();
    await PrefsService.init();
    _backgroundInitialized = true;
  }

  static Future<void> checkAndSendCourseReminder({bool force = false}) async {
    await _ensureInitialized();

    // 防止重复执行（force 模式除外）
    if (!force && _isExecuting) {
      AppLogger.debug('课程提醒正在执行中，跳过本次调用');
      return;
    }
    _isExecuting = true;

    try {
      final prefs = await PrefsService.getInstanceAsync();

      // 检查是否启用提醒
      final isReminderEnabled = prefs.getBool(PrefsKeys.IS_REMIND) ?? false;
      if (!isReminderEnabled) {
        AppLogger.debug('课程提醒未启用');
        return;
      }

      final now = DateTime.now();

      // 一天只提醒一次（force 模式除外，如用户主动启用提醒时）
      if (!force) {
        final lastRemindStr = prefs.getString(PrefsKeys.LAST_REMIND_DATE);
        if (lastRemindStr != null) {
          try {
            final lastRemindDate = DateTime.parse(lastRemindStr);
            if (lastRemindDate.year >= now.year &&
                lastRemindDate.month >= now.month &&
                lastRemindDate.day >= now.day) {
              AppLogger.debug('今日已执行课程提醒，跳过');
              return;
            }
          } catch (_) {
            // 解析失败则继续执行
          }
        }
      }

      // 预加载数据
      await _preloadData();

      // 获取所有课程和时间信息
      if (_cachedCourses == null ||
          _cachedTime == null ||
          _cachedTime!.startTime == null) {
        AppLogger.debug('没有课程或时间信息，跳过排期');
        return;
      }

      final startTime = DateTime.parse(_cachedTime!.startTime!);

      // 获取所有已排期的通知，优化去重逻辑
      final pendingRequests = await NotificationService.instance.notifications
          .pendingNotificationRequests();

      // 如果已经接近上限，先清空所有通知（这是一个应急保险）
      if (pendingRequests.length > 400) {
        AppLogger.debug('检测到闹钟接近上限 (${pendingRequests.length}), 正在清空并重排...');
        await NotificationService.instance.cancelAllNotifications();
      }

      final existingIds = pendingRequests.map((r) => r.id).toSet();

      // 只排期一天的课程，优先今天，今天没课则排明天
      DateTime? scheduledDate;
      for (int i = 0; i < 2; i++) {
        final targetDate = now.add(Duration(days: i));
        final targetWeek = WeekStartUtils.getWeekIndexByStartTime(
          targetDate,
          startTime,
          weekStartDay: _cachedWeekStartDay,
        );
        final targetWeekday = targetDate.weekday;

        var dailyCourses = _cachedCourses!.where((course) {
          return course.weekIndexes.contains(targetWeek) &&
              course.weekday == targetWeekday;
        }).toList();

        // 如果是今天，过滤掉已经结束的课程
        if (i == 0) {
          dailyCourses = dailyCourses.where((course) {
            final courseTime = TimeService.getStartAndEnd(course);
            final l = courseTime.end.split(':');
            var end = DateTime(now.year, now.month, now.day, int.parse(l[0]),
                int.parse(l[1]), 0);
            return now.isBefore(end);
          }).toList();
        }

        dailyCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

        if (dailyCourses.isNotEmpty) {
          await NotificationService.remindList(
            dailyCourses,
            targetDate: targetDate,
            existingIds: existingIds,
          );
          scheduledDate = targetDate;
          break; // 一天有课即停止，不再排后续天数
        }
      }

      // LAST_REMIND_DATE 设为实际排期的目标日期，而非今天
      // 这样如果排的是明天的课，明天就不会重复排期
      await prefs.setString(
        PrefsKeys.LAST_REMIND_DATE,
        (scheduledDate ?? now).toIso8601String(),
      );
      AppLogger.debug(
        '课程提醒排期完成, 目标日期=${(scheduledDate ?? now).toIso8601String()}',
      );
    } catch (e) {
      AppLogger.debug('课程提醒检查失败: $e');
    } finally {
      _isExecuting = false;
    }
  }

  @pragma('vm:entry-point')
  static Future<void> updateWidget() async {
    await _ensureInitialized();
    // 防止重复执行
    if (_isExecuting) {
      AppLogger.debug('后台任务正在执行中，跳过本次调用');
      return;
    }

    _isExecuting = true;
    try {
      // 预加载数据（只请求一次）
      await _preloadData();

      // 并行更新两个小组件
      await Future.wait([
        _updateTodayWidgetFromCache(),
        _updateTodayAndTomorrowWidgetFromCache(),
      ]);
    } catch (e) {
      AppLogger.debug('更新小组件失败: $e');
    } finally {
      _isExecuting = false;
    }
  }

  /// 从缓存更新今日课程小组件
  static Future<void> _updateTodayWidgetFromCache() async {
    try {
      final (_, courses) =
          _getTodayOrTomorrowCourseFromCache(isTomorrow: false);

      if (courses.isNotEmpty) {
        final scheduleItems = _convertToScheduleItems(courses);
        await WidgetService.updateTodayCourses(scheduleItems);
        AppLogger.debug('今日课程小组件更新成功');
      } else {
        await WidgetService.updateTodayCourses([]);
        AppLogger.debug('今日无课，小组件已更新');
      }
    } catch (e) {
      AppLogger.debug('更新今日课程小组件失败: $e');
    }
  }

  /// 从缓存更新近日课程小组件
  static Future<void> _updateTodayAndTomorrowWidgetFromCache() async {
    try {
      final courses = _getTodayAndTomorrowCoursesFromCache();

      Map<String, List<ScheduleItem>> scheduleItems = {};
      scheduleItems['today'] = _convertToScheduleItems(courses['today']!);
      scheduleItems['tomorrow'] = _convertToScheduleItems(courses['tomorrow']!);
      await WidgetService.updateTodayAndTomorrowCourses(scheduleItems);
      AppLogger.debug('近日课程小组件更新成功');
    } catch (e) {
      AppLogger.debug('更新近日课程小组件失败: $e');
    }
  }

  /// 更新今日课程小组件（公开方法，用于外部调用）
  @pragma('vm:entry-point')
  static Future<void> updateTodayWidget() async {
    await _ensureInitialized();
    try {
      await _preloadData();
      await _updateTodayWidgetFromCache();
    } catch (e) {
      AppLogger.debug('更新小组件失败: $e');
    }
  }

  /// 更新近日课程小组件（公开方法，用于外部调用）
  @pragma('vm:entry-point')
  static Future<void> updateTodayAndTomorrowWidget() async {
    await _ensureInitialized();
    try {
      await _preloadData();
      await _updateTodayAndTomorrowWidgetFromCache();
    } catch (e) {
      AppLogger.debug('更新小组件失败: $e');
    }
  }

  /// 转换课程数据为小组件显示格式
  static List<ScheduleItem> _convertToScheduleItems(List<CourseModel> courses) {
    final List<ScheduleItem> items = [];

    for (final course in courses) {
      try {
        final time = TimeService.getStartAndEnd(course);

        items.add(ScheduleItem(
          title: course.courseName,
          time:
              '第${course.startUnit}-${course.endUnit}节 ${time.start}-${time.end}',
          location: course.room,
          teacher: course.room,
        ));
      } catch (e) {
        AppLogger.debug('转换课程 ${course.courseName} 失败: $e');
        // 即使单个课程转换失败，也继续处理其他课程
        continue;
      }
    }

    return items;
  }
}
