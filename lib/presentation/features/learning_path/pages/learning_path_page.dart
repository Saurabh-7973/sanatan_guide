// lib/presentation/features/learning_path/pages/learning_path_page.dart
//
// Your Path — the practice / learning-path screen (S8). Heritage restyle to
// New Design/screen-12-practice.html: in-content header, compressed 7-day
// streak strip (full history in a calendar sheet), sūtra-numbered section
// headers, a "Continue your path" anchor, knot-threaded module rows, and a
// dashed Mastery horizon. All providers and progression logic are preserved.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/domain/entities/learning_module.dart';
import 'package:sanatan_guide/presentation/features/learning_path/providers/learning_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';
import 'package:sanatan_guide/presentation/shared/widgets/mockup_icons.dart';

/// Level 1 completions required to unlock Level 2 (Deepening). Preserved
/// verbatim from the pre-restyle screen.
const int _kDeepeningUnlockThreshold = 4;

String _ymd(DateTime d) => '${d.year}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

class LearningPathPage extends ConsumerWidget {
  const LearningPathPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(modulesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SafeArea(
            child: state.when(
              loading: () => const LearningPathShimmer(),
              error: (_, __) => ErrorStateWidget(
                onRetry: () => ref.invalidate(modulesProvider),
              ),
              data: (either) => either.fold(
                (failure) => ErrorStateWidget(message: failure.message),
                (modules) => _PathBody(modules: modules),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathBody extends StatelessWidget {
  const _PathBody({required this.modules});

  final List<LearningModule> modules;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final foundations = modules.where((m) => m.level == 1).toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final deepening = modules.where((m) => m.level == 2).toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    final foundationsDone = foundations.where((m) => m.isCompleted).length;
    final deepeningUnlocked = foundationsDone >= _kDeepeningUnlockThreshold;

    // The single "next up" module: first incomplete one in an unlocked
    // section. Drives both the active-row styling and the Continue anchor.
    LearningModule? active;
    for (final m in foundations) {
      if (!m.isCompleted) {
        active = m;
        break;
      }
    }
    if (active == null && deepeningUnlocked) {
      for (final m in deepening) {
        if (!m.isCompleted) {
          active = m;
          break;
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        const _PathHeader(),
        const _StreakStrip(),
        _SectionHeader(
          isDark: isDark,
          marker: 'I.',
          name: 'Foundations',
          description:
              'Eight modules on the essentials of Sanātana Dharma.',
          completed: foundationsDone,
          total: foundations.length,
          locked: false,
        ),
        if (active != null && active.level == 1)
          _ContinueAnchor(
            isDark: isDark,
            module: active,
            ordinal: active.sequence,
            total: foundations.length,
          ),
        _ModuleList(
          isDark: isDark,
          modules: foundations,
          locked: false,
          activeId: active?.id,
        ),
        _SectionHeader(
          isDark: isDark,
          marker: 'II.',
          name: 'Deepening',
          description:
              'The primary scriptures, in their structure — Vedas, '
              'Upaniṣads, the Gītā in full.',
          completed: deepening.where((m) => m.isCompleted).length,
          total: deepening.length,
          locked: !deepeningUnlocked,
          lockedMeta: deepeningUnlocked
              ? null
              : 'Complete ${_kDeepeningUnlockThreshold - foundationsDone} '
                  'more',
        ),
        if (active != null && active.level == 2)
          _ContinueAnchor(
            isDark: isDark,
            module: active,
            ordinal: active.sequence,
            total: deepening.length,
          ),
        _ModuleList(
          isDark: isDark,
          modules: deepening,
          locked: !deepeningUnlocked,
          activeId: active?.id,
        ),
        _Horizon(isDark: isDark),
      ],
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _PathHeader extends StatelessWidget {
  const _PathHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Path', style: AppText.screenTitle(color: text1)),
          const SizedBox(height: 4),
          Text(
            'A guided journey through the foundations of Sanātana Dharma.',
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontStyle: FontStyle.italic,
              fontSize: 13.5,
              height: 1.4,
              color: text2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Streak strip ───────────────────────────────────────────────────────────

class _StreakStrip extends ConsumerWidget {
  const _StreakStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? DColors.surface : LColors.surface;
    final divider = isDark ? DColors.divider : LColors.divider;
    final glow = isDark ? DColors.saffronGlow : LColors.saffronGlow;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    final history = ref.watch(readHistoryProvider).value ?? const <String>{};
    final streak = ref.watch(currentStreakProvider).value ?? 0;

    final today = DateTime.now();
    final monday = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      child: InkWell(
        onTap: () => _openCalendar(context),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: divider),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(color: glow, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  '🔥',
                  style: TextStyle(
                    fontSize: 14,
                    color: streak > 0 ? null : text3,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: '$streak ',
                          style: TextStyle(
                            fontFamily: Fonts.serif,
                            fontFamilyFallback: AppFontFallback.latin,
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            // Mockup `.streak-count .num` is saffron, not
                            // text1 — the number is the saffron-coloured
                            // anchor that makes the row read as a streak.
                            color: isDark ? DColors.saffron : LColors.saffron,
                          ),
                        ),
                        TextSpan(
                          text: streak == 1
                              ? 'day streak · this week'
                              : 'days streak · this week',
                          style: TextStyle(
                            fontFamily: Fonts.sans,
                            fontFamilyFallback: AppFontFallback.latin,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: text1,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        for (var i = 0; i < 7; i++)
                          Expanded(
                            child: _WeekDot(
                              isDark: isDark,
                              label: labels[i],
                              date: monday.add(Duration(days: i)),
                              today: today,
                              history: history,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              MockupRowChevron(color: text3),
            ],
          ),
        ),
      ),
    );
  }

  void _openCalendar(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CalendarSheet(),
    );
  }
}

class _WeekDot extends StatelessWidget {
  const _WeekDot({
    required this.isDark,
    required this.label,
    required this.date,
    required this.today,
    required this.history,
  });

  final bool isDark;
  final String label;
  final DateTime date;
  final DateTime today;
  final Set<String> history;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final divider = isDark ? DColors.divider : LColors.divider;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    final t = DateTime(today.year, today.month, today.day);
    final isToday = date == t;
    final isFuture = date.isAfter(t);
    final wasRead = history.contains(_ymd(date));

    final Color dotColor;
    final Border? border;
    if (wasRead) {
      dotColor = saffron;
      border = null;
    } else if (isToday) {
      dotColor = Colors.transparent;
      border = Border.all(color: saffron, width: 1.5);
    } else if (isFuture) {
      dotColor = divider.withValues(alpha: 0.4);
      border = null;
    } else {
      dotColor = divider;
      border = null;
    }

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: Fonts.sans,
            fontFamilyFallback: AppFontFallback.latin,
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.48,
            color: text3,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: dotColor, shape: BoxShape.circle, border: border),
        ),
      ],
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.isDark,
    required this.marker,
    required this.name,
    required this.description,
    required this.completed,
    required this.total,
    required this.locked,
    this.lockedMeta,
  });

  final bool isDark;
  final String marker;
  final String name;
  final String description;
  final int completed;
  final int total;
  final bool locked;
  final String? lockedMeta;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;
    final threadLocked = isDark ? DColors.threadLocked : LColors.threadLocked;

    final progress = total > 0 ? completed / total : 0.0;
    final allDone = total > 0 && completed == total;
    final status = locked
        ? null
        : allDone
            ? 'Complete'
            : completed > 0
                ? 'In progress'
                : 'Not started';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                marker,
                style: TextStyle(
                  fontFamily: Fonts.serif,
                  fontFamilyFallback: AppFontFallback.latin,
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: saffron,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: TextStyle(
                  fontFamily: Fonts.serif,
                  fontFamilyFallback: AppFontFallback.latin,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.18,
                  color: text1,
                ),
              ),
              const Spacer(),
              if (locked)
                _LockPill(isDark: isDark)
              else
                Text(status!, style: AppText.sectionLabel(color: text3)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontStyle: FontStyle.italic,
              fontSize: 13,
              height: 1.45,
              color: text2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 1.5,
                    backgroundColor: divider,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      locked ? threadLocked : saffron,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                lockedMeta ?? '$completed / $total',
                style: AppText.sectionLabel(color: text3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LockPill extends StatelessWidget {
  const _LockPill({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final surface2 = isDark ? DColors.surface2 : LColors.surface2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: surface2,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline_rounded, size: 10, color: text3),
          const SizedBox(width: 4),
          Text('LOCKED', style: AppText.sectionLabel(color: text3)),
        ],
      ),
    );
  }
}

// ── Continue anchor ────────────────────────────────────────────────────────

class _ContinueAnchor extends StatelessWidget {
  const _ContinueAnchor({
    required this.isDark,
    required this.module,
    required this.ordinal,
    required this.total,
  });

  final bool isDark;
  final LearningModule module;
  final int ordinal;
  final int total;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? DColors.surface : LColors.surface;
    final divider = isDark ? DColors.divider : LColors.divider;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
      child: InkWell(
        onTap: () => context.push('/learn/${module.id}'),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: divider),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 56,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: saffron,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 19),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONTINUE YOUR PATH',
                        style: AppText.sectionLabel(color: saffron),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        module.title,
                        style: TextStyle(
                          fontFamily: Fonts.serif,
                          fontFamilyFallback: AppFontFallback.latin,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                          color: text1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Module $ordinal of $total · '
                        '${module.estimatedMinutes} min',
                        style: TextStyle(
                          fontFamily: Fonts.sans,
                          fontFamilyFallback: AppFontFallback.latin,
                          fontSize: 11,
                          height: 1.3,
                          color: text2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 16, color: saffron),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Module list ────────────────────────────────────────────────────────────

class _ModuleList extends StatelessWidget {
  const _ModuleList({
    required this.isDark,
    required this.modules,
    required this.locked,
    required this.activeId,
  });

  final bool isDark;
  final List<LearningModule> modules;
  final bool locked;
  final String? activeId;

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) return const SizedBox.shrink();

    final divider = isDark ? DColors.divider : LColors.divider;
    final threadLocked = isDark ? DColors.threadLocked : LColors.threadLocked;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        children: [
          // The binding thread — a hairline behind the knots.
          Positioned(
            left: 6,
            top: 8,
            bottom: 8,
            child: Container(width: 1, color: locked ? threadLocked : divider),
          ),
          Column(
            children: [
              for (var i = 0; i < modules.length; i++)
                _ModuleRow(
                  isDark: isDark,
                  module: modules[i],
                  locked: locked,
                  isActive: modules[i].id == activeId,
                  showDivider: i != modules.length - 1,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({
    required this.isDark,
    required this.module,
    required this.locked,
    required this.isActive,
    required this.showDivider,
  });

  final bool isDark;
  final LearningModule module;
  final bool locked;
  final bool isActive;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final threadLocked = isDark ? DColors.threadLocked : LColors.threadLocked;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;

    final done = module.isCompleted;

    // Knot fill follows the row state.
    final Color knotColor;
    if (locked) {
      knotColor = threadLocked;
    } else if (done || isActive) {
      knotColor = saffron;
    } else {
      knotColor = text3;
    }

    final titleColor = locked
        ? text1.withValues(alpha: 0.62)
        : done
            ? text2
            : text1;
    final metaText = done
        ? '${module.estimatedMinutes} min · completed'
        : isActive
            ? '${module.estimatedMinutes} min · next up'
            : '${module.estimatedMinutes} min';

    // Mockup `.module-row.locked` uses per-element opacity (title 0.62,
    // desc 0.5, meta 0.5, num 0.4) rather than a single wrapping Opacity.
    // Applying alpha at each Text gives more granular contrast: title
    // stays legible while desc/meta/num recede.
    return InkWell(
        onTap: locked
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Complete more Foundations modules to unlock Deepening.',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                )
            : () => context.push('/learn/${module.id}'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(bottom: BorderSide(color: dividerSoft))
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Knot — a 12px diamond riding the thread.
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  width: 13,
                  child: Center(
                    child: Transform.rotate(
                      angle: 0.7853981633974483, // 45°
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: knotColor,
                          boxShadow: isActive && !locked
                              ? [
                                  BoxShadow(
                                    color: saffron.withValues(alpha: 0.55),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 22,
                child: Text(
                  '${module.sequence}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    color: locked
                        ? text3.withValues(alpha: 0.4)
                        : done
                            ? text3
                            : text2,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: TextStyle(
                        fontFamily: Fonts.serif,
                        fontFamilyFallback: AppFontFallback.latin,
                        fontSize: 15.5,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        height: 1.3,
                        letterSpacing: -0.08,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.hook,
                      style: TextStyle(
                        fontFamily: Fonts.serif,
                        fontFamilyFallback: AppFontFallback.latin,
                        fontStyle: FontStyle.italic,
                        fontSize: 12.5,
                        height: 1.45,
                        color: locked
                            ? text2.withValues(alpha: 0.5)
                            : text2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      metaText,
                      style: TextStyle(
                        fontFamily: Fonts.sans,
                        fontFamilyFallback: AppFontFallback.latin,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.06,
                        color: locked
                            ? text3.withValues(alpha: 0.5)
                            : text3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 16,
                child: _ModuleStateIcon(
                  done: done,
                  active: isActive,
                  locked: locked,
                  saffron: saffron,
                  text2: text2,
                  text3: text3,
                ),
              ),
            ],
          ),
        ),
      );
  }
}

class _ModuleStateIcon extends StatelessWidget {
  const _ModuleStateIcon({
    required this.done,
    required this.active,
    required this.locked,
    required this.saffron,
    required this.text2,
    required this.text3,
  });

  final bool done;
  final bool active;
  final bool locked;
  final Color saffron;
  final Color text2;
  final Color text3;

  @override
  Widget build(BuildContext context) {
    if (locked) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Icon(Icons.lock_outline_rounded, size: 12, color: text3),
      );
    }
    if (done) {
      return Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Icon(Icons.check_circle_outline_rounded,
            size: 15, color: text2),
      );
    }
    if (active) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: MockupRowChevron(color: saffron),
      );
    }
    return const SizedBox.shrink();
  }
}

// ── Mastery horizon ────────────────────────────────────────────────────────

class _Horizon extends StatelessWidget {
  const _Horizon({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final divider = isDark ? DColors.divider : LColors.divider;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      padding: const EdgeInsets.fromLTRB(22, 18, 20, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: divider,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('THEN', style: AppText.sectionLabel(color: text3)),
          const SizedBox(height: 6),
          Text(
            'III. Mastery',
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontStyle: FontStyle.italic,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.3,
              color: text1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The Itihāsa-Purāṇa corpus, the six Darśanas, and the '
            'philosophical schools — when you are ready.',
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontStyle: FontStyle.italic,
              fontSize: 12.5,
              height: 1.5,
              color: text2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Calendar bottom sheet (full read history) ──────────────────────────────

class _CalendarSheet extends ConsumerWidget {
  const _CalendarSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? DColors.bg : LColors.bg;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final divider = isDark ? DColors.divider : LColors.divider;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    final history = ref.watch(readHistoryProvider).value ?? const <String>{};
    final streak = ref.watch(currentStreakProvider).value ?? 0;

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final rangeStart = today.subtract(const Duration(days: 29));
    final firstMonday =
        rangeStart.subtract(Duration(days: rangeStart.weekday - 1));

    final gridDays = <DateTime?>[];
    var d = firstMonday;
    while (!d.isAfter(today)) {
      gridDays.add(d.isBefore(rangeStart) ? null : d);
      d = d.add(const Duration(days: 1));
    }
    while (gridDays.length % 7 != 0) {
      gridDays.add(null);
    }
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: dividerSoft,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Text('Your reading days',
                    style: AppText.sectionName(color: text1)),
                const Spacer(),
                Text(
                  streak > 0 ? '$streak day streak' : 'No streak yet',
                  style: AppText.sectionLabel(
                      color: streak >= 7 ? saffron : text3),
                ),
              ],
            ),
          ),
          // The calendar grid stretches edge-to-edge inside the sheet so
          // the cells get the full sheet width. The old fixed-cell layout
          // (34 px columns) left the grid cramped on the left half of the
          // sheet — user-reported "calendar is not expanding to the whole
          // bottom sheet in width".
          Row(
            children: [
              for (final l in labels)
                Expanded(
                  child: Text(
                    l,
                    textAlign: TextAlign.center,
                    style: AppText.sectionLabel(color: text3),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (var row = 0; row < gridDays.length ~/ 7; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  for (final day in gridDays.skip(row * 7).take(7))
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: day == null
                            ? const SizedBox.shrink()
                            : _CalendarCell(
                                day: day,
                                today: today,
                                read: history.contains(_ymd(day)),
                                saffron: saffron,
                                divider: divider,
                                text1: text1,
                                text3: text3,
                              ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Read any verse or complete a module card to fill a day.',
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontStyle: FontStyle.italic,
              fontSize: 12,
              height: 1.4,
              color: text2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.day,
    required this.today,
    required this.read,
    required this.saffron,
    required this.divider,
    required this.text1,
    required this.text3,
  });

  final DateTime day;
  final DateTime today;
  final bool read;
  final Color saffron;
  final Color divider;
  final Color text1;
  final Color text3;

  @override
  Widget build(BuildContext context) {
    final isToday = day == today;
    return Center(
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: read ? saffron : Colors.transparent,
          border: isToday && !read ? Border.all(color: saffron) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontFamily: Fonts.sans,
            fontFamilyFallback: AppFontFallback.latin,
            fontSize: 11,
            fontWeight: read || isToday ? FontWeight.w600 : FontWeight.w400,
            color: read
                ? (Theme.of(context).brightness == Brightness.dark
                    ? DColors.bg
                    : LColors.bg)
                : isToday
                    ? saffron
                    : text3,
          ),
        ),
      ),
    );
  }
}
