import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanatan_guide/core/services/gemini_service.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';

/// Signature of [GeminiService.ask], extracted so tests can inject a fake.
typedef GeminiAsk = Future<String> Function({
  required String systemContext,
  required List<ChatMessage> history,
  required String userMessage,
});

/// Lazily resolves a per-word Sanskrit gloss via Gemini and caches it
/// forever in [SharedPreferences].
///
/// The bundled database ships zero word-level glosses for any of the
/// 133k+ verses, so this is the only source. It is key-gated: without a
/// `--dart-define=GEMINI_API_KEY=...` build it throws [GeminiException]
/// (callers fall back to a calm "not bundled" message). Each unique word
/// costs exactly one Gemini call ever — subsequent taps are cache hits.
class WordGlossService {
  WordGlossService._();

  static const String _prefix = 'wordgloss_v1_';

  static const String _fieldSep = '\u0001';

  static String _cacheKey(String verseId, String word) =>
      '$_prefix${verseId}__$word';

  /// Returns a [WordMeaning] enriched with transliteration + meaning.
  ///
  /// Throws [GeminiException] when uncached and either the API key is
  /// absent or the daily gloss budget is spent.
  static Future<WordMeaning> glossFor({
    required String verseId,
    required String word,
    required String verseSanskrit,
    required String scriptureLabel,
    GeminiAsk ask = GeminiService.ask,
    bool? enabledOverride,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey(verseId, word));
    if (cached != null) return _decode(word, cached);

    final enabled = enabledOverride ?? GeminiService.isEnabled;
    if (!enabled) {
      throw const GeminiException('Gemini API key not configured.');
    }

    final ok = await GeminiRateLimit.consume(
      bucket: 'gloss',
      cap: GeminiRateLimit.glossCap,
    );
    if (!ok) {
      throw const GeminiException(
          'Daily word-lookup limit reached. Try again tomorrow.');
    }

    final raw = await ask(
      systemContext: 'You are a precise Sanskrit lexicographer. '
          'Scripture: $scriptureLabel.\n'
          'Full verse (Devanagari) for context:\n$verseSanskrit',
      history: const [],
      userMessage:
          'For the single Sanskrit word "$word" exactly as it appears in '
          'the verse above, give its IAST transliteration and a concise '
          'English gloss in this verse\'s context. Reply on ONE line, '
          'exactly as:\nIAST :: gloss\nNo other text.',
    );

    final line = raw.trim().split('\n').first.trim();
    final sep = line.indexOf('::');
    final translit = sep >= 0 ? line.substring(0, sep).trim() : '';
    final meaning = (sep >= 0 ? line.substring(sep + 2) : line).trim();

    await prefs.setString(
      _cacheKey(verseId, word),
      '$translit$_fieldSep$meaning',
    );
    return WordMeaning(
      word: word,
      transliteration: translit.isEmpty ? null : translit,
      meaning: meaning,
    );
  }

  static WordMeaning _decode(String word, String cached) {
    final parts = cached.split(_fieldSep);
    final translit = parts.isNotEmpty ? parts[0] : '';
    return WordMeaning(
      word: word,
      transliteration: translit.isEmpty ? null : translit,
      meaning: parts.length > 1 ? parts[1] : '',
    );
  }
}
