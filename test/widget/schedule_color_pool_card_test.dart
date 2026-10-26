import 'dart:convert';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/schedule_style_store.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_color_pool_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();

    final prefs = PrefsService.instance;
    for (final key in <String>[
      PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID,
      PrefsKeys.SCHEDULE_DARK_COLOR_POOL_THEME_ID,
      PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES,
      PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL,
      PrefsKeys.SCHEDULE_DARK_COLOR_POOL,
    ]) {
      await prefs.remove(key);
    }
    await prefs.setInt(
      PrefsKeys.SCHEDULE_COLOR_POOL_SCHEMA,
      ScheduleStyleStore.colorPoolSchema,
    );
  });

  Future<ProviderContainer> pumpCard(
    WidgetTester tester, {
    bool isDarkPool = false,
  }) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: McThemeData.materialTheme(McColors.light),
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 380,
                child: ScheduleColorPoolCard(
                  isDarkPool: isDarkPool,
                  title: isDarkPool ? '深色模式颜色池' : '浅色模式颜色池',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return container;
  }

  Future<void> expandEditor(WidgetTester tester, {bool dark = false}) async {
    final suffix = dark ? 'dark' : 'light';
    await tester.tap(
      find.byKey(ValueKey('schedule-color-pool-edit-toggle-$suffix')),
    );
    await tester.pumpAndSettle();
  }

  Future<void> closePicker(WidgetTester tester) async {
    Navigator.of(tester.element(find.byType(ScheduleColorPoolCard))).pop();
    await tester.pumpAndSettle();
  }

  testWidgets('should show the built-in theme as read-only', (tester) async {
    await pumpCard(tester);

    expect(find.text('Macchiato'), findsOneWidget);
    expect(find.text('14 种颜色'), findsOneWidget);

    await expandEditor(tester);

    expect(find.text('内置主题为只读，复制为自定义主题后可编辑。'), findsOneWidget);
    expect(find.text('复制为自定义主题'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('schedule-color-pool-light-0')));
    await tester.pumpAndSettle();

    expect(find.text('H'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('should list and apply built-in themes', (tester) async {
    final container = await pumpCard(tester);

    await tester.tap(
      find.byKey(const ValueKey('schedule-color-theme-selector-light')),
    );
    await tester.pumpAndSettle();

    for (final id in <String>['latte', 'macchiato']) {
      expect(
        find.byKey(ValueKey('schedule-color-theme-option-$id')),
        findsOneWidget,
      );
    }
    for (final removedId in <String>['frappe', 'mocha']) {
      expect(
        find.byKey(ValueKey('schedule-color-theme-option-$removedId')),
        findsNothing,
      );
    }
    expect(
      find.byKey(const ValueKey('schedule-color-theme-new')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('schedule-color-theme-option-latte')),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(scheduleStyleStoreProvider).lightColorPoolThemeId,
      'latte',
    );
    expect(find.text('Latte'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('should copy a built-in theme to a named custom theme', (
    tester,
  ) async {
    final container = await pumpCard(tester);
    await expandEditor(tester);

    await tester.tap(
      find.byKey(const ValueKey('schedule-color-theme-copy-light')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CupertinoTextField), '我的主题');
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    final style = container.read(scheduleStyleStoreProvider);
    expect(style.customColorPoolThemes, hasLength(1));
    expect(style.lightColorPoolThemeId, startsWith('custom:'));
    expect(style.lightColorPool, isNotEmpty);
    expect(find.text('我的主题'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('schedule-color-pool-light-edit-0')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('should edit, add, rename and delete a custom theme', (
    tester,
  ) async {
    await PrefsService.instance.setString(
      PrefsKeys.SCHEDULE_CUSTOM_COLOR_POOL_THEMES,
      jsonEncode(<String, Object>{
        'custom:test': <String, Object>{
          'name': '测试主题',
          'colors': <String>['FF112233', 'FF445566'],
        },
      }),
    );
    await PrefsService.instance.setString(
      PrefsKeys.SCHEDULE_LIGHT_COLOR_POOL_THEME_ID,
      'custom:test',
    );

    final container = await pumpCard(tester);
    await expandEditor(tester);

    await tester.tap(
      find.byKey(const ValueKey('schedule-color-pool-light-edit-0')),
    );
    await tester.pumpAndSettle();
    expect(find.text('H'), findsOneWidget);
    await closePicker(tester);

    await tester.tap(
      find.byKey(const ValueKey('schedule-color-pool-light-add')),
    );
    await tester.pumpAndSettle();
    expect(
      container
          .read(scheduleStyleStoreProvider)
          .customColorPoolThemes['custom:test']
          ?.colors
          .length,
      3,
    );
    expect(find.text('H'), findsOneWidget);
    await closePicker(tester);

    await tester.tap(
      find.byKey(const ValueKey('schedule-color-pool-light-delete-0')),
    );
    await tester.pumpAndSettle();
    expect(
      container
          .read(scheduleStyleStoreProvider)
          .customColorPoolThemes['custom:test']
          ?.colors
          .length,
      2,
    );

    await tester.tap(
      find.byKey(const ValueKey('schedule-color-theme-rename-light')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), '新名字');
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    expect(
      container
          .read(scheduleStyleStoreProvider)
          .customColorPoolThemes['custom:test']
          ?.name,
      '新名字',
    );
    expect(find.text('新名字'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('schedule-color-theme-delete-light')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    final style = container.read(scheduleStyleStoreProvider);
    expect(style.customColorPoolThemes, isEmpty);
    expect(style.lightColorPoolThemeId, 'macchiato');
    expect(find.text('Macchiato'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('should prevent removing the last custom color', (tester) async {
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

    final container = await pumpCard(tester);
    await expandEditor(tester);

    expect(find.text('至少保留一种颜色'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('schedule-color-pool-light-delete-0')),
    );
    await tester.pumpAndSettle();

    expect(
      container
          .read(scheduleStyleStoreProvider)
          .customColorPoolThemes['custom:one']
          ?.colors
          .length,
      1,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('should render a 32-color custom theme without overflow', (
    tester,
  ) async {
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

    await pumpCard(tester);
    await expandEditor(tester);

    expect(find.text('最多 32 种颜色'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('schedule-color-pool-light-add')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
