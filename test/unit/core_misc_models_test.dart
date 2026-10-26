import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/course_time.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'package:ios_club_app/features/education/models/week_info.dart';

void main() {
  group('UserData', () {
    test('should parse from json', () {
      final model = UserData.fromJson(<String, dynamic>{
        'studentId': '20261234',
        'cookie': 'sid=abc',
      });
      expect(model.studentId, '20261234');
      expect(model.cookie, 'sid=abc');
    });
  });

  group('WeekInfo', () {
    test('should parse with defaults', () {
      final model = WeekInfo.fromJson(<String, dynamic>{});
      expect(model.week, 0);
      expect(model.maxWeek, 0);
      expect(model.toJson(), <String, dynamic>{'week': 0, 'maxWeek': 0});
    });
  });

  group('CourseTime', () {
    test('difference should return startTime minus input time', () {
      final start = DateTime(2026, 3, 2, 10, 0);
      final end = DateTime(2026, 3, 2, 11, 30);
      final model = CourseTime(
        startTime: start,
        courseName: '高数',
        endTime: end,
      );

      final diff = model.difference(DateTime(2026, 3, 2, 9, 30));
      expect(diff, const Duration(minutes: 30));
      expect(model.courseName, '高数');
      expect(model.endTime, end);
    });
  });
}
