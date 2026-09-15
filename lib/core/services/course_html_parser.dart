import 'package:curriculum/curriculum.dart' as curriculum;

import 'package:ios_club_app/features/education/models/course_model.dart';

/// 一次课表 HTML 解析的结果。
class CourseHtmlParseResult {
  CourseHtmlParseResult({
    required this.courses,
    this.adapterId,
    this.warnings = const <curriculum.ParseWarning>[],
    this.skippedCount = 0,
  });

  /// 可直接写入 CourseStore 的课程列表。
  final List<CourseModel> courses;

  /// 实际使用的适配器 id，例如 `XAUAT_01`。
  final String? adapterId;

  /// 解析过程中的诊断（缺教师、周次回退等）。
  final List<curriculum.ParseWarning> warnings;

  /// 因节次缺失或越界而被丢弃的课程数。
  final int skippedCount;

  bool get isEmpty => courses.isEmpty;

  /// 可读的诊断报告，用于日志与线上排查。
  String get diagnosticReport {
    final buffer = StringBuffer()
      ..writeln('adapter: ${adapterId ?? '(none)'}')
      ..writeln('courses: ${courses.length}'
          '${skippedCount > 0 ? '  (skipped $skippedCount)' : ''}');
    if (warnings.isEmpty) {
      buffer.writeln('warnings: none');
      return buffer.toString();
    }
    buffer.writeln('warnings: ${warnings.length}');
    for (final warning in warnings) {
      buffer.writeln('  $warning');
    }
    return buffer.toString();
  }
}

/// 课表 HTML 解析入口。
///
/// 解析本身由 `curriculum` 包完成，这里只做三件事：按学校挑适配器、把
/// `curriculum.Course` 映射成 [CourseModel]、把不满足 App 侧不变量的课程挡掉。
///
/// 页面结构、周次/节次文本解析、字段抽取都归 curriculum，新增学校时只改那边，
/// 这个文件不用动。
class CourseHtmlParser {
  const CourseHtmlParser._();

  /// App 侧支持的节次范围。
  ///
  /// `schedule_grid` 用 `(startUnit - 1) * cellHeight` 定位、网格高度固定 12 行，
  /// 而 `TimeService` 的四张作息表都只有 13 项并拿 `startUnit` 直接当下标。
  /// 所以 0 会得到负偏移，大于 12 会 RangeError。
  static const int minUnit = 1;
  static const int maxUnit = 12;

  /// 解析课表 HTML。
  ///
  /// [schoolCode] 是 `School.code`（如 `XAUAT`）。给了就**优先用该校的适配器**；
  /// 该校没有适配器、或适配器没解析出课程时，回退到自动探测。因此选错学校也不会
  /// 比不选更差。
  static CourseHtmlParseResult parseHtml(String html, {String? schoolCode}) {
    final registry = curriculum.SchoolAdapterRegistry.standard;

    final bySchool = _parseForSchool(registry, html, schoolCode);
    if (bySchool != null && bySchool.courses.isNotEmpty) {
      return _convert(bySchool);
    }

    final auto = registry.parseAuto(html);
    if (auto.courses.isNotEmpty) {
      return _convert(auto);
    }

    // 两条路都没出课程：把本校那次的结果（若有）返回，它的诊断更有指向性。
    return _convert(bySchool ?? auto);
  }

  /// 用指定学校的适配器解析；没有该校适配器时返回 null。
  static curriculum.CourseImportResult? _parseForSchool(
    curriculum.SchoolAdapterRegistry registry,
    String html,
    String? schoolCode,
  ) {
    final code = schoolCode?.trim().toUpperCase();
    if (code == null || code.isEmpty) return null;

    final forSchool = registry.bySchoolId(code);
    if (forSchool.isEmpty) return null;
    if (forSchool.length == 1) return forSchool.single.parse(html);

    // 同一学校有多个适配器时，挑在这个页面上真正命中的那个；都不命中就用第一个。
    final hits = registry
        .detect(html)
        .where((c) => c.adapter.info.schoolId.toUpperCase() == code)
        .toList();
    final adapter = hits.isEmpty ? forSchool.first : hits.first.adapter;
    return adapter.parse(html);
  }

  /// 映射成 [CourseModel]，并挡掉违反 App 侧不变量的课程。
  static CourseHtmlParseResult _convert(curriculum.CourseImportResult result) {
    final courses = <CourseModel>[];
    var skipped = 0;

    for (final course in result.courses) {
      final start = course.startSection;
      final end = course.endSection;
      final usable = course.name.isNotEmpty &&
          start != null &&
          end != null &&
          start >= minUnit &&
          end <= maxUnit &&
          end >= start;

      if (!usable) {
        // 丢掉而不是填 0：填 0 会让 time_service 取到空字符串进而
        // FormatException，等于用崩溃换一门课。
        skipped++;
        continue;
      }

      courses.add(CourseModel(
        courseName: course.name,
        room: course.position,
        weekday: course.day,
        startUnit: start,
        endUnit: end,
        weekIndexes: course.weeks,
        teachers: _splitTeachers(course.teacher),
        // 以下字段页面不提供，或 curriculum 的模型里没有对应项。
        courseCode: '',
        credits: '',
        lessonId: '',
        campus: '',
        isCustom: false,
      ));
    }

    return CourseHtmlParseResult(
      courses: courses,
      adapterId: result.adapterId,
      warnings: result.warnings,
      skippedCount: skipped,
    );
  }

  /// `张三,李四` / `张三、李四` → `[张三, 李四]`。
  static List<String> _splitTeachers(String raw) {
    if (raw.trim().isEmpty) return const <String>[];
    return raw
        .split(RegExp('[,，、/]'))
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }
}
