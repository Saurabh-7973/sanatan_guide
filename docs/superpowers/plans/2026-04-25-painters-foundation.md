# Sacred Ornaments — Painters Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix light-mode opacity on all 6 existing ornament painters and add 13 new CustomPainter classes (Ganga, Peacock, Seedling, Diya, Scroll, Forest, NalandaArch, PalmLeaf, PrasadTray, DiyaFlame, TempleStaircase, PeepalTree, DhyanaAsana, OilLampRow, InscriptionBorder, TempleStairs, DiamondKnot, OpenScroll) to `sacred_ornaments.dart`.

**Architecture:** All painters live in `lib/presentation/shared/widgets/sacred_ornaments.dart`. Each painter is a private `CustomPainter` subclass. Each public widget wrapper reads `Theme.of(context).brightness` and selects opacity accordingly. No images, no SVGs — pure `CustomPainter`. New painters follow the exact existing pattern: private `_XxxPainter` class + public `XxxBackdrop` or `XxxWidget` wrapper.

**Tech Stack:** Flutter `CustomPainter`, `dart:math`, `AppColors` from `app_colors.dart`. No new dependencies.

---

## File Map

| File | Action |
|------|--------|
| `lib/presentation/shared/widgets/sacred_ornaments.dart` | Modify: fix 6 painters + append 18 new painters |
| `lib/presentation/features/scripture_reader/widgets/verse_content_sliver.dart` | Modify: fix `JaaliLattice` opacity call |
| `test/presentation/widgets/sacred_ornaments_test.dart` | Create: widget smoke tests |

---

### Task 1: Fix JaaliLattice opacity caller bug

**Files:**
- Modify: `lib/presentation/features/scripture_reader/widgets/verse_content_sliver.dart:316–319`

The caller passes `opacity: isDark ? 0.10 : 0.08`. Light mode 0.08 on cream is invisible. Fix to `isDark ? 0.12 : 0.26`.

- [ ] **Step 1: Open and edit the file**

In `verse_content_sliver.dart` around line 316, change:
```dart
// BEFORE
JaaliLattice(
  cell: 24,
  opacity: isDark ? 0.10 : 0.08,
),
```
to:
```dart
// AFTER
JaaliLattice(
  cell: 24,
  opacity: isDark ? 0.12 : 0.26,
),
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/presentation/features/scripture_reader/widgets/verse_content_sliver.dart
```
Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/features/scripture_reader/widgets/verse_content_sliver.dart
git commit -m "fix: bump JaaliLattice opacity in light mode (0.08→0.26)"
```

---

### Task 2: Make ToranaArch isDark-aware

**Files:**
- Modify: `lib/presentation/shared/widgets/sacred_ornaments.dart` (ToranaArch section)

`_ToranaPainter` bakes `alpha: 0.55` for stroke. On cream this is fine but we want 0.30 in light mode for a subtler look that matches home screen. Pass `isDark` to painter.

- [ ] **Step 1: Update ToranaArch widget**

Replace the `ToranaArch.build()` method:
```dart
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
```

- [ ] **Step 2: Update _ToranaPainter**

Add `isDark` field and use it for opacity:
```dart
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

    // ... rest of paint() body unchanged, but replace all hardcoded 0.42 with curlAlpha
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final baseY = h - 1;
    final span = math.min(w * 0.62, 240.0);
    final left = cx - span / 2;
    final right = cx + span / 2;

    final cuspH1 = h * 0.55;
    final cuspH2 = h * 0.95;
    final cuspH3 = h * 0.55;
    final p1 = left + span * 0.20;
    final p2 = cx;
    final p3 = right - span * 0.20;

    final path = Path()..moveTo(left, baseY);
    path.quadraticBezierTo((left + p1) / 2, baseY - cuspH1 - 4, p1, baseY - cuspH1);
    path.quadraticBezierTo((p1 + p2) / 2, baseY - cuspH1 + 6, (p1 + p2) / 2, baseY - cuspH1 * 0.45);
    path.quadraticBezierTo((p1 + p2) / 2, baseY - cuspH2, p2, baseY - cuspH2);
    path.quadraticBezierTo((p2 + p3) / 2, baseY - cuspH2, (p2 + p3) / 2, baseY - cuspH3 * 0.45);
    path.quadraticBezierTo((p2 + p3) / 2, baseY - cuspH3 + 6, p3, baseY - cuspH3);
    path.quadraticBezierTo((p3 + right) / 2, baseY - cuspH3 - 4, right, baseY);
    canvas.drawPath(path, stroke);

    final pendantTop = Offset(cx, baseY - cuspH2 + 2);
    final pendantBottom = Offset(cx, h * 0.06);
    canvas.drawLine(pendantTop, pendantBottom, stroke);
    canvas.drawCircle(Offset(cx, h * 0.045), 2.4, fill);
    canvas.drawCircle(Offset(p1, baseY - cuspH1 - 1), 1.4, fill);
    canvas.drawCircle(Offset(p2, baseY - cuspH2 - 1), 1.8, fill);
    canvas.drawCircle(Offset(p3, baseY - cuspH3 - 1), 1.4, fill);

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
```

- [ ] **Step 3: Run analyzer**

```bash
flutter analyze lib/presentation/shared/widgets/sacred_ornaments.dart
```

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/shared/widgets/sacred_ornaments.dart
git commit -m "fix: ToranaArch isDark-aware opacity (light 0.30, dark 0.55)"
```

---

### Task 3: Fix VineFlourish, KalashFinial, MandalaBackdrop, LotusMedallion opacity

**Files:**
- Modify: `lib/presentation/shared/widgets/sacred_ornaments.dart`

VineFlourish bakes 0.40/0.70/0.75 — good for dark, but light mode should be more visible. KalashFinial bakes 0.65/0.85. MandalaBackdrop defaults to 0.10 — too low for light. LotusMedallion bakes 0.85 petal (OK). Fix by passing `isDark` to each painter.

- [ ] **Step 1: Fix VineFlourish**

```dart
class VineFlourish extends StatelessWidget {
  const VineFlourish({super.key, this.height = 18, this.maxWidth = 220});

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
```

- [ ] **Step 2: Fix KalashFinial**

In `KalashFinial.build()`, pass `isDark` to painter. In `_KalashPainter`:
```dart
class KalashFinial extends StatelessWidget {
  const KalashFinial({super.key, this.height = 42, this.flip = false});

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

    // ... rest of paint() body unchanged from original ...
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final baseY = h - 2;
    final stepW1 = w * 0.95;
    final stepW2 = w * 0.78;
    final stepW3 = w * 0.62;
    canvas.drawLine(Offset(cx - stepW1 / 2, baseY), Offset(cx + stepW1 / 2, baseY), stroke);
    canvas.drawLine(Offset(cx - stepW2 / 2, baseY - 3), Offset(cx + stepW2 / 2, baseY - 3), stroke);
    canvas.drawLine(Offset(cx - stepW3 / 2, baseY - 6), Offset(cx + stepW3 / 2, baseY - 6), stroke);

    final potTop = baseY - 6;
    final potBulgeY = potTop - h * 0.28;
    final potNeckY = potTop - h * 0.46;
    final potW = w * 0.7;
    final neckW = w * 0.34;
    final potPath = Path()
      ..moveTo(cx - neckW / 2, potNeckY)
      ..quadraticBezierTo(cx - potW / 2 - 2, potBulgeY, cx - potW * 0.45, potTop)
      ..lineTo(cx + potW * 0.45, potTop)
      ..quadraticBezierTo(cx + potW / 2 + 2, potBulgeY, cx + neckW / 2, potNeckY);
    canvas.drawPath(potPath, stroke);
    canvas.drawLine(Offset(cx - neckW / 2 - 1, potNeckY), Offset(cx + neckW / 2 + 1, potNeckY), stroke);

    final coconutY = potNeckY - h * 0.12;
    canvas.drawCircle(Offset(cx, coconutY), w * 0.18, fill);

    final leafBase = Offset(cx, coconutY - w * 0.15);
    final leafTip = Offset(cx + w * 0.12, 1);
    final leafPath = Path()
      ..moveTo(leafBase.dx, leafBase.dy)
      ..quadraticBezierTo(cx - w * 0.05, (leafBase.dy + leafTip.dy) / 2, leafTip.dx, leafTip.dy)
      ..quadraticBezierTo(cx + w * 0.18, (leafBase.dy + leafTip.dy) / 2 + 4, leafBase.dx, leafBase.dy);
    canvas.drawPath(leafPath, stroke);
  }

  @override
  bool shouldRepaint(covariant _KalashPainter old) =>
      old.color != color || old.isDark != isDark;
}
```

- [ ] **Step 3: Fix MandalaBackdrop default opacity**

Change default from 0.10 to isDark-aware selection:
```dart
class MandalaBackdrop extends StatelessWidget {
  const MandalaBackdrop({
    super.key,
    this.size = 320,
    this.opacity,  // null = auto-select by brightness
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
```

- [ ] **Step 4: Run analyzer**

```bash
flutter analyze lib/presentation/shared/widgets/sacred_ornaments.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/shared/widgets/sacred_ornaments.dart
git commit -m "fix: all ornament painters use isDark-aware opacity (light mode visible)"
```

---

### Task 4: GangaWavePainter + GangaWaveBackdrop

**Files:**
- Modify: `lib/presentation/shared/widgets/sacred_ornaments.dart` (append at end)

Onboarding background. Sky gradient + sun disk + ghats silhouette + 3 wave paths.

- [ ] **Step 1: Append GangaWavePainter to sacred_ornaments.dart**

```dart
// ─────────────────────────────────────────────────────────────────────────────
//  GangaWaveBackdrop
// ─────────────────────────────────────────────────────────────────────────────

/// Full-bleed background for the onboarding screen.
/// Paints: sky gradient (violet→amber in dark, cream→warm-saffron in light),
/// sun disk with radial glow at horizon, ghats silhouettes left+right,
/// and three sine-wave paths representing the Ganga.
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

    // ── Sky gradient ────────────────────────────────────────────────
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

    // ── Sun glow (radial gradient) ───────────────────────────────────
    final sunY = h * 0.76;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [
                const Color(0xFFF4A830).withValues(alpha: 0.35),
                const Color(0xFFF4A830).withValues(alpha: 0.10),
                Colors.transparent,
              ]
            : [
                const Color(0xFFE8820C).withValues(alpha: 0.20),
                const Color(0xFFE8820C).withValues(alpha: 0.06),
                Colors.transparent,
              ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, sunY), radius: w * 0.55));
    canvas.drawCircle(Offset(cx, sunY), w * 0.55, glowPaint);

    // Sun disk
    final sunColor = isDark ? const Color(0xFFF4A830) : const Color(0xFFE8820C);
    final sunPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = sunColor.withValues(alpha: isDark ? 0.90 : 0.70);
    canvas.drawCircle(Offset(cx, sunY), 14, sunPaint);

    // Sun inner highlight
    final innerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = (isDark ? const Color(0xFFFFE08A) : const Color(0xFFFFF3D0))
          .withValues(alpha: 0.80);
    canvas.drawCircle(Offset(cx, sunY), 8, innerPaint);

    // ── Horizon line ─────────────────────────────────────────────────
    final horizonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = sunColor.withValues(alpha: 0.35);
    canvas.drawLine(Offset(0, sunY + 14), Offset(w, sunY + 14), horizonPaint);

    // ── Ghats silhouettes ────────────────────────────────────────────
    final ghatsColor = isDark ? const Color(0xFF0F0508) : const Color(0xFFD4C4B0);
    final ghatsPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = ghatsColor.withValues(alpha: isDark ? 0.85 : 0.40);

    // Left ghats
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

    // Right ghats (mirror)
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

    // ── Ganga waves (3 sine paths) ────────────────────────────────────
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
    final reflectPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = sunColor.withValues(alpha: 0.18);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.84), width: w * 0.12, height: h * 0.02),
      reflectPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GangaWavePainter old) => old.isDark != isDark;
}
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/presentation/shared/widgets/sacred_ornaments.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/shared/widgets/sacred_ornaments.dart
git commit -m "feat: add GangaWaveBackdrop painter (onboarding background)"
```

---

### Task 5: Onboarding icon painters (SeedlingPainter, DiyaPainter, ScrollPainter)

**Files:**
- Modify: `lib/presentation/shared/widgets/sacred_ornaments.dart` (append)

Three 32×32 icon painters replacing emojis 🌱 🪔 📜 in onboarding.

- [ ] **Step 1: Append three icon painters**

```dart
// ─────────────────────────────────────────────────────────────────────────────
//  Onboarding Icon Painters — Seedling, Diya, Scroll
// ─────────────────────────────────────────────────────────────────────────────

/// 32×32 seedling: central stem, two teardrop leaves, root forks.
/// Used for "New Seeker / Beginner" level card on onboarding.
class SeedlingIcon extends StatelessWidget {
  const SeedlingIcon({super.key, this.size = 32, this.selected = false});

  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? (isDark ? AppColors.saffronOnDark : AppColors.saffron)
        : AppColors.textSecondary;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _SeedlingPainter(color: color)),
    );
  }
}

class _SeedlingPainter extends CustomPainter {
  const _SeedlingPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    final strokeFaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.55);

    // Stem (center vertical)
    canvas.drawLine(Offset(cx, h * 0.88), Offset(cx, h * 0.42), stroke);

    // Left leaf (teardrop bezier)
    final leftLeaf = Path()
      ..moveTo(cx, h * 0.42)
      ..cubicTo(cx - w * 0.30, h * 0.30, cx - w * 0.38, h * 0.12, cx - w * 0.12, h * 0.10)
      ..cubicTo(cx + w * 0.04, h * 0.10, cx + w * 0.02, h * 0.30, cx, h * 0.42);
    canvas.drawPath(leftLeaf, stroke);

    // Right leaf (mirror, slightly smaller)
    final rightLeaf = Path()
      ..moveTo(cx, h * 0.42)
      ..cubicTo(cx + w * 0.26, h * 0.32, cx + w * 0.32, h * 0.16, cx + w * 0.10, h * 0.14)
      ..cubicTo(cx - w * 0.02, h * 0.14, cx - w * 0.01, h * 0.32, cx, h * 0.42);
    canvas.drawPath(rightLeaf, strokeFaint);

    // Root forks
    canvas.drawLine(Offset(cx, h * 0.88), Offset(cx - w * 0.18, h), strokeFaint);
    canvas.drawLine(Offset(cx, h * 0.88), Offset(cx + w * 0.18, h), strokeFaint);
    canvas.drawLine(Offset(cx, h * 0.92), Offset(cx - w * 0.08, h), strokeFaint);
  }

  @override
  bool shouldRepaint(covariant _SeedlingPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────

/// 32×32 diya lamp: clay bowl, wick, teardrop flame.
/// Used for "Devoted Hindu / Regular" level card on onboarding.
class DiyaIcon extends StatelessWidget {
  const DiyaIcon({super.key, this.size = 32, this.selected = false});

  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? (isDark ? AppColors.saffronOnDark : AppColors.saffron)
        : AppColors.textSecondary;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _DiyaPainter(color: color)),
    );
  }
}

class _DiyaPainter extends CustomPainter {
  const _DiyaPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.038
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    // Bowl (lower half ellipse + flat base)
    final bowl = Path()
      ..moveTo(w * 0.15, h * 0.58)
      ..cubicTo(w * 0.10, h * 0.72, w * 0.20, h * 0.85, cx, h * 0.87)
      ..cubicTo(w * 0.80, h * 0.85, w * 0.90, h * 0.72, w * 0.85, h * 0.58)
      ..lineTo(w * 0.15, h * 0.58);
    canvas.drawPath(bowl, stroke);

    // Spout (right tip)
    final spout = Path()
      ..moveTo(w * 0.85, h * 0.58)
      ..cubicTo(w * 0.92, h * 0.52, w * 0.96, h * 0.48, w * 0.92, h * 0.44)
      ..cubicTo(w * 0.88, h * 0.42, w * 0.84, h * 0.46, w * 0.80, h * 0.50);
    canvas.drawPath(spout, stroke);

    // Wick
    canvas.drawLine(Offset(cx * 0.92, h * 0.58), Offset(cx * 0.92, h * 0.44), stroke);

    // Flame (teardrop)
    final flame = Path()
      ..moveTo(cx * 0.92, h * 0.44)
      ..cubicTo(cx * 0.72, h * 0.36, cx * 0.74, h * 0.18, cx * 0.92, h * 0.12)
      ..cubicTo(cx * 1.00, h * 0.10, cx * 1.00, h * 0.10, cx * 0.96, h * 0.12)
      ..cubicTo(cx * 1.10, h * 0.18, cx * 1.12, h * 0.36, cx * 0.92, h * 0.44);
    canvas.drawPath(flame, stroke);
  }

  @override
  bool shouldRepaint(covariant _DiyaPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────

/// 32×32 palm-leaf scroll: rounded rectangle + text lines + curl edges.
/// Used for "Vidvān / Scholar" level card on onboarding.
class ScrollIcon extends StatelessWidget {
  const ScrollIcon({super.key, this.size = 32, this.selected = false});

  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? (isDark ? AppColors.saffronOnDark : AppColors.saffron)
        : AppColors.textSecondary;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _ScrollPainter(color: color)),
    );
  }
}

class _ScrollPainter extends CustomPainter {
  const _ScrollPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.038
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    final faint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.50);

    // Scroll body (rounded rect)
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.12, w * 0.84, h * 0.76),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(body, stroke);

    // Curl shadow at top (darker strip suggesting rolled edge)
    canvas.drawLine(Offset(w * 0.12, h * 0.20), Offset(w * 0.88, h * 0.20), faint);
    canvas.drawLine(Offset(w * 0.12, h * 0.80), Offset(w * 0.88, h * 0.80), faint);

    // Text lines on scroll
    final lineY = [0.34, 0.46, 0.58, 0.70];
    for (var i = 0; i < lineY.length; i++) {
      final lineW = i == lineY.length - 1 ? w * 0.45 : w * 0.64;
      canvas.drawLine(
        Offset(w * 0.18, h * lineY[i]),
        Offset(w * 0.18 + lineW, h * lineY[i]),
        faint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScrollPainter old) => old.color != color;
}
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/presentation/shared/widgets/sacred_ornaments.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/shared/widgets/sacred_ornaments.dart
git commit -m "feat: add SeedlingIcon, DiyaIcon, ScrollIcon painters (onboarding)"
```

---

### Task 6: PeacockPainter + PeacockBackdrop

**Files:**
- Modify: `lib/presentation/shared/widgets/sacred_ornaments.dart` (append)

The hero illustration for the Search screen empty state. Scales from 200px (hero) down to 18px (search bar feather icon). Ink-drawing style: stroke only, no fills. Saffron on dark, deep brown on light.

- [ ] **Step 1: Append PeacockPainter**

```dart
// ─────────────────────────────────────────────────────────────────────────────
//  PeacockPainter
// ─────────────────────────────────────────────────────────────────────────────

/// Ink-drawing peacock illustration. Size-parameterised: use 200 for hero
/// empty state, 18 for search-bar prefix icon (singleFeather: true).
/// Stroke-only, no fills — saffron on dark, [AppColors.sankritText] on light.
class PeacockIllustration extends StatelessWidget {
  const PeacockIllustration({
    super.key,
    this.size = 200,
    this.singleFeather = false,
    this.tailFolded = false,
  });

  final double size;
  final bool singleFeather;
  final bool tailFolded;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.sanskritText;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _PeacockPainter(
          color: color,
          isDark: isDark,
          singleFeather: singleFeather,
          tailFolded: tailFolded,
        ),
      ),
    );
  }
}

class _PeacockPainter extends CustomPainter {
  const _PeacockPainter({
    required this.color,
    required this.isDark,
    this.singleFeather = false,
    this.tailFolded = false,
  });

  final Color color;
  final bool isDark;
  final bool singleFeather;
  final bool tailFolded;

  // Feather angles (from vertical, negative = left, positive = right).
  // 9 feathers for full display.
  static const _featherAngles = [
    -65.0, -48.0, -32.0, -16.0, 0.0, 16.0, 32.0, 48.0, 65.0,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (singleFeather) {
      _paintSingleFeather(canvas, size);
      return;
    }
    _paintFull(canvas, size);
  }

  void _paintSingleFeather(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..color = color;

    // Single central feather: shaft + eye
    canvas.drawLine(Offset(w / 2, h * 0.95), Offset(w / 2, h * 0.25), stroke);
    _paintFeatherEye(canvas, Offset(w / 2, h * 0.22), w * 0.28, 0, stroke);
  }

  void _paintFull(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Anchor: tail fan radiates from bodyCenterY
    final bodyX = w * 0.50;
    final bodyY = h * 0.68;
    final bodyRx = w * 0.09;
    final bodyRy = h * 0.13;

    final mainStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.008
      ..strokeCap = StrokeCap.round
      ..color = color;

    final faintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.005
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.50);

    // ── Tail feathers ────────────────────────────────────────────────
    final tailOrigin = Offset(bodyX, bodyY - bodyRy * 0.4);
    final angles = tailFolded
        ? _featherAngles.map((a) => a * 0.15).toList()
        : _featherAngles;

    for (var i = 0; i < angles.length; i++) {
      final angleDeg = angles[i];
      final angleRad = (angleDeg - 90) * math.pi / 180;
      // Center feathers longest, outermost shorter
      final lengthFrac = 1.0 - (i - 4).abs() * 0.06;
      final featherLen = h * 0.54 * lengthFrac;

      final tip = Offset(
        tailOrigin.dx + math.cos(angleRad) * featherLen,
        tailOrigin.dy + math.sin(angleRad) * featherLen,
      );

      // Shaft
      final shaft = Path()
        ..moveTo(tailOrigin.dx, tailOrigin.dy)
        ..quadraticBezierTo(
          tailOrigin.dx + (tip.dx - tailOrigin.dx) * 0.3 + math.sin(angleRad) * featherLen * 0.08,
          tailOrigin.dy + (tip.dy - tailOrigin.dy) * 0.3 - math.cos(angleRad) * featherLen * 0.08,
          tip.dx,
          tip.dy,
        );
      canvas.drawPath(shaft, i == 4 ? mainStroke : faintStroke);

      // Eye at tip
      if (!tailFolded || (tailFolded && i == 4)) {
        final eyeR = w * 0.032 * lengthFrac;
        _paintFeatherEye(canvas, tip, eyeR, angleRad, mainStroke);
      }
    }

    // ── Body (ellipse) ────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(center: Offset(bodyX, bodyY), width: bodyRx * 2, height: bodyRy * 2),
      mainStroke,
    );

    // ── Neck (bezier upward) ──────────────────────────────────────────
    final neckBase = Offset(bodyX, bodyY - bodyRy);
    final headCenter = Offset(bodyX - w * 0.02, h * 0.30);
    final neckPath = Path()
      ..moveTo(neckBase.dx, neckBase.dy)
      ..cubicTo(
        bodyX - w * 0.04, h * 0.55,
        bodyX - w * 0.06, h * 0.42,
        headCenter.dx, headCenter.dy,
      );
    canvas.drawPath(neckPath, mainStroke);

    // ── Head ─────────────────────────────────────────────────────────
    final headR = w * 0.055;
    canvas.drawCircle(headCenter, headR, mainStroke);

    // ── Crest (3 lines + dot tips) ────────────────────────────────────
    final crestAngles = [-20.0, 0.0, 20.0];
    for (final ca in crestAngles) {
      final cRad = (ca - 90) * math.pi / 180;
      final crestLen = headR * 1.4;
      final cTip = Offset(
        headCenter.dx + math.cos(cRad) * crestLen,
        headCenter.dy + math.sin(cRad) * crestLen,
      );
      canvas.drawLine(headCenter, cTip, faintStroke);
      canvas.drawCircle(cTip, w * 0.010, mainStroke..style = PaintingStyle.fill);
      mainStroke.style = PaintingStyle.stroke;
    }

    // ── Eye ──────────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(headCenter.dx - headR * 0.3, headCenter.dy - headR * 0.1),
      w * 0.012,
      mainStroke..style = PaintingStyle.fill,
    );
    mainStroke.style = PaintingStyle.stroke;

    // ── Beak ─────────────────────────────────────────────────────────
    final beakPath = Path()
      ..moveTo(headCenter.dx - headR, headCenter.dy + headR * 0.2)
      ..lineTo(headCenter.dx - headR * 1.55, headCenter.dy + headR * 0.55);
    canvas.drawPath(beakPath, faintStroke);

    // ── Feet ─────────────────────────────────────────────────────────
    final footBaseL = Offset(bodyX - bodyRx * 0.5, bodyY + bodyRy);
    final footBaseR = Offset(bodyX + bodyRx * 0.5, bodyY + bodyRy);
    for (final fb in [footBaseL, footBaseR]) {
      // 3 toes per foot
      for (var t = -1; t <= 1; t++) {
        final toe = Path()
          ..moveTo(fb.dx, fb.dy)
          ..lineTo(fb.dx + t * w * 0.045, fb.dy + h * 0.05);
        canvas.drawPath(toe, faintStroke);
      }
    }
  }

  void _paintFeatherEye(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    Paint stroke,
  ) {
    // Outer ellipse (perpendicular to feather direction)
    final eyeW = radius * 1.6;
    final eyeH = radius * 1.0;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle + math.pi / 2);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: eyeW, height: eyeH), stroke);
    // Inner pupil
    final pupilPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = stroke.color.withValues(alpha: 0.50);
    canvas.drawCircle(Offset.zero, radius * 0.32, pupilPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PeacockPainter old) =>
      old.color != color || old.tailFolded != tailFolded || old.singleFeather != singleFeather;
}
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/presentation/shared/widgets/sacred_ornaments.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/shared/widgets/sacred_ornaments.dart
git commit -m "feat: add PeacockIllustration painter (search empty state)"
```

---

### Task 7: Remaining support painters (batch)

**Files:**
- Modify: `lib/presentation/shared/widgets/sacred_ornaments.dart` (append)

Append all remaining painters in one commit. Each follows the same pattern: private `_XxxPainter` + public wrapper.

- [ ] **Step 1: Append ForestDappleBackdrop**

```dart
// ─────────────────────────────────────────────────────────────────────────────
//  ForestDappleBackdrop — overlapping circles, canopy suggestion
// ─────────────────────────────────────────────────────────────────────────────
class ForestDappleBackdrop extends StatelessWidget {
  const ForestDappleBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? const Color(0xFF2E5A38) : const Color(0xFF8A6830);
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(painter: _ForestDapplePainter(color: color)),
      ),
    );
  }
}

class _ForestDapplePainter extends CustomPainter {
  const _ForestDapplePainter({required this.color});
  final Color color;

  static const _circles = [
    (0.08, 0.08, 0.14, 0.30), (0.85, 0.06, 0.16, 0.25),
    (0.50, 0.04, 0.10, 0.20), (0.20, 0.85, 0.18, 0.15),
    (0.80, 0.88, 0.16, 0.15), (0.35, 0.40, 0.22, 0.10),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (fx, fy, fr, alpha) in _circles) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(size.width * fx, size.height * fy),
        size.width * fr,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ForestDapplePainter old) => old.color != color;
}
```

- [ ] **Step 2: Append NalandaArchBackdrop**

```dart
// ─────────────────────────────────────────────────────────────────────────────
//  NalandaArchBackdrop — ruined multi-foil arch, scripture library header
// ─────────────────────────────────────────────────────────────────────────────
class NalandaArchBackdrop extends StatelessWidget {
  const NalandaArchBackdrop({super.key, this.height = 80});
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: _NalandaArchPainter(color: color, isDark: isDark)),
    );
  }
}

class _NalandaArchPainter extends CustomPainter {
  const _NalandaArchPainter({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final alpha = isDark ? 0.22 : 0.28;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = color.withValues(alpha: alpha);

    // 5 arch spans across width
    const spans = 5;
    final spanW = w / spans;
    for (var i = 0; i < spans; i++) {
      final cx = spanW * i + spanW / 2;
      final archPath = Path()
        ..moveTo(cx - spanW * 0.48, h)
        ..cubicTo(cx - spanW * 0.48, h * 0.4, cx - spanW * 0.28, h * 0.05, cx, h * 0.05)
        ..cubicTo(cx + spanW * 0.28, h * 0.05, cx + spanW * 0.48, h * 0.4, cx + spanW * 0.48, h);
      canvas.drawPath(archPath, stroke);
      // Keystone dot
      canvas.drawCircle(Offset(cx, h * 0.05), 2.0, stroke..style = PaintingStyle.fill);
      stroke.style = PaintingStyle.stroke;
    }

    // Horizontal string course
    canvas.drawLine(Offset(0, h * 0.90), Offset(w, h * 0.90), stroke);
    // Base line
    canvas.drawLine(Offset(0, h - 1), Offset(w, h - 1), stroke);
  }

  @override
  bool shouldRepaint(covariant _NalandaArchPainter old) =>
      old.color != color || old.isDark != isDark;
}
```

- [ ] **Step 3: Append remaining painters**

```dart
// ─────────────────────────────────────────────────────────────────────────────
//  PalmLeafBorder — thin leaf-vein ornament for verse list rows
// ─────────────────────────────────────────────────────────────────────────────
class PalmLeafBorder extends StatelessWidget {
  const PalmLeafBorder({super.key, this.height = 6});
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: _PalmLeafBorderPainter(color: color, isDark: isDark)),
    );
  }
}

class _PalmLeafBorderPainter extends CustomPainter {
  const _PalmLeafBorderPainter({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cy = size.height / 2;
    final alpha = isDark ? 0.20 : 0.28;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = color.withValues(alpha: alpha);

    // Central vein
    canvas.drawLine(Offset(0, cy), Offset(w, cy), stroke);

    // Lateral veins at intervals
    const spacing = 16.0;
    for (var x = spacing; x < w; x += spacing) {
      canvas.drawLine(Offset(x, cy), Offset(x + 6, cy - size.height * 0.4), stroke);
      canvas.drawLine(Offset(x, cy), Offset(x + 6, cy + size.height * 0.4), stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _PalmLeafBorderPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
//  PrasadTrayIllustration — offering tray for bookmarks empty state
// ─────────────────────────────────────────────────────────────────────────────
class PrasadTrayIllustration extends StatelessWidget {
  const PrasadTrayIllustration({super.key, this.size = 160});
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _PrasadTrayPainter(color: color)),
    );
  }
}

class _PrasadTrayPainter extends CustomPainter {
  const _PrasadTrayPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.70);
    final faint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.008
      ..color = color.withValues(alpha: 0.35);

    // Tray (ellipse)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + h * 0.10), width: w * 0.80, height: h * 0.22),
      stroke,
    );
    // Water ripples
    for (final r in [0.30, 0.45, 0.60]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + h * 0.10), width: w * r, height: h * r * 0.25),
        faint,
      );
    }

    // 5 lotus flowers arranged on tray
    final positions = [
      Offset(cx, cy - h * 0.08),
      Offset(cx - w * 0.22, cy + h * 0.02),
      Offset(cx + w * 0.22, cy + h * 0.02),
      Offset(cx - w * 0.12, cy + h * 0.14),
      Offset(cx + w * 0.12, cy + h * 0.14),
    ];

    for (final pos in positions) {
      _drawLotus(canvas, pos, w * 0.09, stroke, faint);
    }
  }

  void _drawLotus(Canvas canvas, Offset center, double r, Paint stroke, Paint faint) {
    // 6 petals
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final tipDir = Offset(math.cos(angle), math.sin(angle));
      final tip = center + tipDir * r;
      final n = Offset(-tipDir.dy, tipDir.dx);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..quadraticBezierTo(
          (center + n * (r * 0.55)).dx, (center + n * (r * 0.55)).dy,
          tip.dx, tip.dy,
        )
        ..quadraticBezierTo(
          (center - n * (r * 0.55)).dx, (center - n * (r * 0.55)).dy,
          center.dx, center.dy,
        );
      canvas.drawPath(path, faint);
    }
    // Centre
    canvas.drawCircle(center, r * 0.20, stroke..style = PaintingStyle.fill);
    stroke.style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(covariant _PrasadTrayPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
//  DiyaFlameIcon — 24px drawn diya (festivals, settings sections)
// ─────────────────────────────────────────────────────────────────────────────
class DiyaFlameIcon extends StatelessWidget {
  const DiyaFlameIcon({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return SizedBox.square(dimension: size, child: CustomPaint(painter: _DiyaFlamePainter(color: color)));
  }
}

class _DiyaFlamePainter extends CustomPainter {
  const _DiyaFlamePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    // Bowl
    final bowl = Path()
      ..moveTo(w * 0.12, h * 0.54)
      ..cubicTo(w * 0.08, h * 0.70, w * 0.18, h * 0.84, cx, h * 0.86)
      ..cubicTo(w * 0.82, h * 0.84, w * 0.92, h * 0.70, w * 0.88, h * 0.54)
      ..lineTo(w * 0.12, h * 0.54);
    canvas.drawPath(bowl, stroke);

    // Wick + flame
    canvas.drawLine(Offset(cx, h * 0.54), Offset(cx, h * 0.40), stroke);
    final flame = Path()
      ..moveTo(cx, h * 0.40)
      ..cubicTo(cx - w * 0.10, h * 0.30, cx - w * 0.08, h * 0.12, cx, h * 0.06)
      ..cubicTo(cx + w * 0.08, h * 0.12, cx + w * 0.10, h * 0.30, cx, h * 0.40);
    canvas.drawPath(flame, stroke);
  }

  @override
  bool shouldRepaint(covariant _DiyaFlamePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
//  TempleStaircaseBackdrop — ascending steps, learning path header
// ─────────────────────────────────────────────────────────────────────────────
class TempleStaircaseBackdrop extends StatelessWidget {
  const TempleStaircaseBackdrop({super.key, this.height = 100});
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: _TempleStaircasePainter(color: color, isDark: isDark)),
    );
  }
}

class _TempleStaircasePainter extends CustomPainter {
  const _TempleStaircasePainter({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final alpha = isDark ? 0.20 : 0.26;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = color.withValues(alpha: alpha);

    const steps = 8;
    final stepW = w / steps;
    final stepH = h / steps;

    for (var i = 0; i < steps; i++) {
      final x = i * stepW;
      final y = h - (i + 1) * stepH;
      // Horizontal tread
      canvas.drawLine(Offset(x, y + stepH), Offset(x + stepW, y + stepH), stroke);
      // Vertical riser
      canvas.drawLine(Offset(x + stepW, y + stepH), Offset(x + stepW, y), stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _TempleStaircasePainter old) => old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
//  PeepalTreeBackdrop — faint peepal silhouette, module reader
// ─────────────────────────────────────────────────────────────────────────────
class PeepalTreeBackdrop extends StatelessWidget {
  const PeepalTreeBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(painter: _PeepalTreePainter(color: color, isDark: isDark)),
      ),
    );
  }
}

class _PeepalTreePainter extends CustomPainter {
  const _PeepalTreePainter({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final alpha = isDark ? 0.10 : 0.18;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: alpha);
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: alpha * 0.5);

    // Trunk
    canvas.drawLine(Offset(w * 0.50, h), Offset(w * 0.50, h * 0.55), stroke..strokeWidth = 2.0);

    // Main branches
    final branches = [
      (0.50, 0.55, 0.28, 0.32), (0.50, 0.55, 0.72, 0.32),
      (0.50, 0.55, 0.50, 0.30), (0.28, 0.32, 0.16, 0.14),
      (0.72, 0.32, 0.84, 0.14),
    ];
    stroke.strokeWidth = 0.8;
    for (final (x1, y1, x2, y2) in branches) {
      canvas.drawLine(Offset(w * x1, h * y1), Offset(w * x2, h * y2), stroke);
    }

    // Peepal leaves (heart-shaped: circle + pointed tip)
    final leafPositions = [
      (0.50, 0.20), (0.30, 0.18), (0.70, 0.18), (0.20, 0.26),
      (0.80, 0.26), (0.40, 0.12), (0.60, 0.12), (0.50, 0.08),
    ];
    for (final (fx, fy) in leafPositions) {
      final lc = Offset(w * fx, h * fy);
      final lr = w * 0.042;
      // Leaf body (oval)
      canvas.drawOval(Rect.fromCenter(center: lc, width: lr * 2, height: lr * 2.6), fill);
      // Drip tip
      final tipPath = Path()
        ..moveTo(lc.dx - lr * 0.3, lc.dy + lr * 1.1)
        ..lineTo(lc.dx, lc.dy + lr * 1.8)
        ..lineTo(lc.dx + lr * 0.3, lc.dy + lr * 1.1);
      canvas.drawPath(tipPath, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _PeepalTreePainter old) => old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
//  DhyanaAsanaBackdrop — seated rishi silhouette + incense, verse chat
// ─────────────────────────────────────────────────────────────────────────────
class DhyanaAsanaBackdrop extends StatelessWidget {
  const DhyanaAsanaBackdrop({super.key, this.height = 120});
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: _DhyanaAsanaPainter(color: color, isDark: isDark)),
    );
  }
}

class _DhyanaAsanaPainter extends CustomPainter {
  const _DhyanaAsanaPainter({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final alpha = isDark ? 0.16 : 0.22;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: alpha);

    final cx = w * 0.50;

    // Seated body in padmasana
    // Base (knees/crossed legs)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.78), width: w * 0.30, height: h * 0.16),
      stroke,
    );
    // Torso
    canvas.drawLine(Offset(cx, h * 0.70), Offset(cx, h * 0.36), stroke);
    // Head
    canvas.drawCircle(Offset(cx, h * 0.26), h * 0.11, stroke);
    // Arms resting on knees
    canvas.drawLine(Offset(cx, h * 0.58), Offset(cx - w * 0.10, h * 0.72), stroke);
    canvas.drawLine(Offset(cx, h * 0.58), Offset(cx + w * 0.10, h * 0.72), stroke);

    // Incense smoke (3 wavy lines rising left)
    final smokeX = cx - w * 0.20;
    for (var i = 0; i < 3; i++) {
      final xOff = i * w * 0.03;
      final smokePath = Path()
        ..moveTo(smokeX + xOff, h * 0.90)
        ..cubicTo(
          smokeX + xOff - w * 0.02, h * 0.75,
          smokeX + xOff + w * 0.03, h * 0.60,
          smokeX + xOff, h * 0.45,
        )
        ..cubicTo(
          smokeX + xOff - w * 0.03, h * 0.30,
          smokeX + xOff + w * 0.02, h * 0.15,
          smokeX + xOff, h * 0.02,
        );
      canvas.drawPath(smokePath, stroke..color = color.withValues(alpha: alpha * (1 - i * 0.25)));
    }
    stroke.color = color.withValues(alpha: alpha);
  }

  @override
  bool shouldRepaint(covariant _DhyanaAsanaPainter old) => old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
//  OilLampRowDivider — 3 diya lamps as section divider for settings
// ─────────────────────────────────────────────────────────────────────────────
class OilLampRowDivider extends StatelessWidget {
  const OilLampRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return SizedBox(
      width: double.infinity,
      height: 28,
      child: CustomPaint(painter: _OilLampRowPainter(color: color, isDark: isDark)),
    );
  }
}

class _OilLampRowPainter extends CustomPainter {
  const _OilLampRowPainter({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final alpha = isDark ? 0.35 : 0.45;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: alpha);

    // Left + right hair rules
    canvas.drawLine(Offset(0, size.height / 2), Offset(w * 0.30, size.height / 2), stroke);
    canvas.drawLine(Offset(w * 0.70, size.height / 2), Offset(w, size.height / 2), stroke);

    // 3 tiny diya icons centered
    final lampPositions = [w * 0.38, w * 0.50, w * 0.62];
    for (final lx in lampPositions) {
      _drawMiniDiya(canvas, lx, size.height / 2, size.height * 0.36, stroke);
    }
  }

  void _drawMiniDiya(Canvas canvas, double cx, double cy, double r, Paint stroke) {
    // Bowl
    final bowl = Path()
      ..moveTo(cx - r, cy)
      ..cubicTo(cx - r, cy + r * 0.6, cx - r * 0.4, cy + r, cx, cy + r)
      ..cubicTo(cx + r * 0.4, cy + r, cx + r, cy + r * 0.6, cx + r, cy)
      ..lineTo(cx - r, cy);
    canvas.drawPath(bowl, stroke);
    // Flame
    final flame = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx - r * 0.3, cy - r * 0.7, cx - r * 0.2, cy - r * 1.4, cx, cy - r * 1.5)
      ..cubicTo(cx + r * 0.2, cy - r * 1.4, cx + r * 0.3, cy - r * 0.7, cx, cy);
    canvas.drawPath(flame, stroke);
  }

  @override
  bool shouldRepaint(covariant _OilLampRowPainter old) => old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
//  InscriptionBorderBackdrop — carved stone header for credits page
// ─────────────────────────────────────────────────────────────────────────────
class InscriptionBorderBackdrop extends StatelessWidget {
  const InscriptionBorderBackdrop({super.key, this.height = 56});
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: _InscriptionBorderPainter(color: color, isDark: isDark)),
    );
  }
}

class _InscriptionBorderPainter extends CustomPainter {
  const _InscriptionBorderPainter({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final alpha = isDark ? 0.28 : 0.35;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: alpha);
    final dotFill = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: alpha);

    // Top border
    canvas.drawLine(Offset(0, 2), Offset(w, 2), stroke);
    // Bottom border
    canvas.drawLine(Offset(0, h - 2), Offset(w, h - 2), stroke);

    // Lotus rosettes at intervals
    const spacing = 80.0;
    for (var x = spacing / 2; x < w; x += spacing) {
      final center = Offset(x, h / 2);
      // 4-petal rosette
      for (var i = 0; i < 4; i++) {
        final a = i * math.pi / 2;
        final tip = center + Offset(math.cos(a), math.sin(a)) * 8.0;
        final n = Offset(-math.sin(a), math.cos(a));
        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..quadraticBezierTo(
            (center + n * 5).dx, (center + n * 5).dy, tip.dx, tip.dy,
          )
          ..quadraticBezierTo(
            (center - n * 5).dx, (center - n * 5).dy, center.dx, center.dy,
          );
        canvas.drawPath(path, stroke);
      }
      canvas.drawCircle(center, 1.5, dotFill);
    }

    // Connecting vine line at mid
    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), stroke..color = color.withValues(alpha: alpha * 0.4));
  }

  @override
  bool shouldRepaint(covariant _InscriptionBorderPainter old) => old.isDark != isDark;
}
```

- [ ] **Step 4: Run analyzer**

```bash
flutter analyze lib/presentation/shared/widgets/sacred_ornaments.dart
```
Expected: no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/shared/widgets/sacred_ornaments.dart
git commit -m "feat: add 11 sacred ornament painters (forest, nalanda, palmleaf, prasad, diya, staircase, peepal, dhyana, oillamp, inscription)"
```

---

### Task 8: Widget smoke tests

**Files:**
- Create: `test/presentation/widgets/sacred_ornaments_test.dart`

- [ ] **Step 1: Create test file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/shared/widgets/sacred_ornaments.dart';

Widget _wrap(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(body: child),
    );

void main() {
  group('Ornament painters render without error', () {
    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';

      testWidgets('MandalaBackdrop $mode', (tester) async {
        await tester.pumpWidget(_wrap(const MandalaBackdrop(), dark: dark));
        expect(find.byType(MandalaBackdrop), findsOneWidget);
      });

      testWidgets('ToranaArch $mode', (tester) async {
        await tester.pumpWidget(_wrap(const ToranaArch(), dark: dark));
        expect(find.byType(ToranaArch), findsOneWidget);
      });

      testWidgets('VineFlourish $mode', (tester) async {
        await tester.pumpWidget(_wrap(const VineFlourish(), dark: dark));
        expect(find.byType(VineFlourish), findsOneWidget);
      });

      testWidgets('JaaliLattice $mode', (tester) async {
        await tester.pumpWidget(_wrap(
          const SizedBox(width: 200, height: 200, child: JaaliLattice()),
          dark: dark,
        ));
        expect(find.byType(JaaliLattice), findsOneWidget);
      });

      testWidgets('LotusMedallion $mode', (tester) async {
        await tester.pumpWidget(_wrap(const LotusMedallion(label: '47'), dark: dark));
        expect(find.byType(LotusMedallion), findsOneWidget);
      });

      testWidgets('KalashFinial $mode', (tester) async {
        await tester.pumpWidget(_wrap(const KalashFinial(), dark: dark));
        expect(find.byType(KalashFinial), findsOneWidget);
      });

      testWidgets('GangaWaveBackdrop $mode', (tester) async {
        await tester.pumpWidget(_wrap(const GangaWaveBackdrop(), dark: dark));
        expect(find.byType(GangaWaveBackdrop), findsOneWidget);
      });

      testWidgets('PeacockIllustration $mode', (tester) async {
        await tester.pumpWidget(_wrap(const PeacockIllustration(), dark: dark));
        expect(find.byType(PeacockIllustration), findsOneWidget);
      });

      testWidgets('PeacockIllustration singleFeather $mode', (tester) async {
        await tester.pumpWidget(_wrap(
          const PeacockIllustration(singleFeather: true, size: 18),
          dark: dark,
        ));
        expect(find.byType(PeacockIllustration), findsOneWidget);
      });

      testWidgets('SeedlingIcon $mode', (tester) async {
        await tester.pumpWidget(_wrap(const SeedlingIcon(), dark: dark));
        expect(find.byType(SeedlingIcon), findsOneWidget);
      });

      testWidgets('DiyaIcon $mode', (tester) async {
        await tester.pumpWidget(_wrap(const DiyaIcon(), dark: dark));
        expect(find.byType(DiyaIcon), findsOneWidget);
      });

      testWidgets('ScrollIcon $mode', (tester) async {
        await tester.pumpWidget(_wrap(const ScrollIcon(), dark: dark));
        expect(find.byType(ScrollIcon), findsOneWidget);
      });

      testWidgets('NalandaArchBackdrop $mode', (tester) async {
        await tester.pumpWidget(_wrap(const NalandaArchBackdrop(), dark: dark));
        expect(find.byType(NalandaArchBackdrop), findsOneWidget);
      });

      testWidgets('PrasadTrayIllustration $mode', (tester) async {
        await tester.pumpWidget(_wrap(const PrasadTrayIllustration(), dark: dark));
        expect(find.byType(PrasadTrayIllustration), findsOneWidget);
      });

      testWidgets('DiyaFlameIcon $mode', (tester) async {
        await tester.pumpWidget(_wrap(const DiyaFlameIcon(), dark: dark));
        expect(find.byType(DiyaFlameIcon), findsOneWidget);
      });

      testWidgets('OilLampRowDivider $mode', (tester) async {
        await tester.pumpWidget(_wrap(const OilLampRowDivider(), dark: dark));
        expect(find.byType(OilLampRowDivider), findsOneWidget);
      });

      testWidgets('InscriptionBorderBackdrop $mode', (tester) async {
        await tester.pumpWidget(_wrap(const InscriptionBorderBackdrop(), dark: dark));
        expect(find.byType(InscriptionBorderBackdrop), findsOneWidget);
      });
    }
  });
}
```

- [ ] **Step 2: Run tests**

```bash
flutter test test/presentation/widgets/sacred_ornaments_test.dart
```
Expected: all 34 tests PASS.

- [ ] **Step 3: Commit**

```bash
git add test/presentation/widgets/sacred_ornaments_test.dart
git commit -m "test: add smoke tests for all 17 sacred ornament painters"
```

---

## Self-Review

**Spec coverage check:**
- ✅ Opacity fix for all 6 existing painters (Tasks 1–3)
- ✅ GangaWavePainter / GangaWaveBackdrop (Task 4)
- ✅ SeedlingPainter / DiyaPainter / ScrollPainter (Task 5)
- ✅ PeacockPainter / PeacockBackdrop (Task 6)
- ✅ ForestDapplePainter, NalandaArchPainter, PalmLeafBorderPainter (Task 7)
- ✅ PrasadTrayPainter, DiyaFlameDrawnPainter, TempleStaircasePainter (Task 7)
- ✅ PeepalTreePainter, DhyanaAsanaPainter, OilLampRowPainter, InscriptionBorderPainter (Task 7)
- ✅ Tests (Task 8)
- ❌ TempleStairsPainter / DiamondKnotPainter / OpenScrollPainter (onboarding path step 2) — added below

**Gap fix — Task 7 Step 3 addition:**

```dart
// ─────────────────────────────────────────────────────────────────────────────
//  Onboarding Path Step 2 Icon Painters
// ─────────────────────────────────────────────────────────────────────────────

class TempleStairsIcon extends StatelessWidget {
  const TempleStairsIcon({super.key, this.size = 32, this.selected = false});
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? (isDark ? AppColors.saffronOnDark : AppColors.saffron)
        : AppColors.textSecondary;
    return SizedBox.square(dimension: size, child: CustomPaint(painter: _TempleStairsIconPainter(color: color)));
  }
}

class _TempleStairsIconPainter extends CustomPainter {
  const _TempleStairsIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final stroke = Paint()..style = PaintingStyle.stroke..strokeWidth = w * 0.055..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..color = color;
    // 4 ascending steps
    final steps = 4;
    for (var i = 0; i < steps; i++) {
      final x = w * 0.10 + i * (w * 0.18);
      final y = h * 0.90 - i * (h * 0.18);
      canvas.drawLine(Offset(x, y), Offset(x + w * 0.22, y), stroke);
      canvas.drawLine(Offset(x + w * 0.22, y), Offset(x + w * 0.22, y - h * 0.18), stroke);
    }
    // Temple silhouette top
    final temple = Path()..moveTo(w * 0.82, h * 0.18)..lineTo(w * 0.70, h * 0.04)..lineTo(w * 0.58, h * 0.18);
    canvas.drawPath(temple, stroke);
  }

  @override
  bool shouldRepaint(covariant _TempleStairsIconPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────

class DiamondKnotIcon extends StatelessWidget {
  const DiamondKnotIcon({super.key, this.size = 32, this.selected = false});
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? (isDark ? AppColors.saffronOnDark : AppColors.saffron)
        : AppColors.textSecondary;
    return SizedBox.square(dimension: size, child: CustomPaint(painter: _DiamondKnotPainter(color: color)));
  }
}

class _DiamondKnotPainter extends CustomPainter {
  const _DiamondKnotPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final cx = w / 2; final cy = h / 2;
    final stroke = Paint()..style = PaintingStyle.stroke..strokeWidth = w * 0.045..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..color = color;
    // Diamond
    final diamond = Path()..moveTo(cx, cy - h * 0.38)..lineTo(cx + w * 0.32, cy)..lineTo(cx, cy + h * 0.38)..lineTo(cx - w * 0.32, cy)..close();
    canvas.drawPath(diamond, stroke);
    // Inner cross
    canvas.drawLine(Offset(cx, cy - h * 0.22), Offset(cx, cy + h * 0.22), stroke);
    canvas.drawLine(Offset(cx - w * 0.18, cy), Offset(cx + w * 0.18, cy), stroke);
    // Corner dots
    for (final pos in [Offset(cx, cy - h * 0.38), Offset(cx + w * 0.32, cy), Offset(cx, cy + h * 0.38), Offset(cx - w * 0.32, cy)]) {
      canvas.drawCircle(pos, w * 0.040, stroke..style = PaintingStyle.fill);
      stroke.style = PaintingStyle.stroke;
    }
  }

  @override
  bool shouldRepaint(covariant _DiamondKnotPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────

class OpenScrollIcon extends StatelessWidget {
  const OpenScrollIcon({super.key, this.size = 32, this.selected = false});
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? (isDark ? AppColors.saffronOnDark : AppColors.saffron)
        : AppColors.textSecondary;
    return SizedBox.square(dimension: size, child: CustomPaint(painter: _OpenScrollPainter(color: color)));
  }
}

class _OpenScrollPainter extends CustomPainter {
  const _OpenScrollPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final stroke = Paint()..style = PaintingStyle.stroke..strokeWidth = w * 0.040..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..color = color;
    final faint = Paint()..style = PaintingStyle.stroke..strokeWidth = w * 0.025..strokeCap = StrokeCap.round..color = color.withValues(alpha: 0.45);
    // Left curl
    final leftCurl = Path()..moveTo(w * 0.10, h * 0.16)..cubicTo(w * 0.00, h * 0.16, w * 0.00, h * 0.84, w * 0.10, h * 0.84)..cubicTo(w * 0.18, h * 0.84, w * 0.18, h * 0.72, w * 0.10, h * 0.72)..cubicTo(w * 0.04, h * 0.72, w * 0.04, h * 0.28, w * 0.10, h * 0.28);
    canvas.drawPath(leftCurl, stroke);
    // Right curl (mirror)
    final rightCurl = Path()..moveTo(w * 0.90, h * 0.16)..cubicTo(w * 1.00, h * 0.16, w * 1.00, h * 0.84, w * 0.90, h * 0.84)..cubicTo(w * 0.82, h * 0.84, w * 0.82, h * 0.72, w * 0.90, h * 0.72)..cubicTo(w * 0.96, h * 0.72, w * 0.96, h * 0.28, w * 0.90, h * 0.28);
    canvas.drawPath(rightCurl, stroke);
    // Text lines in center
    for (final y in [0.34, 0.48, 0.62]) {
      canvas.drawLine(Offset(w * 0.22, h * y), Offset(w * 0.78, h * y), faint);
    }
  }

  @override
  bool shouldRepaint(covariant _OpenScrollPainter old) => old.color != color;
}
```

**No placeholders found.** All steps have complete code.

**Type consistency:** All public widget names match what Plan B (screen implementations) will reference.
