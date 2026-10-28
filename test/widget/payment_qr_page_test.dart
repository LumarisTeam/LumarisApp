import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/payment_qr_code.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/ui/pages/payment_page/payment_qr_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
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
    expect(fetchCount, 1);
    expect(find.text('50 秒后自动刷新'), findsOneWidget);
    // 支付码内容已渲染为二维码
    expect(find.byType(QrImageView), findsOneWidget);

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
  });
}
