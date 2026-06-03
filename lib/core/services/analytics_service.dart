import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';

/// Central analytics façade over Firebase Analytics (GA4).
///
/// Design rules (keep these — they're why reports stay usable):
/// * **Parameterized, not proliferated.** A small set of event names with
///   parameters, never one name per micro-action (GA4 caps at 500 names).
/// * **No raw text, ever.** Search queries, AI messages, and notes are
///   religious-belief data; log only metadata (lengths, ids, codes, counts).
/// * **Fire-and-forget + non-throwing.** Every call swallows errors and should
///   be invoked without `await` (use `unawaited`) so analytics never blocks or
///   crashes a user action — and so the test suite (no Firebase init) stays green.
/// * **Opt-out is SDK-level.** [setCollectionEnabled] gates everything below it,
///   so individual call sites don't need to check the toggle.
abstract final class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Navigator observer that auto-logs `screen_view` for every named route.
  /// Register in the router's `observers` list.
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Toggles Firebase Analytics collection at the SDK level. Off → nothing is
  /// buffered, queued, or sent. Called by analyticsEnabledProvider on the
  /// Settings switch and at boot to apply the persisted preference.
  static Future<void> setCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      AppLogger.instance.i('Firebase Analytics collection: $enabled');
    } catch (e, st) {
      AppLogger.instance.w('setAnalyticsCollectionEnabled failed', e, st);
    }
  }

  // ── Reading / content ─────────────────────────────────────────────────────

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

  /// A navigable container was opened. [type] is scripture | chapter | book |
  /// festival. [id] is a stable code/number (never user text).
  static Future<void> contentOpened({
    required String type,
    required String id,
  }) =>
      _log('content_opened', {'type': type, 'id': id});

  // ── Verse actions ─────────────────────────────────────────────────────────

  static Future<void> verseBookmarked({
    required String verseId,
    required bool added,
  }) =>
      _log('verse_bookmarked', {'verse_id': verseId, 'added': added ? 1 : 0});

  /// [option] = sanskrit_only | with_translation | full_citation.
  static Future<void> verseShared({
    required String verseId,
    String? option,
  }) =>
      _log('verse_shared', {
        'verse_id': verseId,
        if (option != null) 'option': option,
      });

  // ── Search ────────────────────────────────────────────────────────────────

  /// Privacy: logs the query LENGTH and mode, never the query text.
  static Future<void> searchPerformed({
    required int queryLength,
    required String mode,
    required int resultCount,
  }) =>
      _log('search_performed', {
        'query_length': queryLength,
        'mode': mode,
        'result_count': resultCount,
      });

  static Future<void> searchResultTapped({String? scripture}) =>
      _log('search_result_tapped', {
        if (scripture != null) 'scripture': scripture,
      });

  // ── AI ────────────────────────────────────────────────────────────────────

  /// Any use of an AI feature. [feature] = explain | gloss | chat | theme |
  /// citation_tap | retry. [surface] = pandit | verse_chat | verse_detail | …
  /// No prompt/response text is ever logged.
  static Future<void> aiUsed({
    required String feature,
    String? surface,
    String? verseId,
  }) =>
      _log('ai_used', {
        'feature': feature,
        if (surface != null) 'surface': surface,
        if (verseId != null) 'verse_id': verseId,
      });

  /// User flagged an AI response via the per-message report action.
  static Future<void> aiContentReported({required String surface}) =>
      _log('ai_content_reported', {'surface': surface});

  // ── Learning ──────────────────────────────────────────────────────────────

  static Future<void> moduleStarted(String moduleId) =>
      _log('module_started', {'module_id': moduleId});

  static Future<void> moduleCompleted(String moduleId) =>
      _log('module_completed', {'module_id': moduleId});

  // ── Settings ──────────────────────────────────────────────────────────────

  /// Every settings change funnels here. [setting] is a stable key (theme,
  /// font_size, language, sanskrit_display, scripture_experience,
  /// daily_reminder, reminder_time, festival_alerts, analytics, crashlytics).
  static Future<void> settingChanged({
    required String setting,
    required String value,
  }) =>
      _log('setting_changed', {'setting': setting, 'value': value});

  // ── External links (monetization signal) ──────────────────────────────────

  /// An outbound link/intent was opened. [host] is the domain (e.g.
  /// amazon.in, archive.org); [source] is where it was tapped (credits,
  /// feedback, module, privacy, terms). This is the hook for affiliate /
  /// store taps when those land.
  static Future<void> externalLink({
    required String host,
    required String source,
  }) =>
      _log('external_link', {'host': host, 'source': source});

  // ── Notifications ─────────────────────────────────────────────────────────

  static Future<void> notificationOpened({String? verseId}) =>
      _log('notification_opened', {if (verseId != null) 'verse_id': verseId});

  // ── Feedback ──────────────────────────────────────────────────────────────

  /// [category] = bug | idea | text_error | other. No message text logged.
  static Future<void> feedbackSubmitted({required String category}) =>
      _log('feedback_submitted', {'category': category});

  // ── Onboarding ────────────────────────────────────────────────────────────

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

  // ── Engagement ────────────────────────────────────────────────────────────

  static Future<void> streakAchieved(int count) =>
      _log('streak_achieved', {'streak_count': count});

  /// Generic catch-all for small UI actions that don't warrant their own event
  /// name — transliteration toggle, verse swipe, pandit CTA, festival filter,
  /// search-mode select, recent-search tap, note add, copy. [feature] is the
  /// stable action key; [extra] is optional metadata (no user text).
  static Future<void> featureUsed(
    String feature, {
    Map<String, Object>? extra,
  }) =>
      _log('feature_used', {'feature': feature, ...?extra});

  // ── User properties (segmentation dimensions) ─────────────────────────────

  static Future<void> setUserProperty(String name, String? value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      AppLogger.instance.w('Analytics user property "$name" failed: $e');
    }
  }

  static Future<void> setStreakDays(int days) =>
      setUserProperty('streak_days', '$days');

  static Future<void> setPreferredTheme(String theme) =>
      setUserProperty('preferred_theme', theme);

  static Future<void> setFontSize(double size) =>
      setUserProperty('font_size', size.round().toString());

  // ── Internal ──────────────────────────────────────────────────────────────

  static Future<void> _log(String name, Map<String, Object> params) async {
    try {
      await _analytics.logEvent(name: name, parameters: params);
    } catch (e) {
      AppLogger.instance.w('Analytics event "$name" failed: $e');
    }
  }
}
