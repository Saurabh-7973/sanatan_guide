import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanatan_guide/core/constants/preferences_keys.dart';
import 'package:sanatan_guide/core/services/analytics_service.dart';
import 'package:sanatan_guide/domain/entities/script_style.dart';

part 'script_style_provider.g.dart';

/// User preference for how panchang/calendar Sanskrit names are scripted.
/// Defaults to [ScriptStyle.both] — keeps the Devanāgarī aesthetic while
/// adding the Latin (IAST) reading requested by beta testers.
@Riverpod(keepAlive: true)
class ScriptStyleNotifier extends _$ScriptStyleNotifier {
  @override
  ScriptStyle build() {
    _load();
    return ScriptStyle.both;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final parsed =
        ScriptStyle.fromStorage(prefs.getString(PrefsKeys.scriptStyle));
    if (parsed != null) state = parsed;
  }

  Future<void> setStyle(ScriptStyle style) async {
    state = style;
    AnalyticsService.settingChanged(
      setting: 'script_style',
      value: style.storageValue,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.scriptStyle, style.storageValue);
  }
}
