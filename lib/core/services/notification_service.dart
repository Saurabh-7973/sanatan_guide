import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

part 'notification_service.g.dart';

// ── Notification IDs ──────────────────────────────────────────────────────
// Use fixed IDs so rescheduling replaces the existing notification,
// not stacks new ones.
const _kVerseOfDayNotifId = 1001;
const _kChannelId = 'verse_of_day';
const _kChannelName = 'Verse of the Day';
const _kChannelDesc = 'Daily morning verse from the Bhagavad Gita';

// ── Callback for notification taps ────────────────────────────────────────
// This must be a top-level function (not a method) because
// flutter_local_notifications calls it from a background isolate.
// The payload is the verseId string e.g. 'BG.11.12'.

@pragma('vm:entry-point')
void onNotificationTap(NotificationResponse response) {
  final verseId = response.payload;
  if (verseId == null || verseId.isEmpty) return;
  // Derive the scripture code from the verse id (BG.2.47 → bhagavad_gita,
  // RV.1.1.1 → rigveda, etc.) instead of hard-coding bhagavad_gita.
  final code = scriptureCodeFromVerseId(verseId);
  NotificationService.pendingDeepLink = '/browse/$code/verse/$verseId';
}

// ── Service ───────────────────────────────────────────────────────────────

final class NotificationService {
  NotificationService._();

  /// For [notificationServiceProvider] wiring only; call static APIs below.
  static final NotificationService riverpodAccess = NotificationService._();

  /// Set by [onNotificationTap]. Router reads and clears this on each build.
  static String? pendingDeepLink;

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Call once from main() before runApp().
  /// Initializes timezone data and the notifications plugin.
  static Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone database (needed by flutter_local_notifications
    // for zonedSchedule). We use UTC as the base — local time conversion
    // is done via Dart's built-in DateTime in scheduleDailyVerseNotification.
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );

    const channel = AndroidNotificationChannel(
      _kChannelId,
      _kChannelName,
      description: _kChannelDesc,
      importance: Importance.high,
      enableVibration: false,
      playSound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
    AppLogger.instance.i('NotificationService initialized');
  }

  /// Request notification permission on Android 13+ (API 33+).
  /// Call after app is fully loaded, not on first launch screen.
  static Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return true;
      final granted = await android.requestNotificationsPermission();
      AppLogger.instance.i('Notification permission granted: $granted');
      // Also request the exact-alarm permission on Android 12+ so
      // exactAllowWhileIdle schedules actually fire on time instead of
      // being demoted to inexact. USE_EXACT_ALARM in the manifest covers
      // most cases without a runtime prompt, but the call is a no-op
      // when not needed.
      try {
        final exactGranted = await android.requestExactAlarmsPermission();
        AppLogger.instance.i('Exact alarm permission granted: $exactGranted');
      } catch (e, st) {
        AppLogger.instance.w('Exact alarm permission request failed', e, st);
      }
      // CMF/Nothing OS + Samsung One UI + Xiaomi MIUI aggressively suppress
      // alarms unless the app is explicitly exempt from battery
      // optimisation. The exact-alarm permission is necessary but not
      // sufficient — OEM doze still kills scheduled fires. Prompt the user
      // to whitelist us.
      try {
        final status = await Permission.ignoreBatteryOptimizations.status;
        AppLogger.instance.i(
          'Battery-optimisation exempt status: $status',
        );
        if (status != PermissionStatus.granted) {
          final result = await Permission.ignoreBatteryOptimizations.request();
          AppLogger.instance.i(
            'Battery-optimisation exempt result: $result',
          );
        }
      } catch (e, st) {
        AppLogger.instance.w(
          'Battery-optimisation request failed', e, st,
        );
      }
      return granted ?? false;
    } catch (e, st) {
      AppLogger.instance.w(
        'requestPermission failed — Activity not ready yet',
        e,
        st,
      );
      return false;
    }
  }

  /// Schedule the daily Verse of the Day notification.
  ///
  /// [verseId] — the verse to deep-link to when tapped, e.g. 'BG.11.12'
  /// [title]   — e.g. 'Bhagavad Gita · 11.12'
  /// [body]    — first ~80 chars of the English translation
  ///
  /// Calling this again replaces the previous schedule (same notification ID).
  static Future<void> scheduleDailyVerseNotification({
    required String verseId,
    required String title,
    required String body,
    int hour = 7,
    int minute = 0,
  }) async {
    if (!_initialized) {
      AppLogger.instance.w('NotificationService not initialized — skipping');
      return;
    }

    // Use Dart's built-in DateTime for local time (no plugin needed).
    // DateTime.now() always reflects the device's actual local timezone.
    final now = DateTime.now();

    // Daily fire time in device local time at the user-picked hour/minute.
    var targetLocal = DateTime(now.year, now.month, now.day, hour, minute);

    // If target time has already passed today, schedule for tomorrow.
    if (targetLocal.isBefore(now)) {
      targetLocal = targetLocal.add(const Duration(days: 1));
    }

    // Convert local DateTime to UTC for TZDateTime scheduling.
    final targetUtc = targetLocal.toUtc();
    final scheduledDate = tz.TZDateTime.from(targetUtc, tz.UTC);

    final androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: _kChannelDesc,
      importance: Importance.high,
      priority: Priority.defaultPriority,
      styleInformation: BigTextStyleInformation(body),
      color: AppColors.saffron,
      enableVibration: false,
      playSound: true,
      autoCancel: true,
    );

    final notifDetails = NotificationDetails(android: androidDetails);

    // exactAllowWhileIdle = fire at the picked minute even in doze.
    // Requires SCHEDULE_EXACT_ALARM + USE_EXACT_ALARM in manifest (both
    // already declared). inexactAllowWhileIdle was deferring delivery for
    // hours on a real Samsung device — invisible to users who set a
    // morning verse reminder and never saw it land at the picked time.
    await _plugin.zonedSchedule(
      _kVerseOfDayNotifId,
      title,
      body,
      scheduledDate,
      notifDetails,
      payload: verseId,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    AppLogger.instance.i(
      'Daily notification scheduled for $targetLocal (local) — $verseId',
    );
  }

  /// Cancel the daily verse notification.
  static Future<void> cancelDailyNotification() async {
    await _plugin.cancel(_kVerseOfDayNotifId);
    AppLogger.instance.i('Daily notification cancelled');
  }

  /// Fire a test notification immediately — for diagnosing delivery on a
  /// real device without waiting for the scheduled hour. Uses the same
  /// channel + payload as the daily reminder so a tap deep-links the
  /// same way.
  static Future<void> fireTestNotificationNow({
    required String verseId,
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      AppLogger.instance.w('NotificationService not initialized — skipping');
      return;
    }
    final androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: _kChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
      color: AppColors.saffron,
      enableVibration: true,
      playSound: true,
      autoCancel: true,
    );
    await _plugin.show(
      _kVerseOfDayNotifId,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: verseId,
    );
    AppLogger.instance.i('Test notification posted for $verseId');
  }
}

// ── Riverpod provider ─────────────────────────────────────────────────────

/// Exposes [NotificationService.riverpodAccess] for DI; behavior is static.
@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) =>
    NotificationService.riverpodAccess;
