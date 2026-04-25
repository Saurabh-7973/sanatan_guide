import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/domain/entities/commentary.dart';
import 'package:sanatan_guide/l10n/generated/app_localizations.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/verse_detail_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/commentaries_block.dart';

Commentary _shankara({
  String id = 'shankara_gita_2.47',
  String verseId = 'BG.2.47',
  String? english = 'You have the right to work, never to its fruits.',
  String? sanskrit = 'कर्मण्येवाधिकारस्ते',
  String translator = 'A. Mahadeva Sastri',
  String license = 'public_domain',
  String tradition = 'advaita',
}) =>
    Commentary(
      id: id,
      verseId: verseId,
      tradition: tradition,
      author: 'Adi Shankaracharya',
      textEnglish: english,
      textSanskrit: sanskrit,
      translator: translator,
      sourceUrl: 'https://archive.org/details/bhagavadgitawith00shan',
      license: license,
      createdAt: DateTime(2024, 1, 1),
    );

Widget _harness(
  String verseId, {
  required List<Commentary> rows,
  Locale? locale,
}) {
  return ProviderScope(
    overrides: [
      verseCommentariesProvider(verseId).overrideWith((_) async => rows),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: CommentariesBlock(verseId: verseId)),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('empty list collapses to SizedBox.shrink (no UI rendered)',
      (tester) async {
    await tester.pumpWidget(_harness('BG.2.47', rows: const []));
    await tester.pumpAndSettle();

    // No commentary artefacts present.
    expect(find.textContaining('Shankaracharya'), findsNothing);
    expect(find.textContaining('Advaita'), findsNothing);
    expect(find.textContaining('Public domain'), findsNothing);
  });

  testWidgets('single row renders author · tradition header with English l10n',
      (tester) async {
    await tester.pumpWidget(
      _harness('BG.2.47', rows: [_shankara()], locale: const Locale('en')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Adi Shankaracharya · Advaita Vedanta'),
      findsOneWidget,
    );
  });

  testWidgets('header uses Hindi label when locale is forced to hi',
      (tester) async {
    await tester.pumpWidget(
      _harness('BG.2.47', rows: [_shankara()], locale: const Locale('hi')),
    );
    await tester.pumpAndSettle();

    // Header concatenates author · localised tradition.
    expect(
      find.textContaining('अद्वैत वेदांत'),
      findsOneWidget,
      reason: 'tradition label should be translated to Hindi',
    );
  });

  testWidgets('expanding the card reveals Sanskrit, English, and provenance',
      (tester) async {
    await tester.pumpWidget(
      _harness('BG.2.47', rows: [_shankara()], locale: const Locale('en')),
    );
    await tester.pumpAndSettle();

    // Tap to expand.
    await tester.tap(find.text('Adi Shankaracharya · Advaita Vedanta'));
    await tester.pumpAndSettle();

    expect(find.textContaining('कर्मण्येवाधिकारस्ते'), findsOneWidget);
    expect(find.textContaining('right to work'), findsOneWidget);
    expect(
      find.textContaining('A. Mahadeva Sastri'),
      findsOneWidget,
      reason: 'provenance line should name the translator',
    );
    expect(find.textContaining('Public domain'), findsOneWidget);
  });

  testWidgets('CC-BY-SA license renders formatted provenance',
      (tester) async {
    await tester.pumpWidget(
      _harness(
        'BG.2.47',
        rows: [_shankara(license: 'cc_by_sa')],
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adi Shankaracharya · Advaita Vedanta'));
    await tester.pumpAndSettle();

    expect(find.textContaining('CC-BY-SA'), findsOneWidget);
  });

  testWidgets('multiple rows: one card per tradition', (tester) async {
    await tester.pumpWidget(
      _harness(
        'BG.2.47',
        rows: [
          _shankara(id: 'a', tradition: 'advaita'),
          _shankara(id: 'b', tradition: 'dvaita'),
        ],
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Advaita Vedanta'), findsOneWidget);
    expect(find.textContaining('· Dvaita'), findsOneWidget);
  });

  testWidgets('Sanskrit-only row shows Sanskrit text, no English',
      (tester) async {
    await tester.pumpWidget(
      _harness(
        'BG.2.47',
        rows: [_shankara(english: null)],
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adi Shankaracharya · Advaita Vedanta'));
    await tester.pumpAndSettle();

    expect(find.textContaining('कर्मण्येवाधिकारस्ते'), findsOneWidget);
    expect(find.textContaining('right to work'), findsNothing);
  });
}
