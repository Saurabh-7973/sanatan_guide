import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/data/datasources/local/daos/bookmarks_dao.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/pages/bookmarks_page.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';

EnrichedBookmark _b({
  required String verseId,
  required String scriptureCode,
  required int chapterNum,
  required int verseNum,
  String sanskrit = 'धर्मक्षेत्रे कुरुक्षेत्रे',
  String? english = 'On the field of dharma',
  String? noteText,
  Duration ago = const Duration(days: 2),
}) =>
    EnrichedBookmark(
      verseId: verseId,
      savedAt: DateTime.now().subtract(ago),
      sanskritPreview: sanskrit,
      englishPreview: english,
      scriptureCode: scriptureCode,
      chapterNum: chapterNum,
      verseNum: verseNum,
      noteText: noteText,
    );

Widget _harness({required List<EnrichedBookmark> bookmarks}) {
  return ProviderScope(
    overrides: [
      enrichedBookmarksProvider.overrideWith((_) => Stream.value(bookmarks)),
    ],
    child: const MaterialApp(home: BookmarksPage()),
  );
}

void main() {
  testWidgets('empty state visible when no bookmarks', (tester) async {
    await tester.pumpWidget(_harness(bookmarks: const []));
    await tester.pumpAndSettle();

    expect(find.text('पोथी'), findsOneWidget);
    expect(find.text('Your collection'), findsOneWidget);
    expect(find.text('Your pothī awaits'), findsOneWidget);
    expect(find.text('BEGIN READING'), findsOneWidget);
  });

  testWidgets('populated state renders Sanskrit + Devanāgarī coord',
      (tester) async {
    await tester.pumpWidget(_harness(
      bookmarks: [
        _b(
          verseId: 'BG.2.47',
          scriptureCode: 'bhagavad_gita',
          chapterNum: 2,
          verseNum: 47,
          sanskrit: 'कर्मण्येवाधिकारस्ते',
          english: 'Your right is to action alone',
        ),
      ],
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.text('पोथी'), findsOneWidget);
    expect(find.text('कर्मण्येवाधिकारस्ते'), findsOneWidget);
    // Coord line includes Devanāgarī २·४७ + BG shortcode
    expect(
      find.textContaining('२·४७'),
      findsWidgets,
    );
    // Footer renders the scripture name uppercase (mockup `.leaf-footer`
    // text-transform: uppercase). The chip text is "BHAGAVAD GITA".
    expect(find.textContaining('BHAGAVAD GITA'), findsOneWidget);
  });

  testWidgets('sort tabs swap when user taps By scripture', (tester) async {
    await tester.pumpWidget(_harness(
      bookmarks: [
        _b(
          verseId: 'BG.2.47',
          scriptureCode: 'bhagavad_gita',
          chapterNum: 2,
          verseNum: 47,
        ),
      ],
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.text('RECENT'), findsOneWidget);
    expect(find.text('BY SCRIPTURE'), findsOneWidget);

    await tester.tap(find.text('BY SCRIPTURE'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    // After swap, group header renders the per-scripture verse count.
    // (Devanāgarī header lives inside Text.rich so plain text finders
    //  don't reach it; the count is a standalone Text.)
    expect(find.text('1 VERSES'), findsOneWidget);
  });

  testWidgets('personal note rendered when present', (tester) async {
    await tester.pumpWidget(_harness(
      bookmarks: [
        _b(
          verseId: 'BG.2.47',
          scriptureCode: 'bhagavad_gita',
          chapterNum: 2,
          verseNum: 47,
          noteText: 'The line my father read aloud at his retirement.',
        ),
      ],
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(
      find.textContaining('father read aloud'),
      findsOneWidget,
    );
  });

  testWidgets('personal note hidden when not set', (tester) async {
    await tester.pumpWidget(_harness(
      bookmarks: [
        _b(
          verseId: 'BG.2.47',
          scriptureCode: 'bhagavad_gita',
          chapterNum: 2,
          verseNum: 47,
        ),
      ],
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.byIcon(Icons.edit_note_rounded), findsNothing);
  });
}
