/// One navigable chapter row derived from the verses table.
final class ChapterOutline {
  const ChapterOutline({
    required this.chapterNum,
    this.bookNum,
    this.chapterLabel,
    this.verseCount = 0,
  });

  final int chapterNum;
  final int? bookNum;
  final String? chapterLabel;
  // Total verses in this chapter; populated by the outlines DAO query so the
  // Resume card and time-left estimate can render for every scripture, not
  // just Bhagavad Gītā (which carries its own typed metadata).
  final int verseCount;
}
