import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/api_response.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/edu_api_models.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/features/education/models/raw_string_response.dart';

void main() {
  group('ApiResponse for CourseActivity', () {
    test('should deserialize v1 payload with envelope', () {
      final apiResponse = ApiResponse<List<CourseModel>>.parsed(
        <String, dynamic>{
          'code': 0,
          'message': 'ok',
          'total': 1,
          'data': <Map<String, dynamic>>[
            <String, dynamic>{
              'weekIndexes': <dynamic>[1, '2'],
              'teachers': <String>['T1'],
              'campus': 'Main',
              'room': 'A101',
              'courseName': 'Math',
              'courseCode': 'M101',
              'weekday': '1',
              'startUnit': 1,
              'endUnit': '2',
              'credits': '3.0',
              'lessonId': 'L1',
            },
          ],
        },
        (data) => (data as List<dynamic>)
            .map((e) => CourseModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

      expect(apiResponse.isSuccess, isTrue);
      expect(apiResponse.data!.single.courseName, 'Math');
      expect(apiResponse.data!.single.weekIndexes, <int>[1, 2]);
      expect(apiResponse.data!.single.endUnit, 2);
    });

    test('should handle bare response without envelope', () {
      final apiResponse = ApiResponse<List<CourseModel>>.parsed(
        <Map<String, dynamic>>[
          <String, dynamic>{
            'weekIndexes': <dynamic>[1, 2],
            'teachers': <String>['T2'],
            'campus': 'East',
            'room': 'B201',
            'courseName': 'Physics',
            'courseCode': 'P201',
            'weekday': 2,
            'startUnit': 3,
            'endUnit': 4,
            'credits': '4.0',
            'lessonId': 'L2',
          },
        ],
        (data) => (data as List<dynamic>)
            .map((e) => CourseModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

      expect(apiResponse.isSuccess, isTrue); // null code → success
      expect(apiResponse.data!.single.courseName, 'Physics');
    });
  });

  group('ExamResponse', () {
    test('should round-trip exams list', () {
      final response = ExamResponse.fromJson(<String, dynamic>{
        'exams': <Map<String, dynamic>>[
          <String, dynamic>{
            'name': '线性代数',
            'time': '2026-01-10 08:00~10:00',
            'location': 'A101',
            'seat': '08',
          },
        ],
        'canClick': true,
        'error': null,
      });

      expect(response.canClick, isTrue);
      expect(response.exams.single.room, 'A101');
      expect(response.toJson()['exams'], hasLength(1));
    });
  });

  group('SemesterResult', () {
    test('should parse value-text items only', () {
      final result = SemesterResult.fromJson(<String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{'value': '2025-2', 'text': '2025-2026-2'},
        ],
      });

      expect(result.data.single.semester, '2025-2');
      expect(result.data.single.name, '2025-2026-2');
    });
  });

  group('PaymentData', () {
    test('should parse payment turnover payload', () {
      final result = PaymentData.fromJson(<String, dynamic>{
        'records': <Map<String, dynamic>>[
          <String, dynamic>{
            'turnoverType': '消费',
            'datetimeStr': '2026-03-23 12:00:00',
            'resume': '食堂',
            'tranamt': '1500',
          },
        ],
        'balance': '88.5',
      });

      expect(result.payments.single.amount, 1500);
      expect(result.balance, 88.5);
    });
  });

  group('Electricity subscription models', () {
    test('should serialize create subscription request', () {
      const request = CreateElectricitySubscriptionRequest(
        url: 'https://example.com/wxAccount?id=1',
        email: 'codex@example.com',
        threshold: 9.8,
      );

      expect(request.toJson(), <String, dynamic>{
        'url': 'https://example.com/wxAccount?id=1',
        'email': 'codex@example.com',
        'threshold': 9.8,
      });
    });

    test('should deserialize subscription query response', () {
      final response =
          ElectricitySubscriptionQueryResponse.fromJson(<String, dynamic>{
            'email': 'codex@example.com',
            'hasSubscription': true,
            'subscriptionId': 'sub-1',
            'threshold': '12.5',
          });

      expect(response.email, 'codex@example.com');
      expect(response.hasSubscription, isTrue);
      expect(response.subscriptionId, 'sub-1');
      expect(response.threshold, 12.5);
      expect(response.toJson()['subscriptionId'], 'sub-1');
    });

    test('should deserialize subscription response with nullable fields', () {
      final response =
          ElectricitySubscriptionResponse.fromJson(<String, dynamic>{
            'id': 'sub-1',
            'url': 'https://example.com/wxAccount?id=1',
            'email': 'codex@example.com',
            'threshold': '10.5',
            'isActive': true,
            'createdAt': '2026-05-01T10:00:00Z',
            'updatedAt': '2026-05-01T10:30:00Z',
            'nextCheckAt': '2026-05-01T11:00:00Z',
            'lastCheckedAt': null,
            'lastKnownBalance': '15.0',
            'lastAlertedAt': null,
            'lastAlertedBalance': null,
            'lastErrorMessage': '',
          });

      expect(response.id, 'sub-1');
      expect(response.threshold, 10.5);
      expect(response.createdAt, DateTime.parse('2026-05-01T10:00:00Z'));
      expect(response.lastKnownBalance, 15.0);
      expect(response.lastCheckedAt, isNull);
      expect(response.toJson()['email'], 'codex@example.com');
    });
  });

  group('RawStringResponse', () {
    test('should wrap raw string responses', () {
      final result = RawStringResponse.fromResponse('plain-text-response');
      expect(result.value, 'plain-text-response');
      expect(result.toJson(), <String, dynamic>{
        'value': 'plain-text-response',
      });
    });
  });
}
