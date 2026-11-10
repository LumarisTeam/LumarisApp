import 'dart:io';

import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
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
import 'package:latlong2/latlong.dart';
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
  Future<void> refreshLocation() async {}

  @override
  Future<void> fetchCampusPOIs() async {}
}

class _PollingMapNotifier extends _FakeMapNotifier {
  static int refreshCount = 0;

  @override
  Future<void> refreshLocation() async {
    refreshCount++;
    state = state.copyWith(currentLocation: LatLng(34.25, 108.98));
  }
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

  testWidgets('should_update_location_without_moving_map_when_polling', (
    tester,
  ) async {
    _PollingMapNotifier.refreshCount = 0;
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
      overrides: [
        userStoreProvider.overrideWith(_LoggedInUserStore.new),
        mapNotifierProvider.overrideWith(_PollingMapNotifier.new),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
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
    await tester.pump();
    final controller = tester
        .widget<FlutterMap>(find.byType(FlutterMap))
        .mapController!;
    final center = controller.camera.center;
    await tester.pump(const Duration(milliseconds: 1499));
    expect(_PollingMapNotifier.refreshCount, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(_PollingMapNotifier.refreshCount, 1);
    expect(
      container.read(mapNotifierProvider).currentLocation,
      const LatLng(34.25, 108.98),
    );
    expect(controller.camera.center, center);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
    expect(_PollingMapNotifier.refreshCount, 1);
  });

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
    expect(find.byIcon(CupertinoIcons.arrow_left), findsOneWidget);

    final back = find.byIcon(CupertinoIcons.arrow_left);
    final backPosition = tester.getCenter(back);
    final search = find.byType(TextField);
    final sidebarPosition = tester.getTopLeft(search);
    final l10n = AppLocalizations.of(tester.element(back));
    await tester.tap(find.byTooltip(l10n.collapseSidebar));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.getTopLeft(search).dx, lessThan(sidebarPosition.dx));
    expect(tester.getCenter(back), backPosition);
    await tester.tap(find.byTooltip(l10n.expandSidebar));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.getTopLeft(search), sidebarPosition);
    expect(tester.getCenter(back), backPosition);

    await tester.tap(back);
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
      expect(find.byIcon(CupertinoIcons.arrow_left), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.arrow_left));
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
    expect(find.byIcon(CupertinoIcons.arrow_left), findsNothing);
  });
}
