import 'package:material_ui/material_ui.dart';
import 'package:ios_club_app/core/services/schedule_color_resolver.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_time_axis.dart';

/// 课表渲染所需的完整外观配置。
///
/// 课表页与个性化预览页共用同一份模型，叶子组件通过参数接收，避免到处读
/// Riverpod store，也方便单测。
class ScheduleVisualStyle {
  const ScheduleVisualStyle({
    required this.cellHeight,
    required this.headerHeight,
    required this.brightness,
    required this.colorPool,
    required this.showGrid,
    this.hideSectionTime = false,
    this.hideDateUnderDay = false,
    this.timeColumnWidth = 45,
    this.showStartTime = false,
    this.hideLocation = false,
    this.pageTextColor,
    this.courseTextColor,
    this.hideTeacher = false,
    this.centerHorizontally = false,
    this.centerVertically = false,
    this.borderStyle = ScheduleBorderStyle.none,
    this.fontScale = 1,
    this.cornerRadius = 8,
    this.innerPadding = 4,
    this.outerPadding = 2,
    this.opacity = 1,
    this.courseColorOverrides = const <String, Color>{},
  });

  final double cellHeight;
  final double headerHeight;

  /// 显式亮暗：深色壁纸也会选择深色颜色池。
  final Brightness brightness;

  /// 已按 [brightness] 选好的颜色池。
  final List<Color> colorPool;

  final bool showGrid;
  final bool hideSectionTime;
  final bool hideDateUnderDay;
  final double timeColumnWidth;
  final bool showStartTime;
  final bool hideLocation;
  final Color? pageTextColor;
  final Color? courseTextColor;
  final bool hideTeacher;
  final bool centerHorizontally;
  final bool centerVertically;
  final ScheduleBorderStyle borderStyle;
  final double fontScale;
  final double cornerRadius;
  final double innerPadding;
  final double outerPadding;
  final double opacity;

  /// 逐课程手动颜色覆盖，key 来自 [ScheduleColorResolver.courseKey]。
  final Map<String, Color> courseColorOverrides;

  bool get isDark => brightness == Brightness.dark;

  int get rowCount => ScheduleTimeAxis.sectionRowCount;

  double get gridHeight => cellHeight * rowCount;

  factory ScheduleVisualStyle.from({
    required ScheduleStyleState styleState,
    required bool showGrid,
    required double cellHeight,
    required bool isDark,
  }) {
    return ScheduleVisualStyle(
      cellHeight: cellHeight,
      headerHeight: styleState.headerHeight,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorPool: isDark ? styleState.darkColorPool : styleState.lightColorPool,
      showGrid: showGrid,
      hideSectionTime: styleState.hideSectionTime,
      hideDateUnderDay: styleState.hideDateUnderDay,
      timeColumnWidth: styleState.timeColumnWidth,
      showStartTime: styleState.showStartTime,
      hideLocation: styleState.hideLocation,
      pageTextColor: styleState.pageTextColor,
      courseTextColor: styleState.courseTextColor,
      hideTeacher: styleState.hideTeacher,
      centerHorizontally: styleState.centerHorizontally,
      centerVertically: styleState.centerVertically,
      borderStyle: styleState.borderStyle,
      fontScale: styleState.fontScale,
      cornerRadius: styleState.cornerRadius,
      innerPadding: styleState.innerPadding,
      outerPadding: styleState.outerPadding,
      opacity: styleState.opacity,
      courseColorOverrides: styleState.courseColorOverrides,
    );
  }

  Color colorFor(CourseModel course) => ScheduleColorResolver.colorForCourse(
    course,
    colorPool,
    courseColorOverrides,
  );

  Color textFor(Color background) =>
      courseTextColor ?? ScheduleColorResolver.autoContrast(background);
}
