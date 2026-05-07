import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/domain/entities/learning_module.dart';
import 'package:sanatan_guide/presentation/features/learning_path/providers/learning_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class LearningPathPage extends ConsumerWidget {
  const LearningPathPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(modulesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Your Path', style: context.ts.displayMedium),
        centerTitle: false,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.paddingOf(context).top,
              ),
              child: state.when(
                loading: () => const LearningPathShimmer(),
                error: (e, _) => ErrorStateWidget(
                  onRetry: () => ref.invalidate(modulesProvider),
                ),
                data: (either) => either.fold(
                  (failure) => ErrorStateWidget(message: failure.message),
                  (modules) {
                    final level1 = modules.where((m) => m.level == 1).toList()
                      ..sort((a, b) => a.sequence.compareTo(b.sequence));
                    final level2 = modules.where((m) => m.level == 2).toList()
                      ..sort((a, b) => a.sequence.compareTo(b.sequence));
                    return _ModuleList(level1: level1, level2: level2);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleList extends StatelessWidget {
  const _ModuleList({required this.level1, required this.level2});

  final List<LearningModule> level1;
  final List<LearningModule> level2;

  @override
  Widget build(BuildContext context) {
    // Unlock Level 2 when at least 4 of 8 Level 1 modules are completed
    final level1Completed = level1.where((m) => m.isCompleted).length;
    final level2Unlocked = level1Completed >= 4;

    // Build item list:
    // index 0 → Level 1 header
    // index 1 → streak calendar
    // index 2..1+level1.length → Level 1 module cards
    // next → Level 2 header
    // next.. → Level 2 module cards
    final itemCount = 2 + level1.length + 1 + level2.length;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.lg,
        AppSpacing.pagePadding,
        AppSpacing.xxxl,
      ),
      physics: const ScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, i) {
        if (i == 0 || i == 1) return const SizedBox(height: AppSpacing.lg);
        if (i == 1 + level1.length) {
          return const SizedBox(height: AppSpacing.xxl);
        }
        return const SizedBox(height: AppSpacing.listItemSpacing);
      },
      itemBuilder: (context, index) {
        // ── index 0: Level 1 header ────────────────────────────────────
        if (index == 0) {
          return _LevelHeader(
            title: 'I — Foundations',
            subtitle: 'Eight modules on the essentials of Sanatan Dharma.',
            completedCount: level1Completed,
            totalCount: level1.length,
          );
        }

        // ── index 1: streak calendar ───────────────────────────────────
        if (index == 1) return const _StreakCalendar();

        // ── index 2..1+level1.length: Level 1 cards ───────────────────
        if (index <= 1 + level1.length) {
          final moduleIndex = index - 2;
          return _TimelineModuleCard(
            module: level1[moduleIndex],
            showConnector: moduleIndex < level1.length - 1,
          )
              .animate(delay: Duration(milliseconds: moduleIndex * 40))
              .fadeIn(duration: 200.ms)
              .slideY(
                begin: 0.05,
                end: 0,
                duration: 200.ms,
                curve: Curves.easeOutCubic,
              );
        }

        // ── Level 2 header ─────────────────────────────────────────────
        if (index == 2 + level1.length) {
          return _Level2Header(
            completedCount: level2.where((m) => m.isCompleted).length,
            totalCount: level2.length,
            unlocked: level2Unlocked,
            level1Completed: level1Completed,
          );
        }

        // ── Level 2 cards ──────────────────────────────────────────────
        final l2Index = index - (3 + level1.length);
        return _TimelineModuleCard(
          module: level2[l2Index],
          locked: !level2Unlocked,
          showConnector: l2Index < level2.length - 1,
        )
            .animate(delay: Duration(milliseconds: l2Index * 40))
            .fadeIn(duration: 200.ms)
            .slideY(
              begin: 0.05,
              end: 0,
              duration: 200.ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }
}

// ── Timeline module card wrapper ──────────────────────────────────────────
// Draws a 1px connector line from the icon centre downward into the separator
// gap, creating a continuous vertical thread between cards in each level.

class _TimelineModuleCard extends StatelessWidget {
  const _TimelineModuleCard({
    required this.module,
    this.locked = false,
    required this.showConnector,
  });

  final LearningModule module;
  final bool locked;
  final bool showConnector;

  // icon occupies y=[cardPadding .. cardPadding+44]; line starts at icon bottom.
  static const double _lineStartY = AppSpacing.cardPadding + 44; // = 60
  // extend below card bottom to reach next icon centre:
  //   separator(12) + cardPadding(16) + half-icon(22) = 50
  static const double _extendBelow =
      AppSpacing.listItemSpacing + AppSpacing.cardPadding + 22;

  @override
  Widget build(BuildContext context) {
    final card = _ModuleCard(module: module, locked: locked);
    if (!showConnector) return card;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        const Positioned(
          left: AppSpacing.cardPadding + 20,
          top: _lineStartY,
          bottom: -_extendBelow,
          child: SizedBox(
            width: 2,
            child: CustomPaint(painter: _DashedLinePainter()),
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const dashH = 3.0;
    const gapH = 4.0;
    final paint = Paint()
      ..color = AppColors.warmGrey10
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, (y + dashH).clamp(0.0, size.height)),
        paint,
      );
      y += dashH + gapH;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter _) => false;
}

// ── Streak Calendar ───────────────────────────────────────────────────────

class _StreakCalendar extends ConsumerWidget {
  const _StreakCalendar();

  static const double _kCellSize = 32;

  static String _dateString(DateTime date) => '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyAsync = ref.watch(readHistoryProvider);
    final streakAsync = ref.watch(currentStreakProvider);

    final history = historyAsync.value ?? {};
    final streak = streakAsync.value ?? 0;

    final today = DateTime.now();
    final rangeStart = today.subtract(const Duration(days: 29));

    // Align grid to Monday of the week containing rangeStart.
    // weekday: Mon=1 … Sun=7
    final firstMonday =
        rangeStart.subtract(Duration(days: rangeStart.weekday - 1));

    // Build a flat list of nullable days: null = padding cell before rangeStart.
    final gridDays = <DateTime?>[];
    var d = firstMonday;
    while (!d.isAfter(today)) {
      gridDays.add(d.isBefore(rangeStart) ? null : d);
      d = d.add(const Duration(days: 1));
    }
    // Pad tail to a full row of 7.
    while (gridDays.length % 7 != 0) {
      gridDays.add(null);
    }

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  streak > 0
                      ? Icons.local_fire_department_rounded
                      : Icons.local_fire_department_outlined,
                  color:
                      streak >= 7 ? AppColors.saffron : AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  streak > 0 ? '$streak day streak' : 'Start your streak today',
                  style: context.ts.labelMedium.copyWith(
                    color: streak >= 7 ? AppColors.saffron : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: dayLabels
                  .map(
                    (label) => SizedBox(
                      width: _kCellSize,
                      child: Text(
                        label,
                        style: context.ts.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...List.generate(gridDays.length ~/ 7, (rowIndex) {
              final rowDays = gridDays.skip(rowIndex * 7).take(7).toList();
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: rowDays.map((day) {
                    if (day == null) {
                      return const SizedBox(width: _kCellSize, height: _kCellSize);
                    }
                    final dateStr = _dateString(day);
                    final isToday = dateStr == _dateString(today);
                    final wasRead = history.contains(dateStr);
                    return Container(
                      width: _kCellSize,
                      height: _kCellSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: wasRead
                            ? (isDark ? AppColors.saffronOnDark : AppColors.saffron)
                            : Colors.transparent,
                        border: isToday && !wasRead
                            ? Border.all(color: AppColors.saffron)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: context.ts.caption.copyWith(
                          color: wasRead
                              ? (isDark ? AppColors.bgDark : AppColors.cream)
                              : isToday
                                  ? AppColors.saffron
                                  : AppColors.textHint,
                          fontWeight: wasRead || isToday
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Read any verse or complete a module card to fill a day',
              style: context.ts.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Level 1 header ────────────────────────────────────────────────────────

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({
    required this.title,
    required this.subtitle,
    required this.completedCount,
    required this.totalCount,
  });

  final String title;
  final String subtitle;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.ts.sectionLabel,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: context.ts.caption),
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? AppColors.borderDark : AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saffron),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$completedCount of $totalCount completed',
          style: context.ts.caption,
        ),
      ],
    );
  }
}

// ── Level 2 header ────────────────────────────────────────────────────────

class _Level2Header extends StatelessWidget {
  const _Level2Header({
    required this.completedCount,
    required this.totalCount,
    required this.unlocked,
    required this.level1Completed,
  });

  final int completedCount;
  final int totalCount;
  final bool unlocked;
  final int level1Completed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: isDark ? AppColors.dividerDark : AppColors.divider),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Text(
              'II — Deepening',
              style: context.ts.sectionLabel,
            ),
            const SizedBox(width: AppSpacing.sm),
            if (!unlocked)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Locked', style: context.ts.caption),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          unlocked
              ? 'Dive deeper into the primary texts.'
              : 'Complete 4 Foundations modules to begin. ($level1Completed/4 done)',
          style: context.ts.caption,
        ),
        if (unlocked) ...[
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? AppColors.borderDark : AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.saffron),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$completedCount of $totalCount completed',
            style: context.ts.caption,
          ),
        ],
      ],
    );
  }
}

// ── Module icon with progress ring ────────────────────────────────────────

class _ModuleIcon extends StatelessWidget {
  const _ModuleIcon({
    required this.locked,
    required this.isCompleted,
    required this.isStarted,
    required this.progress,
    required this.sequence,
  });

  final bool locked;
  final bool isCompleted;
  final bool isStarted;
  final double progress;
  final int sequence;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (locked) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.borderDark : AppColors.border,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.textSecondary,
          size: 18,
        ),
      );
    }

    if (isCompleted) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.check_rounded,
          color: AppColors.success,
          size: 22,
        ),
      );
    }

    if (isStarted) {
      return SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor: isDark ? AppColors.borderDark : AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.saffron),
              ),
            ),
            Text(
              '$sequence',
              style: context.ts.labelMedium.copyWith(
                color: AppColors.saffron,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.warmGrey10,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        '$sequence',
        style: context.ts.labelLarge.copyWith(
          color: AppColors.warmGrey80,
        ),
      ),
    );
  }
}

// ── Module card ───────────────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, this.locked = false});

  final LearningModule module;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = module.isCompleted;
    final isStarted = module.cardsRead > 0 && !isCompleted;
    final progress =
        module.cardCount > 0 ? module.cardsRead / module.cardCount : 0.0;

    return InkWell(
      onTap: locked
          ? () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Complete 4 Foundations modules to unlock Deepening.',
                  ),
                  duration: Duration(seconds: 2),
                ),
              )
          : () => context.push('/learn/${module.id}'),
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: AnimatedOpacity(
        opacity: locked ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: isCompleted
                  ? AppColors.successMuted
                  : isStarted
                      ? AppColors.saffronBorder
                      : isDark
                          ? AppColors.borderDark
                          : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ModuleIcon(
                locked: locked,
                isCompleted: isCompleted,
                isStarted: isStarted,
                progress: progress,
                sequence: module.sequence,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(module.title, style: context.ts.labelLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      module.hook,
                      style: context.ts.caption,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${module.estimatedMinutes} min',
                          style: context.ts.caption,
                        ),
                        if (isStarted) ...[
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            '${module.cardsRead}/${module.cardCount} cards',
                            style: context.ts.captionHighlight,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                locked
                    ? Icons.lock_outline_rounded
                    : Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
