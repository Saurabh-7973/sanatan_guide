// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reactive current streak count.
/// Invalidate after calling recordReadingToday().

@ProviderFor(currentStreak)
final currentStreakProvider = CurrentStreakProvider._();

/// Reactive current streak count.
/// Invalidate after calling recordReadingToday().

final class CurrentStreakProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Reactive current streak count.
  /// Invalidate after calling recordReadingToday().
  CurrentStreakProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentStreakProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentStreakHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return currentStreak(ref);
  }
}

String _$currentStreakHash() => r'fcfd2cfaab170d075004dfc6f85c9950f9d1a70d';

/// Reactive read history — set of yyyy-MM-dd strings.
/// Invalidate after calling recordReadingToday().

@ProviderFor(readHistory)
final readHistoryProvider = ReadHistoryProvider._();

/// Reactive read history — set of yyyy-MM-dd strings.
/// Invalidate after calling recordReadingToday().

final class ReadHistoryProvider extends $FunctionalProvider<
        AsyncValue<Set<String>>, Set<String>, FutureOr<Set<String>>>
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  /// Reactive read history — set of yyyy-MM-dd strings.
  /// Invalidate after calling recordReadingToday().
  ReadHistoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'readHistoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$readHistoryHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return readHistory(ref);
  }
}

String _$readHistoryHash() => r'dd622c05872ffa250b4e2764de1bf7bb0dcf2996';

/// Last-read verse. Invalidate after reading a new verse.

@ProviderFor(lastReadVerse)
final lastReadVerseProvider = LastReadVerseProvider._();

/// Last-read verse. Invalidate after reading a new verse.

final class LastReadVerseProvider extends $FunctionalProvider<
        AsyncValue<
            ({
              String scriptureCode,
              String verseId,
            })?>,
        ({
          String scriptureCode,
          String verseId,
        })?,
        FutureOr<
            ({
              String scriptureCode,
              String verseId,
            })?>>
    with
        $FutureModifier<
            ({
              String scriptureCode,
              String verseId,
            })?>,
        $FutureProvider<
            ({
              String scriptureCode,
              String verseId,
            })?> {
  /// Last-read verse. Invalidate after reading a new verse.
  LastReadVerseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'lastReadVerseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lastReadVerseHash();

  @$internal
  @override
  $FutureProviderElement<
      ({
        String scriptureCode,
        String verseId,
      })?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<
      ({
        String scriptureCode,
        String verseId,
      })?> create(Ref ref) {
    return lastReadVerse(ref);
  }
}

String _$lastReadVerseHash() => r'f6d8d60d906ff6aaabeaa39645e107bd27839804';
