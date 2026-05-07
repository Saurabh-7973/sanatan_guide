import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/search/pages/search_page.dart';
import 'package:sanatan_guide/presentation/features/search/providers/recent_searches_provider.dart';
import 'package:sanatan_guide/presentation/features/search/providers/search_provider.dart';

Widget _harness() {
  return ProviderScope(
    overrides: [
      searchQueryProvider.overrideWith(_FixedQuery.new),
      searchResultsProvider
          .overrideWith((_) async => const Right<Failure, List<Verse>>([])),
      recentSearchesProvider.overrideWith(_FixedRecents.new),
    ],
    child: const MaterialApp(home: SearchPage()),
  );
}

class _FixedQuery extends SearchQuery {
  @override
  String build() => '';
}

class _FixedRecents extends RecentSearches {
  @override
  Future<List<String>> build() async => const [];
}

void main() {
  testWidgets('empty state shows the four "Search any way" intent rows',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('SEARCH ANY WAY'), findsOneWidget);
    expect(find.text('By phrase'), findsOneWidget);
    expect(find.text('By coordinate'), findsOneWidget);
    expect(find.text('By question'), findsOneWidget);
    expect(find.text('कर्म'), findsOneWidget);
  });

  testWidgets('empty state shows Pandit CTA', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('ASK THE PANDIT'), findsOneWidget);
    expect(find.text('ॐ'), findsOneWidget);
  });
}
