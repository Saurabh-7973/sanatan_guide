import 'package:flutter/material.dart';

import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

/// SVG-spec icons used across reader screens (chapter list, verse list, etc).
/// Stroke widths and viewbox dimensions match the New Design mockups.

class MockupBackChevron extends StatelessWidget {
  const MockupBackChevron({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? DColors.text1
        : LColors.text1;
    return Semantics(
      label: 'Back',
      button: true,
      child: SizedBox(
        width: 20,
        height: 20,
        child: ExcludeSemantics(
          child: CustomPaint(painter: _BackChevronPainter(color: color)),
        ),
      ),
    );
  }
}

class _BackChevronPainter extends CustomPainter {
  const _BackChevronPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(12, 4)
      ..lineTo(6, 10)
      ..lineTo(12, 16);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_BackChevronPainter old) => old.color != color;
}

class MockupRowChevron extends StatelessWidget {
  const MockupRowChevron({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Decorative — the surrounding row's text is the semantic anchor for
    // TalkBack. Don't double-announce "Forward" on every list row.
    return ExcludeSemantics(
      child: SizedBox(
        width: 8,
        height: 14,
        child: CustomPaint(painter: _RowChevronPainter(color: color)),
      ),
    );
  }
}

class _RowChevronPainter extends CustomPainter {
  const _RowChevronPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(1, 1)
      ..lineTo(7, 7)
      ..lineTo(1, 13);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_RowChevronPainter old) => old.color != color;
}

class MockupResumeArrow extends StatelessWidget {
  const MockupResumeArrow({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: CustomPaint(painter: _ResumeArrowPainter(color: color)),
    );
  }
}

class _ResumeArrowPainter extends CustomPainter {
  const _ResumeArrowPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawLine(const Offset(2, 7), const Offset(12, 7), p);
    final head = Path()
      ..moveTo(8, 3)
      ..lineTo(12, 7)
      ..lineTo(8, 11);
    canvas.drawPath(head, p);
  }

  @override
  bool shouldRepaint(_ResumeArrowPainter old) => old.color != color;
}
