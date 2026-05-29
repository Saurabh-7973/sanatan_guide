import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanatan_guide/data/datasources/local/app_database_provider.dart';

part 'chapter_progress_provider.g.dart';

/// Returns how many verses have been read in a given chapter.
@riverpod
Future<int> chapterReadCount(
  Ref ref,
  String scriptureCode,
  int chapterNum,
  int? bookNum,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.scriptureDao.getReadVerseCountInChapter(
    scriptureCode: scriptureCode,
    chapterNum: chapterNum,
    bookNum: bookNum,
  );
}

/// Returns per-scripture read counts in a single query (`GROUP BY scripture`).
/// Map keys are scripture codes (`bhagavad_gita`, `rigveda`, …). Missing keys
/// mean zero. Invalidate after [markVerseRead] so Library reflects new reads.
///
/// `keepAlive: true` survives Library remounts (e.g. bottom-nav round-trips)
/// so the user doesn't see a flash of zero counts every time they return.
/// The provider is still invalidated on writes from verse_detail_page.dart.
@Riverpod(keepAlive: true)
Future<Map<String, int>> scriptureReadCounts(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.scriptureDao.getReadVerseCountsByScripture();
}

/// Per-chapter read counts within one scripture, keyed by "bookNum:chapterNum"
/// ("0:1" for flat texts, "1:1" for nested-id texts like Ṛgveda). One GROUP
/// BY query replaces N [chapterReadCountProvider] watches on long chapter
/// lists. Use [chapterReadCountFromMap] to read a single chapter's count.
@riverpod
Future<Map<String, int>> scriptureChapterReadCounts(
  Ref ref,
  String scriptureCode,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.scriptureDao.getReadVerseCountsForScripture(scriptureCode);
}

/// Helper for the keying convention used by [scriptureChapterReadCounts].
int chapterReadCountFromMap(
  Map<String, int> counts,
  int chapterNum, [
  int? bookNum,
]) =>
    counts['${bookNum ?? 0}:$chapterNum'] ?? 0;
