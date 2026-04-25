import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/presentation/shared/widgets/sacred_card.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// Unified verse card used by both search results and bookmarks.
///
/// Required: [locationLabel] (e.g. "BG 2.47"), [onTap].
/// Optional enrichment:
///  - [query] — highlights matching text in search context
///  - [isBookmarked] — shows a small bookmark indicator on the badge row
///  - [savedAt] — renders a "Saved …" date line (bookmark mode)
///  - [animateIndex] — enables staggered entry animation (search list)
class VersePreviewTile extends StatelessWidget {
  const VersePreviewTile({
    super.key,
    required this.locationLabel,
    required this.onTap,
    this.sanskritPreview,
    this.englishPreview,
    this.isBookmarked = false,
    this.savedAt,
    this.query = '',
    this.animateIndex,
  });

  final String locationLabel;
  final String? sanskritPreview;
  final String? englishPreview;
  final VoidCallback onTap;
  final bool isBookmarked;
  final DateTime? savedAt;
  final String query;
  final int? animateIndex;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  @override
  Widget build(BuildContext context) {
    final hasText = (sanskritPreview != null && sanskritPreview!.isNotEmpty) ||
        (englishPreview != null && englishPreview!.isNotEmpty);

    Widget tile = SacredCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Badge row ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.saffronFaint,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Text(locationLabel, style: context.ts.captionHighlight),
              ),
              if (isBookmarked) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.bookmark_rounded,
                  size: 14,
                  color: AppColors.saffron.withValues(alpha: 0.6),
                ),
              ],
            ],
          ),

          // ── Sanskrit preview ───────────────────────────────────────────
          if (sanskritPreview != null && sanskritPreview!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _HighlightedText(
              text: sanskritPreview!,
              query: query,
              baseStyle: context.ts.sanskritSmall,
              maxLines: 2,
            ),
          ],

          // ── English preview ────────────────────────────────────────────
          if (englishPreview != null && englishPreview!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            _HighlightedText(
              text: englishPreview!,
              query: query,
              baseStyle: context.ts.caption,
              maxLines: 2,
            ),
          ],

          // ── Saved date (bookmark mode) ─────────────────────────────────
          if (savedAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.event_outlined,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Saved ${_formatDate(savedAt!)}',
                  style: context.ts.caption,
                ),
              ],
            ),
          ],

          // ── Fallback when no text available ────────────────────────────
          if (!hasText && savedAt == null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Text not available for this verse',
              style: context.ts.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );

    if (animateIndex != null) {
      tile = tile
          .animate(
            delay: Duration(milliseconds: animateIndex!.clamp(0, 8) * 40),
          )
          .fadeIn(duration: 200.ms)
          .slideY(
            begin: 0.03,
            end: 0,
            duration: 200.ms,
            curve: Curves.easeOutCubic,
          );
    }

    return tile;
  }
}

// ── Highlighted text ──────────────────────────────────────────────────────

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.baseStyle,
    this.maxLines,
  });

  final String text;
  final String query;
  final TextStyle baseStyle;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final q = query.trim();
    if (q.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQ = q.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (start < text.length) {
      final matchIdx = lowerText.indexOf(lowerQ, start);
      if (matchIdx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (matchIdx > start) {
        spans.add(TextSpan(text: text.substring(start, matchIdx)));
      }
      final matchEnd = matchIdx + q.length;
      spans.add(TextSpan(
        text: text.substring(matchIdx, matchEnd),
        style: baseStyle.copyWith(
          backgroundColor: AppColors.saffron.withValues(alpha: 0.18),
          color: AppColors.saffron,
          fontWeight: FontWeight.w600,
        ),
      ));
      start = matchEnd;
    }

    return RichText(
      text: TextSpan(style: baseStyle, children: spans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );
  }
}
