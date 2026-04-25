// lib/presentation/features/home/widgets/streak_badge_strip.dart
//
// Streak milestone badges (roadmap gamification v1) — shown above reading heatmap.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/domain/entities/streak_badge.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class StreakBadgeStrip extends ConsumerWidget {
  const StreakBadgeStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(currentStreakProvider);
    final historyAsync = ref.watch(readHistoryProvider);

    return streakAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (int streak) => historyAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (Set<String> history) {
              if (history.isEmpty && streak == 0) {
                return const SizedBox.shrink();
              }
              final isDark =
                  Theme.of(context).brightness == Brightness.dark;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'READING MILESTONES',
                    style: context.ts.caption.copyWith(
                      letterSpacing: 2.0,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        for (var i = 0; i < StreakBadge.values.length; i++) ...[
                          if (i > 0) const SizedBox(width: AppSpacing.sm),
                          _BadgeOrb(
                            badge: StreakBadge.values[i],
                            earned: streak >= StreakBadge.values[i].minStreak,
                            isDark: isDark,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}

class _BadgeOrb extends StatelessWidget {
  const _BadgeOrb({
    required this.badge,
    required this.earned,
    required this.isDark,
  });

  final StreakBadge badge;
  final bool earned;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final borderColor = earned
        ? AppColors.saffron.withValues(alpha: isDark ? 0.55 : 0.45)
        : (isDark ? AppColors.borderDark : AppColors.border);
    final fill = earned
        ? AppColors.saffron.withValues(alpha: isDark ? 0.14 : 0.1)
        : (isDark
            ? AppColors.surfaceHighest.withValues(alpha: 0.6)
            : AppColors.surfaceVariant.withValues(alpha: 0.85));

    return Tooltip(
      message: earned
          ? '${badge.label} — unlocked'
          : '${badge.label} — unlocks at a ${badge.minStreak}-day streak',
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: Border.all(color: borderColor, width: earned ? 1.5 : 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            badge.emoji,
            style: TextStyle(
              fontSize: 20,
              height: 1,
              color: earned
                  ? null
                  : (isDark
                      ? AppColors.textSecondaryOnDark
                          .withValues(alpha: 0.45)
                      : AppColors.textSecondary.withValues(alpha: 0.45)),
            ),
          ),
        ),
      ),
    );
  }
}
