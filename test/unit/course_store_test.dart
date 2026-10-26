import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;
  late CourseStore courseStore;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
    container = ProviderContainer();
    addTearDown(container.dispose);
    courseStore = container.read(courseStoreProvider.notifier);
  });

  group('CourseStore', () {
    CourseModel buildCourse({
      required String lessonId,
      required String courseName,
      bool isCustom = false,
    }) {
      return CourseModel(
        lessonId: lessonId,
        courseName: courseName,
        teachers: const ['测试老师'],
        room: 'A101',
        weekIndexes: const [1, 2],
        weekday: 1,
        startUnit: 1,
        endUnit: 2,
        isCustom: isCustom,
      );
    }

    test('should_initialize_with_empty_lists', () {
      expect(courseStore.courses, isEmpty);
      expect(courseStore.ignoreCourses, isEmpty);
    });

    test('should_set_ignore_courses_in_bulk', () {
      courseStore.setIgnoreCourses(['数学', '英语']);

      expect(courseStore.ignoreCourses, hasLength(2));
      expect(courseStore.ignoreCourses, containsAll(['数学', '英语']));
    });

    test('should_add_single_ignore_course', () async {
      courseStore.setIgnoreCourses(['数学']);
      await courseStore.addIgnoreCourse('英语');

      expect(courseStore.ignoreCourses, hasLength(2));
      expect(courseStore.ignoreCourses, containsAll(['数学', '英语']));
    });

    test('should_not_add_duplicate_ignore_course', () async {
      courseStore.setIgnoreCourses(['数学']);
      await courseStore.addIgnoreCourse('数学');

      expect(courseStore.ignoreCourses, hasLength(1));
    });

    test('should_remove_ignore_course', () async {
      courseStore.setIgnoreCourses(['数学', '英语']);
      await courseStore.removeIgnoreCourse('数学');

      expect(courseStore.ignoreCourses, hasLength(1));
      expect(courseStore.ignoreCourses, contains('英语'));
      expect(courseStore.ignoreCourses, isNot(contains('数学')));
    });

    test('should_not_throw_when_removing_non_existent_course', () async {
      courseStore.setIgnoreCourses(['数学']);
      await expectLater(courseStore.removeIgnoreCourse('英语'), completes);
      expect(courseStore.ignoreCourses, hasLength(1));
    });

    test('should_clear_course_data_without_throwing', () {
      expect(() => courseStore.clearCourseData(), returnsNormally);
    });

    test('should_expose_ignoreCoursesList_as_reactive_list', () {
      expect(courseStore.ignoreCoursesList, isA<List<String>>());
    });

    test('should_add_to_empty_ignore_list', () async {
      await courseStore.addIgnoreCourse('新课程');

      expect(courseStore.ignoreCourses, hasLength(1));
      expect(courseStore.ignoreCourses, contains('新课程'));
    });

    test('should_handle_large_ignore_course_list', () async {
      final largeList = List.generate(100, (i) => '课程$i');
      courseStore.setIgnoreCourses(largeList);
      expect(courseStore.ignoreCourses, hasLength(100));

      await courseStore.addIgnoreCourse('新课程');
      expect(courseStore.ignoreCourses, hasLength(101));

      await courseStore.removeIgnoreCourse('课程50');
      expect(courseStore.ignoreCourses, hasLength(100));
      expect(courseStore.ignoreCourses, isNot(contains('课程50')));
    });

    test('should_clear_courses_from_memory', () {
      courseStore.clearCourseData();
      expect(courseStore.courses, isEmpty);
    });

    test('should_load_custom_courses_from_prefs', () async {
      final customCourse = buildCourse(
        lessonId: 'custom-1',
        courseName: '自定义课程',
        isCustom: true,
      );
      await PrefsService.instance.setString(
        PrefsKeys.CUSTOM_COURSE_DATA,
        jsonEncode([customCourse.toJson()]),
      );

      final customCourses = await courseStore.loadCustomCourses();

      expect(customCourses, hasLength(1));
      expect(customCourses.first.courseName, '自定义课程');
      expect(customCourses.first.isCustom, isTrue);
    });

    test('should_merge_guest_and_custom_courses', () async {
      final guestCourse = buildCourse(lessonId: 'guest-1', courseName: '游客课程');
      final customCourse = buildCourse(
        lessonId: 'custom-1',
        courseName: '自定义课程',
        isCustom: true,
      );

      await courseStore.saveGuestCourses([guestCourse]);
      await PrefsService.instance.setString(
        PrefsKeys.CUSTOM_COURSE_DATA,
        jsonEncode([customCourse.toJson()]),
      );

      final mergedCourses = await courseStore.loadGuestAndCustomCourses();

      expect(mergedCourses, hasLength(2));
      expect(
        mergedCourses.map((course) => course.courseName),
        containsAll(['游客课程', '自定义课程']),
      );
    });
  });
}
