// lib/presentation/features/home/widgets/streak_calendar.dart
//
// GitHub-style contribution grid: weeks as columns, weekdays as rows.
// Uses the same date keys as [StreakService] read history.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class StreakCalendar extends ConsumerWidget {
  const StreakCalendar({super.key});

  static const int _visiblePastDays = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(readHistoryProvider);

    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (Set<String> history) {
        if (history.isEmpty) return const SizedBox.shrink();

        final today = _dateOnly(DateTime.now());
        final oldest = today.subtract(const Duration(days: _visiblePastDays - 1));
        final material = MaterialLocalizations.of(context);
        final firstDayIndex = material.firstDayOfWeekIndex;

        final gridStart = _startOfWeek(oldest, firstDayIndex);
        final gridEnd = _endOfWeek(today, firstDayIndex);
        final totalDays = gridEnd.difference(gridStart).inDays + 1;
        final columnCount = totalDays ~/ 7;

        final readDaysInWindow = history.where((key) {
          try {
            final d = DateTime.parse(key);
            return !d.isBefore(oldest) && !d.isAfter(today);
          } catch (_) {
            return false;
          }
        }).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeatmapHeader(
              readDaysInWindow: readDaysInWindow,
              windowDays: _visiblePastDays,
            ),
            const SizedBox(height: AppSpacing.sm),
            _HeatmapGrid(
              gridStart: gridStart,
              columnCount: columnCount,
              oldest: oldest,
              today: today,
              history: history,
              narrowWeekdays: material.narrowWeekdays,
              firstDayOfWeekIndex: firstDayIndex,
            ),
            const SizedBox(height: AppSpacing.xs),
            const _HeatmapLegend(),
          ],
        );
      },
    );
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _startOfWeek(DateTime date, int materialFirstDayOfWeekIndex) {
  final d = _dateOnly(date);
  final materialFromSunday = d.weekday == DateTime.sunday ? 0 : d.weekday;
  final delta =
      (materialFromSunday - materialFirstDayOfWeekIndex + 7) % 7;
  return d.subtract(Duration(days: delta));
}

DateTime _endOfWeek(DateTime date, int materialFirstDayOfWeekIndex) {
  final start = _startOfWeek(date, materialFirstDayOfWeekIndex);
  return start.add(const Duration(days: 6));
}

class _HeatmapHeader extends StatelessWidget {
  const _HeatmapHeader({
    required this.readDaysInWindow,
    required this.windowDays,
  });

  final int readDaysInWindow;
  final int windowDays;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'READING ACTIVITY',
          style: context.ts.caption.copyWith(
            letterSpacing: 2.0,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          '$readDaysInWindow / $windowDays days',
          style: context.ts.caption.copyWith(
            color: AppColors.saffron,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({
    required this.gridStart,
    required this.columnCount,
    required this.oldest,
    required this.today,
    required this.history,
    required this.narrowWeekdays,
    required this.firstDayOfWeekIndex,
  });

  final DateTime gridStart;
  final int columnCount;
  final DateTime oldest;
  final DateTime today;
  final Set<String> history;
  final List<String> narrowWeekdays;
  final int firstDayOfWeekIndex;

  static const double _cell = 11;
  static const double _gap = 3;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelStyle = context.ts.caption.copyWith(
      fontSize: 9,
      height: 1,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          child: Column(
            children: List.generate(7, (row) {
              final labelIndex = (firstDayOfWeekIndex + row) % 7;
              final label = narrowWeekdays[labelIndex];
              return SizedBox(
                height: _cell + _gap,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(label, style: labelStyle),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final naturalWidth =
                  columnCount * (_cell + _gap) - _gap;
              final useScroll = naturalWidth > maxWidth + 0.5;

              final grid = Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(columnCount, (col) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: col == columnCount - 1 ? 0 : _gap,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(7, (row) {
                        final index = col * 7 + row;
                        final day = gridStart.add(Duration(days: index));
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: row == 6 ? 0 : _gap,
                          ),
                          child: _HeatmapCell(
                            day: day,
                            oldest: oldest,
                            today: today,
                            wasRead: history.contains(
                              StreakService.formatReadDateKey(day),
                            ),
                            isDark: isDark,
                          ),
                        );
                      }),
                    ),
                  );
                }),
              );

              if (!useScroll) {
                return Align(alignment: Alignment.centerLeft, child: grid);
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: grid,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.day,
    required this.oldest,
    required this.today,
    required this.wasRead,
    required this.isDark,
  });

  final DateTime day;
  final DateTime oldest;
  final DateTime today;
  final bool wasRead;
  final bool isDark;

  static const double _size = _HeatmapGrid._cell;
  static const BorderRadius _radius =
      BorderRadius.all(Radius.circular(3));

  @override
  Widget build(BuildContext context) {
    final isToday =
        StreakService.formatReadDateKey(day) ==
            StreakService.formatReadDateKey(today);
    final beforeWindow = day.isBefore(oldest);
    final afterToday = day.isAfter(today);

    if (beforeWindow || afterToday) {
      return SizedBox(
        width: _size,
        height: _size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: afterToday
                ? (isDark
                    ? AppColors.surfaceHighest.withValues(alpha: 0.35)
                    : AppColors.surfaceVariant.withValues(alpha: 0.45))
                : Colors.transparent,
            borderRadius: _radius,
          ),
        ),
      );
    }

    if (wasRead) {
      return Tooltip(
        message: StreakService.formatReadDateKey(day),
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: AppColors.saffron.withValues(alpha: isToday ? 1.0 : 0.78),
            borderRadius: _radius,
            border: isToday
                ? Border.all(
                    color: isDark ? AppColors.saffronOnDark : AppColors.saffron,
                    width: 1.5,
                  )
                : null,
          ),
        ),
      );
    }

    final missedColor = isDark
        ? AppColors.surfaceHighest
        : AppColors.surfaceVariant;

    return Tooltip(
      message: StreakService.formatReadDateKey(day),
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: isToday ? Colors.transparent : missedColor,
          borderRadius: _radius,
          border: isToday
              ? Border.all(
                  color: isDark
                      ? AppColors.textSecondaryOnDark
                      : AppColors.textSecondary,
                  width: 1.5,
                )
              : null,
        ),
      ),
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Less', style: context.ts.caption.copyWith(fontSize: 10)),
        const SizedBox(width: AppSpacing.sm),
        const _LegendDot(filled: false),
        const SizedBox(width: 4),
        const _LegendDot(filled: true, alpha: 0.35),
        const SizedBox(width: 4),
        const _LegendDot(filled: true, alpha: 0.65),
        const SizedBox(width: 4),
        const _LegendDot(filled: true, alpha: 1.0),
        const SizedBox(width: AppSpacing.sm),
        Text('More', style: context.ts.caption.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.filled, this.alpha = 1.0});

  final bool filled;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.surfaceHighest : AppColors.surfaceVariant;

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: filled
            ? AppColors.saffron.withValues(alpha: alpha)
            : base,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
