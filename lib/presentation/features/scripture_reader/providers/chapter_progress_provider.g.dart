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

/// Returns per-scripture read counts in a single query (`GROUP BY scripture`).
/// Map keys are scripture codes (`bhagavad_gita`, `rigveda`, …). Missing keys
/// mean zero. Invalidate after [markVerseRead] so Library reflects new reads.

@ProviderFor(scriptureReadCounts)
final scriptureReadCountsProvider = ScriptureReadCountsProvider._();

/// Returns per-scripture read counts in a single query (`GROUP BY scripture`).
/// Map keys are scripture codes (`bhagavad_gita`, `rigveda`, …). Missing keys
/// mean zero. Invalidate after [markVerseRead] so Library reflects new reads.

final class ScriptureReadCountsProvider extends $FunctionalProvider<
        AsyncValue<Map<String, int>>,
        Map<String, int>,
        FutureOr<Map<String, int>>>
    with $FutureModifier<Map<String, int>>, $FutureProvider<Map<String, int>> {
  /// Returns per-scripture read counts in a single query (`GROUP BY scripture`).
  /// Map keys are scripture codes (`bhagavad_gita`, `rigveda`, …). Missing keys
  /// mean zero. Invalidate after [markVerseRead] so Library reflects new reads.
  ScriptureReadCountsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scriptureReadCountsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scriptureReadCountsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, int>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, int>> create(Ref ref) {
    return scriptureReadCounts(ref);
  }
}

String _$scriptureReadCountsHash() =>
    r'c40b2e15d9e7531aebd4a4c5b7e72ef1b11fc052';

/// Per-chapter read counts within one scripture, keyed by "bookNum:chapterNum"
/// ("0:1" for flat texts, "1:1" for nested-id texts like Ṛgveda). One GROUP
/// BY query replaces N [chapterReadCountProvider] watches on long chapter
/// lists. Use [chapterReadCountFromMap] to read a single chapter's count.

@ProviderFor(scriptureChapterReadCounts)
final scriptureChapterReadCountsProvider = ScriptureChapterReadCountsFamily._();

/// Per-chapter read counts within one scripture, keyed by "bookNum:chapterNum"
/// ("0:1" for flat texts, "1:1" for nested-id texts like Ṛgveda). One GROUP
/// BY query replaces N [chapterReadCountProvider] watches on long chapter
/// lists. Use [chapterReadCountFromMap] to read a single chapter's count.

final class ScriptureChapterReadCountsProvider extends $FunctionalProvider<
        AsyncValue<Map<String, int>>,
        Map<String, int>,
        FutureOr<Map<String, int>>>
    with $FutureModifier<Map<String, int>>, $FutureProvider<Map<String, int>> {
  /// Per-chapter read counts within one scripture, keyed by "bookNum:chapterNum"
  /// ("0:1" for flat texts, "1:1" for nested-id texts like Ṛgveda). One GROUP
  /// BY query replaces N [chapterReadCountProvider] watches on long chapter
  /// lists. Use [chapterReadCountFromMap] to read a single chapter's count.
  ScriptureChapterReadCountsProvider._(
      {required ScriptureChapterReadCountsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'scriptureChapterReadCountsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scriptureChapterReadCountsHash();

  @override
  String toString() {
    return r'scriptureChapterReadCountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, int>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, int>> create(Ref ref) {
    final argument = this.argument as String;
    return scriptureChapterReadCounts(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ScriptureChapterReadCountsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scriptureChapterReadCountsHash() =>
    r'1d711141a695c19f7fb0c2f314371498fdc32b43';

/// Per-chapter read counts within one scripture, keyed by "bookNum:chapterNum"
/// ("0:1" for flat texts, "1:1" for nested-id texts like Ṛgveda). One GROUP
/// BY query replaces N [chapterReadCountProvider] watches on long chapter
/// lists. Use [chapterReadCountFromMap] to read a single chapter's count.

final class ScriptureChapterReadCountsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, int>>, String> {
  ScriptureChapterReadCountsFamily._()
      : super(
          retry: null,
          name: r'scriptureChapterReadCountsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Per-chapter read counts within one scripture, keyed by "bookNum:chapterNum"
  /// ("0:1" for flat texts, "1:1" for nested-id texts like Ṛgveda). One GROUP
  /// BY query replaces N [chapterReadCountProvider] watches on long chapter
  /// lists. Use [chapterReadCountFromMap] to read a single chapter's count.

  ScriptureChapterReadCountsProvider call(
    String scriptureCode,
  ) =>
      ScriptureChapterReadCountsProvider._(argument: scriptureCode, from: this);

  @override
  String toString() => r'scriptureChapterReadCountsProvider';
}
