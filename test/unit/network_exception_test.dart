import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/network_exception.dart';

void main() {
  group('NetworkException', () {
    test('should format toString with status code', () {
      final e = NetworkException('bad gateway', 502);
      expect(e.toString(), 'NetworkException: bad gateway (Status code: 502)');
    });

    test('should format toString without status code', () {
      final e = NetworkException('offline');
      expect(e.toString(), 'NetworkException: offline');
    });
  });

  group('Specialized exceptions', () {
    test('should set expected status codes', () {
      expect(AuthenticationException('auth').statusCode, 401);
      expect(AuthorizationException('forbidden').statusCode, 403);
      expect(NotFoundException('missing').statusCode, 404);
      expect(ServerException('server').statusCode, 500);
      expect(TimeoutException().statusCode, 408);
    });
  });
}
