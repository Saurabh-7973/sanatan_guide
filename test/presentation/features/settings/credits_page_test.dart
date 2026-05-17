import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/features/settings/pages/credits_page.dart';

void main() {
  testWidgets('Credits renders hero + sūtra numerals at top', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreditsPage()));
    await tester.pump(const Duration(seconds: 1)); // settle fade-ups

    expect(find.text('श्रद्धा · WITH GRATITUDE'), findsOneWidget);
    expect(find.text('Credits & Attributions'), findsOneWidget);
    // Devanāgarī numeral marker for the first row of a section (top is visible).
    expect(find.text('१'), findsWidgets);
  });

  testWidgets('GRETIL tool credit + Bṛhadāraṇyaka blessing reachable',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreditsPage()));
    await tester.pump(const Duration(seconds: 1));

    final scrollable = find.byType(Scrollable);

    await tester.scrollUntilVisible(
      find.textContaining('GRETIL'),
      400,
      scrollable: scrollable,
    );
    expect(find.textContaining('GRETIL'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('Bṛhadāraṇyaka Upaniṣad'),
      400,
      scrollable: scrollable,
    );
    expect(find.textContaining('Bṛhadāraṇyaka Upaniṣad'), findsOneWidget);
  });

  testWidgets('Credits renders in light theme without overflow',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      home: const CreditsPage(),
    ));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
