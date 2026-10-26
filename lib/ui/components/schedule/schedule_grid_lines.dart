import 'package:material_ui/material_ui.dart';

/// 课表线条的统一坐标与绘制。
///
/// 表头、时间列和网格必须使用完全相同的 `drawLine` 语义（0.5px 居中描边），
/// 否则 `Border` 的向内描边与 `drawLine` 会产生约 0.25px 的偏差，在分数宽度
/// 或不同 DPR 下表现为“差一条线”。
class ScheduleGridLines {
  const ScheduleGridLines._();

  static const double strokeWidth = 0.5;

  static List<double> verticalOffsets(double width, int columns) {
    if (columns <= 0) return const <double>[];
    return List<double>.generate(columns + 1, (index) {
      return index * width / columns;
    });
  }

  static List<double> horizontalOffsets(double cellHeight, int rows) {
    if (rows <= 0) return const <double>[];
    return List<double>.generate(rows + 1, (index) {
      return index * cellHeight;
    });
  }

  static Paint createPaint(Color color) {
    return Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
  }
}

/// 课程网格日区域的横竖线。
class ScheduleDayGridPainter extends CustomPainter {
  const ScheduleDayGridPainter({
    required this.color,
    required this.cellHeight,
    required this.rowCount,
    this.columnCount = 7,
  });

  final Color color;
  final double cellHeight;
  final int rowCount;
  final int columnCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = ScheduleGridLines.createPaint(color);

    for (final x in ScheduleGridLines.verticalOffsets(
      size.width,
      columnCount,
    )) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (final y in ScheduleGridLines.horizontalOffsets(cellHeight, rowCount)) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ScheduleDayGridPainter oldDelegate) {
    return color != oldDelegate.color ||
        cellHeight != oldDelegate.cellHeight ||
        rowCount != oldDelegate.rowCount ||
        columnCount != oldDelegate.columnCount;
  }
}

/// 时间列的横线。
class ScheduleHorizontalLinesPainter extends CustomPainter {
  const ScheduleHorizontalLinesPainter({
    required this.color,
    required this.cellHeight,
    required this.rowCount,
  });

  final Color color;
  final double cellHeight;
  final int rowCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = ScheduleGridLines.createPaint(color);
    for (final y in ScheduleGridLines.horizontalOffsets(cellHeight, rowCount)) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ScheduleHorizontalLinesPainter oldDelegate) {
    return color != oldDelegate.color ||
        cellHeight != oldDelegate.cellHeight ||
        rowCount != oldDelegate.rowCount;
  }
}

/// 表头：左侧时间列占位与 7 个日单元格的竖线，以及表头底边。
class ScheduleHeaderLinesPainter extends CustomPainter {
  const ScheduleHeaderLinesPainter({
    required this.color,
    required this.timeColumnWidth,
    this.columnCount = 7,
  });

  final Color color;
  final double timeColumnWidth;
  final int columnCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = ScheduleGridLines.createPaint(color);

    // 表头底边（横跨左侧占位和所有日单元格）。
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint,
    );

    // 日区域的竖线：从 timeColumnWidth 开始，与网格日区域使用同样的比例。
    final dayWidth = (size.width - timeColumnWidth) / columnCount;
    for (var index = 0; index <= columnCount; index++) {
      final x = timeColumnWidth + index * dayWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ScheduleHeaderLinesPainter oldDelegate) {
    return color != oldDelegate.color ||
        timeColumnWidth != oldDelegate.timeColumnWidth ||
        columnCount != oldDelegate.columnCount;
  }
}
