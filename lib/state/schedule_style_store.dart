import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/schedule_color_themes.dart';

final scheduleStyleStoreProvider =
    NotifierProvider<ScheduleStyleStore, ScheduleStyleState>(
      ScheduleStyleStore.new,
    );

/// 课表个性化样式设置。
///
/// 壁纸、网格线开关、格子高度不属于本 store，分别由 SettingsStore 和
/// ScheduleStore 管理；个性化页负责协调三者。
class ScheduleStyleStore extends Notifier<ScheduleStyleState> {
  static const double minHeaderHeight = 30;
  static const double maxHeaderHeight = 80;
  static const double minTimeColumnWidth = 20;
  static const double maxTimeColumnWidth = 80;
  static const double minFontScale = 0.5;
  static const double maxFontScale = 2.0;
  static const double minCornerRadius = 0;
  static const double maxCornerRadius = 24;
  static const double minInnerPadding = 0;
  static const double maxInnerPadding = 12;
  static const double minOuterPadding = 0;
  static const double maxOuterPadding = 8;
  static const double minOpacity = 0.1;
  static const double maxOpacity = 1.0;

  static const int minThemeColorCount = 1;
  static const int maxThemeColorCount = ScheduleColorThemeCatalog.maxColors;
  static const int maxThemeNameLength = ScheduleColorThemeCatalog.maxNameLength;

  /// 颜色池默认值版本。旧版本（无 key 或小于该值）升级时把两个池的
  /// 活动主题一次性重置为 Macchiato；自定义主题定义保留。
  static const int colorPoolSchema = 3;

  @override
  ScheduleStyleState build() {
    final loaded = _readStyle();
    final schema =
        PrefsService.instance.getInt(PrefsKeys.SCHEDULE_COLOR_POOL_SCHEMA) ?? 0;
    if (schema < colorPoolSchema) {
      Future<void>.microtask(_migrateColorPools);
    }
    return loaded;
  }

  ScheduleStyleState _readStyle() {
    final prefs = PrefsService.instance;
    final schema = prefs.getInt(PrefsKeys.SCHEDULE_COLOR_POOL_SCHEMA) ?? 0;
    final useDefaultThemes = schema < colorPoolSchema;

    // 自定义主题定义始终解码，schema 升级只重置活动主题。
    final customThemes = _decodeCustomColorThemes(
      prefs.getString(PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES),
    );

    final lightThemeId = useDefaultThemes
        ? scheduleDefaultLightThemeId
        : _resolveStoredThemeId(
            prefs.getString(PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID),
            customThemes,
          );

    final darkThemeId = useDefaultThemes
        ? scheduleDefaultDarkThemeId
        : _resolveStoredThemeId(
            prefs.getString(PrefsKeys.SCHEDULE_DARK_COLOR_POOL_THEME_ID),
            customThemes,
          );

    return ScheduleStyleState(
      headerHeight: _clamp(
        prefs.getDouble(PrefsKeys.SCHEDULE_HEADER_HEIGHT) ?? 45,
        minHeaderHeight,
        maxHeaderHeight,
      ),
      hideSectionTime:
          prefs.getBool(PrefsKeys.SCHEDULE_HIDE_SECTION_TIME) ?? false,
      hideDateUnderDay:
          prefs.getBool(PrefsKeys.SCHEDULE_HIDE_DATE_UNDER_DAY) ?? false,
      timeColumnWidth: _clamp(
        prefs.getDouble(PrefsKeys.SCHEDULE_TIME_COLUMN_WIDTH) ?? 45,
        minTimeColumnWidth,
        maxTimeColumnWidth,
      ),
      showStartTime: prefs.getBool(PrefsKeys.SCHEDULE_SHOW_START_TIME) ?? false,
      hideLocation: prefs.getBool(PrefsKeys.SCHEDULE_HIDE_LOCATION) ?? false,
      pageTextColor: _decodeColor(
        prefs.getString(PrefsKeys.SCHEDULE_PAGE_TEXT_COLOR),
      ),
      courseTextColor: _decodeColor(
        prefs.getString(PrefsKeys.SCHEDULE_COURSE_TEXT_COLOR),
      ),
      hideTeacher: prefs.getBool(PrefsKeys.SCHEDULE_HIDE_TEACHER) ?? false,
      centerHorizontally:
          prefs.getBool(PrefsKeys.SCHEDULE_TEXT_CENTER_H) ?? false,
      centerVertically:
          prefs.getBool(PrefsKeys.SCHEDULE_TEXT_CENTER_V) ?? false,
      borderStyle: _decodeBorderStyle(
        prefs.getString(PrefsKeys.SCHEDULE_BORDER_STYLE),
      ),
      fontScale: _clamp(
        prefs.getDouble(PrefsKeys.SCHEDULE_FONT_SCALE) ?? 1.0,
        minFontScale,
        maxFontScale,
      ),
      cornerRadius: _clamp(
        prefs.getDouble(PrefsKeys.SCHEDULE_CORNER_RADIUS) ?? 8.0,
        minCornerRadius,
        maxCornerRadius,
      ),
      innerPadding: _clamp(
        prefs.getDouble(PrefsKeys.SCHEDULE_INNER_PADDING) ?? 4.0,
        minInnerPadding,
        maxInnerPadding,
      ),
      outerPadding: _clamp(
        prefs.getDouble(PrefsKeys.SCHEDULE_OUTER_PADDING) ?? 2.0,
        minOuterPadding,
        maxOuterPadding,
      ),
      opacity: _clamp(
        prefs.getDouble(PrefsKeys.SCHEDULE_OPACITY) ?? 1.0,
        minOpacity,
        maxOpacity,
      ),
      lightColorPoolThemeId: lightThemeId,
      darkColorPoolThemeId: darkThemeId,
      customColorPoolThemes: customThemes,
      courseColorOverrides: _decodeCourseColorOverrides(
        prefs.getString(PrefsKeys.SCHEDULE_COURSE_COLOR_OVERRIDES),
      ),
    );
  }

  double get headerHeight => state.headerHeight;
  bool get hideSectionTime => state.hideSectionTime;
  bool get hideDateUnderDay => state.hideDateUnderDay;
  double get timeColumnWidth => state.timeColumnWidth;
  bool get showStartTime => state.showStartTime;
  bool get hideLocation => state.hideLocation;
  Color? get pageTextColor => state.pageTextColor;
  Color? get courseTextColor => state.courseTextColor;
  bool get hideTeacher => state.hideTeacher;
  bool get centerHorizontally => state.centerHorizontally;
  bool get centerVertically => state.centerVertically;
  ScheduleBorderStyle get borderStyle => state.borderStyle;
  double get fontScale => state.fontScale;
  double get cornerRadius => state.cornerRadius;
  double get innerPadding => state.innerPadding;
  double get outerPadding => state.outerPadding;
  double get opacity => state.opacity;
  List<Color> get lightColorPool => state.lightColorPool;
  List<Color> get darkColorPool => state.darkColorPool;
  String get lightColorPoolThemeId => state.lightColorPoolThemeId;
  String get darkColorPoolThemeId => state.darkColorPoolThemeId;
  Map<String, ScheduleColorTheme> get customColorPoolThemes =>
      state.customColorPoolThemes;
  Map<String, Color> get courseColorOverrides => state.courseColorOverrides;

  List<Color> colorPoolFor(bool isDark) =>
      isDark ? state.darkColorPool : state.lightColorPool;

  Future<void> setHeaderHeight(double value, {bool persist = true}) async {
    final clamped = _clamp(value, minHeaderHeight, maxHeaderHeight);
    state = state.copyWith(headerHeight: clamped);
    if (persist) {
      await PrefsService.instance.setDouble(
        PrefsKeys.SCHEDULE_HEADER_HEIGHT,
        clamped,
      );
    }
  }

  Future<void> setHideSectionTime(bool value) async {
    state = state.copyWith(hideSectionTime: value);
    await PrefsService.instance.setBool(
      PrefsKeys.SCHEDULE_HIDE_SECTION_TIME,
      value,
    );
  }

  Future<void> setHideDateUnderDay(bool value) async {
    state = state.copyWith(hideDateUnderDay: value);
    await PrefsService.instance.setBool(
      PrefsKeys.SCHEDULE_HIDE_DATE_UNDER_DAY,
      value,
    );
  }

  Future<void> setTimeColumnWidth(double value) async {
    final clamped = _clamp(value, minTimeColumnWidth, maxTimeColumnWidth);
    state = state.copyWith(timeColumnWidth: clamped);
    await PrefsService.instance.setDouble(
      PrefsKeys.SCHEDULE_TIME_COLUMN_WIDTH,
      clamped,
    );
  }

  Future<void> setShowStartTime(bool value) async {
    state = state.copyWith(showStartTime: value);
    await PrefsService.instance.setBool(
      PrefsKeys.SCHEDULE_SHOW_START_TIME,
      value,
    );
  }

  Future<void> setHideLocation(bool value) async {
    state = state.copyWith(hideLocation: value);
    await PrefsService.instance.setBool(
      PrefsKeys.SCHEDULE_HIDE_LOCATION,
      value,
    );
  }

  Future<void> setPageTextColor(Color? value) async {
    state = state.copyWith(pageTextColor: value);
    await _persistNullableColor(PrefsKeys.SCHEDULE_PAGE_TEXT_COLOR, value);
  }

  Future<void> setCourseTextColor(Color? value) async {
    state = state.copyWith(courseTextColor: value);
    await _persistNullableColor(PrefsKeys.SCHEDULE_COURSE_TEXT_COLOR, value);
  }

  Future<void> setHideTeacher(bool value) async {
    state = state.copyWith(hideTeacher: value);
    await PrefsService.instance.setBool(PrefsKeys.SCHEDULE_HIDE_TEACHER, value);
  }

  Future<void> setCenterHorizontally(bool value) async {
    state = state.copyWith(centerHorizontally: value);
    await PrefsService.instance.setBool(
      PrefsKeys.SCHEDULE_TEXT_CENTER_H,
      value,
    );
  }

  Future<void> setCenterVertically(bool value) async {
    state = state.copyWith(centerVertically: value);
    await PrefsService.instance.setBool(
      PrefsKeys.SCHEDULE_TEXT_CENTER_V,
      value,
    );
  }

  Future<void> setBorderStyle(ScheduleBorderStyle value) async {
    state = state.copyWith(borderStyle: value);
    await PrefsService.instance.setString(
      PrefsKeys.SCHEDULE_BORDER_STYLE,
      value.name,
    );
  }

  Future<void> setFontScale(double value) async {
    final clamped = _clamp(value, minFontScale, maxFontScale);
    state = state.copyWith(fontScale: clamped);
    await PrefsService.instance.setDouble(
      PrefsKeys.SCHEDULE_FONT_SCALE,
      clamped,
    );
  }

  Future<void> setCornerRadius(double value) async {
    final clamped = _clamp(value, minCornerRadius, maxCornerRadius);
    state = state.copyWith(cornerRadius: clamped);
    await PrefsService.instance.setDouble(
      PrefsKeys.SCHEDULE_CORNER_RADIUS,
      clamped,
    );
  }

  Future<void> setInnerPadding(double value) async {
    final clamped = _clamp(value, minInnerPadding, maxInnerPadding);
    state = state.copyWith(innerPadding: clamped);
    await PrefsService.instance.setDouble(
      PrefsKeys.SCHEDULE_INNER_PADDING,
      clamped,
    );
  }

  Future<void> setOuterPadding(double value) async {
    final clamped = _clamp(value, minOuterPadding, maxOuterPadding);
    state = state.copyWith(outerPadding: clamped);
    await PrefsService.instance.setDouble(
      PrefsKeys.SCHEDULE_OUTER_PADDING,
      clamped,
    );
  }

  Future<void> setOpacity(double value) async {
    final clamped = _clamp(value, minOpacity, maxOpacity);
    state = state.copyWith(opacity: clamped);
    await PrefsService.instance.setDouble(PrefsKeys.SCHEDULE_OPACITY, clamped);
  }

  /// 切换某个池的活动主题。内置主题与已存在的自定义主题都允许。
  Future<bool> applyColorPoolTheme({
    required bool isDark,
    required String themeId,
  }) async {
    final exists =
        ScheduleColorThemeCatalog.isBuiltIn(themeId) ||
        state.customColorPoolThemes.containsKey(themeId);
    if (!exists) return false;

    state = isDark
        ? state.copyWith(darkColorPoolThemeId: themeId)
        : state.copyWith(lightColorPoolThemeId: themeId);
    await _persistActiveThemeId(isDark: isDark, themeId: themeId);
    return true;
  }

  /// 把当前池的颜色复制成一个新的自定义主题，并设为该池的活动主题。
  Future<String?> copyActivePoolThemeAsCustom({
    required bool isDark,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (!isColorThemeNameAvailable(trimmed)) return null;

    final colors = colorPoolFor(isDark);
    if (colors.isEmpty || colors.length > maxThemeColorCount) return null;

    final id = _newCustomThemeId();
    final next = Map<String, ScheduleColorTheme>.from(
      state.customColorPoolThemes,
    )..[id] = ScheduleColorTheme(name: trimmed, colors: colors);

    state = isDark
        ? state.copyWith(darkColorPoolThemeId: id, customColorPoolThemes: next)
        : state.copyWith(
            lightColorPoolThemeId: id,
            customColorPoolThemes: next,
          );

    await _persistCustomColorThemes(next);
    await _persistActiveThemeId(isDark: isDark, themeId: id);
    return id;
  }

  Future<bool> renameCustomColorTheme({
    required String id,
    required String name,
  }) async {
    final theme = state.customColorPoolThemes[id];
    if (theme == null || !ScheduleColorThemeCatalog.isCustomId(id)) {
      return false;
    }

    final trimmed = name.trim();
    if (!isColorThemeNameAvailable(trimmed, excludingId: id)) return false;

    return _updateCustomTheme(
      id,
      (current) => ScheduleColorTheme(name: trimmed, colors: current.colors),
    );
  }

  Future<bool> deleteCustomColorTheme(String id) async {
    if (!ScheduleColorThemeCatalog.isCustomId(id) ||
        !state.customColorPoolThemes.containsKey(id)) {
      return false;
    }

    final next = Map<String, ScheduleColorTheme>.from(
      state.customColorPoolThemes,
    )..remove(id);
    final lightWasActive = state.lightColorPoolThemeId == id;
    final darkWasActive = state.darkColorPoolThemeId == id;

    state = state.copyWith(
      customColorPoolThemes: next,
      lightColorPoolThemeId: lightWasActive
          ? scheduleDefaultLightThemeId
          : state.lightColorPoolThemeId,
      darkColorPoolThemeId: darkWasActive
          ? scheduleDefaultDarkThemeId
          : state.darkColorPoolThemeId,
    );

    await _persistCustomColorThemes(next);
    if (lightWasActive) {
      await _persistActiveThemeId(
        isDark: false,
        themeId: scheduleDefaultLightThemeId,
      );
    }
    if (darkWasActive) {
      await _persistActiveThemeId(
        isDark: true,
        themeId: scheduleDefaultDarkThemeId,
      );
    }
    return true;
  }

  Future<bool> setCustomColorThemeColor({
    required String id,
    required int index,
    required Color color,
  }) async {
    final theme = state.customColorPoolThemes[id];
    if (theme == null || !ScheduleColorThemeCatalog.isCustomId(id)) {
      return false;
    }
    if (index < 0 || index >= theme.colors.length) return false;

    final colors = List<Color>.from(theme.colors)..[index] = color;
    return _updateCustomTheme(
      id,
      (current) => ScheduleColorTheme(name: current.name, colors: colors),
    );
  }

  /// 追加一种颜色；返回新颜色索引，失败（非自定义主题/已达上限）返回 null。
  Future<int?> addCustomColorThemeColor({
    required String id,
    Color? seedColor,
  }) async {
    final theme = state.customColorPoolThemes[id];
    if (theme == null || !ScheduleColorThemeCatalog.isCustomId(id)) {
      return null;
    }
    if (theme.colors.length >= maxThemeColorCount) return null;

    final seed =
        seedColor ??
        ScheduleColorThemeCatalog.defaultColorPool[theme.colors.length %
            ScheduleColorThemeCatalog.defaultColorPool.length];
    final colors = List<Color>.from(theme.colors)..add(seed);
    final updated = ScheduleColorTheme(name: theme.name, colors: colors);
    final next = Map<String, ScheduleColorTheme>.from(
      state.customColorPoolThemes,
    )..[id] = updated;

    state = state.copyWith(customColorPoolThemes: next);
    await _persistCustomColorThemes(next);
    return colors.length - 1;
  }

  Future<bool> removeCustomColorThemeColor({
    required String id,
    required int index,
  }) async {
    final theme = state.customColorPoolThemes[id];
    if (theme == null || !ScheduleColorThemeCatalog.isCustomId(id)) {
      return false;
    }
    if (theme.colors.length <= minThemeColorCount) return false;
    if (index < 0 || index >= theme.colors.length) return false;

    final colors = List<Color>.from(theme.colors)..removeAt(index);
    return _updateCustomTheme(
      id,
      (current) => ScheduleColorTheme(name: current.name, colors: colors),
    );
  }

  bool isColorThemeNameAvailable(String rawName, {String? excludingId}) {
    final name = rawName.trim();
    if (name.isEmpty || name.length > maxThemeNameLength) return false;
    if (ScheduleColorThemeCatalog.isReservedName(name)) return false;

    final lower = name.toLowerCase();
    for (final entry in state.customColorPoolThemes.entries) {
      if (entry.key == excludingId) continue;
      if (entry.value.name.toLowerCase() == lower) return false;
    }
    return true;
  }

  Future<void> setCourseColorOverride(String key, Color color) async {
    if (key.trim().isEmpty) return;
    final next = Map<String, Color>.from(state.courseColorOverrides)
      ..[key] = color;
    state = state.copyWith(courseColorOverrides: next);
    await _persistCourseColorOverrides(next);
  }

  Future<void> clearCourseColorOverride(String key) async {
    if (!state.courseColorOverrides.containsKey(key)) return;
    final next = Map<String, Color>.from(state.courseColorOverrides)
      ..remove(key);
    state = state.copyWith(courseColorOverrides: next);
    await _persistCourseColorOverrides(next);
  }

  Future<void> resetToDefaults() async {
    state = const ScheduleStyleState();

    final prefs = PrefsService.instance;
    await Future.wait([
      prefs.remove(PrefsKeys.SCHEDULE_HEADER_HEIGHT),
      prefs.remove(PrefsKeys.SCHEDULE_HIDE_SECTION_TIME),
      prefs.remove(PrefsKeys.SCHEDULE_HIDE_DATE_UNDER_DAY),
      prefs.remove(PrefsKeys.SCHEDULE_TIME_COLUMN_WIDTH),
      prefs.remove(PrefsKeys.SCHEDULE_SHOW_START_TIME),
      prefs.remove(PrefsKeys.SCHEDULE_HIDE_LOCATION),
      prefs.remove(PrefsKeys.SCHEDULE_PAGE_TEXT_COLOR),
      prefs.remove(PrefsKeys.SCHEDULE_COURSE_TEXT_COLOR),
      prefs.remove(PrefsKeys.SCHEDULE_HIDE_TEACHER),
      prefs.remove(PrefsKeys.SCHEDULE_TEXT_CENTER_H),
      prefs.remove(PrefsKeys.SCHEDULE_TEXT_CENTER_V),
      prefs.remove(PrefsKeys.SCHEDULE_BORDER_STYLE),
      prefs.remove(PrefsKeys.SCHEDULE_FONT_SCALE),
      prefs.remove(PrefsKeys.SCHEDULE_CORNER_RADIUS),
      prefs.remove(PrefsKeys.SCHEDULE_INNER_PADDING),
      prefs.remove(PrefsKeys.SCHEDULE_OUTER_PADDING),
      prefs.remove(PrefsKeys.SCHEDULE_OPACITY),
      prefs.remove(PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL),
      prefs.remove(PrefsKeys.SCHEDULE_DARK_COLOR_POOL),
      prefs.remove(PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID),
      prefs.remove(PrefsKeys.SCHEDULE_DARK_COLOR_POOL_THEME_ID),
      prefs.remove(PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES),
      prefs.remove(PrefsKeys.SCHEDULE_COURSE_COLOR_OVERRIDES),
    ]);
  }

  Future<bool> _updateCustomTheme(
    String id,
    ScheduleColorTheme Function(ScheduleColorTheme current) transform,
  ) async {
    final current = state.customColorPoolThemes[id];
    if (current == null || !ScheduleColorThemeCatalog.isCustomId(id)) {
      return false;
    }

    final next = Map<String, ScheduleColorTheme>.from(
      state.customColorPoolThemes,
    )..[id] = transform(current);
    state = state.copyWith(customColorPoolThemes: next);
    await _persistCustomColorThemes(next);
    return true;
  }

  String _newCustomThemeId() {
    final base =
        '${ScheduleColorThemeCatalog.customIdPrefix}'
        '${DateTime.now().microsecondsSinceEpoch}';
    var id = base;
    var suffix = 1;
    while (state.customColorPoolThemes.containsKey(id)) {
      id = '$base-$suffix';
      suffix++;
    }
    return id;
  }

  Future<void> _persistActiveThemeId({
    required bool isDark,
    required String themeId,
  }) async {
    await PrefsService.instance.setString(
      isDark
          ? PrefsKeys.SCHEDULE_DARK_COLOR_POOL_THEME_ID
          : PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID,
      themeId,
    );
  }

  Future<void> _persistCustomColorThemes(
    Map<String, ScheduleColorTheme> themes,
  ) async {
    final prefs = PrefsService.instance;
    if (themes.isEmpty) {
      await prefs.remove(PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES);
      return;
    }

    await prefs.setString(
      PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES,
      jsonEncode(
        themes.map(
          (id, theme) => MapEntry(id, <String, Object>{
            'name': theme.name,
            'colors': theme.colors.map(_encodeColor).toList(),
          }),
        ),
      ),
    );
  }

  Future<void> _persistCourseColorOverrides(
    Map<String, Color> overrides,
  ) async {
    final prefs = PrefsService.instance;
    if (overrides.isEmpty) {
      await prefs.remove(PrefsKeys.SCHEDULE_COURSE_COLOR_OVERRIDES);
      return;
    }

    await prefs.setString(
      PrefsKeys.SCHEDULE_COURSE_COLOR_OVERRIDES,
      jsonEncode(
        overrides.map((key, color) => MapEntry(key, _encodeColor(color))),
      ),
    );
  }

  Future<void> _persistNullableColor(String key, Color? value) async {
    final prefs = PrefsService.instance;
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, _encodeColor(value));
    }
  }

  static double _clamp(double value, double min, double max) =>
      value.clamp(min, max).toDouble();

  static Color? _decodeColor(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final value = int.tryParse(raw, radix: 16);
    if (value == null || value > 0xFFFFFFFF) return null;
    return Color(value);
  }

  /// 解码主题里的颜色：兼容可选的 `#` 前缀与 6/8 位 hex。
  static Color? _decodeThemeColor(String raw) {
    var value = raw.trim();
    if (value.startsWith('#')) value = value.substring(1);
    if (value.length != 6 && value.length != 8) return null;

    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return null;
    return Color(value.length == 6 ? 0xFF000000 | parsed : parsed);
  }

  static String _encodeColor(Color color) =>
      color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();

  /// 保留原始长度，逐项丢弃非法颜色，最多 [maxLength] 个。
  static List<Color> _decodeColorList(Object? raw, {required int maxLength}) {
    if (raw is! List || raw.isEmpty) return const <Color>[];

    final colors = <Color>[];
    for (final value in raw) {
      if (value is! String) continue;
      final color = _decodeThemeColor(value);
      if (color == null) continue;
      colors.add(color);
      if (colors.length >= maxLength) break;
    }
    return List<Color>.unmodifiable(colors);
  }

  /// 解码自定义主题 JSON。非法 JSON、非法颜色、重名、空色板逐项丢弃。
  static Map<String, ScheduleColorTheme> _decodeCustomColorThemes(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const <String, ScheduleColorTheme>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const <String, ScheduleColorTheme>{};
      }

      final themes = <String, ScheduleColorTheme>{};
      final usedNames = <String>{};

      decoded.forEach((id, value) {
        if (!ScheduleColorThemeCatalog.isCustomId(id) ||
            ScheduleColorThemeCatalog.isBuiltIn(id)) {
          return;
        }
        if (value is! Map<String, dynamic>) return;

        final rawName = value['name'];
        if (rawName is! String) return;

        var name = rawName.trim();
        if (name.isEmpty) return;
        if (name.length > maxThemeNameLength) {
          name = name.substring(0, maxThemeNameLength).trim();
        }
        if (name.isEmpty || ScheduleColorThemeCatalog.isReservedName(name)) {
          return;
        }
        if (usedNames.contains(name.toLowerCase())) return;

        final colors = _decodeColorList(
          value['colors'],
          maxLength: maxThemeColorCount,
        );
        if (colors.isEmpty) return;

        usedNames.add(name.toLowerCase());
        themes[id] = ScheduleColorTheme(name: name, colors: colors);
      });

      return Map<String, ScheduleColorTheme>.unmodifiable(themes);
    } catch (_) {
      return const <String, ScheduleColorTheme>{};
    }
  }

  static String _resolveStoredThemeId(
    String? raw,
    Map<String, ScheduleColorTheme> customThemes,
  ) {
    if (raw != null && raw.isNotEmpty) {
      if (ScheduleColorThemeCatalog.isBuiltIn(raw) ||
          customThemes.containsKey(raw)) {
        return raw;
      }
    }
    return ScheduleColorThemeCatalog.defaultThemeId;
  }

  /// 解码逐课程颜色覆盖。非法 JSON / 非法颜色逐项丢弃，绝不抛异常。
  static Map<String, Color> _decodeCourseColorOverrides(String? raw) {
    if (raw == null || raw.isEmpty) return const <String, Color>{};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const <String, Color>{};

      final overrides = <String, Color>{};
      decoded.forEach((key, value) {
        if (key.trim().isEmpty || value is! String) return;
        final color = _decodeColor(value);
        if (color != null) overrides[key] = color;
      });
      return Map<String, Color>.unmodifiable(overrides);
    } catch (_) {
      return const <String, Color>{};
    }
  }

  static ScheduleBorderStyle _decodeBorderStyle(String? raw) {
    for (final style in ScheduleBorderStyle.values) {
      if (style.name == raw) return style;
    }
    return ScheduleBorderStyle.none;
  }

  /// 旧版本升级：把两个池的活动主题一次性重置为 Macchiato。
  ///
  /// 自定义主题定义保留（只是不再处于活动状态）；不触碰
  /// [PrefsKeys.SCHEDULE_COURSE_COLOR_OVERRIDES]；schema 最后写入，
  /// 迁移中断后可安全重跑。
  Future<void> _migrateColorPools() async {
    state = state.copyWith(
      lightColorPoolThemeId: scheduleDefaultLightThemeId,
      darkColorPoolThemeId: scheduleDefaultDarkThemeId,
    );

    final prefs = PrefsService.instance;
    await Future.wait([
      prefs.remove(PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL),
      prefs.remove(PrefsKeys.SCHEDULE_DARK_COLOR_POOL),
    ]);
    await prefs.setString(
      PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID,
      scheduleDefaultLightThemeId,
    );
    await prefs.setString(
      PrefsKeys.SCHEDULE_DARK_COLOR_POOL_THEME_ID,
      scheduleDefaultDarkThemeId,
    );
    await prefs.setInt(PrefsKeys.SCHEDULE_COLOR_POOL_SCHEMA, colorPoolSchema);
  }
}
