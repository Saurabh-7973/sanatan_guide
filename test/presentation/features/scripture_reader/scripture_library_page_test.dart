import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/pages/scripture_library_page.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

Widget _harness({TextScaler textScaler = TextScaler.noScaling}) =>
    ProviderScope(
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: textScaler),
          child: const ScriptureLibraryPage(),
        ),
      ),
    );

void main() {
  testWidgets('renders the static family catalogue (not a blank page)',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Header + search.
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Find a scripture...'), findsOneWidget);

    // The first family header + the Vedas 2×2 grid must be laid out (the rest
    // is lazily built further down the CustomScrollView).
    expect(find.text('श्रुति'), findsOneWidget);
    expect(find.text('ऋग्वेद'), findsOneWidget);
    expect(find.text('Ṛg Veda'), findsOneWidget);

    // Scroll the catalogue and the later families/rows resolve too.
    await tester.dragUntilVisible(
      find.text('Bhagavad Gītā'),
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    expect(find.text('Bhagavad Gītā'), findsOneWidget);
  });

  testWidgets('family headers do not stack — each is bound to its section',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('श्रुति'), findsOneWidget); // first family, at the top

    // Scroll to the last family. Each family lives in its own SliverMainAxisGroup
    // so its pinned header clips away once that section scrolls past — earlier
    // headers must not still be in the tree (they would be if they all piled up
    // pinned at the top).
    await tester.dragUntilVisible(
      find.text('Tirukkuṟaḷ'),
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    expect(find.text('Tirukkuṟaḷ'), findsOneWidget);
    expect(find.text('श्रुति'), findsNothing);
    expect(find.text('इतिहास'), findsNothing);
  });

  testWidgets('no layout overflow at a large accessibility text scale',
      (tester) async {
    await tester.pumpWidget(_harness(textScaler: const TextScaler.linear(1.6)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('search query swaps the family list for results', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'gita');
    await tester.pumpAndSettle();

    expect(find.text('श्रुति'), findsNothing); // family list replaced
    expect(find.textContaining('RESULT'), findsOneWidget); // count line
    expect(find.text('Bhagavad Gītā'), findsOneWidget); // the match
  });

  testWidgets(
      'search border drops to unfocused after tapping outside, '
      'even with a non-empty query', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    Color searchBorderColor() {
      final containers = tester.widgetList<Container>(
        find.ancestor(
          of: find.byType(TextField),
          matching: find.byType(Container),
        ),
      );
      for (final c in containers) {
        final d = c.decoration;
        if (d is BoxDecoration &&
            d.borderRadius == BorderRadius.circular(28) &&
            d.border is Border) {
          return (d.border! as Border).top.color;
        }
      }
      fail('search-bar pill container not found');
    }

    await tester.enterText(find.byType(TextField), 'rig');
    await tester.pumpAndSettle();
    // Focused while typing → saffron active border.
    expect(searchBorderColor(), LColors.saffron);

    // Simulate tapping outside (global unfocus / onTapOutside).
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    // Focus gone → border must return to the idle divider even though the
    // query text ("rig") is still present.
    expect(searchBorderColor(), LColors.dividerSoft,
        reason: 'border must track focus, not query presence');
  });
}
