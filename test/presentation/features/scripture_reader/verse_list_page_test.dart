import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/pages/verse_list_page.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_browser_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_progress_provider.dart';

Verse _v({
  required int n,
  bool isBookmarked = false,
  int readCount = 0,
}) =>
    Verse(
      id: 'BG.1.$n',
      scripture: Scripture.bhagavadGita,
      chapterNum: 1,
      verseNum: n,
      sanskrit: 'धृतराष्ट्र उवाच $n',
      english: 'Dhṛtarāṣṭra said: line $n',
      isBookmarked: isBookmarked,
      readCount: readCount,
      createdAt: DateTime(2024),
    );

Widget _harness({
  required List<Verse> verses,
  required Set<String> bookmarkIds,
  int readCount = 0,
}) {
  return ProviderScope(
    overrides: [
      chapterVersesProvider('bhagavad_gita', 1, null)
          .overrideWith((_) async => Right<Failure, List<Verse>>(verses)),
      chapterReadCountProvider('bhagavad_gita', 1, null)
          .overrideWith((_) async => readCount),
      bookmarkedIdsProvider.overrideWith((_) => Stream.value(bookmarkIds)),
    ],
    child: const MaterialApp(
      home: VerseListPage(scriptureId: 'bhagavad_gita', chapterNum: 1),
    ),
  );
}

void main() {
  testWidgets('jumper hidden when fewer than 40 verses', (tester) async {
    final verses = [for (var i = 1; i <= 10; i++) _v(n: i)];
    await tester.pumpWidget(
      _harness(verses: verses, bookmarkIds: const {}),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    // Jumper renders Devanāgarī decade markers; ‖१‖ is daṇḍa-marked verse 1
    // from the row, so to test for jumper we look for marker १ rendered as
    // standalone text without daṇḍa flanks. Simpler: jumper is BackdropFilter.
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('jumper renders when verse count ≥ 40', (tester) async {
    final verses = [for (var i = 1; i <= 47; i++) _v(n: i)];
    await tester.pumpWidget(
      _harness(verses: verses, bookmarkIds: const {}),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('bookmarked verse shows bookmark glyph', (tester) async {
    final verses = [_v(n: 1, isBookmarked: true)];
    await tester.pumpWidget(
      _harness(verses: verses, bookmarkIds: const {'BG.1.1'}),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
  });

  testWidgets('read verse shows check glyph (no bookmark)', (tester) async {
    final verses = [_v(n: 1, readCount: 1)];
    await tester.pumpWidget(
      _harness(verses: verses, bookmarkIds: const {}, readCount: 1),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_rounded), findsNothing);
  });

  testWidgets('bookmark wins over read state', (tester) async {
    final verses = [_v(n: 1, readCount: 1, isBookmarked: true)];
    await tester.pumpWidget(
      _harness(
        verses: verses,
        bookmarkIds: const {'BG.1.1'},
        readCount: 1,
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });
}
