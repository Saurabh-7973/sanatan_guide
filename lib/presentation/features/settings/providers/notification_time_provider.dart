import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notification_time_provider.g.dart';

const _kNotifHourKey = 'notif_verse_hour';
const _kNotifMinuteKey = 'notif_verse_minute';
const TimeOfDay _kDefault = TimeOfDay(hour: 7, minute: 0);

@Riverpod(keepAlive: true)
class NotificationTimeNotifier extends _$NotificationTimeNotifier {
  @override
  TimeOfDay build() {
    _load();
    return _kDefault;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_kNotifHourKey);
    final minute = prefs.getInt(_kNotifMinuteKey);
    if (hour != null && minute != null) {
      state = TimeOfDay(hour: hour, minute: minute);
    }
  }

  Future<void> setTime(TimeOfDay time) async {
    state = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kNotifHourKey, time.hour);
    await prefs.setInt(_kNotifMinuteKey, time.minute);
  }
}
