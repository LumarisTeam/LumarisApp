import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_background_image.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_grid.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_visual_style.dart';
import 'package:ios_club_app/ui/components/schedule/weekday_header.dart';

/// 个性化页顶部的固定示例课表。
///
/// 只渲染传入的 demo 课程，不读 ScheduleStore；页面在设置提交后重建它一次，
/// 拖动过程中不会触发重建。外层 RepaintBoundary 隔离绘制。
class SchedulePreview extends StatefulWidget {
  const SchedulePreview({
    super.key,
    required this.style,
    required this.courses,
    required this.weekStartDate,
    required this.isDark,
    this.wallpaperPath,
    this.weekStartDay = School.defaultWeekStartDay,
  });

  final ScheduleVisualStyle style;
  final List<CourseModel> courses;
  final DateTime weekStartDate;
  final bool isDark;
  final String? wallpaperPath;
  final int weekStartDay;

  @override
  State<SchedulePreview> createState() => _SchedulePreviewState();
}

class _SchedulePreviewState extends State<SchedulePreview> {
  final ScrollController _scrollController = ScrollController();
  ThemeData? _lightTheme;
  ThemeData? _darkTheme;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ThemeData _themeFor(BuildContext context, bool dark) {
    final locale = Localizations.localeOf(context);
    if (dark) {
      return _darkTheme ??= McThemeData.materialTheme(
        McColors.dark,
        locale: locale,
      );
    }
    return _lightTheme ??= McThemeData.materialTheme(
      McColors.light,
      locale: locale,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final hasWallpaper =
        widget.wallpaperPath != null && widget.wallpaperPath!.isNotEmpty;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: McRadii.cardBorder,
        child: Theme(
          data: _themeFor(context, widget.isDark),
          child: Builder(
            builder: (context) {
              return Material(
                type: MaterialType.transparency,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasWallpaper)
                      ScheduleBackgroundImage(imagePath: widget.wallpaperPath!)
                    else
                      ColoredBox(color: context.mc.colors.background),
                    SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          WeekdayHeader(
                            weekStartDate: widget.weekStartDate,
                            currentWeek: 1,
                            showDate: true,
                            highlightToday: false,
                            showGrid: style.showGrid,
                            height: style.headerHeight,
                            timeColumnWidth: style.timeColumnWidth,
                            hideDateUnderDay: style.hideDateUnderDay,
                            textColor: style.pageTextColor,
                          ),
                          SizedBox(
                            height: style.gridHeight,
                            child: ScheduleGrid(
                              courses: widget.courses,
                              cellHeight: style.cellHeight,
                              weekStartDay: widget.weekStartDay,
                              showGrid: style.showGrid,
                              visualStyle: style,
                              preview: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
