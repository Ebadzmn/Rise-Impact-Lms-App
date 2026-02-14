import 'dart:math';
import 'package:flutter/material.dart';

class CircularPercentIndicator extends StatelessWidget {
  final double radius;
  final double lineWidth;
  final double percent;
  final Color progressColor;
  final Color backgroundColor;
  final Widget center;

  const CircularPercentIndicator({
    super.key,
    required this.radius,
    required this.lineWidth,
    required this.percent,
    required this.progressColor,
    required this.backgroundColor,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(radius * 2, radius * 2),
            painter: CirclePainter(
              lineWidth: lineWidth,
              percent: percent,
              progressColor: progressColor,
              backgroundColor: backgroundColor,
            ),
          ),
          Center(child: center),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double lineWidth;
  final double percent;
  final Color progressColor;
  final Color backgroundColor;

  CirclePainter({
    required this.lineWidth,
    required this.percent,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, backgroundPaint);

    double angle = 2 * pi * percent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
