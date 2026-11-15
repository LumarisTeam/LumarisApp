import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/models/login_mode.dart';
import 'package:ios_club_app/features/education/services/schedule_time_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

import 'auth_service.dart';
import 'auth_session_guard.dart';
import 'course_service.dart';
import 'edu_time_service.dart';
import 'education_cache_service.dart';
import 'exam_service.dart';
import 'info_service.dart';
import 'login_mode_service.dart';
import 'score_service.dart';

typedef CourseRefreshCallback = Future<void> Function();

class EducationRefreshService {
  static CourseRefreshCallback? _courseRefreshCallback;
  static final Map<int, Future<bool>> _refreshes = {};

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
    // 登录成功后必须强制刷新一次，确保课程、成绩、考试等数据已预加载。
    return refreshWithExistingSession(isForced: true);
  }

  static Future<bool> refresh() async {
    final int epoch = AuthSessionGuard.epoch;
    final existing = _refreshes[epoch];
    if (existing != null) return existing;

    final refresh = refreshWithExistingSession(isForced: true);
    _refreshes[epoch] = refresh;
    try {
      return await refresh;
    } finally {
      _refreshes.remove(epoch);
    }
  }

  static Future<bool> refreshWithExistingSession({
    bool isForced = false,
  }) async {
    final int epoch = AuthSessionGuard.epoch;
    try {
      final cookieData = await AuthService.getUserData();
      if (cookieData == null || !AuthSessionGuard.isCurrent(epoch)) {
        return false;
      }

      await EduTimeService.fetchTimeInfoFromRemote(forceRefresh: true);
      await ScheduleTimeService.fetchFromRemote(forceRefresh: true);
      if (!AuthSessionGuard.isCurrent(epoch)) return false;

      if (isForced) {
        if (LoginModeService.current == LoginMode.graduate) {
          // 研究生系统目前只提供登录与课表。成绩、考试、学业进度仍会打到
          // 本科生接口，拿 gmis 的 cookie 只会得到 401（还会触发一次无谓的
          // 重登录），因此这里只预加载课表。
          await CourseService.getCourse(userData: cookieData, isRefresh: true);
        } else {
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
            CourseService.getCourse(userData: cookieData, isRefresh: true),
          ]);
        }
      }

      final callback = _courseRefreshCallback;
      if (!AuthSessionGuard.isCurrent(epoch)) return false;
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
