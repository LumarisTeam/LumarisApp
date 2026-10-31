import 'package:curriculum/warehouse.dart' as curriculum;
import 'package:ios_club_app/core/services/time_service.dart';
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

  /// 因自定义时间无法映射到节次而被跳过的课程数。
  final int skippedCustomTime;

  /// 因节次为空或超出课表范围被跳过的课程数。
  final int skippedOutOfRange;

  /// 被跳过的课程总数。
  int get skipped => skippedCustomTime + skippedOutOfRange;
}

/// 把 `curriculum.Course` 映射成 App 的 `CourseModel`。
///
/// App 的网格按 1..12 节定位，因此自定义时间课程会先映射到最近的节次格；
/// 原始 `HH:mm` 仍保留在 `CourseModel.isCustomTime/customStartTime/customEndTime`
/// 里，提醒和详情展示优先使用精确时间。
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
  /// [table] 用于把自定义时间映射到节次；不传时只保留有节次的课程。
  static WarehouseCourseMapResult toCourseModels(
    Iterable<curriculum.Course> courses, {
    int fallbackWeeks = defaultWeeks,
    ScheduleTable? table,
  }) {
    final mapped = <CourseModel>[];
    var skippedCustomTime = 0;
    var skippedOutOfRange = 0;

    for (final course in courses) {
      final int startUnit;
      final int endUnit;

      if (course.startSection == null) {
        if (!course.isCustomTime) {
          skippedOutOfRange++;
          continue;
        }
        final sections = _mapCustomTime(course, table);
        if (sections == null) {
          skippedCustomTime++;
          continue;
        }
        startUnit = sections.$1;
        endUnit = sections.$2;
      } else {
        startUnit = course.startSection!;
        endUnit = course.endSection ?? startUnit;
      }

      if (startUnit < minUnit || endUnit > maxUnit || endUnit < startUnit) {
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
          startUnit: startUnit,
          endUnit: endUnit,
          weekIndexes: weeks,
          teachers: _splitTeachers(course.teacher),
          courseCode: '',
          credits: course.credit?.toString() ?? '',
          lessonId: course.id ?? '',
          campus: '',
          isCustom: false,
          isCustomTime: course.isCustomTime,
          customStartTime: course.isCustomTime
              ? (course.customStartTime ?? '')
              : '',
          customEndTime: course.isCustomTime ? (course.customEndTime ?? '') : '',
        ),
      );
    }

    return WarehouseCourseMapResult(
      courses: List<CourseModel>.unmodifiable(mapped),
      skippedCustomTime: skippedCustomTime,
      skippedOutOfRange: skippedOutOfRange,
    );
  }

  static (int, int)? _mapCustomTime(
    curriculum.Course course,
    ScheduleTable? table,
  ) {
    if (table == null) return null;
    final startMinutes = _parseMinutes(course.customStartTime);
    if (startMinutes == null) return null;
    final endMinutes = _parseMinutes(course.customEndTime) ?? startMinutes + 45;

    final start = _nearestSection(table.start, startMinutes, preferEarlier: true);
    final end = _nearestSection(table.end, endMinutes, preferEarlier: false);
    if (start == null || end == null) return null;

    final safeStart = start.clamp(minUnit, maxUnit);
    final safeEnd = end.clamp(safeStart, maxUnit);
    return (safeStart, safeEnd);
  }

  static int? _nearestSection(
    List<String> times,
    int target, {
    required bool preferEarlier,
  }) {
    int? best;
    var bestDistance = 1 << 30;

    for (var index = minUnit; index < times.length && index <= maxUnit; index++) {
      final minutes = _parseMinutes(times[index]);
      if (minutes == null) continue;
      final distance = (minutes - target).abs();
      final isBetter = distance < bestDistance;
      final isTieAndPreferred =
          distance == bestDistance &&
          preferEarlier &&
          best != null &&
          index < best;
      if (isBetter || isTieAndPreferred) {
        best = index;
        bestDistance = distance;
      }
    }
    return best;
  }

  static int? _parseMinutes(String? raw) {
    if (raw == null) return null;
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw.trim());
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return hour * 60 + minute;
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
