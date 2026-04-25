/// 4pt-grid spacing constants. Never hardcode margin/padding values in widgets.
abstract final class AppSpacing {
  // Scale (4pt grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double huge = 64.0;

  // Semantic aliases
  static const double cardPadding = 16.0;
  static const double pagePadding = 24.0;
  static const double sectionGap = 32.0;
  static const double listItemSpacing = 12.0;

  // ── Tiered border radius ───────────────────────────────────────────────
  // Different radii = different emotional weight. Same radius everywhere = SaaS.
  // Use these instead of cardRadius (kept below as deprecated alias).

  static const double radiusRow   = 4.0;   // list rows — manuscript page feel
  static const double radiusChip  = 8.0;   // small chips, badges
  static const double radiusCard  = 16.0;  // content cards
  static const double radiusHero  = 24.0;  // hero cards (VoD, featured scripture)
  static const double radiusSheet = 20.0;  // share card, bottom sheets

  /// @deprecated Use radiusCard (16dp) instead.
  static const double cardRadius = 12.0;

  // Typography (line height multipliers)
  static const double verseLineHeight = 1.9;
  static const double bodyLineHeight = 1.6;
  static const double labelLineHeight = 1.3;
}
