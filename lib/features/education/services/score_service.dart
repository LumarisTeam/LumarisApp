import 'dart:convert';

import '../../../core/repositories/score_repository.dart';
import '../../../core/services/network_exception.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../state/prefs_keys.dart';
import '../apis/score_api.dart';
import '../models/edu_fetch_models.dart';
import '../models/score_model.dart';
import '../models/semester_model.dart';
import '../models/user_data.dart';
import 'auth_service.dart';
import 'auth_session_guard.dart';

class ScoreService {
  static final Map<(int, String), Future<List<ScoreList>>> _scoreRequests = {};
  static const Set<int> _stopRefreshStatuses = {401, 403, 429};

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
    final int epoch = AuthSessionGuard.epoch;
    final cookieData = userData ?? await AuthService.getUserData();
    if (cookieData == null || !AuthSessionGuard.isCurrent(epoch)) {
      return [];
    }

    try {
      final response = await ScoreApi.getSemester(
        cookieData.studentId,
        forceRefresh: forceRefresh,
      );
      if (!AuthSessionGuard.isCurrent(epoch)) return [];
      final prefs = PrefsService.instance;
      await prefs.setString(
        PrefsKeys.SEMESTER_DATA,
        jsonEncode(response.toJson()),
      );
      return response.data;
    } catch (e, stackTrace) {
      AppLogger.error('获取学期信息失败', error: e, stackTrace: stackTrace);
      if (e is NetworkException &&
          _stopRefreshStatuses.contains(e.statusCode)) {
        rethrow;
      }
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
        return _refreshScores(fallbackScores: localScores, forceRefresh: false);
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
    final int epoch = AuthSessionGuard.epoch;
    final UserData? session = userData ?? await AuthService.getUserData();
    if (!AuthSessionGuard.isCurrent(epoch)) return [];
    if (session == null) {
      return sortScores(await ScoreRepository().getScores());
    }

    final key = (epoch, session.studentId);
    final existing = _scoreRequests[key];
    if (existing != null) return existing;

    final request = _fetchScores(session, epoch, forceRefresh: forceRefresh);
    _scoreRequests[key] = request;
    try {
      return await request;
    } finally {
      _scoreRequests.remove(key);
    }
  }

  static Future<List<ScoreList>> _fetchScores(
    UserData session,
    int epoch, {
    required bool forceRefresh,
  }) async {
    final scoreRepo = ScoreRepository();
    final cachedScoresList = await scoreRepo.getScores();
    if (!AuthSessionGuard.isCurrent(epoch)) return [];
    final mergedScores = {
      for (final score in cachedScoresList) score.semester.semester: score,
    };

    var semesters = await fetchSemestersFromRemote(
      userData: session,
      forceRefresh: forceRefresh,
    );
    if (semesters.isEmpty) {
      semesters = readSemestersFromPrefs();
    }
    if (semesters.isEmpty) {
      return sortScores(cachedScoresList);
    }

    var fetchedAny = false;
    final orderedSemesters = {
      for (final semester in semesters) semester.semester: semester,
    }.values.toList()..sort((a, b) => b.semester.compareTo(a.semester));
    NetworkException? stoppedError;
    for (final semester in orderedSemesters) {
      if (!AuthSessionGuard.isCurrent(epoch)) return [];
      try {
        final list = await ScoreApi.getScore(
          session.studentId,
          semester.semester,
          forceRefresh: forceRefresh,
        );
        mergedScores[semester.semester] = ScoreList(
          semester: semester,
          list: list,
        );
        fetchedAny = true;
      } catch (e, stackTrace) {
        AppLogger.error(
          '获取学期 ${semester.semester} 成绩失败',
          error: e,
          stackTrace: stackTrace,
        );
        if (e is NetworkException &&
            _stopRefreshStatuses.contains(e.statusCode)) {
          stoppedError = e;
          break;
        }
      }
    }

    if (!AuthSessionGuard.isCurrent(epoch)) return [];
    final mergedScoresList = sortScores(mergedScores.values.toList());
    if (fetchedAny) {
      await scoreRepo.saveScores(mergedScoresList);
    }
    if (stoppedError != null) throw stoppedError;

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
    bool forceRefresh = true,
  }) async {
    try {
      final scores = await fetchScoresFromRemote(forceRefresh: forceRefresh);
      return FetchSnapshot<List<ScoreList>>(
        data: sortScores(scores),
        isFromLocal: false,
        isStale: false,
      );
    } catch (e) {
      AppLogger.debug('刷新成绩数据失败: $e');
      if (e is NetworkException &&
          _stopRefreshStatuses.contains(e.statusCode)) {
        final scores = await ScoreRepository().getScores();
        if (scores.isEmpty) rethrow;
        return FetchSnapshot<List<ScoreList>>(
          data: sortScores(scores),
          isFromLocal: true,
          isStale: true,
        );
      }
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
