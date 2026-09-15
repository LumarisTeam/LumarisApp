import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/system/notifications/notification_service.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/core/services/app_locale_service.dart';

import '../features/basic/models/school.dart';
import '../features/basic/services/school_api.dart';
import '../features/basic/services/school_config_cache.dart';
import '../features/education/services/edu_http_client_manager.dart';
import '../features/education/services/education_cache_service.dart';
import 'prefs_keys.dart';

final settingsStoreProvider =
    NotifierProvider<SettingsStore, SettingsState>(SettingsStore.new);

/// 学校列表 Provider：从 API 获取，失败时回退到本地 fallback
final schoolListProvider =
    AsyncNotifierProvider<SchoolListNotifier, List<School>>(
  SchoolListNotifier.new,
);

class SchoolListNotifier extends AsyncNotifier<List<School>> {
  @override
  Future<List<School>> build() async {
    try {
      final data = await SchoolApi.listSchools();
      final schools = data.items
          .where((s) => s.enabled && s.supports(Feature.login))
          .toList();
      return schools.isEmpty ? _localSchools() : schools;
    } catch (_) {
      return _localSchools();
    }
  }

  List<School> _localSchools() {
    final cachedSchool = SchoolConfigCache.read();
    if (cachedSchool == null ||
        !cachedSchool.enabled ||
        !cachedSchool.supports(Feature.login)) {
      return School.fallbackList;
    }

    return <School>[
      cachedSchool,
      ...School.fallbackList.where(
        (school) =>
            school.code.toUpperCase() != cachedSchool.code.toUpperCase(),
      ),
    ];
  }
}

/// HTML 课表导入用的学校列表。
///
/// 与 [schoolListProvider] 的关键区别是**不按 `Feature.login` 过滤**：HTML 导入是在
/// WebView 里自己登录教务系统，不依赖 App 侧的任何学校功能开关。复用前者会把
/// 「只开了课表、没开 App 内登录」的学校从列表里悄悄隐掉。
///
/// 只保留 `enabled` 的学校；接口失败时退回 `School.fallbackList`（导入页还允许
/// 手填自定义网址，所以退化成一项不会把用户堵死）。
final importSchoolListProvider = FutureProvider<List<School>>((ref) async {
  try {
    final data = await SchoolApi.listSchools();
    final schools = data.items.where((s) => s.enabled).toList();
    return schools.isEmpty ? School.fallbackList : schools;
  } catch (_) {
    return School.fallbackList;
  }
});

class SettingsStore extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final initialState = _readSettings();
    return initialState;
  }

  bool get isRemind => state.isRemind;
  int get remindTime => state.remindTime;
  bool get isShowTomorrow => state.isShowTomorrow;
  int get pageIndex => state.pageIndex;
  bool get enableHapticFeedback => state.enableHapticFeedback;
  bool get updateIgnored => state.updateIgnored;
  String get fontFamily => state.fontFamily;
  bool get showCourseGrid => state.showCourseGrid;
  bool get todoRemindEnabled => state.todoRemindEnabled;
  ThemeMode get themeMode => state.themeMode;
  String get scheduleBackground => state.scheduleBackground;
  String get customBackgroundImage => state.customBackgroundImage;
  bool? get customBackgroundIsDark => state.customBackgroundIsDark;
  String get schoolId => state.schoolId;
  bool get hasAcceptedAgreement => state.hasAcceptedAgreement;
  AppLocaleCode get localeCode => state.localeCode;
  Locale? get locale => AppLocaleService.localeOf(state.localeCode);

  School? get currentSchool {
    final cachedSchool = SchoolConfigCache.read();
    if (cachedSchool != null &&
        cachedSchool.code.toUpperCase() == state.schoolId.toUpperCase()) {
      return cachedSchool;
    }
    final schools =
        ref.read(schoolListProvider).valueOrNull ?? School.fallbackList;
    return School.findByCode(schools, state.schoolId) ??
        (schools.isNotEmpty ? schools.first : null);
  }

  SettingsState _readSettings() {
    final prefs = PrefsService.instance;

    return SettingsState(
      isRemind: prefs.getBool(PrefsKeys.IS_REMIND) ?? false,
      remindTime: prefs.getInt(PrefsKeys.NOTIFICATION_TIME) ?? 15,
      isShowTomorrow: prefs.getBool(PrefsKeys.IS_SHOW_TOMORROW) ?? false,
      pageIndex: prefs.getInt(PrefsKeys.PAGE_DATA) ?? 0,
      enableHapticFeedback:
          prefs.getBool(PrefsKeys.ENABLE_HAPTIC_FEEDBACK) ?? false,
      updateIgnored: prefs.getBool(PrefsKeys.UPDATE_IGNORED) ?? false,
      fontFamily: prefs.getString(PrefsKeys.FONT_FAMILY) ?? '',
      showCourseGrid: prefs.getBool(PrefsKeys.SHOW_COURSE_GRID) ?? false,
      todoRemindEnabled: prefs.getBool(PrefsKeys.TODO_REMIND_ENABLED) ?? false,
      themeMode: ClubThemeModeCodec.fromPreference(
        prefs.getString(PrefsKeys.THEME_MODE),
      ),
      localeCode: AppLocaleService.fromPreference(
        prefs.getString(PrefsKeys.LOCALE_CODE),
      ),
      scheduleBackground: prefs.getString(PrefsKeys.SCHEDULE_BACKGROUND) ?? '',
      customBackgroundImage:
          prefs.getString(PrefsKeys.CUSTOM_BACKGROUND_IMAGE) ?? '',
      customBackgroundIsDark:
          prefs.getBool(PrefsKeys.CUSTOM_BACKGROUND_IS_DARK),
      schoolId: prefs.getString(PrefsKeys.SCHOOL_ID) ?? School.defaultCode,
      hasAcceptedAgreement:
          prefs.getBool(PrefsKeys.AGREEMENT_ACCEPTED) ?? false,
    );
  }

  Future<void> reload() async {
    state = _readSettings();
  }

  Future<void> setIsRemind(bool value) async {
    state = state.copyWith(isRemind: value);
    await PrefsService.instance.setBool(PrefsKeys.IS_REMIND, value);

    // 如果关闭提醒，尝试清除所有已排期的通知以释放系统资源
    if (!value) {
      try {
        await NotificationService.instance.cancelAllNotifications();
      } catch (e) {
        // 忽略错误
      }
    }
  }

  Future<void> setRemindTime(int value) async {
    state = state.copyWith(remindTime: value);
    await PrefsService.instance.setInt(PrefsKeys.NOTIFICATION_TIME, value);
  }

  Future<void> setIsShowTomorrow(bool value) async {
    state = state.copyWith(isShowTomorrow: value);
    await PrefsService.instance.setBool(PrefsKeys.IS_SHOW_TOMORROW, value);
  }

  Future<void> setPageIndex(int value) async {
    state = state.copyWith(pageIndex: value);
    await PrefsService.instance.setInt(PrefsKeys.PAGE_DATA, value);
  }

  Future<void> setEnableHapticFeedback(bool value) async {
    state = state.copyWith(enableHapticFeedback: value);
    await PrefsService.instance
        .setBool(PrefsKeys.ENABLE_HAPTIC_FEEDBACK, value);
  }

  Future<void> setUpdateIgnored(bool value) async {
    state = state.copyWith(updateIgnored: value);
    await PrefsService.instance.setBool(PrefsKeys.UPDATE_IGNORED, value);
  }

  Future<void> setFontFamily(String value) async {
    state = state.copyWith(fontFamily: value);
    await PrefsService.instance.setString(PrefsKeys.FONT_FAMILY, value);
  }

  Future<void> setShowCourseGrid(bool value) async {
    state = state.copyWith(showCourseGrid: value);
    await PrefsService.instance.setBool(PrefsKeys.SHOW_COURSE_GRID, value);
  }

  Future<void> setTodoRemindEnabled(bool value) async {
    state = state.copyWith(todoRemindEnabled: value);
    await PrefsService.instance.setBool(PrefsKeys.TODO_REMIND_ENABLED, value);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    state = state.copyWith(themeMode: value);
    await PrefsService.instance.setString(
      PrefsKeys.THEME_MODE,
      ClubThemeModeCodec.toPreference(value),
    );
  }

  Future<void> setLocaleCode(AppLocaleCode value) async {
    state = state.copyWith(localeCode: value);
    await PrefsService.instance.setString(
      PrefsKeys.LOCALE_CODE,
      AppLocaleService.toPreference(value),
    );
  }

  Future<void> setScheduleBackground(String value) async {
    state = state.copyWith(scheduleBackground: value);
    await PrefsService.instance.setString(PrefsKeys.SCHEDULE_BACKGROUND, value);
  }

  Future<void> setCustomBackgroundImage(String value) async {
    state = state.copyWith(customBackgroundImage: value);
    await PrefsService.instance
        .setString(PrefsKeys.CUSTOM_BACKGROUND_IMAGE, value);
  }

  Future<void> setCustomBackgroundIsDark(bool? value) async {
    state = state.copyWith(customBackgroundIsDark: value);
    final prefs = PrefsService.instance;
    if (value == null) {
      await prefs.remove(PrefsKeys.CUSTOM_BACKGROUND_IS_DARK);
    } else {
      await prefs.setBool(PrefsKeys.CUSTOM_BACKGROUND_IS_DARK, value);
    }
  }

  Future<void> setSchoolId(String schoolId) async {
    final schools =
        ref.read(schoolListProvider).valueOrNull ?? School.fallbackList;
    final school = School.findByCode(schools, schoolId);
    if (school == null) {
      throw ArgumentError('Invalid school code: $schoolId');
    }

    await selectSchool(school);
  }

  /// Applies a school before authentication so every education request uses
  /// the selected school's API endpoint. Existing education data is cleared
  /// only when the school actually changes.
  Future<void> selectSchool(School school) async {
    if (!school.enabled || !school.supports(Feature.login)) {
      throw ArgumentError('School does not support login: ${school.code}');
    }

    final normalizedCode = school.code.toUpperCase();
    final schoolChanged = state.schoolId.toUpperCase() != normalizedCode;
    if (schoolChanged) {
      await EducationCacheService.clearEduCache();
    }

    state = state.copyWith(schoolId: normalizedCode);
    await PrefsService.instance.setString(
      PrefsKeys.SCHOOL_ID,
      normalizedCode,
    );
    await SchoolConfigCache.save(school);

    EduHttpClientManager.current.updateSchoolConfig(school);
  }

  /// Clears the previous education session and applies [school] before login.
  Future<void> prepareSchoolForLogin(School school) async {
    await EducationCacheService.clearEduCache();
    await selectSchool(school);
  }

  Future<void> setHasAcceptedAgreement(bool value) async {
    state = state.copyWith(hasAcceptedAgreement: value);
    await PrefsService.instance.setBool(PrefsKeys.AGREEMENT_ACCEPTED, value);
  }
}
