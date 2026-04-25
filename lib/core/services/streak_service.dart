import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanatan_guide/core/services/analytics_service.dart';
import 'package:sanatan_guide/core/services/review_service.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';

part 'streak_service.g.dart';

// ── Keys ──────────────────────────────────────────────────────────────────
const _kLastReadDateKey = 'streak_last_read_date';
const _kCurrentStreakKey = 'streak_current_count';
const _kLongestStreakKey = 'streak_longest_count';
const _kReadHistoryKey = 'streak_read_history'; // comma-separated yyyy-MM-dd
const _kLastReadVerseIdKey = 'last_read_verse_id';
const _kLastReadScriptureKey = 'last_read_scripture_code';

// ── Service ───────────────────────────────────────────────────────────────

final class StreakService {
  StreakService._();

  static final StreakService instance = StreakService._();

  /// Storage key for a calendar date (`yyyy-MM-dd`), matching read history keys.
  static String formatReadDateKey(DateTime date) => '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Records that the user read something today.
  /// Updates streak count and read history.
  static Future<void> recordReadingToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = formatReadDateKey(DateTime.now());
      final lastRead = prefs.getString(_kLastReadDateKey);

      // Already recorded today — but still ensure today is in history
      // (handles the case where history tracking was added after the streak
      // was already recorded for today)
      if (lastRead == today) {
        final historyRaw = prefs.getString(_kReadHistoryKey) ?? '';
        if (!historyRaw.contains(today)) {
          final history =
              historyRaw.isEmpty ? <String>{} : historyRaw.split(',').toSet();
          history.add(today);
          await prefs.setString(_kReadHistoryKey, history.join(','));
        }
        return;
      }

      final current = prefs.getInt(_kCurrentStreakKey) ?? 0;
      final longest = prefs.getInt(_kLongestStreakKey) ?? 0;

      final yesterday = formatReadDateKey(
        DateTime.now().subtract(const Duration(days: 1)),
      );

      int newStreak;
      if (lastRead == yesterday) {
        newStreak = current + 1;
      } else {
        newStreak = 1;
      }

      final newLongest = newStreak > longest ? newStreak : longest;

      // ── Update read history ───────────────────────────────────────────
      // Keep a rolling set of the last 60 days max
      final historyRaw = prefs.getString(_kReadHistoryKey) ?? '';
      final history =
          historyRaw.isEmpty ? <String>{} : historyRaw.split(',').toSet();
      history.add(today);

      // Prune entries older than 60 days
      final cutoff = DateTime.now().subtract(const Duration(days: 60));
      history.removeWhere((d) {
        try {
          return DateTime.parse(d).isBefore(cutoff);
        } catch (_) {
          return true;
        }
      });

      await prefs.setString(_kLastReadDateKey, today);
      await prefs.setInt(_kCurrentStreakKey, newStreak);
      await prefs.setInt(_kLongestStreakKey, newLongest);
      await prefs.setString(_kReadHistoryKey, history.join(','));

      if (newStreak == 7) {
        // duringReading=false: StreakService is called from verse_detail_page
        // but we intentionally skip the review there to respect the trust covenant.
        // The call from module_reader_page is fine (not verse reading).
        unawaited(ReviewService.maybeRequestReview(ReviewTrigger.streak7Day));
      }

      const milestones = {3, 7, 14, 30, 100};
      if (milestones.contains(newStreak)) {
        AnalyticsService.streakAchieved(newStreak);
      }

      AppLogger.instance.i(
        'Streak updated: $newStreak days (longest: $newLongest)',
      );
    } catch (e, st) {
      AppLogger.instance.w('StreakService.recordReadingToday failed', e, st);
    }
  }

  /// Returns the current streak count. Returns 0 if never read.
  static Future<int> getCurrentStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = formatReadDateKey(DateTime.now());
      final yesterday = formatReadDateKey(
        DateTime.now().subtract(const Duration(days: 1)),
      );
      final lastRead = prefs.getString(_kLastReadDateKey);

      if (lastRead == today || lastRead == yesterday) {
        return prefs.getInt(_kCurrentStreakKey) ?? 0;
      }
      return 0;
    } catch (e, st) {
      AppLogger.instance.w('StreakService.getCurrentStreak failed', e, st);
      return 0;
    }
  }

  /// Saves the last-read verse for "Continue Reading" on Home.
  static Future<void> saveLastReadVerse(
    String verseId,
    String scriptureCode,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLastReadVerseIdKey, verseId);
      await prefs.setString(_kLastReadScriptureKey, scriptureCode);
    } catch (e, st) {
      AppLogger.instance.w('saveLastReadVerse failed', e, st);
    }
  }

  /// Returns (verseId, scriptureCode) or null if nothing read yet.
  static Future<({String verseId, String scriptureCode})?>
      getLastReadVerse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_kLastReadVerseIdKey);
      final code = prefs.getString(_kLastReadScriptureKey);
      if (id != null && code != null) {
        return (verseId: id, scriptureCode: code);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Clears all reading history: streak counts, dates, and last-read info.
  /// Bookmarks and notes are NOT affected.
  Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_kLastReadDateKey),
      prefs.remove(_kCurrentStreakKey),
      prefs.remove(_kLongestStreakKey),
      prefs.remove(_kReadHistoryKey),
      prefs.remove(_kLastReadVerseIdKey),
      prefs.remove(_kLastReadScriptureKey),
    ]);
  }

  /// Returns the set of dates (yyyy-MM-dd) the user read on.
  static Future<Set<String>> getReadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kReadHistoryKey) ?? '';
      if (raw.isEmpty) return {};
      return raw.split(',').toSet();
    } catch (e, st) {
      AppLogger.instance.w('StreakService.getReadHistory failed', e, st);
      return {};
    }
  }
}

// ── Riverpod providers ────────────────────────────────────────────────────

/// Reactive current streak count.
/// Invalidate after calling recordReadingToday().
@riverpod
Future<int> currentStreak(Ref ref) => StreakService.getCurrentStreak();

/// Reactive read history — set of yyyy-MM-dd strings.
/// Invalidate after calling recordReadingToday().
@riverpod
Future<Set<String>> readHistory(Ref ref) => StreakService.getReadHistory();

/// Last-read verse. Invalidate after reading a new verse.
@riverpod
Future<({String verseId, String scriptureCode})?> lastReadVerse(Ref ref) =>
    StreakService.getLastReadVerse();
