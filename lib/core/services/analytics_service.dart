import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';

abstract final class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Toggles Firebase Analytics collection at the SDK level. Off → no
  /// events are buffered, queued, or sent. Called by the
  /// analyticsEnabledProvider whenever the user flips the Settings switch
  /// and at app boot to apply the persisted preference.
  static Future<void> setCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      AppLogger.instance.i('Firebase Analytics collection: $enabled');
    } catch (e, st) {
      AppLogger.instance.w('setAnalyticsCollectionEnabled failed', e, st);
    }
  }

  // ── Scripture reading ───────────────────────────────────────────────────

  static Future<void> verseRead({
    required String verseId,
    required String scripture,
    required int chapter,
    required int verse,
  }) =>
      _log('verse_read', {
        'verse_id': verseId,
        'scripture': scripture,
        'chapter': chapter,
        'verse': verse,
      });

  static Future<void> scriptureOpened(String scriptureCode) =>
      _log('scripture_opened', {'scripture': scriptureCode});

  static Future<void> chapterOpened({
    required String scripture,
    required int chapter,
  }) =>
      _log('chapter_opened', {
        'scripture': scripture,
        'chapter': chapter,
      });

  // ── User actions ────────────────────────────────────────────────────────

  static Future<void> verseBookmarked(String verseId) =>
      _log('verse_bookmarked', {'verse_id': verseId});

  static Future<void> verseShared(String verseId) =>
      _log('verse_shared', {'verse_id': verseId});

  static Future<void> searchPerformed({
    required String query,
    required String filter,
    required int resultCount,
  }) =>
      _log('search_performed', {
        'query': query,
        'filter': filter,
        'result_count': resultCount,
      });

  // ── Learning ────────────────────────────────────────────────────────────

  static Future<void> moduleStarted(String moduleId) =>
      _log('module_started', {'module_id': moduleId});

  static Future<void> moduleCompleted(String moduleId) =>
      _log('module_completed', {'module_id': moduleId});

  // ── Engagement ──────────────────────────────────────────────────────────

  static Future<void> streakAchieved(int count) =>
      _log('streak_achieved', {'streak_count': count});

  static Future<void> readingModeChanged(String mode) =>
      _log('reading_mode_changed', {'mode': mode});

  static Future<void> darkModeToggled({required bool enabled}) =>
      _log('dark_mode_toggled', {'enabled': enabled ? 1 : 0});

  static Future<void> onboardingPathSelected(String path) =>
      _log('onboarding_path_selected', {'path': path});

  static Future<void> experienceLevelSet({
    required String level,
    required String source,
  }) =>
      _log('experience_level_set', {'level': level, 'source': source});

  static Future<void> onboardingReminderChosen({
    required bool enabled,
    int? hour,
    int? minute,
  }) =>
      _log('onboarding_reminder_chosen', {
        'enabled': enabled ? 1 : 0,
        if (hour != null) 'hour': hour,
        if (minute != null) 'minute': minute,
      });

  // ── Internal ────────────────────────────────────────────────────────────

  static Future<void> _log(
    String name,
    Map<String, Object> params,
  ) async {
    try {
      await _analytics.logEvent(name: name, parameters: params);
    } catch (e) {
      AppLogger.instance.w('Analytics event "$name" failed: $e');
    }
  }
}
