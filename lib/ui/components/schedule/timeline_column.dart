import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_grid_lines.dart';

/// 时间轴列组件。
///
/// 展示节次编号和对应的起止时间。
class TimelineColumn extends StatelessWidget {
  const TimelineColumn({
    super.key,
    required this.periodCount,
    required this.cellHeight,
    this.isYanTa = false,
    this.showGrid = true,
    this.timeColumnWidth = 45,
    this.hideSectionTime = false,
    this.textColor,
  });

  final int periodCount;
  final double cellHeight;
  final bool isYanTa;
  final bool showGrid;
  final double timeColumnWidth;
  final bool hideSectionTime;

  /// 课表页面文字颜色；为空时跟随主题。
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;

    return SizedBox(
      width: timeColumnWidth,
      child: CustomPaint(
        foregroundPainter: showGrid
            ? ScheduleHorizontalLinesPainter(
                color: colors.separator,
                cellHeight: cellHeight,
                rowCount: periodCount,
              )
            : null,
        child: Column(
          children: List.generate(periodCount, (index) {
            return SizedBox(
              height: cellHeight,
              child: _buildSectionCell(index + 1, colors),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSectionCell(int period, McColors colors) {
    final timeInfo = _getTimeInfo(period);

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 节次
            Text(
              '$period',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor ?? colors.label,
              ),
            ),
            if (!hideSectionTime) ...[
              const SizedBox(height: 2),
              // 开始时间
              Text(
                timeInfo.start,
                style: TextStyle(
                  fontSize: 9,
                  color:
                      textColor?.withValues(alpha: 0.7) ?? colors.tertiaryLabel,
                ),
              ),
              // 结束时间
              Text(
                timeInfo.end,
                style: TextStyle(
                  fontSize: 9,
                  color:
                      textColor?.withValues(alpha: 0.7) ?? colors.tertiaryLabel,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  ({String start, String end}) _getTimeInfo(int period) {
    // 作息表由 ScheduleTimeService 装载（远端优先，内置兜底），这里同步读取；
    // 雁塔的季节由表上的适用区间决定，节次越界时回退草堂时间。
    final time = TimeService.getStartAndEndForCampus(
      campus: isYanTa ? TimeService.yanTaCampus : TimeService.caoTangCampus,
      startUnit: period,
      endUnit: period,
    );

    return (start: time.start, end: time.end);
  }
}
