import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// A warm, bordered surface card — the visual foundation for content cards
/// across search results, bookmarks, and home screen sections.
///
/// Provides ripple-capable tap, optional left accent strip, and automatic
/// light/dark surface + border colors from [AppColors].
class SacredCard extends StatelessWidget {
  const SacredCard({
    super.key,
    required this.child,
    this.onTap,
    this.accentColor,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Optional 4dp left accent border (e.g. saffron for continue-reading).
  final Color? accentColor;

  final EdgeInsetsGeometry padding;

  static const _radius = BorderRadius.all(Radius.circular(AppSpacing.cardRadius));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    final inner = _applyAccent(child, padding);

    return Ink(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: _radius,
        border: Border.all(color: borderColor),
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: _radius,
              child: inner,
            )
          : inner,
    );
  }

  Widget _applyAccent(Widget content, EdgeInsetsGeometry pad) {
    final padded = Padding(padding: pad, child: content);
    if (accentColor == null) return padded;

    return ClipRRect(
      borderRadius: _radius,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accentColor),
            Expanded(child: padded),
          ],
        ),
      ),
    );
  }
}
