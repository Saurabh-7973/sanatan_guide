import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/router/app_routes.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/domain/entities/learning_module.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/presentation/features/learning_path/providers/learning_provider.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// Learning path card: title + progress count + thin bar + continue row.
///
/// Uses existing `modulesProvider` for path progress and
/// `lastReadVerseProvider` for the continue line. Gracefully degrades if
/// either is empty.
class PathCard extends ConsumerWidget {
  const PathCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final modulesAsync = ref.watch(modulesProvider);
    final lastReadAsync = ref.watch(lastReadVerseProvider);

    final modulesEither = modulesAsync.asData?.value;
    var total = 0;
    var completed = 0;
    modulesEither?.fold(
      (_) {},
      (List<LearningModule> list) {
        total = list.length;
        completed = list.where((LearningModule m) => m.isCompleted).length;
      },
    );
    final progress = total == 0 ? 0.0 : completed / total;

    final accent = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    final surface = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.55)
        : AppColors.surface.withValues(alpha: 0.5);
    final border = isDark
        ? AppColors.saffronOnDark.withValues(alpha: 0.15)
        : AppColors.saffron.withValues(alpha: 0.18);

    final lastRead = lastReadAsync.asData?.value;
    Scripture? scripture;
    if (lastRead != null) {
      try {
        scripture = ScriptureX.fromCode(lastRead.scriptureCode);
      } on ArgumentError {
        scripture = null;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.learningPath),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.cardPadding,
            AppSpacing.md,
            AppSpacing.cardPadding,
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your Path',
                      style: context.ts.titleMedium.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textOnDark
                            : AppColors.warmGrey80,
                      ),
                    ),
                  ),
                  Text(
                    '$completed / $total',
                    style: context.ts.labelSmall.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: accent,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 3,
                  child: Stack(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                        ),
                        child: const SizedBox.expand(),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accent, accent.withValues(alpha: 0.8)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Continue reading row
              if (lastRead != null && scripture != null) ...[
                const SizedBox(height: AppSpacing.md),
                _ContinueRow(
                  label:
                      '${scripture.displayName} · ${_fmt(lastRead.verseId)}',
                  onTap: () => context.push(
                    '/browse/${lastRead.scriptureCode}/verse/${lastRead.verseId}',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _fmt(String id) {
    final parts = id.split('.');
    if (parts.length >= 3) return '${parts[1]}:${parts[2]}';
    if (parts.length >= 2) return parts.sublist(1).join(':');
    return id;
  }
}

class _ContinueRow extends StatelessWidget {
  const _ContinueRow({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.saffronOnDark : AppColors.saffron;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 14,
                color: AppColors.onSaffron,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: context.ts.caption.copyWith(
                    fontSize: 12.5,
                    color: isDark
                        ? AppColors.textSecondaryOnDark
                        : AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'Continue · '),
                    TextSpan(
                      text: label,
                      style: context.ts.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textOnDark
                            : AppColors.warmGrey80,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 11,
              color: isDark
                  ? AppColors.textSecondaryOnDark
                  : AppColors.warmGrey50,
            ),
          ],
        ),
      ),
    );
  }
}
