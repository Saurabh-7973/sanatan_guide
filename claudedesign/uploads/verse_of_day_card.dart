import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class VerseOfDayCard extends ConsumerWidget {
  const VerseOfDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(verseOfDayProvider);

    return async.when(
      data: (Either<Failure, Verse> either) => either.fold(
        (Failure f) => _MessageRow(
          icon: Icons.error_outline,
          text: f.message,
          color: AppColors.error,
        ),
        (Verse v) => _VerseHero(verse: v),
      ),
      loading: () => const VerseOfDayCardShimmer(),
      error: (Object e, StackTrace _) => const ErrorStateWidget(),
    );
  }
}

class _VerseHero extends StatelessWidget {
  const _VerseHero({required this.verse});
  final Verse verse;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(
          '/browse/${verse.scripture.code}/verse/${verse.id}',
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
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
              // ── Saffron accent dash ─────────────────────────────────
              Center(
                child: Container(
                  width: 32,
                  height: 2,
                  decoration: const BoxDecoration(
                    color: AppColors.saffron,
                    borderRadius: BorderRadius.all(Radius.circular(1)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Sanskrit or translation ─────────────────────────────
              if (verse.sanskrit.isNotEmpty)
                Text(
                  verse.sanskrit,
                  style: context.ts.sanskritLarge,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (verse.english != null && verse.english!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  verse.english!,
                  style: context.ts.bodyMediumMuted,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // ── Reference ───────────────────────────────────────────
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getVerseLabel(verse),
                    style: context.ts.caption,
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.warmGrey50,
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

class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(text, style: context.ts.bodyMedium),
        ),
      ],
    );
  }
}
