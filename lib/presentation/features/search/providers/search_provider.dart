import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/core/services/analytics_service.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';

part 'search_provider.g.dart';

// ── Search filter ─────────────────────────────────────────────────────────

enum SearchFilter { all, sanskrit, english, hindi }

extension SearchFilterLabel on SearchFilter {
  String get label => switch (this) {
        SearchFilter.all => 'All',
        SearchFilter.sanskrit => 'Sanskrit',
        SearchFilter.english => 'English',
        SearchFilter.hindi => 'Hindi',
      };
}

@riverpod
class SearchFilterNotifier extends _$SearchFilterNotifier {
  @override
  SearchFilter build() => SearchFilter.all;

  void select(SearchFilter filter) => state = filter;
}

// ── Search query ──────────────────────────────────────────────────────────

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
  void clear() => state = '';
}

// ── Search results ────────────────────────────────────────────────────────

@riverpod
Future<Either<Failure, List<Verse>>> searchResults(Ref ref) async {
  final query = ref.watch(searchQueryProvider);
  final SearchFilter filter = ref.watch(searchFilterProvider);

  // Debounce — waits for typing to settle before hitting the DB
  await Future<void>.delayed(const Duration(milliseconds: 300));

  if (query.trim().length < 2) {
    return const Right([]);
  }

  final repo = await ref.watch(scriptureRepositoryProvider.future);
  final result = await repo.search(query.trim());

  result.fold((_) {}, (verses) {
    AnalyticsService.searchPerformed(
      query: query.trim(),
      filter: filter.label,
      resultCount: verses.length,
    );
  });

  return result.map((verses) {
    if (filter == SearchFilter.all) return verses;

    return verses.where((v) {
      final q = query.trim().toLowerCase();
      return switch (filter) {
        SearchFilter.sanskrit =>
          v.sanskrit.toLowerCase().contains(q),
        SearchFilter.english =>
          v.english?.toLowerCase().contains(q) ?? false,
        SearchFilter.hindi =>
          v.hindi?.toLowerCase().contains(q) ?? false,
        SearchFilter.all => true,
      };
    }).toList();
  });
}
