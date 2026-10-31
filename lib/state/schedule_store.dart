import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/constants/schedule_constants.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/core/utils/stale_request_guard.dart';
import 'package:ios_club_app/core/utils/week_start_utils.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/week_info.dart';
import 'package:ios_club_app/features/education/services/course_service.dart';
import 'package:ios_club_app/features/education/services/edu_time_service.dart';
import 'package:ios_club_app/features/education/services/warehouse_course_mapper.dart';
import 'package:ios_club_app/features/education/services/warehouse_import_store.dart';
import 'package:ios_club_app/features/system/notifications/task_executor.dart';
import 'package:ios_club_app/platform/android/background_service.dart';
import 'package:ios_club_app/platform/ios/background_service.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/state/user_store.dart';

final scheduleStoreProvider = NotifierProvider<ScheduleStore, ScheduleState>(
  ScheduleStore.new,
);

class ScheduleStore extends Notifier<ScheduleState> {
  List<CourseModel> _allCoursesRemind = [];
  final _refreshGuard = StaleRequestGuard();

  @override
  ScheduleState build() {
    Future<void>.microtask(() async {
      try {
        await initializeData();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Failed to initialize schedule data',
          error: error,
          stackTrace: stackTrace,
        );
        // Set error state so UI knows initialization failed
        state = state.copyWith(isLoading: false);
      }
    });
    return const ScheduleState();
  }

  List<List<CourseModel>> get allCourses => List.unmodifiable(state.allCourses);
  bool get isLoading => state.isLoading;
  int get maxWeek => state.maxWeek;
  int get currentWeek => state.currentWeek;
  int get currentPage => state.currentPage;
  double get height => state.height;
  bool get isYanTa => state.isYanTa;
  bool get showTomorrow => state.showTomorrow;
  bool get isShowTomorrow => ref.read(settingsStoreProvider).isShowTomorrow;
  int get weekNow => state.weekNow;

  int get _weekStartDay =>
      ref.read(schoolStoreProvider).school?.weekStartDay ??
      School.defaultWeekStartDay;

  Future<void> initializeData() async {
    try {
      final weekData = await EduTimeService.getWeek(
        weekStartDay: _weekStartDay,
      );
      _handleWeekData(weekData);
      final isLogin = ref.read(userStoreProvider).isLogin;
      if (isLogin) {
        // 登录态使用学校服务端的作息；导入作息只在游客课表下生效。
        TimeService.clearImportedTable();
        await getRemindCourses();
        await _loadCourses();
      } else {
        final imported = WarehouseImportStore.read();
        if (imported != null) {
          if (imported.timeSlots.isNotEmpty) {
            TimeService.installImportedSlots(imported.timeSlots);
          }
          applyImportedWeekConfig(
            semesterStartDate: imported.config?.semesterStartDate,
            semesterTotalWeeks: imported.config?.semesterTotalWeeks,
            firstDayOfWeek: imported.config?.firstDayOfWeek,
          );
        } else {
          TimeService.clearImportedTable();
        }
        final guestCourses = await ref
            .read(courseStoreProvider.notifier)
            .loadGuestAndCustomCourses();
        _allCoursesRemind = guestCourses;
        if (guestCourses.isNotEmpty) {
          _applyCourses(_filterIgnored(guestCourses));
        } else {
          state = state.copyWith(isLoading: false);
        }
      }
      await _loadPreferences();
    } catch (e) {
      AppLogger.debug('初始化课表数据出错: $e');
    }
  }

  /// 从 CourseStore 加载游客课程并应用到课表
  Future<void> loadGuestCourseData() async {
    final guestCourses = await ref
        .read(courseStoreProvider.notifier)
        .loadGuestAndCustomCourses();
    _allCoursesRemind = guestCourses;
    if (guestCourses.isNotEmpty) {
      _applyCourses(_filterIgnored(guestCourses));
    } else {
      state = state.copyWith(allCourses: const [], isLoading: false);
    }
  }

  void _handleWeekData(WeekInfo weekData) {
    final currentWeek = weekData.week;
    state = state.copyWith(
      currentWeek: currentWeek,
      weekNow: currentWeek,
      maxWeek: weekData.maxWeek,
      currentPage: currentWeek <= 0 ? 0 : currentWeek,
    );
  }

  /// 用适配仓库导入的学期配置计算当前周与总周数。
  ///
  /// 游客导入没有西建大的 `/Week` 接口，若不显式设置，`currentWeek` 会停在 0，
  /// 课表只能显示「全部课程」而无法按周切换。这里用开学日期算周次；日期缺失或
  /// 早于开学时回退到第 1 周，并用学期总周数作为上界。
  void applyImportedWeekConfig({
    String? semesterStartDate,
    int? semesterTotalWeeks,
    int? firstDayOfWeek,
  }) {
    final total = (semesterTotalWeeks ?? WarehouseCourseMapper.defaultWeeks)
        .clamp(1, 60);
    final weekStartDay = firstDayOfWeek ?? _weekStartDay;
    var current = 1;

    final start = semesterStartDate == null
        ? null
        : DateTime.tryParse(semesterStartDate);
    if (start != null) {
      final now = DateTime.now();
      final startWeek = WeekStartUtils.getWeekStart(start, weekStartDay);
      final currentWeekStart = WeekStartUtils.getWeekStart(now, weekStartDay);
      current = currentWeekStart.difference(startWeek).inDays ~/ 7 + 1;
      current = current.clamp(1, total);
    }

    state = state.copyWith(
      currentWeek: current,
      weekNow: current,
      maxWeek: total,
      currentPage: current,
    );

    if (_allCoursesRemind.isNotEmpty) {
      _applyCourses(_filterIgnored(_allCoursesRemind));
    }
  }

  Future<void> getRemindCourses() async {
    _allCoursesRemind = await CourseService.getAllCourse(isNeedIgnore: false);
  }

  /// 按当前忽略名单重新过滤课表。
  ///
  /// 依据是内存里的未过滤快照，不读 prefs——忽略开关刚点下时，落盘可能还没
  /// 完成。
  Future<void> refreshCourseData() async {
    // 快照只有校内账号登录后由 getRemindCourses() 填充。游客、以及初始化还
    // 没跑完时它是空的，不能当成“一门课都没有”，否则会把整张课表清空。
    if (_allCoursesRemind.isEmpty) {
      await refreshLocalCourses();
      return;
    }

    _applyCourses(_filterIgnored(_allCoursesRemind));
  }

  List<CourseModel> _filterIgnored(List<CourseModel> courses) {
    final ignoreCourses = ref.read(courseStoreProvider).ignoreCourses;
    if (ignoreCourses.isEmpty) return courses;

    return courses
        .where((course) => !ignoreCourses.contains(course.courseName))
        .toList();
  }

  Future<void> _loadCourses() async {
    final courses = await CourseService.getAllCourse();
    _applyCourses(courses);
  }

  void _applyCourses(List<CourseModel> courses) {
    var isYanTa = state.isYanTa;
    if (courses.isNotEmpty) {
      final firstCourse = courses[0];
      isYanTa =
          !(firstCourse.campus == '草堂校区' ||
              (firstCourse.room.length >= 2 &&
                  firstCourse.room.startsWith('草堂')));
    }

    state = state.copyWith(
      allCourses: List.generate(state.maxWeek + 1, (i) {
        return i == 0
            ? courses
            : courses
                  .where((course) => course.weekIndexes.contains(i))
                  .toList();
      }),
      isYanTa: isYanTa,
      isLoading: false,
    );
  }

  Future<void> _loadPreferences() async {
    final courseSize = PrefsService.instance.getDouble(PrefsKeys.COURSE_SIZE);

    if (courseSize != null && courseSize != 0) {
      state = state.copyWith(
        height: courseSize.clamp(
          ScheduleConstants.minGridHeight,
          ScheduleConstants.maxGridHeight,
        ),
      );
    }
  }

  Future<void> refreshCourses() async {
    final requestId = _refreshGuard.beginRequest();
    AppLogger.debug('[ScheduleStore] 开始刷新课程');
    state = state.copyWith(isLoading: true);
    try {
      AppLogger.debug('[ScheduleStore] 调用 CourseService.getCourse');

      final weekData = await EduTimeService.getWeek(
        isRefresh: true,
        weekStartDay: _weekStartDay,
      );

      if (!_refreshGuard.isCurrent(requestId)) return;

      _handleWeekData(weekData);

      await CourseService.getCourse(isRefresh: true).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          AppLogger.warning('[ScheduleStore] 刷新课程超时');
          throw TimeoutException('刷新课程超时');
        },
      );

      if (!_refreshGuard.isCurrent(requestId)) return;

      AppLogger.debug('[ScheduleStore] CourseService.getCourse 完成');

      await getRemindCourses();
      AppLogger.debug('[ScheduleStore] getRemindCourses 完成');

      await ref.read(courseStoreProvider.notifier).loadCourses();
      AppLogger.debug('[ScheduleStore] CourseStore.loadCourses 完成');

      await _loadCourses();
      AppLogger.debug('[ScheduleStore] _loadCourses 完成');

      await _syncHomeWidget();
      await TaskExecutor.checkAndSendCourseReminder();
      AppLogger.debug('[ScheduleStore] 小组件同步与通知安排完成');

      AppLogger.debug('[ScheduleStore] 刷新课程成功');
    } on TimeoutException catch (e) {
      if (!_refreshGuard.isCurrent(requestId)) return;
      AppLogger.warning('[ScheduleStore] 刷新课程超时: $e');
      rethrow;
    } catch (e, stackTrace) {
      if (!_refreshGuard.isCurrent(requestId)) return;
      AppLogger.error(
        '[ScheduleStore] 刷新课程失败',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      if (_refreshGuard.isCurrent(requestId)) {
        AppLogger.debug('[ScheduleStore] 设置 isLoading = false');
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> refreshLocalCourses() async {
    state = state.copyWith(isLoading: true);
    try {
      if (ref.read(userStoreProvider).isLogin) {
        await getRemindCourses();
        await _loadCourses();
      } else {
        await loadGuestCourseData();
      }
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _syncHomeWidget() async {
    try {
      if (PlatformUtils.isAndroid) {
        await BackgroundService.updateWidget();
      } else if (PlatformUtils.isIOS) {
        await IOSBackgroundService.updateWidget();
      }
    } catch (e) {
      AppLogger.warning('[ScheduleStore] 同步小组件失败', error: e);
    }
  }

  void jumpToPage(int page) {
    var nextPage = page;
    if (nextPage < 0) {
      nextPage = state.maxWeek;
    } else if (nextPage > state.maxWeek) {
      nextPage = 0;
    }
    state = state.copyWith(currentPage: nextPage);
  }

  /// 只更新内存中的格子高度，用于个性化页滑杆拖动时的实时预览。
  void previewCourseHeight(double value) {
    state = state.copyWith(
      height: value.clamp(
        ScheduleConstants.minGridHeight,
        ScheduleConstants.maxGridHeight,
      ),
    );
  }

  /// 更新并持久化格子高度。
  Future<void> commitCourseHeight(double value) async {
    previewCourseHeight(value);
    await PrefsService.instance.setDouble(PrefsKeys.COURSE_SIZE, state.height);
  }

  Future<void> setCourseHeight(double value) => commitCourseHeight(value);

  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  Future<void> toggleShowTomorrow() async {
    final settingsStore = ref.read(settingsStoreProvider.notifier);
    await settingsStore.setIsShowTomorrow(!settingsStore.isShowTomorrow);
  }

  List<CourseModel> getTodayCourses() {
    final now = DateTime.now();
    final weekDay = now.weekday;
    var isShowingTomorrow = false;

    final weekIndex = state.currentWeek;

    if (weekIndex < 0 || weekIndex >= state.allCourses.length) {
      return [];
    }

    // Index 0 is the unfiltered "all schedules" bucket, not a real semester
    // week. Never use it for today's courses, otherwise pre-semester dates can
    // leak courses from the all-schedules view into the home page.
    var filteredCourses = weekIndex == 0
        ? <CourseModel>[]
        : state.allCourses[weekIndex]
              .where(
                (course) =>
                    course.weekIndexes.contains(weekIndex) &&
                    course.weekday == weekDay,
              )
              .toList();

    filteredCourses = filteredCourses.where((course) {
      final time = TimeService.getStartAndEnd(course);

      final endParts = time.end.split(':');
      final end = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );

      return now.isBefore(end);
    }).toList();

    filteredCourses = CourseModel.mergeSameNameCourses(filteredCourses)
      ..sort((a, b) => a.startUnit.compareTo(b.startUnit));

    if (isShowTomorrow && filteredCourses.isEmpty) {
      final tomorrow = now.add(const Duration(days: 1));
      var tomorrowWeekDay = tomorrow.weekday;
      if (tomorrowWeekDay > 7) {
        tomorrowWeekDay = 1;
      }

      final todayWeekStart = WeekStartUtils.getWeekStart(now, _weekStartDay);
      final tomorrowWeekStart = WeekStartUtils.getWeekStart(
        tomorrow,
        _weekStartDay,
      );
      final targetWeek = tomorrowWeekStart == todayWeekStart
          ? weekIndex
          : weekIndex + 1;

      if (targetWeek > 0 && targetWeek < state.allCourses.length) {
        final courses = state.allCourses[targetWeek];
        isShowingTomorrow = true;
        filteredCourses = courses
            .where((course) => course.weekday == tomorrowWeekDay)
            .toList();
        filteredCourses = CourseModel.mergeSameNameCourses(filteredCourses)
          ..sort((a, b) => a.startUnit.compareTo(b.startUnit));
      }
    }

    // 仅在值真正变化时更新，避免 home 构建期间的 microtask 触发
    // schedule store 的无限重建循环（Riverpod 按对象身份通知）。
    if (state.showTomorrow != isShowingTomorrow) {
      Future<void>.microtask(() {
        if (state.showTomorrow != isShowingTomorrow) {
          state = state.copyWith(showTomorrow: isShowingTomorrow);
        }
      });
    }

    return filteredCourses;
  }

  void clean() {
    _allCoursesRemind = [];
    state = state.copyWith(allCourses: const []);
  }
}
