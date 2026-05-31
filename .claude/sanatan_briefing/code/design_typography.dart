// lib/core/theme/design_typography.dart
//
// CANONICAL TEXT STYLES for Sanatan Guide.
// Every TextStyle in the app comes from here. No inline TextStyles.
//
// Naming convention:
//   AppText.<role><Size?>   e.g.  AppText.title, AppText.bodySmall
//   AppText.<role>Italic    e.g.  AppText.commentary
//   AppText.<role>Sanskrit  e.g.  AppText.verseSanskrit

import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppText {
  // ==========================================================
  // DISPLAY — large hero text (Verse Detail, Module Complete)
  // ==========================================================
  static const displayLarge = TextStyle(
    fontFamily: Fonts.serif,
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: -0.6,
  );

  static const displayMedium = TextStyle(
    fontFamily: Fonts.serif,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1.18,
    letterSpacing: -0.56,
  );

  // ==========================================================
  // TITLES — screen + section
  // ==========================================================
  static const title = TextStyle(
    fontFamily: Fonts.serif,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: -0.22,
  );

  static const titleSmall = TextStyle(
    fontFamily: Fonts.serif,
    fontSize: 19,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: -0.19,
  );

  static const titleItalic = TextStyle(
    fontFamily: Fonts.serif,
    fontStyle: FontStyle.italic,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: -0.18,
  );

  // ==========================================================
  // BODY PROSE — reading text, commentary, translations
  // ==========================================================
  static const body = TextStyle(
    fontFamily: Fonts.serif,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.7,
  );

  static const bodySmall = TextStyle(
    fontFamily: Fonts.serif,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  // Italic body — AI replies, commentary, taglines, notes, empty states
  static const commentary = TextStyle(
    fontFamily: Fonts.serif,
    fontStyle: FontStyle.italic,
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    height: 1.65,
  );

  static const commentarySmall = TextStyle(
    fontFamily: Fonts.serif,
    fontStyle: FontStyle.italic,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ==========================================================
  // VERSE TEXT — Sanskrit + translation
  // For verseSanskrit, font-size is overridden at runtime from
  // sanskritFontSizeProvider (Settings slider).
  // ==========================================================
  static const verseSanskrit = TextStyle(
    fontFamily: Fonts.deva,
    fontFamilyFallback: Fonts.devaFallback,
    fontSize: 18,
    height: 1.85,
  );

  static const verseSanskritLarge = TextStyle(
    fontFamily: Fonts.deva,
    fontFamilyFallback: Fonts.devaFallback,
    fontSize: 22,
    height: 1.85,
  );

  // Used in cards, search results, key verse step
  static const verseSanskritCompact = TextStyle(
    fontFamily: Fonts.deva,
    fontFamilyFallback: Fonts.devaFallback,
    fontSize: 16,
    height: 1.7,
  );

  static const verseTranslation = TextStyle(
    fontFamily: Fonts.serif,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  // ==========================================================
  // UI CHROME — sans-serif Outfit
  // ==========================================================
  static const button = TextStyle(
    fontFamily: Fonts.sans,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.82, // 0.14em
  );

  static const buttonSmall = TextStyle(
    fontFamily: Fonts.sans,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.44, // 0.12em
  );

  static const meta = TextStyle(
    fontFamily: Fonts.sans,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.75, // 0.06em
  );

  static const label = TextStyle(
    fontFamily: Fonts.sans,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.98, // 0.18em
  );

  // Small-caps section label (saffron) used in modules, festivals, etc.
  static const sectionLabel = TextStyle(
    fontFamily: Fonts.sans,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.2, // 0.20em
  );

  // Smaller small-caps (RECOMMENDED, AD, etc.)
  static const sectionLabelSmall = TextStyle(
    fontFamily: Fonts.sans,
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.66, // 0.28em
  );

  static const tapHint = TextStyle(
    fontFamily: Fonts.sans,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.2, // 0.2em
  );

  // ==========================================================
  // DEVANAGARI UI — chapter numbers, dates, source enumeration
  // ==========================================================
  static const devaNumber = TextStyle(
    fontFamily: Fonts.deva,
    fontFamilyFallback: Fonts.devaFallback,
    fontSize: 13,
    height: 1,
  );

  static const devaNumberLarge = TextStyle(
    fontFamily: Fonts.deva,
    fontFamilyFallback: Fonts.devaFallback,
    fontSize: 22,
    height: 1,
  );

  // Used for the brand wordmark "सनातन"
  static const devaWordmark = TextStyle(
    fontFamily: Fonts.deva,
    fontFamilyFallback: Fonts.devaFallback,
    fontSize: 22,
    height: 1,
  );

  // ==========================================================
  // WORD CALLOUT (Verse Detail tap-a-word)
  // ==========================================================
  static const calloutDeva = TextStyle(
    fontFamily: Fonts.deva,
    fontFamilyFallback: Fonts.devaFallback,
    fontSize: 22,
    height: 1.1,
  );

  static const calloutIast = TextStyle(
    fontFamily: Fonts.serif,
    fontStyle: FontStyle.italic,
    fontSize: 13,
    height: 1.2,
  );

  static const calloutMeaning = TextStyle(
    fontFamily: Fonts.serif,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const calloutGrammar = TextStyle(
    fontFamily: Fonts.sans,
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.09, // 0.22em
  );
}
