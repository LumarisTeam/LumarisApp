import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/schedule_color_themes.dart';
import 'package:ios_club_app/state/schedule_style_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScheduleStyleStore', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await PrefsService.init();

      // PrefsService 缓存同一个实例，显式清掉上一个用例可能写入的主题数据。
      final prefs = PrefsService.instance;
      for (final key in <String>[
        PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID,
        PrefsKeys.SCHEDULE_DARK_COLOR_POOL_THEME_ID,
        PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES,
        PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL,
        PrefsKeys.SCHEDULE_DARK_COLOR_POOL,
        PrefsKeys.SCHEDULE_COURSE_COLOR_OVERRIDES,
      ]) {
        await prefs.remove(key);
      }
      // 默认认为颜色池已是当前 schema，避免迁移 microtask 覆盖各测试写入的数据。
      await prefs.setInt(
        PrefsKeys.SCHEDULE_COLOR_POOL_SCHEMA,
        ScheduleStyleStore.colorPoolSchema,
      );
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    ScheduleStyleStore store() =>
        container.read(scheduleStyleStoreProvider.notifier);
    ScheduleStyleState state() => container.read(scheduleStyleStoreProvider);

    Future<void> reload() async {
      container.dispose();
      container = ProviderContainer();
      addTearDown(container.dispose);
    }

    test('should load default values when prefs is empty', () {
      final style = state();

      expect(style.headerHeight, 45);
      expect(style.hideSectionTime, isFalse);
      expect(style.hideDateUnderDay, isFalse);
      expect(style.timeColumnWidth, 45);
      expect(style.showStartTime, isFalse);
      expect(style.hideLocation, isFalse);
      expect(style.pageTextColor, isNull);
      expect(style.courseTextColor, isNull);
      expect(style.hideTeacher, isFalse);
      expect(style.centerHorizontally, isFalse);
      expect(style.centerVertically, isFalse);
      expect(style.borderStyle, ScheduleBorderStyle.none);
      expect(style.fontScale, 1.0);
      expect(style.cornerRadius, 8.0);
      expect(style.innerPadding, 4.0);
      expect(style.outerPadding, 2.0);
      expect(style.opacity, 1.0);
      expect(style.lightColorPoolThemeId, scheduleDefaultLightThemeId);
      expect(style.darkColorPoolThemeId, scheduleDefaultDarkThemeId);
      expect(style.lightColorPool, scheduleDefaultLightColorPool);
      expect(style.darkColorPool, scheduleDefaultDarkColorPool);
      expect(style.lightColorPool.length, 14);
      expect(style.darkColorPool.length, 14);
      expect(style.customColorPoolThemes, isEmpty);
      expect(style.courseColorOverrides, isEmpty);
    });

    test('should load existing style values from prefs', () async {
      final prefs = PrefsService.instance;
      await prefs.setDouble(PrefsKeys.SCHEDULE_HEADER_HEIGHT, 72);
      await prefs.setString(PrefsKeys.SCHEDULE_PAGE_TEXT_COLOR, 'FF112233');
      await prefs.setString(PrefsKeys.SCHEDULE_COURSE_TEXT_COLOR, 'FF445566');
      await prefs.setBool(PrefsKeys.SCHEDULE_HIDE_TEACHER, true);
      await prefs.setBool(PrefsKeys.SCHEDULE_TEXT_CENTER_H, true);
      await prefs.setBool(PrefsKeys.SCHEDULE_TEXT_CENTER_V, true);
      await prefs.setString(PrefsKeys.SCHEDULE_BORDER_STYLE, 'dashed');

      await reload();

      final style = state();
      expect(style.headerHeight, 72);
      expect(style.pageTextColor, const Color(0xFF112233));
      expect(style.courseTextColor, const Color(0xFF445566));
      expect(style.hideTeacher, isTrue);
      expect(style.centerHorizontally, isTrue);
      expect(style.centerVertically, isTrue);
      expect(style.borderStyle, ScheduleBorderStyle.dashed);
    });

    test('should load theme ids and variable-length custom themes', () async {
      final prefs = PrefsService.instance;
      await prefs.setString(
        PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES,
        jsonEncode(<String, Object>{
          'custom:1': <String, Object>{
            'name': '我的主题',
            'colors': <String>['FF112233', '112233', 'FF445566'],
          },
        }),
      );
      await prefs.setString(
        PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID,
        'custom:1',
      );
      await prefs.setString(
        PrefsKeys.SCHEDULE_DARK_COLOR_POOL_THEME_ID,
        'latte',
      );

      await reload();

      final style = state();
      expect(style.lightColorPoolThemeId, 'custom:1');
      expect(style.darkColorPoolThemeId, 'latte');
      expect(style.customColorPoolThemes['custom:1']?.name, '我的主题');
      expect(style.lightColorPool, const <Color>[
        Color(0xFF112233),
        Color(0xFF112233),
        Color(0xFF445566),
      ]);
      expect(style.darkColorPool, ScheduleColorThemeCatalog.latteAccents);
    });

    test('should fall back to default theme ids for unknown ids', () async {
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID,
        'custom:missing',
      );
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_DARK_COLOR_POOL_THEME_ID,
        'not-a-theme',
      );

      await reload();

      expect(state().lightColorPoolThemeId, 'macchiato');
      expect(state().darkColorPoolThemeId, 'macchiato');
    });

    test('should ignore invalid custom theme entries', () async {
      final tooManyColors = List<String>.generate(
        40,
        (index) => 'FF0000${index.toString().padLeft(2, '0')}',
      );
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES,
        jsonEncode(<String, Object>{
          'custom:ok': <String, Object>{
            'name': 'Good',
            'colors': <String>['FF112233', 'not-a-color', '112233'],
          },
          'custom:empty': <String, Object>{
            'name': 'Empty',
            'colors': <String>[],
          },
          'custom:reserved': <String, Object>{
            'name': 'Latte',
            'colors': <String>['FF112233'],
          },
          'custom:duplicate': <String, Object>{
            'name': 'Good',
            'colors': <String>['FF445566'],
          },
          'latte': <String, Object>{
            'name': 'Built-in',
            'colors': <String>['FF112233'],
          },
          'custom:long': <String, Object>{
            'name': 'X' * 60,
            'colors': <String>['FF112233'],
          },
          'custom:many': <String, Object>{
            'name': 'Many',
            'colors': tooManyColors,
          },
          'custom:not-colors': <String, Object>{
            'name': 'No colors',
            'colors': 'FF112233',
          },
        }),
      );

      await reload();

      final themes = state().customColorPoolThemes;
      expect(
        themes.keys,
        containsAll(<String>['custom:ok', 'custom:long', 'custom:many']),
      );
      expect(themes.keys, isNot(contains('custom:empty')));
      expect(themes.keys, isNot(contains('custom:reserved')));
      expect(themes.keys, isNot(contains('custom:duplicate')));
      expect(themes.keys, isNot(contains('latte')));
      expect(themes.keys, isNot(contains('custom:not-colors')));
      expect(themes['custom:ok']?.colors.length, 2);
      expect(themes['custom:long']?.name.length, 40);
      expect(themes['custom:many']?.colors.length, 32);
    });

    test('should tolerate malformed custom theme json', () async {
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES,
        '{not json',
      );

      await reload();

      expect(state().customColorPoolThemes, isEmpty);
    });

    test('should update and persist style values', () async {
      final styleStore = store();

      await styleStore.setHeaderHeight(90);
      await styleStore.setPageTextColor(const Color(0xFF112233));
      await styleStore.setCourseTextColor(const Color(0xFF445566));
      await styleStore.setHideTeacher(true);
      await styleStore.setCenterHorizontally(true);
      await styleStore.setCenterVertically(true);
      await styleStore.setBorderStyle(ScheduleBorderStyle.solid);

      final prefs = PrefsService.instance;
      expect(state().headerHeight, 80);
      expect(state().pageTextColor, const Color(0xFF112233));
      expect(state().courseTextColor, const Color(0xFF445566));
      expect(state().hideTeacher, isTrue);
      expect(state().centerHorizontally, isTrue);
      expect(state().centerVertically, isTrue);
      expect(state().borderStyle, ScheduleBorderStyle.solid);

      expect(prefs.getDouble(PrefsKeys.SCHEDULE_HEADER_HEIGHT), 80);
      expect(prefs.getString(PrefsKeys.SCHEDULE_PAGE_TEXT_COLOR), 'FF112233');
      expect(prefs.getString(PrefsKeys.SCHEDULE_COURSE_TEXT_COLOR), 'FF445566');
      expect(prefs.getBool(PrefsKeys.SCHEDULE_HIDE_TEACHER), isTrue);
      expect(prefs.getString(PrefsKeys.SCHEDULE_BORDER_STYLE), 'solid');
    });

    test('should update and persist extended style values', () async {
      final styleStore = store();

      await styleStore.setHideSectionTime(true);
      await styleStore.setHideDateUnderDay(true);
      await styleStore.setTimeColumnWidth(70);
      await styleStore.setShowStartTime(true);
      await styleStore.setHideLocation(true);
      await styleStore.setFontScale(1.5);
      await styleStore.setCornerRadius(16);
      await styleStore.setInnerPadding(8);
      await styleStore.setOuterPadding(4);
      await styleStore.setOpacity(0.5);

      final style = state();
      expect(style.hideSectionTime, isTrue);
      expect(style.hideDateUnderDay, isTrue);
      expect(style.timeColumnWidth, 70);
      expect(style.showStartTime, isTrue);
      expect(style.hideLocation, isTrue);
      expect(style.fontScale, 1.5);
      expect(style.cornerRadius, 16);
      expect(style.innerPadding, 8);
      expect(style.outerPadding, 4);
      expect(style.opacity, 0.5);

      final prefs = PrefsService.instance;
      expect(prefs.getBool(PrefsKeys.SCHEDULE_HIDE_SECTION_TIME), isTrue);
      expect(prefs.getBool(PrefsKeys.SCHEDULE_HIDE_DATE_UNDER_DAY), isTrue);
      expect(prefs.getDouble(PrefsKeys.SCHEDULE_TIME_COLUMN_WIDTH), 70);
      expect(prefs.getBool(PrefsKeys.SCHEDULE_SHOW_START_TIME), isTrue);
      expect(prefs.getBool(PrefsKeys.SCHEDULE_HIDE_LOCATION), isTrue);
      expect(prefs.getDouble(PrefsKeys.SCHEDULE_FONT_SCALE), 1.5);
      expect(prefs.getDouble(PrefsKeys.SCHEDULE_CORNER_RADIUS), 16);
      expect(prefs.getDouble(PrefsKeys.SCHEDULE_INNER_PADDING), 8);
      expect(prefs.getDouble(PrefsKeys.SCHEDULE_OUTER_PADDING), 4);
      expect(prefs.getDouble(PrefsKeys.SCHEDULE_OPACITY), 0.5);
    });

    test('should clamp extended style values to their ranges', () async {
      final styleStore = store();

      await styleStore.setTimeColumnWidth(200);
      await styleStore.setFontScale(5);
      await styleStore.setCornerRadius(100);
      await styleStore.setOpacity(0);

      final style = state();
      expect(style.timeColumnWidth, 80);
      expect(style.fontScale, 2.0);
      expect(style.cornerRadius, 24);
      expect(style.opacity, 0.1);
    });

    test('should remove nullable color keys when reset to theme', () async {
      final styleStore = store();
      await styleStore.setPageTextColor(const Color(0xFF112233));
      await styleStore.setPageTextColor(null);

      expect(state().pageTextColor, isNull);
      expect(
        PrefsService.instance.getString(PrefsKeys.SCHEDULE_PAGE_TEXT_COLOR),
        isNull,
      );
    });

    test('should apply a built-in theme to one pool only', () async {
      final styleStore = store();

      final applied = await styleStore.applyColorPoolTheme(
        isDark: false,
        themeId: 'latte',
      );

      expect(applied, isTrue);
      expect(state().lightColorPoolThemeId, 'latte');
      expect(state().darkColorPoolThemeId, 'macchiato');
      expect(state().lightColorPool, ScheduleColorThemeCatalog.latteAccents);
      expect(state().darkColorPool, scheduleDefaultDarkColorPool);
      expect(
        PrefsService.instance.getString(
          PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID,
        ),
        'latte',
      );
      expect(
        PrefsService.instance.getString(
          PrefsKeys.SCHEDULE_DARK_COLOR_POOL_THEME_ID,
        ),
        isNull,
      );
    });

    test('should reject unknown theme ids', () async {
      final styleStore = store();

      final applied = await styleStore.applyColorPoolTheme(
        isDark: false,
        themeId: 'custom:missing',
      );

      expect(applied, isFalse);
      expect(state().lightColorPoolThemeId, 'macchiato');
    });

    test('should copy the active pool into a custom theme', () async {
      final styleStore = store();

      final id = await styleStore.copyActivePoolThemeAsCustom(
        isDark: false,
        name: '我的主题',
      );

      expect(id, isNotNull);
      expect(id, startsWith('custom:'));
      expect(state().lightColorPoolThemeId, id);
      expect(state().darkColorPoolThemeId, 'macchiato');
      expect(state().customColorPoolThemes[id]?.name, '我的主题');
      expect(state().lightColorPool, scheduleDefaultLightColorPool);

      final persisted =
          jsonDecode(
                PrefsService.instance.getString(
                  PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES,
                )!,
              )
              as Map<String, dynamic>;
      expect(persisted.keys, contains(id));
      expect(persisted[id]['name'], '我的主题');
      expect(persisted[id]['colors'], hasLength(14));
    });

    test(
      'should keep built-in palettes immutable after editing a copy',
      () async {
        final styleStore = store();
        final id = (await styleStore.copyActivePoolThemeAsCustom(
          isDark: false,
          name: '副本',
        ))!;

        final updated = await styleStore.setCustomColorThemeColor(
          id: id,
          index: 0,
          color: const Color(0xFF000000),
        );

        expect(updated, isTrue);
        expect(state().lightColorPool.first, const Color(0xFF000000));
        expect(scheduleDefaultLightColorPool.first, const Color(0xFFF4DBD6));
        expect(
          state().customColorPoolThemes[id]?.colors.first,
          const Color(0xFF000000),
        );
      },
    );

    test('should validate theme names', () async {
      final styleStore = store();
      final id = (await styleStore.copyActivePoolThemeAsCustom(
        isDark: false,
        name: '我的主题',
      ))!;

      expect(styleStore.isColorThemeNameAvailable(''), isFalse);
      expect(styleStore.isColorThemeNameAvailable('   '), isFalse);
      expect(styleStore.isColorThemeNameAvailable('latte'), isFalse);
      expect(styleStore.isColorThemeNameAvailable('MACCHIATO'), isFalse);
      expect(styleStore.isColorThemeNameAvailable('Mocha'), isTrue);
      expect(styleStore.isColorThemeNameAvailable('我的主题'), isFalse);
      expect(
        styleStore.isColorThemeNameAvailable('我的主题', excludingId: id),
        isTrue,
      );
      expect(styleStore.isColorThemeNameAvailable('X' * 41), isFalse);
      expect(styleStore.isColorThemeNameAvailable('另一个主题'), isTrue);
    });

    test('should rename a custom theme without changing its id', () async {
      final styleStore = store();
      final id = (await styleStore.copyActivePoolThemeAsCustom(
        isDark: false,
        name: '旧名称',
      ))!;

      final renamed = await styleStore.renameCustomColorTheme(
        id: id,
        name: '新名称',
      );

      expect(renamed, isTrue);
      expect(state().lightColorPoolThemeId, id);
      expect(state().customColorPoolThemes[id]?.name, '新名称');
      expect(
        PrefsService.instance.getString(
          PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES,
        ),
        contains('新名称'),
      );
    });

    test('should reject duplicate and reserved rename targets', () async {
      final styleStore = store();
      final firstId = (await styleStore.copyActivePoolThemeAsCustom(
        isDark: false,
        name: '主题一',
      ))!;
      await styleStore.copyActivePoolThemeAsCustom(isDark: false, name: '主题二');

      expect(
        await styleStore.renameCustomColorTheme(id: firstId, name: '主题二'),
        isFalse,
      );
      expect(
        await styleStore.renameCustomColorTheme(id: firstId, name: 'Latte'),
        isFalse,
      );
      expect(
        await styleStore.renameCustomColorTheme(id: firstId, name: '主题一'),
        isTrue,
      );
    });

    test('should add, edit and remove custom theme colors', () async {
      final styleStore = store();
      final id = (await styleStore.copyActivePoolThemeAsCustom(
        isDark: false,
        name: '可编辑',
      ))!;

      final addedIndex = await styleStore.addCustomColorThemeColor(
        id: id,
        seedColor: const Color(0xFF010203),
      );
      expect(addedIndex, 14);
      expect(state().lightColorPool.length, 15);
      expect(state().lightColorPool.last, const Color(0xFF010203));

      await styleStore.setCustomColorThemeColor(
        id: id,
        index: addedIndex!,
        color: const Color(0xFF0A0B0C),
      );
      expect(state().lightColorPool.last, const Color(0xFF0A0B0C));

      final removed = await styleStore.removeCustomColorThemeColor(
        id: id,
        index: 0,
      );
      expect(removed, isTrue);
      expect(state().lightColorPool.length, 14);
      expect(state().lightColorPool.first, scheduleDefaultLightColorPool[1]);
    });

    test('should enforce the minimum color count', () async {
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES,
        jsonEncode(<String, Object>{
          'custom:one': <String, Object>{
            'name': '单色',
            'colors': <String>['FF112233'],
          },
        }),
      );
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID,
        'custom:one',
      );
      await reload();

      final styleStore = store();
      expect(state().lightColorPool, const <Color>[Color(0xFF112233)]);
      expect(
        await styleStore.removeCustomColorThemeColor(
          id: 'custom:one',
          index: 0,
        ),
        isFalse,
      );
    });

    test('should enforce the maximum color count', () async {
      final colors = List<String>.generate(32, (index) {
        return 'FF0000${index.toString().padLeft(2, '0')}';
      });
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES,
        jsonEncode(<String, Object>{
          'custom:max': <String, Object>{'name': '满色', 'colors': colors},
        }),
      );
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID,
        'custom:max',
      );
      await reload();

      final styleStore = store();
      expect(state().lightColorPool.length, 32);
      expect(
        await styleStore.addCustomColorThemeColor(id: 'custom:max'),
        isNull,
      );
    });

    test('should share custom theme edits between both pools', () async {
      final styleStore = store();
      final id = (await styleStore.copyActivePoolThemeAsCustom(
        isDark: false,
        name: '共享主题',
      ))!;
      await styleStore.applyColorPoolTheme(isDark: true, themeId: id);

      await styleStore.setCustomColorThemeColor(
        id: id,
        index: 0,
        color: const Color(0xFF123123),
      );

      expect(state().lightColorPoolThemeId, id);
      expect(state().darkColorPoolThemeId, id);
      expect(state().lightColorPool.first, const Color(0xFF123123));
      expect(state().darkColorPool.first, const Color(0xFF123123));
    });

    test('should reset every pool using a deleted custom theme', () async {
      final styleStore = store();
      final id = (await styleStore.copyActivePoolThemeAsCustom(
        isDark: false,
        name: '共享主题',
      ))!;
      await styleStore.applyColorPoolTheme(isDark: true, themeId: id);

      final deleted = await styleStore.deleteCustomColorTheme(id);

      expect(deleted, isTrue);
      expect(state().customColorPoolThemes, isEmpty);
      expect(state().lightColorPoolThemeId, 'macchiato');
      expect(state().darkColorPoolThemeId, 'macchiato');
      expect(state().lightColorPool, scheduleDefaultLightColorPool);
      expect(state().darkColorPool, scheduleDefaultDarkColorPool);
      expect(
        PrefsService.instance.getString(
          PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES,
        ),
        isNull,
      );
      expect(
        PrefsService.instance.getString(
          PrefsKeys.SCHEDULE_DARK_COLOR_POOL_THEME_ID,
        ),
        'macchiato',
      );
    });

    test('should keep built-in themes read-only', () async {
      final styleStore = store();
      final before = state();

      expect(
        await styleStore.setCustomColorThemeColor(
          id: 'latte',
          index: 0,
          color: const Color(0xFF000000),
        ),
        isFalse,
      );
      expect(await styleStore.addCustomColorThemeColor(id: 'latte'), isNull);
      expect(
        await styleStore.removeCustomColorThemeColor(id: 'latte', index: 0),
        isFalse,
      );
      expect(
        await styleStore.renameCustomColorTheme(id: 'latte', name: '另一个名字'),
        isFalse,
      );
      expect(await styleStore.deleteCustomColorTheme('latte'), isFalse);
      expect(state(), before);
    });

    test('should set and clear a course color override', () async {
      final styleStore = store();
      const color = Color(0xFF123456);

      await styleStore.setCourseColorOverride('id:L1', color);

      expect(state().courseColorOverrides['id:L1'], color);
      expect(
        PrefsService.instance.getString(
          PrefsKeys.SCHEDULE_COURSE_COLOR_OVERRIDES,
        ),
        contains('"id:L1":"FF123456"'),
      );

      await styleStore.clearCourseColorOverride('id:L1');

      expect(state().courseColorOverrides, isEmpty);
      expect(
        PrefsService.instance.getString(
          PrefsKeys.SCHEDULE_COURSE_COLOR_OVERRIDES,
        ),
        isNull,
      );
    });

    test('should ignore empty override keys', () async {
      final styleStore = store();

      await styleStore.setCourseColorOverride('   ', const Color(0xFF123456));

      expect(state().courseColorOverrides, isEmpty);
    });

    test('should restore defaults and clear keys on resetToDefaults', () async {
      final styleStore = store();
      await styleStore.setHeaderHeight(72);
      await styleStore.setHideSectionTime(true);
      await styleStore.setHideTeacher(true);
      await styleStore.setBorderStyle(ScheduleBorderStyle.dashed);
      await styleStore.setFontScale(1.5);
      await styleStore.applyColorPoolTheme(isDark: false, themeId: 'latte');
      await styleStore.copyActivePoolThemeAsCustom(isDark: false, name: '自定义');
      await styleStore.setCourseColorOverride('id:L1', const Color(0xFF123456));

      await styleStore.resetToDefaults();

      expect(state().headerHeight, 45);
      expect(state().hideSectionTime, isFalse);
      expect(state().hideTeacher, isFalse);
      expect(state().borderStyle, ScheduleBorderStyle.none);
      expect(state().fontScale, 1.0);
      expect(state().lightColorPoolThemeId, 'macchiato');
      expect(state().darkColorPoolThemeId, 'macchiato');
      expect(state().lightColorPool, scheduleDefaultLightColorPool);
      expect(state().darkColorPool, scheduleDefaultDarkColorPool);
      expect(state().customColorPoolThemes, isEmpty);
      expect(state().courseColorOverrides, isEmpty);

      final prefs = PrefsService.instance;
      expect(prefs.getDouble(PrefsKeys.SCHEDULE_HEADER_HEIGHT), isNull);
      expect(prefs.getBool(PrefsKeys.SCHEDULE_HIDE_SECTION_TIME), isNull);
      expect(prefs.getBool(PrefsKeys.SCHEDULE_HIDE_TEACHER), isNull);
      expect(prefs.getString(PrefsKeys.SCHEDULE_BORDER_STYLE), isNull);
      expect(prefs.getDouble(PrefsKeys.SCHEDULE_FONT_SCALE), isNull);
      expect(
        prefs.getString(PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID),
        isNull,
      );
      expect(
        prefs.getString(PrefsKeys.SCHEDULE_DARK_COLOR_POOL_THEME_ID),
        isNull,
      );
      expect(
        prefs.getString(PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES),
        isNull,
      );
      expect(
        prefs.getInt(PrefsKeys.SCHEDULE_COLOR_POOL_SCHEMA),
        ScheduleStyleStore.colorPoolSchema,
      );
    });

    test('should keep course overrides during color pool migration', () async {
      await PrefsService.instance.remove(PrefsKeys.SCHEDULE_COLOR_POOL_SCHEMA);
      await PrefsService.instance.setStringList(
        PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL,
        List<String>.generate(
          12,
          (index) => 'FF0000${index.toString().padLeft(2, '0')}',
        ),
      );
      await PrefsService.instance.setStringList(
        PrefsKeys.SCHEDULE_DARK_COLOR_POOL,
        List<String>.generate(
          12,
          (index) => 'FF0000${index.toString().padLeft(2, '0')}',
        ),
      );
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_COURSE_COLOR_OVERRIDES,
        '{"id:L1":"FF123456"}',
      );

      await reload();

      expect(state().lightColorPoolThemeId, 'macchiato');
      expect(state().darkColorPoolThemeId, 'macchiato');
      expect(state().lightColorPool, scheduleDefaultLightColorPool);
      expect(state().darkColorPool, scheduleDefaultDarkColorPool);
      expect(state().courseColorOverrides['id:L1'], const Color(0xFF123456));

      // 迁移在 microtask 中落盘。
      await Future<void>.delayed(Duration.zero);

      final prefs = PrefsService.instance;
      expect(
        prefs.getInt(PrefsKeys.SCHEDULE_COLOR_POOL_SCHEMA),
        ScheduleStyleStore.colorPoolSchema,
      );
      expect(
        prefs.getString(PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID),
        'macchiato',
      );
      expect(
        prefs.getString(PrefsKeys.SCHEDULE_DARK_COLOR_POOL_THEME_ID),
        'macchiato',
      );
      expect(prefs.getStringList(PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL), isNull);
      expect(prefs.getStringList(PrefsKeys.SCHEDULE_DARK_COLOR_POOL), isNull);
      expect(
        prefs.getString(PrefsKeys.SCHEDULE_COURSE_COLOR_OVERRIDES),
        '{"id:L1":"FF123456"}',
      );
    });

    test('should preserve custom themes during schema 3 migration', () async {
      await PrefsService.instance.setInt(
        PrefsKeys.SCHEDULE_COLOR_POOL_SCHEMA,
        2,
      );
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES,
        jsonEncode(<String, Object>{
          'custom:keep': <String, Object>{
            'name': '保留主题',
            'colors': <String>['FF112233'],
          },
        }),
      );
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID,
        'custom:keep',
      );
      await PrefsService.instance.setString(
        PrefsKeys.SCHEDULE_DARK_COLOR_POOL_THEME_ID,
        'frappe',
      );

      await reload();

      expect(state().lightColorPoolThemeId, 'macchiato');
      expect(state().darkColorPoolThemeId, 'macchiato');
      expect(state().customColorPoolThemes['custom:keep']?.name, '保留主题');

      await Future<void>.delayed(Duration.zero);

      final prefs = PrefsService.instance;
      expect(
        prefs.getInt(PrefsKeys.SCHEDULE_COLOR_POOL_SCHEMA),
        ScheduleStyleStore.colorPoolSchema,
      );
      expect(
        prefs.getString(PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID),
        'macchiato',
      );
      expect(
        prefs.getString(PrefsKeys.SCHEDULE_DARK_COLOR_POOL_THEME_ID),
        'macchiato',
      );
      expect(
        prefs.getString(PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES),
        contains('保留主题'),
      );
    });
  });
}
