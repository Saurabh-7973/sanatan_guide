// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the BookmarksDao — keepAlive since bookmarks are
/// accessed from multiple screens.

@ProviderFor(bookmarksDao)
final bookmarksDaoProvider = BookmarksDaoProvider._();

/// Provides the BookmarksDao — keepAlive since bookmarks are
/// accessed from multiple screens.

final class BookmarksDaoProvider extends $FunctionalProvider<
        AsyncValue<BookmarksDao>, BookmarksDao, FutureOr<BookmarksDao>>
    with $FutureModifier<BookmarksDao>, $FutureProvider<BookmarksDao> {
  /// Provides the BookmarksDao — keepAlive since bookmarks are
  /// accessed from multiple screens.
  BookmarksDaoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bookmarksDaoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bookmarksDaoHash();

  @$internal
  @override
  $FutureProviderElement<BookmarksDao> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<BookmarksDao> create(Ref ref) {
    return bookmarksDao(ref);
  }
}

String _$bookmarksDaoHash() => r'13dcbdb1483dac415a8d482f1ad2f4a94f98e620';

/// Stream of saved bookmarks (verse id + saved time), most recent first.

@ProviderFor(bookmarkedVerses)
final bookmarkedVersesProvider = BookmarkedVersesProvider._();

/// Stream of saved bookmarks (verse id + saved time), most recent first.

final class BookmarkedVersesProvider extends $FunctionalProvider<
        AsyncValue<List<BookmarkListEntry>>,
        List<BookmarkListEntry>,
        Stream<List<BookmarkListEntry>>>
    with
        $FutureModifier<List<BookmarkListEntry>>,
        $StreamProvider<List<BookmarkListEntry>> {
  /// Stream of saved bookmarks (verse id + saved time), most recent first.
  BookmarkedVersesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bookmarkedVersesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bookmarkedVersesHash();

  @$internal
  @override
  $StreamProviderElement<List<BookmarkListEntry>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<BookmarkListEntry>> create(Ref ref) {
    return bookmarkedVerses(ref);
  }
}

String _$bookmarkedVersesHash() => r'4484c61ccb40a59aa938585dfae619c4f86fff40';

/// Enriched bookmarks (with Sanskrit preview + scripture code).

@ProviderFor(enrichedBookmarks)
final enrichedBookmarksProvider = EnrichedBookmarksProvider._();

/// Enriched bookmarks (with Sanskrit preview + scripture code).

final class EnrichedBookmarksProvider extends $FunctionalProvider<
        AsyncValue<List<EnrichedBookmark>>,
        List<EnrichedBookmark>,
        Stream<List<EnrichedBookmark>>>
    with
        $FutureModifier<List<EnrichedBookmark>>,
        $StreamProvider<List<EnrichedBookmark>> {
  /// Enriched bookmarks (with Sanskrit preview + scripture code).
  EnrichedBookmarksProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'enrichedBookmarksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$enrichedBookmarksHash();

  @$internal
  @override
  $StreamProviderElement<List<EnrichedBookmark>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<EnrichedBookmark>> create(Ref ref) {
    return enrichedBookmarks(ref);
  }
}

String _$enrichedBookmarksHash() => r'3acfe5fe6ec094293797bf175627ed071bdc0ccd';

/// Whether a specific verse is bookmarked — used by verse detail screen.

@ProviderFor(isBookmarked)
final isBookmarkedProvider = IsBookmarkedFamily._();

/// Whether a specific verse is bookmarked — used by verse detail screen.

final class IsBookmarkedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether a specific verse is bookmarked — used by verse detail screen.
  IsBookmarkedProvider._(
      {required IsBookmarkedFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'isBookmarkedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isBookmarkedHash();

  @override
  String toString() {
    return r'isBookmarkedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isBookmarked(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsBookmarkedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isBookmarkedHash() => r'2d34dea2fe8f9b914fb318d9a520b9265a3a03ab';

/// Whether a specific verse is bookmarked — used by verse detail screen.

final class IsBookmarkedFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, String> {
  IsBookmarkedFamily._()
      : super(
          retry: null,
          name: r'isBookmarkedProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Whether a specific verse is bookmarked — used by verse detail screen.

  IsBookmarkedProvider call(
    String verseId,
  ) =>
      IsBookmarkedProvider._(argument: verseId, from: this);

  @override
  String toString() => r'isBookmarkedProvider';
}

/// All bookmarked verse IDs as a reactive set — single stream
/// replacing N individual [isBookmarked] watches in list views.

@ProviderFor(bookmarkedIds)
final bookmarkedIdsProvider = BookmarkedIdsProvider._();

/// All bookmarked verse IDs as a reactive set — single stream
/// replacing N individual [isBookmarked] watches in list views.

final class BookmarkedIdsProvider extends $FunctionalProvider<
        AsyncValue<Set<String>>, Set<String>, Stream<Set<String>>>
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  /// All bookmarked verse IDs as a reactive set — single stream
  /// replacing N individual [isBookmarked] watches in list views.
  BookmarkedIdsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bookmarkedIdsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bookmarkedIdsHash();

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    return bookmarkedIds(ref);
  }
}

String _$bookmarkedIdsHash() => r'fed882321a167e3fc49f972732663b7693776f82';
