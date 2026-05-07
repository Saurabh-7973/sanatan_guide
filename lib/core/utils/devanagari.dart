/// Converts a non-negative Arabic integer to Devanāgarī numerals.
///
/// Used for chapter and verse numbering in scripture readers, where the
/// Devanāgarī numeral is the primary glyph and the Arabic form is a
/// fallback. Negative inputs are returned as-is with a leading `-`.
String arabicToDevanagari(int n) {
  const digits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
  if (n == 0) return digits[0];
  final sign = n < 0 ? '-' : '';
  var x = n.abs();
  final buf = StringBuffer();
  while (x > 0) {
    buf.write(digits[x % 10]);
    x ~/= 10;
  }
  return sign + buf.toString().split('').reversed.join();
}
