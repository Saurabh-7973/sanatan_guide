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
    if (location.startsWith('/learn')) {
      return 1;
    }
    if (location.startsWith('/browse') ||
        location.startsWith(AppRoutes.bookmarks)) {
      return 2;
    }
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        {
          context.go('/home');
        }
      case 1:
        {
          context.go('/learn');
        }
      case 2:
        {
          context.go(AppRoutes.browse);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const inactive = AppColors.warmGrey50;

    Widget icon(int index, _NavGlyph glyph) => _NavIcon(
          painter: _NavIconPainter(
            glyph: glyph,
            color: selectedIndex == index ? AppColors.saffron : inactive,
          ),
        );

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
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.04 * 11,
                    color: selected ? AppColors.saffron : inactive,
                  );
                }),
                destinations: [
                  NavigationDestination(
                    icon: icon(0, _NavGlyph.sun),
                    label: 'Today',
                  ),
                  NavigationDestination(
                    icon: icon(1, _NavGlyph.flame),
                    label: 'Practice',
                  ),
                  NavigationDestination(
                    icon: icon(2, _NavGlyph.books),
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

enum _NavGlyph { sun, flame, books }

/// Draws the three bottom-nav glyphs to match the screen-01 mockup SVGs
/// (a 22-unit viewBox): a rayed sun, a dhyāna flame outline, two book spines.
class _NavIconPainter extends CustomPainter {
  const _NavIconPainter({required this.glyph, required this.color});

  final _NavGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 22.0; // mockup viewBox is 22×22
    Offset p(double x, double y) => Offset(x * u, y * u);

    Paint stroke(double w) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * u
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (glyph) {
      case _NavGlyph.sun:
        // circle r=3.5 at (11,11) + 8 short rays
        canvas.drawCircle(p(11, 11), 3.5 * u, stroke(1.6));
        const rays = [
          [11.0, 4.0, 11.0, 5.5], // N
          [11.0, 16.5, 11.0, 18.0], // S
          [4.0, 11.0, 5.5, 11.0], // W
          [16.5, 11.0, 18.0, 11.0], // E
          [6.05, 6.05, 7.11, 7.11], // NW
          [14.9, 14.9, 15.95, 15.95], // SE
          [6.05, 15.95, 7.11, 14.9], // SW
          [14.9, 7.1, 15.95, 6.05], // NE
        ];
        for (final r in rays) {
          canvas.drawLine(p(r[0], r[1]), p(r[2], r[3]), stroke(1.6));
        }
      case _NavGlyph.flame:
        // M11 18 c0 -4 3 -6 3 -9 a3 3 0 0 0 -6 0 c0 3 3 5 3 9 z
        final path = Path()
          ..moveTo(11 * u, 18 * u)
          ..cubicTo(11 * u, 14 * u, 14 * u, 12 * u, 14 * u, 9 * u)
          ..arcToPoint(p(8, 9),
              radius: Radius.circular(3 * u), clockwise: false)
          ..cubicTo(8 * u, 12 * u, 11 * u, 14 * u, 11 * u, 18 * u)
          ..close();
        canvas.drawPath(path, stroke(1.6));
      case _NavGlyph.books:
        final r = Radius.circular(0.5 * u);
        canvas.drawRRect(
            RRect.fromLTRBR(3 * u, 4 * u, 10.5 * u, 18 * u, r), stroke(1.6));
        canvas.drawRRect(
            RRect.fromLTRBR(11.5 * u, 4 * u, 19 * u, 18 * u, r), stroke(1.6));
        for (final l in const [
          [5.0, 8.0, 8.5, 8.0],
          [5.0, 11.0, 8.5, 11.0],
          [13.5, 8.0, 17.0, 8.0],
          [13.5, 11.0, 17.0, 11.0],
        ]) {
          canvas.drawLine(p(l[0], l[1]), p(l[2], l[3]), stroke(1.4));
        }
    }
  }

  @override
  bool shouldRepaint(_NavIconPainter old) =>
      old.color != color || old.glyph != glyph;
}
