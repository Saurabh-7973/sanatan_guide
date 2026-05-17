import 'package:flutter/material.dart';

/// The three Home/Library trailing-icon glyphs.
enum TopBarGlyph { search, bookmark, overflow }

/// Stroke glyphs for the Home/Library topbar, matching the screen-13 mockup
/// SVGs exactly (20-unit viewBox, stroke-width 1.6). Same CustomPainter
/// technique as the bottom-nav `_NavIconPainter`.
class TopBarIcon extends StatelessWidget {
  const TopBarIcon({
    super.key,
    required this.glyph,
    required this.color,
    this.size = 20,
  });

  final TopBarGlyph glyph;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _TopBarIconPainter(glyph, color)),
      );
}

class _TopBarIconPainter extends CustomPainter {
  const _TopBarIconPainter(this.glyph, this.color);

  final TopBarGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 20.0; // mockup viewBox is 20×20
    Offset p(double x, double y) => Offset(x * u, y * u);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * u
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (glyph) {
      case TopBarGlyph.search:
        // circle cx=8.5 cy=8.5 r=5.5 ; path M13 13 l4.5 4.5
        canvas.drawCircle(p(8.5, 8.5), 5.5 * u, stroke);
        canvas.drawLine(p(13, 13), p(17.5, 17.5), stroke);
      case TopBarGlyph.bookmark:
        // path M5 3 h10 v15 l-5 -3 l-5 3 V3 z
        final path = Path()
          ..moveTo(5 * u, 3 * u)
          ..lineTo(15 * u, 3 * u)
          ..lineTo(15 * u, 18 * u)
          ..lineTo(10 * u, 15 * u)
          ..lineTo(5 * u, 18 * u)
          ..close();
        canvas.drawPath(path, stroke);
      case TopBarGlyph.overflow:
        final fill = Paint()..color = color;
        for (final cx in const [4.0, 10.0, 16.0]) {
          canvas.drawCircle(p(cx, 10), 1.7 * u, fill);
        }
    }
  }

  @override
  bool shouldRepaint(_TopBarIconPainter old) =>
      old.glyph != glyph || old.color != color;
}
