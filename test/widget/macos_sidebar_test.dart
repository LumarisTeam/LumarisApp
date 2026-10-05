import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/sidebar_destination.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/platform/macos/macos_sidebar.dart';
import 'package:ios_club_app/platform/macos/macos_shell.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 这些常量是从 macos_ui 2.2.2 复刻过来的，一旦漂移 macOS 侧边栏就会变样。
const double _expectedItemHeight = 34;
const Color _expectedSelectionLight = Color.fromRGBO(9, 129, 255, 0.749);
const Color _expectedSelectionDark = Color.fromRGBO(22, 105, 229, 0.749);
const Color _expectedLabelLight = Color.fromRGBO(0, 0, 0, 0.85);
const Color _expectedLabelDark = Color.fromRGBO(255, 255, 255, 0.85);

const List<SidebarDestination> _items = [
  SidebarDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: '首页',
  ),
  SidebarDestination(
    icon: Icons.schedule_outlined,
    selectedIcon: Icons.schedule,
    label: '课表',
  ),
  SidebarDestination(
    icon: Icons.map_outlined,
    selectedIcon: Icons.map,
    label: '地图',
  ),
];

Widget _wrap(Widget child, {ThemeMode themeMode = ThemeMode.light}) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ClubTheme.lightTheme(),
      darkTheme: ClubTheme.darkTheme(),
      themeMode: themeMode,
      home: Scaffold(body: child),
    ),
  );
}

/// 离标签最近的那个 Container，也就是侧边栏导航项本身。
Finder _itemContainer(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(Container)).first;

ShapeDecoration _itemDecoration(WidgetTester tester, String label) {
  final container = tester.widget<Container>(_itemContainer(label));
  return container.decoration! as ShapeDecoration;
}

Icon _itemIcon(WidgetTester tester, String label) {
  return tester.widget<Icon>(
    find.descendant(of: _itemContainer(label), matching: find.byType(Icon)),
  );
}

Color? _labelColor(WidgetTester tester, String label) {
  return tester.widget<Text>(find.text(label)).style?.color;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
    await PrefsService.instance.clear();
  });

  group('MacosSidebar', () {
    testWidgets('should render one item per destination at the ported height', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MacosSidebar(items: _items, selectedIndex: 0, onItemSelected: (_) {}),
        ),
      );

      for (final item in _items) {
        expect(_itemContainer(item.label), findsOneWidget);
        expect(
          tester.getSize(_itemContainer(item.label)).height,
          _expectedItemHeight,
        );
      }
    });

    testWidgets('should highlight only the selected item in light mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MacosSidebar(items: _items, selectedIndex: 0, onItemSelected: (_) {}),
        ),
      );

      expect(_itemDecoration(tester, '首页').color, _expectedSelectionLight);
      expect(_itemDecoration(tester, '课表').color, Colors.transparent);

      expect(_itemIcon(tester, '首页').color, const Color(0xFFFFFFFF));
      expect(_itemIcon(tester, '课表').color, ClubColors.light.primary);

      expect(_labelColor(tester, '首页'), const Color(0xFFFFFFFF));
      expect(_labelColor(tester, '课表'), _expectedLabelLight);
    });

    testWidgets('should use the dark selection and label colors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MacosSidebar(items: _items, selectedIndex: 1, onItemSelected: (_) {}),
          themeMode: ThemeMode.dark,
        ),
      );

      expect(_itemDecoration(tester, '课表').color, _expectedSelectionDark);
      expect(_itemDecoration(tester, '首页').color, Colors.transparent);
      expect(_labelColor(tester, '首页'), _expectedLabelDark);
    });

    testWidgets('should render the bottom user tile', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MacosSidebar(items: _items, selectedIndex: 0, onItemSelected: (_) {}),
        ),
      );

      expect(find.byIcon(CupertinoIcons.person_fill), findsOneWidget);
    });
  });

  group('MacosShell', () {
    testWidgets('should lay the sidebar out next to the child at 220 wide', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MacosShell(
            items: _items,
            selectedIndex: 0,
            onItemSelected: (_) {},
            child: const Text('content'),
          ),
        ),
      );

      expect(tester.getSize(find.byType(MacosSidebar)).width, 220);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('should report the tapped index', (WidgetTester tester) async {
      var tapped = -1;
      await tester.pumpWidget(
        _wrap(
          MacosShell(
            items: _items,
            selectedIndex: 0,
            onItemSelected: (index) => tapped = index,
            child: const Text('content'),
          ),
        ),
      );

      await tester.tap(find.text('地图'));
      await tester.pump();

      expect(tapped, 2);
    });
  });
}
