import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/router/app_routes.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.child});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/learn')) { return 1; }
    if (location.startsWith('/browse') ||
        location.startsWith(AppRoutes.bookmarks)) { return 2; }
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0: { context.go('/home'); }
      case 1: { context.go('/learn'); }
      case 2: { context.go(AppRoutes.browse); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color iconColor(int index) =>
        selectedIndex == index ? AppColors.saffron : AppColors.warmGrey50;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // Non-home tab → go home; home tab → allow exit via double-back (default)
        if (selectedIndex != 0) {
          context.go('/home');
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSheet),
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (i) =>
                    _onDestinationSelected(context, i),
                backgroundColor:
                    isDark ? AppColors.surfaceDark : AppColors.surface,
                indicatorColor: AppColors.saffron.withValues(alpha: 0.12),
                surfaceTintColor: Colors.transparent,
                elevation: isDark ? 0 : 4,
                shadowColor: isDark
                    ? Colors.transparent
                    : Colors.black.withValues(alpha: 0.08),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: _NavIcon(
                      painter: _SunriseIconPainter(color: iconColor(0)),
                    ),
                    selectedIcon: const _NavIcon(
                      painter: _SunriseIconPainter(color: AppColors.saffron),
                    ),
                    label: 'Today',
                  ),
                  NavigationDestination(
                    icon: _NavIcon(
                      painter: _LotusIconPainter(color: iconColor(1)),
                    ),
                    selectedIcon: const _NavIcon(
                      painter: _LotusIconPainter(color: AppColors.saffron),
                    ),
                    label: 'Practice',
                  ),
                  NavigationDestination(
                    icon: _NavIcon(
                      painter: _ScrollIconPainter(color: iconColor(2)),
                    ),
                    selectedIcon: const _NavIcon(
                      painter: _ScrollIconPainter(color: AppColors.saffron),
                    ),
                    label: 'Texts',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav icon wrapper ──────────────────────────────────────────────────────

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.painter});
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24, 24),
      painter: painter,
    );
  }
}

// ── Today — sunrise arc ───────────────────────────────────────────────────
// Horizon line + semicircle arc above it + 3 short rays

class _SunriseIconPainter extends CustomPainter {
  const _SunriseIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final baseY = size.height * 0.62;

    // Horizon line
    canvas.drawLine(Offset(cx - 9, baseY), Offset(cx + 9, baseY), p);

    // Sunrise semicircle
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, baseY), radius: 5.5),
      math.pi,
      math.pi,
      false,
      p,
    );

    // Three rays: left / top / right
    const rayLen = 2.8;
    const rayGap = 1.6;
    const r = 5.5;
    for (final angle in [math.pi * 0.75, math.pi * 0.5, math.pi * 0.25]) {
      final start = Offset(
        cx + (r + rayGap) * math.cos(angle),
        baseY + (r + rayGap) * math.sin(angle),
      );
      final end = Offset(
        cx + (r + rayGap + rayLen) * math.cos(angle),
        baseY + (r + rayGap + rayLen) * math.sin(angle),
      );
      canvas.drawLine(start, end, p);
    }
  }

  @override
  bool shouldRepaint(_SunriseIconPainter old) => old.color != color;
}

// ── Practice — lotus silhouette ───────────────────────────────────────────
// Three upward petal arcs emanating from a common base

class _LotusIconPainter extends CustomPainter {
  const _LotusIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height * 0.56;

    // Centre petal — tall arc straight up
    final centerPath = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx - 4, cy - 9, cx + 4, cy - 9, cx, cy);
    canvas.drawPath(centerPath, p);

    // Left petal — arc opening left-up
    final leftPath = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx - 8, cy - 7, cx - 9, cy - 1, cx, cy);
    canvas.drawPath(leftPath, p);

    // Right petal — mirror of left
    final rightPath = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx + 8, cy - 7, cx + 9, cy - 1, cx, cy);
    canvas.drawPath(rightPath, p);

    // Stem base line
    canvas.drawLine(
      Offset(cx - 8, cy + 1),
      Offset(cx + 8, cy + 1),
      p,
    );
  }

  @override
  bool shouldRepaint(_LotusIconPainter old) => old.color != color;
}

// ── Texts — open scroll ───────────────────────────────────────────────────
// Rectangle with vertical spine + three text-lines on left half

class _ScrollIconPainter extends CustomPainter {
  const _ScrollIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final top = size.height * 0.2;
    final bottom = size.height * 0.82;
    final left = cx - 8.5;
    final right = cx + 8.5;

    // Outer rectangle
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTRB(left, top, right, bottom),
      const Radius.circular(2),
    );
    canvas.drawRRect(rrect, p);

    // Vertical spine
    canvas.drawLine(Offset(cx, top), Offset(cx, bottom), p);

    // Three text lines on right half
    final lineColor = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final midH = (bottom - top) / 2 + top;
    for (final y in [midH - 4.0, midH, midH + 4.0]) {
      canvas.drawLine(Offset(cx + 2.5, y), Offset(right - 2.5, y), lineColor);
    }
  }

  @override
  bool shouldRepaint(_ScrollIconPainter old) => old.color != color;
}
