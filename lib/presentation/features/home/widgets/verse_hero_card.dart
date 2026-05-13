import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

/// Verse-of-day hero card — palm-leaf manuscript metaphor.
///
/// Top + bottom BindingLine with central diamond hole, pushpikā ❁ flanking
/// verse meta, Tiro Devanagari Sanskrit, italic serif translation, saffron
/// "Read full verse →" CTA. Three states: data, loading, error.
class VerseHeroCard extends ConsumerWidget {
  const VerseHeroCard({super.key, this.isFirstDay = false});

  final bool isFirstDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncVerse = ref.watch(verseOfDayProvider);

    return asyncVerse.when(
      data: (either) => either.fold(
        (_) => _ErrorBanner(
          isDark: isDark,
          onRetry: () => ref.invalidate(verseOfDayProvider),
        ),
        (verse) => _VerseCard(
          isDark: isDark,
          verse: verse,
          isFirstDay: isFirstDay,
          onTap: () => context.push(
            '/browse/${verse.scripture.code}/verse/${verse.id}',
          ),
        ),
      ),
      loading: () => _LoadingCard(isDark: isDark),
      error: (_, __) => _ErrorBanner(
        isDark: isDark,
        onRetry: () => ref.invalidate(verseOfDayProvider),
      ),
    );
  }
}

// ============================================================
// _VerseCard — happy path
// ============================================================
class _VerseCard extends StatelessWidget {
  const _VerseCard({
    required this.isDark,
    required this.verse,
    required this.isFirstDay,
    required this.onTap,
  });

  final bool isDark;
  final Verse verse;
  final bool isFirstDay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? DColors.surface : LColors.surface;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final saffronDeep = isDark ? DColors.saffronDeep : LColors.saffronDeep;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;

    final meta = isFirstDay
        ? 'Your first verse'
        : '${verse.scripture.displayName} · ${verse.chapterNum} · ${verse.verseNum}';
    final ctaText = isFirstDay ? 'BEGIN READING' : 'READ FULL VERSE';
    final translation = verse.english?.trim() ?? '';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(top: 28),
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(
            color: saffron.withValues(alpha: isDark ? 0.10 : 0.12),
            width: 1,
          ),
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    saffron.withValues(alpha: 0.04),
                    Colors.transparent,
                    saffron.withValues(alpha: 0.03),
                  ],
                  stops: const [0, 0.3, 1],
                )
              : null,
        ),
        child: Column(
          children: [
            BindingLine(isDark: isDark),
            const SizedBox(height: 14),
            _VerseMeta(
              text: meta,
              saffron: saffron,
              pushpikaColor: isDark ? saffronDeep : LColors.ironRed,
            ),
            const SizedBox(height: 22),
            Text(
              verse.sanskrit.trim(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Fonts.deva,
                fontSize: 22,
                height: 1.85,
                letterSpacing: 0.11,
                color: cream,
              ),
            )
                .animate()
                .fadeIn(
                  duration: 700.ms,
                  delay: 100.ms,
                  curve: Curves.easeOut,
                )
                .slideY(
                  begin: 0.05,
                  end: 0,
                  duration: 700.ms,
                  delay: 100.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 22),
            _DividerLabel(
              label: isFirstDay ? _firstDaySource(verse) : 'TRANSLATION',
              isDark: isDark,
              divider: divider,
              text3: text3,
              saffron: saffron,
            ),
            const SizedBox(height: 22),
            if (translation.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  translation,
                  textAlign: TextAlign.center,
                  style: AppText.translation(color: text2, size: 14.5),
                ),
              )
                  .animate()
                  .fadeIn(
                    duration: 700.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  )
                  .slideY(
                    begin: 0.05,
                    end: 0,
                    duration: 700.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  ),
            const SizedBox(height: 22),
            _Cta(label: ctaText, color: saffron)
                .animate()
                .fadeIn(
                  duration: 700.ms,
                  delay: 500.ms,
                  curve: Curves.easeOut,
                )
                .slideY(
                  begin: 0.05,
                  end: 0,
                  duration: 700.ms,
                  delay: 500.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 14),
            BindingLine(isDark: isDark),
          ],
        ),
      ),
    );
  }

  static String _firstDaySource(Verse verse) {
    return '${verse.scripture.displayName} ${verse.chapterNum}.${verse.verseNum}';
  }
}

// ============================================================
// _VerseMeta — pushpikā ❁ · meta · ❁
// ============================================================
class _VerseMeta extends StatelessWidget {
  const _VerseMeta({
    required this.text,
    required this.saffron,
    required this.pushpikaColor,
  });

  final String text;
  final Color saffron;
  final Color pushpikaColor;

  @override
  Widget build(BuildContext context) {
    final pushpika = TextStyle(
      fontFamily: Fonts.serif,
      fontSize: 12,
      height: 1.0,
      color: pushpikaColor,
    );
    final label = TextStyle(
      fontFamily: Fonts.sans,
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 2.2,
      color: saffron,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('❁', style: pushpika),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text.toUpperCase(),
            textAlign: TextAlign.center,
            style: label,
          ),
        ),
        const SizedBox(width: 12),
        Text('❁', style: pushpika),
      ],
    );
  }
}

// ============================================================
// _DividerLabel — line · TRANSLATION · line
// ============================================================
class _DividerLabel extends StatelessWidget {
  const _DividerLabel({
    required this.label,
    required this.isDark,
    required this.divider,
    required this.text3,
    required this.saffron,
  });

  final String label;
  final bool isDark;
  final Color divider;
  final Color text3;
  final Color saffron;

  @override
  Widget build(BuildContext context) {
    final isSourceLine = label.contains(' ');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 24, height: 1, color: divider),
        const SizedBox(width: 10),
        Text(
          label,
          style: isSourceLine
              ? TextStyle(
                  fontFamily: Fonts.serif,
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                  letterSpacing: 0.5,
                  color: text3,
                )
              : TextStyle(
                  fontFamily: Fonts.sans,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.52,
                  color: text3,
                ),
        ),
        const SizedBox(width: 10),
        Container(width: 24, height: 1, color: divider),
      ],
    );
  }
}

// ============================================================
// _Cta — "READ FULL VERSE  →"
// ============================================================
class _Cta extends StatelessWidget {
  const _Cta({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: Fonts.sans,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.92,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.arrow_forward, size: 14, color: color),
      ],
    );
  }
}

// ============================================================
// _LoadingCard — skeleton w/ binding-lines visible
// ============================================================
class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? DColors.surface : LColors.surface;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final divider = isDark ? DColors.divider : LColors.divider;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return Container(
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(
          color: saffron.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          BindingLine(isDark: isDark),
          const SizedBox(height: 14),
          const _Skel(width: 140, height: 10),
          const SizedBox(height: 22),
          for (final w in const [0.85, 0.6, 0.85, 0.6]) ...[
            _Skel(widthFactor: w, height: 16),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 10),
          _DividerLabel(
            label: 'TRANSLATION',
            isDark: isDark,
            divider: divider,
            text3: text3,
            saffron: saffron,
          ),
          const SizedBox(height: 16),
          for (final w in const [0.7, 0.7, 0.5]) ...[
            _Skel(widthFactor: w, height: 10),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 22),
          BindingLine(isDark: isDark),
        ],
      ),
    );
  }
}

class _Skel extends StatelessWidget {
  const _Skel({this.width, this.widthFactor, required this.height});

  final double? width;
  final double? widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0x14E8820C),
        borderRadius: BorderRadius.circular(2),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 800.ms, begin: 0.5, curve: Curves.easeInOut);
    if (widthFactor != null) {
      return FractionallySizedBox(widthFactor: widthFactor, child: box);
    }
    return box;
  }
}

// ============================================================
// _ErrorBanner — dashed iron-red w/ ! glyph + retry
// ============================================================
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.isDark, required this.onRetry});

  final bool isDark;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ironRed = isDark ? DColors.ironRed : LColors.ironRed;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;

    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: ironRed.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(
          color: ironRed,
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ironRed.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '!',
              style: TextStyle(
                fontFamily: Fonts.deva,
                fontSize: 18,
                color: ironRed,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Today's verse couldn't be retrieved",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontStyle: FontStyle.italic,
              fontSize: 15,
              color: text1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your library is intact. The daily selection just needs another moment.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontSize: 12,
              height: 1.5,
              color: text2,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: Text(
                '↻   TRY AGAIN',
                style: TextStyle(
                  fontFamily: Fonts.sans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.2,
                  color: saffron,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
