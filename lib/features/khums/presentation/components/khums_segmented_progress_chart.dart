import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pockaw/core/constants/app_colors.dart';
import 'package:pockaw/core/constants/app_text_styles.dart';

class KhumsSegmentedProgressChart extends StatelessWidget {
  final int totalSegments;
  final int completedSegments;
  final double size;
  final double strokeWidth;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showPercentage;

  const KhumsSegmentedProgressChart({
    super.key,
    required this.totalSegments,
    required this.completedSegments,
    this.size = 56,
    this.strokeWidth = 5.0,
    this.activeColor,
    this.inactiveColor,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTotal = totalSegments > 0 ? totalSegments : 1;
    final effectiveCompleted =
        completedSegments.clamp(0, effectiveTotal);
    final percentage = (effectiveCompleted / effectiveTotal * 100).round();

    final active = activeColor ?? AppColors.primary;
    final inactive = inactiveColor ?? context.secondaryBorderLighter;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _SegmentedCirclePainter(
              totalSegments: effectiveTotal,
              completedSegments: effectiveCompleted,
              strokeWidth: strokeWidth,
              activeColor: active,
              inactiveColor: inactive,
            ),
          ),
          if (showPercentage)
            Text(
              '$percentage%',
              style: AppTextStyles.body4.copyWith(
                fontSize: size > 50 ? 11 : 9,
                fontWeight: FontWeight.bold,
                color: active,
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentedCirclePainter extends CustomPainter {
  final int totalSegments;
  final int completedSegments;
  final double strokeWidth;
  final Color activeColor;
  final Color inactiveColor;

  _SegmentedCirclePainter({
    required this.totalSegments,
    required this.completedSegments,
    required this.strokeWidth,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    if (totalSegments <= 1) {
      // Single continuous ring
      final bgPaint = Paint()
        ..color = inactiveColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius, bgPaint);

      if (completedSegments >= 1) {
        final fgPaint = Paint()
          ..color = activeColor
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(center, radius, fgPaint);
      }
      return;
    }

    final totalAngle = 2 * math.pi;
    final gapAngle = totalSegments > 16
        ? 0.04
        : totalSegments > 8
            ? 0.07
            : 0.12; // Gap in radians between segments
    final totalGap = gapAngle * totalSegments;
    final sweepAngle = (totalAngle - totalGap) / totalSegments;

    // Start angle from top (-pi / 2)
    double startAngle = -math.pi / 2;

    for (int i = 0; i < totalSegments; i++) {
      final isCompleted = i < completedSegments;

      final paint = Paint()
        ..color = isCompleted ? activeColor : inactiveColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedCirclePainter oldDelegate) {
    return oldDelegate.totalSegments != totalSegments ||
        oldDelegate.completedSegments != completedSegments ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}
