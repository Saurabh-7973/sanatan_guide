import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// Verse of the day — Temple Dawn hero card.
///
/// Translucent warm surface, saffron-tinted 1px border, centered Sanskrit,
/// diamond divider, italic translation. Tap → verse detail (unchanged).
class VerseOfDayCard extends ConsumerWidget {
  const VerseOfDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(verseOfDayProvider);

    return async.when(
      data: (Either<Failure, Verse> either) => either.fold(
        (Failure f) => _ErrorLine(message: f.message),
        (Verse v) => _DawnVerseHero(verse: v),
      ),
      loading: () => const VerseOfDayCardShimmer(),
      error: (Object e, StackTrace _) => const ErrorStateWidget(),
    );
  }
}

class _DawnVerseHero extends StatelessWidget {
  const _DawnVerseHero({required this.verse});
  final Verse verse;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Translucent warm surface — sits over the dawn glow, lets the sun
    // bleed through softly. Uses existing palette; no new tokens.
    final surface = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.78)
        : AppColors.surface.withValues(alpha: 0.62);
    final borderColor = isDark
        ? AppColors.saffronOnDark.withValues(alpha: 0.22)
        : AppColors.saffron.withValues(alpha: 0.22);
    final labelColor =
        isDark ? AppColors.saffronOnDark : AppColors.saffron;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(
          '/browse/${verse.scripture.code}/verse/${verse.id}',
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        child: Ink(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.cardPadding,
            AppSpacing.xl,
            AppSpacing.cardPadding,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Verse label ────────────────────────────────────
              _VerseLabel(color: labelColor),
              const SizedBox(height: AppSpacing.lg),

              // ── Sanskrit ───────────────────────────────────────
              if (verse.sanskrit.isNotEmpty)
                Text(
                  verse.sanskrit,
                  style: context.ts.sanskritLarge.copyWith(
                    color: isDark
                        ? AppColors.sanskritTextOnDark
                        : AppColors.sanskritText,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              // ── Divider (line-diamond-line) ────────────────────
              const SizedBox(height: AppSpacing.md),
              _DiamondDivider(color: labelColor),
              const SizedBox(height: AppSpacing.md),

              // ── English translation ────────────────────────────
              if (verse.english != null && verse.english!.isNotEmpty)
                Text(
                  verse.english!,
                  style: context.ts.bodyMediumMuted.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),

              // ── Reference + read arrow ─────────────────────────
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getVerseLabel(verse).toUpperCase(),
                    style: context.ts.labelSmall.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryOnDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Read',
                        style: context.ts.labelSmall.copyWith(
                          color: labelColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: labelColor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerseLabel extends StatelessWidget {
  const _VerseLabel({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget dot() => Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        dot(),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'VERSE OF THE DAY',
          style: context.ts.cardLabel.copyWith(
            color: color,
            letterSpacing: 2.4,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        dot(),
      ],
    );
  }
}

class _DiamondDivider extends StatelessWidget {
  const _DiamondDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 0.5,
          color: color.withValues(alpha: 0.5),
        ),
        const SizedBox(width: AppSpacing.sm),
        Transform.rotate(
          angle: 0.785398, // 45°
          child: Container(
            width: 5,
            height: 5,
            color: color.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          width: 28,
          height: 0.5,
          color: color.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, color: AppColors.error),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(message, style: context.ts.bodyMedium)),
      ],
    );
  }
}
