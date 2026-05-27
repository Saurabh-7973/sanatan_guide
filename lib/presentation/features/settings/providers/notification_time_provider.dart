import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanatan_guide/core/services/notification_service.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';

part 'notification_time_provider.g.dart';

const _kNotifHourKey = 'notif_verse_hour';
const _kNotifMinuteKey = 'notif_verse_minute';
const _kNotifEnabledKey = 'notif_verse_enabled';
const _kFestivalAlertsEnabledKey = 'notif_festival_alerts_enabled';
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
    // Force verseOfDay to recompute so scheduleDailyVerseNotification
    // re-fires with the new time. Without this, the keepAlive cache
    // delivers the old schedule until the app restarts.
    ref.invalidate(verseOfDayProvider);
    unawaited(ref.read(verseOfDayProvider.future));
  }
}

/// Whether the Daily verse reminder is enabled. Defaults to true to honour
/// the onboarding "Enable reminder" tap; user can toggle off in Settings.
@Riverpod(keepAlive: true)
class NotificationEnabled extends _$NotificationEnabled {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool(_kNotifEnabledKey);
    if (v != null) state = v;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifEnabledKey, enabled);
    // Opting in for the first time → ask the OS for notification + exact
    // alarm permissions now, not at next app launch. requestPermission is
    // idempotent so re-enables after an earlier grant are no-ops.
    if (enabled) {
      unawaited(NotificationService.requestPermission());
    }
    // Same fix as setTime — force verseOfDay rebuild so the schedule path
    // re-runs and either cancels or re-fires immediately.
    ref.invalidate(verseOfDayProvider);
    unawaited(ref.read(verseOfDayProvider.future));
  }
}

/// Whether festival-day alerts are enabled. Default off — the scheduler
/// gated on this won't post anything until the user opts in. The actual
/// scheduling job is wired separately; this preference is the on/off pin
/// that any future festival-notification path reads before firing.
@Riverpod(keepAlive: true)
class FestivalAlertsEnabled extends _$FestivalAlertsEnabled {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool(_kFestivalAlertsEnabledKey);
    if (v != null) state = v;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFestivalAlertsEnabledKey, enabled);
  }
}
