// lib/core/theme/design_tokens.dart
//
// CANONICAL DESIGN TOKENS for Sanatan Guide.
// Do not invent new colors, fonts, sizes, or radii outside this file.
// If you need a new token, add it here with a comment explaining why.

import 'package:flutter/material.dart';

// ============================================================
// DARK THEME (default)
// ============================================================
class DColors {
  // Backgrounds
  static const bg = Color(0xFF0F0F0F);        // page scaffold
  static const surface = Color(0xFF1C1816);   // cards, sheets
  static const surface2 = Color(0xFF251F1B);  // elevated surfaces (dialogs, popovers)

  // Saffron family
  static const saffron = Color(0xFFE8820C);       // accents, active state
  static const saffronDeep = Color(0xFFB86908);   // headings, sub-accent
  static const saffronGlow = Color(0x1FE8820C);   // 12% saffron — selection backgrounds

  // Cream / text
  static const cream = Color(0xFFF2E5CE);
  static const text1 = Color(0xFFF2E5CE);            // primary text
  static const text2 = Color(0x9EF2E5CE);            // 62% — secondary text
  static const text3 = Color(0x61F2E5CE);            // 38% — tertiary/labels

  // Dividers
  static const divider = Color(0x2EE8820C);          // 18% saffron — strong divider
  static const dividerSoft = Color(0x14F2E5CE);      // 8% cream — soft divider

  // Iron-red (RESERVED: festivals + destructive + KEY VERSE pill only)
  static const ironRed = Color(0xFFB85A3A);          // borders/icons
  static const ironRedBright = Color(0xFFD17048);    // text (WCAG AA on dark bg)
}

// ============================================================
// LIGHT THEME
// ============================================================
class LColors {
  static const bg = Color(0xFFFDFAF6);
  static const surface = Color(0xFFF7F2EC);
  static const surface2 = Color(0xFFEFE7D7);

  static const saffron = Color(0xFFC26508);
  static const saffronDeep = Color(0xFF8B4806);
  static const saffronGlow = Color(0x14C26508);      // 8%

  static const text1 = Color(0xFF2A1E14);
  static const text2 = Color(0xA62A1E14);            // 65%
  static const text3 = Color(0x662A1E14);            // 40%

  static const divider = Color(0x40C26508);          // 25%
  static const dividerSoft = Color(0x1A2A1E14);      // 10%

  static const ironRed = Color(0xFF8B2818);
  static const ironRedBright = Color(0xFFA53520);
}

// ============================================================
// FONTS
// ============================================================
class Fonts {
  static const sans = 'Outfit';                       // UI chrome
  static const serif = 'Lora';                        // reading prose, AI replies
  static const deva = 'Tiro Devanagari Sanskrit';     // Sanskrit verses
  static const devaUI = 'Noto Sans Devanagari';       // UI Devanāgarī (compact)

  // Fallback chain — apply to EVERY Sanskrit/Devanāgarī TextStyle.
  static const List<String> devaFallback = [
    'Noto Sans Devanagari',
    'serif',
  ];
}

// ============================================================
// SANSKRIT FONT-SIZE SCALE
// Settings slider has 7 ticks mapped to these sizes.
// Default index = 2 (18px). Exposed via sanskritFontSizeProvider.
// ============================================================
class SanskritScale {
  static const List<double> sizes = [14, 16, 18, 20, 22, 24, 28];
  static const int defaultIndex = 2;  // 18px
  static const int minIndex = 0;
  static const int maxIndex = 6;

  static double sizeAt(int index) {
    final clamped = index.clamp(minIndex, maxIndex);
    return sizes[clamped];
  }
}

// ============================================================
// SPACING — 4pt grid
// ============================================================
class Spacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const base = 14.0;
  static const lg = 16.0;
  static const lgPlus = 18.0;
  static const xl = 20.0;
  static const xl2 = 22.0;
  static const xl3 = 24.0;
  static const xxl = 28.0;
  static const xxxl = 32.0;
}

// ============================================================
// RADII
// ============================================================
class Radii {
  static const card = 4.0;
  static const pillSmall = 11.0;
  static const pill = 18.0;
  static const button = 28.0;
  static const sheetTop = 16.0;
  static const dialog = 12.0;
}

// ============================================================
// MOTION
// ============================================================
class Motion {
  static const Duration tap = Duration(milliseconds: 120);
  static const Duration sheet = Duration(milliseconds: 280);
  static const Duration dialog = Duration(milliseconds: 200);
  static const Duration toast = Duration(milliseconds: 240);
  static const Duration toastVisible = Duration(milliseconds: 3500);
  static const Duration calloutOpen = Duration(milliseconds: 180);
  static const Duration page = Duration(milliseconds: 280);
  static const Duration leafThreadPulse = Duration(milliseconds: 1200);
  static const Duration aiThinkingCycle = Duration(milliseconds: 1400);
  static const Duration themeTransition = Duration(milliseconds: 320);

  static const Curve standardOut = Curves.easeOut;
  static const Curve standard = Curves.easeInOut;
  static const Curve sheetCurve = Cubic(0.32, 0.72, 0, 1);
}

// ============================================================
// GLOWS / SHADOWS
// ============================================================
class Glows {
  static List<BoxShadow> saffronSoft = [
    BoxShadow(
      color: DColors.saffron.withOpacity(0.4),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> saffronStrong = [
    BoxShadow(
      color: DColors.saffron.withOpacity(0.5),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> saffronText = [
    Shadow(
      color: DColors.saffron.withOpacity(0.5),
      blurRadius: 12,
    ),
  ].whereType<BoxShadow>().toList();
}
