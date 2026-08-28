import 'package:flutter/material.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/utils/week_start_utils.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/schedule/course_card.dart';
import 'package:ios_club_app/ui/components/schedule/timeline_column.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

import '../../../core/services/course_color_manager.dart';
import '../../../core/utils/platform_utils.dart';

/// 课表网格组件
///
/// 简约的苹果风格设计，用于展示整个周的课程安排
class ScheduleGrid extends StatelessWidget {
  const ScheduleGrid({
    super.key,
    required this.courses,
    required this.cellHeight,
    this.periodCount = 12,
    this.weekStartDay = School.defaultWeekStartDay,
    this.isYanTa = false,
    this.cardStyle = CourseCardStyle.normal,
    this.showGrid = true,
    this.onCourseTap,
    this.onCourseLongPress,
    this.onConflictCourseTap,
  });

  final List<CourseModel> courses;
  final double cellHeight;
  final int periodCount;
  final int weekStartDay;
  final bool isYanTa;
  final CourseCardStyle cardStyle;
  final bool showGrid;
  final void Function(CourseModel)? onCourseTap;
  final void Function(CourseModel)? onCourseLongPress;
  final void Function(List<CourseModel>)? onConflictCourseTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧时间轴
        TimelineColumn(
          periodCount: periodCount,
          cellHeight: cellHeight,
          isYanTa: isYanTa,
          showGrid: showGrid,
        ),
        // 右侧课程网格
        Expanded(
          child: CustomPaint(
            painter: showGrid
                ? _ScheduleGridPainter(
                    color: context.clubColors.separator,
                    cellHeight: cellHeight,
                    periodCount: periodCount,
                  )
                : null,
            child: Row(
              children: WeekStartUtils.orderedWeekdays(weekStartDay)
                  .map((weekday) => Expanded(
                        child: _buildDayColumn(context, weekday),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayColumn(BuildContext context, int weekday) {
    // 获取当天的课程
    final dayCourses = courses.where((c) => c.weekday == weekday).toList();
    dayCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

    // 处理课程冲突
    final conflictGroups = _groupConflictingCourses(dayCourses);

    return Stack(
      children: [
        // 课程卡片
        ...conflictGroups.expand((group) {
          if (group.length == 1) {
            return [_buildSingleCourseCard(group.first)];
          } else {
            return _buildConflictingCourseCards(context, group);
          }
        }),
      ],
    );
  }

  /// 构建单个课程卡片
  Widget _buildSingleCourseCard(CourseModel course) {
    final top = (course.startUnit - 1) * cellHeight;
    final height = (course.endUnit - course.startUnit + 1) * cellHeight;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: height,
      child: CourseCard(
        course: course,
        height: height,
        style: cardStyle,
        onTap: onCourseTap != null ? () => onCourseTap!(course) : null,
        onLongPress:
            onCourseLongPress != null ? () => onCourseLongPress!(course) : null,
      ),
    );
  }

  /// 构建冲突的课程卡片
  List<Widget> _buildConflictingCourseCards(
    BuildContext context,
    List<CourseModel> conflictCourses,
  ) {
    return [_buildConflictIndicator(context, conflictCourses)];
  }

  /// 构建冲突提示卡片
  Widget _buildConflictIndicator(
      BuildContext context, List<CourseModel> courses) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    var minStart = courses.first.startUnit;
    var maxEnd = courses.first.endUnit;

    for (var course in courses) {
      if (course.startUnit < minStart) minStart = course.startUnit;
      if (course.endUnit > maxEnd) maxEnd = course.endUnit;
    }

    final top = (minStart - 1) * cellHeight;
    final height = (maxEnd - minStart + 1) * cellHeight;
    // 使用第一个课程的颜色作为背景
    final courseColor =
        CourseColorManager.generateSoftColor(courses.first.courseName);

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: height,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: ShapeDecoration(
          shape: ClubSmoothCorners.shape(ClubRadii.control),
          color: courseColor,
        ),
        child: InkWell(
          borderRadius: ClubRadii.control,
          customBorder: ClubSmoothCorners.shape(ClubRadii.control),
          onTap: onConflictCourseTap != null
              ? () => onConflictCourseTap!(courses)
              : (onCourseTap != null
                  ? () => onCourseTap!(courses.first)
                  : null),
          onLongPress: null,
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 8 : 4),
            child: Center(
              child: Text(
                context.l10n.courseConflict,
                style: TextStyle(
                  fontSize: 10,
                  color: context.clubColors.onAccent.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 将课程按冲突分组
  List<List<CourseModel>> _groupConflictingCourses(List<CourseModel> courses) {
    // 第一步：合并同名且时间相同的课程
    final mergedCourses = _mergeSameNameCourses(courses);

    // 第二步：按冲突分组
    final groups = <List<CourseModel>>[];
    final used = List<bool>.filled(mergedCourses.length, false);

    for (int i = 0; i < mergedCourses.length; i++) {
      if (used[i]) continue;

      final group = <CourseModel>[mergedCourses[i]];
      used[i] = true;

      for (int j = i + 1; j < mergedCourses.length; j++) {
        if (used[j]) continue;

        // 检查是否有时间冲突
        if (_hasTimeConflict(mergedCourses[i], mergedCourses[j])) {
          group.add(mergedCourses[j]);
          used[j] = true;
        }
      }

      groups.add(group);
    }

    return groups;
  }

  /// 合并同名且时间相同的课程（将不同老师合并到一个课程对象中）
  List<CourseModel> _mergeSameNameCourses(List<CourseModel> courses) {
    final result = <CourseModel>[];
    final used = List<bool>.filled(courses.length, false);

    for (int i = 0; i < courses.length; i++) {
      if (used[i]) continue;

      final current = courses[i];
      final teachersToMerge = <String>[...current.teachers];
      used[i] = true;

      // 查找同名且时间相同的课程
      for (int j = i + 1; j < courses.length; j++) {
        if (used[j]) continue;

        final other = courses[j];
        // 如果课程名相同且时间完全相同
        if (current.courseName == other.courseName &&
            current.startUnit == other.startUnit &&
            current.endUnit == other.endUnit) {
          // 合并老师信息（去重）
          for (var teacher in other.teachers) {
            if (!teachersToMerge.contains(teacher)) {
              teachersToMerge.add(teacher);
            }
          }
          used[j] = true;
        }
      }

      // 创建合并后的课程对象
      result.add(CourseModel(
        weekIndexes: current.weekIndexes,
        teachers: teachersToMerge,
        room: current.room,
        courseName: current.courseName,
        courseCode: current.courseCode,
        weekday: current.weekday,
        startUnit: current.startUnit,
        endUnit: current.endUnit,
        credits: current.credits,
        lessonId: current.lessonId,
        campus: current.campus,
        isCustom: current.isCustom,
      ));
    }

    return result;
  }

  /// 检查两个课程是否有时间冲突
  bool _hasTimeConflict(CourseModel a, CourseModel b) {
    // 检查两个课程的上课节次是否有时间重叠
    // 注意：同名课程已经在 _mergeSameNameCourses 中合并了，这里不会出现同名课程
    return (a.startUnit <= b.endUnit && a.endUnit >= b.startUnit);
  }
}

/// Draws the static timetable grid in one paint operation instead of creating
/// a widget for every cell border.
class _ScheduleGridPainter extends CustomPainter {
  const _ScheduleGridPainter({
    required this.color,
    required this.cellHeight,
    required this.periodCount,
  });

  final Color color;
  final double cellHeight;
  final int periodCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final dayWidth = size.width / 7;
    for (var day = 0; day <= 7; day++) {
      final x = day * dayWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var period = 1; period <= periodCount; period++) {
      final y = period * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScheduleGridPainter oldDelegate) {
    return color != oldDelegate.color ||
        cellHeight != oldDelegate.cellHeight ||
        periodCount != oldDelegate.periodCount;
  }
}
