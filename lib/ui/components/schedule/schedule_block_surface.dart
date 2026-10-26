import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:ios_club_app/state/app_states.dart';

/// 课程块/冲突块的统一底色与边框。
///
/// 实线边框直接交给 [ShapeDecoration]；虚线用 [CustomPaint] 沿圆角路径绘制。
class ScheduleBlockSurface extends StatelessWidget {
  const ScheduleBlockSurface({
    super.key,
    required this.color,
    required this.child,
    this.borderStyle = ScheduleBorderStyle.none,
    this.borderColor,
    this.margin = EdgeInsets.zero,
    this.borderRadius = McRadii.controlBorder,
  });

  final Color color;
  final Widget child;
  final ScheduleBorderStyle borderStyle;
  final Color? borderColor;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? context.mc.colors.separator;
    final shape = McSmoothCorners.shape(
      borderRadius,
      side: borderStyle == ScheduleBorderStyle.solid
          ? BorderSide(color: effectiveBorderColor, width: 1)
          : BorderSide.none,
    );

    Widget content = child;
    if (borderStyle == ScheduleBorderStyle.dashed) {
      content = CustomPaint(
        foregroundPainter: _DashedBorderPainter(
          shape: McSmoothCorners.shape(borderRadius),
          color: effectiveBorderColor,
        ),
        child: content,
      );
    }

    return Container(
      margin: margin,
      decoration: ShapeDecoration(shape: shape, color: color),
      child: content,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.shape, required this.color});

  final ShapeBorder shape;
  final Color color;

  static const double _strokeWidth = 1;
  static const double _dashLength = 5;
  static const double _gapLength = 3;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rect = Rect.fromLTWH(
      _strokeWidth / 2,
      _strokeWidth / 2,
      size.width - _strokeWidth,
      size.height - _strokeWidth,
    );
    final path = shape.getOuterPath(rect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + _dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return shape != oldDelegate.shape || color != oldDelegate.color;
  }
}
