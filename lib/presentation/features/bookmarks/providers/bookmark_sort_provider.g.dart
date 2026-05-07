// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_sort_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// User-controlled sort tab on the Bookmarks (Pothī) screen. Defaults
/// to [BookmarkSort.recent].

@ProviderFor(BookmarkSortNotifier)
final bookmarkSortProvider = BookmarkSortNotifierProvider._();

/// User-controlled sort tab on the Bookmarks (Pothī) screen. Defaults
/// to [BookmarkSort.recent].
final class BookmarkSortNotifierProvider
    extends $NotifierProvider<BookmarkSortNotifier, BookmarkSort> {
  /// User-controlled sort tab on the Bookmarks (Pothī) screen. Defaults
  /// to [BookmarkSort.recent].
  BookmarkSortNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bookmarkSortProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bookmarkSortNotifierHash();

  @$internal
  @override
  BookmarkSortNotifier create() => BookmarkSortNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookmarkSort value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookmarkSort>(value),
    );
  }
}

String _$bookmarkSortNotifierHash() =>
    r'44812dca66d09a9c687ab206ec997504778312c5';

/// User-controlled sort tab on the Bookmarks (Pothī) screen. Defaults
/// to [BookmarkSort.recent].

abstract class _$BookmarkSortNotifier extends $Notifier<BookmarkSort> {
  BookmarkSort build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BookmarkSort, BookmarkSort>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<BookmarkSort, BookmarkSort>,
        BookmarkSort,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
