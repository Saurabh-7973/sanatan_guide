// Sanatan Guide design tokens.
// SOURCE OF TRUTH for colors, spacing, radii, durations.
// Do not invent new values — extend this file.

import 'package:flutter/material.dart';

// ============================================================
// COLORS — DARK THEME (default)
// ============================================================
class DColors {
  static const bg = Color(0xFF0F0F0F);
  static const surface = Color(0xFF1C1816);
  static const surface2 = Color(0xFF251F1B);

  static const saffron = Color(0xFFE8820C);
  static const saffronDeep = Color(0xFFB86908);
  static const saffronGlow = Color(0x1FE8820C);

  static const cream = Color(0xFFF2E5CE);

  static const text1 = Color(0xFFF2E5CE);
  static const text2 = Color(0x9EF2E5CE);
  static const text3 = Color(0x61F2E5CE);

  static const divider = Color(0x2EE8820C);
  static const dividerSoft = Color(0x14F2E5CE);

  static const ironRed = Color(0xFFB85A3A);
  static const ironRedBright = Color(0xFFD17048);

  static const threadLocked = Color(0x38B86908);
}

// ============================================================
// COLORS — LIGHT THEME
// ============================================================
class LColors {
  static const bg = Color(0xFFFDFAF6);
  static const surface = Color(0xFFF7F2EC);
  static const surface2 = Color(0xFFEFE7D7);

  static const saffron = Color(0xFFC26508);
  static const saffronDeep = Color(0xFF8B4806);
  static const saffronGlow = Color(0x14C26508);

  static const cream = Color(0xFF2A1E14);

  static const text1 = Color(0xFF2A1E14);
  static const text2 = Color(0xA62A1E14);
  static const text3 = Color(0x662A1E14);

  static const divider = Color(0x40C26508);
  static const dividerSoft = Color(0x1A2A1E14);

  static const ironRed = Color(0xFF8B2818);
  static const ironRedBright = Color(0xFFA53520);

  static const threadLocked = Color(0x408B4806);
}

// ============================================================
// FONT FAMILIES
// ============================================================
class Fonts {
  // These must match the `family:` names declared in pubspec.yaml exactly,
  // or Flutter silently falls back to a system font.
  static const sans = 'Outfit';
  static const serif = 'Lora';
  static const deva = 'TiroDevanagari';
  static const devaUI = 'NotoSansDevanagari';
}

// ============================================================
// SPACING (4pt grid)
// ============================================================
class Spacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;

  static const screenH = 24.0;
  static const sectionV = 22.0;
}

// ============================================================
// RADII
// ============================================================
class Radii {
  static const card = 4.0;
  static const pill = 18.0;
  static const pillSm = 11.0;
  static const sheet = 12.0;
  static const button = 28.0;
  static const circle = 999.0;
}

// ============================================================
// SANSKRIT FONT-SIZE SCALE (Settings slider)
// ============================================================
class SanskritScale {
  static const sizes = [14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 28.0];
  static const defaultIndex = 2;

  static double sizeFor(int tickIndex) {
    if (tickIndex < 0 || tickIndex >= sizes.length) {
      return sizes[defaultIndex];
    }
    return sizes[tickIndex];
  }
}

// ============================================================
// MOTION (durations + curves)
// ============================================================
class Motion {
  static const tapFeedback = Duration(milliseconds: 120);
  static const cardEntry = Duration(milliseconds: 400);
  static const cardStagger = Duration(milliseconds: 60);
  static const sheetEntry = Duration(milliseconds: 200);
  static const pageTransition = Duration(milliseconds: 280);
  static const aiTokenFade = Duration(milliseconds: 30);
  static const aiThinkingPulse = Duration(milliseconds: 1400);

  static const easeOut = Curves.easeOut;
  static const easeInOut = Curves.easeInOut;
  static const elastic = Curves.easeOutBack;
}

// ============================================================
// SHADOWS / GLOWS
// ============================================================
class Glows {
  static const List<BoxShadow> threadDark = [
    BoxShadow(
      color: Color(0x80E8820C),
      blurRadius: 6,
    ),
  ];

  static const List<BoxShadow> activeKnotDark = [
    BoxShadow(
      color: Color(0x8CE8820C),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> moonGlowDark = [
    BoxShadow(
      color: Color(0x33F2E5CE),
      blurRadius: 4,
    ),
  ];

  static const List<BoxShadow> overflowMenuDark = [
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> overflowMenuLight = [
    BoxShadow(
      color: Color(0x1F2A1E14),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];
}
