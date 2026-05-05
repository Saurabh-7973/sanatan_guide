import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanatan_guide/core/constants/preferences_keys.dart';

part 'daily_reminder_provider.g.dart';

class DailyReminderPrefs {
  final bool enabled;
  final TimeOfDay time;

  const DailyReminderPrefs({required this.enabled, required this.time});

  DailyReminderPrefs copyWith({bool? enabled, TimeOfDay? time}) =>
      DailyReminderPrefs(
        enabled: enabled ?? this.enabled,
        time: time ?? this.time,
      );

  static const defaults = DailyReminderPrefs(
    enabled: false,
    time: TimeOfDay(hour: 7, minute: 0),
  );
}

@Riverpod(keepAlive: true)
class DailyReminderNotifier extends _$DailyReminderNotifier {
  @override
  DailyReminderPrefs build() {
    _load();
    return DailyReminderPrefs.defaults;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(PrefsKeys.reminderEnabled) ?? false;
    final minutes = prefs.getInt(PrefsKeys.reminderTimeMinutes) ?? 7 * 60;
    state = DailyReminderPrefs(
      enabled: enabled,
      time: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
  }

  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.reminderEnabled, value);
  }

  Future<void> setTime(TimeOfDay value) async {
    state = state.copyWith(time: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      PrefsKeys.reminderTimeMinutes,
      value.hour * 60 + value.minute,
    );
  }
}
