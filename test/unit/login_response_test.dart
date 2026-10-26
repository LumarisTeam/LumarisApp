import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/login_response.dart';

void main() {
  group('LoginResponse', () {
    test('should parse the documented login payload', () {
      final model = LoginResponse.fromJson(<String, dynamic>{
        'success': true,
        'studentId': '59769',
        'cookie': '**pstsid**=session-id; SESSION=session-token',
      });

      expect(model.success, isTrue);
      expect(model.studentId, '59769');
      expect(model.cookie, '**pstsid**=session-id; SESSION=session-token');
      expect(model.isSuccess, isTrue);
    });

    test('should default isSuccess to true when success is null', () {
      final model = LoginResponse.fromJson(<String, dynamic>{});
      expect(model.success, isNull);
      expect(model.isSuccess, isTrue);
      expect(model.toJson(), isEmpty);
    });

    test('toJson should only include non-null fields', () {
      final model = LoginResponse(success: true, cookie: 'session-cookie');

      final json = model.toJson();
      expect(json['success'], isTrue);
      expect(json['cookie'], 'session-cookie');
      expect(json.containsKey('studentId'), isFalse);
    });
  });
}
