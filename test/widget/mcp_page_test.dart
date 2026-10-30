import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ios_club_app/features/basic/services/basic_http_client.dart';
import 'package:ios_club_app/features/mcp/mcp_constants.dart';
import 'package:ios_club_app/features/mcp/models/mcp_probe_result.dart';
import 'package:ios_club_app/features/mcp/models/mcp_tool.dart';
import 'package:ios_club_app/features/mcp/services/mcp_config_generator.dart';
import 'package:ios_club_app/features/mcp/services/mcp_probe_service.dart';
import 'package:ios_club_app/features/mcp/services/mcp_token_store.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/ui/pages/mcp_page/mcp_page.dart';

/// 成功探测的固定结果，供连接、布局与暗色测试复用。
const McpProbeResult _successResult = McpProbeResult(
  serverName: 'luminous-mcp-server',
  serverVersion: '1.0.0',
  protocolVersion: '2025-06-18',
  tools: <McpTool>[
    McpTool(name: 'query_school', description: '学校详情'),
    McpTool(name: 'query_schedule', description: '课程表'),
  ],
);

class _FakeTokenStore extends McpTokenStore {
  _FakeTokenStore([this.value]);

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
  _FakeProbeService(this.result, {this.gate})
    : super(client: BasicHttpClient());

  final McpProbeResult result;

  /// 非空时探测会挂起，直到测试完成它，用于断言“探测中”状态。
  final Completer<void>? gate;

  String? lastToken;

  @override
  Future<McpProbeResult> probe({String? token}) async {
    lastToken = token;
    if (gate != null) {
      await gate!.future;
    }
    return result;
  }
}

ThemeData get _lightTheme =>
    McThemeData.materialTheme(McColors.light, locale: const Locale('en'));

ThemeData get _darkTheme =>
    McThemeData.materialTheme(McColors.dark, locale: const Locale('en'));

Widget _buildApp(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    theme: theme ?? _lightTheme,
    home: child,
  );
}

Future<void> _pumpPage(
  WidgetTester tester, {
  McpTokenStore? tokenStore,
  McpProbeService? probeService,
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    _buildApp(
      McpPage(
        tokenStore: tokenStore ?? _FakeTokenStore(),
        probeService: probeService ?? _FakeProbeService(const McpProbeResult()),
      ),
      theme: theme,
    ),
  );
  await tester.pumpAndSettle();
}

/// McFeedback 的 toast 由 3 秒定时器移除，测试结束前必须把它排空。
Future<void> _drainFeedback(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

Map<String, dynamic> _mockClipboard() {
  final clipboard = <String, dynamic>{};
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'Clipboard.setData') {
      clipboard.addAll(Map<String, dynamic>.from(call.arguments as Map));
    }
    return null;
  });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return clipboard;
}

CupertinoButton _buttonWithText(WidgetTester tester, String text) {
  return tester.widget<CupertinoButton>(
    find.widgetWithText(CupertinoButton, text),
  );
}

/// 确认弹窗里的按钮——与页面里同名的按钮区分开。
///
/// 弹窗是插入在页面之上的路由，遍历顺序在页面之后，因此同名按钮取最后一个。
Finder _dialogButton(String label) {
  return find.widgetWithText(CupertinoButton, label).last;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('should_render_endpoint_and_empty_token_status_when_page_opens', (
    tester,
  ) async {
    await _pumpPage(tester);

    expect(find.text('Lumaris MCP'), findsOneWidget);
    expect(find.textContaining(McpConstants.endpoint), findsWidgets);
    expect(find.text('Streamable HTTP · POST'), findsOneWidget);
    expect(find.text('ACCESS TOKEN'), findsOneWidget);
    expect(find.text('No token set'), findsOneWidget);
    expect(find.text('Test connection'), findsOneWidget);
    expect(find.text('Copy JSON config'), findsOneWidget);
  });

  testWidgets('should_update_json_preview_when_token_text_changes', (
    tester,
  ) async {
    await _pumpPage(tester);

    final field = find.byType(CupertinoTextField);

    await tester.enterText(field, 'test-token');
    await tester.pump();

    expect(
      find.textContaining('"Authorization": "Bearer test-token"'),
      findsWidgets,
    );

    await tester.enterText(field, '');
    await tester.pump();

    expect(find.textContaining('"Authorization"'), findsNothing);
  });

  testWidgets(
    'should_transition_token_status_from_unset_to_unsaved_to_saved_when_edited',
    (tester) async {
      final store = _FakeTokenStore();

      await _pumpPage(tester, tokenStore: store);

      expect(find.text('No token set'), findsOneWidget);
      expect(_buttonWithText(tester, 'Save').onPressed, isNull);
      expect(_buttonWithText(tester, 'Delete').onPressed, isNull);

      // 保存按钮禁用时点击不产生任何副作用。
      await tester.ensureVisible(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(store.value, isNull);
      expect(find.text('No token set'), findsOneWidget);

      await tester.enterText(find.byType(CupertinoTextField), 'secret-token');
      await tester.pump();

      expect(find.text('Not saved'), findsOneWidget);
      expect(_buttonWithText(tester, 'Save').onPressed, isNotNull);
      expect(_buttonWithText(tester, 'Delete').onPressed, isNotNull);

      // 输入会聚焦输入框并触发滚动，重新定位按钮后再点击。
      await tester.ensureVisible(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(store.value, 'secret-token');
      expect(find.text('Token saved'), findsWidgets);
      // 已保存值与输入一致，保存按钮重新禁用。
      expect(_buttonWithText(tester, 'Save').onPressed, isNull);

      await _drainFeedback(tester);
      expect(find.text('Token saved'), findsOneWidget);
    },
  );

  testWidgets('should_save_normalized_token_and_show_toast_when_save_tapped', (
    tester,
  ) async {
    final store = _FakeTokenStore();

    await _pumpPage(tester, tokenStore: store);

    await tester.enterText(find.byType(CupertinoTextField), '  Bearer abc\n');
    await tester.pump();

    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(store.value, 'abc');
    expect(find.text('Token saved'), findsWidgets);

    await _drainFeedback(tester);
  });

  testWidgets('should_toggle_token_visibility_when_eye_button_tapped', (
    tester,
  ) async {
    await _pumpPage(tester);

    expect(find.byTooltip('Show token'), findsOneWidget);
    expect(
      tester
          .widget<CupertinoTextField>(find.byType(CupertinoTextField))
          .obscureText,
      isTrue,
    );

    await tester.tap(find.byIcon(CupertinoIcons.eye));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<CupertinoTextField>(find.byType(CupertinoTextField))
          .obscureText,
      isFalse,
    );
    expect(find.byTooltip('Hide token'), findsOneWidget);
  });

  testWidgets(
    'should_show_progress_then_results_and_tools_when_connection_tested',
    (tester) async {
      final gate = Completer<void>();
      final probe = _FakeProbeService(_successResult, gate: gate);

      await _pumpPage(
        tester,
        tokenStore: _FakeTokenStore('abc'),
        probeService: probe,
      );

      await tester.ensureVisible(find.text('Test connection'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test connection'));
      await tester.pump();

      expect(find.text('Testing connection…'), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();

      expect(probe.lastToken, 'abc');
      expect(find.text('Connection successful'), findsOneWidget);
      expect(find.textContaining('luminous-mcp-server 1.0.0'), findsOneWidget);
      expect(find.text('Available tools (2)'), findsOneWidget);
      expect(find.text('query_school'), findsOneWidget);
      expect(find.text('学校详情'), findsOneWidget);
      expect(find.text('query_schedule'), findsOneWidget);
    },
  );

  testWidgets('should_copy_json_config_when_copy_button_tapped', (
    tester,
  ) async {
    final clipboard = _mockClipboard();

    await _pumpPage(tester, tokenStore: _FakeTokenStore('abc'));

    await tester.ensureVisible(find.text('Copy JSON config'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy JSON config'));
    await tester.pumpAndSettle();

    expect(clipboard['text'], McpConfigGenerator.buildJson('abc'));

    await _drainFeedback(tester);
  });

  testWidgets(
    'should_switch_preview_to_cli_when_claude_code_segment_selected',
    (tester) async {
      await _pumpPage(tester, tokenStore: _FakeTokenStore('abc'));

      expect(find.textContaining('"mcpServers"'), findsOneWidget);
      expect(find.text('Copy JSON config'), findsOneWidget);

      await tester.ensureVisible(find.text('Claude Code'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Claude Code'));
      await tester.pumpAndSettle();

      expect(find.textContaining('"mcpServers"'), findsNothing);
      expect(
        find.textContaining('claude mcp add --transport http luminous'),
        findsOneWidget,
      );
      expect(find.text('Copy Claude Code command'), findsOneWidget);
    },
  );

  testWidgets('should_copy_cli_command_when_claude_code_copy_tapped', (
    tester,
  ) async {
    final clipboard = _mockClipboard();

    await _pumpPage(tester, tokenStore: _FakeTokenStore('abc'));

    await tester.ensureVisible(find.text('Claude Code'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Claude Code'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Copy Claude Code command'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy Claude Code command'));
    await tester.pumpAndSettle();

    expect(clipboard['text'], McpConfigGenerator.buildClaudeCodeCommand('abc'));

    await _drainFeedback(tester);
  });

  testWidgets('should_clear_token_and_empty_field_when_delete_confirmed', (
    tester,
  ) async {
    final store = _FakeTokenStore('abc');

    await _pumpPage(tester, tokenStore: store);

    expect(find.text('Token saved'), findsOneWidget);

    await tester.ensureVisible(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(McButton, 'Delete'));
    await tester.pumpAndSettle();

    // 弹窗标题是令牌小节名，正文解释将会发生什么。
    expect(find.text('Access token'), findsOneWidget);
    expect(find.text('Clear the saved token?'), findsOneWidget);
    // 页面与弹窗各有一个 Delete。
    expect(find.text('Delete'), findsNWidgets(2));

    await tester.tap(_dialogButton('Delete'));
    await tester.pumpAndSettle();

    expect(store.value, isNull);
    expect(
      tester
          .widget<CupertinoTextField>(find.byType(CupertinoTextField))
          .controller
          ?.text,
      '',
    );
    expect(find.text('Access token'), findsNothing);
    expect(find.text('No token set'), findsOneWidget);
    expect(_buttonWithText(tester, 'Delete').onPressed, isNull);
  });

  testWidgets('should_render_key_content_when_dark_theme_applied', (
    tester,
  ) async {
    await _pumpPage(
      tester,
      tokenStore: _FakeTokenStore('abc'),
      theme: _darkTheme,
    );

    final context = tester.element(find.byType(McpPage));
    final theme = Theme.of(context);

    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, McColors.dark.groupedBackground);
    expect(find.text('Lumaris MCP'), findsOneWidget);
    expect(find.text('Token saved'), findsOneWidget);
    expect(find.text('Test connection'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('should_not_overflow_when_rendered_at_320x640', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.reset);

    await _pumpPage(
      tester,
      tokenStore: _FakeTokenStore('abc'),
      probeService: _FakeProbeService(_successResult),
    );

    await tester.ensureVisible(find.text('Test connection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test connection'));
    await tester.pumpAndSettle();

    expect(find.text('Connection successful'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('should_not_overflow_when_rendered_at_800x1000', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1000);
    addTearDown(tester.view.reset);

    await _pumpPage(
      tester,
      tokenStore: _FakeTokenStore('abc'),
      probeService: _FakeProbeService(_successResult),
    );

    await tester.ensureVisible(find.text('Test connection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test connection'));
    await tester.pumpAndSettle();

    expect(find.text('Connection successful'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('should_not_overflow_when_text_scale_is_2x_at_393x852', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(393, 852);
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpPage(
      tester,
      tokenStore: _FakeTokenStore('abc'),
      probeService: _FakeProbeService(_successResult),
    );

    await tester.ensureVisible(find.text('Test connection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test connection'));
    await tester.pumpAndSettle();

    expect(find.text('Connection successful'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
