import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/electric_data.dart';
import 'package:ios_club_app/features/education/models/edu_api_models.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/services/electricity_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const launcherChannel = MethodChannel('plugins.flutter.io/url_launcher');

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
    await PrefsService.instance.clear();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(launcherChannel, null);
  });

  group('ElectricityService', () {
    test('should_delegate_balance_request_with_url_and_persist_it', () async {
      String? receivedUrl;
      final service = ElectricityService(
        balanceReader: ({String? url}) async {
          receivedUrl = url;
          return 12.5;
        },
      );

      final value = await service.fetchCurrentBalance(
        url: 'https://example.com/e',
      );

      expect(value, 12.5);
      expect(receivedUrl, 'https://example.com/e');
      expect(
        PrefsService.instance.getString(PrefsKeys.ELECTRICITY_URL),
        'https://example.com/e',
      );
    });

    test('should_use_cached_url_when_balance_request_has_no_input', () async {
      String? receivedUrl;
      await PrefsService.instance.setString(
        PrefsKeys.ELECTRICITY_URL,
        'https://cached.example.com/e',
      );
      final service = ElectricityService(
        balanceReader: ({String? url}) async {
          receivedUrl = url;
          return 9.5;
        },
      );

      final value = await service.fetchCurrentBalance();

      expect(value, 9.5);
      expect(receivedUrl, 'https://cached.example.com/e');
    });

    test(
      'should_return_null_when_balance_request_has_no_input_and_no_cache',
      () async {
        var called = false;
        final service = ElectricityService(
          balanceReader: ({String? url}) async {
            called = true;
            return 1.0;
          },
        );

        final value = await service.fetchCurrentBalance();

        expect(value, isNull);
        expect(called, isFalse);
      },
    );

    test('should_return_null_when_balance_reader_throws', () async {
      final service = ElectricityService(
        balanceReader: ({String? url}) async {
          throw NetworkException('boom', 500);
        },
      );

      final value = await service.fetchCurrentBalance(url: 'bad-url');

      expect(value, isNull);
    });

    test('should_delegate_weekly_data_request_with_cached_url', () async {
      String? receivedUrl;
      await PrefsService.instance.setString(
        PrefsKeys.ELECTRICITY_URL,
        'https://cached.example.com/e',
      );
      final expected = [
        ElectricData(timestamp: DateTime(2026, 3, 2, 10), value: 2.0),
        ElectricData(timestamp: DateTime(2026, 3, 2, 11), value: 1.0),
      ];
      final service = ElectricityService(
        weeklyDataReader: ({String? url}) async {
          receivedUrl = url;
          return expected;
        },
      );

      final list = await service.fetchWeeklyData();

      expect(receivedUrl, 'https://cached.example.com/e');
      expect(list, hasLength(2));
      expect(list[0].value, 2.0);
      expect(list[1].timestamp.hour, 11);
    });

    test('should_delegate_recharge_url_request_with_cached_url', () async {
      String? receivedUrl;
      await PrefsService.instance.setString(
        PrefsKeys.ELECTRICITY_URL,
        'https://cached.example.com/e',
      );
      final service = ElectricityService(
        rechargeUrlReader: ({String? url}) async {
          receivedUrl = url;
          return 'https://x/wxCharge?id=1';
        },
      );

      final rechargeUrl = await service.getRechargeUrl();

      expect(receivedUrl, 'https://cached.example.com/e');
      expect(rechargeUrl, 'https://x/wxCharge?id=1');
    });

    test('should_prefer_wechat_url_scheme_when_available', () async {
      final launched = <String>[];
      final service = ElectricityService(
        rechargeUrlReader: ({String? url}) async =>
            'https://example.com/wxCharge',
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(launcherChannel, (call) async {
            final url = (call.arguments is Map)
                ? (call.arguments['url'] as String? ?? '')
                : call.arguments.toString();
            if (call.method == 'canLaunch' || call.method == 'canLaunchUrl') {
              return url.startsWith('weixin://');
            }
            if (call.method == 'launch' || call.method == 'launchUrl') {
              launched.add(url);
              return true;
            }
            return null;
          });

      await service.openRechargePage();

      expect(launched.single, startsWith('weixin://dl/business/'));
    });

    test('should_fallback_to_browser_when_wechat_is_unavailable', () async {
      final launched = <String>[];
      final service = ElectricityService(
        rechargeUrlReader: ({String? url}) async =>
            'https://example.com/wxCharge',
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(launcherChannel, (call) async {
            final url = (call.arguments is Map)
                ? (call.arguments['url'] as String? ?? '')
                : call.arguments.toString();
            if (call.method == 'canLaunch' || call.method == 'canLaunchUrl') {
              return url.startsWith('http');
            }
            if (call.method == 'launch' || call.method == 'launchUrl') {
              launched.add(url);
              return true;
            }
            return null;
          });

      await service.openRechargePage();

      expect(launched.single, 'https://example.com/wxCharge');
    });

    test('should_throw_when_recharge_url_is_missing', () async {
      final service = ElectricityService(
        rechargeUrlReader: ({String? url}) async => null,
      );

      await expectLater(service.openRechargePage, throwsA(isA<String>()));
    });

    test('should_throw_when_no_launcher_is_available', () async {
      final service = ElectricityService(
        rechargeUrlReader: ({String? url}) async =>
            'https://example.com/wxCharge',
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(launcherChannel, (call) async {
            if (call.method == 'canLaunch' || call.method == 'canLaunchUrl') {
              return false;
            }
            return null;
          });

      await expectLater(service.openRechargePage, throwsA(isA<String>()));
    });

    test('should_save_and_read_subscription_email', () async {
      final service = ElectricityService();

      await service.saveSubscriptionEmail(' codex@example.com ');
      final email = await service.getSavedSubscriptionEmail();

      expect(email, 'codex@example.com');
      expect(
        PrefsService.instance.getString(
          PrefsKeys.ELECTRICITY_SUBSCRIPTION_EMAIL,
        ),
        'codex@example.com',
      );
    });

    test(
      'should_create_subscription_with_cached_url_and_persist_email',
      () async {
        await PrefsService.instance.setString(
          PrefsKeys.ELECTRICITY_URL,
          'https://cached.example.com/e',
        );

        CreateElectricitySubscriptionRequest? receivedRequest;
        final service = ElectricityService(
          subscriptionCreator: (request) async {
            receivedRequest = request;
            return ElectricitySubscriptionResponse(
              id: 'sub-1',
              url: request.url,
              email: request.email,
              threshold: request.threshold ?? 0,
              isActive: true,
              createdAt: DateTime.parse('2026-05-01T10:00:00Z'),
              updatedAt: DateTime.parse('2026-05-01T10:00:00Z'),
              nextCheckAt: DateTime.parse('2026-05-01T11:00:00Z'),
              lastErrorMessage: '',
            );
          },
        );

        final subscription = await service.createSubscription(
          email: ' codex@example.com ',
          threshold: 12.5,
        );

        expect(receivedRequest, isNotNull);
        expect(receivedRequest!.url, 'https://cached.example.com/e');
        expect(receivedRequest!.email, 'codex@example.com');
        expect(receivedRequest!.threshold, 12.5);
        expect(subscription.id, 'sub-1');
        expect(
          PrefsService.instance.getString(
            PrefsKeys.ELECTRICITY_SUBSCRIPTION_EMAIL,
          ),
          'codex@example.com',
        );
      },
    );

    test('should_query_subscription_with_explicit_email', () async {
      String? receivedEmail;
      final service = ElectricityService(
        subscriptionQueryReader: (email) async {
          receivedEmail = email;
          return const ElectricitySubscriptionQueryResponse(
            email: 'codex@example.com',
            hasSubscription: true,
            subscriptionId: 'sub-1',
            threshold: 12.5,
          );
        },
      );

      final result = await service.getSubscription(
        email: ' codex@example.com ',
      );

      expect(receivedEmail, 'codex@example.com');
      expect(result.hasSubscription, isTrue);
      expect(result.subscriptionId, 'sub-1');
    });

    test(
      'should_query_subscription_with_saved_email_when_not_provided',
      () async {
        await PrefsService.instance.setString(
          PrefsKeys.ELECTRICITY_SUBSCRIPTION_EMAIL,
          'cached@example.com',
        );

        String? receivedEmail;
        final service = ElectricityService(
          subscriptionQueryReader: (email) async {
            receivedEmail = email;
            return const ElectricitySubscriptionQueryResponse(
              email: 'cached@example.com',
              hasSubscription: false,
              subscriptionId: '',
              threshold: 0,
            );
          },
        );

        final result = await service.getSubscription();

        expect(receivedEmail, 'cached@example.com');
        expect(result.email, 'cached@example.com');
        expect(result.hasSubscription, isFalse);
      },
    );

    test('should_throw_when_querying_subscription_without_email', () async {
      final service = ElectricityService(
        subscriptionQueryReader: (_) async {
          return const ElectricitySubscriptionQueryResponse(
            email: 'unused@example.com',
            hasSubscription: false,
            subscriptionId: '',
            threshold: 0,
          );
        },
      );

      await expectLater(service.getSubscription, throwsA(isA<StateError>()));
    });

    test('should_delegate_subscription_delete', () async {
      String? deletedId;
      final service = ElectricityService(
        subscriptionDeleter: (id) async {
          deletedId = id;
        },
      );

      await service.deleteSubscription('sub-1');

      expect(deletedId, 'sub-1');
    });
  });
}
