import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';

/// Regression guard: [WarmBackdrop] must paint an *opaque* base colour beneath
/// the translucent saffron wash. A `BoxDecoration` with both `color` and
/// `gradient` only paints the gradient, so transparent-`Scaffold` screens that
/// sit on top of it used to bleed through to clear-black.
void main() {
  ColoredBox opaqueBase(WidgetTester tester) => tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(WarmBackdrop),
          matching: find.byType(ColoredBox),
        ),
      );

  testWidgets('light mode paints an opaque cream base', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: WarmBackdrop(intensity: 0.6),
        ),
      ),
    );

    final base = opaqueBase(tester);
    expect(base.color, AppColors.cream);
    expect(base.color.a, 1.0);
  });

  testWidgets('dark mode paints an opaque near-black base', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: const Scaffold(
          backgroundColor: Colors.transparent,
          body: WarmBackdrop(),
        ),
      ),
    );

    final base = opaqueBase(tester);
    expect(base.color, AppColors.bgDark);
    expect(base.color.a, 1.0);
  });
}
