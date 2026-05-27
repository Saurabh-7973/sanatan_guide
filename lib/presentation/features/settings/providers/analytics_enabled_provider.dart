import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanatan_guide/core/services/analytics_service.dart';

part 'analytics_enabled_provider.g.dart';

const _kAnalyticsEnabledKey = 'privacy_analytics_enabled';

/// User-facing opt-out for Firebase Analytics. Default ON. Writing to the
/// notifier persists to SharedPreferences and immediately flips the SDK-level
/// collection flag so no further events are buffered or sent.
@Riverpod(keepAlive: true)
class AnalyticsEnabled extends _$AnalyticsEnabled {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool(_kAnalyticsEnabledKey);
    if (v != null) {
      state = v;
      await AnalyticsService.setCollectionEnabled(v);
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAnalyticsEnabledKey, enabled);
    await AnalyticsService.setCollectionEnabled(enabled);
  }
}
