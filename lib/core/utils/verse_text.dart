/// Formats an IAST transliteration block for display.
///
/// The DB stores each pāda on its own line ended with " ." and the verse with
/// a trailing "||chapter-verse||" marker (e.g. "||2-47||"). The marker
/// duplicates the coordinate already shown in the verse-detail header, so we
/// drop it. Each remaining line is trimmed; blanks collapse to a single break.
String formatTransliteration(String raw) {
  final lines = raw.split('\n');
  final out = <String>[];
  for (var line in lines) {
    var t = line.trim();
    if (t.isEmpty) continue;
    // Strip "||1-2||" verse-end markers; tolerate "||2-47||", "||1.2||", etc.
    t = t.replaceAll(RegExp(r'\|\|[\d.\-]+\|\|'), '').trim();
    if (t.isNotEmpty) out.add(t);
  }
  return out.join('\n');
}

/// Formats an English translation by breaking on sentence boundaries so a
/// long paragraph reads as one-sentence-per-line. Leading verse coordinate
/// (e.g. "2.47 ") is stripped — the header already shows it.
///
/// Sentence detection: period / question / exclamation followed by whitespace
/// and an upper-case letter, digit, or quote. Abbreviations like "Mr." aren't
/// followed by a capital after a single space in scripture prose, so this is
/// safe for the BG/Upaniṣad corpus; revisit if false breaks show up.
String formatTranslation(String raw) {
  var s = raw.trim();
  // Drop a leading verse coordinate ("2.47 ", "1-1.1 ", "1.1.1 ").
  s = s.replaceFirst(RegExp(r'^[\d]+([.\-][\d]+)*\s+'), '');
  // Break sentences. Lookahead avoids consuming the following character.
  final parts = s.split(RegExp(r'(?<=[.!?])\s+(?=["“(]?[A-Z0-9])'));
  return parts.map((p) => p.trim()).where((p) => p.isNotEmpty).join('\n');
}

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
