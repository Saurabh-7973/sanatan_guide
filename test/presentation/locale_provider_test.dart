import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('default is null (follow device locale)', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(localeProvider), isNull);
  });

  test('setLocale writes to prefs and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(localeProvider.notifier)
        .setLocale(const Locale('hi'));
    expect(container.read(localeProvider), const Locale('hi'));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), 'hi');
  });

  test('setLocale(null) clears the override', () async {
    SharedPreferences.setMockInitialValues({'app_locale': 'hi'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(localeProvider.notifier).setLocale(null);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), isNull);
    expect(container.read(localeProvider), isNull);
  });
}
