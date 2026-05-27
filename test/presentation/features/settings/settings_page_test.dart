import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanatan_guide/l10n/generated/app_localizations.dart';
import 'package:sanatan_guide/presentation/features/settings/pages/settings_page.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/font_size_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/theme_mode_provider.dart';

Widget _harness({Brightness brightness = Brightness.light}) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SettingsPage()),
      for (final p in const ['/credits', '/feedback'])
        GoRoute(
          path: p,
          builder: (_, __) => Scaffold(body: Text('at $p')),
        ),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(brightness: brightness),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

/// The settings ListView is lazy; a tall surface builds every section at once.
Future<void> _pumpSettings(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_harness(brightness: brightness));
  await tester.pump();
}

void main() {
  // Every settings provider lazily loads from SharedPreferences.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('renders five heritage section headers in spec order',
      (tester) async {
    await _pumpSettings(tester);

    // Per screen-09 mockup the APPEARANCE section is collapsed into
    // READING (Theme is the first reading row), so the spec is five
    // headers, not six.
    for (final header in const [
      'READING',
      'NOTIFICATIONS',
      'DATA',
      'ABOUT',
      'RESET',
    ]) {
      expect(find.text(header), findsOneWidget, reason: header);
    }
  });

  testWidgets('theme segmented control and key rows are present',
      (tester) async {
    await _pumpSettings(tester);

    expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
    expect(find.text('Reading font size'), findsOneWidget);
    expect(find.text('Clear reading history'), findsOneWidget);
    expect(find.text('Reset all settings'), findsOneWidget);
  });

  testWidgets('dark theme pumps without exception', (tester) async {
    await _pumpSettings(tester, brightness: Brightness.dark);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Credits row navigates to /credits', (tester) async {
    await _pumpSettings(tester);

    final credits = find.text('Credits & attributions');
    await tester.ensureVisible(credits);
    await tester.tap(credits);
    await tester.pumpAndSettle();

    expect(find.text('at /credits'), findsOneWidget);
  });

  testWidgets('Reset confirm dialog restores defaults and snackbars',
      (tester) async {
    await _pumpSettings(tester);

    // Move providers off their defaults so the reset is observable.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsPage)),
    );
    await container
        .read(themeModeProvider.notifier)
        .setThemeMode(ThemeMode.dark);
    await container.read(fontSizeProvider.notifier).setFontSize(22);
    await tester.pump();

    await tester.tap(find.text('Reset all settings'));
    await tester.pumpAndSettle();
    // Confirm dialog migrated from AlertDialog/TextButton to a heritage
    // bottom sheet whose confirm CTA is an uppercase pill ("RESET").
    // The "Reset" section header also renders "RESET" — disambiguate by
    // tapping the descendant of the Material pill.
    await tester
        .tap(find.descendant(of: find.byType(InkWell), matching: find.text('RESET')));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.system);
    expect(container.read(fontSizeProvider), 16.0); // kDefaultFontSize
    expect(find.text('Settings reset'), findsOneWidget);
  });
}
