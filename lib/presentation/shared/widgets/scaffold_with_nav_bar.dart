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
                      painter: _SunRaysIconPainter(color: iconColor(0)),
                    ),
                    selectedIcon: const _NavIcon(
                      painter: _SunRaysIconPainter(color: AppColors.saffron),
                    ),
                    label: 'Today',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.location_on_outlined,
                      size: 22,
                      color: iconColor(1),
                    ),
                    selectedIcon: const Icon(
                      Icons.location_on,
                      size: 22,
                      color: AppColors.saffron,
                    ),
                    label: 'Practice',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.menu_book_outlined,
                      size: 22,
                      color: iconColor(2),
                    ),
                    selectedIcon: const Icon(
                      Icons.menu_book_rounded,
                      size: 22,
                      color: AppColors.saffron,
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

// ── Today — sun with downward rays ───────────────────────────────────────
// Top half-disc (filled) + 5 short rays radiating down/sideways

class _SunRaysIconPainter extends CustomPainter {
  const _SunRaysIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = color;

    final cx = size.width / 2;
    final baseY = size.height * 0.55;
    const r = 4.5;

    // Filled half-disc (sun above horizon)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, baseY), radius: r),
      math.pi,
      math.pi,
      true,
      fill,
    );

    // 5 downward rays — fan at 30°, 60°, 90°, 120°, 150° (below horizon)
    const rayGap = 2.2;
    const rayLen = 3.4;
    for (final deg in [30.0, 60.0, 90.0, 120.0, 150.0]) {
      final ang = deg * math.pi / 180;
      final start = Offset(
        cx + (r + rayGap) * math.cos(ang),
        baseY + (r + rayGap) * math.sin(ang),
      );
      final end = Offset(
        cx + (r + rayGap + rayLen) * math.cos(ang),
        baseY + (r + rayGap + rayLen) * math.sin(ang),
      );
      canvas.drawLine(start, end, stroke);
    }
  }

  @override
  bool shouldRepaint(_SunRaysIconPainter old) => old.color != color;
}

