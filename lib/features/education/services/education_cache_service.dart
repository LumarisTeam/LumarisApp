import 'package:ios_club_app/core/repositories/course_repository.dart';
import 'package:ios_club_app/core/repositories/score_repository.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

class EducationCacheService {
  static Future<void> clearEduCache() async {
    try {
      final prefs = PrefsService.instance;

      AppLogger.debug('[EducationCacheService] 开始清理教务系统缓存');

      final eduKeys = [
        PrefsKeys.USER_DATA,
        PrefsKeys.LAST_FETCH_TIME,
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

      for (final key in eduKeys) {
        await prefs.remove(key);
      }

      await CourseRepository().clear();
      await ScoreRepository().clear();

      await RequestCache().deleteByPattern(RegExp(r'.*/course.*'));
      await RequestCache().deleteByPattern(RegExp(r'.*/score.*'));
      await RequestCache().deleteByPattern(RegExp(r'.*/exam.*'));
      await RequestCache().deleteByPattern(RegExp(r'.*/semester.*'));
      await RequestCache().deleteByPattern(RegExp(r'.*/program.*'));
      await RequestCache().deleteByPattern(RegExp(r'.*/info.*'));
      await RequestCache().deleteByPattern(RegExp(r'.*/time.*'));
    } catch (e, stackTrace) {
      AppLogger.error('清理教务系统缓存失败', error: e, stackTrace: stackTrace);
    }
  }
}
