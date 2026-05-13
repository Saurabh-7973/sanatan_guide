/// Strips Vedic svara / accent marks for a cleaner reading pass.
///
/// Removes the combining Devanagari stress signs udātta (U+0951) and anudātta
/// (U+0952) and the Vedic Extensions block (U+1CD0–U+1CFF). Standard
/// nasalisation marks — anusvāra (U+0902) and candrabindu (U+0901) — are
/// *kept*: they change the word, not just the recitation. Also collapses runs
/// of whitespace.
///
/// Idempotent — calling twice returns the same output.
String stripVedicAccents(String text) {
  return text
      .replaceAll(RegExp(r'[॒॑᳐-᳿]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
