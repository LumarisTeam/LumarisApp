import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/features/education/models/semester_model.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_manager_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('HiveManager 单例', () {
    test('should_always_return_the_same_instance', () {
      final a = HiveManager.instance;
      final b = HiveManager.instance;
      expect(identical(a, b), isTrue);
    });

    test('should_expose_correct_box_name_constants', () {
      expect(HiveManager.requestCacheBoxName, 'request_cache');
      expect(HiveManager.courseBoxName, 'courses');
      expect(HiveManager.scoreBoxName, 'scores');
    });
  });

  group('HiveManager adapter 注册', () {
    // 在测试中手动注册 adapters（模拟 HiveManager.init() 的注册步骤，
    // 但使用 Hive.init() 而非 Hive.initFlutter()，避免依赖 Flutter 平台通道）

    void registerAdapters() {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CourseModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ScoreModelAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(ScoreListAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(SemesterModelAdapter());
      }
    }

    test('should_register_all_four_adapters', () {
      registerAdapters();

      expect(Hive.isAdapterRegistered(0), isTrue); // CourseModel
      expect(Hive.isAdapterRegistered(1), isTrue); // ScoreModel
      expect(Hive.isAdapterRegistered(2), isTrue); // ScoreList
      expect(Hive.isAdapterRegistered(3), isTrue); // SemesterModel
    });

    test('should_not_throw_when_registering_same_adapter_twice', () {
      registerAdapters();
      // 第二次注册相同 typeId 的 adapter 不应抛出异常
      expect(() => registerAdapters(), returnsNormally);
    });
  });

  group('HiveManager.openBox', () {
    setUp(() {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CourseModelAdapter());
      }
    });

    test('should_open_a_box_successfully', () async {
      final box = await HiveManager.instance
          .openBox<CourseModel>(HiveManager.courseBoxName);
      expect(box, isNotNull);
      expect(box.isOpen, isTrue);
    });

    test('should_return_same_box_instance_when_already_open', () async {
      final box1 = await HiveManager.instance
          .openBox<CourseModel>(HiveManager.courseBoxName);
      final box2 = await HiveManager.instance
          .openBox<CourseModel>(HiveManager.courseBoxName);
      expect(identical(box1, box2), isTrue);
    });

    test('should_open_dynamic_box_without_type_parameter', () async {
      final box =
          await HiveManager.instance.openBox(HiveManager.requestCacheBoxName);
      expect(box.isOpen, isTrue);
    });

    test('should_open_multiple_different_boxes', () async {
      final courseBox = await HiveManager.instance
          .openBox<CourseModel>(HiveManager.courseBoxName);
      final cacheBox =
          await HiveManager.instance.openBox(HiveManager.requestCacheBoxName);

      expect(courseBox.isOpen, isTrue);
      expect(cacheBox.isOpen, isTrue);
      expect(courseBox.name, HiveManager.courseBoxName);
      expect(cacheBox.name, HiveManager.requestCacheBoxName);
    });

    test('should_persist_data_written_to_box', () async {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CourseModelAdapter());
      }
      final box = await HiveManager.instance
          .openBox<CourseModel>(HiveManager.courseBoxName);
      final course = CourseModel(lessonId: 'T001', courseName: '测试课程');

      await box.put('T001', course);

      expect(box.get('T001')?.courseName, '测试课程');
    });
  });

  group('HiveManager.box', () {
    test('should_return_open_box_by_name', () async {
      await HiveManager.instance.openBox(HiveManager.requestCacheBoxName);

      final box = HiveManager.instance.box(HiveManager.requestCacheBoxName);
      expect(box.isOpen, isTrue);
    });

    test('should_throw_when_box_is_not_open', () {
      expect(
        () => HiveManager.instance.box('nonexistent_box'),
        throwsA(isA<HiveError>()),
      );
    });
  });

  group('HiveManager.closeAll', () {
    test('should_close_all_open_boxes', () async {
      final box1 =
          await HiveManager.instance.openBox(HiveManager.requestCacheBoxName);
      final box2 =
          await HiveManager.instance.openBox(HiveManager.courseBoxName);

      expect(box1.isOpen, isTrue);
      expect(box2.isOpen, isTrue);

      await HiveManager.instance.closeAll();

      expect(box1.isOpen, isFalse);
      expect(box2.isOpen, isFalse);
    });

    test('should_not_throw_when_no_boxes_are_open', () async {
      await expectLater(HiveManager.instance.closeAll(), completes);
    });
  });
}
