// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_searches_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reactive list of the user's recent search queries, most recent first.
/// Backed by [RecentSearchesService] (SharedPreferences). Re-loads when
/// invalidated; mutators must call `ref.invalidateSelf()` after writing.

@ProviderFor(RecentSearches)
final recentSearchesProvider = RecentSearchesProvider._();

/// Reactive list of the user's recent search queries, most recent first.
/// Backed by [RecentSearchesService] (SharedPreferences). Re-loads when
/// invalidated; mutators must call `ref.invalidateSelf()` after writing.
final class RecentSearchesProvider
    extends $AsyncNotifierProvider<RecentSearches, List<String>> {
  /// Reactive list of the user's recent search queries, most recent first.
  /// Backed by [RecentSearchesService] (SharedPreferences). Re-loads when
  /// invalidated; mutators must call `ref.invalidateSelf()` after writing.
  RecentSearchesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recentSearchesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recentSearchesHash();

  @$internal
  @override
  RecentSearches create() => RecentSearches();
}

String _$recentSearchesHash() => r'8275f3b133e21ad0586750ddc1f0166a9c82fb62';

/// Reactive list of the user's recent search queries, most recent first.
/// Backed by [RecentSearchesService] (SharedPreferences). Re-loads when
/// invalidated; mutators must call `ref.invalidateSelf()` after writing.

abstract class _$RecentSearches extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<String>>, List<String>>,
        AsyncValue<List<String>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
