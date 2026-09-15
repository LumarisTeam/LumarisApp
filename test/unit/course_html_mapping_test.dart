import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/course_html_parser.dart';

/// 一份能同时覆盖「有教师 / 无教师」两条路径的西建大课表。
const String _html = '''
<div class="course-table">
  <div class="time-table-body">
    <div class="columns weekday">
      <div class="card-view">
        <div class="card-content-code">CS201</div>
        <div class="card-content-info">
          数据结构
          信息楼B301
          (2~16周)
          (5,6节)
        </div>
      </div>
    </div>
  </div>
</div>
''';

/// 教师写在单元格里的通用矩阵表。
const String _withTeachers = '''
<table id="kbTable" class="timetable">
  <tr><th>节次</th><th>星期</th></tr>
  <tr><th></th><th>星期一</th></tr>
  <tr><td>第3-4节</td><td>大学物理<br>孙老师、周老师<br>1-16周<br>理科楼201</td></tr>
</table>
''';

void main() {
  group('Course -> CourseModel 映射', () {
    test('should_map_core_fields_from_curriculum_course', () {
      final course =
          CourseHtmlParser.parseHtml(_html, schoolCode: 'XAUAT').courses.single;

      expect(course.courseName, '数据结构');
      expect(course.room, '信息楼B301');
      expect(course.weekday, DateTime.monday);
      expect(course.startUnit, 5);
      expect(course.endUnit, 6);
      expect(course.weekIndexes,
          <int>[2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
    });

    test('should_leave_fields_the_page_does_not_provide_empty', () {
      final course =
          CourseHtmlParser.parseHtml(_html, schoolCode: 'XAUAT').courses.single;

      // 课程代码按设计丢弃：CourseModel 没有对应字段，curriculum 也没有。
      expect(course.courseCode, '');
      expect(course.credits, '');
      expect(course.lessonId, '');
      expect(course.campus, '');
      expect(course.isCustom, isFalse);
    });

    test('should_return_empty_teacher_list_when_page_has_no_teacher', () {
      final course =
          CourseHtmlParser.parseHtml(_html, schoolCode: 'XAUAT').courses.single;

      // 西建大页面不提供教师（卡片里没有师资信息）。
      expect(course.teachers, isEmpty);
    });

    test('should_split_teachers_on_chinese_enumeration_comma', () {
      final course = CourseHtmlParser.parseHtml(_withTeachers).courses.single;

      expect(course.teachers, <String>['孙老师', '周老师']);
    });

    test('should_keep_week_indexes_sorted_and_deduplicated', () {
      final course =
          CourseHtmlParser.parseHtml(_html, schoolCode: 'XAUAT').courses.single;

      final weeks = course.weekIndexes;
      expect(weeks, equals(<int>[...weeks]..sort()));
      expect(weeks.toSet().length, weeks.length);
      // CourseModel.formatWeekRanges 只合并「连续递增」的段，未排序会输出乱码。
      expect(weeks.first, lessThan(weeks.last));
    });
  });
}
