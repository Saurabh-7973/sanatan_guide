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

  group('formatTransliteration', () {
    test('keeps pāda line breaks, drops trailing verse marker', () {
      const raw = 'karmaṇyevādhikāraste mā phaleṣu kadācana .\n'
          'mā karmaphalaheturbhūrmā te saṅgo.astvakarmaṇi ||2-47||';
      expect(
        formatTransliteration(raw),
        'karmaṇyevādhikāraste mā phaleṣu kadācana .\n'
        'mā karmaphalaheturbhūrmā te saṅgo.astvakarmaṇi',
      );
    });

    test('drops blank lines and trims', () {
      const raw = '\n  pāda one .\n\n   pāda two ||1-1||  \n';
      expect(formatTransliteration(raw), 'pāda one .\npāda two');
    });

    test('handles single-line input without marker', () {
      expect(formatTransliteration('eka mantra'), 'eka mantra');
    });
  });

  group('formatTranslation', () {
    test('splits multi-sentence prose onto its own lines', () {
      const raw =
          'Thy right is to work only. Never with its fruits. Let attachment '
          'not be to inaction.';
      expect(
        formatTranslation(raw),
        'Thy right is to work only.\n'
        'Never with its fruits.\n'
        'Let attachment not be to inaction.',
      );
    });

    test('strips a leading verse coordinate', () {
      expect(
        formatTranslation('2.47 Thy right is to work only.'),
        'Thy right is to work only.',
      );
    });

    test('does not split on decimals like "Krishna 3.5"', () {
      expect(
        formatTranslation('Krishna spoke. The number was 3.5 in value.'),
        'Krishna spoke.\nThe number was 3.5 in value.',
      );
    });

    test('single sentence stays a single line', () {
      expect(
        formatTranslation('All beings perish at the end of the age.'),
        'All beings perish at the end of the age.',
      );
    });
  });
}
