import 'package:drift/drift.dart';
import 'package:sanatan_guide/data/datasources/local/app_database.dart';
import 'package:sanatan_guide/data/datasources/local/tables/bookmarks_table.dart';

part 'bookmarks_dao.g.dart';

@DriftAccessor(tables: [BookmarksTable])
class BookmarksDao extends DatabaseAccessor<AppDatabase>
    with _$BookmarksDaoMixin {
  BookmarksDao(super.db);

  /// All bookmarks ordered by most recently saved first.
  Stream<List<BookmarksTableData>> watchAll() => (select(bookmarksTable)
        ..orderBy([
          (t) => OrderingTerm(
                expression: t.savedAt,
                mode: OrderingMode.desc,
              ),
        ]))
      .watch();

  /// Bookmarks enriched with Sanskrit, English, verse coordinates, and the
  /// user's personal note (`verses.note_text` — the same store the verse
  /// detail screen writes, so a note saved there shows here).
  Stream<List<EnrichedBookmark>> watchAllEnriched() {
    final q = customSelect(
      'SELECT b.verse_id, b.saved_at, v.sanskrit, v.english, '
      'v.scripture, v.chapter_num, v.verse_num, v.book_num, v.note_text '
      'FROM bookmarks b LEFT JOIN verses v ON b.verse_id = v.id '
      'ORDER BY b.saved_at DESC',
      readsFrom: {bookmarksTable, db.versesTable},
    );
    return q.watch().map((rows) => rows.map((r) {
          return EnrichedBookmark(
            verseId: r.read<String>('verse_id'),
            savedAt: r.read<DateTime>('saved_at'),
            sanskritPreview: r.readNullable<String>('sanskrit'),
            englishPreview: r.readNullable<String>('english'),
            scriptureCode: r.readNullable<String>('scripture'),
            chapterNum: r.readNullable<int>('chapter_num'),
            verseNum: r.readNullable<int>('verse_num'),
            bookNum: r.readNullable<int>('book_num'),
            noteText: r.readNullable<String>('note_text'),
          );
        }).toList());
  }

  Future<bool> isBookmarked(String verseId) async {
    final row = await (select(bookmarksTable)
          ..where((t) => t.verseId.equals(verseId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> toggleBookmark(String verseId) async {
    final existing = await (select(bookmarksTable)
          ..where((t) => t.verseId.equals(verseId)))
        .getSingleOrNull();

    if (existing != null) {
      await (delete(bookmarksTable)..where((t) => t.verseId.equals(verseId)))
          .go();
    } else {
      await into(bookmarksTable).insert(
        BookmarksTableCompanion.insert(
          verseId: verseId,
          savedAt: DateTime.now(),
        ),
      );
    }
  }

  Stream<bool> watchIsBookmarked(String verseId) =>
      (select(bookmarksTable)..where((t) => t.verseId.equals(verseId)))
          .watch()
          .map((rows) => rows.isNotEmpty);

  /// All bookmarked verse IDs as a reactive set — single stream for
  /// an entire chapter list instead of N individual watches.
  Stream<Set<String>> watchBookmarkedIds() =>
      (select(bookmarksTable)).watch().map(
            (rows) => rows.map((r) => r.verseId).toSet(),
          );
}

class EnrichedBookmark {
  const EnrichedBookmark({
    required this.verseId,
    required this.savedAt,
    this.sanskritPreview,
    this.englishPreview,
    this.scriptureCode,
    this.chapterNum,
    this.verseNum,
    this.bookNum,
    this.noteText,
  });

  final String verseId;
  final DateTime savedAt;
  final String? sanskritPreview;
  final String? englishPreview;
  final String? scriptureCode;
  final int? chapterNum;
  final int? verseNum;
  final int? bookNum;

  /// The user's personal note for this verse (`verses.note_text`), or null.
  final String? noteText;
}
