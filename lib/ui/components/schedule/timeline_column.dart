import 'package:flutter/material.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

/// 时间轴列组件
///
/// 简约的苹果风格设计，展示课程节次和对应的时间
class TimelineColumn extends StatelessWidget {
  const TimelineColumn({
    super.key,
    required this.periodCount,
    required this.cellHeight,
    this.isYanTa = false,
    this.showGrid = true,
  });

  final int periodCount;
  final double cellHeight;
  final bool isYanTa;
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;

    return SizedBox(
      width: 56,
      child: Column(
        children: List.generate(periodCount, (index) {
          final period = index + 1;
          final timeInfo = _getTimeInfo(period);

          return Container(
            height: cellHeight,
            decoration: showGrid
                ? BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colors.separator,
                        width: 0.5,
                      ),
                    ),
                  )
                : null,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 节次
                  Text(
                    '$period',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.label,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 开始时间
                  Text(
                    timeInfo.start,
                    style: TextStyle(
                      fontSize: 9,
                      color: colors.tertiaryLabel,
                    ),
                  ),
                  // 结束时间
                  Text(
                    timeInfo.end,
                    style: TextStyle(
                      fontSize: 9,
                      color: colors.tertiaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
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
