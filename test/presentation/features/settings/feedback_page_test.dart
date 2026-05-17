import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/features/settings/pages/feedback_page.dart';
import 'package:sanatan_guide/presentation/shared/widgets/mockup_icons.dart';

void main() {
  testWidgets('State A shows 4 kinds; tapping one → compose', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FeedbackPage()));
    await tester.pump();

    expect(find.text('Send feedback'), findsOneWidget);
    expect(find.text('Bug report'), findsOneWidget);
    expect(find.text('Idea or suggestion'), findsOneWidget);
    expect(find.text('Text or translation error'), findsOneWidget);
    expect(find.text('Something else'), findsOneWidget);

    await tester.tap(find.text('Text or translation error'));
    await tester.pumpAndSettle();

    expect(find.text('Text or translation error'), findsWidgets);
    expect(find.text('SEND'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'BG 2.47 typo');
    await tester.pump();
    expect(find.text('BG 2.47 typo'), findsOneWidget);
  });

  testWidgets('back in State B returns to State A', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FeedbackPage()));
    await tester.pump();
    await tester.tap(find.text('Bug report'));
    await tester.pumpAndSettle();
    expect(find.text('WHAT KIND OF FEEDBACK?'), findsNothing);

    await tester.tap(find.byType(MockupBackChevron));
    await tester.pumpAndSettle();
    expect(find.text('WHAT KIND OF FEEDBACK?'), findsOneWidget);
  });

  testWidgets('light theme renders without overflow', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      home: const FeedbackPage(),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
