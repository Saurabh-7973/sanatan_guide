import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';
import 'package:sanatan_guide/data/festivals/festival_data_2026.dart';
import 'package:sanatan_guide/domain/entities/festival.dart';

part 'festival_provider.g.dart';

// ── Remote Config key ─────────────────────────────────────────────────────
// Value format in Firebase console (JSON string):
// {
//   "makar_sankranti": "2027-01-14",
//   "maha_shivratri": "2027-02-17",
//   "holi": "2027-03-25",
//   "ram_navami": "2027-04-17",
//   "hanuman_jayanti": "2027-04-27",
//   "guru_purnima": "2027-07-01",
//   "janmashtami": "2027-08-05",
//   "ganesh_chaturthi": "2027-09-11",
//   "navratri": "2027-09-30",
//   "dussehra": "2027-10-09",
//   "diwali": "2027-10-19",
//   "dev_deepawali": "2027-11-02"
// }
const _kFestivalDatesKey = 'festival_dates_override';

// ── Provider ──────────────────────────────────────────────────────────────

/// Returns the festival list with dates overridden from Remote Config
/// if available. Falls back to hardcoded 2026 dates silently.
@Riverpod(keepAlive: true)
Future<List<Festival>> festivals(Ref ref) async {
  try {
    final rc = FirebaseRemoteConfig.instance;

    // Set defaults so the app works offline or before first RC fetch
    await rc.setDefaults({_kFestivalDatesKey: ''});

    // Configure fetch settings
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? const Duration(minutes: 1) // Fast refresh in debug
            : const Duration(hours: 12), // Conservative in production
      ),
    );

    // Fetch and activate — non-blocking, fails silently
    await rc.fetchAndActivate();

    final raw = rc.getString(_kFestivalDatesKey);

    if (raw.isEmpty) {
      AppLogger.instance.i('FestivalProvider: using hardcoded 2026 dates');
      return festivals2026;
    }

    // Parse the date override map
    final Map<String, dynamic> overrides =
        json.decode(raw) as Map<String, dynamic>;

    // Apply overrides to the base festival list
    final updated = festivals2026.map((festival) {
      final dateStr = overrides[festival.id] as String?;
      if (dateStr == null) return festival;

      try {
        final newDate = DateTime.parse(dateStr);
        // Return a new Festival with the overridden date
        return Festival(
          id: festival.id,
          name: festival.name,
          sanskritName: festival.sanskritName,
          date: newDate,
          shortDesc: festival.shortDesc,
          explainer: festival.explainer,
          deity: festival.deity,
          emoji: festival.emoji,
          category: festival.category,
          howToObserve: festival.howToObserve,
        );
      } catch (e) {
        AppLogger.instance.w(
          'FestivalProvider: invalid date for ${festival.id}: $dateStr',
        );
        return festival;
      }
    }).toList();

    AppLogger.instance.i(
      'FestivalProvider: applied ${overrides.length} date override(s) from Remote Config',
    );
    return updated;
  } catch (e, st) {
    AppLogger.instance.w(
      'FestivalProvider: RC fetch failed, using 2026 dates',
      e,
      st,
    );
    return festivals2026;
  }
}
