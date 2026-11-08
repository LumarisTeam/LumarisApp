import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/sidebar_destination.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/platform/macos/macos_sidebar.dart';
import 'package:ios_club_app/platform/macos/macos_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 这些常量是从 macos_ui 2.2.2 复刻过来的，一旦漂移 macOS 侧边栏就会变样。
const double _expectedItemHeight = 34;
const Color _expectedSelectionLight = Color.fromRGBO(9, 129, 255, 0.749);
const Color _expectedSelectionDark = Color.fromRGBO(22, 105, 229, 0.749);
const Color _expectedLabelLight = Color.fromRGBO(0, 0, 0, 0.85);
const Color _expectedLabelDark = Color.fromRGBO(255, 255, 255, 0.85);

const List<SidebarDestination> _items = [
  SidebarDestination(
    icon: CupertinoIcons.house,
    selectedIcon: CupertinoIcons.house_fill,
    label: '首页',
  ),
  SidebarDestination(
    icon: CupertinoIcons.clock,
    selectedIcon: CupertinoIcons.clock_fill,
    label: '课表',
  ),
  SidebarDestination(
    icon: CupertinoIcons.map,
    selectedIcon: CupertinoIcons.map_fill,
    label: '地图',
  ),
];

Widget _wrap(Widget child, {ThemeMode themeMode = ThemeMode.light}) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: McThemeData.materialTheme(McColors.light),
      darkTheme: McThemeData.materialTheme(McColors.dark),
      themeMode: themeMode,
      home: child,
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

/// [Text] 合并 [DefaultTextStyle] 之后真正用于排版的那个样式。
TextStyle _resolvedStyle(WidgetTester tester, String label) {
  final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
  return (paragraph.text as TextSpan).style!;
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
      expect(_itemIcon(tester, '课表').color, McColors.light.primary);

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

    testWidgets('should not inherit the MaterialApp error text style', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MacosSidebar(items: _items, selectedIndex: 0, onItemSelected: (_) {}),
        ),
      );

      // MaterialApp 的兜底 DefaultTextStyle 带黄色双下划线，专门提醒开发者
      // 文字缺少 Material 祖先。侧边栏不含 Scaffold，必须自带 DefaultTextStyle。
      final style = _resolvedStyle(tester, '首页');
      expect(style.decoration, isNot(TextDecoration.underline));
      expect(style.fontSize, 13);
      expect(style.fontFamily, '.AppleSystemUIFont');
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
    testWidgets('should_drag_and_zoom_window_when_header_background_is_used', (
      tester,
    ) async {
      const channel = MethodChannel('window_manager');
      final calls = <String>[];
      var maximized = false;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call.method);
        switch (call.method) {
          case 'isFocused':
            return true;
          case 'isMaximized':
            return maximized;
          case 'maximize':
            maximized = true;
            return null;
          case 'unmaximize':
            maximized = false;
            return null;
          default:
            return null;
        }
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
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
      await tester.dragFrom(const Offset(600, 26), const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(calls, contains('startDragging'));
      Future<void> doubleTapHeader() async {
        await tester.tapAt(const Offset(600, 26));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tapAt(const Offset(600, 26));
        await tester.pumpAndSettle();
      }

      await doubleTapHeader();
      expect(maximized, isTrue);
      await doubleTapHeader();
      expect(maximized, isFalse);
      expect(calls, containsAllInOrder(['maximize', 'unmaximize']));
    });

    testWidgets(
      'should_show_default_toolbar_and_toggle_its_owned_sidebar_controller',
      (tester) async {
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
        expect(find.text('光序'), findsOneWidget);
        final toolbar = find.byType(McToolBar);
        expect(toolbar, findsOneWidget);
        expect(tester.getTopLeft(toolbar), Offset.zero);
        expect(tester.getSize(toolbar).width, 800);
        expect(tester.getTopLeft(find.byType(MacosSidebar)).dy, 52);
        final buttons = tester
            .widgetList<McToolBarIconButton>(
              find.descendant(
                of: toolbar,
                matching: find.byType(McToolBarIconButton),
              ),
            )
            .toList();
        expect(buttons, hasLength(2));
        expect(buttons[1].onPressed, isNull);
        final toggle = find.byIcon(CupertinoIcons.sidebar_left);
        expect(tester.getCenter(toggle).dx, greaterThan(80));
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        expect(find.byType(MacosSidebar), findsNothing);
        expect(
          tester
              .widget<McToolBarIconButton>(
                find
                    .ancestor(
                      of: toggle,
                      matching: find.byType(McToolBarIconButton),
                    )
                    .first,
              )
              .label,
          '展开侧边栏',
        );
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        expect(find.byType(MacosSidebar), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

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

    testWidgets('should_toggle_sidebar_when_toolbar_control_is_activated', (
      tester,
    ) async {
      final controller = McSidebarController();
      await tester.pumpWidget(
        _wrap(
          MacosShell(
            items: _items,
            selectedIndex: 0,
            onItemSelected: (_) {},
            controller: controller,
            toolbar: McToolBar(
              leading: McToolBarIconButton(
                label: '切换侧边栏',
                icon: const Icon(CupertinoIcons.sidebar_left),
                onPressed: controller.toggle,
              ),
              title: const Text('工具栏标题'),
            ),
            child: const Text('content'),
          ),
        ),
      );
      expect(find.byType(MacosSidebar), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.sidebar_left));
      await tester.pumpAndSettle();
      expect(find.byType(MacosSidebar), findsNothing);
      expect(find.text('工具栏标题'), findsOneWidget);
      expect(find.text('content'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
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
