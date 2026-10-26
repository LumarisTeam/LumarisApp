import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';

/// 一门课在节次网格中的纵向几何。
class CourseGeometry {
  const CourseGeometry({
    required this.top,
    required this.height,
    this.timeLabel,
  });

  final double top;
  final double height;
  final String? timeLabel;
}

/// 课表节次几何与课程开始时间解析。
class ScheduleTimeAxis {
  const ScheduleTimeAxis._();

  static const int sectionRowCount = 12;

  static CourseGeometry geometryFor(
    CourseModel course,
    double cellHeight, {
    bool showStartTime = false,
  }) {
    final start = course.startUnit.clamp(1, sectionRowCount).toInt();
    final end = course.endUnit.clamp(start, sectionRowCount).toInt();

    return CourseGeometry(
      top: (start - 1) * cellHeight,
      height: (end - start + 1) * cellHeight,
      timeLabel: showStartTime ? _sectionStartLabel(course) : null,
    );
  }

  static String? _sectionStartLabel(CourseModel course) {
    final times = TimeService.getStartAndEnd(course);
    if (times.start.trim().isNotEmpty) return times.start;

    final fallback = TimeService.getStartAndEndForCampus(
      campus: TimeService.caoTangCampus,
      startUnit: course.startUnit,
      endUnit: course.startUnit,
    );
    return fallback.start.trim().isEmpty ? null : fallback.start;
  }
}
