import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/core/utils/week_start_utils.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/week_info.dart';
import 'package:ios_club_app/features/education/application/education_providers.dart';
import 'package:ios_club_app/features/system/notifications/task_executor.dart';
import 'package:ios_club_app/platform/android/background_service.dart';
import 'package:ios_club_app/platform/ios/background_service.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/state/user_store.dart';

final scheduleStoreProvider =
    NotifierProvider<ScheduleStore, ScheduleState>(ScheduleStore.new);

class ScheduleStore extends Notifier<ScheduleState> {
  List<CourseModel> _allCoursesRemind = [];
  int _refreshCount = 0;

  @override
  ScheduleState build() {
    ref.listen<List<String>>(
      courseStoreProvider.select((value) => value.ignoreCourses),
      (previous, next) {
        if (previous != null && previous != next) {
          refreshCourseData();
        }
      },
    );
    ref.listen<int>(
      schoolStoreProvider.select(
        (value) => value.school?.weekStartDay ?? School.defaultWeekStartDay,
      ),
      (previous, next) {
        if (previous != null && previous != next) {
          Future<void>.microtask(initializeData);
        }
      },
    );
    Future<void>.microtask(initializeData);
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
      final weekResult = await ref
          .read(educationTimeRepositoryProvider)
          .getWeek(weekStartDay: _weekStartDay);
      if (!weekResult.isSuccess) throw weekResult.error;
      final weekData = weekResult.data;
      _handleWeekData(weekData);
      final isLogin = ref.read(userStoreProvider).isLogin;
      if (isLogin) {
        await getRemindCourses();
        await _loadCourses();
      } else {
        final guestCourses = await ref
            .read(courseStoreProvider.notifier)
            .loadGuestAndCustomCourses();
        if (guestCourses.isNotEmpty) {
          _applyCourses(guestCourses);
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
    if (guestCourses.isNotEmpty) {
      _applyCourses(guestCourses);
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

  Future<void> getRemindCourses() async {
    final result = await ref
        .read(courseFeatureRepositoryProvider)
        .getAllCourses(applyIgnore: false);
    if (!result.isSuccess) throw result.error;
    _allCoursesRemind = result.data;
  }

  Future<void> refreshCourseData() async {
    final ignoreCourses = ref.read(courseStoreProvider).ignoreCourses;
    final courses = <CourseModel>[];
    for (final item in _allCoursesRemind) {
      if (ignoreCourses.isNotEmpty &&
          ignoreCourses.any((x) => x == item.courseName)) {
        continue;
      }
      courses.add(item);
    }
    _applyCourses(courses);
  }

  Future<void> _loadCourses() async {
    final result =
        await ref.read(courseFeatureRepositoryProvider).getAllCourses();
    if (!result.isSuccess) throw result.error;
    _applyCourses(result.data);
  }

  void _applyCourses(List<CourseModel> courses) {
    var isYanTa = state.isYanTa;
    if (courses.isNotEmpty) {
      final firstCourse = courses[0];
      isYanTa = !(firstCourse.campus == '草堂校区' ||
          (firstCourse.room.length >= 2 && firstCourse.room.startsWith('草堂')));
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
    final courseSize = PrefsService.instance.getDouble('course_size');

    if (courseSize != null && courseSize != 0) {
      state = state.copyWith(height: courseSize);
    }
  }

  Future<void> refreshCourses() async {
    final currentRefreshId = ++_refreshCount;
    AppLogger.debug('[ScheduleStore] 开始刷新课程');
    state = state.copyWith(isLoading: true);
    try {
      AppLogger.debug('[ScheduleStore] 调用 CourseRepository.refreshCourses');

      final weekResult =
          await ref.read(educationTimeRepositoryProvider).getWeek(
                forceRefresh: true,
                weekStartDay: _weekStartDay,
              );
      if (!weekResult.isSuccess) throw weekResult.error;
      final weekData = weekResult.data;

      if (currentRefreshId != _refreshCount) return;

      _handleWeekData(weekData);

      final refreshResult = await ref
          .read(courseFeatureRepositoryProvider)
          .refreshCourses()
          .timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          AppLogger.warning('[ScheduleStore] 刷新课程超时');
          throw TimeoutException('刷新课程超时');
        },
      );
      if (!refreshResult.isSuccess) throw refreshResult.error;

      if (currentRefreshId != _refreshCount) return;

      AppLogger.debug('[ScheduleStore] CourseRepository.refreshCourses 完成');

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
      if (currentRefreshId != _refreshCount) return;
      AppLogger.warning('[ScheduleStore] 刷新课程超时: $e');
      rethrow;
    } catch (e, stackTrace) {
      if (currentRefreshId != _refreshCount) return;
      AppLogger.error(
        '[ScheduleStore] 刷新课程失败',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      if (currentRefreshId == _refreshCount) {
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

  Future<void> setCourseHeight(double value) async {
    state = state.copyWith(height: value);
    await PrefsService.instance.setDouble('course_size', value);
  }

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

    var filteredCourses = state.allCourses[weekIndex]
        .where((course) =>
            course.weekIndexes.contains(weekIndex) && course.weekday == weekDay)
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

    filteredCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

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
      final targetWeek =
          tomorrowWeekStart == todayWeekStart ? weekIndex : weekIndex + 1;

      if (targetWeek >= state.allCourses.length) {
        return [];
      }

      final courses = state.allCourses[targetWeek];
      isShowingTomorrow = true;
      filteredCourses = courses
          .where((course) => course.weekday == tomorrowWeekDay)
          .toList()
        ..sort((a, b) => a.startUnit.compareTo(b.startUnit));
    }

    Future<void>.microtask(() {
      state = state.copyWith(showTomorrow: isShowingTomorrow);
    });

    return filteredCourses;
  }

  void clean() {
    state = state.copyWith(allCourses: const []);
  }
}
