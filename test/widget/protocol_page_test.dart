import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/ui/pages/protocol_page/protocol_page.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

const _urlLauncherChannel = MethodChannel('plugins.flutter.io/url_launcher');

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ClubTheme.lightTheme(),
    home: child,
  );
}

/// 测试环境的平台通道没有引擎应答，不装 handler 的话 launchUrl 会一直挂起。
void _mockUrlLauncher(Future<Object?> Function(MethodCall call) handler) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_urlLauncherChannel, handler);
}

/// 测试环境默认平台是 Android，但 WebView 插件在测试里没有注册，
/// 构造 controller 会直接抛异常。协议页的无 WebView 分支是纯 Dart 的，
/// 覆盖成 Windows 后可以稳定断言。override 必须在测试体内部还原，
/// 否则会被 flutter_test 的 debug 变量检查判为失败。
Future<void> _pumpProtocolPage(
  WidgetTester tester,
  ProtocolDocument document,
  Future<void> Function() body,
) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  try {
    await tester.pumpWidget(_wrapWithApp(ProtocolPage(document: document)));
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

void main() {
  tearDown(() => _mockUrlLauncher((_) async => null));

  group('ProtocolDocument', () {
    test('should point at the server-side documents', () {
      expect(
        ProtocolDocument.privacyPolicy.url,
        'https://app.xauat.site/protocols/36ab2fc8-8e09-4c38-b96f-4f2d7e58263d',
      );
      expect(
        ProtocolDocument.userAgreement.url,
        'https://app.xauat.site/protocols/9b0e570c-4447-475f-8cfd-e346e23e105b',
      );
    });
  });

  testWidgets('should show browser fallback when webview is unavailable', (
    tester,
  ) async {
    await _pumpProtocolPage(tester, ProtocolDocument.privacyPolicy, () async {
      expect(find.text('隐私协议'), findsOneWidget);
      expect(find.text('当前平台无法在应用内显示协议内容，请前往浏览器查看。'), findsOneWidget);
      expect(find.text('在浏览器中打开'), findsOneWidget);
    });
  });

  testWidgets('should title the page from the requested document', (
    tester,
  ) async {
    await _pumpProtocolPage(tester, ProtocolDocument.userAgreement, () async {
      expect(find.text('用户协议'), findsOneWidget);
      expect(find.text('隐私协议'), findsNothing);
    });
  });

  testWidgets('should surface a snackbar when the link cannot be opened', (
    tester,
  ) async {
    _mockUrlLauncher((call) async {
      if (call.method == 'launch') {
        throw PlatformException(code: 'no_browser');
      }
      return null;
    });

    await _pumpProtocolPage(tester, ProtocolDocument.userAgreement, () async {
      await tester.tap(find.text('在浏览器中打开'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('无法打开协议页面'), findsOneWidget);
    });
  });
}
