import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsStore', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await PrefsService.init();
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    SettingsStore store() => container.read(settingsStoreProvider.notifier);

    test('should load default values when prefs is empty', () async {
      final settingsStore = store();

      expect(settingsStore.isRemind, isFalse);
      expect(settingsStore.remindTime, 15);
      expect(settingsStore.isShowTomorrow, isFalse);
      expect(settingsStore.pageIndex, 0);
      expect(settingsStore.enableHapticFeedback, isFalse);
      expect(settingsStore.updateIgnored, isFalse);
      expect(settingsStore.fontFamily, '');
      expect(settingsStore.showCourseGrid, isFalse);
      expect(settingsStore.themeMode, ThemeMode.system);
      expect(settingsStore.scheduleBackground, '');
      expect(settingsStore.customBackgroundImage, '');
      expect(settingsStore.schoolId, School.defaultCode);
      expect(settingsStore.currentSchool?.code, School.defaultCode);
    });

    test('should load existing values from prefs', () async {
      final prefs = PrefsService.instance;
      await prefs.setBool(PrefsKeys.IS_REMIND, true);
      await prefs.setInt(PrefsKeys.NOTIFICATION_TIME, 30);
      await prefs.setBool(PrefsKeys.IS_SHOW_TOMORROW, true);
      await prefs.setInt(PrefsKeys.PAGE_DATA, 2);
      await prefs.setBool(PrefsKeys.ENABLE_HAPTIC_FEEDBACK, true);
      await prefs.setBool(PrefsKeys.UPDATE_IGNORED, true);
      await prefs.setString(PrefsKeys.FONT_FAMILY, 'PingFang SC');
      await prefs.setBool(PrefsKeys.SHOW_COURSE_GRID, true);
      await prefs.setString(PrefsKeys.THEME_MODE, 'dark');
      await prefs.setString(PrefsKeys.SCHEDULE_BACKGROUND, 'paper');
      await prefs.setString(PrefsKeys.CUSTOM_BACKGROUND_IMAGE, '/tmp/bg.jpg');
      await prefs.setString(PrefsKeys.SCHOOL_ID, 'xauat');

      container.dispose();
      container = ProviderContainer();
      addTearDown(container.dispose);
      final settingsStore = store();

      expect(settingsStore.isRemind, isTrue);
      expect(settingsStore.remindTime, 30);
      expect(settingsStore.isShowTomorrow, isTrue);
      expect(settingsStore.pageIndex, 2);
      expect(settingsStore.enableHapticFeedback, isTrue);
      expect(settingsStore.updateIgnored, isTrue);
      expect(settingsStore.fontFamily, 'PingFang SC');
      expect(settingsStore.showCourseGrid, isTrue);
      expect(settingsStore.themeMode, ThemeMode.dark);
      expect(settingsStore.scheduleBackground, 'paper');
      expect(settingsStore.customBackgroundImage, '/tmp/bg.jpg');
      expect(settingsStore.schoolId, 'xauat');
    });

    test('should update and persist common settings', () async {
      final settingsStore = store();

      await settingsStore.setIsRemind(true);
      await settingsStore.setRemindTime(45);
      await settingsStore.setIsShowTomorrow(true);
      await settingsStore.setPageIndex(1);
      await settingsStore.setEnableHapticFeedback(true);
      await settingsStore.setUpdateIgnored(true);
      await settingsStore.setFontFamily('Source Han Sans');
      await settingsStore.setShowCourseGrid(true);
      await settingsStore.setThemeMode(ThemeMode.light);
      await settingsStore.setScheduleBackground('wave');
      await settingsStore.setCustomBackgroundImage('/tmp/custom.png');

      final prefs = PrefsService.instance;
      expect(settingsStore.isRemind, isTrue);
      expect(settingsStore.remindTime, 45);
      expect(settingsStore.isShowTomorrow, isTrue);
      expect(settingsStore.pageIndex, 1);
      expect(settingsStore.enableHapticFeedback, isTrue);
      expect(settingsStore.updateIgnored, isTrue);
      expect(settingsStore.fontFamily, 'Source Han Sans');
      expect(settingsStore.showCourseGrid, isTrue);
      expect(settingsStore.themeMode, ThemeMode.light);
      expect(settingsStore.scheduleBackground, 'wave');
      expect(settingsStore.customBackgroundImage, '/tmp/custom.png');

      expect(prefs.getBool(PrefsKeys.IS_REMIND), isTrue);
      expect(prefs.getInt(PrefsKeys.NOTIFICATION_TIME), 45);
      expect(prefs.getBool(PrefsKeys.IS_SHOW_TOMORROW), isTrue);
      expect(prefs.getInt(PrefsKeys.PAGE_DATA), 1);
      expect(prefs.getBool(PrefsKeys.ENABLE_HAPTIC_FEEDBACK), isTrue);
      expect(prefs.getBool(PrefsKeys.UPDATE_IGNORED), isTrue);
      expect(prefs.getString(PrefsKeys.FONT_FAMILY), 'Source Han Sans');
      expect(prefs.getBool(PrefsKeys.SHOW_COURSE_GRID), isTrue);
      expect(prefs.getString(PrefsKeys.THEME_MODE), 'light');
      expect(prefs.getString(PrefsKeys.SCHEDULE_BACKGROUND), 'wave');
      expect(
        prefs.getString(PrefsKeys.CUSTOM_BACKGROUND_IMAGE),
        '/tmp/custom.png',
      );
    });

    test('should throw when setting invalid school id', () async {
      final settingsStore = store();

      await expectLater(
        settingsStore.setSchoolId('invalid-school'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should fallback currentSchool to default when school id is unknown',
        () async {
      await PrefsService.instance
          .setString(PrefsKeys.SCHOOL_ID, 'unknown-school');
      container.dispose();
      container = ProviderContainer();
      addTearDown(container.dispose);
      final settingsStore = store();

      expect(settingsStore.schoolId, 'unknown-school');
      expect(settingsStore.currentSchool?.code, School.defaultCode);
    });

    test('should fallback theme mode to system when prefs value is invalid',
        () async {
      await PrefsService.instance.setString(PrefsKeys.THEME_MODE, 'neon');
      container.dispose();
      container = ProviderContainer();
      addTearDown(container.dispose);

      final settingsStore = store();

      expect(settingsStore.themeMode, ThemeMode.system);
    });
  });
}
