import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/features/onboarding/pages/onboarding_page.dart';

Widget _harness({TextScaler textScaler = TextScaler.noScaling}) => ProviderScope(
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: textScaler),
          child: const OnboardingPage(),
        ),
      ),
    );

void main() {
  // Onboarding is designed for a phone viewport (the mockup is 390×844); the
  // default 800×600 test surface is shorter than any real phone.
  Future<void> pumpPhone(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(child);
    await tester.pump(const Duration(milliseconds: 400)); // AnimatedSwitcher
  }

  testWidgets('welcome step renders the logomark, question and level cards',
      (tester) async {
    await pumpPhone(tester, _harness());

    expect(tester.takeException(), isNull);
    expect(find.text('ॐ'), findsOneWidget);
    expect(find.text('Sanatan Guide'), findsOneWidget);
    expect(find.text('TELL US WHERE TO BEGIN'), findsOneWidget);
    expect(find.text('How familiar are you with the scriptures?'),
        findsOneWidget);
    expect(find.text('Beginner'), findsOneWidget);
    expect(find.text('Regular'), findsOneWidget);
    expect(find.text('Scholar'), findsOneWidget);
  });

  testWidgets('no layout overflow at a large accessibility text scale',
      (tester) async {
    await pumpPhone(tester, _harness(textScaler: const TextScaler.linear(1.3)));
    expect(tester.takeException(), isNull);
  });
}
