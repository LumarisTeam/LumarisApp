import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/course_html_parser.dart';

/// 西建大课表页面：一列一天，卡片里用括号子句写周次与节次。
const String _xauatHtml = '''
<div class="course-table">
  <div class="time-table-body">
    <div class="columns weekday">
      <div class="card-view">
        <div class="card-content-code">MATH101</div>
        <div class="card-content-info">
          高等数学
          教一101
          (1~2周)
          (1,2节)
        </div>
      </div>
    </div>
    <div class="columns weekday"></div>
    <div class="columns weekday"></div>
    <div class="columns weekday"></div>
    <div class="columns weekday"></div>
    <div class="columns weekday"></div>
    <div class="columns weekday">
      <div class="card-view">
        <div class="card-content-code">ENG201</div>
        <div class="card-content-info">
          大学英语
          教二202
          (3周)
          (3,4节)
        </div>
      </div>
    </div>
  </div>
</div>
''';

/// 通用「星期 × 节次」矩阵表，用来验证自动探测路径。
const String _standardGridHtml = '''
<table id="kbTable" class="timetable">
  <tr><th>节次</th><th>星期</th></tr>
  <tr><th></th><th>星期一</th></tr>
  <tr>
    <td>第1-2节</td>
    <td>高等数学<br>张伟,李娜<br>1-16周<br>凌云楼101</td>
  </tr>
</table>
''';

void main() {
  group('CourseHtmlParser', () {
    test('should_map_monday_first_columns_to_datetime_weekday_values', () {
      final result = CourseHtmlParser.parseHtml(_xauatHtml);

      expect(result.courses, hasLength(2));
      expect(result.courses.first.weekday, DateTime.monday);
      expect(result.courses.last.weekday, DateTime.sunday);
    });

    test('should_use_school_adapter_when_school_code_matches', () {
      final result =
          CourseHtmlParser.parseHtml(_xauatHtml, schoolCode: 'XAUAT');

      expect(result.adapterId, 'XAUAT_01');
      expect(result.courses, hasLength(2));
    });

    test('should_be_case_insensitive_for_school_code', () {
      final result =
          CourseHtmlParser.parseHtml(_xauatHtml, schoolCode: 'xauat');

      expect(result.adapterId, 'XAUAT_01');
    });

    test('should_fall_back_to_autodetect_when_school_has_no_adapter', () {
      final result = CourseHtmlParser.parseHtml(
        _standardGridHtml,
        schoolCode: 'NOT_A_REAL_SCHOOL',
      );

      expect(result.courses, hasLength(1));
      expect(result.courses.single.courseName, '高等数学');
    });

    test('should_fall_back_to_autodetect_when_adapter_yields_nothing', () {
      // 选了西建大，但页面其实是通用矩阵表 -> 本校适配器解析不出东西，回退自动探测。
      final result = CourseHtmlParser.parseHtml(
        _standardGridHtml,
        schoolCode: 'XAUAT',
      );

      expect(result.courses, hasLength(1));
      expect(result.adapterId, isNot('XAUAT_01'));
    });

    test('should_parse_sections_and_weeks_from_parenthesized_clauses', () {
      final result = CourseHtmlParser.parseHtml(_xauatHtml);

      final math = result.courses.first;
      expect(math.courseName, '高等数学');
      expect(math.room, '教一101');
      expect(math.startUnit, 1);
      expect(math.endUnit, 2);
      expect(math.weekIndexes, <int>[1, 2]);
    });

    test('should_expand_odd_week_clause', () {
      const html = '''
<div class="course-table">
  <div class="time-table-body">
    <div class="columns weekday">
      <div class="card-view">
        <div class="card-content-info">
          线性代数
          教二202
          (1~8周(单))
          (3,4节)
        </div>
      </div>
    </div>
  </div>
</div>
''';
      final result = CourseHtmlParser.parseHtml(html);

      expect(result.courses.single.weekIndexes, <int>[1, 3, 5, 7]);
    });

    test('should_keep_course_name_containing_halfwidth_parentheses', () {
      const html = '''
<div class="course-table">
  <div class="time-table-body">
    <div class="columns weekday">
      <div class="card-view">
        <div class="card-content-info">
          数据结构(实验)
          信息楼机房4
          (1~4周)
          (5,6节)
        </div>
      </div>
    </div>
  </div>
</div>
''';
      final result = CourseHtmlParser.parseHtml(html);

      expect(result.courses.single.courseName, '数据结构(实验)');
      expect(result.courses.single.room, '信息楼机房4');
    });

    test('should_split_multiple_teachers_when_separated_by_comma', () {
      final result = CourseHtmlParser.parseHtml(_standardGridHtml);

      expect(result.courses.single.teachers, <String>['张伟', '李娜']);
    });

    test('should_drop_courses_whose_section_exceeds_supported_range', () {
      // App 侧 startUnit 最大只能是 12（网格 12 行、作息表 13 项），
      // 越界的课必须被丢掉而不是让 time_service 抛 RangeError。
      const html = '''
<table id="kbTable" class="timetable">
  <tr><th>节次</th><th>星期</th></tr>
  <tr><th></th><th>星期一</th></tr>
  <tr><td>第1-2节</td><td>高等数学<br>张伟<br>1-16周<br>凌云楼101</td></tr>
  <tr><td>第13-14节</td><td>晚自习<br>李娜<br>1-16周<br>凌云楼101</td></tr>
</table>
''';
      final result = CourseHtmlParser.parseHtml(html);

      expect(result.courses, hasLength(1));
      expect(result.courses.single.courseName, '高等数学');
      expect(result.skippedCount, 1);
      expect(result.diagnosticReport, contains('skipped 1'));
    });

    test('should_report_empty_when_page_is_not_a_timetable', () {
      final result = CourseHtmlParser.parseHtml(
        '<html><body><p>没有课表</p></body></html>',
      );

      expect(result.isEmpty, isTrue);
      expect(result.diagnosticReport, contains('courses: 0'));
    });
  });
}
