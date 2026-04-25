import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/domain/entities/streak_badge.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';
import 'package:sanatan_guide/presentation/theme/app_typography.dart';

/// Streak footer — Temple Dawn variant.
///
/// Single line: 🪔  N day(s) of practice — keep the lamp burning.
/// If streak == 0 → gentle nudge instead.
class StreakLine extends ConsumerWidget {
  const StreakLine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final streakAsync = ref.watch(currentStreakProvider);
    final accent = isDark ? AppColors.saffronOnDark : AppColors.saffron;

    return streakAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (count) {
        if (count == 0) {
          return Text(
            'Start your practice today — read one verse.',
            style: context.ts.caption.copyWith(
              fontStyle: FontStyle.italic,
              color: isDark
                  ? AppColors.textSecondaryOnDark
                  : AppColors.textSecondary,
            ),
          );
        }

        final badge = StreakBadge.forStreak(count);
        final badgeSuffix = badge != null ? '  ${badge.emoji}' : '';

        return Row(
          children: [
            const Text('🪔', style: AppTypography.emojiInline),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: context.ts.bodyMedium.copyWith(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: accent,
                  ),
                  children: [
                    TextSpan(
                      text: '$count',
                      style: context.ts.bodyMedium.copyWith(
                        fontSize: 12.5,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' ${count == 1 ? 'day' : 'days'} of practice — keep the lamp burning$badgeSuffix',
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        );
      },
    );
  }
}
