import 'dart:convert';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/state/schedule_style_store.dart';
import 'package:ios_club_app/ui/pages/schedule_list_page/schedule_personalization_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeScheduleStore extends ScheduleStore {
  @override
  ScheduleState build() => const ScheduleState(
    isLoading: false,
    currentWeek: 1,
    maxWeek: 20,
    currentPage: 1,
    height: 55,
  );
}

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

  testWidgets('should render personalization sections and preview', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [scheduleStoreProvider.overrideWith(_FakeScheduleStore.new)],
    );
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
          home: const SchedulePersonalizationPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('个性化配置'), findsOneWidget);
    expect(find.text('界面显示'), findsOneWidget);
    expect(find.text('网格尺寸'), findsOneWidget);
    expect(find.text('课程块配置'), findsOneWidget);
    expect(find.text('浅色模式颜色池'), findsOneWidget);
    expect(find.text('深色模式颜色池'), findsOneWidget);
    expect(find.text('Macchiato'), findsNWidgets(2));
    expect(find.text('课表背景壁纸 · 浅色模式'), findsOneWidget);
    expect(find.text('课表背景壁纸 · 深色模式'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('should lay out without overflow on a phone-sized screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [scheduleStoreProvider.overrideWith(_FakeScheduleStore.new)],
    );
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
          home: const SchedulePersonalizationPage(),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('should open the color picker from a custom pool circle', (
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

    final container = ProviderContainer(
      overrides: [scheduleStoreProvider.overrideWith(_FakeScheduleStore.new)],
    );
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
          home: const SchedulePersonalizationPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('测试主题'), findsOneWidget);

    final circle = find.byKey(const ValueKey('schedule-color-pool-light-0'));
    await tester.ensureVisible(circle);
    await tester.pumpAndSettle();
    await tester.tap(circle);
    await tester.pumpAndSettle();

    expect(find.text('H'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('should open the numeric input dialog from a slider value', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [scheduleStoreProvider.overrideWith(_FakeScheduleStore.new)],
    );
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
          home: const SchedulePersonalizationPage(),
        ),
      ),
    );
    await tester.pump();

    final value = find.text('55');
    await tester.ensureVisible(value);
    await tester.pumpAndSettle();
    await tester.tap(value);
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoTextField), findsOneWidget);
    expect(find.text('确认'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('should show the reset confirmation dialog', (tester) async {
    final container = ProviderContainer(
      overrides: [scheduleStoreProvider.overrideWith(_FakeScheduleStore.new)],
    );
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
          home: const SchedulePersonalizationPage(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('恢复默认样式设置'));
    await tester.pumpAndSettle();

    expect(find.text('恢复默认样式'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
