// lib/presentation/features/home/widgets/learning_progress_summary.dart
//
// Compact learning progress toward CURRENT_SPRINT task 55 (dashboard).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/domain/entities/learning_module.dart';
import 'package:sanatan_guide/presentation/features/learning_path/providers/learning_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class LearningProgressSummary extends ConsumerWidget {
  const LearningProgressSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(modulesProvider);

    return modulesAsync.when(
      loading: () => const LearningProgressShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (Either<Failure, List<LearningModule>> either) => either.fold(
        (_) => const SizedBox.shrink(),
        (List<LearningModule> modules) {
          if (modules.isEmpty) return const SizedBox.shrink();
          final done = modules.where((LearningModule m) => m.isCompleted).length;
          final total = modules.length;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.go('/learn'),
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.borderDark
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 20,
                        color: AppColors.warmGrey50,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Learning · $done of $total modules done',
                          style: context.ts.labelMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'Path',
                        style: context.ts.chipLabel.copyWith(fontSize: 12),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
