/// Strips Vedic svara / combining marks for a cleaner reading pass.
///
/// Removes Unicode combining Devanagari accents (U+0951, U+0952), extended
/// Vedic signs (U+1CD0–U+1CFF), and zero-width Devanagari modifiers
/// (U+0900–U+0902). Also collapses runs of whitespace.
///
/// Idempotent — calling twice returns the same output.
String stripVedicAccents(String text) {
  return text
      .replaceAll(RegExp(r'[॒॑᳐-᳿ऀ-ं]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
