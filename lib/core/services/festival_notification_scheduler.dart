import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:sanatan_guide/core/utils/app_logger.dart';
import 'package:sanatan_guide/domain/entities/festival.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';

/// Schedules a single "Today: <festival name>" notification at the user's
/// reminder hour on the morning of each upcoming festival. Lazily called
/// from the Settings toggle and from app boot — never re-schedules on hot
/// reload or every verseOfDayProvider rebuild.
abstract final class FestivalNotificationScheduler {
  // Channel reuses the verse-of-day channel so the user sees one consistent
  // settings entry under the app's notification controls.
  static const _kChannelId = 'verse_of_day_v2';
  static const _kChannelName = 'Verse of the Day';
  static const _kChannelDesc = 'Daily morning verse and major-parva reminders';
  static const _kIcon = 'ic_notification_om';
  static const _kLargeIcon =
      DrawableResourceAndroidBitmap('ic_launcher_foreground');

  // SharedPreferences key tracking the IDs we scheduled last sync so we can
  // cancel them precisely (versus blowing away every notification with
  // cancelAll, which would also kill the daily verse reminder).
  static const _kScheduledIdsKey = 'festival_notif_ids';

  // Stay well clear of _kVerseOfDayNotifId (1001) and _kTestNotifId (1099).
  static const _kIdBase = 2000;
  // Cap: only schedule the next 30 festivals so we don't exhaust the
  // platform's alarm quota. The OS limit varies (Samsung: ~500; vanilla
  // Android: 50) — 30 is comfortably under everyone's floor.
  static const _kMaxScheduled = 30;
  // Window: don't schedule beyond ~120 days out. Far-future dates often
  // shift after panchāṅga corrections; the next sync (next boot / toggle)
  // catches up.
  static const _kHorizon = Duration(days: 120);

  static late FlutterLocalNotificationsPlugin _plugin;
  static bool _wired = false;

  /// Inject the same plugin instance NotificationService uses — both schedule
  /// against the same channel so the user sees one channel in OS settings.
  static void wirePlugin(FlutterLocalNotificationsPlugin plugin) {
    _plugin = plugin;
    _wired = true;
  }

  /// Recompute the schedule. Safe to call repeatedly — clears previously
  /// scheduled festival IDs first, then schedules afresh up to [_kMaxScheduled]
  /// festivals over the next [_kHorizon].
  ///
  /// [enabled] off → cancels everything and clears the stored ID set.
  static Future<void> sync({
    required List<Festival> all,
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    if (!_wired) {
      AppLogger.instance
          .w('FestivalNotificationScheduler not wired — call wirePlugin');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await _cancelPrior(prefs);
    if (!enabled) return;

    final now = DateTime.now();
    final cutoff = now.add(_kHorizon);
    final upcoming = all
        .where((f) =>
            f.date.isAfter(DateTime(now.year, now.month, now.day - 1)) &&
            f.date.isBefore(cutoff))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final picked = upcoming.take(_kMaxScheduled);

    final scheduledIds = <int>[];
    for (final f in picked) {
      final id = _idFor(f);
      final fireAt = DateTime(
        f.date.year,
        f.date.month,
        f.date.day,
        hour,
        minute,
      );
      // Skip same-day past-time slots so today's festival doesn't fire after
      // its window has already closed.
      if (fireAt.isBefore(now)) continue;
      try {
        await _plugin.zonedSchedule(
          id,
          '${f.emoji} Today: ${f.name}',
          f.shortDesc,
          tz.TZDateTime.from(fireAt.toUtc(), tz.UTC),
          NotificationDetails(
            android: AndroidNotificationDetails(
              _kChannelId,
              _kChannelName,
              channelDescription: _kChannelDesc,
              icon: _kIcon,
              largeIcon: _kLargeIcon,
              importance: Importance.high,
              priority: Priority.high,
              styleInformation: BigTextStyleInformation(f.shortDesc),
              color: AppColors.saffron,
              enableVibration: true,
              playSound: true,
              autoCancel: true,
            ),
          ),
          payload: f.readingVerseId,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        scheduledIds.add(id);
      } catch (e, st) {
        AppLogger.instance.w('festival sched failed for ${f.id}', e, st);
      }
    }
    await prefs.setString(_kScheduledIdsKey, jsonEncode(scheduledIds));
    AppLogger.instance
        .i('Festival notifs scheduled: ${scheduledIds.length}');
  }

  static Future<void> _cancelPrior(SharedPreferences prefs) async {
    final raw = prefs.getString(_kScheduledIdsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      for (final v in decoded) {
        if (v is int) await _plugin.cancel(v);
      }
    } catch (_) {
      // ignore malformed legacy values
    }
    await prefs.remove(_kScheduledIdsKey);
  }

  /// Deterministic per-festival ID from yyyymmdd offset by _kIdBase. Stable
  /// across syncs so reruns replace rather than duplicate.
  static int _idFor(Festival f) {
    final yyyy = f.date.year;
    final mm = f.date.month;
    final dd = f.date.day;
    // Compact: id = base + (yyyy % 100) * 10000 + mm * 100 + dd
    // Keeps the value safely under Java int max for the next ~80 years.
    return _kIdBase + (yyyy % 100) * 10000 + mm * 100 + dd;
  }
}
