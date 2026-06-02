import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/shared/widgets/ai_message.dart';

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('AiMessage', () {
    testWidgets('shows the AI-generated label and a Report action',
        (tester) async {
      await tester.pumpWidget(_host(
        const AiMessage(
          isDark: false,
          text: 'The self is eternal.',
          surface: 'pandit',
        ),
      ));

      expect(find.text('AI-generated'), findsOneWidget);
      expect(find.text('Report'), findsOneWidget);
    });

    testWidgets('tapping Report confirms with a toast and does not throw',
        (tester) async {
      await tester.pumpWidget(_host(
        const AiMessage(
          isDark: false,
          text: 'The self is eternal.',
          surface: 'pandit',
        ),
      ));

      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();

      // reportAiContent best-effort routes to Crashlytics/analytics (both
      // no-op safely without Firebase) and always shows the confirmation.
      expect(find.text('Thank you — reported for review.'), findsOneWidget);
    });
  });

  group('AiDisclaimer', () {
    testWidgets('renders the exact required disclaimer string',
        (tester) async {
      await tester.pumpWidget(_host(const AiDisclaimer(isDark: false)));
      expect(
        find.text(
          'AI responses may contain errors. '
          'Always refer to traditional commentaries.',
        ),
        findsOneWidget,
      );
    });
  });
}
