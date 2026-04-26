import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// Reusable sanctum-style card: surface bg, border, left 3 px saffron accent,
/// optional collapse chevron. Matches direction-sanctum.jsx SanctumCard.
class SanctumCard extends StatefulWidget {
  const SanctumCard({
    super.key,
    required this.title,
    required this.child,
    this.collapsible = false,
    this.initiallyExpanded = true,
    this.headerAction,
  });

  final String title;
  final Widget child;
  final bool collapsible;
  final bool initiallyExpanded;
  final Widget? headerAction;

  @override
  State<SanctumCard> createState() => _SanctumCardState();
}

class _SanctumCardState extends State<SanctumCard> {
  late bool _open;

  @override
  void initState() {
    super.initState();
    _open = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant SanctumCard old) {
    super.didUpdateWidget(old);
    if (old.initiallyExpanded != widget.initiallyExpanded &&
        widget.collapsible) {
      _open = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final saff = isDark ? AppColors.saffronOnDark : AppColors.saffron;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: border),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.collapsible
                ? () => setState(() => _open = !_open)
                : null,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                _open ? AppSpacing.sm : AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      color: saff,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.title.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (widget.headerAction != null) widget.headerAction!,
                  if (widget.collapsible) ...[
                    if (widget.headerAction != null)
                      const SizedBox(width: AppSpacing.xs),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.textSecondaryOnDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: widget.child,
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState:
                _open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
