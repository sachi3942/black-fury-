import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Paints two glowing Toothless-style slit-pupil eyes.
///
/// [openAmount] 0.0 -> fully closed (just a thin line), 1.0 -> fully open.
/// [glowIntensity] drives the pulse-particle glow radius/opacity.
class ToothlessEyesPainter extends CustomPainter {
  final double openAmount;
  final double glowIntensity;

  ToothlessEyesPainter({
    required this.openAmount,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final eyeSpacing = size.width * 0.22;
    final eyeWidth = size.width * 0.16;
    final eyeHeight = eyeWidth * 0.62 * openAmount.clamp(0.05, 1.0);

    final leftCenter = center - Offset(eyeSpacing, 0);
    final rightCenter = center + Offset(eyeSpacing, 0);

    _drawGlowParticles(canvas, leftCenter, eyeWidth);
    _drawGlowParticles(canvas, rightCenter, eyeWidth);

    _drawEye(canvas, leftCenter, eyeWidth, eyeHeight);
    _drawEye(canvas, rightCenter, eyeWidth, eyeHeight);
  }

  void _drawGlowParticles(Canvas canvas, Offset eyeCenter, double eyeWidth) {
    final rand = Random(eyeCenter.dx.toInt());
    final particlePaint = Paint()
      ..color = AppColors.neonGreen.withOpacity(0.35 * glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    for (int i = 0; i < 10; i++) {
      final angle = rand.nextDouble() * 2 * pi;
      final radius = eyeWidth * (0.9 + rand.nextDouble() * 1.4) * glowIntensity;
      final offset = eyeCenter + Offset(cos(angle) * radius, sin(angle) * radius);
      canvas.drawCircle(offset, 1.6 + rand.nextDouble() * 2.2, particlePaint);
    }
  }

  void _drawEye(Canvas canvas, Offset eyeCenter, double width, double height) {
    // Outer glow
    final glowPaint = Paint()
      ..color = AppColors.neonGreen.withOpacity(0.6 * glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    final glowRect = Rect.fromCenter(center: eyeCenter, width: width * 1.4, height: height * 3 + 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(glowRect, Radius.circular(height)),
      glowPaint,
    );

    // Eye "sclera" glow shape (soft rounded diamond)
    final scleraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.neonGreen.withOpacity(0.9),
          AppColors.emerald.withOpacity(0.15),
        ],
      ).createShader(Rect.fromCenter(center: eyeCenter, width: width, height: height + 4));

    final scleraRect = Rect.fromCenter(center: eyeCenter, width: width, height: height + 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(scleraRect, Radius.circular((height + 4) / 2)),
      scleraPaint,
    );

    // Slit pupil (thin vertical-ish black slit, Toothless style is more
    // horizontal-narrow when excited; we draw a narrow black capsule).
    final pupilPaint = Paint()..color = const Color(0xFF020402);
    final pupilRect = Rect.fromCenter(
      center: eyeCenter,
      width: width * 0.22,
      height: height * 0.9,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pupilRect, Radius.circular(pupilRect.width / 2)),
      pupilPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ToothlessEyesPainter oldDelegate) {
    return oldDelegate.openAmount != openAmount ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}
