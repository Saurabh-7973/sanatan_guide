import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// All text styles for Sanatan Guide.
/// Rule: Never use TextStyle inline in widgets. Always use AppTypography.
/// Type scale (masterplan): display 32/24, label 16/14, body 18/16, caption 13,
/// Sanskrit 22/18 — line heights: Sanskrit 2.0, body 1.6, label 1.3.
abstract final class AppTypography {
  static const String _sanskrit = 'TiroDevanagari';
  static const String _devanagari = 'NotoSansDevanagari';
  static const String _english = 'Lora';
  static const String _ui = 'Outfit';

  // ── Sanskrit display ────────────────────────────────────────────────────

  static const TextStyle sanskritLarge = TextStyle(
    fontFamily: _sanskrit,
    fontSize: 32,
    height: 2.4,
    color: AppColors.sanskritText,
    letterSpacing: 0.8,
  );

  static const TextStyle sanskritMedium = TextStyle(
    fontFamily: _sanskrit,
    fontSize: 22,
    height: 2.0,
    color: AppColors.sanskritText,
    letterSpacing: 0.3,
  );

  static const TextStyle sanskritSmall = TextStyle(
    fontFamily: _sanskrit,
    fontSize: 18,
    height: 2.0,
    color: AppColors.sanskritText,
    letterSpacing: 0.2,
  );

  // ── Transliteration ─────────────────────────────────────────────────────

  static const TextStyle transliteration = TextStyle(
    fontFamily: _english,
    fontSize: 15,
    fontStyle: FontStyle.italic,
    height: AppSpacing.bodyLineHeight,
    color: AppColors.translitText,
    letterSpacing: 0.3,
  );

  // ── Hindi / Devanagari ──────────────────────────────────────────────────

  static const TextStyle hindiLarge = TextStyle(
    fontFamily: _devanagari,
    fontSize: 18,
    height: AppSpacing.bodyLineHeight,
    color: AppColors.textPrimary,
  );

  static const TextStyle hindiBody = TextStyle(
    fontFamily: _devanagari,
    fontSize: 16,
    height: AppSpacing.bodyLineHeight,
    color: AppColors.textPrimary,
  );

  // ── English display ─────────────────────────────────────────────────────

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _english,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: AppSpacing.labelLineHeight,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _english,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: AppSpacing.labelLineHeight,
    color: AppColors.textPrimary,
  );

  // ── Missing middle of the type scale ─────────────────────────────────
  // Without these, everything is either 11px metadata or 24px+ display.
  // The gap is what makes the app read as SaaS instead of editorial.

  /// Card titles, chapter names in lists, module titles.
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _english,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  /// Subsection titles, scripture names inline, settings section headers.
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _english,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// Buttons in body content, nav labels, primary action text (not appbar).
  static const TextStyle labelXLarge = TextStyle(
    fontFamily: _ui,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _english,
    fontSize: 18,
    height: AppSpacing.bodyLineHeight,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _english,
    fontSize: 16,
    height: AppSpacing.bodyLineHeight,
    color: AppColors.textPrimary,
  );

  // ── UI text ─────────────────────────────────────────────────────────────

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _ui,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: AppSpacing.labelLineHeight,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _ui,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: AppSpacing.labelLineHeight,
    color: AppColors.textPrimary,
  );

  // Small UI label — badges, verse counts, dense meta text (12sp)
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _ui,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: AppSpacing.labelLineHeight,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _ui,
    fontSize: 13,
    color: AppColors.textSecondary,
    height: AppSpacing.labelLineHeight,
  );

  // ── Semantic variants ────────────────────────────────────────────────────

  /// Section header labels (DAILY PRACTICE, TODAY, STREAK, etc.)
  /// Always uppercase in usage. 11sp + wide tracking.
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: _ui,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    height: AppSpacing.labelLineHeight,
    color: AppColors.textPrimary,
  );

  /// Card-type labels (KEY VERSE, ANCHOR, CONTENT etc.) — saffron accent.
  static const TextStyle cardLabel = TextStyle(
    fontFamily: _ui,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: AppSpacing.labelLineHeight,
    color: AppColors.saffron,
  );

  /// Highlighted caption — streak count, progress %, active saffron body text.
  static const TextStyle captionHighlight = TextStyle(
    fontFamily: _ui,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: AppSpacing.labelLineHeight,
    color: AppColors.saffron,
  );
}
