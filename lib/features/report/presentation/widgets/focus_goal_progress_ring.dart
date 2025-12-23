import 'dart:math';
import 'package:flutter/material.dart';

/// Widget hiển thị progress ring cho Focus Goal
/// Progress từ 0.0 đến 1.0 (0% - 100%)
class FocusGoalProgressRing extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;
  final Widget? child;

  const FocusGoalProgressRing({
    super.key,
    required this.progress,
    this.size = 36,
    this.strokeWidth = 3,
    this.progressColor = const Color(0xFFFF6B6B),
    this.backgroundColor = const Color(0xFFFFE5E5),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProgressRingPainter(
          progress: progress.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          progressColor: progressColor,
          backgroundColor: backgroundColor,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle (light color)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// Calendar cell với progress ring cho Focus Goal
class FocusGoalCalendarCell extends StatelessWidget {
  final int day;
  final double progress; // 0.0 - 1.0
  final bool isToday;
  final bool isOutside;
  final double size;

  const FocusGoalCalendarCell({
    super.key,
    required this.day,
    required this.progress,
    this.isToday = false,
    this.isOutside = false,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isOutside
        ? Colors.grey.shade400
        : isToday
            ? Colors.white
            : Colors.grey.shade700;

    // Nếu là hôm nay, hiển thị filled circle
    if (isToday) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFFF6B6B),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      );
    }

    // Ngày bình thường với progress ring
    return FocusGoalProgressRing(
      progress: progress,
      size: size,
      strokeWidth: 2.5,
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: 12,
          fontWeight: progress >= 1.0 ? FontWeight.w600 : FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }
}
