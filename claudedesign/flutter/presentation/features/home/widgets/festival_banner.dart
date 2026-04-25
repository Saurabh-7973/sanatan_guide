import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/router/app_routes.dart';
import 'package:sanatan_guide/data/festivals/festival_data_2026.dart';
import 'package:sanatan_guide/presentation/features/festivals/providers/festival_provider.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// Upcoming festival — a slim horizontal banner with a soft saffron wash.
/// Tap → festivals list (unchanged route).
class FestivalBanner extends ConsumerWidget {
  const FestivalBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final festivalsAsync = ref.watch(festivalsProvider);
    final allFestivals = festivalsAsync.value ?? festivals2026;
    final upcoming = allFestivals.where((f) => !f.isPast || f.isToday).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (upcoming.isEmpty) return const SizedBox.shrink();

    final next = upcoming.first;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysUntil = next.date.difference(todayDate).inDays;

    final daysLabel = next.isToday
        ? 'Today'
        : daysUntil == 1
            ? 'Tomorrow'
            : '$daysUntil days';

    final accent = isDark ? AppColors.saffronOnDark : AppColors.saffron;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.festivals),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard - 2),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppSpacing.radiusCard - 2),
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: isDark ? 0.13 : 0.10),
                accent.withValues(alpha: 0.03),
              ],
            ),
            border: Border.all(
              color: accent.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Text(next.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'UPCOMING PARVA',
                      style: context.ts.labelSmall.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      next.name,
                      style: context.ts.titleMedium.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textOnDark
                            : AppColors.warmGrey80,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    daysLabel,
                    style: context.ts.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
