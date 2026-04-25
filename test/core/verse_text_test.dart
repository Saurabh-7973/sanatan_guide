import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/core/utils/verse_text.dart';

void main() {
  group('stripVedicAccents', () {
    test('removes U+0951 (udatta) and U+0952 (anudatta) marks', () {
      // Note: the current impl also strips anusvara (U+0902), so "अग्निं"
      // (with anusvara) becomes "अग्नि" (without). Documented here as the
      // de-facto behaviour; revisit if a future reading-mode needs to
      // preserve anusvara.
      expect(
        stripVedicAccents('अ॑ग्निं॒ ई॑ळे'),
        'अग्नि ईळे',
      );
    });

    test('removes extended Vedic signs in U+1CD0–U+1CFF block', () {
      // U+1CDA is a svarita mark used in Rigvedic accenting.
      expect(stripVedicAccents('र᳚वि'), 'रवि');
    });

    test('collapses runs of whitespace to a single space', () {
      expect(stripVedicAccents('राम   वि ष्॑णु'), 'राम वि ष्णु');
    });

    test('trims leading / trailing whitespace', () {
      expect(stripVedicAccents('   ॐ  '), 'ॐ');
    });

    test('is idempotent', () {
      const input = 'अ॑ग्निं ई॑ळे॒';
      final once = stripVedicAccents(input);
      expect(stripVedicAccents(once), once);
    });

    test('leaves plain Sanskrit untouched', () {
      const plain = 'कर्मण्येवाधिकारस्ते';
      expect(stripVedicAccents(plain), plain);
    });

    test('empty input returns empty', () {
      expect(stripVedicAccents(''), '');
    });
  });
}
