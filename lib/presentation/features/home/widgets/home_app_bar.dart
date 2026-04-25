import 'package:flutter/material.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/utils/panchang_utils.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// Custom scrolling header for Temple Dawn home.
///
/// Greeting reads as a calm title; date is a single small line of panchang
/// context. Icon buttons are circular blur-glass so they sit comfortably
/// over the dawn glow without a heavy app bar bar background.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    required this.onSearch,
    required this.onSettings,
  });

  final VoidCallback onSearch;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final greeting = greetingForTimeOfDay(now);
    final hindu = PanchangUtils.getHinduDate(now);

    final dateText =
        '${hindu.monthName} · VS ${hindu.vikramSamvatYear}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                greeting,
                style: context.ts.displayMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: isDark
                      ? AppColors.textOnDark
                      : AppColors.warmGrey80,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                dateText.toUpperCase(),
                style: context.ts.labelSmall.copyWith(
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryOnDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _GlassIconButton(
          icon: Icons.search_outlined,
          tooltip: 'Search verses',
          onTap: onSearch,
        ),
        const SizedBox(width: AppSpacing.sm),
        _GlassIconButton(
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          onTap: onSettings,
        ),
      ],
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.saffronFaint
                  : AppColors.cream.withValues(alpha: 0.55),
              border: Border.all(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.border.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark
                  ? AppColors.textSecondaryOnDark
                  : AppColors.warmGrey50,
            ),
          ),
        ),
      ),
    );
  }
}
