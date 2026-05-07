// lib/core/widgets/heritage_widgets.dart
//
// The 5 shared primitives for Sanatan Guide.
// Every screen composes from these. Do not reimplement these
// patterns inline — extend this file if needed.

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/design_typography.dart';

// ============================================================
// 1. BINDING LINE — palm-leaf top marker with diamond hole
// ============================================================

/// A horizontal saffron-faded rule with a small rotated diamond
/// at the center. Used at the top of "leaf" surfaces:
/// verse cards, bookmark leaves, citation cards in AI Chat.
///
/// Place this 6–8 px from the top of the leaf, with horizontal
/// padding matching the leaf's content padding.
///
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     // ...your card content
///     Positioned(
///       top: 8, left: 18, right: 18,
///       child: BindingLine(isDark: isDark),
///     ),
///   ],
/// )
/// ```
class BindingLine extends StatelessWidget {
  final bool isDark;
  final double diamondSize;
  final double sideGap;

  const BindingLine({
    super.key,
    required this.isDark,
    this.diamondSize = 5,
    this.sideGap = 10,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = isDark
        ? DColors.saffronDeep.withOpacity(0.4)
        : LColors.saffronDeep.withOpacity(0.4);
    final dotColor = isDark ? DColors.saffron : LColors.saffronDeep;

    return SizedBox(
      height: 12,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, lineColor, Colors.transparent],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
          SizedBox(width: sideGap),
          Transform.rotate(
            angle: 0.785398, // 45deg
            child: Container(
              width: diamondSize,
              height: diamondSize,
              color: dotColor,
            ),
          ),
          SizedBox(width: sideGap),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, lineColor, Colors.transparent],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 2. LEAF THREAD — saffron 3 px strip on the left edge
// ============================================================

/// A 3px saffron rectangle on the left edge of a card or row.
/// Means "your place / your active / your selection."
///
/// Compose this inside a Stack with the leaf content. Set
/// `pulseOnce: true` for the entry animation (Practice/Continue,
/// Onboarding selection).
///
/// Usage:
/// ```dart
/// Container(
///   decoration: ...your card decoration,
///   child: Stack(
///     children: [
///       // ...content
///       Positioned(
///         left: 0, top: 12, bottom: 12,
///         child: LeafThread(isDark: isDark, pulseOnce: true),
///       ),
///     ],
///   ),
/// )
/// ```
class LeafThread extends StatefulWidget {
  final bool isDark;
  final bool pulseOnce;
  final double width;

  const LeafThread({
    super.key,
    required this.isDark,
    this.pulseOnce = false,
    this.width = 3,
  });

  @override
  State<LeafThread> createState() => _LeafThreadState();
}

class _LeafThreadState extends State<LeafThread>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.pulseOnce) {
      _ctrl.forward().then((_) => _ctrl.reverse());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isDark ? DColors.saffron : LColors.saffron;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final glowOpacity = 0.5 + (_ctrl.value * 0.5);
        return Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: widget.isDark
                ? [
                    BoxShadow(
                      color: color.withOpacity(glowOpacity),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}

// ============================================================
// 3. DAṆḌA COORDINATE — ‖१·१‖
// ============================================================

/// Renders a verse coordinate using Sanskrit double-vertical-bar
/// convention with Devanāgarī numerals.
///
/// Pass `1, 1` for BG 1.1; pass `2, 47` for BG 2.47.
/// For Upanishads with 3-part coords, use `[1, 3, 14]` via the named
/// constructor `multipart`.
///
/// Always saffron when used as a coordinate; pass color override
/// for special cases.
class DandaCoord extends StatelessWidget {
  final List<int> parts;
  final bool isDark;
  final double fontSize;
  final Color? colorOverride;

  const DandaCoord({
    super.key,
    required this.chapter,
    required this.verse,
    required this.isDark,
    this.fontSize = 13,
    this.colorOverride,
  }) : parts = const [];

  const DandaCoord.simple({
    super.key,
    required int chapter,
    required int verse,
    required this.isDark,
    this.fontSize = 13,
    this.colorOverride,
  })  : parts = const [],
        chapter = chapter,
        verse = verse;

  const DandaCoord.multipart({
    super.key,
    required this.parts,
    required this.isDark,
    this.fontSize = 13,
    this.colorOverride,
  })  : chapter = 0,
        verse = 0;

  final int chapter;
  final int verse;

  static const _devNumerals = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];

  static String toDevanagari(int n) {
    return n.toString().split('').map((d) {
      final i = int.tryParse(d);
      return i != null ? _devNumerals[i] : d;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final color = colorOverride ??
        (isDark ? DColors.saffron : LColors.saffron);

    final coordText = parts.isNotEmpty
        ? parts.map(toDevanagari).join('·')
        : '${toDevanagari(chapter)}·${toDevanagari(verse)}';

    return Text(
      '‖$coordText‖',
      style: TextStyle(
        fontFamily: Fonts.deva,
        fontSize: fontSize,
        height: 1.0,
        color: color,
      ),
    );
  }
}

// ============================================================
// 4. AI THINKING DOTS — three pulsing saffron dots
// ============================================================

/// Three small saffron dots pulsing with 0.2s phase offset.
/// Single AI-thinking vocabulary across the app: Verse Detail
/// "Explain", Search Pandit, AI Chat.
///
/// Show this whenever the AI is generating a response.
class AIThinkingDots extends StatefulWidget {
  final bool isDark;
  final double dotSize;

  const AIThinkingDots({
    super.key,
    required this.isDark,
    this.dotSize = 5,
  });

  @override
  State<AIThinkingDots> createState() => _AIThinkingDotsState();
}

class _AIThinkingDotsState extends State<AIThinkingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _opacityFor(double t, double phase) {
    // phase ∈ {0, 0.2, 0.4} for three dots
    final shifted = (t - phase) % 1.0;
    if (shifted < 0.4) {
      // 0..0.4 ramps up then down (peak at 0.2)
      return 0.3 + (shifted < 0.2
          ? (shifted / 0.2) * 0.7
          : (1 - (shifted - 0.2) / 0.2) * 0.7);
    }
    return 0.3;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isDark ? DColors.saffron : LColors.saffron;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [0.0, 0.143, 0.286].map((phase) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: widget.dotSize,
                height: widget.dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(_opacityFor(t, phase)),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ============================================================
// 5. SANSKRIT TEXT — wrapper that always uses Tiro Devanagari
// ============================================================

/// Renders Sanskrit text with the correct font, line-height, and
/// language attribute for screen readers.
///
/// Use this for all Sanskrit verse bodies. For UI Devanāgarī
/// (numerals, short labels), use AppText.devUI instead.
class SanskritText extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const SanskritText(
    this.text, {
    super.key,
    required this.color,
    this.size = 18,
    this.textAlign = TextAlign.left,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: AppText.sanskritBody(color: color, size: size),
      // Locale tag for screen readers; Sanskrit = 'sa'
      locale: const Locale('sa'),
    );
  }
}
