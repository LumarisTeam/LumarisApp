import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/core/services/schedule_color_resolver.dart';
import 'package:ios_club_app/state/schedule_style_store.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_color_picker.dart';

/// 课程详情弹窗组件
///
/// 简约的苹果风格设计，用于展示课程的完整信息
class CourseDetailSheet extends StatelessWidget {
  const CourseDetailSheet({
    super.key,
    required this.course,
    this.isDark,
    this.onEdit,
    this.onDelete,
  });

  final CourseModel course;

  /// 课表当前实际使用的亮暗（包含自定义壁纸的影响）；不传时跟随系统主题。
  final bool? isDark;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop =
        isTablet && !PlatformUtils.isAndroid && !PlatformUtils.isIOS;
    final effectiveIsDark =
        isDark ?? (Theme.of(context).brightness == Brightness.dark);

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: ShapeDecoration(
        color: colors.cardBackground,
        shape: McSmoothCorners.shape(
          isDesktop ? McRadii.cardBorder : McRadii.sheetTopBorder,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    course.courseName,
                    key: const ValueKey('courseDetailTitle'),
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 22,
                      fontWeight: FontWeight.w700,
                      color: colors.label,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                _CourseColorSwatch(
                  key: const ValueKey('courseColorSwatch'),
                  course: course,
                  isDark: effectiveIsDark,
                ),
                if (course.isCustom && (onEdit != null || onDelete != null))
                  _buildActionMenu(context),
              ],
            ),
            SizedBox(height: isTablet ? 24 : 20),

            // 课程信息列表
            _buildInfoRow(
              context,
              icon: CupertinoIcons.location_solid,
              label: context.l10n.classroom,
              content: course.room,
              color: colors.primary,
            ),
            SizedBox(height: isTablet ? 16 : 14),

            _buildInfoRow(
              context,
              icon: course.teachers.length > 1
                  ? CupertinoIcons.person_2_fill
                  : CupertinoIcons.person_fill,
              label: context.l10n.teacherLabel,
              content: course.teachers.join(', '),
              color: colors.danger,
            ),
            SizedBox(height: isTablet ? 16 : 14),

            _buildInfoRow(
              context,
              icon: CupertinoIcons.calendar,
              label: context.l10n.classTime,
              content: _formatScheduleInfo(context),
              color: colors.success,
            ),

            if (course.campus.isNotEmpty) ...[
              SizedBox(height: isTablet ? 16 : 14),
              _buildInfoRow(
                context,
                icon: CupertinoIcons.building_2_fill,
                label: context.l10n.classCampus,
                content: course.campus,
                color: colors.warning,
              ),
            ],

            if (course.credits.isNotEmpty) ...[
              SizedBox(height: isTablet ? 16 : 14),
              _buildInfoRow(
                context,
                icon: CupertinoIcons.star_fill,
                label: context.l10n.courseCredits,
                content: course.credits,
                color: colors.yellow,
              ),
            ],

            SizedBox(height: isTablet ? 24 : 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return McMenu<String>(
      items: <McMenuItem<String>>[
        if (onEdit != null)
          McMenuItem<String>(
            value: 'edit',
            label: context.l10n.editCourse,
            icon: CupertinoIcons.pencil,
          ),
        if (onDelete != null)
          McMenuItem<String>(
            value: 'delete',
            label: context.l10n.deleteCourse,
            icon: CupertinoIcons.delete,
            isDestructive: true,
          ),
      ],
      onSelected: (String value) {
        Navigator.of(context).pop();
        if (value == 'edit' && onEdit != null) {
          onEdit!();
        } else if (value == 'delete' && onDelete != null) {
          onDelete!();
        }
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String content,
    required Color color,
  }) {
    final colors = context.mc.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图标容器
        Container(
          width: 36,
          height: 36,
          decoration: ShapeDecoration(
            color: color.withValues(alpha: 0.12),
            shape: McSmoothCorners.shape(McRadii.controlBorder),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 14),
        // 文本内容
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.secondaryLabel,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.label,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatScheduleInfo(BuildContext context) {
    final weekdayNames = _getWeekdayNames(context);
    return context.l10n.scheduleCourseTime(
      CourseModel.formatWeekRanges(course.weekIndexes),
      weekdayNames[course.weekday],
      course.startUnit,
      course.endUnit,
    );
  }

  List<String> _getWeekdayNames(BuildContext context) {
    final l10n = context.l10n;
    return [
      l10n.sunday,
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];
  }

  /// 显示课程详情弹窗
  ///
  /// [isDark] 传入课表当前实际使用的亮暗（自定义壁纸可能覆盖系统主题）；
  /// 不传时颜色圆点按系统主题选池。
  static Future<void> show(
    BuildContext context,
    CourseModel course, {
    bool? isDark,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    if (isTablet && !PlatformUtils.isAndroid && !PlatformUtils.isIOS) {
      // 桌面平台使用对话框
      return showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: McSmoothCorners.shape(McRadii.cardBorder),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: CourseDetailSheet(
              course: course,
              isDark: isDark,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        ),
      );
    } else {
      // 移动平台使用底部弹窗
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SafeArea(
          top: false,
          child: CourseDetailSheet(
            course: course,
            isDark: isDark,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ),
      );
    }
  }
}

/// 详情弹窗标题右上角的课程颜色圆点。
///
/// 点击打开 HSV 取色器，修改会按 [ScheduleColorResolver.courseKey] 覆盖同一
/// 教学班（同 lessonId）的所有课程；重置则清除覆盖、回到自动色池颜色。
class _CourseColorSwatch extends ConsumerWidget {
  const _CourseColorSwatch({
    super.key,
    required this.course,
    required this.isDark,
  });

  final CourseModel course;
  final bool isDark;

  static const double _dotSize = 36;
  static const double _tapPadding = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styleState = ref.watch(scheduleStyleStoreProvider);
    final colorPool = isDark
        ? styleState.darkColorPool
        : styleState.lightColorPool;
    final color = ScheduleColorResolver.colorForCourse(
      course,
      colorPool,
      styleState.courseColorOverrides,
    );
    final colors = context.mc.colors;
    final canCustomize =
        course.lessonId.trim().isNotEmpty ||
        course.courseName.trim().isNotEmpty;

    final dot = Container(
      key: const ValueKey('courseColorSwatchDot'),
      width: _dotSize,
      height: _dotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: colors.separator.withValues(alpha: 0.35),
          width: 0.5,
        ),
      ),
      child: Icon(
        Icons.palette_outlined,
        size: 16,
        color: ScheduleColorResolver.autoContrast(color),
      ),
    );

    if (!canCustomize) {
      return Padding(padding: const EdgeInsets.all(_tapPadding), child: dot);
    }

    final label = context.l10n.changeCourseColor;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _openPicker(context, ref, color),
          child: Padding(
            padding: const EdgeInsets.all(_tapPadding),
            child: dot,
          ),
        ),
      ),
    );
  }

  void _openPicker(BuildContext context, WidgetRef ref, Color initialColor) {
    final store = ref.read(scheduleStyleStoreProvider.notifier);
    final key = ScheduleColorResolver.courseKey(
      lessonId: course.lessonId,
      courseName: course.courseName,
    );

    showScheduleColorPicker(
      context: context,
      title: course.courseName,
      initialColor: initialColor,
      onChanged: (value) => store.setCourseColorOverride(key, value),
      onReset: () => store.clearCourseColorOverride(key),
      resetLabel: context.l10n.resetCourseColor,
    );
  }
}
