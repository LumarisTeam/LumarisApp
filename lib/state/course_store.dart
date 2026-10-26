import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/repositories/course_repository.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository();
});

final courseStoreProvider = NotifierProvider<CourseStore, CourseState>(
  CourseStore.new,
);

class CourseStore extends Notifier<CourseState> {
  CourseRepository get _repository => ref.read(courseRepositoryProvider);

  @override
  CourseState build() {
    return const CourseState();
  }

  List<CourseModel> get courses => List.unmodifiable(state.courses);
  List<String> get ignoreCourses => List.unmodifiable(state.ignoreCourses);
  List<String> get ignoreCoursesList => ignoreCourses;
  List<CourseModel> get customCourses =>
      state.courses.where((course) => course.isCustom).toList();

  Future<void> loadCourses() async {
    final courses = await _repository.getCourses();
    state = state.copyWith(courses: courses);
  }

  Future<void> saveCourses(List<CourseModel> courses) async {
    await _repository.saveCourses(courses);
    state = state.copyWith(courses: courses);
  }

  Future<void> loadIgnoreCourses() async {
    final prefs = PrefsService.instance;
    final String? jsonString = prefs.getString(PrefsKeys.IGNORE_DATA);

    if (jsonString != null) {
      try {
        final List<String> list = [];
        var jsonList = jsonDecode(jsonString);
        jsonList = jsonList['data'];
        for (final json in jsonList) {
          list.add(json as String);
        }
        state = state.copyWith(ignoreCourses: list);
      } catch (_) {
        await prefs.remove(PrefsKeys.IGNORE_DATA);
      }
    }
  }

  void setIgnoreCourses(List<String> ignoreList) {
    state = state.copyWith(ignoreCourses: List<String>.from(ignoreList));
  }

  Future<void> saveCourseData(List<String> ignoreList) async {
    await PrefsService.instance.setString(
      PrefsKeys.IGNORE_DATA,
      jsonEncode({'data': ignoreList}),
    );
  }

  Future<void> addIgnoreCourse(String courseName) async {
    if (!state.ignoreCourses.contains(courseName)) {
      final next = [...state.ignoreCourses, courseName];
      setIgnoreCourses(next);
      await saveCourseData(next);
    }
  }

  Future<void> removeIgnoreCourse(String courseName) async {
    if (state.ignoreCourses.contains(courseName)) {
      final next = state.ignoreCourses
          .where((course) => course != courseName)
          .toList();
      setIgnoreCourses(next);
      await saveCourseData(next);
    }
  }

  void clearCourseData() {
    PrefsService.instance.remove(PrefsKeys.GUEST_COURSE_DATA);
    state = state.copyWith(courses: const []);
  }

  Future<void> saveGuestCourses(List<CourseModel> courses) async {
    final jsonList = courses.map((c) => c.toJson()).toList();
    await PrefsService.instance.setString(
      PrefsKeys.GUEST_COURSE_DATA,
      jsonEncode(jsonList),
    );
    state = state.copyWith(courses: courses);
  }

  Future<void> loadGuestCourses() async {
    final prefs = PrefsService.instance;
    final String? jsonString = prefs.getString(PrefsKeys.GUEST_COURSE_DATA);
    if (jsonString == null || jsonString.isEmpty) return;

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      final courses = jsonList
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(courses: courses);
    } catch (_) {
      await prefs.remove(PrefsKeys.GUEST_COURSE_DATA);
    }
  }

  Future<List<CourseModel>> loadCustomCourses() async {
    final prefs = PrefsService.instance;
    final String? jsonString = prefs.getString(PrefsKeys.CUSTOM_COURSE_DATA);
    if (jsonString == null || jsonString.isEmpty) {
      return const <CourseModel>[];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .where((course) => course.isCustom)
          .toList();
    } catch (_) {
      await prefs.remove(PrefsKeys.CUSTOM_COURSE_DATA);
      return const <CourseModel>[];
    }
  }

  Future<List<CourseModel>> loadGuestAndCustomCourses() async {
    await loadGuestCourses();
    final guestCourses = state.courses
        .where((course) => !course.isCustom)
        .toList();
    final customCourses = await loadCustomCourses();
    final mergedCourses = [...guestCourses, ...customCourses];
    state = state.copyWith(courses: mergedCourses);
    return mergedCourses;
  }

  Future<void> clearGuestCourses() async {
    await PrefsService.instance.remove(PrefsKeys.GUEST_COURSE_DATA);
    state = state.copyWith(courses: const []);
  }
}
