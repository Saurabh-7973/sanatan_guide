import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

List<LinearGradient> _ruleGradients(WidgetTester tester) => tester
    .widgetList<Container>(find.byType(Container))
    .map((c) => c.decoration)
    .whereType<BoxDecoration>()
    .map((d) => d.gradient)
    .whereType<LinearGradient>()
    .toList();

void main() {
  group('faded BindingLine matches the verse-detail leaf-binding mockup', () {
    testWidgets('dark rule is saffron-deep @0.45, 3-stop fade', (tester) async {
      await tester.pumpWidget(
        _wrap(const BindingLine(
          isDark: true,
          faded: true,
          diamondSize: 6,
          sideGap: 12,
        )),
      );

      final gradients = _ruleGradients(tester);
      expect(gradients, isNotEmpty,
          reason: 'faded rule halves must be gradient Containers');
      final g = gradients.first;
      // Mockup: linear-gradient(90deg, transparent, color, transparent)
      expect(g.colors.length, 3,
          reason: '3-stop transparent→color→transparent');
      expect(g.colors.first, Colors.transparent);
      expect(g.colors.last, Colors.transparent);
      expect(g.colors[1], DColors.saffronDeep.withValues(alpha: 0.45),
          reason: 'mockup .theme-dark .leaf-binding::before opacity 0.45');
    });

    testWidgets('light rule is saffron-deep @0.4, 3-stop fade', (tester) async {
      await tester.pumpWidget(
        _wrap(const BindingLine(
          isDark: false,
          faded: true,
          diamondSize: 6,
          sideGap: 12,
        )),
      );

      final g = _ruleGradients(tester).first;
      expect(g.colors.length, 3);
      expect(g.colors.first, Colors.transparent);
      expect(g.colors.last, Colors.transparent);
      expect(g.colors[1], LColors.saffronDeep.withValues(alpha: 0.4),
          reason: 'mockup .theme-light rgba(139,72,6,0.4)');
    });
  });
}
