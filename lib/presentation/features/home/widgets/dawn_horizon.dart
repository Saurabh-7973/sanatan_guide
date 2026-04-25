import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';

/// A soft rising-sun ornament that sits above the verse card.
///
/// Pure-Flutter painting (no SVG) — a half-disc of saffron gradient with
/// five thin rays radiating from the horizon point. Rendered behind the
/// verse card, then clipped so the top half of the sun peeks above it.
class DawnHorizon extends StatelessWidget {
  const DawnHorizon({super.key, this.height = 96});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sunColor = isDark ? AppColors.saffronOnDark : AppColors.saffron;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DawnPainter(sunColor: sunColor, isDark: isDark),
      ),
    );
  }
}

class _DawnPainter extends CustomPainter {
  _DawnPainter({required this.sunColor, required this.isDark});

  final Color sunColor;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseline = size.height - 4;
    const sunRadius = 78.0;

    // ── Rays ────────────────────────────────────────────────────────
    final rayPaint = Paint()
      ..color = sunColor.withValues(alpha: isDark ? 0.28 : 0.22)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.75
      ..style = PaintingStyle.stroke;

    const rayAngles = <double>[
      -math.pi * 0.85,
      -math.pi * 0.72,
      -math.pi * 0.5,
      -math.pi * 0.28,
      -math.pi * 0.15,
    ];
    for (final a in rayAngles) {
      final start = Offset(
        cx + math.cos(a) * (sunRadius - 8),
        baseline + math.sin(a) * (sunRadius - 8),
      );
      final end = Offset(
        cx + math.cos(a) * (sunRadius + 24),
        baseline + math.sin(a) * (sunRadius + 24),
      );
      canvas.drawLine(start, end, rayPaint);
    }

    // ── Sun disc (radial gradient, clipped to baseline) ────────────
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, baseline));

    final rect = Rect.fromCircle(
      center: Offset(cx, baseline),
      radius: sunRadius,
    );
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          sunColor.withValues(alpha: isDark ? 0.90 : 0.85),
          sunColor.withValues(alpha: isDark ? 0.35 : 0.40),
          sunColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawCircle(Offset(cx, baseline), sunRadius, sunPaint);

    canvas.restore();

    // ── Horizon line (hairline) ────────────────────────────────────
    final horizonPaint = Paint()
      ..color = sunColor.withValues(alpha: isDark ? 0.18 : 0.16)
      ..strokeWidth = 0.5;
    canvas.drawLine(
      Offset(cx - sunRadius - 40, baseline),
      Offset(cx + sunRadius + 40, baseline),
      horizonPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DawnPainter old) =>
      old.sunColor != sunColor || old.isDark != isDark;
}
