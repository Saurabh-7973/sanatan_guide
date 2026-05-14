import 'package:flutter/material.dart';

/// Custom glyphs that match the screen-02 verse-detail mockup SVGs.
///
/// Each painter draws against a fixed logical viewBox so the shape stays
/// identical to the HTML and only the size + color change at the call site.

class _GlyphPaint extends StatelessWidget {
  const _GlyphPaint({
    required this.size,
    required this.viewBox,
    required this.painter,
  });

  final double size;
  final Size viewBox;
  final CustomPainter Function(double scale) painter;

  @override
  Widget build(BuildContext context) {
    final scale = size / viewBox.width;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(size: Size(size, size), painter: painter(scale)),
    );
  }
}

// ── Topbar: share (3 circles + 2 connecting lines) ───────────────────────
class ShareNetworkGlyph extends StatelessWidget {
  const ShareNetworkGlyph({super.key, required this.color, this.size = 18});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => _GlyphPaint(
        size: size,
        viewBox: const Size(18, 18),
        painter: (s) => _ShareNetworkPainter(color, s),
      );
}

class _ShareNetworkPainter extends CustomPainter {
  _ShareNetworkPainter(this.color, this.scale);
  final Color color;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(4 * scale, 9 * scale), 2 * scale, stroke);
    canvas.drawCircle(Offset(14 * scale, 4 * scale), 2 * scale, stroke);
    canvas.drawCircle(Offset(14 * scale, 14 * scale), 2 * scale, stroke);
    canvas.drawLine(
      Offset(5.7 * scale, 8 * scale),
      Offset(12.3 * scale, 5 * scale),
      stroke,
    );
    canvas.drawLine(
      Offset(5.7 * scale, 10 * scale),
      Offset(12.3 * scale, 13 * scale),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_ShareNetworkPainter old) =>
      old.color != color || old.scale != scale;
}

// ── Topbar: ribbon bookmark ──────────────────────────────────────────────
class RibbonBookmarkGlyph extends StatelessWidget {
  const RibbonBookmarkGlyph({
    super.key,
    required this.color,
    required this.filled,
    this.size = 18,
  });
  final Color color;
  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) => _GlyphPaint(
        size: size,
        viewBox: const Size(18, 18),
        painter: (s) => _RibbonBookmarkPainter(color, filled, s),
      );
}

class _RibbonBookmarkPainter extends CustomPainter {
  _RibbonBookmarkPainter(this.color, this.filled, this.scale);
  final Color color;
  final bool filled;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    // Path "M4 2h10v15l-5-3.5L4 17V2z"
    final path = Path()
      ..moveTo(4 * scale, 2 * scale)
      ..relativeLineTo(10 * scale, 0)
      ..relativeLineTo(0, 15 * scale)
      ..lineTo(9 * scale, 13.5 * scale)
      ..lineTo(4 * scale, 17 * scale)
      ..lineTo(4 * scale, 2 * scale)
      ..close();
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;
    if (filled) {
      paint.style = PaintingStyle.fill;
    } else {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * scale
        ..strokeJoin = StrokeJoin.round;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RibbonBookmarkPainter old) =>
      old.color != color || old.filled != filled || old.scale != scale;
}

// ── Util-bar: Translation = eye (almond + pupil) ─────────────────────────
class TranslationEyeGlyph extends StatelessWidget {
  const TranslationEyeGlyph({super.key, required this.color, this.size = 14});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => _GlyphPaint(
        size: size,
        viewBox: const Size(14, 14),
        painter: (s) => _TranslationEyePainter(color, s),
      );
}

class _TranslationEyePainter extends CustomPainter {
  _TranslationEyePainter(this.color, this.scale);
  final Color color;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    // Almond "M2 7c1-2 3-4 5-4s4 2 5 4c-1 2-3 4-5 4S3 9 2 7z"
    final path = Path()
      ..moveTo(2 * scale, 7 * scale)
      ..cubicTo(3 * scale, 5 * scale, 5 * scale, 3 * scale, 7 * scale, 3 * scale)
      ..cubicTo(
          9 * scale, 3 * scale, 11 * scale, 5 * scale, 12 * scale, 7 * scale)
      ..cubicTo(
          11 * scale, 9 * scale, 9 * scale, 11 * scale, 7 * scale, 11 * scale)
      ..cubicTo(5 * scale, 11 * scale, 3 * scale, 9 * scale, 2 * scale, 7 * scale)
      ..close();
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * scale
      ..isAntiAlias = true;
    canvas.drawPath(path, stroke);
    final fill = Paint()..color = color;
    canvas.drawCircle(Offset(7 * scale, 7 * scale), 1.5 * scale, fill);
  }

  @override
  bool shouldRepaint(_TranslationEyePainter old) =>
      old.color != color || old.scale != scale;
}

// ── Util-bar: Listen = clock face ────────────────────────────────────────
class ListenClockGlyph extends StatelessWidget {
  const ListenClockGlyph({super.key, required this.color, this.size = 14});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => _GlyphPaint(
        size: size,
        viewBox: const Size(14, 14),
        painter: (s) => _ListenClockPainter(color, s),
      );
}

class _ListenClockPainter extends CustomPainter {
  _ListenClockPainter(this.color, this.scale);
  final Color color;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * scale
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(7 * scale, 7 * scale), 6 * scale, stroke);
    canvas.drawLine(
      Offset(7 * scale, 4 * scale),
      Offset(7 * scale, 7 * scale),
      stroke,
    );
    canvas.drawLine(
      Offset(7 * scale, 7 * scale),
      Offset(9 * scale, 8.5 * scale),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_ListenClockPainter old) =>
      old.color != color || old.scale != scale;
}

// ── Util-bar: Notes = downward caret ─────────────────────────────────────
class NotesCaretGlyph extends StatelessWidget {
  const NotesCaretGlyph({super.key, required this.color, this.size = 14});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => _GlyphPaint(
        size: size,
        viewBox: const Size(14, 14),
        painter: (s) => _NotesCaretPainter(color, s),
      );
}

class _NotesCaretPainter extends CustomPainter {
  _NotesCaretPainter(this.color, this.scale);
  final Color color;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    final path = Path()
      ..moveTo(3 * scale, 5 * scale)
      ..lineTo(7 * scale, 9 * scale)
      ..lineTo(11 * scale, 5 * scale);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_NotesCaretPainter old) =>
      old.color != color || old.scale != scale;
}
