import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/features/education/models/semester_model.dart';
import 'package:ios_club_app/core/repositories/score_repository.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

SemesterModel _semester({
  String semester = '2024-2025-1',
  String name = '2024-2025学年第一学期',
}) => SemesterModel(semester: semester, name: name);

ScoreModel _score({
  String lessonCode = 'CS001',
  String lessonName = '数据结构',
  String grade = '90',
  String gpa = '4.0',
  String credit = '3.0',
  bool isMinor = false,
}) => ScoreModel(
  lessonCode: lessonCode,
  lessonName: lessonName,
  grade: grade,
  gpa: gpa,
  credit: credit,
  isMinor: isMinor,
);

ScoreList _scoreList({
  String semester = '2024-2025-1',
  List<ScoreModel>? scores,
}) => ScoreList(
  semester: _semester(semester: semester),
  list: scores ?? [_score()],
);

void main() {
  late Directory tempDir;
  late ScoreRepository repo;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('score_repo_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ScoreModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ScoreListAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SemesterModelAdapter());
    }
    repo = ScoreRepository();
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('ScoreRepository.saveScores', () {
    test('should_store_scores_under_all_scores_key', () async {
      await repo.saveScores([_scoreList()]);

      final box = await Hive.openBox(HiveManager.scoreBoxName);
      expect(box.containsKey('all_scores'), isTrue);
    });

    test('should_replace_all_scores_on_second_call', () async {
      await repo.saveScores([
        _scoreList(semester: '2023-2024-1'),
        _scoreList(semester: '2023-2024-2'),
      ]);
      await repo.saveScores([_scoreList(semester: '2024-2025-1')]);

      final result = await repo.getScores();
      expect(result, hasLength(1));
      expect(result.first.semester.semester, '2024-2025-1');
    });

    test('should_clear_existing_scores_when_saving_empty_list', () async {
      await repo.saveScores([_scoreList()]);
      await repo.saveScores([]);

      final result = await repo.getScores();
      expect(result, isEmpty);
    });

    test('should_save_multiple_semesters', () async {
      await repo.saveScores([
        _scoreList(semester: '2023-2024-1'),
        _scoreList(semester: '2023-2024-2'),
        _scoreList(semester: '2024-2025-1'),
      ]);

      final result = await repo.getScores();
      expect(result, hasLength(3));
    });
  });

  group('ScoreRepository.getScores', () {
    test('should_return_empty_list_when_box_is_empty', () async {
      final result = await repo.getScores();
      expect(result, isEmpty);
    });

    test('should_return_all_saved_score_lists', () async {
      await repo.saveScores([
        _scoreList(semester: '2023-2024-1'),
        _scoreList(semester: '2023-2024-2'),
      ]);

      final result = await repo.getScores();

      expect(result, hasLength(2));
      final semesters = result.map((s) => s.semester.semester).toSet();
      expect(semesters, containsAll(['2023-2024-1', '2023-2024-2']));
    });

    test('should_preserve_score_fields_after_round_trip', () async {
      final original = ScoreList(
        semester: SemesterModel(
          semester: '2024-2025-1',
          name: '2024-2025学年第一学期',
        ),
        list: [
          ScoreModel(
            lessonCode: 'CS001',
            lessonName: '数据结构',
            grade: '95',
            gpa: '4.5',
            credit: '4.0',
            isMinor: false,
          ),
          ScoreModel(
            lessonCode: 'MINOR001',
            lessonName: '辅修课程',
            grade: '85',
            gpa: '3.7',
            credit: '2.0',
            isMinor: true,
          ),
        ],
      );
      await repo.saveScores([original]);

      final result = await repo.getScores();

      expect(result, hasLength(1));
      final sl = result.first;
      expect(sl.semester.semester, '2024-2025-1');
      expect(sl.semester.name, '2024-2025学年第一学期');
      expect(sl.list, hasLength(2));
      expect(sl.list.first.lessonCode, 'CS001');
      expect(sl.list.first.grade, '95');
      expect(sl.list.first.gpa, '4.5');
      expect(sl.list.first.credit, '4.0');
      expect(sl.list.first.isMinor, isFalse);
      expect(sl.list.last.isMinor, isTrue);
    });

    test('should_migrate_from_shared_preferences_when_hive_is_empty', () async {
      final jsonData = jsonEncode([
        _scoreList(semester: 'SP-2023-2024-1').toJson(),
      ]);
      // ignore: deprecated_member_use
      await PrefsService.instance.setString(PrefsKeys.ALL_SCORE_DATA, jsonData);

      final result = await repo.getScores();

      expect(result, hasLength(1));
      expect(result.first.semester.semester, 'SP-2023-2024-1');

      // 清理，避免影响其他测试
      // ignore: deprecated_member_use
      await PrefsService.instance.remove(PrefsKeys.ALL_SCORE_DATA);
    });

    test(
      'should_return_empty_list_when_prefs_migration_data_is_corrupt',
      () async {
        await PrefsService.instance.setString(
          'all_score_data',
          'not-valid-json',
        );

        final result = await repo.getScores();
        expect(result, isEmpty);

        await PrefsService.instance.remove('all_score_data');
      },
    );
  });

  group('ScoreRepository.clear', () {
    test('should_remove_all_scores_key', () async {
      await repo.saveScores([_scoreList()]);

      await repo.clear();

      final box = await Hive.openBox(HiveManager.scoreBoxName);
      expect(box.containsKey('all_scores'), isFalse);
    });

    test('should_return_empty_list_after_clear', () async {
      await repo.saveScores([
        _scoreList(),
        _scoreList(semester: '2023-2024-2'),
      ]);

      await repo.clear();

      final result = await repo.getScores();
      expect(result, isEmpty);
    });

    test('should_not_throw_when_box_is_already_empty', () async {
      await expectLater(repo.clear(), completes);
    });
  });
}
