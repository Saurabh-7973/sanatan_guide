import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/pages/chapter_list_page.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_progress_provider.dart';

/// Build a Bhagavad Gītā harness with the 18 chapter read-counts overridden.
/// BG uses the typed const path (no DB outline lookup) so this isolates
/// rendering from data layer.
Widget _bgHarness({
  required List<int> readCounts,
  ({String verseId, String scriptureCode})? lastRead,
}) {
  assert(readCounts.length == 18, 'BG has 18 chapters');
  // Chapter list now reads through scriptureChapterReadCountsProvider
  // (a single GROUP BY query) instead of one chapterReadCountProvider
  // per chapter — so the harness overrides the map provider.
  final countsMap = <String, int>{
    for (var i = 0; i < 18; i++)
      if (readCounts[i] > 0) '0:${i + 1}': readCounts[i],
  };
  return ProviderScope(
    overrides: [
      scriptureChapterReadCountsProvider('bhagavad_gita')
          .overrideWith((_) async => countsMap),
      lastReadVerseProvider.overrideWith((_) async => lastRead),
    ],
    child: const MaterialApp(
      home: ChapterListPage(scriptureId: 'bhagavad_gita'),
    ),
  );
}

void main() {
  testWidgets(
    'resume row appears when last-read scripture matches current',
    (tester) async {
      await tester.pumpWidget(_bgHarness(
        readCounts: List.filled(18, 0),
        lastRead: (verseId: 'BG.3.22', scriptureCode: 'bhagavad_gita'),
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 700));

      expect(find.text('CONTINUE READING'), findsOneWidget);
    },
  );

  testWidgets('resume row hidden when no last-read', (tester) async {
    await tester.pumpWidget(_bgHarness(
      readCounts: List.filled(18, 0),
      lastRead: null,
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 700));

    expect(find.text('CONTINUE READING'), findsNothing);
  });

  testWidgets(
    'resume row hidden when last-read belongs to a different scripture',
    (tester) async {
      await tester.pumpWidget(_bgHarness(
        readCounts: List.filled(18, 0),
        lastRead: (verseId: 'RV.1.1.1', scriptureCode: 'rigveda'),
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 700));

      expect(find.text('CONTINUE READING'), findsNothing);
    },
  );

  testWidgets(
    'completed chapter shows check_circle_outline glyph',
    (tester) async {
      // BG ch 1 has 47 verses; mark all read.
      final reads = List<int>.filled(18, 0);
      reads[0] = 47;
      await tester.pumpWidget(_bgHarness(
        readCounts: reads,
        lastRead: null,
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 700));

      expect(
        find.byIcon(Icons.check_circle_outline_rounded),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'incomplete chapters show no check icon',
    (tester) async {
      await tester.pumpWidget(_bgHarness(
        readCounts: List.filled(18, 0),
        lastRead: null,
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 700));

      expect(find.byIcon(Icons.check_circle_outline_rounded), findsNothing);
      // Row chevron is a custom-painted 8×14 stroke matching the mockup —
      // no longer an Icon, so we can't byIcon-match it. Absence of the
      // completed-state check is what proves we're on the chevron path.
    },
  );

  testWidgets('header shows Devanāgarī title and counts', (tester) async {
    await tester.pumpWidget(_bgHarness(
      readCounts: List.filled(18, 0),
      lastRead: null,
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 700));

    expect(find.text('भगवद्गीता'), findsOneWidget);
    expect(find.text('Bhagavad Gītā · The Song of God'), findsOneWidget);
    expect(find.text('ALL CHAPTERS'), findsOneWidget);
  });
}
