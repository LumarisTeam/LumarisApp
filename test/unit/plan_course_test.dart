import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/plan_course.dart';

void main() {
  group('PlanCourse', () {
    test('should parse uppercase and lowercase keys', () {
      final upper = PlanCourse.fromJson(<String, dynamic>{
        'Name': '高等数学',
        'LessonType': '必修',
        'ExamMode': '考试',
        'CourseTypeName': '公共基础',
        'Credits': 4,
        'TermStr': '2025-2026-1',
      });
      final lower = PlanCourse.fromJson(<String, dynamic>{
        'name': '大学英语',
        'lessonType': '选修',
        'examMode': '考查',
        'courseTypeName': '通识',
        'credits': 2.5,
        'termStr': '2025-2026-2',
      });

      expect(upper.name, '高等数学');
      expect(upper.credits, 4.0);
      expect(lower.name, '大学英语');
      expect(lower.credits, 2.5);
      expect(lower.termStr, '2025-2026-2');
    });

    test('should convert to and from json string', () {
      final course = PlanCourse(
        name: '数据结构',
        lessonType: '必修',
        examMode: '考试',
        courseTypeName: '专业课',
        credits: 3.0,
        termStr: '2026-2027-1',
      );

      final encoded = course.toJsonString();
      final decoded = PlanCourse.fromJsonString(encoded);
      expect(decoded.name, '数据结构');
      expect(decoded.lessonType, '必修');
      expect(decoded.examMode, '考试');
      expect(decoded.courseTypeName, '专业课');
      expect(decoded.credits, 3.0);
      expect(decoded.termStr, '2026-2027-1');
    });
  });

  group('PlanCourseList', () {
    test('should return empty list when input json is empty', () {
      final list = PlanCourseList.fromJson(<String, dynamic>{});
      expect(list.term, '');
      expect(list.courses, isEmpty);
    });

    test('should parse and serialize term-course mapping', () {
      final list = PlanCourseList.fromJson(<String, dynamic>{
        '2025-2026-1': <Map<String, dynamic>>[
          <String, dynamic>{
            'Name': '操作系统',
            'LessonType': '必修',
            'ExamMode': '考试',
            'CourseTypeName': '专业课',
            'Credits': 3,
            'TermStr': '2025-2026-1',
          },
        ],
      });

      expect(list.term, '2025-2026-1');
      expect(list.courses.length, 1);
      expect(list.courses.first.name, '操作系统');
      expect(list.toJson().keys.single, '2025-2026-1');
    });

    test('fromMap should build courses with provided term', () {
      final list = PlanCourseList.fromMap('2026-2027-2', <Map<String, dynamic>>[
        <String, dynamic>{'name': '编译原理', 'credits': 3},
        <String, dynamic>{'name': '人工智能', 'credits': 2},
      ]);

      expect(list.term, '2026-2027-2');
      expect(list.courses.length, 2);
      expect(list.courses.first.name, '编译原理');
      expect(list.courses.last.credits, 2.0);
    });
  });
}
