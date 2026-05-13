import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/core/utils/verse_text.dart';

void main() {
  group('stripVedicAccents', () {
    test('removes U+0951 (udatta) and U+0952 (anudatta) marks', () {
      // Strips the stress signs but keeps anusvāra (U+0902) — it's part of
      // the word ("अग्निं" stays "अग्निं", not "अग्नि").
      expect(
        stripVedicAccents('अ॑ग्निं॒ ई॑ळे'),
        'अग्निं ईळे',
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
