import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/system/widget_settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(WidgetSettingsService.channelName);
  const codec = StandardMethodCodec();

  /// 记录 Dart -> 原生 的调用参数，由各用例断言。
  late List<MethodCall> nativeCalls;
  late String? nativeResponse;
  late bool homeScreenResult;

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// 模拟原生 -> Dart 的反向调用。
  Future<void> emitFromNative(MethodCall call) {
    return messenger.handlePlatformMessage(
      WidgetSettingsService.channelName,
      codec.encodeMethodCall(call),
      (_) {},
    );
  }

  setUp(() {
    nativeCalls = <MethodCall>[];
    nativeResponse = 'pickerShown';
    homeScreenResult = true;
    WidgetSettingsService.resetForTesting();

    messenger.setMockMethodCallHandler(channel, (call) async {
      nativeCalls.add(call);
      if (call.method == WidgetSettingsService.methodOpenHomeScreen) {
        return homeScreenResult;
      }
      return nativeResponse;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    WidgetSettingsService.resetForTesting();
  });

  group('openWidgetSetup', () {
    test('should_return_pickerShown_when_native_accepts_request', () async {
      final result = await WidgetSettingsService.openWidgetSetup();

      expect(result, WidgetSetupLaunchResult.pickerShown);
      expect(nativeCalls.single.method, 'openWidgetSetup');
      expect(nativeCalls.single.arguments, <String, String>{'type': 'today'});
    });

    test('should_pass_tomorrow_type_when_requested', () async {
      await WidgetSettingsService.openWidgetSetup(
        type: WidgetSetupType.tomorrow,
      );

      expect(nativeCalls.single.arguments, <String, String>{
        'type': 'tomorrow',
      });
    });

    test('should_return_unsupported_when_native_cannot_pin', () async {
      nativeResponse = 'unsupported';

      final result = await WidgetSettingsService.openWidgetSetup();

      expect(result, WidgetSetupLaunchResult.unsupported);
    });

    test('should_return_failed_when_native_returns_unknown_value', () async {
      nativeResponse = 'somethingElse';

      final result = await WidgetSettingsService.openWidgetSetup();

      expect(result, WidgetSetupLaunchResult.failed);
    });

    test('should_return_failed_when_channel_is_not_registered', () async {
      messenger.setMockMethodCallHandler(channel, null);

      final result = await WidgetSettingsService.openWidgetSetup();

      expect(result, WidgetSetupLaunchResult.failed);
    });
  });

  group('openHomeScreen', () {
    test('should_return_true_when_native_opens_home', () async {
      final result = await WidgetSettingsService.openHomeScreen();

      expect(result, isTrue);
      expect(nativeCalls.single.method, 'openHomeScreen');
      expect(nativeCalls.single.arguments, isNull);
    });

    test('should_return_false_when_native_reports_failure', () async {
      homeScreenResult = false;

      expect(await WidgetSettingsService.openHomeScreen(), isFalse);
    });

    test('should_return_false_when_channel_is_not_registered', () async {
      messenger.setMockMethodCallHandler(channel, null);

      expect(await WidgetSettingsService.openHomeScreen(), isFalse);
    });
  });

  group('onPinOutcome', () {
    test('should_emit_installed_when_native_confirms_pin', () async {
      WidgetSettingsService.openWidgetSetup();

      final expectation = expectLater(
        WidgetSettingsService.onPinOutcome,
        emits(
          isA<WidgetPinOutcome>()
              .having((o) => o.installed, 'installed', isTrue)
              .having((o) => o.type, 'type', WidgetSetupType.tomorrow),
        ),
      );

      await emitFromNative(
        const MethodCall(WidgetSettingsService.eventWidgetPinned, {
          'type': 'tomorrow',
          'alreadyInstalled': false,
        }),
      );

      await expectation;
    });

    test('should_emit_not_installed_with_reason_when_pin_fails', () async {
      WidgetSettingsService.openWidgetSetup();

      final expectation = expectLater(
        WidgetSettingsService.onPinOutcome,
        emits(
          isA<WidgetPinOutcome>()
              .having((o) => o.installed, 'installed', isFalse)
              .having((o) => o.reason, 'reason', 'timeout')
              .having((o) => o.supported, 'supported', isFalse)
              .having((o) => o.brand, 'brand', 'Redmi/Xiaomi')
              .having((o) => o.launcher, 'launcher', 'com.miui.home'),
        ),
      );

      await emitFromNative(
        const MethodCall(WidgetSettingsService.eventWidgetPinUnavailable, {
          'type': 'today',
          'reason': 'timeout',
          'supported': false,
          'brand': 'Redmi/Xiaomi',
          'launcher': 'com.miui.home',
        }),
      );

      await expectation;
    });

    test('should_mark_xiaomi_like_brand_for_shortcut_hint', () async {
      WidgetSettingsService.openWidgetSetup();

      final expectation = expectLater(
        WidgetSettingsService.onPinOutcome,
        emits(
          isA<WidgetPinOutcome>().having(
            (o) => o.needsShortcutPermissionHint,
            'needsShortcutPermissionHint',
            isTrue,
          ),
        ),
      );

      await emitFromNative(
        const MethodCall(WidgetSettingsService.eventWidgetPinUnavailable, {
          'type': 'today',
          'brand': 'POCO/Xiaomi',
        }),
      );

      await expectation;
    });

    test('should_not_mark_other_brands_for_shortcut_hint', () async {
      WidgetSettingsService.openWidgetSetup();

      final expectation = expectLater(
        WidgetSettingsService.onPinOutcome,
        emits(
          isA<WidgetPinOutcome>().having(
            (o) => o.needsShortcutPermissionHint,
            'needsShortcutPermissionHint',
            isFalse,
          ),
        ),
      );

      await emitFromNative(
        const MethodCall(WidgetSettingsService.eventWidgetPinUnavailable, {
          'type': 'today',
          'brand': 'HUAWEI/HUAWEI',
        }),
      );

      await expectation;
    });

    test('should_ignore_unknown_native_events', () async {
      WidgetSettingsService.openWidgetSetup();

      final events = <WidgetPinOutcome>[];
      final subscription = WidgetSettingsService.onPinOutcome.listen(
        events.add,
      );
      addTearDown(subscription.cancel);

      await emitFromNative(const MethodCall('onSomethingElse'));
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty);
    });
  });
}
