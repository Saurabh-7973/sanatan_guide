// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

final class SharedPreferencesProvider extends $FunctionalProvider<
        AsyncValue<SharedPreferences>,
        SharedPreferences,
        FutureOr<SharedPreferences>>
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  SharedPreferencesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sharedPreferencesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'ad13470fe866595ad0f58a3e26f11048d94ef22e';

@ProviderFor(TransliterationEnabled)
final transliterationEnabledProvider = TransliterationEnabledProvider._();

final class TransliterationEnabledProvider
    extends $AsyncNotifierProvider<TransliterationEnabled, bool> {
  TransliterationEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transliterationEnabledProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transliterationEnabledHash();

  @$internal
  @override
  TransliterationEnabled create() => TransliterationEnabled();
}

String _$transliterationEnabledHash() =>
    r'ee5eae7919abefa9ada88ffbb1efe9f58c46bb94';

abstract class _$TransliterationEnabled extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<bool>, bool>,
        AsyncValue<bool>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(getVerseByIdUseCase)
final getVerseByIdUseCaseProvider = GetVerseByIdUseCaseProvider._();

final class GetVerseByIdUseCaseProvider extends $FunctionalProvider<
        AsyncValue<GetVerseByIdUseCase>,
        GetVerseByIdUseCase,
        FutureOr<GetVerseByIdUseCase>>
    with
        $FutureModifier<GetVerseByIdUseCase>,
        $FutureProvider<GetVerseByIdUseCase> {
  GetVerseByIdUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getVerseByIdUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getVerseByIdUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<GetVerseByIdUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GetVerseByIdUseCase> create(Ref ref) {
    return getVerseByIdUseCase(ref);
  }
}

String _$getVerseByIdUseCaseHash() =>
    r'8e35ef4c8183a1726a7e016f7e9c5c1f100bf8c0';

@ProviderFor(verseDetail)
final verseDetailProvider = VerseDetailFamily._();

final class VerseDetailProvider extends $FunctionalProvider<
        AsyncValue<Either<Failure, Verse>>,
        Either<Failure, Verse>,
        FutureOr<Either<Failure, Verse>>>
    with
        $FutureModifier<Either<Failure, Verse>>,
        $FutureProvider<Either<Failure, Verse>> {
  VerseDetailProvider._(
      {required VerseDetailFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'verseDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$verseDetailHash();

  @override
  String toString() {
    return r'verseDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Either<Failure, Verse>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Either<Failure, Verse>> create(Ref ref) {
    final argument = this.argument as String;
    return verseDetail(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VerseDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$verseDetailHash() => r'9cf28d901eecaf7397bf42efe9bfe588491e2583';

final class VerseDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Either<Failure, Verse>>, String> {
  VerseDetailFamily._()
      : super(
          retry: null,
          name: r'verseDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  VerseDetailProvider call(
    String verseId,
  ) =>
      VerseDetailProvider._(argument: verseId, from: this);

  @override
  String toString() => r'verseDetailProvider';
}

/// Optional AI explanation row for this verse (null if not generated yet).

@ProviderFor(verseExplanation)
final verseExplanationProvider = VerseExplanationFamily._();

/// Optional AI explanation row for this verse (null if not generated yet).

final class VerseExplanationProvider extends $FunctionalProvider<
        AsyncValue<VerseExplanation?>,
        VerseExplanation?,
        FutureOr<VerseExplanation?>>
    with
        $FutureModifier<VerseExplanation?>,
        $FutureProvider<VerseExplanation?> {
  /// Optional AI explanation row for this verse (null if not generated yet).
  VerseExplanationProvider._(
      {required VerseExplanationFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'verseExplanationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$verseExplanationHash();

  @override
  String toString() {
    return r'verseExplanationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<VerseExplanation?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<VerseExplanation?> create(Ref ref) {
    final argument = this.argument as String;
    return verseExplanation(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VerseExplanationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$verseExplanationHash() => r'8455d79fb526eb232049fdf0e60c6fcc154642dc';

/// Optional AI explanation row for this verse (null if not generated yet).

final class VerseExplanationFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<VerseExplanation?>, String> {
  VerseExplanationFamily._()
      : super(
          retry: null,
          name: r'verseExplanationProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Optional AI explanation row for this verse (null if not generated yet).

  VerseExplanationProvider call(
    String verseId,
  ) =>
      VerseExplanationProvider._(argument: verseId, from: this);

  @override
  String toString() => r'verseExplanationProvider';
}

/// Scholarly commentaries for this verse (empty list when none seeded).

@ProviderFor(verseCommentaries)
final verseCommentariesProvider = VerseCommentariesFamily._();

/// Scholarly commentaries for this verse (empty list when none seeded).

final class VerseCommentariesProvider extends $FunctionalProvider<
        AsyncValue<List<Commentary>>,
        List<Commentary>,
        FutureOr<List<Commentary>>>
    with $FutureModifier<List<Commentary>>, $FutureProvider<List<Commentary>> {
  /// Scholarly commentaries for this verse (empty list when none seeded).
  VerseCommentariesProvider._(
      {required VerseCommentariesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'verseCommentariesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$verseCommentariesHash();

  @override
  String toString() {
    return r'verseCommentariesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Commentary>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Commentary>> create(Ref ref) {
    final argument = this.argument as String;
    return verseCommentaries(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VerseCommentariesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$verseCommentariesHash() => r'444e453602c4348002a059e91b8ac27e1354633c';

/// Scholarly commentaries for this verse (empty list when none seeded).

final class VerseCommentariesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Commentary>>, String> {
  VerseCommentariesFamily._()
      : super(
          retry: null,
          name: r'verseCommentariesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Scholarly commentaries for this verse (empty list when none seeded).

  VerseCommentariesProvider call(
    String verseId,
  ) =>
      VerseCommentariesProvider._(argument: verseId, from: this);

  @override
  String toString() => r'verseCommentariesProvider';
}

@ProviderFor(verseChapterPosition)
final verseChapterPositionProvider = VerseChapterPositionFamily._();

final class VerseChapterPositionProvider extends $FunctionalProvider<
        AsyncValue<
            ({
              int index,
              int total,
            })?>,
        ({
          int index,
          int total,
        })?,
        FutureOr<
            ({
              int index,
              int total,
            })?>>
    with
        $FutureModifier<
            ({
              int index,
              int total,
            })?>,
        $FutureProvider<
            ({
              int index,
              int total,
            })?> {
  VerseChapterPositionProvider._(
      {required VerseChapterPositionFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'verseChapterPositionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$verseChapterPositionHash();

  @override
  String toString() {
    return r'verseChapterPositionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<
      ({
        int index,
        int total,
      })?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<
      ({
        int index,
        int total,
      })?> create(Ref ref) {
    final argument = this.argument as String;
    return verseChapterPosition(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VerseChapterPositionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$verseChapterPositionHash() =>
    r'59ffd1f61d51e2ca0e2dee31a4464964d0db8aff';

final class VerseChapterPositionFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<
                ({
                  int index,
                  int total,
                })?>,
            String> {
  VerseChapterPositionFamily._()
      : super(
          retry: null,
          name: r'verseChapterPositionProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  VerseChapterPositionProvider call(
    String verseId,
  ) =>
      VerseChapterPositionProvider._(argument: verseId, from: this);

  @override
  String toString() => r'verseChapterPositionProvider';
}

@ProviderFor(adjacentVerseIds)
final adjacentVerseIdsProvider = AdjacentVerseIdsFamily._();

final class AdjacentVerseIdsProvider extends $FunctionalProvider<
        AsyncValue<
            ({
              String? nextId,
              String? prevId,
            })>,
        ({
          String? nextId,
          String? prevId,
        }),
        FutureOr<
            ({
              String? nextId,
              String? prevId,
            })>>
    with
        $FutureModifier<
            ({
              String? nextId,
              String? prevId,
            })>,
        $FutureProvider<
            ({
              String? nextId,
              String? prevId,
            })> {
  AdjacentVerseIdsProvider._(
      {required AdjacentVerseIdsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'adjacentVerseIdsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$adjacentVerseIdsHash();

  @override
  String toString() {
    return r'adjacentVerseIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<
      ({
        String? nextId,
        String? prevId,
      })> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<
      ({
        String? nextId,
        String? prevId,
      })> create(Ref ref) {
    final argument = this.argument as String;
    return adjacentVerseIds(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AdjacentVerseIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adjacentVerseIdsHash() => r'1c61543ec243de156bccdb0a35693f8891a1a857';

final class AdjacentVerseIdsFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<
                ({
                  String? nextId,
                  String? prevId,
                })>,
            String> {
  AdjacentVerseIdsFamily._()
      : super(
          retry: null,
          name: r'adjacentVerseIdsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  AdjacentVerseIdsProvider call(
    String verseId,
  ) =>
      AdjacentVerseIdsProvider._(argument: verseId, from: this);

  @override
  String toString() => r'adjacentVerseIdsProvider';
}
