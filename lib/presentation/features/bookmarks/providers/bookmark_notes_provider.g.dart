// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's personal note for a single bookmarked verse, or null when
/// no note is set. Backed by [BookmarkNotesService] (SharedPreferences).

@ProviderFor(bookmarkNote)
final bookmarkNoteProvider = BookmarkNoteFamily._();

/// The user's personal note for a single bookmarked verse, or null when
/// no note is set. Backed by [BookmarkNotesService] (SharedPreferences).

final class BookmarkNoteProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The user's personal note for a single bookmarked verse, or null when
  /// no note is set. Backed by [BookmarkNotesService] (SharedPreferences).
  BookmarkNoteProvider._(
      {required BookmarkNoteFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'bookmarkNoteProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bookmarkNoteHash();

  @override
  String toString() {
    return r'bookmarkNoteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return bookmarkNote(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BookmarkNoteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookmarkNoteHash() => r'4109b7bdb8c6ce61196283eaa88a281634f31fd0';

/// The user's personal note for a single bookmarked verse, or null when
/// no note is set. Backed by [BookmarkNotesService] (SharedPreferences).

final class BookmarkNoteFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  BookmarkNoteFamily._()
      : super(
          retry: null,
          name: r'bookmarkNoteProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// The user's personal note for a single bookmarked verse, or null when
  /// no note is set. Backed by [BookmarkNotesService] (SharedPreferences).

  BookmarkNoteProvider call(
    String verseId,
  ) =>
      BookmarkNoteProvider._(argument: verseId, from: this);

  @override
  String toString() => r'bookmarkNoteProvider';
}
