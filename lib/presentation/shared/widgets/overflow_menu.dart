import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

/// One overflow item.
class _Item {
  const _Item(this.label, this.route, this.draw);
  final String label;
  final String route;
  final void Function(Canvas, Size, Color) draw;
}

/// Shows the shared 5-item overflow menu (spec 13 A.3 + roadmap §3.6).
/// 55% black scrim, 220 px popover anchored top-right, 180 ms scale+fade.
Future<void> showOverflowMenu(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      barrierDismissible: true,
      barrierLabel: 'Dismiss menu',
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) => const _OverflowMenu(),
      transitionsBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            alignment: Alignment.topRight,
            scale: Tween(begin: 0.98, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

class _OverflowMenu extends StatelessWidget {
  const _OverflowMenu();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final bg = isDark ? DColors.surface2 : Colors.white;
    final border = isDark ? DColors.divider : LColors.divider;
    final sep = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final text1 = isDark ? DColors.text1 : LColors.text1;

    // Exactly three items, per screen-13 mockup. (Festivals reached from the
    // Home "Upcoming Parva" card; general AI chat from Search.)
    const items = <_Item>[
      _Item('Settings', '/settings', _drawGear),
      _Item('Send feedback', '/feedback', _drawPlane),
      _Item('About this app', '/credits', _drawInfo),
    ];

    return Stack(
      children: [
        Positioned(
          right: 16,
          top: 80,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 220,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: border),
                boxShadow:
                    isDark ? Glows.overflowMenuDark : Glows.overflowMenuLight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < items.length; i++)
                    _Row(
                      item: items[i],
                      saffron: saffron,
                      text1: text1,
                      border: i == items.length - 1 ? null : sep,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.item,
    required this.saffron,
    required this.text1,
    required this.border,
  });
  final _Item item;
  final Color saffron;
  final Color text1;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Capture the router BEFORE popping — this context lives inside the
        // menu route, which is gone after pop.
        final router = GoRouter.of(context);
        Navigator.of(context, rootNavigator: true).pop();
        router.push(item.route);
      },
      child: Container(
        decoration: BoxDecoration(
          border: border == null
              ? null
              : Border(bottom: BorderSide(color: border!)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CustomPaint(
                painter: _GlyphPainter(
                  item.draw,
                  saffron.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.rowLabel(color: text1).copyWith(
                  fontFamily: Fonts.sans,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.draw, this.color);
  final void Function(Canvas, Size, Color) draw;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) => draw(canvas, size, color);
  @override
  bool shouldRepaint(_GlyphPainter old) => old.color != color;
}

// 16-unit stroke glyphs. Gear / plane / info match the screen-13 mockup
// overflow-menu frame exactly (stroke-width 1.4). Calendar + Om have no
// mockup reference (mockup ships the older 3-item menu) — kept simple.
Paint _s(Color c, double u) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.4 * u
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

void _drawGear(Canvas c, Size s, Color col) {
  final u = s.width / 16;
  Offset p(double x, double y) => Offset(x * u, y * u);
  c.drawCircle(p(8, 8), 2 * u, _s(col, u));
  // Eight rays: M8 1.5v1.5 M8 13v1.5 M1.5 8h1.5 M13 8h1.5
  //             M3.2 3.2l1 1 M11.8 11.8l1 1 M3.2 12.8l1-1 M11.8 4.2l1-1
  c.drawLine(p(8, 1.5), p(8, 3), _s(col, u));
  c.drawLine(p(8, 13), p(8, 14.5), _s(col, u));
  c.drawLine(p(1.5, 8), p(3, 8), _s(col, u));
  c.drawLine(p(13, 8), p(14.5, 8), _s(col, u));
  c.drawLine(p(3.2, 3.2), p(4.2, 4.2), _s(col, u));
  c.drawLine(p(11.8, 11.8), p(12.8, 12.8), _s(col, u));
  c.drawLine(p(3.2, 12.8), p(4.2, 11.8), _s(col, u));
  c.drawLine(p(11.8, 4.2), p(12.8, 3.2), _s(col, u));
}

void _drawPlane(Canvas c, Size s, Color col) {
  final u = s.width / 16;
  Offset p(double x, double y) => Offset(x * u, y * u);
  // path M2 3.5 h10.5 L11 6 12.5 8.5 H2 V3.5 z  +  M2 8.5 V14
  final path = Path()
    ..moveTo(2 * u, 3.5 * u)
    ..lineTo(12.5 * u, 3.5 * u)
    ..lineTo(11 * u, 6 * u)
    ..lineTo(12.5 * u, 8.5 * u)
    ..lineTo(2 * u, 8.5 * u)
    ..close();
  c.drawPath(path, _s(col, u));
  c.drawLine(p(2, 8.5), p(2, 14), _s(col, u));
}

void _drawInfo(Canvas c, Size s, Color col) {
  final u = s.width / 16;
  Offset p(double x, double y) => Offset(x * u, y * u);
  c.drawCircle(p(8, 8), 6.5 * u, _s(col, u));
  c.drawLine(p(8, 5), p(8, 8.5), _s(col, u));
  c.drawLine(p(8, 10.5), p(8, 11), _s(col, u));
}
