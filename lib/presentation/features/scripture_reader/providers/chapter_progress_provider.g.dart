// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns how many verses have been read in a given chapter.

@ProviderFor(chapterReadCount)
final chapterReadCountProvider = ChapterReadCountFamily._();

/// Returns how many verses have been read in a given chapter.

final class ChapterReadCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Returns how many verses have been read in a given chapter.
  ChapterReadCountProvider._(
      {required ChapterReadCountFamily super.from,
      required (
        String,
        int,
        int?,
      )
          super.argument})
      : super(
          retry: null,
          name: r'chapterReadCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chapterReadCountHash();

  @override
  String toString() {
    return r'chapterReadCountProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as (
      String,
      int,
      int?,
    );
    return chapterReadCount(
      ref,
      argument.$1,
      argument.$2,
      argument.$3,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterReadCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chapterReadCountHash() => r'2a58a921fde66f437d66cf354a1021c9daa55463';

/// Returns how many verses have been read in a given chapter.

final class ChapterReadCountFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<int>,
            (
              String,
              int,
              int?,
            )> {
  ChapterReadCountFamily._()
      : super(
          retry: null,
          name: r'chapterReadCountProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Returns how many verses have been read in a given chapter.

  ChapterReadCountProvider call(
    String scriptureCode,
    int chapterNum,
    int? bookNum,
  ) =>
      ChapterReadCountProvider._(argument: (
        scriptureCode,
        chapterNum,
        bookNum,
      ), from: this);

  @override
  String toString() => r'chapterReadCountProvider';
}
