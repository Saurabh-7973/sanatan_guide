import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanatan_guide/core/constants/preferences_keys.dart';

part 'locale_provider.g.dart';


/// Null → follow device locale. Non-null → force this locale.
@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(PrefsKeys.appLocale);
    if (raw == null || raw.isEmpty) return;
    state = Locale(raw);
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(PrefsKeys.appLocale);
    } else {
      await prefs.setString(PrefsKeys.appLocale, locale.languageCode);
    }
  }
}
