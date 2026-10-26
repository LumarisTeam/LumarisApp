import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

/// 课表网格尺寸的默认值，以及从旧版本升级时的一次性重置。
///
/// 默认值同时体现在 `ScheduleState.height`（55）和 `ScheduleStyleState`
/// 的 `headerHeight` / `timeColumnWidth`（45/45）上；这里只负责清掉旧用户
/// 可能存过的尺寸 prefs，让两个 store 回退到新默认。
class ScheduleLayoutDefaults {
  const ScheduleLayoutDefaults._();

  static const int schema = 1;
  static const double gridHeight = 55;
  static const double timeColumnWidth = 45;
  static const double headerHeight = 45;

  /// 旧版本升级时清空三个尺寸键并写入 schema；之后不再重复。
  static Future<void> migrateIfNeeded() async {
    final prefs = PrefsService.instance;
    final current = prefs.getInt(PrefsKeys.SCHEDULE_LAYOUT_SCHEMA) ?? 0;
    if (current >= schema) return;

    await Future.wait([
      prefs.remove(PrefsKeys.COURSE_SIZE),
      prefs.remove(PrefsKeys.SCHEDULE_HEADER_HEIGHT),
      prefs.remove(PrefsKeys.SCHEDULE_TIME_COLUMN_WIDTH),
    ]);
    await prefs.setInt(PrefsKeys.SCHEDULE_LAYOUT_SCHEMA, schema);
  }
}
