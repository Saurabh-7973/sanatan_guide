import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanatan_guide/core/services/gemini_service.dart';
import 'package:sanatan_guide/core/services/word_gloss_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('disabled + no cache throws GeminiException', () async {
    expect(
      () => WordGlossService.glossFor(
        verseId: 'BG.2.47',
        word: 'कर्मणि',
        verseSanskrit: 'कर्मण्येवाधिकारस्ते',
        scriptureLabel: 'Bhagavad Gita',
        enabledOverride: false,
        ask: (
                {required systemContext,
                required history,
                required userMessage}) async =>
            fail('ask must not be called when disabled'),
      ),
      throwsA(isA<GeminiException>()),
    );
  });

  test('enabled: fetches, parses "IAST :: gloss", caches (one ask call)',
      () async {
    var calls = 0;
    Future<String> fakeAsk({
      required String systemContext,
      required List<ChatMessage> history,
      required String userMessage,
    }) async {
      calls++;
      // The prompt must carry verse context so the gloss is context-aware.
      expect(systemContext, contains('कर्मण्येवाधिकारस्ते'));
      return 'karmaṇi :: in action, in one\'s duty';
    }

    final first = await WordGlossService.glossFor(
      verseId: 'BG.2.47',
      word: 'कर्मणि',
      verseSanskrit: 'कर्मण्येवाधिकारस्ते',
      scriptureLabel: 'Bhagavad Gita',
      enabledOverride: true,
      ask: fakeAsk,
    );
    expect(first.transliteration, 'karmaṇi');
    expect(first.meaning, "in action, in one's duty");
    expect(first.word, 'कर्मणि');

    final second = await WordGlossService.glossFor(
      verseId: 'BG.2.47',
      word: 'कर्मणि',
      verseSanskrit: 'कर्मण्येवाधिकारस्ते',
      scriptureLabel: 'Bhagavad Gita',
      enabledOverride: true,
      ask: fakeAsk,
    );
    expect(second.meaning, "in action, in one's duty");
    expect(calls, 1, reason: 'second lookup must hit the cache');
  });

  test('cached value is returned even when later disabled', () async {
    Future<String> ask({
      required String systemContext,
      required List<ChatMessage> history,
      required String userMessage,
    }) async =>
        'dharma :: righteous duty';

    await WordGlossService.glossFor(
      verseId: 'BG.1.1',
      word: 'धर्म',
      verseSanskrit: 'धर्मक्षेत्रे',
      scriptureLabel: 'Bhagavad Gita',
      enabledOverride: true,
      ask: ask,
    );

    final cached = await WordGlossService.glossFor(
      verseId: 'BG.1.1',
      word: 'धर्म',
      verseSanskrit: 'धर्मक्षेत्रे',
      scriptureLabel: 'Bhagavad Gita',
      enabledOverride: false,
      ask: (
              {required systemContext,
              required history,
              required userMessage}) async =>
          fail('cache must serve without calling Gemini'),
    );
    expect(cached.meaning, 'righteous duty');
  });
}
