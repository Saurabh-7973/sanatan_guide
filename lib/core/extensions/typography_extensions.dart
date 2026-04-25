import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_typography.dart';

/// Theme-aware typography. Use [context.ts] instead of [AppTypography]
/// directly in widgets so styles adapt to light and dark mode automatically.
///
/// Usage:
///   Text(verse.sanskrit, style: context.ts.sanskritMedium)
///   Text(label, style: context.ts.caption)
extension TypographyX on BuildContext {
  AppTextStyles get ts => AppTextStyles(
        isDark: Theme.of(this).brightness == Brightness.dark,
      );
}

/// Resolved text styles for the current brightness.
/// All Sanskrit/Hindi/English content styles adapt automatically.
final class AppTextStyles {
  final bool isDark;
  const AppTextStyles({required this.isDark});

  // ── Sanskrit ──────────────────────────────────────────────────────────
  // Sanskrit always renders on a card surface.
  // Dark mode: warm cream. Light mode: deep warm brown.

  TextStyle get sanskritLarge => AppTypography.sanskritLarge.copyWith(
        color: isDark ? AppColors.sanskritTextOnDark : AppColors.sanskritText,
      );

  TextStyle get sanskritMedium => AppTypography.sanskritMedium.copyWith(
        color: isDark ? AppColors.sanskritTextOnDark : AppColors.sanskritText,
      );

  TextStyle get sanskritSmall => AppTypography.sanskritSmall.copyWith(
        color: isDark ? AppColors.sanskritTextOnDark : AppColors.sanskritText,
      );

  // ── IAST Transliteration ──────────────────────────────────────────────
  TextStyle get transliteration => AppTypography.transliteration.copyWith(
        color: isDark ? const Color(0xFFBBAA90) : AppColors.translitText,
      );

  // ── Hindi ────────────────────────────────────────────────────────────
  TextStyle get hindiLarge => AppTypography.hindiLarge.copyWith(
        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
      );

  TextStyle get hindiBody => AppTypography.hindiBody.copyWith(
        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
      );

  // ── English display headings ──────────────────────────────────────────
  TextStyle get displayLarge => AppTypography.displayLarge.copyWith(
        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
      );

  TextStyle get displayMedium => AppTypography.displayMedium.copyWith(
        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
      );

  // ── Missing type-scale middle ─────────────────────────────────────────
  TextStyle get titleLarge => AppTypography.titleLarge.copyWith(
        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
      );

  TextStyle get titleMedium => AppTypography.titleMedium.copyWith(
        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
      );

  TextStyle get labelXLarge => AppTypography.labelXLarge.copyWith(
        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
      );

  // ── English body ──────────────────────────────────────────────────────
  TextStyle get bodyLarge => AppTypography.bodyLarge.copyWith(
        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
      );

  TextStyle get bodyMedium => AppTypography.bodyMedium.copyWith(
        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
      );

  // ── UI labels ─────────────────────────────────────────────────────────
  TextStyle get labelLarge => AppTypography.labelLarge.copyWith(
        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
      );

  TextStyle get labelMedium => AppTypography.labelMedium.copyWith(
        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
      );

  // labelSmall — badges, verse counts, dense meta text (12sp Outfit w500)
  TextStyle get labelSmall => AppTypography.labelSmall.copyWith(
        color: isDark ? AppColors.textSecondaryOnDark : AppColors.textSecondary,
      );

  // ── Caption ───────────────────────────────────────────────────────────
  TextStyle get caption => AppTypography.caption.copyWith(
        color: isDark ? AppColors.textSecondaryOnDark : AppColors.textSecondary,
      );

  // ── Semantic variants ─────────────────────────────────────────────────

  /// Section header labels: DAILY PRACTICE, TODAY, STREAK…
  /// Usage: `Text('TODAY', style: context.ts.sectionLabel)`
  // Section labels are navigation aids, not sacred elements — warmGrey, not saffron.
  TextStyle get sectionLabel => AppTypography.sectionLabel.copyWith(
        color: isDark ? AppColors.textSecondaryOnDark : AppColors.warmGrey50,
      );

  /// Card-type labels: KEY VERSE, ANCHOR, CONTENT… (saffron, always)
  TextStyle get cardLabel => AppTypography.cardLabel;

  /// Highlighted caption: streak count, progress %, saffron text.
  TextStyle get captionHighlight => AppTypography.captionHighlight;

  // Use these for muted secondary content (translations, attributions).
  TextStyle get bodyMediumMuted => bodyMedium.copyWith(
        fontStyle: FontStyle.italic,
        color: isDark ? const Color(0xFF9E8E78) : AppColors.textSecondary,
      );

  // Saffron-tinted label — used for scripture chips, active tags.
  TextStyle get chipLabel => AppTypography.caption.copyWith(
        color: AppColors.saffron,
        fontWeight: FontWeight.w600,
      );
}
