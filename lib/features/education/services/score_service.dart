import 'dart:convert';

import 'package:ios_club_app/core/repositories/score_repository.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/features/education/models/semester_model.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

import 'auth_service.dart';
import '../models/edu_fetch_models.dart';
import '../apis/score_api.dart';

class ScoreService {
  static Future<void> getThisSemester({UserData? userData}) async {
    try {
      final response = await ScoreApi.getThisSemester(forceRefresh: false);
      final prefs = PrefsService.instance;
      await prefs.setString(
        PrefsKeys.THIS_SEMESTER_DATA,
        jsonEncode(response.toJson()),
      );
    } catch (e, stackTrace) {
      AppLogger.error('获取本学期成绩失败', error: e, stackTrace: stackTrace);
    }
  }

  static Future<void> getSemester({UserData? userData}) async {
    await fetchSemestersFromRemote(userData: userData);
  }

  static Future<List<SemesterModel>> fetchSemestersFromRemote({
    UserData? userData,
    bool forceRefresh = false,
  }) async {
    final cookieData = userData ?? await AuthService.getUserData();
    if (cookieData == null) {
      return [];
    }

    try {
      final response = await ScoreApi.getSemester(
        cookieData.studentId,
        forceRefresh: forceRefresh,
      );
      final prefs = PrefsService.instance;
      await prefs.setString(
        PrefsKeys.SEMESTER_DATA,
        jsonEncode(response.toJson()),
      );
      return response.data;
    } catch (e, stackTrace) {
      AppLogger.error('获取学期信息失败', error: e, stackTrace: stackTrace);
    }

    return [];
  }

  static Future<void> getAllScore({UserData? userData}) async {
    await fetchScoresFromRemote(userData: userData, forceRefresh: true);
  }

  static Future<List<ScoreList>> getAllScoreFromLocal({
    bool isRefresh = false,
  }) async {
    final snapshot = await getScores(
      policy: isRefresh ? FetchPolicy.refresh : FetchPolicy.localFirst,
    );
    return snapshot.data;
  }

  static Future<FetchSnapshot<List<ScoreList>>> getScores({
    FetchPolicy policy = FetchPolicy.localFirst,
  }) async {
    final scoreRepo = ScoreRepository();
    final localScores = await scoreRepo.getScores();

    switch (policy) {
      case FetchPolicy.localFirst:
        if (localScores.isNotEmpty) {
          return FetchSnapshot<List<ScoreList>>(
            data: sortScores(localScores),
            isFromLocal: true,
            isStale: false,
          );
        }
        return _refreshScores(fallbackScores: localScores);
      case FetchPolicy.refresh:
      case FetchPolicy.fallbackToLocal:
        return _refreshScores(fallbackScores: localScores);
    }
  }

  static Future<List<SemesterModel>> getSemesterList({
    bool isRefresh = false,
  }) async {
    final snapshot = await getSemesters(
      policy: isRefresh ? FetchPolicy.refresh : FetchPolicy.localFirst,
    );
    return snapshot.data;
  }

  static Future<FetchSnapshot<List<SemesterModel>>> getSemesters({
    FetchPolicy policy = FetchPolicy.localFirst,
  }) async {
    final localSemesters = readSemestersFromPrefs();

    switch (policy) {
      case FetchPolicy.localFirst:
        if (localSemesters.isNotEmpty) {
          return FetchSnapshot<List<SemesterModel>>(
            data: localSemesters,
            isFromLocal: true,
            isStale: false,
          );
        }
        return _refreshSemesters(fallbackSemesters: localSemesters);
      case FetchPolicy.refresh:
      case FetchPolicy.fallbackToLocal:
        return _refreshSemesters(fallbackSemesters: localSemesters);
    }
  }

  static Future<List<ScoreList>> fetchScoresFromRemote({
    UserData? userData,
    bool forceRefresh = false,
  }) async {
    final scoreRepo = ScoreRepository();
    final cachedScoresList = await scoreRepo.getScores();
    final cachedScores = {
      for (final score in cachedScoresList) score.semester.semester: score,
    };

    final cookieData = userData ?? await AuthService.getUserData();
    if (cookieData == null) {
      return sortScores(cachedScoresList);
    }

    var semesters = await fetchSemestersFromRemote(
      userData: cookieData,
      forceRefresh: forceRefresh,
    );
    if (semesters.isEmpty) {
      semesters = readSemestersFromPrefs();
    }
    if (semesters.isEmpty) {
      return sortScores(cachedScoresList);
    }

    final mergedScores = Map<String, ScoreList>.from(cachedScores);
    var fetchedAny = false;

    final results = await Future.wait(
      semesters.map((semester) async {
        try {
          final list = await ScoreApi.getScore(
            cookieData.studentId,
            semester.semester,
            forceRefresh: forceRefresh,
          );
          return MapEntry(semester, list);
        } catch (e, stackTrace) {
          AppLogger.error(
            '获取学期 ${semester.semester} 成绩失败',
            error: e,
            stackTrace: stackTrace,
          );
          return null;
        }
      }),
    );

    for (final result in results) {
      if (result == null) continue;
      mergedScores[result.key.semester] = ScoreList(
        semester: result.key,
        list: result.value,
      );
      fetchedAny = true;
    }

    final mergedScoresList = sortScores(mergedScores.values.toList());
    if (fetchedAny) {
      await scoreRepo.saveScores(mergedScoresList);
    }

    return mergedScoresList;
  }

  static List<SemesterModel> readSemestersFromPrefs() {
    final prefs = PrefsService.instance;
    final jsonString = prefs.getString(PrefsKeys.SEMESTER_DATA);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is! List) {
        return [];
      }

      return data
          .whereType<Map>()
          .map(
            (item) => SemesterModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('读取本地学期数据失败', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  static List<ScoreList> sortScores(List<ScoreList> scores) {
    scores.sort((a, b) => b.semester.semester.compareTo(a.semester.semester));
    return scores;
  }

  static Future<FetchSnapshot<List<ScoreList>>> _refreshScores({
    required List<ScoreList> fallbackScores,
  }) async {
    try {
      final scores = await fetchScoresFromRemote(forceRefresh: true);
      return FetchSnapshot<List<ScoreList>>(
        data: sortScores(scores),
        isFromLocal: false,
        isStale: false,
      );
    } catch (e) {
      AppLogger.debug('刷新成绩数据失败: $e');
      return FetchSnapshot<List<ScoreList>>(
        data: sortScores(fallbackScores),
        isFromLocal: true,
        isStale: fallbackScores.isNotEmpty,
      );
    }
  }

  static Future<FetchSnapshot<List<SemesterModel>>> _refreshSemesters({
    required List<SemesterModel> fallbackSemesters,
  }) async {
    try {
      final semesters = await fetchSemestersFromRemote(forceRefresh: true);
      return FetchSnapshot<List<SemesterModel>>(
        data: semesters,
        isFromLocal: false,
        isStale: false,
      );
    } catch (e) {
      AppLogger.debug('刷新学期数据失败: $e');
      return FetchSnapshot<List<SemesterModel>>(
        data: fallbackSemesters,
        isFromLocal: true,
        isStale: fallbackSemesters.isNotEmpty,
      );
    }
  }
}
