// Design preview harness: renders the real MCP page to PNG files under
// build/design/ so a designer can inspect light/dark/full-page shots.
//
// This file lives outside test/ on purpose: it is a throwaway rendering
// harness, not part of the test suite. Run it with:
//
//   export FLUTTER_ROOT=/Users/luckyfish/Documents/tools/flutter \
//     FLUTTER_ALREADY_LOCKED=true FLUTTER_SUPPRESS_ANALYTICS=true CI=true
//   DART=$FLUTTER_ROOT/bin/cache/dart-sdk/bin/dart
//   $DART $FLUTTER_ROOT/bin/cache/flutter_tools.snapshot test \
//     tool/preview/mcp_page_preview_test.dart
//
// It never mutates lib/; it only reads the real page and writes PNGs.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/basic/services/basic_http_client.dart';
import 'package:ios_club_app/features/mcp/models/mcp_probe_result.dart';
import 'package:ios_club_app/features/mcp/models/mcp_tool.dart';
import 'package:ios_club_app/features/mcp/services/mcp_config_generator.dart';
import 'package:ios_club_app/features/mcp/services/mcp_probe_service.dart';
import 'package:ios_club_app/features/mcp/services/mcp_token_store.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/ui/pages/mcp_page/mcp_page.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

/// iPhone 15 logical size.
const Size _phoneSize = Size(393, 852);

/// Tablet / desktop window size, to exercise the wide layout path.
const Size _wideSize = Size(800, 1000);

/// Tall surface used for the "entire page in one image" shot.
const double _tallHeight = 1700;

const double _phoneDpr = 3;
const double _wideDpr = 2;
const String _outputDir = 'build/design';

/// Family name the CJK font is registered under. The app themes receive this
/// same name, so every theme-driven [TextStyle] uses the loaded font.
const String _appFontFamily = 'PingFang SC';

/// Family name the monospace font is registered under. The page styles URLs,
/// JSON and tool names with `fontFamily: 'monospace'`.
const String _monospaceFamily = 'monospace';

/// System fonts that cover Latin + Simplified Chinese. PingFang is the real
/// iOS UI font; the rest are fallbacks for machines without it.
const List<String> _cjkFontCandidates = <String>[
  '/System/Library/AssetsV2/com_apple_MobileAsset_Font8/'
      '86ba2c91f017a3749571a82f2c6d890ac7ffb2fb.asset/AssetData/PingFang.ttc',
  '/System/Library/Fonts/Hiragino Sans GB.ttc',
  '/System/Library/AssetsV2/com_apple_MobileAsset_Font8/'
      '53fe5be564086fefc7523ccd0a31200acf92e0e5.asset/AssetData/STHEITI.ttf',
  '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
];

/// Menlo / SF Mono are the macOS monospace faces; the app renders code blocks
/// in its monospace family.
const List<String> _monospaceFontCandidates = <String>[
  '/System/Library/Fonts/SFNSMono.ttf',
  '/System/Library/Fonts/Menlo.ttc',
];

/// The fake probe payload the shots show.
const McpProbeResult _probeResult = McpProbeResult(
  serverName: 'luminous-mcp-server',
  serverVersion: '1.0.0',
  protocolVersion: '2025-06-18',
  tools: <McpTool>[
    McpTool(name: 'query_school', description: '学校详情'),
    McpTool(name: 'query_schedule', description: '课表查询'),
  ],
);

class _FakeTokenStore extends McpTokenStore {
  _FakeTokenStore(this.value);

  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<bool> save(String token) async {
    value = McpConfigGenerator.normalizeToken(token);
    return true;
  }

  @override
  Future<bool> clear() async {
    value = null;
    return true;
  }
}

class _FakeProbeService extends McpProbeService {
  _FakeProbeService(this.result) : super(client: BasicHttpClient());

  final McpProbeResult result;

  @override
  Future<McpProbeResult> probe({String? token}) async => result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadFonts);

  testWidgets('mcp_light.png - default page, token saved', (tester) async {
    _addTearDownReset(tester);
    _configureView(tester, _phoneSize, _phoneDpr);

    final boundaryKey = GlobalKey();
    await _pumpPage(tester, key: boundaryKey, themeMode: ThemeMode.light);
    await _capture(tester, boundaryKey, 'mcp_light.png', _phoneDpr);
  });

  // Tall surface: the first-run screenshot must show both the "未设置令牌"
  // chip at the top and the anonymous-test hint at the bottom of the page,
  // which do not fit in a 393x852 viewport at the same time.
  testWidgets('mcp_light_empty.png - first run, no token saved', (
    tester,
  ) async {
    _addTearDownReset(tester);
    _configureView(tester, const Size(393, _tallHeight), _phoneDpr);

    final boundaryKey = GlobalKey();
    await _pumpPage(
      tester,
      key: boundaryKey,
      themeMode: ThemeMode.light,
      token: null,
    );
    await _growToFit(tester);
    await _capture(tester, boundaryKey, 'mcp_light_empty.png', _phoneDpr);
  });

  testWidgets('mcp_light_tested.png - connection tested, tools visible', (
    tester,
  ) async {
    _addTearDownReset(tester);
    _configureView(tester, _phoneSize, _phoneDpr);

    final boundaryKey = GlobalKey();
    await _pumpPage(tester, key: boundaryKey, themeMode: ThemeMode.light);
    await _tapTestConnection(tester);
    await _revealTools(tester);
    await _capture(tester, boundaryKey, 'mcp_light_tested.png', _phoneDpr);
  });

  testWidgets('mcp_dark.png - default page in dark mode', (tester) async {
    _addTearDownReset(tester);
    _configureView(tester, _phoneSize, _phoneDpr);

    final boundaryKey = GlobalKey();
    await _pumpPage(tester, key: boundaryKey, themeMode: ThemeMode.dark);
    await _capture(tester, boundaryKey, 'mcp_dark.png', _phoneDpr);
  });

  testWidgets('mcp_wide.png - tablet width, content capped and centered', (
    tester,
  ) async {
    _addTearDownReset(tester);
    _configureView(tester, _wideSize, _wideDpr);

    final boundaryKey = GlobalKey();
    await _pumpPage(tester, key: boundaryKey, themeMode: ThemeMode.light);
    await _capture(tester, boundaryKey, 'mcp_wide.png', _wideDpr);
  });

  testWidgets('mcp_full.png - whole tested page on one tall surface', (
    tester,
  ) async {
    _addTearDownReset(tester);
    _configureView(tester, const Size(393, _tallHeight), _phoneDpr);

    final boundaryKey = GlobalKey();
    await _pumpPage(tester, key: boundaryKey, themeMode: ThemeMode.light);
    await _tapTestConnection(tester);
    await _growToFit(tester);

    await _capture(tester, boundaryKey, 'mcp_full.png', _phoneDpr);
  });
}

// ── Rendering helpers ────────────────────────────────────────────────────────

void _configureView(WidgetTester tester, Size logicalSize, double dpr) {
  tester.view.physicalSize = Size(
    logicalSize.width * dpr,
    logicalSize.height * dpr,
  );
  tester.view.devicePixelRatio = dpr;
}

void _addTearDownReset(WidgetTester tester) {
  addTearDown(tester.view.reset);
}

/// Grows the current surface until the whole page fits, so nothing is clipped.
Future<void> _growToFit(WidgetTester tester) async {
  final scrollable = tester.state<ScrollableState>(
    find.byType(Scrollable).first,
  );
  final overflow = scrollable.position.maxScrollExtent;
  if (overflow <= 0) {
    return;
  }

  final dpr = tester.view.devicePixelRatio;
  final current = tester.view.physicalSize / dpr;
  _configureView(
    tester,
    Size(current.width, current.height + overflow + 48),
    dpr,
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required GlobalKey key,
  required ThemeMode themeMode,
  String? token = 'demo-token',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: McThemeData.materialTheme(
        McColors.light,
        fontFamily: _appFontFamily,
        locale: const Locale('zh'),
      ),
      darkTheme: McThemeData.materialTheme(
        McColors.dark,
        fontFamily: _appFontFamily,
        locale: const Locale('zh'),
      ),
      themeMode: themeMode,
      locale: const Locale('zh'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: RepaintBoundary(
        key: key,
        child: McpPage(
          tokenStore: _FakeTokenStore(token),
          probeService: _FakeProbeService(_probeResult),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapTestConnection(WidgetTester tester) async {
  final button = _findTestConnectionButton();
  if (button.evaluate().isEmpty) {
    fail('Could not find the "Test connection" button on the MCP page.');
  }

  await tester.ensureVisible(button.first);
  await tester.pumpAndSettle();
  await tester.tap(button.first);
  await tester.pumpAndSettle();
}

Finder _findTestConnectionButton() {
  const List<String> labels = <String>[
    'Test connection',
    'Test Connection',
    '测试连接',
  ];
  for (final label in labels) {
    final finder = find.text(label);
    if (finder.evaluate().isNotEmpty) {
      return finder;
    }
  }
  return find.text('Test connection');
}

Future<void> _revealTools(WidgetTester tester) async {
  final lastTool = find.text('query_schedule');
  if (lastTool.evaluate().isNotEmpty) {
    await tester.ensureVisible(lastTool.first);
  } else {
    // Fallback: scroll to the bottom of the page.
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -600));
  }
  await tester.pumpAndSettle();
}

Future<void> _capture(
  WidgetTester tester,
  GlobalKey boundaryKey,
  String fileName,
  double dpr,
) async {
  await tester.pumpAndSettle();
  _applyAppFontToUnstyledText(tester);
  await tester.pump();

  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  if (boundary.debugNeedsPaint) {
    await tester.pump();
  }

  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: dpr);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        fail('PNG encoding failed for $fileName');
      }

      final directory = Directory(_outputDir);
      await directory.create(recursive: true);
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
      debugPrint(
        'Wrote ${file.absolute.path} (${image.width}x${image.height})',
      );
    } finally {
      image.dispose();
    }
  });
}

// ── Font fallback for text that resets DefaultTextStyle ─────────────────────

/// Re-lays out text that has no explicit font family with [_appFontFamily].
///
/// `flutter test` renders the app with `--use-test-fonts`: when a [TextStyle]
/// has no family, the engine uses its test default font (FlutterTest), which
/// has no CJK glyphs and no system fallback, so labels inside widgets that
/// replace [DefaultTextStyle] (notably `McButton`'s label) come out as tofu
/// boxes. Registering the CJK font under the test default family names does
/// not win over the engine's embedded test font, so this harness instead
/// patches the already-laid-out paragraphs just before capture. It only
/// touches render objects, never page source, and mirrors what the real app
/// gets from the system font fallback on device.
void _applyAppFontToUnstyledText(WidgetTester tester) {
  final richTexts = find.byType(RichText, skipOffstage: false).evaluate();
  for (final element in richTexts) {
    final renderObject = element.renderObject;
    if (renderObject is! RenderParagraph) {
      continue;
    }

    final span = renderObject.text;
    if (span is! TextSpan || span.style?.fontFamily != null) {
      continue;
    }

    renderObject.text = TextSpan(
      text: span.text,
      children: span.children,
      style: (span.style ?? const TextStyle()).copyWith(
        fontFamily: _appFontFamily,
      ),
      recognizer: span.recognizer,
      semanticsLabel: span.semanticsLabel,
      locale: span.locale,
      spellOut: span.spellOut,
    );
  }
}

// ── Font loading ─────────────────────────────────────────────────────────────

Future<void> _loadFonts() async {
  final cjkPath = _firstExisting(_cjkFontCandidates);
  if (cjkPath == null) {
    fail('No CJK system font found; text would render as tofu.');
  }
  await _loadFileFont(_appFontFamily, cjkPath);
  // `flutter test` runs the engine with --use-test-fonts, so text without an
  // explicit font family (e.g. text nested in McButton's own DefaultTextStyle)
  // falls back to the engine's test default font: "FlutterTest" in this SDK
  // (older SDKs: "Ahem"). That font has no CJK glyphs, so labels like 保存 /
  // 删除 / 测试连接 would render as tofu boxes. Registering the CJK font under
  // those default family names makes the fallback render real glyphs. On a
  // real device the same null-family text resolves to the system font.
  await _loadFileFont('FlutterTest', cjkPath);
  await _loadFileFont('Ahem', cjkPath);

  final monospacePath = _firstExisting(_monospaceFontCandidates);
  if (monospacePath == null) {
    fail('No monospace system font found.');
  }
  await _loadFileFont(_monospaceFamily, monospacePath);

  // Icons come from the test asset bundle (see build/unit_test_assets/
  // FontManifest.json); without them AppBar/copy icons render as boxes.
  await _loadBundledFont('MaterialIcons', 'fonts/MaterialIcons-Regular.otf');
  await _loadBundledFont(
    'packages/cupertino_icons/CupertinoIcons',
    'packages/cupertino_icons/assets/CupertinoIcons.ttf',
  );
}

String? _firstExisting(List<String> paths) {
  for (final path in paths) {
    if (File(path).existsSync()) {
      return path;
    }
  }
  return null;
}

Future<void> _loadFileFont(String family, String path) async {
  final bytes = await File(path).readAsBytes();
  final loader = FontLoader(family)
    ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  await loader.load();
  debugPrint('Loaded font family "$family" from $path');
}

Future<void> _loadBundledFont(String family, String asset) async {
  try {
    final loader = FontLoader(family)..addFont(rootBundle.load(asset));
    await loader.load();
  } catch (error) {
    // Icons are a nice-to-have for the preview; never fail the run for them.
    debugPrint('Could not load bundled font "$family" ($error).');
  }
}
