
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/router/app_routes.dart';
import 'package:sanatan_guide/core/services/app_open_ad_service.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/core/utils/panchang_utils.dart';
import 'package:sanatan_guide/data/festivals/festival_data_2026.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/streak_badge.dart';
import 'package:sanatan_guide/presentation/features/festivals/providers/festival_provider.dart';
import 'package:sanatan_guide/presentation/features/learning_path/providers/learning_provider.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/learning_progress_summary.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/verse_of_day_card.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppOpenAdService.instance.showIfReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const _GreetingHeader(),
        titleSpacing: AppSpacing.pagePadding,
        centerTitle: false,
        toolbarHeight: 64,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            tooltip: 'Search verses',
            onPressed: () => context.push(AppRoutes.search),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Warm radial glow in dark mode (top-center, very subtle)
          if (isDark)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.82),
                  radius: 1.05,
                  colors: [
                    AppColors.saffron.withValues(alpha: 0.07),
                    AppColors.saffron.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
          RefreshIndicator(
            color: AppColors.saffron,
            onRefresh: () async {
              ref.invalidate(verseOfDayProvider);
              ref.invalidate(modulesProvider);
              await ref.read(verseOfDayProvider.future);
            },
            child: ListView(
              physics: const ScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.xl,
                AppSpacing.pagePadding,
                AppSpacing.xxxl,
              ),
              children: const [
                // ── Verse of the Day hero ───────────────────────────────
                VerseOfDayCard(),

                // ── Panchang + festival ─────────────────────────────────
                SizedBox(height: AppSpacing.xxl),
                _PanchangRow(),
                SizedBox(height: AppSpacing.xs),
                _UpcomingFestivalRow(),

                // ── Learning progress + continue reading ────────────────
                SizedBox(height: AppSpacing.xxl),
                LearningProgressSummary(),
                SizedBox(height: AppSpacing.sm),
                _ContinueReadingRow(),

                // ── Streak footer ───────────────────────────────────────
                SizedBox(height: AppSpacing.xxl),
                _StreakFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Greeting header ───────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = greetingForTimeOfDay(now);
    final hindu = PanchangUtils.getHinduDate(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(greeting, style: context.ts.displayMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${hindu.monthName} · VS ${hindu.vikramSamvatYear}',
          style: context.ts.caption.copyWith(letterSpacing: 0.8),
        ),
      ],
    );
  }
}

// ── Continue reading row (simple text row, no card) ──────────────────────

class _ContinueReadingRow extends ConsumerWidget {
  const _ContinueReadingRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lastReadAsync = ref.watch(lastReadVerseProvider);
    final data = lastReadAsync.value;

    if (data == null) return const SizedBox.shrink();

    final scripture = Scripture.values.cast<Scripture?>().firstWhere(
          (s) => s?.code == data.scriptureCode,
          orElse: () => null,
        );
    if (scripture == null) return const SizedBox.shrink();

    final label = '${scripture.displayName} · ${_formatVerseId(data.verseId)}';

    return InkWell(
      onTap: () => context.push(
        '/browse/${data.scriptureCode}/verse/${data.verseId}',
      ),
      borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            const Icon(
              Icons.play_circle_outline_rounded,
              size: 18,
              color: AppColors.warmGrey50,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: context.ts.caption,
                  children: [
                    TextSpan(
                      text: 'Continue · ',
                      style: context.ts.caption.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryOnDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    TextSpan(text: label),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: isDark
                  ? AppColors.textSecondaryOnDark
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatVerseId(String id) {
    final parts = id.split('.');
    if (parts.length >= 3) return '${parts[1]}:${parts[2]}';
    if (parts.length >= 2) return parts.sublist(1).join(':');
    return id;
  }
}

// ── Streak footer (single compact line) ──────────────────────────────────

class _StreakFooter extends ConsumerWidget {
  const _StreakFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(currentStreakProvider);

    return streakAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (count) {
        if (count == 0) {
          return Text(
            'Start your practice today — read one verse.',
            style: context.ts.caption,
          );
        }
        final badge = StreakBadge.forStreak(count);
        final suffix = badge != null ? '  ${badge.emoji}' : '';
        return Text(
          '🪔  $count days of practice$suffix',
          style: context.ts.captionHighlight,
        );
      },
    );
  }
}

// ── Panchang row (compact, TODAY section) ────────────────────────────────

class _PanchangRow extends StatelessWidget {
  const _PanchangRow();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final vara = PanchangUtils.getVaraForDate(now);
    final tithi = PanchangUtils.getTithiForDate(now);

    return Row(
      children: [
        Text(vara.emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            '${vara.varaName} · ${tithi.tithiName}, ${tithi.paksha}',
            style: context.ts.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}


// ── Upcoming festival row ─────────────────────────────────────────────────

class _UpcomingFestivalRow extends ConsumerWidget {
  const _UpcomingFestivalRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final festivalsAsync = ref.watch(festivalsProvider);
    final allFestivals = festivalsAsync.value ?? festivals2026;
    final upcoming = allFestivals.where((f) => !f.isPast || f.isToday).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (upcoming.isEmpty) return const SizedBox.shrink();

    final next = upcoming.first;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysUntil = next.date.difference(todayDate).inDays;

    final daysText = next.isToday
        ? 'Today'
        : daysUntil == 1
            ? 'Tomorrow'
            : 'In $daysUntil days';

    return InkWell(
      onTap: () => context.push(AppRoutes.festivals),
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Text(next.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(next.name, style: context.ts.bodyMedium),
            ),
            Text(
              daysText,
              style: context.ts.captionHighlight,
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: AppColors.warmGrey50,
            ),
          ],
        ),
      ),
    );
  }
}
