import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/utils/verse_text.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/reading_mode_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/verse_section_widgets.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/font_size_provider.dart'
    as font_prefs;
import 'package:sanatan_guide/presentation/shared/widgets/sacred_ornaments.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// Scrollable body of the verse detail page: heading, Sanskrit/Tamil,
/// IAST, translations, word-by-word. Kept in a sliver so the parent
/// collapsing app bar drives layout.
class VerseContentSliver extends ConsumerWidget {
  const VerseContentSliver({
    super.key,
    required this.verse,
    required this.plainSanskritReading,
    required this.canStripAccents,
    required this.isTirukkural,
    required this.onToggleAccents,
    required this.wordMeaningsExpanded,
    required this.onToggleWordMeanings,
    required this.hasPrev,
    required this.hasNext,
    required this.showTranslitOverride,
    required this.onToggleTranslit,
  });

  final Verse verse;
  final bool plainSanskritReading;
  final bool canStripAccents;
  final bool isTirukkural;
  final VoidCallback onToggleAccents;
  final bool wordMeaningsExpanded;
  final VoidCallback onToggleWordMeanings;
  final bool hasPrev;
  final bool hasNext;
  final bool showTranslitOverride;
  final VoidCallback onToggleTranslit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(readingModeProvider);
    final fontSize = ref.watch(font_prefs.fontSizeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showSanskrit =
        mode == ReadingMode.all || mode == ReadingMode.sanskrit;
    final showTranslit = mode == ReadingMode.all || showTranslitOverride;
    final showTranslation =
        mode == ReadingMode.all || mode == ReadingMode.translationOnly;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: AppSpacing.sm),
          // Lotus medallion verse-number badge
          Center(
            child: LotusMedallion(
              label: '${verse.verseNum}',
              size: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            verse.scripture.displayName.toUpperCase(),
            style: context.ts.caption.copyWith(
              letterSpacing: 2.0,
              fontWeight: FontWeight.w600,
              color: AppColors.warmGrey50,
            ),
            textAlign: TextAlign.center,
          ),

          if (showSanskrit && verse.sanskrit.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            isTirukkural
                ? _TamilBlock(verse: verse)
                : _SanskritBlock(
                    verse: verse,
                    plain: plainSanskritReading,
                    canStrip: canStripAccents,
                    onToggleAccents: onToggleAccents,
                    fontSizeScale: fontSize / font_prefs.kDefaultFontSize,
                  ),
          ] else if (!showSanskrit &&
              !showTranslation &&
              (verse.english == null || verse.english!.isEmpty)) ...[
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Text not available for this verse',
              style: context.ts.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          if (showSanskrit && verse.sanskrit.isNotEmpty && canStripAccents)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                plainSanskritReading
                    ? 'Tap Sanskrit to show Vedic accents'
                    : 'Tap Sanskrit for plain reading',
                style: context.ts.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),

          if (!showTranslit &&
              mode != ReadingMode.all &&
              verse.transliteration != null &&
              verse.transliteration!.isNotEmpty &&
              showSanskrit)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: GestureDetector(
                onTap: onToggleTranslit,
                child: Text(
                  showTranslitOverride
                      ? 'Hide pronunciation'
                      : 'Show pronunciation',
                  style: context.ts.caption.copyWith(
                    color: AppColors.saffron,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.saffron,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          if (showTranslit &&
              verse.transliteration != null &&
              verse.transliteration!.isNotEmpty) ...[
            SizedBox(
              height: showSanskrit && verse.sanskrit.isNotEmpty
                  ? AppSpacing.md
                  : AppSpacing.lg,
            ),
            if (showSanskrit && verse.sanskrit.isNotEmpty) ...[
              verseSectionDivider(context),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              verse.transliteration!,
              style: context.ts.transliteration.copyWith(fontSize: fontSize),
              textAlign: TextAlign.center,
            ),
          ],

          if (!showTranslation &&
              (verse.english != null && verse.english!.isNotEmpty)) ...[
            const SizedBox(height: AppSpacing.xl),
            GestureDetector(
              onTap: () => ref
                  .read(readingModeProvider.notifier)
                  .setMode(ReadingMode.all),
              child: Text(
                'Translation hidden · tap to show',
                style: context.ts.caption.copyWith(
                  color: AppColors.saffron.withValues(alpha: 0.7),
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.saffron.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          if (showTranslation &&
              ((verse.english != null && verse.english!.isNotEmpty) ||
                  (verse.hindi != null && verse.hindi!.isNotEmpty))) ...[
            if ((showSanskrit && verse.sanskrit.isNotEmpty) ||
                (showTranslit &&
                    verse.transliteration != null &&
                    verse.transliteration!.isNotEmpty)) ...[
              const SizedBox(height: AppSpacing.xl),
              verseSectionDivider(context),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (verse.english != null && verse.english!.isNotEmpty)
              Text(
                verse.english!,
                style: context.ts.bodyLarge.copyWith(
                  fontSize: fontSize,
                  color: isDark
                      ? AppColors.textOnDark
                      : AppColors.textPrimary.withValues(alpha: 0.85),
                ),
              ),
            if (verse.hindi != null && verse.hindi!.isNotEmpty) ...[
              if (verse.english != null && verse.english!.isNotEmpty)
                const SizedBox(height: AppSpacing.xl),
              Text(
                'हिंदी',
                style:
                    context.ts.caption.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                verse.hindi!,
                style: context.ts.hindiBody.copyWith(
                  fontSize: math.max(17.0, fontSize),
                ),
              ),
            ],
          ],

          if (verse.wordMeanings != null &&
              verse.wordMeanings!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            verseSectionDivider(context),
            const SizedBox(height: AppSpacing.sm),
            ExpandableSection(
              title: 'Word by Word',
              expanded: wordMeaningsExpanded,
              onToggle: onToggleWordMeanings,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: verse.wordMeanings!.map((wm) {
                  final base = context.ts.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: fontSize,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: RichText(
                      text: TextSpan(
                        style: base,
                        children: [
                          TextSpan(
                            text: wm.word,
                            style: base.copyWith(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: ' — ${wm.meaning}'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxxl),
          if (hasPrev || hasNext)
            Text(
              'Swipe left or right to navigate',
              textAlign: TextAlign.center,
              style: context.ts.caption.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary.withValues(alpha: 0.35),
              ),
            ),
          const SizedBox(height: AppSpacing.huge),
        ]),
      ),
    );
  }
}

class _SanskritBlock extends StatelessWidget {
  const _SanskritBlock({
    required this.verse,
    required this.plain,
    required this.canStrip,
    required this.onToggleAccents,
    this.fontSizeScale = 1.0,
  });

  final Verse verse;
  final bool plain;
  final bool canStrip;
  final VoidCallback onToggleAccents;
  final double fontSizeScale;

  @override
  Widget build(BuildContext context) {
    final text =
        plain && canStrip ? stripVedicAccents(verse.sanskrit) : verse.sanskrit;
    final isMultiLine = text.contains('\n') || text.length > 60;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseStyle = context.ts.sanskritLarge.copyWith(
      color: isDark ? AppColors.sanskritTextOnDark : AppColors.sanskritText,
    );
    final scaledStyle = fontSizeScale != 1.0
        ? baseStyle.copyWith(
            fontSize: (baseStyle.fontSize ?? 32) * fontSizeScale,
          )
        : baseStyle;

    return Semantics(
      label: 'Sanskrit verse: ${verse.transliteration ?? verse.id}',
      child: GestureDetector(
        onTap: canStrip ? onToggleAccents : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Faint jaali screen behind Sanskrit
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRect(
                  child: JaaliLattice(
                    cell: 24,
                    opacity: isDark ? 0.10 : 0.08,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.md,
              ),
              child: Text(
                text,
                style: scaledStyle,
                textAlign: isMultiLine ? TextAlign.start : TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(
          begin: 0.03,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _TamilBlock extends StatelessWidget {
  const _TamilBlock({required this.verse});

  final Verse verse;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tamil (Tirukkural)',
          style: context.ts.caption,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            verse.sanskrit,
            style: context.ts.sanskritLarge.copyWith(fontFamily: 'monospace'),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Install Tamil font for best experience.',
          style: context.ts.caption.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(
          begin: 0.03,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
