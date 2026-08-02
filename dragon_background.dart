import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Persistent Night Fury background: pitch-black base, a faint dragon-scale
/// texture, and a low-opacity Toothless head silhouette watermark.
/// Wrap any screen's content with [DragonBackground] to apply the theme
/// consistently across the whole app.
class DragonBackground extends StatelessWidget {
  final Widget child;
  final double silhouetteOpacity;
  final double scaleOpacity;

  const DragonBackground({
    super.key,
    required this.child,
    this.silhouetteOpacity = 0.05,
    this.scaleOpacity = 0.035,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.background),
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _DragonBackgroundPainter(
                silhouetteOpacity: silhouetteOpacity,
                scaleOpacity: scaleOpacity,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _DragonBackgroundPainter extends CustomPainter {
  final double silhouetteOpacity;
  final double scaleOpacity;

  _DragonBackgroundPainter({
    required this.silhouetteOpacity,
    required this.scaleOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintScaleTexture(canvas, size);
    _paintToothlessSilhouette(canvas, size);
  }

  void _paintScaleTexture(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF16D97A).withOpacity(scaleOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const double scaleW = 46;
    const double scaleH = 30;

    for (double y = -scaleH; y < size.height + scaleH; y += scaleH) {
      final rowIndex = (y / scaleH).round();
      final xOffset = (rowIndex.isOdd) ? scaleW / 2 : 0.0;
      for (double x = -scaleW + xOffset; x < size.width + scaleW; x += scaleW) {
        final rect = Rect.fromCenter(center: Offset(x, y), width: scaleW, height: scaleH * 1.6);
        canvas.drawArc(rect, pi * 0.15, pi * 0.7, false, paint);
      }
    }
  }

  void _paintToothlessSilhouette(Canvas canvas, Size size) {
    // Large watermark silhouette anchored bottom-right, partly off-canvas,
    // echoing the app icon's head + ear-fin shape.
    final headColor = const Color(0xFF12D97A).withOpacity(silhouetteOpacity);
    final paint = Paint()..color = headColor;

    final scale = size.width / 420;
    final cx = size.width * 0.86;
    final cy = size.height * 0.92;

    Path headPath(double cx, double cy, double rx, double ry) {
      final path = Path();
      const n = 60;
      for (int i = 0; i <= n; i++) {
        final t = 2 * pi * i / n;
        final ct = cos(t), st = sin(t);
        final x = cx + rx * ct.sign * pow(ct.abs(), 2 / 2.3);
        double taper = st > 0 ? 1.0 - 0.18 * st * st : 1.0;
        final y = cy + ry * st.sign * pow(st.abs(), 2 / 2.3) * taper;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      return path;
    }

    canvas.drawPath(headPath(cx, cy, 190 * scale, 210 * scale), paint);

    // Ear fins
    Path earPath(double cx, double cy, int side) {
      final dx = side.toDouble();
      final path = Path()
        ..moveTo(cx + dx * 130 * scale, cy - 155 * scale)
        ..lineTo(cx + dx * 210 * scale, cy - 285 * scale)
        ..lineTo(cx + dx * 155 * scale, cy - 185 * scale)
        ..lineTo(cx + dx * 100 * scale, cy - 95 * scale)
        ..close();
      return path;
    }

    canvas.drawPath(earPath(cx, cy, -1), paint);
    canvas.drawPath(earPath(cx, cy, 1), paint);
  }

  @override
  bool shouldRepaint(covariant _DragonBackgroundPainter oldDelegate) {
    return oldDelegate.silhouetteOpacity != silhouetteOpacity ||
        oldDelegate.scaleOpacity != scaleOpacity;
  }
}
