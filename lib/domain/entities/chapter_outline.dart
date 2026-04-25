/// One navigable chapter row derived from the verses table.
final class ChapterOutline {
  const ChapterOutline({
    required this.chapterNum,
    this.bookNum,
    this.chapterLabel,
  });

  final int chapterNum;
  final int? bookNum;
  final String? chapterLabel;
}
