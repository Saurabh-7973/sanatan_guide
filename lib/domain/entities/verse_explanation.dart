/// Plain-language AI explanation attached to a verse (offline DB row).
final class VerseExplanation {
  const VerseExplanation({
    required this.verseId,
    required this.explanationText,
    required this.generatedAt,
    required this.modelVersion,
  });

  final String verseId;
  final String explanationText;
  final DateTime generatedAt;
  final String modelVersion;
}
