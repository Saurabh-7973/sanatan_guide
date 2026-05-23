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

  // v2 cache: 3 fields (IAST, gloss, grammar). v1 entries are ignored —
  // old cache stays in prefs (no migration cost) but new taps re-fetch.
  static const String _prefix = 'wordgloss_v2_';

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
          'the verse above, give its IAST transliteration, a concise '
          "English gloss in this verse's context, and its grammar tag "
          '(part of speech, case, number, gender — separated by " · "). '
          'Reply on ONE line, exactly as:\n'
          'IAST :: gloss :: grammar\n'
          'Examples of the grammar field: "noun · locative · neuter", '
          '"verb · 3rd person · singular · present", "adjective · '
          'nominative · masculine · plural". No other text.',
    );

    final line = raw.trim().split('\n').first.trim();
    final parts = line.split('::').map((s) => s.trim()).toList();
    final translit = parts.isNotEmpty ? parts[0] : '';
    final meaning = parts.length > 1 ? parts[1] : line;
    final grammar = parts.length > 2 ? parts[2] : '';

    await prefs.setString(
      _cacheKey(verseId, word),
      '$translit$_fieldSep$meaning$_fieldSep$grammar',
    );
    return WordMeaning(
      word: word,
      transliteration: translit.isEmpty ? null : translit,
      meaning: meaning,
      grammar: grammar.isEmpty ? null : grammar,
    );
  }

  static WordMeaning _decode(String word, String cached) {
    final parts = cached.split(_fieldSep);
    final translit = parts.isNotEmpty ? parts[0] : '';
    final grammar = parts.length > 2 ? parts[2] : '';
    return WordMeaning(
      word: word,
      transliteration: translit.isEmpty ? null : translit,
      meaning: parts.length > 1 ? parts[1] : '',
      grammar: grammar.isEmpty ? null : grammar,
    );
  }
}
