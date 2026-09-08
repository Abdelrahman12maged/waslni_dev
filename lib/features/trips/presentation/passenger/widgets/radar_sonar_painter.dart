import 'package:car_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RadarSonarPainter extends CustomPainter {
  final double progress;

  const RadarSonarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final currentProgress = (progress + (i * 0.33)) % 1.0;
      final radius = currentProgress * maxRadius;
      final opacity = (1.0 - currentProgress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = AppColors.primary.withOpacity(opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);

      final fillPaint = Paint()
        ..color = AppColors.primary.withOpacity(opacity * 0.08)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RadarSonarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
