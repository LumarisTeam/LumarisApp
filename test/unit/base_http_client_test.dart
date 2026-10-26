import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/base_http_client.dart';

void main() {
  group('BaseHttpClient', () {
    test(
      'should safely extract special-character query values from path',
      () async {
        final client = BaseHttpClient(
          baseUrl: 'https://api.test',
          enableCache: false,
        );
        const specialPassword = r'p?%$&=+/你好';

        client.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              expect(options.uri.path, '/login');
              expect(options.queryParameters, <String, dynamic>{
                'username': 'test_user',
                'password': specialPassword,
              });

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

        final result = await client.get(
          '/login?username=test_user&password=${Uri.encodeQueryComponent(specialPassword)}',
        );

        expect(result, <String, dynamic>{'ok': true});
        client.dispose();
      },
    );

    test(
      'should let explicit query parameters override same-name path values',
      () async {
        final client = BaseHttpClient(
          baseUrl: 'https://api.test',
          enableCache: false,
        );
        const overridePassword = r'new?%$&value';

        client.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              expect(options.uri.path, '/login');
              expect(options.queryParameters, <String, dynamic>{
                'username': 'override_user',
                'password': overridePassword,
              });

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

        final result = await client.get(
          '/login?username=old_user&password=old_password',
          queryParameters: <String, dynamic>{
            'username': 'override_user',
            'password': overridePassword,
          },
        );

        expect(result, <String, dynamic>{'ok': true});
        client.dispose();
      },
    );
  });
}
