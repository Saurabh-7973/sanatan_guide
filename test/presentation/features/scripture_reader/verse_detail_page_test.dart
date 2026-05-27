import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/data/datasources/local/app_database.dart';
import 'package:sanatan_guide/data/datasources/local/app_database_provider.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/domain/entities/verse_explanation.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/pages/verse_detail_page.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/verse_detail_provider.dart';

const _id = 'BG.1.1';

Verse _verse() => Verse(
      id: _id,
      scripture: Scripture.bhagavadGita,
      chapterNum: 1,
      verseNum: 1,
      sanskrit: 'धृतराष्ट्र उवाच ।\nधर्मक्षेत्रे कुरुक्षेत्रे',
      english: 'Dhṛtarāṣṭra said: O Sañjaya, what did my sons do...',
      transliteration: 'dhṛtarāṣṭra uvāca | dharmakṣetre kurukṣetre',
      translation: 'sivananda',
      wordMeanings: const [
        WordMeaning(
          word: 'धर्मक्षेत्रे',
          transliteration: 'dharma-kṣetre',
          meaning: 'In the field of dharma — where right action is performed.',
        ),
      ],
      isBookmarked: false,
      readCount: 1,
      createdAt: DateTime(2024),
    );

Widget _harness({
  Verse? verse,
  ({String? prevId, String? nextId}) adjacent = (prevId: null, nextId: 'BG.1.2'),
  ({int index, int total})? position = (index: 1, total: 47),
  VerseExplanation? explanation,
}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider
          .overrideWith((ref) async => AppDatabase(NativeDatabase.memory())),
      verseDetailProvider(_id)
          .overrideWith((_) async => Right<Failure, Verse>(verse ?? _verse())),
      adjacentVerseIdsProvider(_id).overrideWith((_) async => adjacent),
      verseChapterPositionProvider(_id).overrideWith((_) async => position),
      verseExplanationProvider(_id).overrideWith((_) async => explanation),
      isBookmarkedProvider(_id).overrideWith((_) => Stream.value(false)),
    ],
    child: const MaterialApp(home: VerseDetailPage(verseId: _id)),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('renders verse with left-aligned, non-italic translation',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('CHAPTER I · VERSE 1'), findsOneWidget);
    expect(find.text('TRANSLATION'), findsOneWidget);

    final translation = tester.widget<Text>(
      find.text('Dhṛtarāṣṭra said: O Sañjaya, what did my sons do...'),
    );
    expect(translation.style?.fontStyle, isNot(FontStyle.italic));
    // No explicit textAlign on the Text => defaults to start (left in LTR).
    expect(translation.textAlign, anyOf(isNull, TextAlign.left, TextAlign.start));
    expect(find.text('— Swami Sivananda'), findsOneWidget);
  });

  testWidgets('tapping a Sanskrit word with a meaning opens the callout',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // The callout meaning is not present until the word is tapped.
    expect(
      find.textContaining('where right action is performed'),
      findsNothing,
    );

    await tester.tap(find.text('धर्मक्षेत्रे'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('where right action is performed'),
      findsOneWidget,
    );
    expect(find.text('dharma-kṣetre'), findsOneWidget);
  });

  testWidgets(
      'word with no gloss + no API key shows calm copy, not false "yet"',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // कुरुक्षेत्रे has no WordMeaning; tests run without GEMINI_API_KEY,
    // so this exercises the no-key fallback branch of _WordCallout.
    await tester.tap(find.text('कुरुक्षेत्रे'));
    await tester.pumpAndSettle();

    // Copy was reworded in 757be61 — no more "Enable the AI guide
    // (GEMINI_API_KEY)" tech leak. The new wording promises nothing.
    expect(
      find.textContaining('isn’t available offline yet'),
      findsOneWidget,
    );
    expect(
      find.textContaining('not available for this verse yet'),
      findsNothing,
      reason: 'the old false-promise copy must be gone',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('no commentary card when there is no cached explanation',
      (tester) async {
    await tester.pumpWidget(_harness(explanation: null));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // The "Explain this verse" trigger is also gated on Gemini being
    // configured (no API key in tests), so we only assert the card is absent.
    expect(find.text('COMMENTARY'), findsNothing);
  });

  testWidgets('cached explanation shows the commentary card, not the trigger',
      (tester) async {
    await tester.pumpWidget(
      _harness(
        explanation: VerseExplanation(
          verseId: _id,
          explanationText: 'The Gītā opens with a question, not a sermon.',
          generatedAt: DateTime(2024),
          modelVersion: 'gemini-2.5-flash',
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('COMMENTARY'), findsOneWidget);
    expect(
      find.text('The Gītā opens with a question, not a sermon.'),
      findsOneWidget,
    );
    expect(find.text('EXPLAIN THIS VERSE'), findsNothing);
  });

  testWidgets('progress rail is absent when chapter position is unknown',
      (tester) async {
    await tester.pumpWidget(_harness(position: null));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('1 / 47'), findsNothing);
  });

  testWidgets('progress rail renders index / total / percent', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('1 / 47'), findsOneWidget);
    expect(find.text('2%'), findsOneWidget);
  });
}
