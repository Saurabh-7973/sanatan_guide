// 5 shared primitives for Sanatan Guide.
// Every screen composes from these.

import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

// ============================================================
// 1. BINDING LINE — palm-leaf top marker with diamond hole
// ============================================================

class BindingLine extends StatelessWidget {
  final bool isDark;
  final double diamondSize;
  final double sideGap;

  /// Palm-leaf folio binding: the rules fade to transparent at the outer
  /// edges and run saffron-deep toward the centre diamond (verse-detail leaf).
  /// When false (default) the rules are a flat divider-colour hairline — the
  /// "incised rule" used on Home / Onboarding.
  final bool faded;

  const BindingLine({
    super.key,
    required this.isDark,
    this.diamondSize = 4,
    this.sideGap = 5,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    if (faded) return _buildFaded();

    final lineColor = isDark ? DColors.divider : LColors.divider;
    final dotColor = isDark ? DColors.saffron : LColors.saffron;

    Widget rule() => Expanded(child: Container(height: 1, color: lineColor));

    return SizedBox(
      height: 12,
      child: Row(
        children: [
          rule(),
          SizedBox(width: sideGap),
          Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: diamondSize,
              height: diamondSize,
              color: dotColor,
            ),
          ),
          SizedBox(width: sideGap),
          rule(),
        ],
      ),
    );
  }

  Widget _buildFaded() {
    final ruleColor = isDark
        ? DColors.saffronDeep
        : LColors.saffronDeep.withValues(alpha: 0.4);
    final dotColor = isDark ? DColors.saffron : LColors.saffronDeep;

    Widget rule({required bool fadeLeft}) => Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: fadeLeft
                    ? [Colors.transparent, ruleColor]
                    : [ruleColor, Colors.transparent],
              ),
            ),
          ),
        );

    return SizedBox(
      height: 14,
      child: Row(
        children: [
          rule(fadeLeft: true),
          SizedBox(width: sideGap),
          Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: diamondSize,
              height: diamondSize,
              decoration: BoxDecoration(
                color: dotColor,
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: DColors.saffron.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
          SizedBox(width: sideGap),
          rule(fadeLeft: false),
        ],
      ),
    );
  }
}

// ============================================================
// 2. LEAF THREAD — saffron 3 px strip on the left edge
// ============================================================

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
      _ctrl.forward().then((_) {
        if (mounted) _ctrl.reverse();
      });
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
                      color: color.withValues(alpha: glowOpacity),
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

class DandaCoord extends StatelessWidget {
  final List<int> parts;
  final bool isDark;
  final double fontSize;
  final Color? colorOverride;

  /// Two-part coord: ‖chapter·verse‖
  const DandaCoord({
    super.key,
    required int chapter,
    required int verse,
    required this.isDark,
    this.fontSize = 13,
    this.colorOverride,
  })  : parts = const [],
        _chapter = chapter,
        _verse = verse;

  /// Multi-part coord: ‖a·b·c‖ (e.g. Upanishad sections)
  const DandaCoord.multipart({
    super.key,
    required this.parts,
    required this.isDark,
    this.fontSize = 13,
    this.colorOverride,
  })  : _chapter = 0,
        _verse = 0;

  final int _chapter;
  final int _verse;

  static const _devNumerals = [
    '०',
    '१',
    '२',
    '३',
    '४',
    '५',
    '६',
    '७',
    '८',
    '९',
  ];

  static String toDevanagari(int n) {
    return n.toString().split('').map((d) {
      final i = int.tryParse(d);
      return i != null ? _devNumerals[i] : d;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final color = colorOverride ?? (isDark ? DColors.saffron : LColors.saffron);

    final coordText = parts.isNotEmpty
        ? parts.map(toDevanagari).join('·')
        : '${toDevanagari(_chapter)}·${toDevanagari(_verse)}';

    return Text(
      '‖$coordText‖',
      style: AppText.dandaCoord(saffronColor: color).copyWith(
        fontSize: fontSize,
      ),
    );
  }
}

// ============================================================
// 4. AI THINKING DOTS — three pulsing saffron dots
// ============================================================

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
    final shifted = (t - phase) % 1.0;
    if (shifted < 0.4) {
      return 0.3 +
          (shifted < 0.2
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
                  color: color.withValues(alpha: _opacityFor(t, phase)),
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
// 5. SANSKRIT TEXT — wrapper using Tiro Devanagari
// ============================================================

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
      locale: const Locale('sa'),
    );
  }
}
