import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/core/utils/crisis_support.dart';

void main() {
  group('isSelfHarmIntent', () {
    // The discriminating test: the filter must NOT gate the app's own
    // content. The Gītā is a battlefield dialogue, the Mahābhārata a war,
    // the Upaniṣads preoccupied with death — none of these may trip it.
    test('does NOT fire on scriptural questions about death/war/killing', () {
      const safe = [
        'What does the Bhagavad Gītā say about death?',
        "Why won't Arjuna fight in the war?",
        'Tell me about the Kurukshetra war',
        'What happens after death according to the Upanishads?',
        'How did Bhishma die?',
        'Is it dharma to kill in battle?',
        'Explain the death of Abhimanyu',
        'What is the soul’s journey after the body dies?',
        'Did Krishna kill Kamsa?',
      ];
      for (final q in safe) {
        expect(isSelfHarmIntent(q), isFalse, reason: q);
      }
    });

    test('fires on first-person self-harm intent', () {
      const crisis = [
        'I want to die',
        'how do I kill myself',
        "I don't want to live anymore",
        'thinking about ending it',
        'I want to hurt myself',
        'I am going to end my life',
        'there is no reason to live',
        'I want to commit suicide',
      ];
      for (final q in crisis) {
        expect(isSelfHarmIntent(q), isTrue, reason: q);
      }
    });

    test('is case-insensitive and whitespace-tolerant', () {
      expect(isSelfHarmIntent('  I  WANT   to DIE '), isTrue);
    });

    test('empty / blank is false', () {
      expect(isSelfHarmIntent(''), isFalse);
      expect(isSelfHarmIntent('   '), isFalse);
    });
  });
}
