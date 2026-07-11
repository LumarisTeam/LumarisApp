import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

import 'auth_service.dart';
import 'course_service.dart';
import 'edu_time_service.dart';
import 'education_cache_service.dart';
import 'exam_service.dart';
import 'info_service.dart';
import 'score_service.dart';

typedef CourseRefreshCallback = Future<void> Function();

class EducationRefreshService {
  static CourseRefreshCallback? _courseRefreshCallback;

  static void setCourseRefreshCallback(CourseRefreshCallback? callback) {
    _courseRefreshCallback = callback;
  }

  static void resetForTest() {
    _courseRefreshCallback = null;
  }

  static Future<bool> loginAndRefresh(String username, String password) async {
    await EducationCacheService.clearEduCache();
    await PrefsService.instance.remove(PrefsKeys.GUEST_COURSE_DATA);
    final loginResult = await AuthService.loginFromData(username, password);
    if (!loginResult) {
      return false;
    }
    return refreshWithExistingSession(isForced: true);
  }

  static Future<bool> refresh() async {
    try {
      final loginResult = await AuthService.login();
      if (!loginResult) {
        return false;
      }
      return refreshWithExistingSession(isForced: true);
    } catch (e, stackTrace) {
      AppLogger.error('刷新数据失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  static Future<bool> refreshWithExistingSession({bool isForced = true}) async {
    try {
      final cookieData = await AuthService.getUserData();
      if (cookieData == null) {
        return false;
      }

      await EduTimeService.fetchTimeInfoFromRemote(forceRefresh: true);

      if (isForced) {
        await Future.wait([
          ScoreService.fetchSemestersFromRemote(
            userData: cookieData,
            forceRefresh: true,
          ),
          ExamService.getExam(userData: cookieData, forceRefresh: true),
          InfoService.getInfoCompletion(
            userData: cookieData,
            forceRefresh: true,
          ),
          CourseService.getCourse(userData: cookieData, isRefresh: true)
        ]);
      }

      final callback = _courseRefreshCallback;
      if (callback != null) {
        await callback();
      }
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('刷新数据失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
