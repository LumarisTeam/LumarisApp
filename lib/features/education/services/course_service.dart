import 'dart:convert';

import 'package:ios_club_app/core/models/course_time.dart';
import 'package:ios_club_app/core/repositories/course_repository.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'package:ios_club_app/features/education/models/week_info.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

import 'auth_service.dart';
import '../apis/course_api.dart';
import '../models/edu_fetch_models.dart';
import 'edu_http_client_manager.dart';
import 'edu_time_service.dart';

class CourseService {
  static int get _weekStartDay {
    return EduHttpClientManager.currentSchoolOrNull?.weekStartDay ??
        School.defaultWeekStartDay;
  }

  static Future<FetchSnapshot<List<CourseModel>>> getCourses({
    FetchPolicy policy = FetchPolicy.localFirst,
    bool includeIgnored = false,
  }) async {
    final localCourses = await _readCoursesFromLocal(
      includeIgnored: includeIgnored,
    );

    switch (policy) {
      case FetchPolicy.localFirst:
        if (localCourses.isNotEmpty) {
          return FetchSnapshot<List<CourseModel>>(
            data: localCourses,
            isFromLocal: true,
            isStale: false,
          );
        }
        return _refreshCourses(
          includeIgnored: includeIgnored,
          fallbackCourses: localCourses,
        );
      case FetchPolicy.refresh:
      case FetchPolicy.fallbackToLocal:
        return _refreshCourses(
          includeIgnored: includeIgnored,
          fallbackCourses: localCourses,
        );
    }
  }

  static Future<List<CourseModel>> getAllCourse({
    bool isNeedIgnore = true,
  }) async {
    final snapshot = await getCourses(includeIgnored: !isNeedIgnore);
    return snapshot.data;
  }

  static Future<List<String>> getCourseName() async {
    final courseRepo = CourseRepository();
    final courses = await courseRepo.getCourses();
    final list = <String>[];
    for (final c in courses) {
      if (!c.isCustom && !list.any((x) => x == c.courseName)) {
        list.add(c.courseName);
      }
    }
    return list;
  }

  static Future<void> setIgnore(List<String> list) async {
    final prefs = PrefsService.instance;
    await prefs.setString(PrefsKeys.IGNORE_DATA, jsonEncode({'data': list}));
  }

  static Future<List<String>> getIgnore() async {
    final prefs = PrefsService.instance;
    final jsonString = prefs.getString(PrefsKeys.IGNORE_DATA);
    final list = <String>[];
    if (jsonString != null) {
      var jsonList = jsonDecode(jsonString);
      jsonList = jsonList['data'];
      for (final json in jsonList) {
        list.add(json);
      }
    }
    return list;
  }

  static Future<void> getCourse({
    UserData? userData,
    bool isRefresh = false,
  }) async {
    await fetchCoursesFromRemote(userData: userData, forceRefresh: isRefresh);
  }

  static Future<List<CourseModel>> fetchCoursesFromRemote({
    UserData? userData,
    bool forceRefresh = false,
  }) async {
    final courseRepo = CourseRepository();
    final cookieData = userData ?? await AuthService.getUserData();
    if (cookieData == null) {
      return courseRepo.getCourses();
    }

    try {
      final response = await CourseApi.getCourse(
        cookieData.studentId,
        forceRefresh: forceRefresh,
      );
      final courses = response;
      await courseRepo.saveCourses(courses);
      await setIgnore([]);
      return courses;
    } catch (e, stackTrace) {
      AppLogger.error('获取课程信息失败', error: e, stackTrace: stackTrace);
    }

    return courseRepo.getCourses();
  }

  static Future<List<CourseModel>> getCourseByWeek({int week = 0}) async {
    final allCourse = await getAllCourse();
    if (week == 0) {
      final time = await EduTimeService.getTime();
      if (time.startTime == null) {
        return [];
      }
      week = EduTimeService.getWeekIndexByStartTime(
        DateTime.now(),
        DateTime.parse(time.startTime!),
        weekStartDay: _weekStartDay,
      );
    }

    return allCourse
        .where((course) => course.weekIndexes.contains(week))
        .toList();
  }

  static Future<(bool, List<CourseModel>)> getTodayOrTomorrowCourse({
    bool isTomorrow = false,
  }) async {
    final allCourse = await getAllCourse();
    final time = await EduTimeService.getTime();
    final now = DateTime.now();
    if (time.startTime == null) {
      return (false, <CourseModel>[]);
    }

    final startTime = DateTime.parse(time.startTime!);
    var weekNow = EduTimeService.getWeekIndexByStartTime(
      now,
      startTime,
      weekStartDay: _weekStartDay,
    );

    var filteredCourses = allCourse.where((course) {
      return course.weekIndexes.contains(weekNow) &&
          course.weekday == now.weekday;
    }).toList();

    if (filteredCourses.isEmpty) {
      if (!isTomorrow) {
        return (false, filteredCourses);
      }
      final tomorrow = now.add(const Duration(days: 1));
      var weekTomorrow = EduTimeService.getWeekIndexByStartTime(
        tomorrow,
        startTime,
        weekStartDay: _weekStartDay,
      );
      var tomorrowWeekday = tomorrow.weekday;

      filteredCourses = allCourse.where((course) {
        return course.weekIndexes.contains(weekTomorrow) &&
            course.weekday == tomorrowWeekday;
      }).toList();
      if (filteredCourses.isEmpty) {
        return (true, filteredCourses);
      }
      filteredCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));
      return (true, filteredCourses);
    }

    filteredCourses = filteredCourses.where((course) {
      final end = TimeService.getStartAndEnd(
        course,
        date: now,
      ).endDateTime(now);
      return end == null || now.isBefore(end);
    }).toList();

    filteredCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));
    return (false, filteredCourses);
  }

  static Future<Map<String, List<CourseModel>>>
  getTodayAndTomorrowCourses() async {
    final allCourse = await getAllCourse();
    final time = await EduTimeService.getTime();
    var now = DateTime.now();

    if (time.startTime == null) {
      return {
        'today': List<CourseModel>.unmodifiable([]),
        'tomorrow': List<CourseModel>.unmodifiable([]),
      };
    }

    final startTime = DateTime.parse(time.startTime!);
    var weekNow = EduTimeService.getWeekIndexByStartTime(
      now,
      startTime,
      weekStartDay: _weekStartDay,
    );

    var todayCourses = allCourse.where((course) {
      return course.weekIndexes.contains(weekNow) &&
          course.weekday == now.weekday;
    }).toList();

    todayCourses = todayCourses.where((course) {
      final end = TimeService.getStartAndEnd(
        course,
        date: now,
      ).endDateTime(now);
      return end == null || now.isBefore(end);
    }).toList();

    todayCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

    final tomorrow = now.add(const Duration(days: 1));
    var weekTomorrow = EduTimeService.getWeekIndexByStartTime(
      tomorrow,
      startTime,
      weekStartDay: _weekStartDay,
    );
    var tomorrowWeekday = tomorrow.weekday;

    final tomorrowCourses = allCourse.where((course) {
      return course.weekIndexes.contains(weekTomorrow) &&
          course.weekday == tomorrowWeekday;
    }).toList()..sort((a, b) => a.startUnit.compareTo(b.startUnit));

    return {'today': todayCourses, 'tomorrow': tomorrowCourses};
  }

  static Future<List<CourseTime>> getAllTime() async {
    final allCourse = await getAllCourse();
    final weekData = await EduTimeService.getWeek(weekStartDay: _weekStartDay);
    var now = DateTime.now();

    final timeList = <CourseTime>[];
    final weekCourses = allCourse.where((course) {
      return course.weekIndexes.contains(weekData.week);
    }).toList();

    for (var j = now.weekday; j < 7; j++) {
      final dayCourses = weekCourses.where((course) {
        return course.weekday == j;
      }).toList()..sort((a, b) => a.startUnit.compareTo(b.startUnit));

      for (final courseToday in dayCourses) {
        final time = TimeService.getStartAndEnd(courseToday);
        var l = time.start.split(':');
        final start = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(l[0]),
          int.parse(l[1]),
        );

        if (start.compareTo(now) <= 0) {
          continue;
        }
        if (timeList.isNotEmpty && timeList.last.startTime == start) {
          continue;
        }

        l = time.end.split(':');
        final end = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(l[0]),
          int.parse(l[1]),
        );

        timeList.add(
          CourseTime(
            startTime: start,
            courseName: courseToday.courseName,
            endTime: end,
          ),
        );
      }
      now = DateTime(now.year, now.month, now.day + 1);
    }

    return timeList;
  }

  static Future<WeekInfo> getWeek({bool isRefresh = false}) {
    return EduTimeService.getWeek(
      isRefresh: isRefresh,
      weekStartDay: _weekStartDay,
    );
  }

  static Future<List<CourseModel>> _readCoursesFromLocal({
    required bool includeIgnored,
  }) async {
    final ignoredCourses = includeIgnored ? <String>[] : await getIgnore();
    final allCourses = <CourseModel>[];
    final courseRepo = CourseRepository();
    final serverCourses = await courseRepo.getCourses();

    for (final course in serverCourses) {
      if (course.isCustom) {
        continue;
      }
      if (ignoredCourses.isNotEmpty &&
          ignoredCourses.any((name) => name == course.courseName)) {
        continue;
      }
      allCourses.add(course);
    }

    final prefs = PrefsService.instance;
    final customJsonString = prefs.getString(PrefsKeys.CUSTOM_COURSE_DATA);
    if (customJsonString != null) {
      try {
        final List<dynamic> customJsonList = jsonDecode(customJsonString);
        for (final json in customJsonList) {
          final course = CourseModel.fromJson(json);
          if (course.isCustom) {
            allCourses.add(course);
          }
        }
      } catch (e) {
        AppLogger.debug('解析自定义课程数据失败: $e');
      }
    }

    return allCourses;
  }

  static Future<FetchSnapshot<List<CourseModel>>> _refreshCourses({
    required bool includeIgnored,
    List<CourseModel> fallbackCourses = const [],
  }) async {
    try {
      await fetchCoursesFromRemote(forceRefresh: true);
      final refreshedCourses = await _readCoursesFromLocal(
        includeIgnored: includeIgnored,
      );
      return FetchSnapshot<List<CourseModel>>(
        data: refreshedCourses,
        isFromLocal: false,
        isStale: false,
      );
    } catch (e) {
      AppLogger.debug('刷新课程数据失败: $e');
      return FetchSnapshot<List<CourseModel>>(
        data: fallbackCourses,
        isFromLocal: true,
        isStale: fallbackCourses.isNotEmpty,
      );
    }
  }
}
