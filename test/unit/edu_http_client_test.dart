import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/features/education/apis/login_api.dart';
import 'package:ios_club_app/features/education/models/login_response.dart';
import 'package:ios_club_app/features/education/services/auth_session_guard.dart';
import 'package:ios_club_app/features/education/services/edu_http_client.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(this._responses);

  final List<ResponseBody Function(RequestOptions)> _responses;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_responses.isEmpty) {
      throw StateError('No queued response for ${options.path}');
    }
    return _responses.removeAt(0)(options);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final secureStore = <String, String>{};
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();

    tempDir = await Directory.systemTemp.createTemp('edu_http_client_test_');
    Hive.init(tempDir.path);
    final box = await Hive.openBox('request_cache');
    await box.clear();
    await RequestCache.instance.initialize();
  });

  setUp(() async {
    secureStore.clear();
    await PrefsService.instance.clear();
    EduHttpClient.resetReloginStateForTest();
    LoginApi.setLoginOverrideForTest(null);
    final box = await Hive.openBox('request_cache');
    await box.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          final key = call.arguments['key'] as String?;
          switch (call.method) {
            case 'read':
              if (key == null) {
                return null;
              }
              return secureStore[key];
            case 'write':
              final value = call.arguments['value'] as String?;
              if (key != null && value != null) {
                secureStore[key] = value;
              }
              return null;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    EduHttpClient.resetReloginStateForTest();
    LoginApi.setLoginOverrideForTest(null);
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('EduHttpClient', () {
    test('should update baseUrl in runtime', () {
      final client = EduHttpClient(baseUrl: 'http://api.old');
      expect(client.baseUrl, 'http://api.old');

      client.updateBaseUrl('http://api.new');
      expect(client.baseUrl, 'http://api.new');

      client.dispose();
    });

    test('should inject cookie headers and return get response data', () async {
      await PrefsService.instance.setString(
        PrefsKeys.USER_DATA,
        jsonEncode(<String, String>{
          'studentId': '2026001',
          'cookie': 'cookie-token',
        }),
      );

      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.headers['Cookie'], 'cookie-token');
            expect(options.headers['xauat'], 'cookie-token');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{'ok': true},
              ),
            );
          },
        ),
      );

      final data = await client.get('/ping');
      expect(data, isA<Map>());
      expect((data as Map<String, dynamic>)['ok'], isTrue);

      client.dispose();
    });

    test('should inject saved x-loginMode header', () async {
      await PrefsService.instance.setInt(PrefsKeys.LOGIN_MODE, 1);

      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.headers['x-loginMode'], '1');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{'ok': true},
              ),
            );
          },
        ),
      );

      final data = await client.get('/graduate') as Map<String, dynamic>;
      expect(data['ok'], isTrue);

      client.dispose();
    });

    test('should keep explicit x-loginMode over the saved mode', () async {
      await PrefsService.instance.setInt(PrefsKeys.LOGIN_MODE, 1);

      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.headers['x-loginMode'], '0');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{'ok': true},
              ),
            );
          },
        ),
      );

      final data =
          await client.get(
                '/undergraduate',
                options: Options(
                  headers: <String, dynamic>{'x-loginMode': '0'},
                ),
              )
              as Map<String, dynamic>;
      expect(data['ok'], isTrue);

      client.dispose();
    });

    test('should inject x-language header from locale preference', () async {
      await PrefsService.instance.setString(PrefsKeys.LOCALE_CODE, 'ja');

      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.headers['x-language'], 'ja');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{'ok': true},
              ),
            );
          },
        ),
      );

      final data = await client.get('/locale');
      expect(data, isA<Map>());
      expect((data as Map<String, dynamic>)['ok'], isTrue);

      client.dispose();
    });

    test(
      'should bypass request cache when force refresh is requested',
      () async {
        await RequestCache.instance.set(
          'http://api.test/ping',
          <String, dynamic>{'cached': true},
        );

        var networkHits = 0;
        final client = EduHttpClient(baseUrl: 'http://api.test');
        client.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              networkHits++;
              handler.resolve(
                Response<dynamic>(
                  requestOptions: options,
                  statusCode: 200,
                  data: <String, dynamic>{'cached': false},
                ),
              );
            },
          ),
        );

        final cachedData = await client.get('/ping') as Map<String, dynamic>;
        final refreshedData =
            await client.get('/ping', bypassCache: true)
                as Map<String, dynamic>;

        expect(cachedData['cached'], isTrue);
        expect(refreshedData['cached'], isFalse);
        expect(networkHits, 1);

        client.dispose();
      },
    );

    test('should return post response data', () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'POST');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{'result': 'ok'},
              ),
            );
          },
        ),
      );

      final data = await client.post(
        '/submit',
        data: <String, dynamic>{'name': 'codex'},
      );
      expect(data, isA<Map>());
      expect((data as Map<String, dynamic>)['result'], 'ok');

      client.dispose();
    });

    test('should return delete response data', () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'DELETE');
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

      final data = await client.delete('/subscriptions/1');
      expect(data, isNull);

      client.dispose();
    });

    test(
      'should trigger relog failed state on 401 and throw auth exception',
      () async {
        var reloggingCalled = 0;
        String? failedReason;
        final client = EduHttpClient(
          baseUrl: 'http://api.test',
          authStateCallbacks: AuthStateCallbacks(
            onRelogging: () => reloggingCalled++,
            onRelogFailed: (reason) => failedReason = reason,
          ),
        );

        client.dio.httpClientAdapter = _QueueAdapter([
          (_) => ResponseBody.fromString(
            '{"error":"unauthorized"}',
            401,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>['application/json'],
            },
          ),
        ]);

        await expectLater(
          () => client.get('/need-auth'),
          throwsA(isA<AuthenticationException>()),
        );
        expect(reloggingCalled, 1);
        expect(failedReason, '账号或密码错误');

        client.dispose();
      },
    );

    test('should skip relogin during cooldown window', () async {
      var loginCalled = 0;
      EduHttpClient.setLoginHandlerForTest((_, _) async {
        loginCalled++;
        return <String, dynamic>{'success': true};
      });
      EduHttpClient.setLastLoginFailTimeForTest(
        DateTime.now().millisecondsSinceEpoch,
      );

      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 401,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      await expectLater(
        () => client.get('/need-auth'),
        throwsA(isA<AuthenticationException>()),
      );
      expect(loginCalled, 0);

      client.dispose();
    });

    test('should map 500 response into server exception', () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
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

      expect(() => client.get('/boom'), throwsA(isA<ServerException>()));

      client.dispose();
    });

    test('should map 429 response into rate limit network exception', () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 429,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      await expectLater(
        () => client.get('/rate-limit'),
        throwsA(
          isA<NetworkException>()
              .having((e) => e.statusCode, 'statusCode', 429)
              .having((e) => e.message, 'message', '已被限流，请稍后再试'),
        ),
      );

      client.dispose();
    });

    test('should block identical request during rate limit cooldown', () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');
      var nowMs = 1000;
      var networkHits = 0;
      EduHttpClient.setNowProviderForTest(() => nowMs);

      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            networkHits++;
            if (networkHits == 1) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response<dynamic>(
                    requestOptions: options,
                    statusCode: 429,
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
              return;
            }

            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{'ok': true},
              ),
            );
          },
        ),
      );

      await expectLater(
        () => client.get('/rate-limit-cooldown'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            '已被限流，请稍后再试',
          ),
        ),
      );

      await expectLater(
        () => client.get('/rate-limit-cooldown'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.statusCode,
            'statusCode',
            429,
          ),
        ),
      );

      expect(networkHits, 1);
      client.dispose();
    });

    test(
      'should not block different request signatures during cooldown',
      () async {
        final client = EduHttpClient(baseUrl: 'http://api.test');
        var nowMs = 2000;
        var networkHits = 0;
        EduHttpClient.setNowProviderForTest(() => nowMs);

        client.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              networkHits++;
              if (options.path == '/same-path' &&
                  options.queryParameters['page'] == 1) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    response: Response<dynamic>(
                      requestOptions: options,
                      statusCode: 429,
                    ),
                    type: DioExceptionType.badResponse,
                  ),
                );
                return;
              }

              handler.resolve(
                Response<dynamic>(
                  requestOptions: options,
                  statusCode: 200,
                  data: <String, dynamic>{'ok': true},
                ),
              );
            },
          ),
        );

        await expectLater(
          () => client.get(
            '/same-path',
            queryParameters: <String, dynamic>{'page': 1},
          ),
          throwsA(isA<NetworkException>()),
        );

        final differentQuery =
            await client.get(
                  '/same-path',
                  queryParameters: <String, dynamic>{'page': 2},
                )
                as Map<String, dynamic>;
        final differentPath =
            await client.get('/different-path') as Map<String, dynamic>;

        expect(differentQuery['ok'], isTrue);
        expect(differentPath['ok'], isTrue);
        expect(networkHits, 3);
        client.dispose();
      },
    );

    test(
      'should allow identical request after rate limit cooldown expires',
      () async {
        final client = EduHttpClient(baseUrl: 'http://api.test');
        var nowMs = 3000;
        var networkHits = 0;
        EduHttpClient.setNowProviderForTest(() => nowMs);

        client.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              networkHits++;
              if (networkHits == 1) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    response: Response<dynamic>(
                      requestOptions: options,
                      statusCode: 429,
                    ),
                    type: DioExceptionType.badResponse,
                  ),
                );
                return;
              }

              handler.resolve(
                Response<dynamic>(
                  requestOptions: options,
                  statusCode: 200,
                  data: <String, dynamic>{'ok': true},
                ),
              );
            },
          ),
        );

        await expectLater(
          () => client.get('/rate-limit-expire'),
          throwsA(isA<NetworkException>()),
        );

        nowMs += 5001;

        final data =
            await client.get('/rate-limit-expire') as Map<String, dynamic>;

        expect(data['ok'], isTrue);
        expect(networkHits, 2);
        client.dispose();
      },
    );

    test(
      'should relogin and retry when adapter returns 401 then 200',
      () async {
        secureStore[PrefsKeys.USERNAME] = 'u1';
        secureStore[PrefsKeys.PASSWORD] = 'p1';
        EduHttpClient.setLoginHandlerForTest((_, _) async {
          return <String, dynamic>{
            'success': true,
            'studentId': '2026001',
            'cookie': 'cookie-after-login',
          };
        });

        final client = EduHttpClient(baseUrl: 'http://api.test');
        client.dio.httpClientAdapter = _QueueAdapter([
          (_) => ResponseBody.fromString(
            '{"error":"unauthorized"}',
            401,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>['application/json'],
            },
          ),
          (options) {
            expect(options.headers['Cookie'], 'cookie-after-login');
            expect(options.headers['xauat'], 'cookie-after-login');
            return ResponseBody.fromString(
              '{"ok":true}',
              200,
              headers: <String, List<String>>{
                Headers.contentTypeHeader: <String>['application/json'],
              },
            );
          },
        ]);

        final data = await client.get('/protected') as Map<String, dynamic>;
        expect(data['ok'], isTrue);

        client.dispose();
      },
    );

    test(
      'should keep auth failure when relogin succeeds but retry still fails',
      () async {
        secureStore[PrefsKeys.USERNAME] = 'u1';
        secureStore[PrefsKeys.PASSWORD] = 'p1';
        EduHttpClient.setLoginHandlerForTest((_, _) async {
          return <String, dynamic>{
            'success': true,
            'studentId': '2026001',
            'cookie': 'cookie-after-login',
          };
        });

        final client = EduHttpClient(baseUrl: 'http://api.test');
        client.dio.httpClientAdapter = _QueueAdapter([
          (_) => ResponseBody.fromString(
            '{"error":"unauthorized"}',
            401,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>['application/json'],
            },
          ),
          (_) => throw DioException(
            requestOptions: RequestOptions(path: '/protected-fail'),
            type: DioExceptionType.connectionError,
            error: 'network down',
          ),
        ]);

        await expectLater(
          () => client.get('/protected-fail'),
          throwsA(isA<AuthenticationException>()),
        );

        client.dispose();
      },
    );

    test(
      'should not relogin twice when retry keeps returning 401',
      () async {
        // 研究生模式下访问尚未支持的成绩/考试接口就是这种情形：重登录本身
        // 成功，但原请求永远 401。没有一次性的重试闸，拦截器会无限递归。
        secureStore[PrefsKeys.USERNAME] = 'u1';
        secureStore[PrefsKeys.PASSWORD] = 'p1';
        var loginCalls = 0;
        EduHttpClient.setLoginHandlerForTest((_, _) async {
          loginCalls++;
          return <String, dynamic>{
            'success': true,
            'studentId': '2026001',
            'cookie': 'cookie-after-login',
          };
        });

        final client = EduHttpClient(baseUrl: 'http://api.test');
        client.dio.httpClientAdapter = _QueueAdapter([
          (_) => ResponseBody.fromString(
            '{"error":"unauthorized"}',
            401,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>['application/json'],
            },
          ),
          (_) => ResponseBody.fromString(
            '{"error":"unauthorized"}',
            401,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>['application/json'],
            },
          ),
        ]);

        await expectLater(
          () => client.get('/unsupported-endpoint'),
          throwsA(isA<AuthenticationException>()),
        );
        expect(loginCalls, 1);

        client.dispose();
      },
    );

    test(
      'reLoginWithLockForTest should succeed and persist fresh cookie',
      () async {
        secureStore[PrefsKeys.USERNAME] = 'u1';
        secureStore[PrefsKeys.PASSWORD] = 'p1';
        EduHttpClient.setLoginHandlerForTest((_, _) async {
          return <String, dynamic>{
            'success': true,
            'studentId': '2026001',
            'cookie': 'fresh-cookie',
          };
        });

        final client = EduHttpClient(baseUrl: 'http://api.test');
        final ok = await client.reLoginWithLockForTest();
        expect(ok, isTrue);
        expect(
          PrefsService.instance.getString(PrefsKeys.USER_DATA),
          contains('fresh-cookie'),
        );
        client.dispose();
      },
    );

    test('reLoginWithLockForTest should discard result after logout', () async {
      secureStore[PrefsKeys.USERNAME] = 'u1';
      secureStore[PrefsKeys.PASSWORD] = 'p1';
      await PrefsService.instance.remove(PrefsKeys.USER_DATA);

      EduHttpClient.setLoginHandlerForTest((_, _) async {
        // 模拟重登录请求还在途时用户点了退出登录。
        AuthSessionGuard.invalidate();
        return <String, dynamic>{
          'success': true,
          'studentId': '2026001',
          'cookie': 'stale-cookie',
        };
      });

      final client = EduHttpClient(baseUrl: 'http://api.test');
      final ok = await client.reLoginWithLockForTest();

      expect(ok, isFalse);
      expect(PrefsService.instance.getString(PrefsKeys.USER_DATA), isNull);
      client.dispose();
    });

    test(
      'reLoginWithLockForTest should return false during cooldown',
      () async {
        EduHttpClient.setLastLoginFailTimeForTest(
          DateTime.now().millisecondsSinceEpoch,
        );
        final client = EduHttpClient(baseUrl: 'http://api.test');

        final ok = await client.reLoginWithLockForTest();
        expect(ok, isFalse);

        client.dispose();
      },
    );

    test(
      'reLoginWithLockForTest should return false when credentials missing',
      () async {
        final client = EduHttpClient(baseUrl: 'http://api.test');

        final ok = await client.reLoginWithLockForTest();
        expect(ok, isFalse);

        client.dispose();
      },
    );

    test(
      'reLoginWithLockForTest should return false when login handler throws',
      () async {
        secureStore[PrefsKeys.USERNAME] = 'u1';
        secureStore[PrefsKeys.PASSWORD] = 'p1';
        EduHttpClient.setLoginHandlerForTest((_, _) async {
          throw Exception('forced failure');
        });
        final client = EduHttpClient(baseUrl: 'http://api.test');

        final ok = await client.reLoginWithLockForTest();
        expect(ok, isFalse);

        client.dispose();
      },
    );

    test(
      'reLoginWithLockForTest should use LoginApi fallback when test handler unset',
      () async {
        secureStore[PrefsKeys.USERNAME] = 'u2';
        secureStore[PrefsKeys.PASSWORD] = 'p2';
        LoginApi.setLoginOverrideForTest(
          (_, _) async => LoginResponse(
            success: true,
            studentId: '2026002',
            cookie: 'fallback-cookie',
          ),
        );
        final client = EduHttpClient(baseUrl: 'http://api.test');

        final ok = await client.reLoginWithLockForTest();
        expect(ok, isTrue);

        client.dispose();
      },
    );

    test('should map post dio error into network exception', () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 400,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      await expectLater(
        () => client.post('/bad-post', data: <String, dynamic>{'k': 'v'}),
        throwsA(isA<NetworkException>()),
      );

      client.dispose();
    });

    test('should map delete dio error into network exception', () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 404,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      await expectLater(
        () => client.delete('/bad-delete'),
        throwsA(isA<NetworkException>()),
      );

      client.dispose();
    });
  });
}
