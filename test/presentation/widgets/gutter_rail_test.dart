import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/gutter_rail.dart';

/// A [Verse] for Bhagavad Gita 2.47 used across all tests.
final _bgVerse = Verse(
  id: 'BG.2.47',
  chapterNum: 2,
  verseNum: 47,
  scripture: Scripture.bhagavadGita,
  sanskrit: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन',
  createdAt: DateTime(2024),
);

Widget _wrap(Widget child, {ThemeData? theme}) => MaterialApp(
      theme: theme,
      home: Scaffold(
        body: SizedBox(height: 600, child: child),
      ),
    );

void main() {
  group('GutterRail', () {
    testWidgets('shows BG abbreviation for bhagavad_gita', (tester) async {
      await tester.pumpWidget(_wrap(GutterRail(verse: _bgVerse)));

      expect(find.text('BG'), findsOneWidget);
    });

    testWidgets('shows chapter number', (tester) async {
      await tester.pumpWidget(_wrap(GutterRail(verse: _bgVerse)));

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows verse number', (tester) async {
      await tester.pumpWidget(_wrap(GutterRail(verse: _bgVerse)));

      expect(find.text('47'), findsOneWidget);
    });

    testWidgets('smoke test — renders without error in dark mode',
        (tester) async {
      final darkTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
      );

      await tester.pumpWidget(_wrap(GutterRail(verse: _bgVerse), theme: darkTheme));

      // The widget renders without throwing; spot-check the abbrev stamp.
      expect(find.text('BG'), findsOneWidget);
    });

    testWidgets('shows YS abbreviation for yoga_sutras', (tester) async {
      final ysVerse = Verse(
        id: 'YS.1.1',
        chapterNum: 1,
        verseNum: 1,
        scripture: Scripture.yogaSutras,
        sanskrit: 'अथ योगानुशासनम्',
        createdAt: DateTime(2024),
      );

      await tester.pumpWidget(_wrap(GutterRail(verse: ysVerse)));

      expect(find.text('YS'), findsOneWidget);
    });
  });
}
