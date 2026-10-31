import 'package:curriculum/warehouse.dart' as curriculum;
import 'package:ios_club_app/features/education/models/course_model.dart';

/// 一次 JS 适配器课程映射的结果。
class WarehouseCourseMapResult {
  /// 创建映射结果。
  const WarehouseCourseMapResult({
    required this.courses,
    this.skippedCustomTime = 0,
    this.skippedOutOfRange = 0,
  });

  /// 可直接写入 `CourseStore` 的课程。
  final List<CourseModel> courses;

  /// 因自定义时间（没有节次）被跳过的课程数。
  final int skippedCustomTime;

  /// 因节次为空或超出课表范围被跳过的课程数。
  final int skippedOutOfRange;

  /// 被跳过的课程总数。
  int get skipped => skippedCustomTime + skippedOutOfRange;
}

/// 把 `curriculum.Course` 映射成 App 的 `CourseModel`。
///
/// App 的网格按 1..12 节定位，且目前没有自定义时间字段，因此：
/// - 自定义时间课程跳过，等 P4 扩展模型后再支持；
/// - 节次缺失或越界的课程跳过，避免渲染时崩溃。
class WarehouseCourseMapper {
  WarehouseCourseMapper._();

  /// App 课表支持的最小节次。
  static const int minUnit = 1;

  /// App 课表支持的最大节次。
  static const int maxUnit = 12;

  /// 默认学期周数；课程没有周次时用它生成全周。
  static const int defaultWeeks = 20;

  /// 执行映射。
  ///
  /// [fallbackWeeks] 用于课程 `weeks` 为空的情况；传学期总周数，缺省 20。
  static WarehouseCourseMapResult toCourseModels(
    Iterable<curriculum.Course> courses, {
    int fallbackWeeks = defaultWeeks,
  }) {
    final mapped = <CourseModel>[];
    var skippedCustomTime = 0;
    var skippedOutOfRange = 0;

    for (final course in courses) {
      if (course.isCustomTime || course.startSection == null) {
        skippedCustomTime++;
        continue;
      }

      final start = course.startSection!;
      final end = course.endSection ?? start;
      if (start < minUnit || end > maxUnit || end < start) {
        skippedOutOfRange++;
        continue;
      }

      final weeks = course.weeks.isEmpty
          ? List<int>.generate(fallbackWeeks, (index) => index + 1)
          : course.weeks;

      mapped.add(
        CourseModel(
          courseName: course.name,
          room: course.position,
          weekday: course.day,
          startUnit: start,
          endUnit: end,
          weekIndexes: weeks,
          teachers: _splitTeachers(course.teacher),
          courseCode: '',
          credits: course.credit?.toString() ?? '',
          lessonId: course.id ?? '',
          campus: '',
          isCustom: false,
        ),
      );
    }

    return WarehouseCourseMapResult(
      courses: List<CourseModel>.unmodifiable(mapped),
      skippedCustomTime: skippedCustomTime,
      skippedOutOfRange: skippedOutOfRange,
    );
  }

  static List<String> _splitTeachers(String raw) {
    if (raw.trim().isEmpty) return const <String>[];
    return raw
        .split(RegExp('[,，、/]'))
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }
}
