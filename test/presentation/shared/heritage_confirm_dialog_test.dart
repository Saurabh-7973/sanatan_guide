import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/shared/widgets/system_chrome.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

/// Pumps a host with a single button that opens [showHeritageConfirmDialog],
/// returning the dialog's result via [resultRef] once it closes.
Future<void> _pumpHost(
  WidgetTester tester, {
  required Brightness brightness,
  required bool isDangerous,
  required List<bool?> resultRef,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                resultRef.add(await showHeritageConfirmDialog(
                  context,
                  title: 'Reset all settings?',
                  body: 'Defaults will be restored.',
                  confirmLabel: 'Reset',
                  isDangerous: isDangerous,
                ));
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('showHeritageConfirmDialog', () {
    testWidgets('confirm button returns true', (tester) async {
      final result = <bool?>[];
      await _pumpHost(
        tester,
        brightness: Brightness.light,
        isDangerous: true,
        resultRef: result,
      );
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(result.single, isTrue);
    });

    testWidgets('cancel button returns false', (tester) async {
      final result = <bool?>[];
      await _pumpHost(
        tester,
        brightness: Brightness.light,
        isDangerous: true,
        resultRef: result,
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result.single, isFalse);
    });

    testWidgets('scrim tap dismisses and returns null', (tester) async {
      final result = <bool?>[];
      await _pumpHost(
        tester,
        brightness: Brightness.light,
        isDangerous: true,
        resultRef: result,
      );

      // Tap the barrier well outside the 312px card.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(result.single, isNull);
      // Call sites collapse null/false via `!= true`, so both are "no-op".
      expect(result.single != true, isTrue);
    });

    testWidgets('destructive confirm label is iron-red (light)',
        (tester) async {
      final result = <bool?>[];
      await _pumpHost(
        tester,
        brightness: Brightness.light,
        isDangerous: true,
        resultRef: result,
      );

      final label = tester.widget<Text>(find.text('Reset'));
      expect(label.style?.color, LColors.ironRedBright);
    });

    testWidgets('destructive confirm label is iron-red (dark)', (tester) async {
      final result = <bool?>[];
      await _pumpHost(
        tester,
        brightness: Brightness.dark,
        isDangerous: true,
        resultRef: result,
      );

      final label = tester.widget<Text>(find.text('Reset'));
      expect(label.style?.color, DColors.ironRedBright);
    });

    testWidgets('non-destructive confirm label is saffron', (tester) async {
      final result = <bool?>[];
      await _pumpHost(
        tester,
        brightness: Brightness.light,
        isDangerous: false,
        resultRef: result,
      );

      final label = tester.widget<Text>(find.text('Reset'));
      expect(label.style?.color, LColors.saffron);
    });
  });
}
