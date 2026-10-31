import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:ios_club_app/core/models/schedule_item.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/services/schedule_time_service.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/features/basic/services/school_config_cache.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/time_info.dart';
import 'package:ios_club_app/features/education/services/course_service.dart';
import 'package:ios_club_app/features/education/services/edu_time_service.dart';
import 'package:ios_club_app/features/education/services/warehouse_import_store.dart';
import 'package:ios_club_app/features/system/notifications/notification_service.dart';
import 'package:ios_club_app/features/system/widget_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

/// 任务执行器 - 实际的业务逻辑
@pragma('vm:entry-point')
class TaskExecutor {
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

  /// 清空内存缓存（登出后调用）。
  ///
  /// 否则缓存有效期内的下一次任务会拿旧课程重新排通知、刷新小组件，
  /// 把登出时清掉的数据又写回来。
  static void clearCache() {
    _cachedCourses = null;
    _cachedTime = null;
    _cacheTimestamp = null;
  }

  /// 预加载数据到缓存
  static Future<void> _preloadData() async {
    if (_isCacheValid()) {
      _cachedWeekStartDay = SchoolConfigCache.readWeekStartDay();
      return;
    }

    try {
      // 并行获取课程和时间数据
      final results =
          await Future.wait([
            CourseService.getAllCourse(),
            EduTimeService.getTime(),
          ]).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('预加载数据超时');
            },
          );

      _cachedCourses = results[0] as List<CourseModel>;
      _cachedTime = results[1] as TimeInfo;
      _cachedWeekStartDay = SchoolConfigCache.readWeekStartDay();
      _cacheTimestamp = DateTime.now();
      AppLogger.debug('后台任务数据预加载完成');
    } catch (e) {
      AppLogger.debug('预加载数据失败: $e');
      // 不再清空缓存，以便在离线或弱网环境下仍能使用旧缓存更新小组件
    }
  }

  /// 从缓存获取今日或明日课程
  static (bool, List<CourseModel>) _getTodayOrTomorrowCourseFromCache({
    bool isTomorrow = false,
  }) {
    if (_cachedCourses == null || _cachedTime == null) {
      return (false, <CourseModel>[]);
    }

    final time = _cachedTime!;
    var now = DateTime.now();
    if (time.startTime == null) {
      return (false, <CourseModel>[]);
    }

    final startTime = DateTime.parse(time.startTime!);
    var weekNow = EduTimeService.getWeekIndexByStartTime(
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
        var weekTomorrow = EduTimeService.getWeekIndexByStartTime(
          tomorrow,
          startTime,
          weekStartDay: _cachedWeekStartDay,
        );
        var tomorrowWeekday = tomorrow.weekday;

        filteredCourses = _cachedCourses!.where((course) {
          return course.weekIndexes.contains(weekTomorrow) &&
              course.weekday == tomorrowWeekday;
        }).toList();
        filteredCourses = _mergeAndSortCourses(filteredCourses);
        return (true, filteredCourses);
      } else {
        return (false, filteredCourses);
      }
    }

    filteredCourses = filteredCourses.where((course) {
      final end = TimeService.getStartAndEnd(
        course,
        date: now,
      ).endDateTime(now);
      return end == null || now.isBefore(end);
    }).toList();

    filteredCourses = _mergeAndSortCourses(filteredCourses);
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
    var weekNow = EduTimeService.getWeekIndexByStartTime(
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
      final end = TimeService.getStartAndEnd(
        course,
        date: now,
      ).endDateTime(now);
      return end == null || now.isBefore(end);
    }).toList();

    todayCourses = _mergeAndSortCourses(todayCourses);

    // 计算明天日期和周数
    final tomorrow = now.add(const Duration(days: 1));
    var weekTomorrow = EduTimeService.getWeekIndexByStartTime(
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

    tomorrowCourses = _mergeAndSortCourses(tomorrowCourses);

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
    // 后台 isolate 不共享内存，课程提醒/小组件要自己装载一次作息表
    await ScheduleTimeService.ensureLoaded();
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

      // 先撤销过期却仍挂在系统里的旧闹钟：设备重启/应用更新后 Android
      // 会把这些过期闹钟重新注册并立刻触发，用户就会在半夜收到通知。
      await NotificationService.purgeStaleReminders();

      final now = DateTime.now();

      // 一天只提醒一次（force 模式除外，如用户主动启用提醒时）
      if (!force) {
        final lastRemindStr = prefs.getString(PrefsKeys.LAST_REMIND_DATE);
        if (lastRemindStr != null) {
          try {
            final lastRemindDate = DateTime.parse(lastRemindStr);
            final alreadyScheduledToday =
                lastRemindDate.year == now.year &&
                lastRemindDate.month == now.month &&
                lastRemindDate.day == now.day;
            if (alreadyScheduledToday) {
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

      // 只排期一天的课程，优先今天，今天没课则排明天。
      // 即使两天都没课也要调用 remindList：它会顺便撤销已经过期、
      // 却还挂在系统里的旧闹钟（Android 会在开机/更新后立刻把它们弹出来）。
      DateTime? scheduledDate;
      List<CourseModel>? dailyCourses;
      for (int i = 0; i < 2; i++) {
        final targetDate = now.add(Duration(days: i));
        final targetWeek = EduTimeService.getWeekIndexByStartTime(
          targetDate,
          startTime,
          weekStartDay: _cachedWeekStartDay,
        );
        final targetWeekday = targetDate.weekday;

        var courses = _cachedCourses!.where((course) {
          return course.weekIndexes.contains(targetWeek) &&
              course.weekday == targetWeekday;
        }).toList();

        // 如果是今天，过滤掉已经结束的课程
        if (i == 0) {
          courses = courses.where((course) {
            final end = TimeService.getStartAndEnd(
              course,
              date: now,
            ).endDateTime(now);
            return end == null || now.isBefore(end);
          }).toList();
        }

        courses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

        if (courses.isNotEmpty) {
          dailyCourses = courses;
          scheduledDate = targetDate;
          break; // 一天有课即停止，不再排后续天数
        }
      }

      await NotificationService.remindList(
        dailyCourses ?? const <CourseModel>[],
        targetDate: scheduledDate ?? now,
      );

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

      if (PlatformUtils.isIOS) {
        // iOS 小组件拿整学期快照自行推算时间线，不需要 App 预先筛好当天课程
        await _updateIOSScheduleSnapshot();
      } else {
        // 并行更新两个小组件
        await Future.wait([
          _updateTodayWidgetFromCache(),
          _updateTodayAndTomorrowWidgetFromCache(),
        ]);
      }
    } catch (e) {
      AppLogger.debug('更新小组件失败: $e');
    } finally {
      _isExecuting = false;
    }
  }

  /// 推送整学期课表快照给 iOS 小组件。
  ///
  /// 课程数据拿不到时直接跳过：宁可让小组件继续用上一份快照，也不要用空数据把它刷白。
  static Future<void> _updateIOSScheduleSnapshot() async {
    final courses = _cachedCourses;
    if (courses == null) {
      AppLogger.debug('没有课程缓存，跳过 iOS 小组件快照更新');
      return;
    }

    try {
      final imported = WarehouseImportStore.read();
      final useImported = TimeService.isUsingImportedTable && imported != null;
      final semesterStart = useImported
          ? imported.config?.semesterStartDate
          : _cachedTime?.startTime;
      final semesterEnd = useImported
          ? _importedSemesterEnd(imported)
          : _cachedTime?.endTime;
      await WidgetService.updateScheduleSnapshot(
        courses: courses,
        tables: TimeService.tables,
        semesterStart: semesterStart,
        semesterEnd: semesterEnd,
        weekStartDay: _cachedWeekStartDay,
      );
      AppLogger.debug('iOS 小组件课表快照更新成功');
    } catch (e) {
      AppLogger.debug('更新 iOS 小组件课表快照失败: $e');
    }
  }

  /// 适配仓库只下发开学日期和总周数，这里补出结束日期给小组件。
  static String? _importedSemesterEnd(WarehouseImportedTimetable imported) {
    final start = imported.config?.semesterStartDate;
    final startDate = start == null ? null : DateTime.tryParse(start);
    if (startDate == null) return null;
    final totalWeeks = imported.config?.semesterTotalWeeks ?? 20;
    final end = startDate.add(Duration(days: totalWeeks * 7 - 1));
    final month = end.month.toString().padLeft(2, '0');
    final day = end.day.toString().padLeft(2, '0');
    return '${end.year.toString().padLeft(4, '0')}-$month-$day';
  }

  /// 从缓存更新今日课程小组件
  static Future<void> _updateTodayWidgetFromCache() async {
    try {
      final (_, courses) = _getTodayOrTomorrowCourseFromCache(
        isTomorrow: false,
      );

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

        items.add(
          ScheduleItem(
            title: course.courseName,
            time:
                '第${course.startUnit}-${course.endUnit}节 ${time.start}-${time.end}',
            location: course.room,
            teacher: course.teachers.join(', '),
          ),
        );
      } catch (e) {
        AppLogger.debug('转换课程 ${course.courseName} 失败: $e');
        // 即使单个课程转换失败，也继续处理其他课程
        continue;
      }
    }

    return items;
  }

  /// 统一小组件课程展示规则：同名且节次相同的课程合并授课教师。
  static List<CourseModel> _mergeAndSortCourses(List<CourseModel> courses) {
    final mergedCourses = CourseModel.mergeSameNameCourses(courses);
    mergedCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));
    return mergedCourses;
  }
}
