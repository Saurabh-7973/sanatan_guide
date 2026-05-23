// lib/core/theme/design_typography.dart
//
// All TextStyle definitions for Sanatan Guide.
// Use these — do not write inline TextStyles in screen code.

import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppText {
  // ============================================================
  // SCREEN TITLES & HEADERS
  // ============================================================

  static TextStyle screenTitle({required Color color}) => TextStyle(
        fontFamily: Fonts.serif,
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 1.0,
        letterSpacing: -0.56,
        color: color,
      );

  static TextStyle sectionName({required Color color}) => TextStyle(
        fontFamily: Fonts.serif,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.18,
        color: color,
      );

  static TextStyle settingsTitle({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
        fontSize: 19,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.19,
        color: color,
      );

  static TextStyle subtitle({required Color color}) => TextStyle(
        fontFamily: Fonts.serif,
        fontStyle: FontStyle.italic,
        fontSize: 13.5,
        height: 1.4,
        color: color,
      );

  // ============================================================
  // SECTION LABELS (small caps, sans-serif)
  // ============================================================

  static TextStyle sectionLabel({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.66, // 0.28em on 9.5px
        color: color,
      );

  static TextStyle metaLabel({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
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
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.07,
        height: 1.25,
        color: color,
      );

  static TextStyle rowSub({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
        fontSize: 11.5,
        height: 1.35,
        color: color,
      );

  static TextStyle moduleTitle({required Color color}) => TextStyle(
        fontFamily: Fonts.serif,
        fontSize: 15.5,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.07,
        height: 1.3,
        color: color,
      );

  static TextStyle moduleDesc({required Color color}) => TextStyle(
        fontFamily: Fonts.serif,
        fontStyle: FontStyle.italic,
        fontSize: 12.5,
        height: 1.45,
        color: color,
      );

  // ============================================================
  // SANSKRIT
  // ============================================================

  /// Verse Sanskrit body — line height ≥ 1.5 for Devanāgarī rendering
  static TextStyle sanskritBody({required Color color, double size = 18}) =>
      TextStyle(
        fontFamily: Fonts.deva,
        fontSize: size,
        height: 1.7,
        letterSpacing: 0.09,
        color: color,
      );

  static TextStyle sanskritIncipit({required Color color}) => TextStyle(
        fontFamily: Fonts.deva,
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
        fontSize: size,
        height: 1.7,
        color: color,
      );

  /// Commentary / AI replies — LITERARY VOICE OF THE APP
  static TextStyle commentary({required Color color, double size = 14.5}) =>
      TextStyle(
        fontFamily: Fonts.serif,
        fontStyle: FontStyle.italic,
        fontSize: size,
        height: 1.7,
        color: color,
      );

  // ============================================================
  // DAṆḌA COORDINATE
  // ============================================================

  static TextStyle dandaCoord({required Color saffronColor}) => TextStyle(
        fontFamily: Fonts.deva,
        fontSize: 13,
        height: 1.0,
        color: saffronColor,
      );

  // ============================================================
  // CHIPS, BUTTONS, METADATA
  // ============================================================

  static TextStyle pill({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.44,
        color: color,
      );

  static TextStyle primaryButton({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.82,
        color: color,
      );

  static TextStyle textButton({required Color color}) => TextStyle(
        fontFamily: Fonts.sans,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.68,
        color: color,
      );

  static TextStyle meta({required Color color, double size = 10.5}) =>
      TextStyle(
        fontFamily: Fonts.sans,
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
        fontSize: 11,
        letterSpacing: 1.76,
        color: saffronColor,
      );
}
