// All TextStyle definitions for Sanatan Guide.
// Use these — do not write inline TextStyles in screen code.

import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

/// Public fallback chains for ad-hoc inline `TextStyle` uses that can't go
/// through [AppText]. Mirror the private chains used by the central styles.
abstract final class AppFontFallback {
  /// IAST/Latin-primary styles that may contain extended diacritics.
  static const List<String> latin = <String>[
    'NotoSansDevanagari',
    'serif',
  ];

  /// Devanāgarī-primary styles (Tiro / Noto Devanagari).
  static const List<String> deva = <String>[
    'NotoSansDevanagari',
    'serif',
  ];
}

class AppText {
  // ============================================================
  // SCREEN TITLES & HEADERS
  // ============================================================

  static TextStyle screenTitle({required Color color}) => TextStyle(
        fontFamily: Fonts.serif,
        fontFamilyFallback: _latinFallback,
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 1.0,
        letterSpacing: -0.56,
        color: color,
      );

  static TextStyle sectionName({required Color color}) => TextStyle(
        fontFamily: Fonts.serif,
        fontFamilyFallback: _latinFallback,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.18,
        color: color,
      );

  static TextStyle settingsTitle({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
        fontFamilyFallback: _latinFallback,
        fontSize: 19,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.19,
        color: color,
      );

  static TextStyle subtitle({required Color color}) => TextStyle(
        fontFamily: Fonts.serif,
        fontFamilyFallback: _latinFallback,
        fontStyle: FontStyle.italic,
        fontSize: 13.5,
        height: 1.4,
        color: color,
      );

  // ============================================================
  // SECTION LABELS
  // ============================================================

  static TextStyle sectionLabel({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
        fontFamilyFallback: _latinFallback,
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.66,
        color: color,
      );

  static TextStyle metaLabel({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
        fontFamilyFallback: _latinFallback,
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.68,
        color: color,
      );

  // ============================================================
  // ROW / CARD COPY
  // ============================================================

  static TextStyle rowLabel({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
        fontFamilyFallback: _latinFallback,
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.07,
        height: 1.25,
        color: color,
      );

  static TextStyle rowSub({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
        fontFamilyFallback: _latinFallback,
        fontSize: 11.5,
        height: 1.35,
        color: color,
      );

  static TextStyle moduleTitle({required Color color}) => TextStyle(
        fontFamily: Fonts.serif,
        fontFamilyFallback: _latinFallback,
        fontSize: 15.5,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.07,
        height: 1.3,
        color: color,
      );

  static TextStyle moduleDesc({required Color color}) => TextStyle(
        fontFamily: Fonts.serif,
        fontFamilyFallback: _latinFallback,
        fontStyle: FontStyle.italic,
        fontSize: 12.5,
        height: 1.45,
        color: color,
      );

  // ============================================================
  // SANSKRIT
  // ============================================================

  // Brief §5.2.9 / §2.3: Devanāgarī styles fall back to Noto Sans Devanagari
  // if Tiro fails to load. Generic `serif` is the final guard.
  static const List<String> _devaFallback = <String>[
    'NotoSansDevanagari',
    'serif',
  ];

  // Universal fallback for Latin-primary styles that may contain IAST
  // diacritics (ṣ ī ḥ ṃ ṇ etc.) or stray Devanāgarī. Lora-Italic notably lacks
  // some Latin Extended Additional glyphs — fall to a Devanāgarī font then to
  // the platform serif/sans (Noto Serif on Android has full Latin Extended).
  static const List<String> _latinFallback = AppFontFallback.latin;

  static TextStyle sanskritBody({
    required Color color,
    double size = 18,
  }) =>
      TextStyle(
        fontFamily: Fonts.deva,
        fontFamilyFallback: _devaFallback,
        fontSize: size,
        height: 1.7,
        letterSpacing: 0.09,
        color: color,
      );

  static TextStyle sanskritIncipit({required Color color}) => TextStyle(
        fontFamily: Fonts.deva,
        fontFamilyFallback: _devaFallback,
        fontSize: 14,
        height: 1.55,
        color: color,
      );

  static TextStyle devUI({required Color color, double size = 13}) => TextStyle(
        fontFamily: Fonts.devaUI,
        fontSize: size,
        height: 1.0,
        color: color,
      );

  // ============================================================
  // VERSE TRANSLATION & COMMENTARY
  // ============================================================

  static TextStyle translation({required Color color, double size = 14.5}) =>
      TextStyle(
        fontFamily: Fonts.serif,
        fontFamilyFallback: _latinFallback,
        fontSize: size,
        height: 1.7,
        color: color,
      );

  static TextStyle commentary({required Color color, double size = 14.5}) =>
      TextStyle(
        fontFamily: Fonts.serif,
        fontFamilyFallback: _latinFallback,
        fontStyle: FontStyle.italic,
        fontSize: size,
        height: 1.7,
        color: color,
      );

  // ============================================================
  // DAṆḌA-MARKED VERSE COORDINATE
  // ============================================================

  static TextStyle dandaCoord({required Color saffronColor}) => TextStyle(
        fontFamily: Fonts.deva,
        fontFamilyFallback: _devaFallback,
        fontSize: 13,
        height: 1.0,
        color: saffronColor,
      );

  // ============================================================
  // CHIPS, BUTTONS, METADATA
  // ============================================================

  static TextStyle pill({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
        fontFamilyFallback: _latinFallback,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.44,
        color: color,
      );

  static TextStyle primaryButton({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
        fontFamilyFallback: _latinFallback,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.82,
        color: color,
      );

  static TextStyle textButton({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
        fontFamilyFallback: _latinFallback,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.68,
        color: color,
      );

  static TextStyle meta({required Color color, double size = 10.5}) =>
      TextStyle(
        fontFamily: Fonts.sans,
        fontFamilyFallback: _latinFallback,
        fontSize: size,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.42,
        color: color,
      );

  // ============================================================
  // INVOCATION / WATERMARK
  // ============================================================

  static TextStyle invocation({required Color saffronColor}) => TextStyle(
        fontFamily: Fonts.deva,
        fontFamilyFallback: _devaFallback,
        fontSize: 11,
        letterSpacing: 1.76,
        color: saffronColor,
      );
}
