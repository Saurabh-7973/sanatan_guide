import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanatan_guide/core/constants/preferences_keys.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';

enum ReviewTrigger { streak7Day, chapterCompleted, moduleCompleted }

final class ReviewService {
  ReviewService._();
  static const _thirtyDaysMs = 30 * 24 * 60 * 60 * 1000;

  static final InAppReview _inAppReview = InAppReview.instance;

  /// Request an in-app review for the given [trigger].
  ///
  /// Rules enforced here:
  ///   • Never more than once per 30 days.
  ///   • Chapter / module triggers fire only the first time.
  ///   • [ReviewTrigger.streak7Day] should NOT be called from inside the
  ///     verse reader — pass it from StreakService only when [duringReading]
  ///     is false (default).
  static Future<void> maybeRequestReview(
    ReviewTrigger trigger, {
    bool duringReading = false,
  }) async {
    if (duringReading) return; // trust covenant — never interrupt verse reading

    try {
      final prefs = await SharedPreferences.getInstance();

      // ── One-time guards for chapter / module triggers ─────────────────────
      if (trigger == ReviewTrigger.chapterCompleted) {
        final done = prefs.getBool(PrefsKeys.reviewFirstChapterDone) ?? false;
        if (done) return; // only fire once
        await prefs.setBool(PrefsKeys.reviewFirstChapterDone, true);
      }
      if (trigger == ReviewTrigger.moduleCompleted) {
        final done = prefs.getBool(PrefsKeys.reviewFirstModuleDone) ?? false;
        if (done) return; // only fire once
        await prefs.setBool(PrefsKeys.reviewFirstModuleDone, true);
      }

      // ── 30-day global cooldown ────────────────────────────────────────────
      final lastMs = prefs.getInt(PrefsKeys.reviewLastRequestedMs) ?? 0;
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      if (nowMs - lastMs < _thirtyDaysMs) {
        AppLogger.instance.i(
          'ReviewService: skipped ($trigger) — within 30-day cooldown',
        );
        return;
      }

      final isAvailable = await _inAppReview.isAvailable();
      if (!isAvailable) {
        AppLogger.instance.i(
          'ReviewService: not available (dev/emulator) — $trigger',
        );
        return;
      }

      await _inAppReview.requestReview();
      await prefs.setInt(PrefsKeys.reviewLastRequestedMs, nowMs);
      AppLogger.instance.i('ReviewService: review dialog shown ($trigger)');
    } catch (e, st) {
      AppLogger.instance.w(
        'ReviewService.maybeRequestReview failed ($trigger)',
        e,
        st,
      );
    }
  }

  /// Legacy alias kept for any existing call sites.
  static Future<void> requestReviewIfAppropriate() =>
      maybeRequestReview(ReviewTrigger.moduleCompleted);
}
