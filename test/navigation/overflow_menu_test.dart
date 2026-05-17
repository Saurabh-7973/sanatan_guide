import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/presentation/shared/widgets/overflow_menu.dart';

void main() {
  testWidgets('overflow menu lists 3 items and scrim dismisses', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (context, __) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showOverflowMenu(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      for (final p in ['/settings', '/feedback', '/credits'])
        GoRoute(path: p, builder: (_, __) => Scaffold(body: Text('at $p'))),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Send feedback'), findsOneWidget);
    expect(find.text('About this app'), findsOneWidget);
    expect(find.text('Festivals & Calendar'), findsNothing);
    expect(find.text('Ask the Pandit'), findsNothing);

    // Tap scrim (away from the top-right popover) to dismiss.
    await tester.tapAt(const Offset(10, 400));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsNothing);
  });
}
