import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/verse_detail_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/verse_section_widgets.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// Optional AI-generated "Simple explanation" card for a verse.
///
/// Collapses cleanly to zero-height when no row exists in
/// `verse_explanations` for this id, so it costs nothing when unseeded.
class AiExplanationBlock extends ConsumerStatefulWidget {
  const AiExplanationBlock({super.key, required this.verseId});

  final String verseId;

  @override
  ConsumerState<AiExplanationBlock> createState() =>
      _AiExplanationBlockState();
}

class _AiExplanationBlockState extends ConsumerState<AiExplanationBlock> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(verseExplanationProvider(widget.verseId));
    return async.when(
      data: (exp) {
        if (exp == null) return const SizedBox.shrink();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            0,
            AppSpacing.pagePadding,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              verseSectionDivider(context),
              const SizedBox(height: AppSpacing.md),
              ExpandableSection(
                title: 'Simple explanation',
                expanded: _expanded,
                onToggle: () => setState(() => _expanded = !_expanded),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: AppColors.warmGrey50,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            exp.explanationText,
                            style: context.ts.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'AI-generated. Refer to traditional commentaries '
                      'for authority.',
                      style: context.ts.caption.copyWith(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryOnDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
