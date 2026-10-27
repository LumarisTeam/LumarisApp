import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/map_notifier.dart';
import 'package:ios_club_app/state/map_state.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/pages/campus_map_page/campus_map_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 已登录用户，避免地图页落到游客占位分支。
class _LoggedInUserStore extends UserStore {
  @override
  UserState build() => const UserState(isLogin: true);
}

/// 地图数据与定位在组件测试里没有真实来源，直接给空状态即可。
class _FakeMapNotifier extends MapNotifier {
  @override
  MapState build() => const MapState();

  @override
  Future<void> checkLocationPermission({
    bool openSettingsOnFailure = false,
  }) async {}

  @override
  Future<void> fetchCampusPOIs() async {}
}

Future<void> _pumpApp(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userStoreProvider.overrideWith(_LoggedInUserStore.new),
        mapNotifierProvider.overrideWith(_FakeMapNotifier.new),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _openCampusMap(WidgetTester tester) async {
  AppRouter.push(AppRoutes.campusMap);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDir;

  setUpAll(() async {
    // 首页会读取课表缓存，测试里用临时目录初始化 Hive 代替 path_provider。
    hiveDir = await Directory.systemTemp.createTemp('campus_map_test_');
    Hive.init(hiveDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDir.delete(recursive: true);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
    AppRouter.go(AppRoutes.home);
  });

  testWidgets('should_show_back_button_when_map_opened_in_wide_tablet_layout', (
    tester,
  ) async {
    await _pumpApp(tester, const Size(1200, 800));
    await _openCampusMap(tester);

    expect(find.byType(CampusMapPage), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(CampusMapPage), findsNothing);
  });

  testWidgets(
    'should_show_back_button_in_narrow_tablet_layout_inside_top_panel',
    (tester) async {
      // 窗口宽度按平板处理，但扣除 NavigationRail 后地图区不足 700，
      // 会走窄屏布局（顶部搜索面板）。
      await _pumpApp(tester, const Size(700, 900));
      await _openCampusMap(tester);

      expect(find.byType(CampusMapPage), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(CampusMapPage), findsNothing);
    },
  );

  testWidgets('should_not_show_back_button_on_phone_layout', (tester) async {
    // 直接渲染地图页，避免首页/个人中心在小屏测试尺寸下的既有布局溢出干扰。
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userStoreProvider.overrideWith(_LoggedInUserStore.new),
          mapNotifierProvider.overrideWith(_FakeMapNotifier.new),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: const CampusMapPage(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(CampusMapPage), findsOneWidget);
    // 手机端继续依赖系统返回手势，地图内不额外增加返回键。
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
  });
}
