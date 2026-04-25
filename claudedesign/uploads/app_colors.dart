import 'package:flutter/material.dart';

/// All colour constants for Sanatan Guide.
///
/// Dark mode surface hierarchy (tonal elevation — no harsh shadows):
///   Level 0 scaffold:  bgDark      #0F0F0F  — near-black with warmth
///   Level 1 cards:     surfaceDark #1C1816  — saffron-tinted dark
///   Level 2 elevated:  surfaceElevated #221E1B — modals, sheets
///   Level 3 chips:     surfaceHighest  #2A2520 — interactive surfaces
///
/// Light mode surface hierarchy:
///   Level 0 scaffold:  cream         #FDFAF6  — warm cream, NOT pure white
///   Level 1 cards:     surface       #F7F2EC  — slightly darker cream
///   Level 2 inputs:    surfaceVariant #EDE8E2 — input fields
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────

  // Primary saffron — used for accents, selected states, icons
  static const Color saffron = Color(0xFFE8820C);

  // Saffron on dark backgrounds — slightly brighter for contrast
  static const Color saffronOnDark = Color(0xFFF4A830);

  static const Color deepRed = Color(0xFF8B0000);
  static const Color gold = Color(0xFFFFD700);

  // ── Light mode surfaces ────────────────────────────────────────────────

  // Scaffold background — warm cream, never pure white
  static const Color cream = Color(0xFFFDFAF6);

  // Card surface — slightly off-cream
  static const Color surface = Color(0xFFF7F2EC);

  // Input fields, secondary surfaces
  static const Color surfaceVariant = Color(0xFFEDE8E2);

  // Deprecated alias — kept for compatibility
  static const Color creamDark = Color(0xFFF5F0E0);

  // ── Dark mode surfaces ─────────────────────────────────────────────────

  // Scaffold background — NOT #000000, warm near-black
  static const Color bgDark = Color(0xFF0F0F0F);

  // Card surface — saffron-tinted dark
  static const Color surfaceDark = Color(0xFF1C1816);

  // Elevated surfaces — modals, bottom sheets
  static const Color surfaceElevated = Color(0xFF221E1B);

  // Highest elevation — chips, interactive elements
  static const Color surfaceHighest = Color(0xFF2A2520);

  // ── Text ───────────────────────────────────────────────────────────────

  // Light mode text
  static const Color textPrimary = Color(0xFF1A1210); // warm near-black
  static const Color textSecondary = Color(0xFF6B6360); // muted warm grey
  static const Color textHint = Color(0xFF9E9A97);

  // Dark mode text
  static const Color textOnDark = Color(0xFFF0EBE5); // warm white
  static const Color textSecondaryOnDark = Color(0xFF9B9390); // muted

  // ── Semantic ───────────────────────────────────────────────────────────

  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color error = Color(0xFFB71C1C);
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFF9C4);

  // ── Dividers & borders ─────────────────────────────────────────────────

  // Light mode — warm grey
  static const Color divider = Color(0xFFE0D9CF);
  static const Color border = Color(0xFFCCC5BB);

  // Dark mode — subtle, not harsh
  static const Color dividerDark = Color(0xFF2E2A27);
  static const Color borderDark = Color(0xFF3A3531);

  // ── Scripture reader ───────────────────────────────────────────────────
  // These only apply to verse display components

  static const Color sanskritText = Color(0xFF2D1B00);
  static const Color sanskritTextOnDark = Color(0xFFE8D9C0);
  static const Color translitText = Color(0xFF5A3E28);
  static const Color englishText = Color(0xFF1A1A1A);

  // ── Opacity variants ──────────────────────────────────────────────────
  // Use these instead of .withValues(alpha: X) in widgets.
  // Naming: <base>Faint = 8%, Muted = 12%, Light = 15%, Border = 30%.

  static const Color saffronFaint  = Color(0x14E8820C); // 8%  chip/icon bg
  static const Color saffronMuted  = Color(0x1FE8820C); // 12% badge, hover
  static const Color saffronLight  = Color(0x26E8820C); // 15% card fill
  static const Color saffronBorder = Color(0x4DE8820C); // 30% accent border

  static const Color deepRedMuted  = Color(0x1F8B0000); // 12% anchor badge bg
  static const Color successMuted  = Color(0x4D2E7D32); // 30% completion border

  static const Color borderFaint     = Color(0x66CCC5BB); // 40% light border
  static const Color borderFaintDark = Color(0x66383330); // 40% dark border

  // ── Warm grey palette ─────────────────────────────────────────────────
  // The missing in-between tones. Replaces saffron in non-sacred UI roles.
  // warmGrey10 = hover/selected bg on cream
  // warmGrey50 = secondary UI, meta text (replaces generic grey)
  // warmGrey80 = primary text on cream (softer than near-black textPrimary)

  static const Color warmGrey10 = Color(0xFFF2EDE6);
  static const Color warmGrey50 = Color(0xFF8A7968);
  static const Color warmGrey80 = Color(0xFF3A322B);

  // Share card background — warmer than pure black (#0F0F0F)
  static const Color shareCardBg = Color(0xFF0F0B07);

  // ── Scripture library category accents ────────────────────────────────
  // Left-border accent color per category chip label.

  static const Color catItihasa = Color(0xFFC45C2A);
  static const Color catVeda = Color(0xFFB85C1C);
  static const Color catUpanishad = Color(0xFF6B5B95);
  static const Color catDarshana = Color(0xFF9B7928); // warm amber-gold
  static const Color catStotra = Color(0xFFB56576);
  static const Color catShastra = Color(0xFF8D6E63);
  static const Color catTantra = Color(0xFF7B5B8A); // muted plum
  static const Color catTamil = Color(0xFF9B5E3A);  // warm terracotta
}
