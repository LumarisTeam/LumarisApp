import 'package:curriculum/warehouse.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';

void main() {
  tearDown(TimeService.clearImportedTable);

  test('导入作息优先于内置表并统一校区', () {
    TimeService.installImportedSlots(<TimeSlot>[
      const TimeSlot(number: 1, startTime: '08:00', endTime: '08:45'),
      const TimeSlot(number: 2, startTime: '08:55', endTime: '09:40'),
    ]);

    expect(TimeService.isUsingImportedTable, isTrue);
    expect(TimeService.defaultCampusName, TimeService.importedCampus);
    expect(TimeService.tables.first.campusName, TimeService.importedCampus);

    final course = CourseModel(weekday: 1, startUnit: 1, endUnit: 2, campus: '草堂校区');
    expect(TimeService.resolveCampusName(course), TimeService.importedCampus);

    final time = TimeService.getStartAndEnd(course);
    expect(time.start, '08:00');
    expect(time.end, '09:40');

    // 显式查询草堂/雁塔也应落到导入表。
    final axis = TimeService.getStartAndEndForCampus(
      campus: TimeService.caoTangCampus,
      startUnit: 2,
      endUnit: 2,
    );
    expect(axis.start, '08:55');
    expect(axis.end, '09:40');
  });

  test('自定义时间课程优先使用自身 HH:mm', () {
    final course = CourseModel(
      weekday: 1,
      startUnit: 3,
      endUnit: 4,
      isCustomTime: true,
      customStartTime: '14:05',
      customEndTime: '15:25',
    );

    final time = TimeService.getStartAndEnd(course);
    expect(time.start, '14:05');
    expect(time.end, '15:25');
  });

  test('清除导入表后恢复默认校区', () {
    TimeService.installImportedSlots(<TimeSlot>[
      const TimeSlot(number: 1, startTime: '08:00', endTime: '08:45'),
    ]);
    TimeService.clearImportedTable();

    expect(TimeService.isUsingImportedTable, isFalse);
    expect(TimeService.defaultCampusName, TimeService.caoTangCampus);
    expect(
      TimeService.resolveCampusName(CourseModel(campus: '')),
      TimeService.yanTaCampus,
    );
  });
}
