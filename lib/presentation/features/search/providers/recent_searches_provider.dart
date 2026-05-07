import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanatan_guide/core/services/recent_searches_service.dart';

part 'recent_searches_provider.g.dart';

/// Reactive list of the user's recent search queries, most recent first.
/// Backed by [RecentSearchesService] (SharedPreferences). Re-loads when
/// invalidated; mutators must call `ref.invalidateSelf()` after writing.
@Riverpod(keepAlive: true)
class RecentSearches extends _$RecentSearches {
  @override
  Future<List<String>> build() async => RecentSearchesService.load();

  Future<void> add(String query) async {
    await RecentSearchesService.add(query);
    ref.invalidateSelf();
  }

  Future<void> clearAll() async {
    await RecentSearchesService.clear();
    ref.invalidateSelf();
  }
}
