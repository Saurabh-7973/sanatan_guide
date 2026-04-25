import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/domain/entities/commentary.dart';
import 'package:sanatan_guide/l10n/generated/app_localizations.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/verse_detail_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/commentary_formatting.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/verse_section_widgets.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// Scholarly commentary section shown below the translation on verse detail.
///
/// Invisible when no rows are seeded for [verseId]. Each row becomes a
/// collapsible card stamped with translator + license so the user knows
/// the provenance at a glance.
class CommentariesBlock extends ConsumerStatefulWidget {
  const CommentariesBlock({super.key, required this.verseId});

  final String verseId;

  @override
  ConsumerState<CommentariesBlock> createState() =>
      _CommentariesBlockState();
}

class _CommentariesBlockState extends ConsumerState<CommentariesBlock> {
  final Set<String> _expanded = <String>{};

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(verseCommentariesProvider(widget.verseId));
    return async.when(
      data: (rows) {
        if (rows.isEmpty) return const SizedBox.shrink();
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
              for (final c in rows)
                _CommentaryCard(
                  commentary: c,
                  expanded: _expanded.contains(c.id),
                  onToggle: () => setState(() {
                    _expanded.contains(c.id)
                        ? _expanded.remove(c.id)
                        : _expanded.add(c.id);
                  }),
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

class _CommentaryCard extends StatelessWidget {
  const _CommentaryCard({
    required this.commentary,
    required this.expanded,
    required this.onToggle,
  });

  final Commentary commentary;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ExpandableSection(
        title: '${commentary.author} · '
            '${commentaryTraditionLabel(commentary.tradition, l10n)}',
        expanded: expanded,
        onToggle: onToggle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((commentary.textSanskrit ?? '').isNotEmpty) ...[
              Text(
                commentary.textSanskrit!,
                style: context.ts.bodyMedium.copyWith(height: 1.6),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if ((commentary.textEnglish ?? '').isNotEmpty)
              Text(
                commentary.textEnglish!,
                style: context.ts.bodyMedium,
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              commentaryProvenanceLine(commentary, l10n),
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
    );
  }
}
