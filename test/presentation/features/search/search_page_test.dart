import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/search/pages/search_page.dart';
import 'package:sanatan_guide/presentation/features/search/providers/recent_searches_provider.dart';
import 'package:sanatan_guide/presentation/features/search/providers/search_provider.dart';

String _testQuery = '';
List<String> _testRecents = const [];

class _FixedQuery extends SearchQuery {
  @override
  String build() => _testQuery;
}

class _FixedRecents extends RecentSearches {
  @override
  Future<List<String>> build() async => _testRecents;
}

Verse _v({
  required String id,
  required int chapterNum,
  required int verseNum,
  String sanskrit = 'धर्मक्षेत्रे कुरुक्षेत्रे',
  String? english = 'On the field of dharma',
  Scripture scripture = Scripture.bhagavadGita,
  int? bookNum,
}) =>
    Verse(
      id: id,
      scripture: scripture,
      chapterNum: chapterNum,
      verseNum: verseNum,
      bookNum: bookNum,
      sanskrit: sanskrit,
      english: english,
      createdAt: DateTime(2024),
    );

Widget _harness({
  String query = '',
  List<String> recents = const [],
  List<Verse> results = const [],
}) {
  _testQuery = query;
  _testRecents = recents;
  return ProviderScope(
    overrides: [
      searchQueryProvider.overrideWith(_FixedQuery.new),
      searchResultsProvider
          .overrideWith((_) async => Right<Failure, List<Verse>>(results)),
      recentSearchesProvider.overrideWith(_FixedRecents.new),
    ],
    child: const MaterialApp(home: SearchPage()),
  );
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

  testWidgets('Pandit CTA hidden when GEMINI_API_KEY is not set',
      (tester) async {
    // Tests run without --dart-define=GEMINI_API_KEY → GeminiService
    // disabled, so the AI CTA must not render (same gate as verse-detail).
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('ASK THE PANDIT'), findsNothing);
  });

  testWidgets('Recent section renders saved queries when present',
      (tester) async {
    await tester.pumpWidget(_harness(
      recents: const ['karmaṇyevādhikāraste', 'BG 2.47'],
    ));
    await tester.pumpAndSettle();

    expect(find.text('RECENT'), findsOneWidget);
    expect(find.text('karmaṇyevādhikāraste'), findsOneWidget);
    expect(find.text('BG 2.47'), findsOneWidget);
  });

  testWidgets('coord query shows DIRECT MATCH coord-resolved card',
      (tester) async {
    await tester.pumpWidget(_harness(query: 'BG 2.47'));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.text('DIRECT MATCH'), findsOneWidget);
    expect(
      find.textContaining('Bhagavad Gita'),
      findsWidgets,
    );
  });

  testWidgets(
    'word query renders result groups with view-all when count > 3',
    (tester) async {
      final dharma = [
        for (var n = 1; n <= 5; n++)
          _v(
            id: 'BG.1.$n',
            chapterNum: 1,
            verseNum: n,
            sanskrit: 'धर्मक्षेत्रे कुरुक्षेत्रे',
            english: 'On the field of dharma',
          ),
      ];
      await tester.pumpWidget(_harness(query: 'dharma', results: dharma));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      expect(find.textContaining('MATCHES ACROSS'), findsOneWidget);
      // 5 verses in the group, so "5 · VIEW ALL" affordance shows.
      expect(find.text('5 · VIEW ALL'), findsOneWidget);
      // Devanāgarī daṇḍa coord rendered on at least one row.
      expect(find.textContaining('‖१·१‖'), findsWidgets);
    },
  );

  testWidgets('view-all expansion toggles to COLLAPSE on tap',
      (tester) async {
    final dharma = [
      for (var n = 1; n <= 5; n++)
        _v(id: 'BG.1.$n', chapterNum: 1, verseNum: n),
    ];
    await tester.pumpWidget(_harness(query: 'dharma', results: dharma));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    await tester.tap(find.text('5 · VIEW ALL'));
    await tester.pump();
    expect(find.text('COLLAPSE'), findsOneWidget);
  });

  testWidgets('tapping outside the search field drops focus (border resets)',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // The border is driven by this exact node's hasFocus.
    FocusNode fieldNode() =>
        tester.widget<TextField>(find.byType(TextField)).focusNode!;

    // The page autofocuses the field in initState.
    expect(fieldNode().hasFocus, isTrue);

    // Tap a non-interactive area outside the field's TapRegion.
    await tester.tap(find.text('SEARCH ANY WAY'));
    await tester.pumpAndSettle();

    expect(fieldNode().hasFocus, isFalse,
        reason: 'onTapOutside must unfocus so the border returns to divider');
  });
}
