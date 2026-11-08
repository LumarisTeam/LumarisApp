import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:ios_club_app/state/tile_store_providers.dart';
import 'package:ios_club_app/ui/pages/payment_page/payment_page.dart';
import 'package:ios_club_app/ui/pages/setting_page/home_page_setting.dart';

class _PaymentStore extends PaymentStore {
  @override
  PaymentState build() => super.build().copyWith(isLoading: false);
}

class _SchoolStore extends SchoolStore {
  @override
  SchoolStoreState build() => const SchoolStoreState();
}

Widget _app(ProviderContainer container, Widget home) =>
    UncontrolledProviderScope(
      container: container,
      child: RepaintBoundary(
        key: const ValueKey('settings-preview'),
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: McThemeData.materialTheme(McColors.light).copyWith(
            textTheme: McThemeData.materialTheme(McColors.light).textTheme
                .apply(fontFamily: _savePreviews ? 'SettingsPreview' : null),
          ),
          debugShowCheckedModeBanner: false,
          home: home,
        ),
      ),
    );

// flutter test --dart-define=SAVE_SETTING_PREVIEWS=true test/widget/payment_launch_settings_test.dart
const bool _savePreviews = bool.fromEnvironment('SAVE_SETTING_PREVIEWS');

void _configurePhone(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(393, 852);
  addTearDown(tester.view.reset);
}

Future<void> _savePreview(WidgetTester tester, String name) async {
  if (!_savePreviews) return;
  for (final element in find.byType(RichText).evaluate()) {
    final paragraph = element.renderObject;
    if (paragraph is! RenderParagraph || paragraph.text is! TextSpan) continue;
    final span = paragraph.text as TextSpan;
    final family = span.style?.fontFamily ?? '';
    if (family.contains('Icons')) continue;
    paragraph.text = TextSpan(
      text: span.text,
      children: span.children,
      style: (span.style ?? const TextStyle()).copyWith(
        fontFamily: 'SettingsPreview',
      ),
    );
  }
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('settings-preview')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/design').create(recursive: true);
    await File(
      'build/design/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (!_savePreviews) return;
    final font = File('/System/Library/Fonts/Hiragino Sans GB.ttc');
    if (await font.exists()) {
      final loader = FontLoader('SettingsPreview')
        ..addFont(Future.value(ByteData.sublistView(await font.readAsBytes())));
      await loader.load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    await (FontLoader('packages/cupertino_icons/CupertinoIcons')..addFont(
          rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf'),
        ))
        .load();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
    await PrefsService.instance.clear();
  });

  testWidgets('should_save_launch_page_when_action_is_selected', (
    tester,
  ) async {
    _configurePhone(tester);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      _app(container, const Scaffold(body: HomePageSetting())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('打开应用的第一个页面'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoActionSheet), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);
    await _savePreview(tester, 'settings-launch-actionsheet');

    final target = find.byType(CupertinoActionSheetAction).at(2);
    await tester.tap(target);
    await tester.pumpAndSettle();
    expect(container.read(settingsStoreProvider).pageIndex, 2);
    expect(PrefsService.instance.getInt(PrefsKeys.PAGE_DATA), 2);
    expect(find.byType(CupertinoActionSheet), findsNothing);

    await tester.tap(find.text('打开应用的第一个页面'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(container.read(settingsStoreProvider).pageIndex, 2);
  });

  testWidgets('should_show_qr_shortcut_setting_when_payment_tile_is_enabled', (
    tester,
  ) async {
    _configurePhone(tester);
    final container = ProviderContainer(
      overrides: [
        tileStoreAutoLoadProvider.overrideWithValue(false),
        paymentStoreProvider.overrideWith(_PaymentStore.new),
        schoolStoreProvider.overrideWith(_SchoolStore.new),
        tileAdderProvider.overrideWithValue((_) async {}),
        tileRemoverProvider.overrideWithValue((_) async {}),
        tileConfigurationReaderProvider.overrideWithValue(
          () async => TileConfigurationList.defaultConfig(),
        ),
        tileConfigurationWriterProvider.overrideWithValue((_) async {}),
        availableTilesReaderProvider.overrideWithValue(() => const ['饭卡']),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container, const PaymentPage()));
    await tester.pumpAndSettle();
    expect(find.text('进入磁贴直接展示支付码'), findsNothing);

    final tileSwitch = find.byType(CupertinoSwitch).first;
    await tester.ensureVisible(tileSwitch);
    await tester.tap(tileSwitch);
    await tester.pumpAndSettle();
    expect(find.text('进入磁贴直接展示支付码'), findsOneWidget);

    final qrSwitch = find.byType(CupertinoSwitch).last;
    expect(tester.widget<CupertinoSwitch>(qrSwitch).value, isFalse);
    await tester.ensureVisible(qrSwitch);
    await tester.tap(qrSwitch);
    await tester.pumpAndSettle();
    expect(container.read(paymentStoreProvider).openQrCodeFromTile, isTrue);
    expect(
      PrefsService.instance.getBool(PrefsKeys.PAYMENT_TILE_OPEN_QR_CODE),
      isTrue,
    );
    await _savePreview(tester, 'payment-tile-settings');

    await tester.ensureVisible(tileSwitch);
    await tester.tap(tileSwitch);
    await tester.pumpAndSettle();
    expect(find.text('进入磁贴直接展示支付码'), findsNothing);

    // 隐藏后重新开启磁贴，保留用户选过的直达行为。
    await tester.tap(tileSwitch);
    await tester.pumpAndSettle();
    expect(
      tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch).last).value,
      isTrue,
    );

    container.invalidate(paymentStoreProvider);
    expect(container.read(paymentStoreProvider).openQrCodeFromTile, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
