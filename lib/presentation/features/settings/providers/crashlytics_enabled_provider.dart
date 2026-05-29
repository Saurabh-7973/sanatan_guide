import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanatan_guide/core/constants/preferences_keys.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';

part 'crashlytics_enabled_provider.g.dart';


/// User-facing opt-out for Firebase Crashlytics. Default ON in release
/// (so we can fix actual crashes), default OFF in debug (so dev noise
/// doesn't pollute prod). Toggling here flips the SDK-level collection
/// flag immediately; no new crash data is buffered or uploaded once off.
@Riverpod(keepAlive: true)
class CrashlyticsEnabled extends _$CrashlyticsEnabled {
  @override
  bool build() {
    _load();
    return !kDebugMode;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool(PrefsKeys.privacyCrashlyticsEnabled);
    if (v != null) {
      state = v;
      await _apply(v);
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.privacyCrashlyticsEnabled, enabled);
    await _apply(enabled);
  }

  static Future<void> _apply(bool enabled) async {
    try {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(enabled);
      AppLogger.instance.i('Firebase Crashlytics collection: $enabled');
    } catch (e, st) {
      AppLogger.instance.w('setCrashlyticsCollectionEnabled failed', e, st);
    }
  }
}
