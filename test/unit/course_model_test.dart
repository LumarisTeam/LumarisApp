import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';

void main() {
  group('CourseModel', () {
    test('should create instance with default values', () {
      final course = CourseModel();

      expect(course.weekIndexes, isEmpty);
      expect(course.teachers, isEmpty);
      expect(course.room, isEmpty);
      expect(course.courseName, isEmpty);
      expect(course.courseCode, isEmpty);
      expect(course.weekday, 0);
      expect(course.startUnit, 0);
      expect(course.endUnit, 0);
      expect(course.credits, isEmpty);
      expect(course.lessonId, isEmpty);
      expect(course.campus, isEmpty);
    });

    test('should create instance with provided values', () {
      final course = CourseModel(
        weekIndexes: [1, 2, 3],
        teachers: ['Teacher A', 'Teacher B'],
        room: 'Room 101',
        courseName: 'Mathematics',
        courseCode: 'MATH101',
        weekday: 1,
        startUnit: 2,
        endUnit: 4,
        credits: '3.0',
        lessonId: 'lesson_123',
        campus: 'Main Campus',
      );

      expect(course.weekIndexes, [1, 2, 3]);
      expect(course.teachers, ['Teacher A', 'Teacher B']);
      expect(course.room, 'Room 101');
      expect(course.courseName, 'Mathematics');
      expect(course.courseCode, 'MATH101');
      expect(course.weekday, 1);
      expect(course.startUnit, 2);
      expect(course.endUnit, 4);
      expect(course.credits, '3.0');
      expect(course.lessonId, 'lesson_123');
      expect(course.campus, 'Main Campus');
    });

    test('should create instance from JSON', () {
      final json = {
        'weekIndexes': [1, 3, 5],
        'teachers': ['Prof. Smith', 'Dr. Jones'],
        'room': 'A201',
        'courseName': 'Physics',
        'courseCode': 'PHYS101',
        'weekday': 3,
        'startUnit': 1,
        'endUnit': 3,
        'credits': '4.0',
        'lessonId': 'phys101_001',
        'campus': 'East Campus',
      };

      final course = CourseModel.fromJson(json);

      expect(course.weekIndexes, [1, 3, 5]);
      expect(course.teachers, ['Prof. Smith', 'Dr. Jones']);
      expect(course.room, 'A201');
      expect(course.courseName, 'Physics');
      expect(course.courseCode, 'PHYS101');
      expect(course.weekday, 3);
      expect(course.startUnit, 1);
      expect(course.endUnit, 3);
      expect(course.credits, '4.0');
      expect(course.lessonId, 'phys101_001');
      expect(course.campus, 'East Campus');
    });

    test('should handle missing JSON fields gracefully', () {
      final json = <String, dynamic>{};
      final course = CourseModel.fromJson(json);

      expect(course.weekIndexes, isEmpty);
      expect(course.teachers, isEmpty);
      expect(course.room, isEmpty);
      expect(course.courseName, isEmpty);
      expect(course.courseCode, isEmpty);
      expect(course.weekday, 0);
      expect(course.startUnit, 0);
      expect(course.endUnit, 0);
      expect(course.credits, isEmpty);
      expect(course.lessonId, isEmpty);
      expect(course.campus, isEmpty);
    });

    test('should handle boundary values for weekday', () {
      final courseMin = CourseModel(weekday: -1);
      final courseMax = CourseModel(weekday: 7);
      final courseValid = CourseModel(weekday: 6);

      expect(courseMin.weekday, -1);
      expect(courseMax.weekday, 7);
      expect(courseValid.weekday, 6);
    });

    test('should handle boundary values for startUnit and endUnit', () {
      final course = CourseModel(startUnit: -1, endUnit: 10);

      expect(course.startUnit, -1);
      expect(course.endUnit, 10);
    });
  });

  group('CourseModel.formatWeekRanges', () {
    test('should return empty string for empty list', () {
      expect(CourseModel.formatWeekRanges([]), '');
    });

    test('should return single number for single week', () {
      expect(CourseModel.formatWeekRanges([5]), '5');
      expect(CourseModel.formatWeekRanges([1]), '1');
      expect(CourseModel.formatWeekRanges([20]), '20');
    });

    test('should format consecutive weeks into range', () {
      expect(CourseModel.formatWeekRanges([1, 2, 3, 4, 5]), '1-5');
      expect(CourseModel.formatWeekRanges([6, 7, 8]), '6-8');
    });

    test('should format non-consecutive weeks into separate ranges', () {
      expect(CourseModel.formatWeekRanges([1, 2, 3, 5, 6, 7]), '1-3,5-7');
      expect(CourseModel.formatWeekRanges([1, 3, 5, 7]), '1,3,5,7');
      expect(CourseModel.formatWeekRanges([1, 2, 4, 5, 7]), '1-2,4-5,7');
    });

    test('should handle single range with two weeks', () {
      expect(CourseModel.formatWeekRanges([1, 2]), '1-2');
      expect(CourseModel.formatWeekRanges([19, 20]), '19-20');
    });

    test('should handle large week numbers', () {
      expect(
        CourseModel.formatWeekRanges([10, 11, 12, 15, 16, 20]),
        '10-12,15-16,20',
      );
      expect(CourseModel.formatWeekRanges([100]), '100');
      expect(CourseModel.formatWeekRanges([99, 100, 101]), '99-101');
    });

    test('should handle unordered week numbers', () {
      // Note: The method expects ordered input, so unordered input may produce unexpected results
      // This test verifies the current behavior with unordered input
      expect(CourseModel.formatWeekRanges([3, 2, 1]), '3,2,1');
      expect(CourseModel.formatWeekRanges([5, 3, 4, 1, 2]), '5,3-4,1-2');
    });

    test('should handle duplicate week numbers', () {
      // Note: The method doesn't handle duplicates, so this test verifies current behavior
      expect(CourseModel.formatWeekRanges([1, 1, 2, 2, 3]), '1,1-2,2-3');
    });
  });

  group('CourseModel.mergeSameNameCourses', () {
    test('should_merge_courses_with_same_name_and_time', () {
      final courses = [
        CourseModel(
          courseName: '数学',
          teachers: ['老师甲'],
          room: 'A101',
          startUnit: 1,
          endUnit: 2,
        ),
        CourseModel(
          courseName: '数学',
          teachers: ['老师乙', '老师甲'],
          room: 'A101',
          startUnit: 1,
          endUnit: 2,
        ),
        CourseModel(
          courseName: '英语',
          teachers: ['老师丙'],
          startUnit: 1,
          endUnit: 2,
        ),
      ];

      final merged = CourseModel.mergeSameNameCourses(courses);

      expect(merged, hasLength(2));
      expect(merged.first.courseName, '数学');
      expect(merged.first.teachers, ['老师甲', '老师乙']);
      expect(merged.last.courseName, '英语');
    });

    test('should_keep_courses_with_different_times_separate', () {
      final courses = [
        CourseModel(
          courseName: '数学',
          teachers: ['老师甲'],
          startUnit: 1,
          endUnit: 2,
        ),
        CourseModel(
          courseName: '数学',
          teachers: ['老师乙'],
          startUnit: 3,
          endUnit: 4,
        ),
      ];

      expect(CourseModel.mergeSameNameCourses(courses), hasLength(2));
    });
  });
}
