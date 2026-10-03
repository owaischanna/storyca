import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  const DashedLine({
    super.key,
    this.axis = Axis.horizontal,
    this.thickness = 1,
    this.length,
    this.dashWidth = 6,
    this.dashGap = 4,
    this.color = Colors.white,
  });

  final Axis axis;
  final double thickness;
  final double? length;
  final double dashWidth;
  final double dashGap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = axis == Axis.horizontal
        ? Size(length ?? double.infinity, thickness)
        : Size(thickness, length ?? double.infinity);

    return CustomPaint(
      size: size,
      painter: _DashedLinePainter(
        axis: axis,
        thickness: thickness,
        dashWidth: dashWidth,
        dashGap: dashGap,
        color: color,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({
    required this.axis,
    required this.thickness,
    required this.dashWidth,
    required this.dashGap,
    required this.color,
  });

  final Axis axis;
  final double thickness;
  final double dashWidth;
  final double dashGap;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    var start = 0.0;
    final max = axis == Axis.horizontal ? size.width : size.height;

    while (start < max) {
      final end = (start + dashWidth).clamp(0.0, max);
      if (axis == Axis.horizontal) {
        final y = size.height / 2;
        canvas.drawLine(Offset(start, y), Offset(end, y), paint);
      } else {
        final x = size.width / 2;
        canvas.drawLine(Offset(x, start), Offset(x, end), paint);
      }
      start += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return axis != oldDelegate.axis ||
        thickness != oldDelegate.thickness ||
        dashWidth != oldDelegate.dashWidth ||
        dashGap != oldDelegate.dashGap ||
        color != oldDelegate.color;
  }
}
