import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/utils/week_start_utils.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/ui/components/schedule/course_card.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_block_surface.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_grid_lines.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_time_axis.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_visual_style.dart';
import 'package:ios_club_app/ui/components/schedule/timeline_column.dart';

import '../../../core/services/course_color_manager.dart';
import '../../../core/services/schedule_color_resolver.dart';

/// 课表网格组件
///
/// 简约的苹果风格设计，用于展示整个周的课程安排
class ScheduleGrid extends StatelessWidget {
  const ScheduleGrid({
    super.key,
    required this.courses,
    required this.cellHeight,
    this.weekStartDay = School.defaultWeekStartDay,
    this.isYanTa = false,
    this.showGrid = true,
    this.visualStyle,
    this.preview = false,
    this.onCourseTap,
    this.onCourseLongPress,
    this.onConflictCourseTap,
  });

  final List<CourseModel> courses;
  final double cellHeight;
  final int weekStartDay;
  final bool isYanTa;
  final bool showGrid;

  /// 个性化外观；传入时以其中的尺寸/颜色/文字规则为准。
  final ScheduleVisualStyle? visualStyle;

  /// 个性化页预览用：跳过卡片交互和滚动布局。
  final bool preview;

  final void Function(CourseModel)? onCourseTap;
  final void Function(CourseModel)? onCourseLongPress;
  final void Function(List<CourseModel>)? onConflictCourseTap;

  int get _rowCount =>
      visualStyle?.rowCount ?? ScheduleTimeAxis.sectionRowCount;

  double get _timeColumnWidth => visualStyle?.timeColumnWidth ?? 45;

  @override
  Widget build(BuildContext context) {
    final effectiveCellHeight = visualStyle?.cellHeight ?? cellHeight;
    final effectiveShowGrid = visualStyle?.showGrid ?? showGrid;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧时间轴
        TimelineColumn(
          periodCount: _rowCount,
          cellHeight: effectiveCellHeight,
          isYanTa: isYanTa,
          showGrid: effectiveShowGrid,
          timeColumnWidth: _timeColumnWidth,
          hideSectionTime: visualStyle?.hideSectionTime ?? false,
          textColor: visualStyle?.pageTextColor,
        ),
        // 右侧课程网格
        Expanded(
          child: CustomPaint(
            painter: effectiveShowGrid
                ? ScheduleDayGridPainter(
                    color: context.mc.colors.separator,
                    cellHeight: effectiveCellHeight,
                    rowCount: _rowCount,
                  )
                : null,
            child: Row(
              children: WeekStartUtils.orderedWeekdays(weekStartDay)
                  .map(
                    (weekday) =>
                        Expanded(child: _buildDayColumn(context, weekday)),
                  )
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
            return [_buildSingleCourseCard(context, group.first)];
          } else {
            return _buildConflictingCourseCards(context, group);
          }
        }),
      ],
    );
  }

  /// 构建单个课程卡片
  Widget _buildSingleCourseCard(BuildContext context, CourseModel course) {
    final effectiveCellHeight = visualStyle?.cellHeight ?? cellHeight;
    final geometry = ScheduleTimeAxis.geometryFor(
      course,
      effectiveCellHeight,
      showStartTime: visualStyle?.showStartTime ?? false,
    );

    return Positioned(
      top: geometry.top,
      left: 0,
      right: 0,
      height: geometry.height,
      child: CourseCard(
        course: course,
        height: geometry.height,
        backgroundColor: visualStyle?.colorFor(course),
        textColor: visualStyle?.courseTextColor,
        timeLabel: geometry.timeLabel,
        hideTeacher: visualStyle?.hideTeacher ?? false,
        hideLocation: visualStyle?.hideLocation ?? false,
        centerHorizontally: visualStyle?.centerHorizontally ?? false,
        centerVertically: visualStyle?.centerVertically ?? false,
        borderStyle: visualStyle?.borderStyle ?? ScheduleBorderStyle.none,
        borderColor: context.mc.colors.separator,
        fontScale: visualStyle?.fontScale ?? 1,
        cornerRadius: visualStyle?.cornerRadius ?? 8,
        innerPadding: visualStyle?.innerPadding ?? 4,
        outerPadding: visualStyle?.outerPadding ?? 2,
        opacity: visualStyle?.opacity ?? 1,
        preview: preview,
        onTap: onCourseTap != null ? () => onCourseTap!(course) : null,
        onLongPress: onCourseLongPress != null
            ? () => onCourseLongPress!(course)
            : null,
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
    BuildContext context,
    List<CourseModel> courses,
  ) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final effectiveCellHeight = visualStyle?.cellHeight ?? cellHeight;
    final cornerRadius = visualStyle?.cornerRadius ?? 8;
    final innerPadding = visualStyle?.innerPadding ?? 4;
    final outerPadding = visualStyle?.outerPadding ?? 2;
    final opacity = visualStyle?.opacity ?? 1;
    final fontScale = visualStyle?.fontScale ?? 1;
    final radius = BorderRadius.circular(cornerRadius);

    var minStart = courses.first.startUnit;
    var maxEnd = courses.first.endUnit;
    for (final course in courses) {
      if (course.startUnit < minStart) minStart = course.startUnit;
      if (course.endUnit > maxEnd) maxEnd = course.endUnit;
    }
    final top = (minStart - 1) * effectiveCellHeight;
    final height = (maxEnd - minStart + 1) * effectiveCellHeight;

    // 使用第一个课程的颜色作为背景
    final courseColor =
        visualStyle?.colorFor(courses.first) ??
        CourseColorManager.generateSoftColor(courses.first.courseName);
    final textColor =
        visualStyle?.textFor(courseColor) ??
        ScheduleColorResolver.autoContrast(courseColor);

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: height,
      child: ScheduleBlockSurface(
        color: courseColor.withValues(alpha: opacity),
        borderStyle: visualStyle?.borderStyle ?? ScheduleBorderStyle.none,
        borderColor: context.mc.colors.separator.withValues(alpha: opacity),
        margin: EdgeInsets.all(outerPadding),
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          customBorder: McSmoothCorners.shape(radius),
          onTap: onConflictCourseTap != null
              ? () => onConflictCourseTap!(courses)
              : (onCourseTap != null
                    ? () => onCourseTap!(courses.first)
                    : null),
          onLongPress: null,
          child: Padding(
            padding: EdgeInsets.all(isTablet ? innerPadding + 4 : innerPadding),
            child: Center(
              child: Text(
                context.l10n.courseConflict,
                style: TextStyle(
                  fontSize: 10 * fontScale,
                  color: textColor.withValues(alpha: 0.9),
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
    return CourseModel.mergeSameNameCourses(courses);
  }

  /// 检查两个课程是否有时间冲突
  bool _hasTimeConflict(CourseModel a, CourseModel b) {
    // 检查两个课程的上课节次是否有时间重叠
    // 注意：同名课程已经在 _mergeSameNameCourses 中合并了，这里不会出现同名课程
    return (a.startUnit <= b.endUnit && a.endUnit >= b.startUnit);
  }
}
