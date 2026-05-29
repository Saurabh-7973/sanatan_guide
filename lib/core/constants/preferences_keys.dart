/// SharedPreferences keys used across the app — single source of truth.
///
/// Add new keys here, never inline. The string value is part of the
/// on-disk contract; renaming the constant is safe, renaming the *string*
/// loses persisted state for existing installs.
///
/// Keys are grouped by feature for readability. Dynamic keys built at
/// runtime (e.g. `gemini_daily_<bucket>_<date>` per rate-limit bucket,
/// `word_gloss_v1_<verseId>_<word>` per cached gloss) are still
/// constructed by their owning service — only the static prefix lives
/// here.
abstract final class PrefsKeys {
  PrefsKeys._();

  // ── Onboarding ──────────────────────────────────────────────────────────
  static const onboardingComplete = 'onboarding_complete';
  static const userExperienceLevel = 'user_experience_level';

  // ── Daily reminder ──────────────────────────────────────────────────────
  static const reminderEnabled = 'reminder_enabled';
  static const reminderTimeMinutes = 'reminder_time_minutes';
  static const notifVerseHour = 'notif_verse_hour';
  static const notifVerseMinute = 'notif_verse_minute';
  static const notifVerseEnabled = 'notif_verse_enabled';
  static const notifFestivalAlertsEnabled = 'notif_festival_alerts_enabled';

  // ── Festivals ───────────────────────────────────────────────────────────
  static const festivalNotifIds = 'festival_notif_ids';
  static const festivalDatesOverride = 'festival_dates_override';

  // ── Streak / reading history ────────────────────────────────────────────
  static const streakLastReadDate = 'streak_last_read_date';
  static const streakCurrentCount = 'streak_current_count';
  static const streakLongestCount = 'streak_longest_count';
  static const streakReadHistory = 'streak_read_history';
  static const lastReadVerseId = 'last_read_verse_id';
  static const lastReadScriptureCode = 'last_read_scripture_code';

  // ── In-app review prompt ────────────────────────────────────────────────
  static const reviewLastRequestedMs = 'review_last_requested_ms';
  static const reviewFirstChapterDone = 'review_first_chapter_done';
  static const reviewFirstModuleDone = 'review_first_module_done';

  // ── Search recents ──────────────────────────────────────────────────────
  static const recentSearches = 'recent_searches_v1';

  // ── Theme / locale / font / transliteration ─────────────────────────────
  static const appLocale = 'app_locale';
  static const appFontSize = 'app_font_size';
  static const appThemeMode = 'app_theme_mode';
  static const transliterationEnabled = 'transliteration_enabled';

  // ── Privacy opt-outs ────────────────────────────────────────────────────
  static const privacyAnalyticsEnabled = 'privacy_analytics_enabled';
  static const privacyCrashlyticsEnabled = 'privacy_crashlytics_enabled';

  // ── Dynamic-key prefixes (services own the runtime suffix) ──────────────
  /// `<this>_<bucket>_<yyyy>_<mm>_<dd>` — Gemini per-bucket daily count.
  static const geminiDailyPrefix = 'gemini_daily_';

  /// `<this>_<verseId>_<word>` — cached word-gloss replies.
  static const wordGlossPrefix = 'word_gloss_v1_';
}
