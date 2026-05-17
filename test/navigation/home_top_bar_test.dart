import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_top_bar.dart';

void main() {
  testWidgets('HomeTopBar shows brand + opens overflow', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: HomeTopBar()),
      ),
      for (final p in [
        '/search',
        '/bookmarks',
        '/settings',
        '/festivals',
        '/chat',
        '/feedback',
        '/credits'
      ])
        GoRoute(path: p, builder: (_, __) => Scaffold(body: Text('at $p'))),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookmarkedVersesProvider.overrideWith(
            (ref) => Stream.value(const <BookmarkListEntry>[]),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    expect(find.text('सनातन'), findsOneWidget);

    await tester.tap(find.byType(InkResponse).last); // overflow icon
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });
}
