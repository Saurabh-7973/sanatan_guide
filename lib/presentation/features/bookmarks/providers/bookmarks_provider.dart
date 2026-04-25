import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanatan_guide/data/datasources/local/app_database.dart';
import 'package:sanatan_guide/data/datasources/local/app_database_provider.dart';
import 'package:sanatan_guide/data/datasources/local/daos/bookmarks_dao.dart';

part 'bookmarks_provider.g.dart';

/// Verse id + saved time for bookmark lists.
/// BookmarksTableData cannot be used in @riverpod return types —
/// riverpod_generator rejects Drift rows.
class BookmarkListEntry {
  const BookmarkListEntry({
    required this.verseId,
    required this.savedAt,
  });

  final String verseId;
  final DateTime savedAt;
}

BookmarkListEntry _toEntry(BookmarksTableData r) => BookmarkListEntry(
      verseId: r.verseId,
      savedAt: r.savedAt,
    );

/// Provides the BookmarksDao — keepAlive since bookmarks are
/// accessed from multiple screens.
@Riverpod(keepAlive: true)
Future<BookmarksDao> bookmarksDao(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.bookmarksDao;
}

/// Stream of saved bookmarks (verse id + saved time), most recent first.
@riverpod
Stream<List<BookmarkListEntry>> bookmarkedVerses(Ref ref) {
  return ref.watch(bookmarksDaoProvider).when(
        data: (dao) =>
            dao.watchAll().map((rows) => rows.map(_toEntry).toList()),
        loading: Stream<List<BookmarkListEntry>>.empty,
        error: Stream<List<BookmarkListEntry>>.error,
      );
}

/// Enriched bookmarks (with Sanskrit preview + scripture code).
@riverpod
Stream<List<EnrichedBookmark>> enrichedBookmarks(Ref ref) {
  return ref.watch(bookmarksDaoProvider).when(
        data: (dao) => dao.watchAllEnriched(),
        loading: Stream<List<EnrichedBookmark>>.empty,
        error: Stream<List<EnrichedBookmark>>.error,
      );
}

/// Whether a specific verse is bookmarked — used by verse detail screen.
@riverpod
Stream<bool> isBookmarked(Ref ref, String verseId) {
  return ref.watch(bookmarksDaoProvider).when(
        data: (dao) => dao.watchIsBookmarked(verseId),
        loading: Stream<bool>.empty,
        error: Stream<bool>.error,
      );
}

/// All bookmarked verse IDs as a reactive set — single stream
/// replacing N individual [isBookmarked] watches in list views.
@riverpod
Stream<Set<String>> bookmarkedIds(Ref ref) {
  return ref.watch(bookmarksDaoProvider).when(
        data: (dao) => dao.watchBookmarkedIds(),
        loading: Stream<Set<String>>.empty,
        error: Stream<Set<String>>.error,
      );
}
