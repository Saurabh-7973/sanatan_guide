import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/features/search/pages/search_page.dart';

void main() {
  group('looksLikeQuestion', () {
    test('empty / whitespace returns false', () {
      expect(looksLikeQuestion(''), isFalse);
      expect(looksLikeQuestion('   '), isFalse);
    });

    test('trailing ? always returns true', () {
      expect(looksLikeQuestion('karma'), isFalse);
      expect(looksLikeQuestion('karma?'), isTrue);
      expect(looksLikeQuestion('xyz?'), isTrue);
    });

    test('grammar-shaped openers fire', () {
      expect(looksLikeQuestion('what is dharma'), isTrue);
      expect(looksLikeQuestion('why does Arjuna doubt'), isTrue);
      expect(looksLikeQuestion('how to meditate'), isTrue);
      expect(looksLikeQuestion('should I fast'), isTrue);
      expect(looksLikeQuestion('tell me about karma'), isTrue);
      expect(looksLikeQuestion('explain moksha'), isTrue);
      expect(looksLikeQuestion('meaning of yoga'), isTrue);
      expect(looksLikeQuestion('difference between atma and brahman'), isTrue);
    });

    test('emotional / situational keywords fire', () {
      expect(looksLikeQuestion('grief'), isTrue);
      expect(looksLikeQuestion('anxiety'), isTrue);
      expect(looksLikeQuestion('i feel lost'), isTrue);
      expect(looksLikeQuestion('feeling depressed'), isTrue);
      expect(looksLikeQuestion('help me with stress'), isTrue);
      expect(looksLikeQuestion('death and suffering'), isTrue);
      expect(looksLikeQuestion('lonely'), isTrue);
    });

    test('plain word queries stay non-question', () {
      // These are scripture coords / topic keywords — not Pandit candidates.
      expect(looksLikeQuestion('karma'), isFalse);
      expect(looksLikeQuestion('dharma'), isFalse);
      expect(looksLikeQuestion('arjuna'), isFalse);
      expect(looksLikeQuestion('BG 2.47'), isFalse);
      expect(looksLikeQuestion('Bhagavad Gita'), isFalse);
    });

    test('case insensitive', () {
      expect(looksLikeQuestion('GRIEF'), isTrue);
      expect(looksLikeQuestion('What Is Dharma'), isTrue);
    });
  });
}
