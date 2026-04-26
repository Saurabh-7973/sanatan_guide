import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/sanctum_card.dart';

Widget _wrap(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('SanctumCard shows title and child', (tester) async {
    await tester.pumpWidget(_wrap(const SanctumCard(
      title: 'Translation',
      child: Text('Some content'),
    )));
    expect(find.text('TRANSLATION'), findsOneWidget);
    expect(find.text('Some content'), findsOneWidget);
  });

  testWidgets('SanctumCard collapses on tap when collapsible', (tester) async {
    await tester.pumpWidget(_wrap(const SanctumCard(
      title: 'Word by Word',
      collapsible: true,
      child: Text('word content'),
    )));
    expect(find.text('word content'), findsOneWidget);
    await tester.tap(find.text('WORD BY WORD'));
    await tester.pumpAndSettle();
    // AnimatedCrossFade keeps both children in the tree but hides the
    // inactive one via a zero-opacity FadeTransition. Verify by finding a
    // FadeTransition ancestor with opacity == 0.
    final fadeTransitions = tester.widgetList<FadeTransition>(
      find.ancestor(
        of: find.text('word content'),
        matching: find.byType(FadeTransition),
      ),
    );
    final isHidden =
        fadeTransitions.any((ft) => ft.opacity.value == 0.0);
    expect(isHidden, isTrue);
  });

  testWidgets('SanctumCard dark mode renders', (tester) async {
    await tester.pumpWidget(_wrap(
      const SanctumCard(title: 'Test', child: Text('dark')),
      dark: true,
    ));
    expect(find.text('TEST'), findsOneWidget);
  });
}
