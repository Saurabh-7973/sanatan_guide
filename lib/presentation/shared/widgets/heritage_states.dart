import 'package:flutter/material.dart';

import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

/// Heritage-toned loading and error states used by AsyncValue.when call
/// sites across the app. Drop-in replacements for the older generic
/// ErrorStateWidget (still around for backward-compat); these match the
/// warm-saffron / Lora aesthetic of the rest of the reader chrome so a
/// brief loading flash or a failed fetch doesn't feel jarring.

/// A small calm spinner sized for full-screen body states. Three saffron
/// dots pulsing on the warm background — no Material indeterminate ring,
/// no spinner inside a divider box. Pair with a one-line label below.
class HeritageLoading extends StatelessWidget {
  const HeritageLoading({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDots(color: saffron),
          if (label != null) ...[
            const SizedBox(height: 18),
            Text(
              label!,
              style: TextStyle(
                fontFamily: Fonts.serif,
                fontFamilyFallback: AppFontFallback.latin,
                fontStyle: FontStyle.italic,
                fontSize: 13,
                color: text3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PulseDots extends StatefulWidget {
  const _PulseDots({required this.color});
  final Color color;

  @override
  State<_PulseDots> createState() => _PulseDotsState();
}

class _PulseDotsState extends State<_PulseDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 12,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              // Stagger the three dots by 1/3 of the cycle.
              final phase = (t + i / 3) % 1.0;
              // Triangle wave 0→1→0 across the cycle.
              final alpha = phase < 0.5
                  ? 0.25 + (phase * 2) * 0.75
                  : 1.0 - ((phase - 0.5) * 2) * 0.75;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: alpha),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// Heritage-toned error state with optional retry. Iron-red glyph in a
/// saffron-glow disc, italic Lora body, saffron pill retry button —
/// matches the empty-state CTA in bookmarks etc. Use as a full-body
/// fallback in AsyncValue.when's error branch.
class HeritageError extends StatelessWidget {
  const HeritageError({
    super.key,
    this.message = 'Something went wrong loading this. Pull down or tap retry.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final iron = isDark ? DColors.ironRedBright : LColors.ironRedBright;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: saffron.withValues(alpha: isDark ? 0.10 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, color: iron, size: 26),
            ),
            const SizedBox(height: 18),
            Text(
              'A pause in the path',
              style: TextStyle(
                fontFamily: Fonts.serif,
                fontFamilyFallback: AppFontFallback.latin,
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: text1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Fonts.serif,
                fontFamilyFallback: AppFontFallback.latin,
                fontStyle: FontStyle.italic,
                fontSize: 13,
                height: 1.5,
                color: text2,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 22),
              Material(
                color: saffron,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: onRetry,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                    child: Text(
                      'TRY AGAIN',
                      style: TextStyle(
                        fontFamily: Fonts.sans,
                        fontFamilyFallback: AppFontFallback.latin,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.12 * 11,
                        color: isDark ? const Color(0xFF1A1208) : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
