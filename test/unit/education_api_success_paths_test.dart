import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/apis/bus_api.dart';
import 'package:ios_club_app/features/education/services/bus_service.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/education/services/edu_http_client.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/features/education/apis/course_api.dart';
import 'package:ios_club_app/features/education/apis/exam_api.dart';
import 'package:ios_club_app/features/education/apis/info_api.dart';
import 'package:ios_club_app/features/education/apis/login_api.dart';
import 'package:ios_club_app/features/education/apis/payment_api.dart';
import 'package:ios_club_app/features/education/apis/program_api.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
    tempDir = await Directory.systemTemp.createTemp(
      'education_api_success_paths_test_',
    );
    Hive.init(tempDir.path);
    await RequestCache.instance.initialize();
  });

  setUp(() async {
    await PrefsService.instance.clear();
    await RequestCache.instance.clear();
    EduHttpClientManager.resetForTest();
    LoginApi.setLoginOverrideForTest(null);
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
    LoginApi.setLoginOverrideForTest(null);
    LoginApi.resetClientForTest();
    EduHttpClientManager.resetForTest();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('education API success paths', () {
    test('AppApi.getAppInfo should parse dynamic nested map releases',
        () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path != '/App/GetTag') {
              handler.next(options);
              return;
            }

            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <dynamic>[
                  Map<dynamic, dynamic>.from({
                    'id': 1,
                    'tag_name': 'v1.2.3',
                    'name': 'Release 1',
                    'body': 'Notes',
                    'author': Map<dynamic, dynamic>.from({
                      'id': 10,
                      'name': 'Alice',
                    }),
                    'created_at': '2026-05-06T00:00:00Z',
                    'assets': <dynamic>[
                      Map<dynamic, dynamic>.from({
                        'browser_download_url':
                            'https://downloads.example.com/app.apk',
                        'name': 'app-release.apk',
                      }),
                    ],
                  }),
                ],
              ),
            );
          },
        ),
      );
    });

    test('refresh-aware APIs should mark requests as bypassing cache',
        () async {
      final seenPaths = <String>{};
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(
              options.extra[CacheInterceptor.bypassCacheKey],
              isTrue,
              reason: 'Expected ${options.path} to bypass request cache',
            );
            seenPaths.add(options.path);

            dynamic data;
            switch (options.path) {
              case '/Info/Completion':
                data = <String, dynamic>{
                  'data': <Map<String, dynamic>>[],
                  'code': 0,
                  'message': 'ok',
                };
              case '/Exam':
                data = <String, dynamic>{
                  'data': <Map<String, dynamic>>[],
                  'code': 0,
                  'message': 'ok',
                };
              case '/Program':
                data = <String, dynamic>{
                  'data': <Map<String, dynamic>>[],
                  'code': 0,
                  'message': 'ok',
                };
              case '/Program/GetDic':
                data = <String, dynamic>{
                  'data': <String, dynamic>{},
                  'code': 0,
                  'message': 'ok',
                };
              case '/v1/course/ScheduleTime':
                data = <dynamic>[
                  <String, dynamic>{
                    'campusName': '草堂校区',
                    'start': <String>['8:00'],
                    'end': <String>['8:20'],
                  },
                ];
              case '/Bus/2026-04-27':
                data = <String, dynamic>{
                  'data': <dynamic>[],
                  'code': 0,
                  'message': 'ok',
                  'total': 0,
                };
              default:
                fail('Unexpected path ${options.path}');
            }

            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: data,
              ),
            );
          },
        ),
      );

      await InfoApi.getInfoCompletion(forceRefresh: true);
      await ExamApi.getExam('2026001', forceRefresh: true);
      await ProgramApi.getProgram('2026001', forceRefresh: true);
      await ProgramApi.getProgramDic('2026001', forceRefresh: true);
      await CourseApi.getScheduleTime(forceRefresh: true);
      await BusApi.getBus(dayDate: '2026-04-27', forceRefresh: true);

      expect(seenPaths, {
        '/v1/course/ScheduleTime',
        '/Info/Completion',
        '/Exam',
        '/Program',
        '/Program/GetDic',
        '/Bus/2026-04-27',
      });
    });

    test('BusApi.getBusNewData should pass time and loc query parameters',
        () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/Bus/NewData/2026-04-27');
            expect(options.queryParameters, {'loc': '雁塔'});
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': [
                    {
                      'lineName': '雁塔-草堂',
                      'description': 'A1',
                      'departureStation': '雁塔',
                      'arrivalStation': '草堂',
                      'runTime': '10:00',
                      'arrivalStationTime': '01:00',
                    }
                  ],
                  'code': 0,
                  'message': 'ok',
                  'total': 1,
                },
              ),
            );
          },
        ),
      );

      final model = await BusApi.getBusNewData('2026-04-27', loc: '雁塔');

      expect(model.records, hasLength(1));
      expect(model.records.single.description, 'A1');
    });

    test('BusApi.getBusOldData should pass isShow query parameter', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/Bus/OldData/2026-04-27');
            expect(options.queryParameters, {'isShow': true});
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': <dynamic>[],
                  'code': 0,
                  'message': 'ok',
                  'total': 0,
                },
              ),
            );
          },
        ),
      );

      final model = await BusApi.getBusOldData('2026-04-27', isShow: true);

      expect(model.records, isEmpty);
      expect(model.total, 0);
    });

    test('PaymentApi should parse raw payment and turnover responses',
        () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == '/Payment/card-1') {
              handler.resolve(
                Response<dynamic>(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'data': 'card-bound',
                    'code': 0,
                    'message': 'ok',
                  },
                ),
              );
              return;
            }
            if (options.path == '/Payment/card-1/turnover') {
              handler.resolve(
                Response<dynamic>(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'data': {
                      'records': [
                        {
                          'turnoverType': '充值',
                          'datetimeStr': '2026-04-27 10:00:00',
                          'resume': '测试',
                          'tranamt': '1000',
                        }
                      ],
                      'balance': '1000',
                    },
                    'code': 0,
                    'message': 'ok',
                  },
                ),
              );
              return;
            }
            handler.next(options);
          },
        ),
      );

      final raw = await PaymentApi.getPayment('card-1');
      final turnover = await PaymentApi.getPaymentTurnover('card-1');

      expect(raw.value, 'card-bound');
      expect(turnover.payments.single.amount, 1000);
      expect(turnover.balance, 1000);
    });

    test('PaymentApi.getPaymentTurnover should throw on invalid response',
        () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: 'not-json',
              ),
            );
          },
        ),
      );

      expect(
        () => PaymentApi.getPaymentTurnover('card-1'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('LoginApi should parse map and string responses', () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');
      var call = 0;
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            call++;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: call == 1
                    ? {
                        'success': true,
                        'studentId': '2026001',
                        'cookie': 'cookie-1',
                      }
                    : jsonEncode({
                        'success': true,
                        'studentId': '2026002',
                        'cookie': 'cookie-2',
                      }),
              ),
            );
          },
        ),
      );
      LoginApi.setClientForTest(client);

      final mapResult = await LoginApi.login('u1', 'p1');
      final stringResult = await LoginApi.login('u2', 'p2');

      expect(mapResult.studentId, '2026001');
      expect(stringResult.studentId, '2026002');
    });

    test('LoginApi should use the current school client', () async {
      final selectedSchool = School(
        code: 'SECOND',
        name: 'Second School',
        website: 'https://second.example',
        features: [Feature.login],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      EduHttpClientManager.current.updateSchoolConfig(selectedSchool);
      late String requestBaseUrl;
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestBaseUrl = options.baseUrl;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'studentId': '2026000',
                  'cookie': 'school-cookie',
                },
              ),
            );
          },
        ),
      );

      final result = await LoginApi.login('user', 'password');

      expect(result.success, isTrue);
      expect(requestBaseUrl, selectedSchool.website);
    });

    test('LoginApi should unwrap the current API response envelope', () async {
      LoginApi.setLoginOverrideForTest(null);
      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'code': 0,
                  'message': 'ok',
                  'data': {
                    'success': true,
                    'studentId': '2026003',
                    'cookie': 'session-cookie',
                  },
                },
              ),
            );
          },
        ),
      );
      LoginApi.setClientForTest(client);

      final result = await LoginApi.login('user', 'password');

      expect(result.success, isTrue);
      expect(result.studentId, '2026003');
      expect(result.cookie, 'session-cookie');
    });

    test('LoginApi should wrap invalid response as NetworkException', () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <dynamic>[],
              ),
            );
          },
        ),
      );
      LoginApi.setClientForTest(client);

      expect(
        () => LoginApi.login('u', 'p'),
        throwsA(isA<NetworkException>()),
      );
    });
    test('CourseApi.getScheduleTime should parse the bare array response',
        () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/v1/course/ScheduleTime');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <dynamic>[
                  <String, dynamic>{
                    'campusName': '草堂校区',
                    'start': <String>['8:00', '8:30'],
                    'end': <String>['8:20', '9:15'],
                  },
                  <String, dynamic>{
                    'campusName': '雁塔校区',
                    'time': '05/01~09/30',
                    'start': <String>['', '8:00'],
                    'end': <String>['', '8:50'],
                  },
                ],
              ),
            );
          },
        ),
      );

      final tables = await CourseApi.getScheduleTime();

      expect(tables, hasLength(2));
      expect(tables.first.campusName, '草堂校区');
      expect(tables.first.time, '');
      expect(tables.last.time, '05/01~09/30');
      expect(tables.last.start, <String>['', '8:00']);
    });

    test('CourseApi.getScheduleTime should parse the enveloped response',
        () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/v1/course/ScheduleTime');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'data': <dynamic>[
                    <String, dynamic>{
                      'campusName': '雁塔校区',
                      'time': '10/01~04/30',
                      'start': <String>['', '8:00'],
                      'end': <String>['', '8:50'],
                    },
                  ],
                  'code': 0,
                  'message': 'ok',
                  'total': 1,
                },
              ),
            );
          },
        ),
      );

      final tables = await CourseApi.getScheduleTime();

      expect(tables, hasLength(1));
      expect(tables.single.campusName, '雁塔校区');
      expect(tables.single.end, <String>['', '8:50']);
    });
  });

  group('BusService', () {
    test('should_filter_past_bus_records_for_today', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': [
                    {
                      'lineName': 'past',
                      'description': '',
                      'departureStation': 'A',
                      'arrivalStation': 'B',
                      'runTime': '00:00:00',
                      'arrivalStationTime': '01:00',
                    },
                    {
                      'lineName': 'future',
                      'description': '',
                      'departureStation': 'A',
                      'arrivalStation': 'B',
                      'runTime': '23:59:00',
                      'arrivalStationTime': '01:00',
                    },
                  ],
                  'code': 0,
                  'message': 'ok',
                  'total': 2,
                },
              ),
            );
          },
        ),
      );

      final model = await BusService.getBus();

      expect(model.records.map((item) => item.lineName), ['future']);
    });

    test('should_not_filter_records_for_explicit_non_today_date', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': [
                    {
                      'lineName': 'early',
                      'description': '',
                      'departureStation': 'A',
                      'arrivalStation': 'B',
                      'runTime': '06:00:00',
                      'arrivalStationTime': '01:00',
                    },
                  ],
                  'code': 0,
                  'message': 'ok',
                  'total': 1,
                },
              ),
            );
          },
        ),
      );

      final model = await BusService.getBus(dayDate: '2099-01-01');

      expect(model.records, hasLength(1));
      expect(model.records.single.lineName, 'early');
    });

    test('should_return_empty_model_when_bus_api_fails', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 500,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final model = await BusService.getBus();

      expect(model.records, isEmpty);
      expect(model.total, 0);
    });
  });
}
