// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_browser_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all verses for a given chapter.
/// Family keyed by (scriptureCode, chapterNum).
/// AutoDispose — frees memory when the user navigates away from the chapter.

@ProviderFor(chapterVerses)
final chapterVersesProvider = ChapterVersesFamily._();

/// Fetches all verses for a given chapter.
/// Family keyed by (scriptureCode, chapterNum).
/// AutoDispose — frees memory when the user navigates away from the chapter.

final class ChapterVersesProvider extends $FunctionalProvider<
        AsyncValue<Either<Failure, List<Verse>>>,
        Either<Failure, List<Verse>>,
        FutureOr<Either<Failure, List<Verse>>>>
    with
        $FutureModifier<Either<Failure, List<Verse>>>,
        $FutureProvider<Either<Failure, List<Verse>>> {
  /// Fetches all verses for a given chapter.
  /// Family keyed by (scriptureCode, chapterNum).
  /// AutoDispose — frees memory when the user navigates away from the chapter.
  ChapterVersesProvider._(
      {required ChapterVersesFamily super.from,
      required (
        String,
        int,
        int?,
      )
          super.argument})
      : super(
          retry: null,
          name: r'chapterVersesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chapterVersesHash();

  @override
  String toString() {
    return r'chapterVersesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Either<Failure, List<Verse>>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Either<Failure, List<Verse>>> create(Ref ref) {
    final argument = this.argument as (
      String,
      int,
      int?,
    );
    return chapterVerses(
      ref,
      argument.$1,
      argument.$2,
      argument.$3,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterVersesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chapterVersesHash() => r'22d26cc8d66b817a51a1e96d372b7abd1d19bb5d';

/// Fetches all verses for a given chapter.
/// Family keyed by (scriptureCode, chapterNum).
/// AutoDispose — frees memory when the user navigates away from the chapter.

final class ChapterVersesFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<Either<Failure, List<Verse>>>,
            (
              String,
              int,
              int?,
            )> {
  ChapterVersesFamily._()
      : super(
          retry: null,
          name: r'chapterVersesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Fetches all verses for a given chapter.
  /// Family keyed by (scriptureCode, chapterNum).
  /// AutoDispose — frees memory when the user navigates away from the chapter.

  ChapterVersesProvider call(
    String scriptureCode,
    int chapterNum,
    int? bookNum,
  ) =>
      ChapterVersesProvider._(argument: (
        scriptureCode,
        chapterNum,
        bookNum,
      ), from: this);

  @override
  String toString() => r'chapterVersesProvider';
}

/// Distinct chapters for a scripture (book + chapter + label from first verse).

@ProviderFor(chapterOutlines)
final chapterOutlinesProvider = ChapterOutlinesFamily._();

/// Distinct chapters for a scripture (book + chapter + label from first verse).

final class ChapterOutlinesProvider extends $FunctionalProvider<
        AsyncValue<List<ChapterOutline>>,
        List<ChapterOutline>,
        FutureOr<List<ChapterOutline>>>
    with
        $FutureModifier<List<ChapterOutline>>,
        $FutureProvider<List<ChapterOutline>> {
  /// Distinct chapters for a scripture (book + chapter + label from first verse).
  ChapterOutlinesProvider._(
      {required ChapterOutlinesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'chapterOutlinesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chapterOutlinesHash();

  @override
  String toString() {
    return r'chapterOutlinesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ChapterOutline>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ChapterOutline>> create(Ref ref) {
    final argument = this.argument as String;
    return chapterOutlines(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterOutlinesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chapterOutlinesHash() => r'eaf8c94e4500d8942b0e1c6fbe696d324db291d9';

/// Distinct chapters for a scripture (book + chapter + label from first verse).

final class ChapterOutlinesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ChapterOutline>>, String> {
  ChapterOutlinesFamily._()
      : super(
          retry: null,
          name: r'chapterOutlinesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Distinct chapters for a scripture (book + chapter + label from first verse).

  ChapterOutlinesProvider call(
    String scriptureCode,
  ) =>
      ChapterOutlinesProvider._(argument: scriptureCode, from: this);

  @override
  String toString() => r'chapterOutlinesProvider';
}
