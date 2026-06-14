/// How Sanskrit panchang names (months, tithis, nakṣatras, vāras) are
/// rendered across the home almanac line and the festival calendar.
enum ScriptStyle {
  devanagari('devanagari', 'Devanāgarī'),
  latin('latin', 'Latin (IAST)'),
  both('both', 'Both');

  const ScriptStyle(this.storageValue, this.displayTitle);

  /// Stable value persisted to SharedPreferences.
  final String storageValue;

  /// Human-readable label shown in Settings.
  final String displayTitle;

  /// Parses a stored value, returning null for unknown/missing input.
  static ScriptStyle? fromStorage(String? raw) {
    for (final style in values) {
      if (style.storageValue == raw) return style;
    }
    return null;
  }

  /// Whether the Devanāgarī form should be shown.
  bool get showsDevanagari => this != latin;

  /// Whether the Latin (IAST) form should be shown.
  bool get showsLatin => this != devanagari;
}
