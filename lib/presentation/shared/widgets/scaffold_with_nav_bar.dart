import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/router/app_routes.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

/// Bottom-nav scaffold matching screen-01: a rounded surface bar with three
/// tab *cells* — the selected cell (icon + label together) sits in a rounded
/// saffron-glow pill, not just the icon.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.child});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/learn')) return 1;
    if (location.startsWith('/browse') ||
        location.startsWith(AppRoutes.bookmarks)) {
      return 2;
    }
    return 0;
  }

  void _go(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/learn');
      case 2:
        context.go(AppRoutes.browse);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final glow = isDark ? DColors.saffronGlow : LColors.saffronGlow;
    const inactive = AppColors.warmGrey50;

    Widget tab(int i, _NavGlyph glyph, String label) {
      final active = selectedIndex == i;
      final fg = active ? saffron : inactive;
      return Expanded(
        child: InkWell(
          onTap: () => _go(context, i),
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
            decoration: BoxDecoration(
              color: active ? glow : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CustomPaint(
                    painter: _NavIconPainter(glyph: glyph, color: fg),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.44,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (selectedIndex != 0) context.go('/home');
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  tab(0, _NavGlyph.sun, 'Today'),
                  const SizedBox(width: 4),
                  tab(1, _NavGlyph.flame, 'Practice'),
                  const SizedBox(width: 4),
                  tab(2, _NavGlyph.books, 'Texts'),
                ],
              ),
            ),
          ),
        ),
      ),
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
