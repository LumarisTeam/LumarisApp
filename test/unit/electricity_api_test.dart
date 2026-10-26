import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/features/education/models/edu_api_models.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/features/education/apis/electricity_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
    tempDir = await Directory.systemTemp.createTemp('electricity_api_test_');
    Hive.init(tempDir.path);
    await RequestCache.instance.initialize();
  });

  setUp(() async {
    await PrefsService.instance.clear();
    await RequestCache.instance.clear();
    EduHttpClientManager.resetForTest();
    final manager = EduHttpClientManager.initialize();
    manager.updateSchoolConfig(
      School(
        code: 'test',
        name: 'Test',
        website: 'http://api.test',
        features: [],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    );
  });

  tearDown(() {
    EduHttpClientManager.resetForTest();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ElectricityApi', () {
    test('should_get_current_balance_with_optional_url', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/Electricity');
            expect(options.queryParameters, <String, dynamic>{
              'url': 'https://example.com/wxAccount?id=1',
            });
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'data': 23.5,
                  'code': 0,
                  'message': 'ok',
                },
              ),
            );
          },
        ),
      );

      final balance = await ElectricityApi.getCurrentBalance(
        url: 'https://example.com/wxAccount?id=1',
      );

      expect(balance, 23.5);
    });

    test('should_return_null_when_current_balance_is_not_found', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 404,
                  data: <String, dynamic>{'error': '未找到电费余额数据'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final balance = await ElectricityApi.getCurrentBalance();

      expect(balance, isNull);
    });

    test('should_parse_weekly_data_list', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/Electricity/WeeklyData');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <Map<String, dynamic>>[
                  <String, dynamic>{
                    'timestamp': '2026-05-01T10:00:00',
                    'value': 1.5,
                  },
                  <String, dynamic>{
                    'Timestamp': '2026-05-01T11:00:00',
                    'Value': '2.0',
                  },
                ],
              ),
            );
          },
        ),
      );

      final data = await ElectricityApi.getWeeklyData();

      expect(data, hasLength(2));
      expect(data[0].timestamp, DateTime.parse('2026-05-01T10:00:00'));
      expect(data[0].value, 1.5);
      expect(data[1].timestamp, DateTime.parse('2026-05-01T11:00:00'));
      expect(data[1].value, 2.0);
    });

    test('should_throw_network_exception_on_invalid_weekly_data', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: 'invalid',
              ),
            );
          },
        ),
      );

      expect(ElectricityApi.getWeeklyData, throwsA(isA<NetworkException>()));
    });

    test('should_return_recharge_url', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/Electricity/RechargeUrl');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'data': 'https://example.com/wxCharge?id=1',
                  'code': 0,
                  'message': 'ok',
                },
              ),
            );
          },
        ),
      );

      final rechargeUrl = await ElectricityApi.getRechargeUrl();

      expect(rechargeUrl, 'https://example.com/wxCharge?id=1');
    });

    test('should_return_null_when_recharge_url_is_not_found', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 404,
                  data: <String, dynamic>{'error': '未找到电费充值地址'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final rechargeUrl = await ElectricityApi.getRechargeUrl();

      expect(rechargeUrl, isNull);
    });

    test('should_create_electricity_subscription', () async {
      final request = CreateElectricitySubscriptionRequest(
        url: 'https://example.com/wxAccount?id=1',
        email: 'codex@example.com',
        threshold: 12.5,
      );

      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'POST');
            expect(options.path, '/Electricity/Subscriptions');
            expect(options.data, <String, dynamic>{
              'url': 'https://example.com/wxAccount?id=1',
              'email': 'codex@example.com',
              'threshold': 12.5,
            });
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'id': 'sub-1',
                  'url': 'https://example.com/wxAccount?id=1',
                  'email': 'codex@example.com',
                  'threshold': '12.5',
                  'isActive': true,
                  'createdAt': '2026-05-01T10:00:00Z',
                  'updatedAt': '2026-05-01T10:30:00Z',
                  'nextCheckAt': '2026-05-01T11:00:00Z',
                  'lastCheckedAt': null,
                  'lastKnownBalance': '15.0',
                  'lastAlertedAt': null,
                  'lastAlertedBalance': null,
                  'lastErrorMessage': '',
                },
              ),
            );
          },
        ),
      );

      final subscription = await ElectricityApi.createSubscription(request);

      expect(subscription.id, 'sub-1');
      expect(subscription.email, 'codex@example.com');
      expect(subscription.threshold, 12.5);
      expect(subscription.lastKnownBalance, 15.0);
      expect(subscription.lastCheckedAt, isNull);
    });

    test('should_get_electricity_subscription_by_email', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'GET');
            expect(options.path, '/Electricity/Subscriptions');
            expect(options.queryParameters, <String, dynamic>{
              'email': 'codex@example.com',
            });
            expect(options.extra[CacheInterceptor.bypassCacheKey], isTrue);
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'email': 'codex@example.com',
                  'hasSubscription': true,
                  'subscriptionId': 'sub-1',
                  'threshold': 10,
                },
              ),
            );
          },
        ),
      );

      final result = await ElectricityApi.getSubscription(
        ' codex@example.com ',
      );

      expect(result.email, 'codex@example.com');
      expect(result.hasSubscription, isTrue);
      expect(result.subscriptionId, 'sub-1');
      expect(result.threshold, 10);
    });

    test('should_delete_electricity_subscription', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'DELETE');
            expect(options.path, '/Electricity/Subscriptions/sub-1');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 204,
                data: null,
              ),
            );
          },
        ),
      );

      await ElectricityApi.deleteSubscription(' sub-1 ');
    });
  });
}
