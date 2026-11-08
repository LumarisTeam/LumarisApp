import 'dart:async';
import 'dart:convert';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ios_club_app/features/education/models/payment_qr_code.dart';
import 'package:ios_club_app/features/system/screen_capture_protection.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/ui/pages/payment_page/payment_qr_page.dart';
import 'package:ios_club_app/ui/components/tiles/payment_tile.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

class _TilePaymentStore extends PaymentStore {
  @override
  PaymentState build() => const PaymentState(
    isLoading: false,
    hasData: true,
    openQrCodeFromTile: true,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final protectionCalls = <String>[];
  setUp(() {
    protectionCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('screen_protector'), (
          call,
        ) async {
          protectionCalls.add(call.method);
          return true;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('screen_protector'),
          null,
        );
  });
  test('should_serialize_capture_protection_when_page_is_reopened', () async {
    final protection = ScreenCaptureProtectionService();
    final firstEnable = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('screen_protector'), (
          call,
        ) async {
          protectionCalls.add(call.method);
          if (protectionCalls.length == 1) await firstEnable.future;
          return true;
        });

    final opening = protection.setEnabled(true);
    final closing = protection.setEnabled(false);
    final reopening = protection.setEnabled(true);
    await Future<void>.delayed(Duration.zero);
    expect(protectionCalls, ['preventScreenshotOn']);
    firstEnable.complete();
    expect(await Future.wait([opening, closing, reopening]), [
      true,
      true,
      true,
    ]);
    expect(protectionCalls, [
      'preventScreenshotOn',
      'preventScreenshotOff',
      'preventScreenshotOn',
    ]);
    await protection.setEnabled(false);
  });

  testWidgets('PaymentQrPage should refresh the code every 50 seconds', (
    tester,
  ) async {
    var fetchCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          paymentStudentIdReaderProvider.overrideWithValue(
            () async => 'student-1',
          ),
          paymentPasswordReaderProvider.overrideWithValue(() async => 'pw'),
          paymentQrFetcherProvider.overrideWithValue((_, _) async {
            fetchCount++;
            return PaymentQrCode(
              data: Uint8List.fromList(utf8.encode('payload-$fetchCount')),
              mode: PaymentQrCode.offlineMode,
            );
          }),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PaymentQrPage(),
        ),
      ),
    );

    // 首次加载
    await tester.pump();
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(protectionCalls, ['preventScreenshotOn']);
    expect(fetchCount, 1);
    expect(find.text('50 秒后自动刷新'), findsOneWidget);
    // 支付码内容已渲染为二维码
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('返回到饭卡页面'), findsNothing);

    // 49 秒时还不应刷新
    await tester.pump(const Duration(seconds: 49));
    expect(fetchCount, 1);

    // 第 50 秒触发刷新
    await tester.pump(const Duration(seconds: 1));
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(fetchCount, 2);

    // 卸载页面，取消计时器，避免测试结束时仍有 pending timer
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(protectionCalls, ['preventScreenshotOn', 'preventScreenshotOff']);
  });

  testWidgets(
    'should_hide_code_when_protection_is_pending_or_app_is_inactive',
    (tester) async {
      final ready = Completer<bool>();
      var fetchCount = 0;
      await tester.pumpWidget(
        _qrApp(
          protection: (enabled) => enabled ? ready.future : Future.value(true),
          fetch: (_, _) async {
            fetchCount++;
            return PaymentQrCode(
              data: Uint8List.fromList([1, 2, 3]),
              mode: PaymentQrCode.offlineMode,
            );
          },
        ),
      );
      await tester.pump();
      expect(fetchCount, 0);
      expect(find.byType(QrImageView), findsNothing);
      ready.complete(true);
      await tester.pump();
      await tester.pump();
      expect(find.byType(QrImageView), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byType(QrImageView), findsNothing);
      await tester.pump(const Duration(seconds: 60));
      expect(fetchCount, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump();
      expect(fetchCount, 2);
      expect(find.byType(QrImageView), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('should_allow_retry_when_capture_protection_fails', (
    tester,
  ) async {
    var enableCount = 0;
    var fetchCount = 0;
    await tester.pumpWidget(
      _qrApp(
        protection: (enabled) async => !enabled || ++enableCount > 1,
        fetch: (_, _) async {
          fetchCount++;
          return PaymentQrCode(
            data: Uint8List.fromList([1, 2, 3]),
            mode: PaymentQrCode.offlineMode,
          );
        },
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(fetchCount, 0);
    expect(find.byType(QrImageView), findsNothing);
    expect(find.text('支付码获取失败，请稍后重试'), findsOneWidget);
    await tester.tap(find.text('重试'));
    await tester.pump();
    await tester.pump();
    expect(fetchCount, 1);
    expect(find.byType(QrImageView), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'should_open_card_details_when_return_button_is_tapped_from_tile',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(393, 852);
      tester.view.padding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.reset);
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(
              body: SizedBox(width: 180, height: 180, child: PaymentTile()),
            ),
          ),
          GoRoute(
            path: AppRoutes.paymentQrCode,
            builder: (_, _) => const PaymentQrPage(fromPaymentTile: true),
          ),
          GoRoute(
            path: AppRoutes.payment,
            builder: (_, _) => const Scaffold(body: Text('饭卡详情')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appRouterProvider.overrideWithValue(router),
            paymentStoreProvider.overrideWith(_TilePaymentStore.new),
            paymentStudentIdReaderProvider.overrideWithValue(
              () async => 'student-1',
            ),
            paymentPasswordReaderProvider.overrideWithValue(() async => 'pw'),
            paymentQrFetcherProvider.overrideWithValue(
              (_, _) async => PaymentQrCode(
                data: Uint8List.fromList([1, 2, 3]),
                mode: PaymentQrCode.offlineMode,
              ),
            ),
          ],
          child: MaterialApp.router(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            routerConfig: router,
            locale: const Locale('zh'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PaymentTile));
      await tester.pumpAndSettle();
      expect(
        GoRouterState.of(
          tester.element(find.byType(PaymentQrPage)),
        ).uri.queryParameters['from'],
        'tile',
      );
      final returnButton = find.widgetWithText(CupertinoButton, '返回到饭卡页面');
      expect(returnButton, findsOneWidget);
      expect(find.text('饭卡'), findsNothing);
      expect(tester.getSize(returnButton).height, greaterThanOrEqualTo(44));
      expect(tester.getBottomRight(returnButton).dy, lessThanOrEqualTo(818));
      expect(
        tester.getTopLeft(returnButton).dy,
        greaterThan(tester.getBottomLeft(find.byType(QrImageView)).dy),
      );

      await tester.tap(returnButton);
      await tester.pumpAndSettle();
      expect(find.text('饭卡详情'), findsOneWidget);
      expect(find.byType(PaymentQrPage), findsNothing);
      expect(protectionCalls, ['preventScreenshotOn', 'preventScreenshotOff']);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(PaymentTile), findsOneWidget);
      expect(find.byType(PaymentQrPage), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

Widget _qrApp({
  required ScreenCaptureProtection protection,
  required PaymentQrFetcher fetch,
}) {
  return ProviderScope(
    overrides: [
      screenCaptureProtectionProvider.overrideWithValue(protection),
      paymentStudentIdReaderProvider.overrideWithValue(() async => 'student-1'),
      paymentPasswordReaderProvider.overrideWithValue(() async => 'pw'),
      paymentQrFetcherProvider.overrideWithValue(fetch),
    ],
    child: MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const PaymentQrPage(),
    ),
  );
}
