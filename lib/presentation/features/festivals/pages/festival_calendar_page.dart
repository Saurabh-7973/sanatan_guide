import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/data/festivals/festival_data_2026.dart';
import 'package:sanatan_guide/domain/entities/festival.dart';
import 'package:sanatan_guide/presentation/features/festivals/providers/festival_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class FestivalCalendarPage extends ConsumerWidget {
  const FestivalCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final festivalsAsync = ref.watch(festivalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Festival Calendar'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: festivalsAsync.when(
        loading: () => const FestivalShimmer(),
        error: (_, __) => _FestivalBody(festivals: festivals2026),
        data: (festivals) => _FestivalBody(festivals: festivals),
      ),
    );
  }
}

class _FestivalBody extends StatelessWidget {
  const _FestivalBody({required this.festivals});

  final List<Festival> festivals;

  @override
  Widget build(BuildContext context) {
    final upcoming = festivals.where((f) => !f.isPast || f.isToday).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final past = festivals.where((f) => f.isPast && !f.isToday).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        const _SourceDisclaimer(),
        if (upcoming.isNotEmpty) ...[
          const _SectionHeader(title: 'Upcoming'),
          ...upcoming.map((f) => _FestivalTile(festival: f)),
        ],
        if (past.isNotEmpty) ...[
          const _SectionHeader(title: 'Earlier this year'),
          ...past.map((f) => _FestivalTile(festival: f, muted: true)),
        ],
      ],
    );
  }
}

class _SourceDisclaimer extends StatelessWidget {
  const _SourceDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
      ),
      child: Text(
        'Dates based on Drik Panchang for North Indian (Purnimant) calendar. '
        'Consult your local pandit for regional variations.',
        style: context.ts.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.lg,
        AppSpacing.pagePadding,
        AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: context.ts.sectionLabel,
      ),
    );
  }
}

class _FestivalTile extends StatelessWidget {
  const _FestivalTile({required this.festival, this.muted = false});

  final Festival festival;
  final bool muted;

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => _FestivalDetailPage(festival: festival),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                _formatDate(festival.date),
                style: context.ts.caption.copyWith(
                  color: muted ? AppColors.textSecondary : AppColors.saffron,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Hero(
              tag: 'festival_emoji_${festival.id}',
              child: Text(
                festival.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        festival.name,
                        style: context.ts.labelMedium.copyWith(
                          color: muted ? AppColors.textSecondary : null,
                        ),
                      ),
                      if (festival.isToday) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.saffronMuted,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Today',
                            style: context.ts.labelSmall.copyWith(
                              color: AppColors.saffron,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    festival.shortDesc,
                    style: context.ts.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: muted
                  ? AppColors.textSecondary.withValues(alpha: 0.4)
                  : AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _FestivalDetailPage extends StatelessWidget {
  const _FestivalDetailPage({required this.festival});

  final Festival festival;

  String _formatFullDate(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${days[date.weekday - 1]}, '
        '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'festival_emoji_${festival.id}',
              child: Text(
                festival.emoji,
                style: const TextStyle(fontSize: 56),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(festival.name, style: context.ts.displayLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              festival.sanskritName,
              style: context.ts.sanskritMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formatFullDate(festival.date),
              style: context.ts.caption.copyWith(color: AppColors.saffron),
            ),
            const SizedBox(height: AppSpacing.xl),
            Divider(color: isDark ? AppColors.dividerDark : AppColors.divider),
            const SizedBox(height: AppSpacing.xl),
            Text(
              festival.explainer,
              style: context.ts.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Divider(color: isDark ? AppColors.dividerDark : AppColors.divider),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                const Icon(
                  Icons.volunteer_activism_outlined,
                  color: AppColors.saffron,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'How to observe',
                  style: context.ts.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ...festival.howToObserve.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.saffronMuted,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: context.ts.caption.copyWith(
                          color: AppColors.saffron,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        step,
                        style: context.ts.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
