import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';

/// Pure-paint ornaments rooted in Hindu manuscript / temple geometry.
///
/// Primitives:
///  * [MandalaBackdrop] — concentric mandala (rings + spokes + petals + dots).
///  * [ToranaArch]      — multi-foiled temple arch with hanging pendant.
///  * [VineFlourish]    — manuscript-style divider with central rosette.
///  * [JaaliLattice]    — repeating star-hex jaali screen for hero backgrounds.
///  * [LotusMedallion]  — 8-petal radial badge for verse / chapter numbers.
///  * [KalashFinial]    — temple corner pot+coconut silhouette.
///
/// All ornaments inherit colour from the saffron palette and respect dark
/// mode automatically. No images, no SVGs — pure CustomPainter.

// ─────────────────────────────────────────────────────────────────────────────
//  MandalaBackdrop
// ─────────────────────────────────────────────────────────────────────────────

class MandalaBackdrop extends StatelessWidget {
  const MandalaBackdrop({
    super.key,
    this.size = 320,
    this.opacity,
  });

  final double size;
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    final resolvedOpacity = opacity ?? (isDark ? 0.10 : 0.24);
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _MandalaPainter(color: color, baseOpacity: resolvedOpacity),
        ),
      ),
    );
  }
}

class _MandalaPainter extends CustomPainter {
  _MandalaPainter({required this.color, required this.baseOpacity});

  final Color color;
  final double baseOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = color.withValues(alpha: baseOpacity);

    final petalPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: baseOpacity * 1.3);

    final spokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4
      ..color = color.withValues(alpha: baseOpacity * 0.7);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: baseOpacity * 1.6);

    // Concentric rings
    for (final f in const [0.32, 0.55, 0.82, 0.96]) {
      canvas.drawCircle(center, r * f, ringPaint);
    }

    // 16 spokes (cardinal + ordinal + half-steps)
    const spokes = 16;
    for (var i = 0; i < spokes; i++) {
      final a = (math.pi * 2 / spokes) * i;
      final start = center + Offset(math.cos(a), math.sin(a)) * (r * 0.32);
      final end = center + Offset(math.cos(a), math.sin(a)) * (r * 0.96);
      canvas.drawLine(start, end, spokePaint);
    }

    // 12-petal lotus ring (between 0.55 and 0.82)
    const petals = 12;
    for (var i = 0; i < petals; i++) {
      final a = (math.pi * 2 / petals) * i - math.pi / 2;
      final mid = center + Offset(math.cos(a), math.sin(a)) * (r * 0.685);
      _drawPetal(canvas, mid, a, r * 0.13, petalPaint);
    }

    // Dot terminals on outer ring (every other spoke)
    for (var i = 0; i < spokes; i += 2) {
      final a = (math.pi * 2 / spokes) * i;
      final pt = center + Offset(math.cos(a), math.sin(a)) * (r * 0.96);
      canvas.drawCircle(pt, 1.6, dotPaint);
    }

    // Center bindu
    canvas.drawCircle(center, 2.2, dotPaint);
  }

  void _drawPetal(Canvas canvas, Offset c, double angle, double len, Paint p) {
    final path = Path();
    final t = Offset(math.cos(angle), math.sin(angle));
    final n = Offset(-t.dy, t.dx);
    final tip = c + t * len;
    final back = c - t * (len * 0.55);
    path.moveTo(back.dx, back.dy);
    path.quadraticBezierTo(
      (c + n * (len * 0.55)).dx,
      (c + n * (len * 0.55)).dy,
      tip.dx,
      tip.dy,
    );
    path.quadraticBezierTo(
      (c - n * (len * 0.55)).dx,
      (c - n * (len * 0.55)).dy,
      back.dx,
      back.dy,
    );
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _MandalaPainter old) =>
      old.color != color || old.baseOpacity != baseOpacity;
}

// ─────────────────────────────────────────────────────────────────────────────
//  ToranaArch
// ─────────────────────────────────────────────────────────────────────────────

/// Temple-arch crown. Three cusps + hanging pendant. Sits above the content
/// of a hero card. Width fills parent; [height] controls the crown depth.
class ToranaArch extends StatelessWidget {
  const ToranaArch({super.key, this.height = 36});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: _ToranaPainter(color: color, isDark: isDark)),
    );
  }
}

class _ToranaPainter extends CustomPainter {
  _ToranaPainter({required this.color, required this.isDark});

  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeAlpha = isDark ? 0.55 : 0.30;
    final fillAlpha   = isDark ? 0.85 : 0.55;
    final curlAlpha   = isDark ? 0.42 : 0.22;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: strokeAlpha);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: fillAlpha);

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final baseY = h - 1;
    final span = math.min(w * 0.62, 240.0);
    final left = cx - span / 2;
    final right = cx + span / 2;

    // Three cusps: small-large-small
    final cuspH1 = h * 0.55;
    final cuspH2 = h * 0.95;
    final cuspH3 = h * 0.55;
    final p1 = left + span * 0.20;
    final p2 = cx;
    final p3 = right - span * 0.20;

    final path = Path()..moveTo(left, baseY);
    // Left cusp
    path.quadraticBezierTo(
      (left + p1) / 2,
      baseY - cuspH1 - 4,
      p1,
      baseY - cuspH1,
    );
    path.quadraticBezierTo(
      (p1 + p2) / 2,
      baseY - cuspH1 + 6,
      (p1 + p2) / 2,
      baseY - cuspH1 * 0.45,
    );
    // Center cusp (tallest)
    path.quadraticBezierTo(
      (p1 + p2) / 2,
      baseY - cuspH2,
      p2,
      baseY - cuspH2,
    );
    path.quadraticBezierTo(
      (p2 + p3) / 2,
      baseY - cuspH2,
      (p2 + p3) / 2,
      baseY - cuspH3 * 0.45,
    );
    // Right cusp (mirror of left)
    path.quadraticBezierTo(
      (p2 + p3) / 2,
      baseY - cuspH3 + 6,
      p3,
      baseY - cuspH3,
    );
    path.quadraticBezierTo(
      (p3 + right) / 2,
      baseY - cuspH3 - 4,
      right,
      baseY,
    );

    canvas.drawPath(path, stroke);

    // Pendant drop hanging from centre cusp
    final pendantTop = Offset(cx, baseY - cuspH2 + 2);
    final pendantBottom = Offset(cx, h * 0.06);
    canvas.drawLine(pendantTop, pendantBottom, stroke);
    canvas.drawCircle(Offset(cx, h * 0.045), 2.4, fill);

    // Cusp peak dots
    canvas.drawCircle(Offset(p1, baseY - cuspH1 - 1), 1.4, fill);
    canvas.drawCircle(Offset(p2, baseY - cuspH2 - 1), 1.8, fill);
    canvas.drawCircle(Offset(p3, baseY - cuspH3 - 1), 1.4, fill);

    // Side flourishes — tiny outward curls at base
    final curl = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: curlAlpha);
    final curlL = Path()
      ..moveTo(left, baseY)
      ..quadraticBezierTo(left - 10, baseY - 4, left - 18, baseY)
      ..quadraticBezierTo(left - 14, baseY + 3, left - 8, baseY + 1);
    final curlR = Path()
      ..moveTo(right, baseY)
      ..quadraticBezierTo(right + 10, baseY - 4, right + 18, baseY)
      ..quadraticBezierTo(right + 14, baseY + 3, right + 8, baseY + 1);
    canvas.drawPath(curlL, curl);
    canvas.drawPath(curlR, curl);
  }

  @override
  bool shouldRepaint(covariant _ToranaPainter old) =>
      old.color != color || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
//  VineFlourish
// ─────────────────────────────────────────────────────────────────────────────

/// Section divider with manuscript flourish: tapering rule, central 4-petal
/// rosette, dot terminals. Width fills parent.
class VineFlourish extends StatelessWidget {
  const VineFlourish({
    super.key,
    this.height = 18,
    this.maxWidth = 220,
  });

  final double height;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return Center(
      child: SizedBox(
        width: maxWidth,
        height: height,
        child: CustomPaint(painter: _VinePainter(color: color, isDark: isDark)),
      ),
    );
  }
}

class _VinePainter extends CustomPainter {
  _VinePainter({required this.color, required this.isDark});

  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final ruleAlpha  = isDark ? 0.40 : 0.30;
    final petalAlpha = isDark ? 0.70 : 0.55;
    final dotAlpha   = isDark ? 0.75 : 0.60;

    final cy = size.height / 2;
    final cx = size.width / 2;

    final rule = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: ruleAlpha);

    final petal = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: petalAlpha);

    final dot = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: dotAlpha);

    const rosetteR = 6.0;
    canvas.drawLine(Offset(0, cy), Offset(cx - rosetteR - 8, cy), rule);
    canvas.drawLine(Offset(cx + rosetteR + 8, cy), Offset(size.width, cy), rule);
    canvas.drawCircle(Offset(0, cy), 1.2, dot);
    canvas.drawCircle(Offset(size.width, cy), 1.2, dot);

    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final tip = Offset(cx + math.cos(a) * rosetteR, cy + math.sin(a) * rosetteR);
      final n = Offset(-math.sin(a), math.cos(a));
      final ctrl1 = Offset(cx, cy) + n * (rosetteR * 0.6);
      final ctrl2 = Offset(cx, cy) - n * (rosetteR * 0.6);
      final path = Path()
        ..moveTo(cx, cy)
        ..quadraticBezierTo(ctrl1.dx, ctrl1.dy, tip.dx, tip.dy)
        ..quadraticBezierTo(ctrl2.dx, ctrl2.dy, cx, cy);
      canvas.drawPath(path, petal);
    }
    canvas.drawCircle(Offset(cx, cy), 1.4, dot);
  }

  @override
  bool shouldRepaint(covariant _VinePainter old) =>
      old.color != color || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
//  JaaliLattice
// ─────────────────────────────────────────────────────────────────────────────

/// Repeating star-and-hexagon jaali screen — the perforated stone lattice
/// found at Fatehpur Sikri, Sidi Saiyyed, and countless temple windows.
/// Sits as a faint backdrop behind hero Sanskrit. No fill — pure stroke.
class JaaliLattice extends StatelessWidget {
  const JaaliLattice({
    super.key,
    this.cell = 28,
    this.opacity = 0.10,
  });

  final double cell;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _JaaliPainter(
            color: color,
            baseOpacity: opacity,
            cell: cell,
          ),
        ),
      ),
    );
  }
}

class _JaaliPainter extends CustomPainter {
  _JaaliPainter({
    required this.color,
    required this.baseOpacity,
    required this.cell,
  });

  final Color color;
  final double baseOpacity;
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: baseOpacity);

    final dot = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: baseOpacity * 1.4);

    final r = cell / 2;
    final dx = cell;
    final dy = cell * 0.866; // hex row pitch (cos 30°)

    // Soft radial mask — fade jaali at edges so it never fights text.
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = math.sqrt(cx * cx + cy * cy);

    for (var row = -1; row * dy < size.height + dy; row++) {
      final y = row * dy;
      final rowOffset = (row.isOdd) ? dx / 2 : 0.0;
      for (var col = -1; col * dx + rowOffset < size.width + dx; col++) {
        final x = col * dx + rowOffset;
        final c = Offset(x, y);

        // Distance falloff for opacity (denser at center).
        final d = (Offset(cx, cy) - c).distance / maxR;
        final fade = (1.0 - d * 0.95).clamp(0.0, 1.0);
        if (fade < 0.05) continue;

        stroke.color = color.withValues(alpha: baseOpacity * fade);
        dot.color = color.withValues(alpha: baseOpacity * 1.4 * fade);

        // 6-point star (two triangles)
        final tri1 = Path();
        final tri2 = Path();
        for (var i = 0; i < 3; i++) {
          final a1 = -math.pi / 2 + i * (math.pi * 2 / 3);
          final a2 = math.pi / 2 + i * (math.pi * 2 / 3);
          final p1 = c + Offset(math.cos(a1), math.sin(a1)) * r;
          final p2 = c + Offset(math.cos(a2), math.sin(a2)) * r;
          if (i == 0) {
            tri1.moveTo(p1.dx, p1.dy);
            tri2.moveTo(p2.dx, p2.dy);
          } else {
            tri1.lineTo(p1.dx, p1.dy);
            tri2.lineTo(p2.dx, p2.dy);
          }
        }
        tri1.close();
        tri2.close();
        canvas.drawPath(tri1, stroke);
        canvas.drawPath(tri2, stroke);

        // Centre dot.
        canvas.drawCircle(c, 0.9, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _JaaliPainter old) =>
      old.color != color ||
      old.baseOpacity != baseOpacity ||
      old.cell != cell;
}

// ─────────────────────────────────────────────────────────────────────────────
//  LotusMedallion
// ─────────────────────────────────────────────────────────────────────────────

/// Circular badge with eight stroke petals around a deep-red bindu and a
/// numeric label. Replaces flat verse-number chips. Use for chapter/verse
/// reference markers on hero cards or section heads.
class LotusMedallion extends StatelessWidget {
  const LotusMedallion({
    super.key,
    required this.label,
    this.size = 44,
  });

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final petalColor = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    const centerColor = AppColors.deepRed;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _LotusPainter(
              petalColor: petalColor,
              centerColor: centerColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: size * 0.32,
              fontWeight: FontWeight.w700,
              color: centerColor,
              height: 1.0,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _LotusPainter extends CustomPainter {
  _LotusPainter({required this.petalColor, required this.centerColor});

  final Color petalColor;
  final Color centerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;

    final petal = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = petalColor.withValues(alpha: 0.85);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = petalColor.withValues(alpha: 0.55);

    final centerFill = Paint()
      ..style = PaintingStyle.fill
      ..color = centerColor.withValues(alpha: 0.12);

    // Outer + inner rings
    canvas.drawCircle(c, r * 0.96, ring);
    canvas.drawCircle(c, r * 0.78, ring);
    // Centre disc fill (deep-red wash)
    canvas.drawCircle(c, r * 0.78, centerFill);

    // 8 petals between r*0.78 and r*0.96 — alternate orientations
    const petals = 8;
    final petalLen = r * 0.18;
    final petalBase = r * 0.78;
    for (var i = 0; i < petals; i++) {
      final a = (math.pi * 2 / petals) * i - math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      final n = Offset(-dir.dy, dir.dx);
      final base = c + dir * petalBase;
      final tip = c + dir * (petalBase + petalLen);
      final w = petalLen * 0.45;
      final path = Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(
          (base + n * w).dx,
          (base + n * w).dy,
          tip.dx,
          tip.dy,
        )
        ..quadraticBezierTo(
          (base - n * w).dx,
          (base - n * w).dy,
          base.dx,
          base.dy,
        );
      canvas.drawPath(path, petal);
    }

    // Tiny dots between petals (inner ring)
    final dot = Paint()
      ..style = PaintingStyle.fill
      ..color = petalColor.withValues(alpha: 0.7);
    for (var i = 0; i < petals; i++) {
      final a = (math.pi * 2 / petals) * i + math.pi / petals - math.pi / 2;
      final p = c + Offset(math.cos(a), math.sin(a)) * (r * 0.87);
      canvas.drawCircle(p, 0.9, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _LotusPainter old) =>
      old.petalColor != petalColor || old.centerColor != centerColor;
}

// ─────────────────────────────────────────────────────────────────────────────
//  KalashFinial
// ─────────────────────────────────────────────────────────────────────────────

/// Tiny temple finial: stepped base, bulbous pot (kalasha), neck, coconut,
/// and crowning leaf. Pair at top corners of a hero card to evoke a shrine.
class KalashFinial extends StatelessWidget {
  const KalashFinial({
    super.key,
    this.height = 42,
    this.flip = false,
  });

  final double height;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    final widget = SizedBox(
      width: height * 0.55,
      height: height,
      child: CustomPaint(painter: _KalashPainter(color: color, isDark: isDark)),
    );
    if (!flip) return widget;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
      child: widget,
    );
  }
}

class _KalashPainter extends CustomPainter {
  _KalashPainter({required this.color, required this.isDark});

  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeAlpha = isDark ? 0.65 : 0.45;
    final fillAlpha   = isDark ? 0.85 : 0.65;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: strokeAlpha);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: fillAlpha);

    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Stepped base (3 thin rectangles)
    final baseY = h - 2;
    final stepW1 = w * 0.95;
    final stepW2 = w * 0.78;
    final stepW3 = w * 0.62;
    canvas.drawLine(
      Offset(cx - stepW1 / 2, baseY),
      Offset(cx + stepW1 / 2, baseY),
      stroke,
    );
    canvas.drawLine(
      Offset(cx - stepW2 / 2, baseY - 3),
      Offset(cx + stepW2 / 2, baseY - 3),
      stroke,
    );
    canvas.drawLine(
      Offset(cx - stepW3 / 2, baseY - 6),
      Offset(cx + stepW3 / 2, baseY - 6),
      stroke,
    );

    // Pot (kalasha) — bulb shape via two arcs
    final potTop = baseY - 6;
    final potBottom = potTop;
    final potBulgeY = potTop - h * 0.28;
    final potNeckY = potTop - h * 0.46;
    final potW = w * 0.7;
    final neckW = w * 0.34;

    final potPath = Path()
      ..moveTo(cx - neckW / 2, potNeckY)
      ..quadraticBezierTo(
        cx - potW / 2 - 2,
        potBulgeY,
        cx - potW * 0.45,
        potBottom,
      )
      ..lineTo(cx + potW * 0.45, potBottom)
      ..quadraticBezierTo(
        cx + potW / 2 + 2,
        potBulgeY,
        cx + neckW / 2,
        potNeckY,
      );
    canvas.drawPath(potPath, stroke);

    // Neck rim
    canvas.drawLine(
      Offset(cx - neckW / 2 - 1, potNeckY),
      Offset(cx + neckW / 2 + 1, potNeckY),
      stroke,
    );

    // Coconut (small filled circle)
    final coconutY = potNeckY - h * 0.12;
    canvas.drawCircle(Offset(cx, coconutY), w * 0.18, fill);

    // Mango / ashoka leaf — single curl above the coconut
    final leafBase = Offset(cx, coconutY - w * 0.15);
    final leafTip = Offset(cx + w * 0.12, 1);
    final leafPath = Path()
      ..moveTo(leafBase.dx, leafBase.dy)
      ..quadraticBezierTo(
        cx - w * 0.05,
        (leafBase.dy + leafTip.dy) / 2,
        leafTip.dx,
        leafTip.dy,
      )
      ..quadraticBezierTo(
        cx + w * 0.18,
        (leafBase.dy + leafTip.dy) / 2 + 4,
        leafBase.dx,
        leafBase.dy,
      );
    canvas.drawPath(leafPath, stroke);
  }

  @override
  bool shouldRepaint(covariant _KalashPainter old) =>
      old.color != color || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
//  GangaWaveBackdrop
// ─────────────────────────────────────────────────────────────────────────────

/// Full-bleed background for the onboarding screen.
/// Paints: sky gradient, sun disk with radial glow at horizon,
/// ghats silhouettes left+right, and three sine-wave Ganga paths.
class GangaWaveBackdrop extends StatelessWidget {
  const GangaWaveBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(painter: _GangaWavePainter(isDark: isDark)),
      ),
    );
  }
}

class _GangaWavePainter extends CustomPainter {
  const _GangaWavePainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Sky gradient
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? const [Color(0xFF1A0E2A), Color(0xFF3D1800), Color(0xFF2D1500)]
            : const [Color(0xFFFDFAF6), Color(0xFFFFF3E0), Color(0xFFFDE8C8)],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Sun radial glow
    final sunY = h * 0.76;
    final sunColor = isDark ? const Color(0xFFF4A830) : const Color(0xFFE8820C);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          sunColor.withValues(alpha: isDark ? 0.35 : 0.20),
          sunColor.withValues(alpha: isDark ? 0.10 : 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(
        Rect.fromCircle(center: Offset(cx, sunY), radius: w * 0.55),
      );
    canvas.drawCircle(Offset(cx, sunY), w * 0.55, glowPaint);

    // Sun disk
    canvas.drawCircle(
      Offset(cx, sunY),
      14,
      Paint()
        ..style = PaintingStyle.fill
        ..color = sunColor.withValues(alpha: isDark ? 0.90 : 0.70),
    );
    // Inner highlight
    canvas.drawCircle(
      Offset(cx, sunY),
      8,
      Paint()
        ..style = PaintingStyle.fill
        ..color = (isDark ? const Color(0xFFFFE08A) : const Color(0xFFFFF3D0))
            .withValues(alpha: 0.80),
    );

    // Horizon line
    canvas.drawLine(
      Offset(0, sunY + 14),
      Offset(w, sunY + 14),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = sunColor.withValues(alpha: 0.35),
    );

    // Ghats silhouettes
    final ghatsColor = isDark ? const Color(0xFF0F0508) : const Color(0xFFD4C4B0);
    final ghatsPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = ghatsColor.withValues(alpha: isDark ? 0.85 : 0.40);

    final leftGhats = Path()
      ..moveTo(0, sunY + 14)
      ..lineTo(0, h * 0.60)
      ..lineTo(w * 0.06, h * 0.60)
      ..lineTo(w * 0.06, h * 0.52)
      ..lineTo(w * 0.12, h * 0.52)
      ..lineTo(w * 0.12, h * 0.56)
      ..lineTo(w * 0.18, h * 0.56)
      ..lineTo(w * 0.18, h * 0.50)
      ..lineTo(w * 0.22, h * 0.50)
      ..lineTo(w * 0.22, h * 0.58)
      ..lineTo(w * 0.28, h * 0.58)
      ..lineTo(w * 0.28, sunY + 14)
      ..close();
    canvas.drawPath(leftGhats, ghatsPaint);

    final rightGhats = Path()
      ..moveTo(w, sunY + 14)
      ..lineTo(w, h * 0.60)
      ..lineTo(w * 0.94, h * 0.60)
      ..lineTo(w * 0.94, h * 0.52)
      ..lineTo(w * 0.88, h * 0.52)
      ..lineTo(w * 0.88, h * 0.56)
      ..lineTo(w * 0.82, h * 0.56)
      ..lineTo(w * 0.82, h * 0.50)
      ..lineTo(w * 0.78, h * 0.50)
      ..lineTo(w * 0.78, h * 0.58)
      ..lineTo(w * 0.72, h * 0.58)
      ..lineTo(w * 0.72, sunY + 14)
      ..close();
    canvas.drawPath(rightGhats, ghatsPaint);

    // Three Ganga wave sine paths
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final waveConfigs = [
      (h * 0.80, 0.38, 1.0),
      (h * 0.86, 0.28, 0.8),
      (h * 0.92, 0.20, 0.6),
    ];

    for (final (y, alpha, strokeW) in waveConfigs) {
      wavePaint.color = sunColor.withValues(alpha: alpha);
      wavePaint.strokeWidth = strokeW;
      final wavePath = Path();
      const steps = 40;
      for (var i = 0; i <= steps; i++) {
        final x = w * i / steps;
        final dy = math.sin((x / w) * math.pi * 4) * h * 0.012;
        if (i == 0) {
          wavePath.moveTo(x, y + dy);
        } else {
          wavePath.lineTo(x, y + dy);
        }
      }
      canvas.drawPath(wavePath, wavePaint);
    }

    // Sun reflection on water
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * 0.84),
        width: w * 0.12,
        height: h * 0.02,
      ),
      Paint()
        ..style = PaintingStyle.fill
        ..color = sunColor.withValues(alpha: 0.18),
    );
  }

  @override
  bool shouldRepaint(covariant _GangaWavePainter old) => old.isDark != isDark;
}
