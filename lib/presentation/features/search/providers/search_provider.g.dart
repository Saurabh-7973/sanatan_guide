// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchFilterNotifier)
final searchFilterProvider = SearchFilterNotifierProvider._();

final class SearchFilterNotifierProvider
    extends $NotifierProvider<SearchFilterNotifier, SearchFilter> {
  SearchFilterNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchFilterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchFilterNotifierHash();

  @$internal
  @override
  SearchFilterNotifier create() => SearchFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchFilter>(value),
    );
  }
}

String _$searchFilterNotifierHash() =>
    r'92d47adfcf99736d07c2cbe77ff74643c2b1731b';

abstract class _$SearchFilterNotifier extends $Notifier<SearchFilter> {
  SearchFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SearchFilter, SearchFilter>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SearchFilter, SearchFilter>,
        SearchFilter,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  SearchQueryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchQueryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'790bd96a8a13bb944767c7bf06a5378cfc78a54d';

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsProvider._();

final class SearchResultsProvider extends $FunctionalProvider<
        AsyncValue<Either<Failure, List<Verse>>>,
        Either<Failure, List<Verse>>,
        FutureOr<Either<Failure, List<Verse>>>>
    with
        $FutureModifier<Either<Failure, List<Verse>>>,
        $FutureProvider<Either<Failure, List<Verse>>> {
  SearchResultsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchResultsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @$internal
  @override
  $FutureProviderElement<Either<Failure, List<Verse>>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Either<Failure, List<Verse>>> create(Ref ref) {
    return searchResults(ref);
  }
}

String _$searchResultsHash() => r'12ae702fbe6275dcbdaff1936bedfdf9cc67f57f';
