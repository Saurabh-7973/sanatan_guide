import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies that every IAST diacritical character can be rendered
/// without producing the replacement glyph (□ / ?).
///
/// These are the critical characters used in Sanskrit transliteration
/// following the International Alphabet of Sanskrit Transliteration.
void main() {
  const iastChars = [
    'ā', 'ī', 'ū', // long vowels
    'ṛ', 'ṝ', 'ḷ', 'ḹ', // vocalic r/l
    'ṭ', 'ḍ', 'ṇ', // retroflex consonants
    'ś', 'ṣ', // sibilants
    'ḥ', 'ṃ', // visarga & anusvara
    'ñ', // palatal nasal
    'ṅ', // velar nasal
  ];

  const sampleWords = [
    'ātman',
    'dhāraṇā',
    'prāṇāyāma',
    'Kṛṣṇa',
    'Śiva',
    'Viṣṇu',
    'saṃsāra',
    'mokṣa',
    'Bhagavadgītā',
    'Bṛhadāraṇyaka',
  ];

  group('IAST diacritical characters render correctly', () {
    for (final char in iastChars) {
      testWidgets('renders "$char" without replacement glyph', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text(char, key: ValueKey(char)),
            ),
          ),
        );

        final finder = find.byKey(ValueKey(char));
        expect(finder, findsOneWidget);

        final text = tester.widget<Text>(finder);
        expect(text.data, char);
      });
    }
  });

  group('IAST Sanskrit words render correctly', () {
    for (final word in sampleWords) {
      testWidgets('renders "$word" as complete string', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text(word, key: ValueKey(word)),
            ),
          ),
        );

        final finder = find.byKey(ValueKey(word));
        expect(finder, findsOneWidget);

        final text = tester.widget<Text>(finder);
        expect(text.data, word);
        expect(text.data!.length, word.length);
      });
    }
  });

  testWidgets('full IAST character set renders in a single Text widget',
      (tester) async {
    final allChars = iastChars.join(' ');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Text(allChars, key: const ValueKey('all-iast')),
        ),
      ),
    );

    final text = tester.widget<Text>(find.byKey(const ValueKey('all-iast')));
    expect(text.data, allChars);
  });
}
