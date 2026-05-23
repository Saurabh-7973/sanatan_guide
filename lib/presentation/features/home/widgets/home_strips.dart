import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/domain/entities/festival.dart';
import 'package:sanatan_guide/domain/entities/learning_module.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/presentation/features/festivals/providers/festival_provider.dart';
import 'package:sanatan_guide/presentation/features/learning_path/providers/learning_provider.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

/// Continue Reading strip — last-read verse + 8 progress beads.
/// Hidden when no read history.
class ContinueStrip extends ConsumerWidget {
  const ContinueStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lastReadAsync = ref.watch(lastReadVerseProvider);
    final streakAsync = ref.watch(currentStreakProvider);

    final lastRead = lastReadAsync.asData?.value;
    if (lastRead == null) return const SizedBox.shrink();

    Scripture? scripture;
    try {
      scripture = ScriptureX.fromCode(lastRead.scriptureCode);
    } on ArgumentError {
      scripture = null;
    }
    if (scripture == null) return const SizedBox.shrink();

    final streak = streakAsync.asData?.value ?? 0;
    final verseLabel = _formatVerseId(lastRead.verseId, scripture);
    final beadsFilled = _beadFillFor(lastRead.verseId);

    return _StripShell(
      isDark: isDark,
      glyph: _StripGlyph.resume,
      label:
          streak > 0 ? 'CONTINUE  ·  $streak DAY STREAK' : 'CONTINUE READING',
      title: '${scripture.displayName} · $verseLabel',
      progressBeads: beadsFilled,
      onTap: () => context.push(
        '/browse/${lastRead.scriptureCode}/verse/${lastRead.verseId}',
      ),
    );
  }

  /// Convert "BG.1.2" or "1.2" to "1.2" display.
  static String _formatVerseId(String id, Scripture scripture) {
    final parts = id.split('.');
    if (parts.length >= 3) return '${parts[1]}.${parts[2]}';
    if (parts.length >= 2) return parts.sublist(1).join('.');
    return id;
  }

  /// 8 beads — proportional fill within current chapter (heuristic).
  /// Without total-verses-in-chapter data here, show 2 filled by default
  /// when there's history; the spec is "8 beads showing chapter progress",
  /// the exact ratio improves once chapter-progress provider is wired.
  static int _beadFillFor(String verseId) {
    final parts = verseId.split('.');
    if (parts.length >= 3) {
      final v = int.tryParse(parts[2]) ?? 1;
      return (v / 4).clamp(1, 8).round();
    }
    return 2;
  }
}

/// Your Path strip — next pending learning module.
class PathStrip extends ConsumerWidget {
  const PathStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modulesAsync = ref.watch(modulesProvider);

    final either = modulesAsync.asData?.value;
    if (either == null) return const SizedBox.shrink();

    return either.fold(
      (_) => const SizedBox.shrink(),
      (List<LearningModule> list) {
        if (list.isEmpty) return const SizedBox.shrink();
        final next = list.firstWhere(
          (m) => !m.isCompleted,
          orElse: () => list.first,
        );
        // Scope position + total to the next module's section (level), so
        // the strip shows "module 1 of 8" (Foundations) — not "of 17"
        // across all sections, which contradicts Practice and the label.
        final section = list.where((m) => m.level == next.level).toList();
        final position = section.indexOf(next) + 1;
        final completedCount = section.where((m) => m.isCompleted).length;

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: _StripShell(
            isDark: isDark,
            glyph: _StripGlyph.ascent,
            label: 'YOUR PATH  ·  FOUNDATIONS',
            title: next.title,
            meta:
                '${next.estimatedMinutes} min  ·  module $position of ${section.length}',
            completedCount: completedCount,
            onTap: () => context.push('/learn/${next.id}'),
          ),
        );
      },
    );
  }
}

/// Festival pill — moon glyph + Devanāgarī tag + Roman + days countdown.
class FestivalPill extends ConsumerWidget {
  const FestivalPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncFests = ref.watch(festivalsProvider);

    final list = asyncFests.asData?.value ?? const <Festival>[];
    final upcoming = _firstUpcoming(list);
    if (upcoming == null) return const SizedBox.shrink();

    final daysUntil =
        upcoming.date.difference(DateTime.now()).inDays.clamp(0, 9999);
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final surface = isDark ? DColors.surface : LColors.surface;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: GestureDetector(
        onTap: () => context.push('/festivals'),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(Radii.card),
            border: Border.all(color: dividerSoft, width: 1),
          ),
          child: Row(
            children: [
              const _MoonGlyph(),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${upcoming.sanskritName}  ',
                        style: TextStyle(
                          fontFamily: Fonts.deva,
                          fontFamilyFallback: AppFontFallback.deva,
                          fontSize: 13,
                          color: saffron,
                        ),
                      ),
                      TextSpan(
                        text: upcoming.name,
                        style: TextStyle(
                          fontFamily: Fonts.serif,
                          fontFamilyFallback: AppFontFallback.latin,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: text1,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                daysUntil == 0
                    ? 'TODAY'
                    : daysUntil == 1
                        ? '1 DAY'
                        : '$daysUntil DAYS',
                style: TextStyle(
                  fontFamily: Fonts.sans,
                  fontFamilyFallback: AppFontFallback.latin,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.98,
                  color: text3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Festival? _firstUpcoming(List<Festival> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Festival? best;
    for (final f in list) {
      final fDay = DateTime(f.date.year, f.date.month, f.date.day);
      if (fDay.isBefore(today)) continue;
      if (best == null || fDay.isBefore(best.date)) best = f;
    }
    return best;
  }
}

// ============================================================
// _StripShell — shared shell for ContinueStrip + PathStrip
// ============================================================
class _StripShell extends StatelessWidget {
  const _StripShell({
    required this.isDark,
    required this.glyph,
    required this.label,
    required this.title,
    required this.onTap,
    this.meta,
    this.progressBeads,
    this.completedCount,
  });

  final bool isDark;
  final _StripGlyph glyph;
  final String label;
  final String title;
  final String? meta;
  final int? progressBeads;
  final int? completedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final saffronGlow = isDark ? DColors.saffronGlow : LColors.saffronGlow;
    final surface = isDark ? DColors.surface : LColors.surface;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: dividerSoft, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: saffronGlow,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CustomPaint(
                  painter: _StripGlyphPainter(glyph: glyph, color: saffron),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: Fonts.sans,
                      fontFamilyFallback: AppFontFallback.latin,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.09,
                      color: text3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: Fonts.serif,
                      fontFamilyFallback: AppFontFallback.latin,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.075,
                      height: 1.3,
                      color: text1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (meta != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      meta!,
                      style: TextStyle(
                        fontFamily: Fonts.sans,
                        fontFamilyFallback: AppFontFallback.latin,
                        fontSize: 12,
                        color: text2,
                      ),
                    ),
                  ],
                  if (progressBeads != null) ...[
                    const SizedBox(height: 6),
                    _ProgressBeads(
                      filled: progressBeads!,
                      saffron: saffron,
                      empty: dividerSoft,
                    ),
                  ],
                  if (completedCount != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '$completedCount complete',
                      style: TextStyle(
                        fontFamily: Fonts.sans,
                        fontFamilyFallback: AppFontFallback.latin,
                        fontSize: 11,
                        color: text3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: text3,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// _ProgressBeads — 8 beads palm-leaf bead row
// ============================================================
class _ProgressBeads extends StatelessWidget {
  const _ProgressBeads({
    required this.filled,
    required this.saffron,
    required this.empty,
  });

  final int filled;
  final Color saffron;
  final Color empty;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 8; i++) ...[
          Container(
            width: 12,
            height: 2,
            decoration: BoxDecoration(
              color: i < filled ? saffron : empty,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          if (i < 7) const SizedBox(width: 4),
        ],
      ],
    );
  }
}

// ============================================================
// _StripGlyph — the screen-01 strip icons (18-unit viewBox)
// ============================================================
enum _StripGlyph { resume, ascent }

class _StripGlyphPainter extends CustomPainter {
  const _StripGlyphPainter({required this.glyph, required this.color});

  final _StripGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 18.0; // mockup viewBox is 18×18
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * u
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (glyph) {
      case _StripGlyph.resume:
        // M2 3.5h6a3 3 0 0 1 3 3v8  +  M16 3.5h-2a3 3 0 0 0-3 3v8
        final left = Path()
          ..moveTo(2 * u, 3.5 * u)
          ..lineTo(8 * u, 3.5 * u)
          ..arcToPoint(Offset(11 * u, 6.5 * u), radius: Radius.circular(3 * u))
          ..lineTo(11 * u, 14.5 * u);
        final right = Path()
          ..moveTo(16 * u, 3.5 * u)
          ..lineTo(14 * u, 3.5 * u)
          ..arcToPoint(Offset(11 * u, 6.5 * u),
              radius: Radius.circular(3 * u), clockwise: false)
          ..lineTo(11 * u, 14.5 * u);
        canvas
          ..drawPath(left, stroke)
          ..drawPath(right, stroke);
      case _StripGlyph.ascent:
        // M9 2v14  +  M3 9l6-7 6 7  (an up-arrow)
        canvas.drawLine(Offset(9 * u, 2 * u), Offset(9 * u, 16 * u), stroke);
        final chevron = Path()
          ..moveTo(3 * u, 9 * u)
          ..lineTo(9 * u, 2 * u)
          ..lineTo(15 * u, 9 * u);
        canvas.drawPath(chevron, stroke);
    }
  }

  @override
  bool shouldRepaint(_StripGlyphPainter old) =>
      old.color != color || old.glyph != glyph;
}

// ============================================================
// _MoonGlyph — 22 px radial-gradient circle
// ============================================================
class _MoonGlyph extends StatelessWidget {
  const _MoonGlyph();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 0.95,
          colors: isDark
              ? const [
                  Color(0xFFF2E5CE),
                  Color(0xFFD4B896),
                  Color(0xFF6E5641),
                ]
              : const [
                  Color(0xFFFFF8EB),
                  Color(0xFFD9C39A),
                  Color(0xFF8A6E44),
                ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }
}
