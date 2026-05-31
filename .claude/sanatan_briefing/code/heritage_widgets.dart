// lib/core/widgets/heritage_widgets.dart
//
// The six shared visual primitives that constitute Sanatan Guide's
// design vocabulary. Implement these here ONCE; use them everywhere.
//
// 1. BindingLine        — palm-leaf top/bottom marker with rotated diamond
// 2. LeafThread         — 3px saffron strip on left edge of card/row
// 3. DandaCoord         — Sanskrit verse coordinates ‖१·१‖
//                         (also: DandaCoord.toDevanagari static helper)
// 4. AIThinkingDots     — three pulsing saffron dots
// 5. SanskritText       — Tiro Devanagari Sanskrit text with proper fallback
// 6. (iron-red ink is a color usage rule, not a widget)

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/design_typography.dart';

// ============================================================
// 1. BINDING LINE — palm-leaf top/bottom marker
// ============================================================
class BindingLine extends StatelessWidget {
  final bool isDark;
  final double sideGap;  // padding on left/right of the diamond

  const BindingLine({
    super.key,
    required this.isDark,
    this.sideGap = 16,
  });

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffronDeep : LColors.saffronDeep;
    final hole = isDark ? DColors.saffron : LColors.saffronDeep;

    return SizedBox(
      height: 12,
      child: Row(
        children: [
          SizedBox(width: sideGap),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    saffron.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Transform.rotate(
            angle: 0.785398, // 45deg
            child: Container(
              width: 5,
              height: 5,
              color: hole,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    saffron.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: sideGap),
        ],
      ),
    );
  }
}

// ============================================================
// 2. LEAF THREAD — 3px saffron strip on left edge
// ============================================================
class LeafThread extends StatelessWidget {
  final bool isDark;
  final double height;
  final double topInset;
  final double bottomInset;

  const LeafThread({
    super.key,
    required this.isDark,
    this.height = double.infinity,
    this.topInset = 8,
    this.bottomInset = 8,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark ? DColors.saffron : LColors.saffron;
    return Padding(
      padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
      child: Container(
        width: 3,
        height: height,
        decoration: BoxDecoration(
          color: color,
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

// Wrapper that places a LeafThread on the left of any child
class LeafThreadRow extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double gap;
  final EdgeInsets padding;

  const LeafThreadRow({
    super.key,
    required this.child,
    required this.isDark,
    this.gap = 14,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LeafThread(isDark: isDark),
            SizedBox(width: gap),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 3. DANDA COORD — Sanskrit verse coordinates
// ============================================================
class DandaCoord extends StatelessWidget {
  final String coord;            // e.g. "1·1" or "१·१"
  final bool isDark;
  final double? fontSize;
  final bool useDevanagari;
  final Color? colorOverride;

  const DandaCoord({
    super.key,
    required this.coord,
    required this.isDark,
    this.fontSize,
    this.useDevanagari = true,
    this.colorOverride,
  });

  /// Convert an Arabic-numeral string ("1.1") into Devanāgarī ("१·१").
  /// Static helper — use anywhere you need int→Devanāgarī conversion.
  static String toDevanagari(String input) {
    const map = {
      '0': '०', '1': '१', '2': '२', '3': '३', '4': '४',
      '5': '५', '6': '६', '7': '७', '8': '८', '9': '९',
      '.': '·',
    };
    final buf = StringBuffer();
    for (final ch in input.split('')) {
      buf.write(map[ch] ?? ch);
    }
    return buf.toString();
  }

  static String intToDevanagari(int n) => toDevanagari(n.toString());

  @override
  Widget build(BuildContext context) {
    final color = colorOverride ?? (isDark ? DColors.saffron : LColors.saffron);
    final displayCoord = useDevanagari ? toDevanagari(coord) : coord;
    return Text(
      '‖$displayCoord‖',
      style: TextStyle(
        fontFamily: Fonts.deva,
        fontFamilyFallback: Fonts.devaFallback,
        fontSize: fontSize ?? 13,
        height: 1,
        color: color,
      ),
    );
  }
}

// ============================================================
// 4. AI THINKING DOTS — three pulsing saffron dots
// ============================================================
class AIThinkingDots extends StatefulWidget {
  final bool isDark;
  final double size;
  final double gap;

  const AIThinkingDots({
    super.key,
    required this.isDark,
    this.size = 5,
    this.gap = 4,
  });

  @override
  State<AIThinkingDots> createState() => _AIThinkingDotsState();
}

class _AIThinkingDotsState extends State<AIThinkingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Motion.aiThinkingCycle,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Returns opacity for a dot at given phase offset.
  /// Triangle wave: ramp 0→0.2 (peak), 0.2→0.4 (down), rest of cycle = base.
  /// Mirrors CSS @keyframes type-pulse { 0%,80%,100% {opacity:0.3} 40% {opacity:1} }
  double _opacityFor(double t, double phase) {
    final shifted = (t - phase + 1.0) % 1.0;
    if (shifted < 0.2) {
      return 0.3 + (shifted / 0.2) * 0.7;
    } else if (shifted < 0.4) {
      return 0.3 + ((0.4 - shifted) / 0.2) * 0.7;
    }
    return 0.3;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isDark ? DColors.saffron : LColors.saffron;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) SizedBox(width: widget.gap),
              Opacity(
                opacity: _opacityFor(t, i * 0.143), // 0.143 ≈ 0.2/1.4 cycle
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ============================================================
// 5. SANSKRIT TEXT — Tiro Devanagari with proper fallback
// ============================================================
class SanskritText extends StatelessWidget {
  final String text;
  final bool isDark;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const SanskritText(
    this.text, {
    super.key,
    required this.isDark,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark ? DColors.cream : LColors.text1;
    final baseStyle = style ?? AppText.verseSanskrit;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: baseStyle.copyWith(
        color: baseStyle.color ?? color,
        fontFamily: Fonts.deva,
        fontFamilyFallback: Fonts.devaFallback,
      ),
    );
  }
}
