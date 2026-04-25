/// Scholarly commentary on a verse, with full provenance.
///
/// Shipped rows must come from a public-domain or permissively-licensed
/// source. [license] and [sourceUrl] make this auditable at row level.
final class Commentary {
  const Commentary({
    required this.id,
    required this.verseId,
    required this.tradition,
    required this.author,
    required this.sourceUrl,
    required this.license,
    required this.createdAt,
    this.textEnglish,
    this.textSanskrit,
    this.translator,
  });

  final String id;
  final String verseId;
  final String tradition;
  final String author;
  final String? textEnglish;
  final String? textSanskrit;
  final String? translator;
  final String sourceUrl;
  final String license;
  final DateTime createdAt;
}
