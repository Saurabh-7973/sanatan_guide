// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_of_day_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides [ScriptureDao] once the DB is ready.

@ProviderFor(scriptureDao)
final scriptureDaoProvider = ScriptureDaoProvider._();

/// Provides [ScriptureDao] once the DB is ready.

final class ScriptureDaoProvider extends $FunctionalProvider<
        AsyncValue<ScriptureDao>, ScriptureDao, FutureOr<ScriptureDao>>
    with $FutureModifier<ScriptureDao>, $FutureProvider<ScriptureDao> {
  /// Provides [ScriptureDao] once the DB is ready.
  ScriptureDaoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scriptureDaoProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scriptureDaoHash();

  @$internal
  @override
  $FutureProviderElement<ScriptureDao> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ScriptureDao> create(Ref ref) {
    return scriptureDao(ref);
  }
}

String _$scriptureDaoHash() => r'0053aaf94f5613f15a87e4d3821a7678292473d7';

/// Remote API for Bhagavad Gita when verses are not bundled in SQLite.

@ProviderFor(bhagavadGitaRemoteDataSource)
final bhagavadGitaRemoteDataSourceProvider =
    BhagavadGitaRemoteDataSourceProvider._();

/// Remote API for Bhagavad Gita when verses are not bundled in SQLite.

final class BhagavadGitaRemoteDataSourceProvider extends $FunctionalProvider<
    BhagavadGitaRemoteDataSource,
    BhagavadGitaRemoteDataSource,
    BhagavadGitaRemoteDataSource> with $Provider<BhagavadGitaRemoteDataSource> {
  /// Remote API for Bhagavad Gita when verses are not bundled in SQLite.
  BhagavadGitaRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bhagavadGitaRemoteDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bhagavadGitaRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<BhagavadGitaRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BhagavadGitaRemoteDataSource create(Ref ref) {
    return bhagavadGitaRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BhagavadGitaRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BhagavadGitaRemoteDataSource>(value),
    );
  }
}

String _$bhagavadGitaRemoteDataSourceHash() =>
    r'85ae724b6c18c136835f040cb81a2e5f2f837eba';

/// Provides [IScriptureRepository] backed by the local DB.

@ProviderFor(scriptureRepository)
final scriptureRepositoryProvider = ScriptureRepositoryProvider._();

/// Provides [IScriptureRepository] backed by the local DB.

final class ScriptureRepositoryProvider extends $FunctionalProvider<
        AsyncValue<IScriptureRepository>,
        IScriptureRepository,
        FutureOr<IScriptureRepository>>
    with
        $FutureModifier<IScriptureRepository>,
        $FutureProvider<IScriptureRepository> {
  /// Provides [IScriptureRepository] backed by the local DB.
  ScriptureRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scriptureRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scriptureRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<IScriptureRepository> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<IScriptureRepository> create(Ref ref) {
    return scriptureRepository(ref);
  }
}

String _$scriptureRepositoryHash() =>
    r'c51be128108a3d762c03c1a3fd56dcbb8eb32b74';

/// Provides [GetVerseOfDayUseCase] ready to execute.

@ProviderFor(getVerseOfDayUseCase)
final getVerseOfDayUseCaseProvider = GetVerseOfDayUseCaseProvider._();

/// Provides [GetVerseOfDayUseCase] ready to execute.

final class GetVerseOfDayUseCaseProvider extends $FunctionalProvider<
        AsyncValue<GetVerseOfDayUseCase>,
        GetVerseOfDayUseCase,
        FutureOr<GetVerseOfDayUseCase>>
    with
        $FutureModifier<GetVerseOfDayUseCase>,
        $FutureProvider<GetVerseOfDayUseCase> {
  /// Provides [GetVerseOfDayUseCase] ready to execute.
  GetVerseOfDayUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getVerseOfDayUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getVerseOfDayUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<GetVerseOfDayUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GetVerseOfDayUseCase> create(Ref ref) {
    return getVerseOfDayUseCase(ref);
  }
}

String _$getVerseOfDayUseCaseHash() =>
    r'032a2c0bf6ba3cdd803017a9a2360bf72b4eedcd';

/// The verse displayed on the Home screen today.
/// KeepAlive — verse doesn't change within a session; avoids
/// unnecessary re-fetches on tab switches.

@ProviderFor(verseOfDay)
final verseOfDayProvider = VerseOfDayProvider._();

/// The verse displayed on the Home screen today.
/// KeepAlive — verse doesn't change within a session; avoids
/// unnecessary re-fetches on tab switches.

final class VerseOfDayProvider extends $FunctionalProvider<
        AsyncValue<Either<Failure, Verse>>,
        Either<Failure, Verse>,
        FutureOr<Either<Failure, Verse>>>
    with
        $FutureModifier<Either<Failure, Verse>>,
        $FutureProvider<Either<Failure, Verse>> {
  /// The verse displayed on the Home screen today.
  /// KeepAlive — verse doesn't change within a session; avoids
  /// unnecessary re-fetches on tab switches.
  VerseOfDayProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'verseOfDayProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$verseOfDayHash();

  @$internal
  @override
  $FutureProviderElement<Either<Failure, Verse>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Either<Failure, Verse>> create(Ref ref) {
    return verseOfDay(ref);
  }
}

String _$verseOfDayHash() => r'8f74a3bc6d216f40e6d6e927a03437016d01d401';
