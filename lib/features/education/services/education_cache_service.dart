import 'package:ios_club_app/core/repositories/course_repository.dart';
import 'package:ios_club_app/core/repositories/score_repository.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/features/education/services/auth_session_guard.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

class EducationCacheService {
  /// 登录态相关 key：仅在 [clearSession] 为 true 时删除。
  static const List<String> _sessionPrefsKeys = [
    PrefsKeys.USER_DATA,
    PrefsKeys.LAST_FETCH_TIME,
  ];

  static const List<String> _eduDataPrefsKeys = [
    PrefsKeys.COURSE_DATA,
    PrefsKeys.IGNORE_DATA,
    PrefsKeys.COURSE_LAST_FETCH_TIME,
    PrefsKeys.SEMESTER_DATA,
    PrefsKeys.SEMESTER_TIME,
    PrefsKeys.ALL_SCORE_DATA,
    PrefsKeys.LAST_SCORE_TIME,
    PrefsKeys.THIS_SEMESTER_DATA,
    PrefsKeys.EXAM_DATA,
    PrefsKeys.EXAM_TIME,
    PrefsKeys.TIME_DATA,
    PrefsKeys.TIME_LAST_UPDATED,
    PrefsKeys.INFO_DATA,
    PrefsKeys.INFO_DATA_TIME,
    '${PrefsKeys.ALL_SCORE_DATA}_TIMESTAMPS',
  ];

  static const List<String> _requestCachePatterns = [
    r'.*/course.*',
    r'.*/score.*',
    r'.*/exam.*',
    r'.*/semester.*',
    r'.*/program.*',
    r'.*/info.*',
    r'.*/time.*',
  ];

  /// 清理教务系统缓存。
  ///
  /// [clearSession] 为 true 时同时删除登录态（登出、换学校、登录前清场）；
  /// 设置页的"清除缓存"传 false，只清数据、保留登录。
  static Future<void> clearEduCache({bool clearSession = true}) async {
    // 只有连同会话一起清空时才作废在途登录。
    if (clearSession) {
      AuthSessionGuard.invalidate();
    }

    AppLogger.debug('[EducationCacheService] 开始清理教务系统缓存');

    final prefsKeys = clearSession
        ? [..._sessionPrefsKeys, ..._eduDataPrefsKeys]
        : _eduDataPrefsKeys;

    // 每一步独立容错：某一步失败不能阻止后续缓存被清理。
    await _runStep('清理 SharedPreferences', () async {
      final prefs = PrefsService.instance;
      for (final key in prefsKeys) {
        await prefs.remove(key);
      }
    });

    await _runStep('清理课程仓库', () => CourseRepository().clear());
    await _runStep('清理成绩仓库', () => ScoreRepository().clear());

    for (final pattern in _requestCachePatterns) {
      await _runStep(
        '清理请求缓存 $pattern',
        () => RequestCache().deleteByPattern(RegExp(pattern)),
      );
    }
  }

  static Future<void> _runStep(
    String label,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e, stackTrace) {
      AppLogger.error('清理教务系统缓存失败: $label', error: e, stackTrace: stackTrace);
    }
  }
}
