import 'package:drift/drift.dart';
import 'package:sanatan_guide/data/datasources/local/app_database.dart';
import 'package:sanatan_guide/data/datasources/local/tables/bookmarks_table.dart';
import 'package:sanatan_guide/data/datasources/local/tables/commentaries_table.dart';
import 'package:sanatan_guide/data/datasources/local/tables/verse_explanations_table.dart';
import 'package:sanatan_guide/data/datasources/local/tables/verses_table.dart';
import 'package:sanatan_guide/domain/entities/chapter_outline.dart';

part 'scripture_dao.g.dart';

/// Sentinel for NULL [book_num] in ordering comparisons (SQLite IFNULL).
const _nullBookSentinel = -9223372036854775808;

@DriftAccessor(
  tables: [
    VersesTable,
    BookmarksTable,
    VerseExplanationsTable,
    CommentariesTable,
  ],
)
class ScriptureDao extends DatabaseAccessor<AppDatabase>
    with _$ScriptureDaoMixin {
  ScriptureDao(super.db);

  // ── Queries ───────────────────────────────────────────────────────────────

  /// Returns verse of the day by selecting a verse based on day-of-year.
  ///
  /// Prefers Bhagavad Gita verses (best data quality with Sanskrit +
  /// clean English translations). Falls back to any verse with non-empty
  /// Sanskrit if Gita verses aren't available.
  Future<VersesTableData?> getVerseOfDay() async {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;

    // Try Bhagavad Gita first — cleanest data
    final gitaVerse = await _verseOfDayFrom(
      dayOfYear,
      filter: (t) =>
          t.scripture.equals('bhagavad_gita') &
          t.sanskrit.length.isBiggerThanValue(0),
    );
    if (gitaVerse != null) return gitaVerse;

    // Fallback: any verse with Sanskrit text
    final anyVerse = await _verseOfDayFrom(
      dayOfYear,
      filter: (t) => t.sanskrit.length.isBiggerThanValue(0),
    );
    if (anyVerse != null) return anyVerse;

    // Last resort: any verse at all
    return _verseOfDayFrom(dayOfYear);
  }

  Future<VersesTableData?> _verseOfDayFrom(
    int dayOfYear, {
    Expression<bool> Function($VersesTableTable t)? filter,
  }) async {
    final countCol = db.versesTable.id.count();
    final countQuery = selectOnly(db.versesTable)..addColumns([countCol]);
    if (filter != null) countQuery.where(filter(db.versesTable));

    final count = await countQuery
        .map((row) => row.read(countCol) ?? 0)
        .getSingle();

    if (count == 0) return null;

    final query = select(db.versesTable)
      ..orderBy([(t) => OrderingTerm(expression: t.id)])
      ..limit(1, offset: dayOfYear % count);
    if (filter != null) query.where((t) => filter(t));

    return query.getSingleOrNull();
  }

  /// Returns a single verse by composite ID or null.
  Future<VersesTableData?> getVerseById(String id) =>
      (select(db.versesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// AI-generated explanation for a verse, if present.
  Future<VerseExplanationsTableData?> getVerseExplanationByVerseId(
    String verseId,
  ) =>
      (select(db.verseExplanationsTable)
            ..where((t) => t.verseId.equals(verseId)))
          .getSingleOrNull();

  /// Inserts or replaces the AI-generated explanation for [verseId].
  Future<void> upsertVerseExplanation({
    required String verseId,
    required String explanationText,
    required String modelVersion,
  }) =>
      into(db.verseExplanationsTable).insertOnConflictUpdate(
        VerseExplanationsTableCompanion.insert(
          verseId: verseId,
          explanationText: explanationText,
          generatedAt: DateTime.now(),
          modelVersion: modelVersion,
        ),
      );

  /// Scholarly commentaries for a verse, grouped in insertion order.
  /// Returns an empty list when none are seeded for [verseId].
  Future<List<CommentariesTableData>> getCommentariesByVerseId(
    String verseId,
  ) =>
      (select(db.commentariesTable)
            ..where((t) => t.verseId.equals(verseId))
            ..orderBy([(t) => OrderingTerm(expression: t.tradition)]))
          .get();

  /// Returns all verses for a given chapter, ordered by verseNum.
  /// When [bookNum] is set, restricts to that book/skanda/kanda (multi-level texts).
  Future<List<VersesTableData>> getChapter({
    required String scriptureCode,
    required int chapterNum,
    int? bookNum,
  }) =>
      (select(db.versesTable)
            ..where(
              (t) {
                var w = t.scripture.equals(scriptureCode) &
                    t.chapterNum.equals(chapterNum);
                if (bookNum != null) {
                  w = w & t.bookNum.equals(bookNum);
                }
                return w;
              },
            )
            ..orderBy([(t) => OrderingTerm(expression: t.verseNum)]))
          .get();

  /// Full-text search across all text columns.
  /// Uses FTS5 for queries of 2+ chars; falls back to LIKE for single chars.
  Future<List<VersesTableData>> search(String query) async {
    if (query.length < 2) {
      final q = '%$query%';
      return (select(db.versesTable)
            ..where(
              (t) =>
                  t.sanskrit.like(q) |
                  t.hindi.like(q) |
                  t.english.like(q) |
                  t.transliteration.like(q),
            )
            ..limit(50))
          .get();
    }

    // Build FTS5 query: each word gets prefix matching (term*)
    // "karma yoga" → "karma* yoga*" (implicit AND).
    // Strip every non letter/digit (incl. Devanāgarī-safe) so FTS5 special
    // chars never reach the parser — e.g. "bg 2.47" would otherwise become
    // `2.47*` and throw `fts5: syntax error near "."`. Coordinate queries
    // are handled separately by the search screen's direct-match path.
    final ftsQuery = query
        .split(RegExp(r'\s+'))
        .map((w) =>
            w.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), ''))
        .where((w) => w.isNotEmpty)
        .map((w) => '$w*')
        .join(' ');

    if (ftsQuery.isEmpty) return [];

    final results = await db.customSelect(
      'SELECT v.* FROM verses v '
      'JOIN verses_fts ON verses_fts.rowid = v.rowid '
      'WHERE verses_fts MATCH ? '
      'LIMIT 50',
      variables: [Variable.withString(ftsQuery)],
      readsFrom: {db.versesTable},
    ).get();

    return results.map((row) => db.versesTable.map(row.data)).toList();
  }

  /// Increments read count (SQL-side). No-op for unknown ids (0 rows updated).
  Future<void> incrementReadCount(String verseId) async {
    await customUpdate(
      'UPDATE verses SET read_count = read_count + 1 WHERE id = ?',
      variables: [Variable<String>(verseId)],
      updates: {versesTable},
    );
  }

  /// Updates the personal note for a verse.
  /// Pass null to clear the note.
  Future<void> updateNoteText(String id, String? noteText) async {
    await (update(db.versesTable)..where((t) => t.id.equals(id)))
        .write(VersesTableCompanion(noteText: Value(noteText)));
  }

  /// Inserts or removes a row in [bookmarksTable] and mirrors [isBookmarked]
  /// on [versesTable]. Returns the updated verse row, or null if [id] is unknown.
  Future<VersesTableData?> toggleBookmark(String id) async {
    final verse = await getVerseById(id);
    if (verse == null) return null;

    final existing = await (select(db.bookmarksTable)
          ..where((t) => t.verseId.equals(id)))
        .getSingleOrNull();

    final bool nowBookmarked;
    if (existing != null) {
      await (delete(db.bookmarksTable)..where((t) => t.verseId.equals(id)))
          .go();
      nowBookmarked = false;
    } else {
      await into(db.bookmarksTable).insert(
        BookmarksTableCompanion.insert(
          verseId: id,
          savedAt: DateTime.now(),
        ),
      );
      nowBookmarked = true;
    }

    await (update(db.versesTable)..where((t) => t.id.equals(id))).write(
      VersesTableCompanion(isBookmarked: Value(nowBookmarked)),
    );

    return getVerseById(id);
  }

  /// How many verses in this chapter have been read at least once.
  Future<int> getReadVerseCountInChapter({
    required String scriptureCode,
    required int chapterNum,
    int? bookNum,
  }) async {
    final countExpr = db.versesTable.id.count();
    return (selectOnly(db.versesTable)
          ..addColumns([countExpr])
          ..where(
            () {
              var w = db.versesTable.scripture.equals(scriptureCode) &
                  db.versesTable.chapterNum.equals(chapterNum) &
                  db.versesTable.readCount.isBiggerThan(const Constant(0));
              if (bookNum != null) {
                w = w & db.versesTable.bookNum.equals(bookNum);
              }
              return w;
            }(),
          ))
        .map((row) => row.read(countExpr) ?? 0)
        .getSingle();
  }

  /// Returns total verse count for a given chapter.
  Future<int> getTotalVerseCountInChapter({
    required String scriptureCode,
    required int chapterNum,
    int? bookNum,
  }) async {
    final countExpr = db.versesTable.id.count();
    return (selectOnly(db.versesTable)
          ..addColumns([countExpr])
          ..where(
            () {
              var w = db.versesTable.scripture.equals(scriptureCode) &
                  db.versesTable.chapterNum.equals(chapterNum);
              if (bookNum != null) {
                w = w & db.versesTable.bookNum.equals(bookNum);
              }
              return w;
            }(),
          ))
        .map((row) => row.read(countExpr) ?? 0)
        .getSingle();
  }

  /// Returns the highest verse_num for a given chapter.
  /// Returns null if no verses exist for that chapter.
  Future<int?> getMaxVerseNumInChapter({
    required String scriptureCode,
    required int chapterNum,
    int? bookNum,
  }) async {
    final maxExpr = db.versesTable.verseNum.max();
    return (selectOnly(db.versesTable)
          ..addColumns([maxExpr])
          ..where(
            () {
              var w = db.versesTable.scripture.equals(scriptureCode) &
                  db.versesTable.chapterNum.equals(chapterNum);
              if (bookNum != null) {
                w = w & db.versesTable.bookNum.equals(bookNum);
              }
              return w;
            }(),
          ))
        .map((row) => row.read(maxExpr))
        .getSingleOrNull();
  }

  /// Previous verse in canonical (book_num, chapter_num, verse_num, id) order.
  /// Accepts a pre-loaded [current] row to avoid a redundant DB round-trip.
  Future<VersesTableData?> getPrevVerse(
    String scriptureCode,
    String currentId, {
    VersesTableData? current,
  }) async {
    current ??= await getVerseById(currentId);
    if (current == null || current.scripture != scriptureCode) return null;
    final bookVal = current.bookNum ?? _nullBookSentinel;
    final rows = await customSelect(
      '''
SELECT * FROM verses WHERE scripture = ? AND (
  IFNULL(book_num, $_nullBookSentinel) < ?
  OR (IFNULL(book_num, $_nullBookSentinel) = ? AND chapter_num < ?)
  OR (IFNULL(book_num, $_nullBookSentinel) = ? AND chapter_num = ? AND verse_num < ?)
)
ORDER BY IFNULL(book_num, $_nullBookSentinel) DESC, chapter_num DESC, verse_num DESC, id DESC
LIMIT 1
''',
      variables: [
        Variable<String>(scriptureCode),
        Variable<int>(bookVal),
        Variable<int>(bookVal),
        Variable<int>(current.chapterNum),
        Variable<int>(bookVal),
        Variable<int>(current.chapterNum),
        Variable<int>(current.verseNum),
      ],
      readsFrom: {versesTable},
    ).map((row) => versesTable.map(row.data)).getSingleOrNull();
    return rows;
  }

  /// Next verse in canonical (book_num, chapter_num, verse_num, id) order.
  /// Accepts a pre-loaded [current] row to avoid a redundant DB round-trip.
  Future<VersesTableData?> getNextVerse(
    String scriptureCode,
    String currentId, {
    VersesTableData? current,
  }) async {
    current ??= await getVerseById(currentId);
    if (current == null || current.scripture != scriptureCode) return null;
    final bookVal = current.bookNum ?? _nullBookSentinel;
    final rows = await customSelect(
      '''
SELECT * FROM verses WHERE scripture = ? AND (
  IFNULL(book_num, $_nullBookSentinel) > ?
  OR (IFNULL(book_num, $_nullBookSentinel) = ? AND chapter_num > ?)
  OR (IFNULL(book_num, $_nullBookSentinel) = ? AND chapter_num = ? AND verse_num > ?)
)
ORDER BY IFNULL(book_num, $_nullBookSentinel) ASC, chapter_num ASC, verse_num ASC, id ASC
LIMIT 1
''',
      variables: [
        Variable<String>(scriptureCode),
        Variable<int>(bookVal),
        Variable<int>(bookVal),
        Variable<int>(current.chapterNum),
        Variable<int>(bookVal),
        Variable<int>(current.chapterNum),
        Variable<int>(current.verseNum),
      ],
      readsFrom: {versesTable},
    ).map((row) => versesTable.map(row.data)).getSingleOrNull();
    return rows;
  }

  /// Distinct chapters with [chapter_label] taken from the lowest [verse_num] row.
  Future<List<ChapterOutline>> getChapterOutlines(String scriptureCode) async {
    final rows = await customSelect(
      '''
SELECT chapter_num, book_num, chapter_label
FROM (
  SELECT chapter_num, book_num, chapter_label,
    ROW_NUMBER() OVER (
      PARTITION BY scripture, IFNULL(book_num, $_nullBookSentinel), chapter_num
      ORDER BY verse_num ASC
    ) AS rn
  FROM verses
  WHERE scripture = ?
) WHERE rn = 1
ORDER BY IFNULL(book_num, $_nullBookSentinel) ASC, chapter_num ASC
''',
      variables: [Variable<String>(scriptureCode)],
      readsFrom: {versesTable},
    ).get();

    return rows
        .map(
          (row) => ChapterOutline(
            chapterNum: row.read<int>('chapter_num'),
            bookNum: row.readNullable<int>('book_num'),
            chapterLabel: row.readNullable<String>('chapter_label'),
          ),
        )
        .toList();
  }
}
