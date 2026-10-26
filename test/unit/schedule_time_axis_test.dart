import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_time_axis.dart';

CourseModel _course({
  int startUnit = 1,
  int endUnit = 2,
  String campus = TimeService.caoTangCampus,
}) {
  return CourseModel(
    courseName: '高等数学',
    room: 'A101',
    teachers: const ['张老师'],
    weekday: 1,
    startUnit: startUnit,
    endUnit: endUnit,
    campus: campus,
  );
}

void main() {
  setUp(TimeService.useBuiltInTables);

  group('ScheduleTimeAxis', () {
    test('should use 12 rows', () {
      expect(ScheduleTimeAxis.sectionRowCount, 12);
    });

    test('should position a course by section units', () {
      final geometry = ScheduleTimeAxis.geometryFor(
        _course(startUnit: 3, endUnit: 4),
        50,
      );

      expect(geometry.top, 100);
      expect(geometry.height, 100);
      expect(geometry.timeLabel, isNull);
    });

    test('should show start time when requested', () {
      final geometry = ScheduleTimeAxis.geometryFor(
        _course(),
        50,
        showStartTime: true,
      );

      expect(geometry.timeLabel, '8:30');
    });

    test('should clamp invalid section units', () {
      final geometry = ScheduleTimeAxis.geometryFor(
        _course(startUnit: 0, endUnit: 99),
        50,
      );

      expect(geometry.top, 0);
      expect(geometry.height, 12 * 50);
    });
  });
}
