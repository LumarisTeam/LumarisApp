import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/schedule_layout_defaults.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
  });

  test('should reset old layout prefs once', () async {
    final prefs = PrefsService.instance;
    await prefs.setDouble(PrefsKeys.COURSE_SIZE, 60);
    await prefs.setDouble(PrefsKeys.SCHEDULE_HEADER_HEIGHT, 60);
    await prefs.setDouble(PrefsKeys.SCHEDULE_TIME_COLUMN_WIDTH, 56);

    await ScheduleLayoutDefaults.migrateIfNeeded();

    expect(prefs.getDouble(PrefsKeys.COURSE_SIZE), isNull);
    expect(prefs.getDouble(PrefsKeys.SCHEDULE_HEADER_HEIGHT), isNull);
    expect(prefs.getDouble(PrefsKeys.SCHEDULE_TIME_COLUMN_WIDTH), isNull);
    expect(
      prefs.getInt(PrefsKeys.SCHEDULE_LAYOUT_SCHEMA),
      ScheduleLayoutDefaults.schema,
    );
    expect(ScheduleLayoutDefaults.gridHeight, 55);
    expect(ScheduleLayoutDefaults.timeColumnWidth, 45);
    expect(ScheduleLayoutDefaults.headerHeight, 45);
  });

  test('should not reset values once schema is current', () async {
    final prefs = PrefsService.instance;
    await prefs.setInt(
      PrefsKeys.SCHEDULE_LAYOUT_SCHEMA,
      ScheduleLayoutDefaults.schema,
    );
    await prefs.setDouble(PrefsKeys.COURSE_SIZE, 70);
    await prefs.setDouble(PrefsKeys.SCHEDULE_HEADER_HEIGHT, 70);
    await prefs.setDouble(PrefsKeys.SCHEDULE_TIME_COLUMN_WIDTH, 70);

    await ScheduleLayoutDefaults.migrateIfNeeded();

    expect(prefs.getDouble(PrefsKeys.COURSE_SIZE), 70);
    expect(prefs.getDouble(PrefsKeys.SCHEDULE_HEADER_HEIGHT), 70);
    expect(prefs.getDouble(PrefsKeys.SCHEDULE_TIME_COLUMN_WIDTH), 70);
  });
}
