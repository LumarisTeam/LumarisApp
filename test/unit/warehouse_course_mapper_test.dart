import 'package:curriculum/warehouse.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/features/education/services/warehouse_course_mapper.dart';

void main() {
  group('WarehouseCourseMapper', () {
    test('把节次课程映射为 CourseModel', () {
      final result = WarehouseCourseMapper.toCourseModels(<Course>[
        Course(
          id: 'lesson-1',
          name: '高等数学',
          teacher: '张三,李四',
          position: '教1-101',
          day: 1,
          startSection: 1,
          endSection: 2,
          weeks: <int>[1, 2, 3],
          credit: 4.5,
        ),
      ]);

      expect(result.courses, hasLength(1));
      expect(result.skipped, 0);
      final course = result.courses.single;
      expect(course.courseName, '高等数学');
      expect(course.teachers, <String>['张三', '李四']);
      expect(course.room, '教1-101');
      expect(course.weekday, 1);
      expect(course.startUnit, 1);
      expect(course.endUnit, 2);
      expect(course.weekIndexes, <int>[1, 2, 3]);
      expect(course.lessonId, 'lesson-1');
      expect(course.credits, '4.5');
    });

    test('自定义时间与越界节次被跳过', () {
      final result = WarehouseCourseMapper.toCourseModels(<Course>[
        Course(
          name: '讲座',
          day: 3,
          isCustomTime: true,
          customStartTime: '14:00',
          customEndTime: '15:30',
        ),
        Course(
          name: '越界课程',
          day: 2,
          startSection: 1,
          endSection: 13,
        ),
        Course(
          name: '正常课程',
          day: 2,
          startSection: 3,
          endSection: 4,
        ),
      ]);

      expect(result.courses, hasLength(1));
      expect(result.courses.single.courseName, '正常课程');
      expect(result.skippedCustomTime, 1);
      expect(result.skippedOutOfRange, 1);
    });

    test('周次为空时用学期总周数补全', () {
      final result = WarehouseCourseMapper.toCourseModels(
        <Course>[
          Course(
            name: '体育',
            day: 5,
            startSection: 5,
            endSection: 6,
          ),
        ],
        fallbackWeeks: 18,
      );

      expect(result.courses.single.weekIndexes, List<int>.generate(18, (i) => i + 1));
    });

    test('自定义时间映射到最近的节次并保留原始时间', () {
      const table = ScheduleTable(
        campusName: '测试',
        start: <String>['', '08:00', '08:55', '10:00', '10:55'],
        end: <String>['', '08:45', '09:40', '10:45', '11:40'],
      );

      final result = WarehouseCourseMapper.toCourseModels(
        <Course>[
          Course(
            name: '讲座',
            day: 3,
            isCustomTime: true,
            customStartTime: '08:50',
            customEndTime: '09:35',
          ),
        ],
        table: table,
      );

      expect(result.courses, hasLength(1));
      final course = result.courses.single;
      expect(course.startUnit, 2);
      expect(course.endUnit, 2);
      expect(course.isCustomTime, isTrue);
      expect(course.customStartTime, '08:50');
      expect(course.customEndTime, '09:35');
    });

    test('没有作息表时无法映射自定义时间课程', () {
      final result = WarehouseCourseMapper.toCourseModels(<Course>[
        Course(
          name: '讲座',
          day: 3,
          isCustomTime: true,
          customStartTime: '14:00',
          customEndTime: '15:30',
        ),
      ]);

      expect(result.courses, isEmpty);
      expect(result.skippedCustomTime, 1);
    });
  });
}
