import 'dart:convert';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 成绩数据仓库
class ScoreRepository {
  static const String _boxName = HiveManager.scoreBoxName;

  /// 保存成绩列表
  ///
  /// 这里的 ScoreList 包含了成绩列表和学期信息。
  /// 我们将每个学期的成绩作为一个条目存储，Key 可以是学期名。
  ///
  /// @param scores 成绩列表数据
  Future<void> saveScores(List<ScoreList> scores) async {
    try {
      final box = await HiveManager.instance.openBox(_boxName);
      await box.put('all_scores', scores);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save scores to Hive',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 获取成绩列表
  Future<List<ScoreList>> getScores() async {
    try {
      final box = await HiveManager.instance.openBox(HiveManager.scoreBoxName);

      // 尝试从 Hive 读取
      final dynamic data = box.get('all_scores');

      if (data != null) {
        if (data is List) {
          return data.cast<ScoreList>();
        }
      }

      // 如果 Hive 中没有，尝试从 SharedPreferences 迁移
      return await _migrateFromPrefs();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get scores from Hive',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// 从 SharedPreferences 迁移数据
  Future<List<ScoreList>> _migrateFromPrefs() async {
    final prefs = PrefsService.instance;
    // ignore: deprecated_member_use
    final jsonString = prefs.getString(PrefsKeys.ALL_SCORE_DATA);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        AppLogger.info(
          'Migrating score data from SharedPreferences to Hive...',
        );
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final scores = <ScoreList>[];
        for (final e in jsonList) {
          try {
            scores.add(ScoreList.fromJson(e as Map<String, dynamic>));
          } catch (itemErr) {
            AppLogger.warning(
              'Skipping corrupt score entry during migration',
              error: itemErr,
            );
          }
        }

        // 保存到 Hive
        await saveScores(scores);

        // 删除旧数据
        // await prefs.remove(PrefsKeys.ALL_SCORE_DATA);

        AppLogger.info(
          'Score data migration completed. Count: ${scores.length}',
        );
        return scores;
      } catch (e) {
        AppLogger.warning('Failed to migrate score data', error: e);
      }
    }
    return [];
  }

  /// 清除成绩数据
  Future<void> clear() async {
    final box = await HiveManager.instance.openBox(HiveManager.scoreBoxName);
    await box.delete('all_scores');
  }
}
