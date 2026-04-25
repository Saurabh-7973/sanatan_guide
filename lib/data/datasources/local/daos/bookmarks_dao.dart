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

  /// Bookmarks enriched with first line of Sanskrit + scripture code.
  Stream<List<EnrichedBookmark>> watchAllEnriched() {
    final q = customSelect(
      'SELECT b.verse_id, b.saved_at, v.sanskrit, v.scripture '
      'FROM bookmarks b LEFT JOIN verses v ON b.verse_id = v.id '
      'ORDER BY b.saved_at DESC',
      readsFrom: {bookmarksTable, db.versesTable},
    );
    return q.watch().map((rows) => rows.map((r) {
          return EnrichedBookmark(
            verseId: r.read<String>('verse_id'),
            savedAt: r.read<DateTime>('saved_at'),
            sanskritPreview: r.readNullable<String>('sanskrit'),
            scriptureCode: r.readNullable<String>('scripture'),
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
    this.scriptureCode,
  });

  final String verseId;
  final DateTime savedAt;
  final String? sanskritPreview;
  final String? scriptureCode;
}
