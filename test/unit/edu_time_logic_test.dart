import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/utils/week_start_utils.dart';
import 'package:ios_club_app/features/education/services/edu_time_service.dart';

void main() {
  group('EduTimeService.getWeekIndexByStartTime', () {
    // 假设第一周开始时间是 2024-03-04 (周一)
    // 根据逻辑，第一周的周日是 2024-03-03 (虽然在日期上它属于前一周，但计算周数时作为起点)
    final startTime = DateTime(2024, 3, 4);

    test('should return 1 for a date in the first week (Monday)', () {
      final now = DateTime(2024, 3, 4);
      expect(EduTimeService.getWeekIndexByStartTime(now, startTime), 1);
    });

    test('should return 1 for the Sunday of the first week', () {
      // 2024-03-03 是周日
      final now = DateTime(2024, 3, 3);
      expect(EduTimeService.getWeekIndexByStartTime(now, startTime), 1);
    });

    test('should return 2 for the Monday of the second week', () {
      // 2024-03-11 是周一
      final now = DateTime(2024, 3, 11);
      expect(EduTimeService.getWeekIndexByStartTime(now, startTime), 2);
    });

    test('should return 2 for the Sunday of the second week', () {
      // 2024-03-10 是周日
      final now = DateTime(2024, 3, 10);
      expect(EduTimeService.getWeekIndexByStartTime(now, startTime), 2);
    });

    test(
        'should correctly transition from Saturday to Sunday (start of new week)',
        () {
      final saturday = DateTime(2024, 3, 9);
      final sunday = DateTime(2024, 3, 10);

      expect(EduTimeService.getWeekIndexByStartTime(saturday, startTime), 1);
      expect(EduTimeService.getWeekIndexByStartTime(sunday, startTime), 2);
    });

    test('should keep dates before a Sunday semester start in week zero', () {
      final sundayStart = DateTime(2024, 3, 10);
      final friday = DateTime(2024, 3, 8);
      final saturday = DateTime(2024, 3, 9);
      final sunday = DateTime(2024, 3, 10);

      expect(
        EduTimeService.getWeekIndexByStartTime(friday, sundayStart),
        0,
      );
      expect(
        EduTimeService.getWeekIndexByStartTime(saturday, sundayStart),
        0,
      );
      expect(
        EduTimeService.getWeekIndexByStartTime(sunday, sundayStart),
        1,
      );
    });

    test('should keep same week from Sunday to Monday', () {
      final sunday = DateTime(2024, 3, 10);
      final monday = DateTime(2024, 3, 11);

      expect(EduTimeService.getWeekIndexByStartTime(sunday, startTime), 2);
      expect(EduTimeService.getWeekIndexByStartTime(monday, startTime), 2);
    });

    test('should keep Monday to Sunday in same week for Monday start', () {
      final monday = DateTime(2024, 3, 4);
      final sunday = DateTime(2024, 3, 10);
      final nextMonday = DateTime(2024, 3, 11);

      expect(
        EduTimeService.getWeekIndexByStartTime(
          monday,
          startTime,
          weekStartDay: DateTime.monday,
        ),
        1,
      );
      expect(
        EduTimeService.getWeekIndexByStartTime(
          sunday,
          startTime,
          weekStartDay: DateTime.monday,
        ),
        1,
      );
      expect(
        EduTimeService.getWeekIndexByStartTime(
          nextMonday,
          startTime,
          weekStartDay: DateTime.monday,
        ),
        2,
      );
    });

    test('should align first week when semester does not start on week start',
        () {
      final wednesdayStart = DateTime(2024, 3, 6);
      final monday = DateTime(2024, 3, 4);
      final sunday = DateTime(2024, 3, 10);
      final nextMonday = DateTime(2024, 3, 11);

      expect(
        EduTimeService.getWeekIndexByStartTime(
          monday,
          wednesdayStart,
          weekStartDay: DateTime.monday,
        ),
        1,
      );
      expect(
        EduTimeService.getWeekIndexByStartTime(
          sunday,
          wednesdayStart,
          weekStartDay: DateTime.monday,
        ),
        1,
      );
      expect(
        EduTimeService.getWeekIndexByStartTime(
          nextMonday,
          wednesdayStart,
          weekStartDay: DateTime.monday,
        ),
        2,
      );
    });
  });

  group('WeekStartUtils.orderedWeekdays', () {
    test('should order weekdays from Sunday by default', () {
      expect(
        WeekStartUtils.orderedWeekdays(DateTime.sunday),
        [
          DateTime.sunday,
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
        ],
      );
    });

    test('should order weekdays from Monday for Monday start', () {
      expect(
        WeekStartUtils.orderedWeekdays(DateTime.monday),
        [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday,
        ],
      );
    });
  });
}
