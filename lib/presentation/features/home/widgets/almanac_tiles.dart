import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/router/app_routes.dart';
import 'package:sanatan_guide/core/utils/panchang_utils.dart';
import 'package:sanatan_guide/data/festivals/festival_data_2026.dart';
import 'package:sanatan_guide/presentation/features/festivals/providers/festival_provider.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// Three celestial tiles for today's panchang:
///   ☀  Vāra       — sun disc
///   ☾  Tithi      — live lunar phase (shaded circle)
///   ✦  Next parva — mandala, countdown
///
/// Each tile is tappable and preserves existing routes.
class AlmanacTiles extends ConsumerWidget {
  const AlmanacTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final vara = PanchangUtils.getVaraForDate(now);
    final tithi = PanchangUtils.getTithiForDate(now);

    // Upcoming festival (uses existing provider + 2026 fallback).
    final festivalsAsync = ref.watch(festivalsProvider);
    final allFestivals = festivalsAsync.value ?? festivals2026;
    final upcoming = allFestivals
        .where((f) => !f.isPast || f.isToday)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final next = upcoming.isNotEmpty ? upcoming.first : null;
    final todayDate = DateTime(now.year, now.month, now.day);
    final daysUntil = next == null
        ? 0
        : next.date.difference(todayDate).inDays;
    final daysLabel = next == null
        ? '—'
        : next.isToday
            ? 'Today'
            : daysUntil == 1
                ? '1 day'
                : '$daysUntil days';

    // In a sliver / vertically unbounded parent, [CrossAxisAlignment.stretch]
    // forces infinite height on flex children — use [start] so tiles get
    // intrinsic height from their [Column] content.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _AlmanacTile(
            label: 'VĀRA',
            title: vara.varaName,
            sub: _englishDayName(now.weekday),
            icon: const _SunIcon(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _AlmanacTile(
            label: 'TITHI',
            title: tithi.tithiName,
            sub: tithi.paksha,
            icon: _MoonIcon(
              // Map tithi → phase fraction 0..1 where 0=new, 0.5=full.
              // Keep simple: Shukla grows 0→0.5, Krishna shrinks 0.5→1.
              phase: _tithiPhase(tithi.tithiName, tithi.paksha),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _AlmanacTile(
            label: 'NEXT PARVA',
            title: next?.name ?? '—',
            sub: daysLabel,
            icon: const _MandalaIcon(),
            onTap: next == null
                ? null
                : () => context.push(AppRoutes.festivals),
          ),
        ),
      ],
    );
  }

  static String _englishDayName(int weekday) {
    const names = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    return names[(weekday - 1) % 7];
  }

  /// Best-effort phase from tithi name — 1..15 of paksha.
  static double _tithiPhase(String tithiName, String paksha) {
    final map = {
      'pratipada': 1, 'dvitīyā': 2, 'dwitīyā': 2, 'tṛtīyā': 3, 'tritīyā': 3,
      'caturthī': 4, 'chaturthi': 4, 'pañcamī': 5, 'panchami': 5,
      'ṣaṣṭhī': 6, 'shashthi': 6, 'saptamī': 7, 'saptami': 7,
      'aṣṭamī': 8, 'ashtami': 8, 'navamī': 9, 'navami': 9,
      'daśamī': 10, 'dashami': 10, 'ekādaśī': 11, 'ekadashi': 11,
      'dvādaśī': 12, 'dwadashi': 12, 'trayodaśī': 13, 'trayodashi': 13,
      'caturdaśī': 14, 'chaturdashi': 14, 'pūrṇimā': 15, 'purnima': 15,
      'amāvāsyā': 15, 'amavasya': 15,
    };
    final n = map[tithiName.toLowerCase()] ?? 3;
    final isShukla = paksha.toLowerCase().contains('shukla') ||
        paksha.toLowerCase().contains('śukla');
    // Shukla: 0 (new) → 0.5 (full) over 1..15
    // Krishna: 0.5 (full) → 1 (new) over 1..15
    final t = n / 15.0;
    return isShukla ? t * 0.5 : 0.5 + t * 0.5;
  }
}

class _AlmanacTile extends StatelessWidget {
  const _AlmanacTile({
    required this.label,
    required this.title,
    required this.sub,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String title;
  final String sub;
  final Widget icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.55)
        : AppColors.surface.withValues(alpha: 0.5);
    final border = isDark
        ? AppColors.saffronOnDark.withValues(alpha: 0.15)
        : AppColors.saffron.withValues(alpha: 0.18);
    final accent =
        isDark ? AppColors.saffronOnDark : AppColors.saffron;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border, width: 0.5),
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Column(
            children: [
              SizedBox(width: 28, height: 28, child: icon),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: context.ts.labelSmall.copyWith(
                  fontSize: 8.5,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textSecondaryOnDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                title,
                style: context.ts.titleMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textOnDark
                      : AppColors.warmGrey80,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: context.ts.labelSmall.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 9.5,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Icons ──────────────────────────────────────────────────────────

class _SunIcon extends StatelessWidget {
  const _SunIcon();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return CustomPaint(painter: _SunPainter(c));
  }
}

class _SunPainter extends CustomPainter {
  _SunPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // disc
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.2,
      Paint()..color = color,
    );
    // rays
    final rayPaint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round;
    final rOuter = size.width * 0.46;
    final rInner = size.width * 0.3;
    for (int i = 0; i < 8; i++) {
      final a = (i * math.pi) / 4;
      canvas.drawLine(
        Offset(cx + math.cos(a) * rInner, cy + math.sin(a) * rInner),
        Offset(cx + math.cos(a) * rOuter, cy + math.sin(a) * rOuter),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SunPainter old) => old.color != color;
}

class _MoonIcon extends StatelessWidget {
  const _MoonIcon({required this.phase});
  final double phase; // 0=new .. 0.5=full .. 1=new

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return CustomPaint(painter: _MoonPainter(c, phase));
  }
}

class _MoonPainter extends CustomPainter {
  _MoonPainter(this.color, this.phase);
  final Color color;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.34;

    // outline
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = color.withValues(alpha: 0.4)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    // illuminated portion — right side waxes for 0..0.5, wanes for 0.5..1
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));
    final litPaint = Paint()..color = color.withValues(alpha: 0.85);
    if (phase <= 0.5) {
      // waxing — right half fills as phase→0.5
      final w = r * 2 * (phase / 0.5);
      canvas.drawRect(Rect.fromLTWH(cx + r - w, cy - r, w, r * 2), litPaint);
    } else {
      // waning — right half empties as phase→1
      final w = r * 2 * (1 - (phase - 0.5) / 0.5);
      canvas.drawRect(Rect.fromLTWH(cx - r, cy - r, w, r * 2), litPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MoonPainter old) =>
      old.color != color || old.phase != phase;
}

class _MandalaIcon extends StatelessWidget {
  const _MandalaIcon();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return CustomPaint(painter: _MandalaPainter(c));
  }
}

class _MandalaPainter extends CustomPainter {
  _MandalaPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final stroke = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(cx, cy), size.width * 0.34, stroke);
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.2,
      Paint()
        ..color = color.withValues(alpha: 0.45)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.06,
      Paint()..color = color,
    );
    // four cardinal ticks
    final tick = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final a = (i * math.pi) / 2;
      canvas.drawLine(
        Offset(cx + math.cos(a) * size.width * 0.38,
            cy + math.sin(a) * size.width * 0.38),
        Offset(cx + math.cos(a) * size.width * 0.46,
            cy + math.sin(a) * size.width * 0.46),
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MandalaPainter old) => old.color != color;
}
