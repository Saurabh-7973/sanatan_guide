import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sanatan_guide/data/festivals/festival_data_2026.dart';
import 'package:sanatan_guide/presentation/features/festivals/pages/festival_calendar_page.dart';
import 'package:sanatan_guide/presentation/features/festivals/pages/festival_detail_page.dart';
import 'package:sanatan_guide/presentation/features/festivals/providers/festival_provider.dart';

Future<void> _pump(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = const Size(1200, 4200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        festivalsProvider.overrideWith((ref) async => festivals2026),
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: const FestivalCalendarPage(),
      ),
    ),
  );
  // Resolve the async festivals provider, then settle the data view.
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('renders the panchāṅga banner, header and filter pills',
      (tester) async {
    await _pump(tester);

    expect(find.text("TODAY'S PANCHANGA"), findsOneWidget);
    expect(find.textContaining('Almanac'), findsWidgets);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Major parvas'), findsOneWidget);
    expect(find.text('Vrats'), findsOneWidget);
    expect(find.text('Regional'), findsOneWidget);
    // The four aṅga cells of the banner (ASCII labels — the bundled sans
    // font lacks the IAST dot-diacritics; see the Tiro-font note).
    expect(find.text('VARA'), findsOneWidget);
    expect(find.text('NAKSHATRA'), findsOneWidget);
    expect(find.text('YOGA'), findsOneWidget);
    expect(find.text('KARANA'), findsOneWidget);
  });

  testWidgets('the Regional filter shows only regional-category festivals',
      (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Regional'));
    await tester.pumpAndSettle();

    // Dev Deepawali is the one regional festival; Holi is a major parva.
    expect(find.text('Dev Deepawali'), findsWidgets);
    expect(find.text('Holi'), findsNothing);
  });

  testWidgets('tapping a festival opens its detail page', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Regional'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dev Deepawali').first);
    await tester.pumpAndSettle();

    expect(find.byType(FestivalDetailPage), findsOneWidget);
    expect(find.text('PRACTICES'), findsOneWidget);
    expect(find.text('देव दीपावली'), findsWidgets);
  });

  testWidgets('dark theme pumps without exception', (tester) async {
    await _pump(tester, brightness: Brightness.dark);
    expect(tester.takeException(), isNull);
  });
}
