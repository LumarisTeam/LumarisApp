import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:ios_club_app/core/services/course_color_manager.dart';
import 'package:ios_club_app/core/services/schedule_color_resolver.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_block_surface.dart';

/// 课程卡片组件
///
/// 简约的苹果风格设计，用于课表中展示单个课程信息。
class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.height,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.textColor,
    this.timeLabel,
    this.hideTeacher = false,
    this.hideLocation = false,
    this.centerHorizontally = false,
    this.centerVertically = false,
    this.borderStyle = ScheduleBorderStyle.none,
    this.borderColor,
    this.fontScale = 1,
    this.cornerRadius = 8,
    this.innerPadding = 4,
    this.outerPadding = 2,
    this.opacity = 1,
    this.preview = false,
  });

  final CourseModel course;
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 课程块底色；为空时回退旧的按课程名哈希取色。
  final Color? backgroundColor;

  /// 课程块文字颜色；为空时按底色自动取对比色。
  final Color? textColor;

  /// 课程开始时间或起止时间；为空时不显示。
  final String? timeLabel;

  final bool hideTeacher;
  final bool hideLocation;
  final bool centerHorizontally;
  final bool centerVertically;
  final ScheduleBorderStyle borderStyle;
  final Color? borderColor;
  final double fontScale;
  final double cornerRadius;
  final double innerPadding;
  final double outerPadding;
  final double opacity;

  /// 个性化页预览用：跳过 InkWell 和内层滚动，降低构建成本。
  final bool preview;

  @override
  Widget build(BuildContext context) {
    final courseColor =
        backgroundColor ??
        CourseColorManager.generateSoftColor(course.courseName);
    final colors = context.mc.colors;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // 固定字号增量；字号细节统一交给 fontScale。
    const double addNum = 0.9;
    final double baseFontSize = (isTablet ? 12 : 10) + addNum;
    final double secondaryFontSize = (isTablet ? 10 : 9) + addNum;
    final double tertiaryFontSize = (isTablet ? 10 : 8) + addNum;
    final double padding = isTablet ? innerPadding + 4 : innerPadding;
    final radius = BorderRadius.circular(cornerRadius);
    final shape = McSmoothCorners.shape(radius);
    final effectiveColor = courseColor.withValues(alpha: opacity);
    final effectiveBorderColor = (borderColor ?? colors.separator).withValues(
      alpha: opacity,
    );

    final Color effectiveTextColor;
    if (textColor != null) {
      effectiveTextColor = textColor!.withValues(alpha: 0.92);
    } else if (backgroundColor != null) {
      effectiveTextColor = ScheduleColorResolver.autoContrast(
        courseColor,
      ).withValues(alpha: 0.92);
    } else {
      // 未接入个性化样式时保持旧版白字外观。
      effectiveTextColor = colors.onAccent.withValues(alpha: 0.9);
    }

    final textAlign = centerHorizontally ? TextAlign.center : TextAlign.start;
    final crossAxisAlignment = centerHorizontally
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    final roomText = course.room;

    final textChildren = <Widget>[
      if (timeLabel != null && timeLabel!.isNotEmpty)
        Text(
          timeLabel!,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: secondaryFontSize * fontScale,
            color: effectiveTextColor.withValues(alpha: 0.8),
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
      // 课程名称
      Text(
        course.courseName,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: baseFontSize * fontScale,
          fontWeight: FontWeight.bold,
          color: effectiveTextColor,
          overflow: TextOverflow.ellipsis,
        ),
        maxLines: 3,
      ),
      // 上课地点
      if (!hideLocation)
        Text(
          roomText,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: secondaryFontSize * fontScale,
            overflow: TextOverflow.ellipsis,
            color: effectiveTextColor,
          ),
          maxLines: 2,
        ),
      // 教师信息
      if (!hideTeacher && course.teachers.isNotEmpty)
        Text(
          course.teachers.join(', '),
          textAlign: textAlign,
          style: TextStyle(
            fontSize: tertiaryFontSize * fontScale,
            overflow: TextOverflow.ellipsis,
            color: effectiveTextColor,
          ),
        ),
    ];

    final Widget content;
    if (preview) {
      // 预览不能用 FittedBox 缩放，否则会把 fontScale 的放大效果抵消掉。
      // 用不可滚动的滚动视口提供裁剪，文字按真实字号布局；同时保留
      // ConstrainedBox/minHeight，让 Vertical Center 在预览里也生效。
      content = ClipRRect(
        borderRadius: radius,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final minHeight = centerVertically && constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : 0.0;

              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: minHeight,
                    minWidth: double.infinity,
                  ),
                  child: Column(
                    mainAxisAlignment: centerVertically
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    crossAxisAlignment: crossAxisAlignment,
                    children: textChildren,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      content = InkWell(
        borderRadius: radius,
        customBorder: shape,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final minHeight = centerVertically && constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : 0.0;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: minHeight,
                    minWidth: double.infinity,
                  ),
                  child: Column(
                    mainAxisAlignment: centerVertically
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    crossAxisAlignment: crossAxisAlignment,
                    children: textChildren,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return ScheduleBlockSurface(
      color: effectiveColor,
      borderStyle: borderStyle,
      borderColor: effectiveBorderColor,
      margin: EdgeInsets.all(outerPadding),
      borderRadius: radius,
      child: content,
    );
  }
}
