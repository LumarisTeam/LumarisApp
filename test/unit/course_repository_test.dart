import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/core/repositories/course_repository.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

CourseModel _course({
  String lessonId = 'L001',
  String courseName = '高等数学',
  int weekday = 1,
  int startUnit = 1,
  List<int>? weekIndexes,
  bool isCustom = false,
}) => CourseModel(
  lessonId: lessonId,
  courseName: courseName,
  isCustom: isCustom,
  weekIndexes: weekIndexes ?? [1, 2, 3],
  teachers: ['张老师'],
  room: 'A101',
  weekday: weekday,
  startUnit: startUnit,
  endUnit: startUnit + 1,
);

void main() {
  late Directory tempDir;
  late CourseRepository repo;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('course_repo_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CourseModelAdapter());
    }
    repo = CourseRepository();
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('CourseRepository.saveCourses', () {
    test('should_store_courses_under_indexed_keys', () async {
      await repo.saveCourses([
        _course(lessonId: 'L001'),
        _course(lessonId: 'L002', courseName: '线性代数'),
      ]);

      final box = await Hive.openBox(HiveManager.courseBoxName);
      expect(box.containsKey('course_0'), isTrue);
      expect(box.containsKey('course_1'), isTrue);
    });

    test('should_not_use_lessonId_as_key', () async {
      await repo.saveCourses([_course(lessonId: 'L001')]);

      final box = await Hive.openBox(HiveManager.courseBoxName);
      expect(box.containsKey('course_L001'), isFalse);
    });

    test('should_store_all_courses_including_same_lessonId', () async {
      // 同一 lessonId 不同时间段的课程不应互相覆盖
      await repo.saveCourses([
        _course(
          lessonId: 'L001',
          weekday: 1,
          startUnit: 1,
          weekIndexes: [1, 2],
        ),
        _course(
          lessonId: 'L001',
          weekday: 3,
          startUnit: 3,
          weekIndexes: [3, 4],
        ),
        _course(
          lessonId: 'L001',
          weekday: 5,
          startUnit: 5,
          weekIndexes: [5, 6],
        ),
      ]);

      final result = await repo.getCourses();
      expect(result, hasLength(3));
    });

    test('should_replace_all_courses_on_second_call', () async {
      await repo.saveCourses([
        _course(lessonId: 'L001'),
        _course(lessonId: 'L002', courseName: '线性代数'),
      ]);
      await repo.saveCourses([_course(lessonId: 'L003', courseName: '英语')]);

      final result = await repo.getCourses();
      expect(result, hasLength(1));
      expect(result.first.lessonId, 'L003');
    });

    test('should_not_leave_stale_keys_after_replacement', () async {
      await repo.saveCourses([
        _course(lessonId: 'L001'),
        _course(lessonId: 'L002', courseName: '线性代数'),
      ]);
      await repo.saveCourses([_course(lessonId: 'L003', courseName: '英语')]);

      final box = await Hive.openBox(HiveManager.courseBoxName);
      final courseKeys = box.keys
          .where((k) => k.toString().startsWith('course_'))
          .toList();
      // 只剩 course_0，不应有 course_1
      expect(courseKeys, hasLength(1));
      expect(courseKeys.first, 'course_0');
    });

    test('should_clear_existing_courses_when_saving_empty_list', () async {
      await repo.saveCourses([_course(lessonId: 'L001')]);
      await repo.saveCourses([]);

      final result = await repo.getCourses();
      expect(result, isEmpty);
    });

    test('should_delete_legacy_current_courses_key_when_present', () async {
      final box = await Hive.openBox(HiveManager.courseBoxName);
      await box.put('current_courses', [_course()]);

      await repo.saveCourses([_course(lessonId: 'L001')]);

      expect(box.containsKey('current_courses'), isFalse);
    });

    test('should_store_custom_courses_with_same_index_scheme', () async {
      await repo.saveCourses([
        _course(lessonId: 'L001', isCustom: false),
        _course(lessonId: '', isCustom: true, courseName: '自定义课程'),
      ]);

      final box = await Hive.openBox(HiveManager.courseBoxName);
      expect(box.containsKey('course_0'), isTrue);
      expect(box.containsKey('course_1'), isTrue);
    });
  });

  group('CourseRepository.getCourses', () {
    test('should_return_empty_list_when_box_is_empty', () async {
      final result = await repo.getCourses();
      expect(result, isEmpty);
    });

    test('should_return_all_saved_courses', () async {
      await repo.saveCourses([
        _course(lessonId: 'L001', courseName: '高等数学'),
        _course(lessonId: 'L002', courseName: '线性代数'),
      ]);

      final result = await repo.getCourses();

      expect(result, hasLength(2));
      final names = result.map((c) => c.courseName).toSet();
      expect(names, containsAll(['高等数学', '线性代数']));
    });

    test('should_migrate_from_legacy_hive_single_key_format', () async {
      final box = await Hive.openBox(HiveManager.courseBoxName);
      await box.put('current_courses', [
        _course(lessonId: 'L001', courseName: '高等数学'),
        _course(lessonId: 'L002', courseName: '线性代数'),
      ]);

      final result = await repo.getCourses();

      expect(result, hasLength(2));
      // 旧 key 已被删除
      expect(box.containsKey('current_courses'), isFalse);
      // 新格式 key 已写入（index-based）
      expect(box.containsKey('course_0'), isTrue);
      expect(box.containsKey('course_1'), isTrue);
    });

    test('should_migrate_from_shared_preferences_when_hive_is_empty', () async {
      final jsonData = jsonEncode([
        _course(lessonId: 'SP001', courseName: 'SP课程').toJson(),
      ]);
      // ignore: deprecated_member_use
      await PrefsService.instance.setString(PrefsKeys.COURSE_DATA, jsonData);

      final result = await repo.getCourses();

      expect(result, hasLength(1));
      expect(result.first.lessonId, 'SP001');
      expect(result.first.courseName, 'SP课程');

      // 清理，避免影响其他测试
      // ignore: deprecated_member_use
      await PrefsService.instance.remove(PrefsKeys.COURSE_DATA);
    });

    test('should_preserve_course_fields_after_round_trip', () async {
      final original = CourseModel(
        lessonId: 'L999',
        courseName: '物理',
        room: 'B202',
        teachers: ['李老师', '王老师'],
        weekIndexes: [1, 3, 5],
        weekday: 3,
        startUnit: 3,
        endUnit: 4,
        credits: '3.0',
        campus: '雁塔',
        isCustom: false,
      );
      await repo.saveCourses([original]);

      final result = await repo.getCourses();

      expect(result, hasLength(1));
      final c = result.first;
      expect(c.lessonId, 'L999');
      expect(c.courseName, '物理');
      expect(c.room, 'B202');
      expect(c.teachers, ['李老师', '王老师']);
      expect(c.weekIndexes, [1, 3, 5]);
      expect(c.weekday, 3);
      expect(c.startUnit, 3);
      expect(c.endUnit, 4);
      expect(c.credits, '3.0');
      expect(c.campus, '雁塔');
    });
  });

  group('CourseRepository.getCourseById', () {
    test('should_return_empty_list_for_non_existent_id', () async {
      await repo.saveCourses([_course(lessonId: 'L001')]);

      final result = await repo.getCourseById('NONEXISTENT');

      expect(result, isEmpty);
    });

    test('should_return_empty_list_when_box_is_empty', () async {
      final result = await repo.getCourseById('L001');
      expect(result, isEmpty);
    });

    test('should_return_all_courses_matching_lessonId', () async {
      // 同一 lessonId 的多个时间段都应被返回
      await repo.saveCourses([
        _course(lessonId: 'L001', weekday: 1, startUnit: 1),
        _course(lessonId: 'L001', weekday: 3, startUnit: 3),
        _course(lessonId: 'L002', courseName: '线性代数'),
      ]);

      final result = await repo.getCourseById('L001');

      expect(result, hasLength(2));
      expect(result.every((c) => c.lessonId == 'L001'), isTrue);
    });

    test('should_return_single_course_when_only_one_matches', () async {
      await repo.saveCourses([
        _course(lessonId: 'L001'),
        _course(lessonId: 'L002', courseName: '线性代数'),
      ]);

      final result = await repo.getCourseById('L002');

      expect(result, hasLength(1));
      expect(result.first.courseName, '线性代数');
    });
  });

  group('CourseRepository.clear', () {
    test('should_remove_all_course_prefixed_keys', () async {
      await repo.saveCourses([
        _course(lessonId: 'L001'),
        _course(lessonId: 'L002', courseName: '线性代数'),
      ]);

      await repo.clear();

      final result = await repo.getCourses();
      expect(result, isEmpty);
    });

    test('should_also_remove_legacy_current_courses_key', () async {
      final box = await Hive.openBox(HiveManager.courseBoxName);
      await box.put('current_courses', [_course()]);

      await repo.clear();

      expect(box.containsKey('current_courses'), isFalse);
    });

    test('should_not_throw_when_box_is_already_empty', () async {
      await expectLater(repo.clear(), completes);
    });
  });
}
