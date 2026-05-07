import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bookmark_sort_provider.g.dart';

enum BookmarkSort { recent, byScripture }

/// User-controlled sort tab on the Bookmarks (Pothī) screen. Defaults
/// to [BookmarkSort.recent].
@riverpod
class BookmarkSortNotifier extends _$BookmarkSortNotifier {
  @override
  BookmarkSort build() => BookmarkSort.recent;

  void select(BookmarkSort sort) => state = sort;
}
