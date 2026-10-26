import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/features/education/models/semester_model.dart';

void _registerHiveAdapters() {
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_adapter_test_');
    Hive.init(tempDir.path);
    _registerHiveAdapters();
  });

  tearDown(() async {
    if (Hive.isBoxOpen('course_adapter_box')) {
      final box = Hive.box<CourseModel>('course_adapter_box');
      await box.clear();
      await box.close();
    }
    if (Hive.isBoxOpen('score_adapter_box')) {
      final box = Hive.box<ScoreList>('score_adapter_box');
      await box.clear();
      await box.close();
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('CourseModelAdapter should round-trip all fields', () async {
    final box = await Hive.openBox<CourseModel>('course_adapter_box');
    final original = CourseModel(
      weekIndexes: <int>[1, 2, 4, 6],
      teachers: <String>['Teacher A', 'Teacher B'],
      room: 'R101',
      courseName: 'Data Structure',
      courseCode: 'CS201',
      weekday: 3,
      startUnit: 5,
      endUnit: 6,
      credits: '3.5',
      lessonId: 'L-CS201-01',
      campus: 'Yanta',
      isCustom: true,
    );

    await box.put('k', original);
    final restored = box.get('k');

    expect(restored, isNotNull);
    expect(restored!.weekIndexes, original.weekIndexes);
    expect(restored.teachers, original.teachers);
    expect(restored.room, original.room);
    expect(restored.courseName, original.courseName);
    expect(restored.courseCode, original.courseCode);
    expect(restored.weekday, original.weekday);
    expect(restored.startUnit, original.startUnit);
    expect(restored.endUnit, original.endUnit);
    expect(restored.credits, original.credits);
    expect(restored.lessonId, original.lessonId);
    expect(restored.campus, original.campus);
    expect(restored.isCustom, isTrue);
  });

  test(
    'Score adapters should round-trip ScoreList and nested score values',
    () async {
      final box = await Hive.openBox<ScoreList>('score_adapter_box');
      final original = ScoreList(
        semester: SemesterModel(
          semester: '2025-2026-1',
          name: '2025-2026学年第一学期',
        ),
        list: <ScoreModel>[
          ScoreModel(
            name: '张三',
            lessonCode: 'CS101',
            lessonName: '程序设计',
            grade: '95',
            gpa: '4.0',
            gradeDetail: '优秀',
            credit: '4.0',
            isMinor: false,
          ),
        ],
      );

      await box.put('list', original);
      final restored = box.get('list');

      expect(restored, isNotNull);
      expect(restored!.semester.semester, original.semester.semester);
      expect(restored.semester.name, original.semester.name);
      expect(restored.list.length, 1);
      expect(restored.list.first.name, '张三');
      expect(restored.list.first.lessonCode, 'CS101');
      expect(restored.list.first.lessonName, '程序设计');
      expect(restored.list.first.grade, '95');
      expect(restored.list.first.gpa, '4.0');
      expect(restored.list.first.gradeDetail, '优秀');
      expect(restored.list.first.credit, '4.0');
      expect(restored.list.first.isMinor, isFalse);
    },
  );
}
