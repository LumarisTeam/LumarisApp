import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/retry_policy.dart';

void main() {
  group('RetryPolicy', () {
    test(
      'defaultShouldRetry should return true for timeout and connection errors',
      () {
        final request = RequestOptions(path: '/x');

        final timeout = DioException(
          requestOptions: request,
          type: DioExceptionType.connectionTimeout,
        );
        final sendTimeout = DioException(
          requestOptions: request,
          type: DioExceptionType.sendTimeout,
        );
        final receiveTimeout = DioException(
          requestOptions: request,
          type: DioExceptionType.receiveTimeout,
        );
        final connectionError = DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        );

        expect(RetryPolicy.defaultShouldRetry(timeout), isTrue);
        expect(RetryPolicy.defaultShouldRetry(sendTimeout), isTrue);
        expect(RetryPolicy.defaultShouldRetry(receiveTimeout), isTrue);
        expect(RetryPolicy.defaultShouldRetry(connectionError), isTrue);
      },
    );

    test('defaultShouldRetry should return true for 5xx and false for 4xx', () {
      final request = RequestOptions(path: '/x');
      final serverError = DioException(
        requestOptions: request,
        response: Response<dynamic>(requestOptions: request, statusCode: 500),
      );
      final forbidden = DioException(
        requestOptions: request,
        response: Response<dynamic>(requestOptions: request, statusCode: 403),
      );
      final rateLimited = DioException(
        requestOptions: request,
        response: Response<dynamic>(requestOptions: request, statusCode: 429),
      );

      expect(RetryPolicy.defaultShouldRetry(serverError), isTrue);
      expect(RetryPolicy.defaultShouldRetry(forbidden), isFalse);
      expect(RetryPolicy.defaultShouldRetry(rateLimited), isFalse);
    });

    test('predefined policies should expose expected limits and delays', () {
      expect(RetryPolicy.defaultPolicy.maxRetries, 2);
      expect(RetryPolicy.defaultPolicy.delayFactor(0).inMilliseconds, 500);
      expect(RetryPolicy.defaultPolicy.delayFactor(2).inMilliseconds, 1500);

      expect(RetryPolicy.fast.maxRetries, 3);
      expect(RetryPolicy.fast.delayFactor(0).inMilliseconds, 300);
      expect(RetryPolicy.fast.delayFactor(2).inMilliseconds, 900);

      expect(RetryPolicy.none.maxRetries, 0);
    });
  });

  group('DioErrorHandler', () {
    test('handleErrorResponse should map status code to typed exceptions', () {
      expect(
        () => DioErrorHandler.handleErrorResponse(401, 'unauthorized'),
        throwsA(isA<AuthenticationException>()),
      );
      expect(
        () => DioErrorHandler.handleErrorResponse(403, 'forbidden'),
        throwsA(isA<AuthorizationException>()),
      );
      expect(
        () => DioErrorHandler.handleErrorResponse(404, 'not found'),
        throwsA(isA<NotFoundException>()),
      );
      expect(
        () => DioErrorHandler.handleErrorResponse(500, 'server error'),
        throwsA(isA<ServerException>()),
      );
      expect(
        () => DioErrorHandler.handleErrorResponse(429, 'too many'),
        throwsA(
          isA<NetworkException>()
              .having((e) => e.statusCode, 'statusCode', 429)
              .having((e) => e.message, 'message', '已被限流，请稍后再试'),
        ),
      );
    });

    test('handleError should map timeout and generic errors', () {
      final request = RequestOptions(path: '/x');
      final timeoutError = DioException(
        requestOptions: request,
        type: DioExceptionType.receiveTimeout,
      );
      final unknownError = DioException(
        requestOptions: request,
        message: 'socket closed',
      );

      expect(
        () => DioErrorHandler.handleError(timeoutError),
        throwsA(isA<TimeoutException>()),
      );

      expect(
        () => DioErrorHandler.handleError(unknownError),
        throwsA(
          isA<NetworkException>().having((e) => e.statusCode, 'statusCode', -1),
        ),
      );
    });

    test(
      'handleError should use response status mapping when response exists',
      () {
        final request = RequestOptions(path: '/x');
        final responseError = DioException(
          requestOptions: request,
          response: Response<dynamic>(
            requestOptions: request,
            statusCode: 404,
            data: 'missing',
          ),
        );

        expect(
          () => DioErrorHandler.handleError(responseError),
          throwsA(isA<NotFoundException>()),
        );
      },
    );
  });
}
