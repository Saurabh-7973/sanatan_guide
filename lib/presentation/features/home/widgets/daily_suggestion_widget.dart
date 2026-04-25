// lib/presentation/features/home/widgets/daily_suggestion_widget.dart
//
// Home "what to read today" chip (Panchang weekday theme + experience level hint).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/utils/daily_reading_suggestion_resolver.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/domain/entities/user_experience_level.dart';
import 'package:sanatan_guide/presentation/features/onboarding/providers/user_experience_level_provider.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class DailySuggestionWidget extends ConsumerWidget {
  const DailySuggestionWidget({super.key});

  static String? _levelHint(UserExperienceLevel level) => switch (level) {
        UserExperienceLevel.beginner =>
          'Tip: tap the verse — try reading modes in the toolbar for a simpler layout.',
        UserExperienceLevel.regular => null,
        UserExperienceLevel.scholar =>
          'Tip: use the verse toolbar for modes and deeper study tools.',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestion = dailyReadingSuggestionFor(DateTime.now());
    final level = ref.watch(userExperienceLevelProvider);
    final hint = _levelHint(level);
    final path = browseVersePath(
      scriptureCode: suggestion.scriptureCode,
      verseId: suggestion.verseId,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(path),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.warmGrey10,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: AppColors.borderFaint,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WHAT TO READ TODAY',
                style: context.ts.caption.copyWith(
                  letterSpacing: 2.0,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_stories_outlined,
                    size: 22,
                    color: AppColors.warmGrey50,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.title,
                          style: context.ts.labelLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          suggestion.subtitle,
                          style: context.ts.caption.copyWith(height: 1.35),
                        ),
                        if (hint != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            hint,
                            style: context.ts.caption.copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.ts.caption.color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
