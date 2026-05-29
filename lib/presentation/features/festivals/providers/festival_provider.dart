import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanatan_guide/core/constants/preferences_keys.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';
import 'package:sanatan_guide/data/festivals/festival_data_2026.dart';
import 'package:sanatan_guide/data/festivals/festival_dates_future.dart';
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

// ── Provider ──────────────────────────────────────────────────────────────

/// Returns the festival list with dates overridden from Remote Config
/// if available. Falls back to hardcoded 2026 dates silently.
@Riverpod(keepAlive: true)
Future<List<Festival>> festivals(Ref ref) async {
  try {
    final rc = FirebaseRemoteConfig.instance;

    // Set defaults so the app works offline or before first RC fetch
    await rc.setDefaults({PrefsKeys.festivalDatesOverride: ''});

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

    final raw = rc.getString(PrefsKeys.festivalDatesOverride);

    if (raw.isEmpty) {
      // No Remote Config push — fall through to the bundled fallback below
      // (year-aware) so the app keeps producing correct dates after 2026
      // without depending on a server roll-out.
      return _withBundledYearOverrides(festivals2026);
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
          readingVerseId: festival.readingVerseId,
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
    return _withBundledYearOverrides(festivals2026);
  }
}

/// Apply [futureFestivalDates] for the current device year. The base list
/// is `festivals2026` so explainer + practices stay year-invariant; only
/// the `date` field is rewritten when the device's year has a bundled
/// override. Year < 2027 returns the base list unchanged.
List<Festival> _withBundledYearOverrides(List<Festival> base) {
  final year = DateTime.now().year;
  if (year < 2027) return base;
  final overrides = futureFestivalDates[year];
  if (overrides == null) {
    // Beyond bundled range — return base list, user sees 2026 dates as a
    // best-effort fallback until Remote Config pushes new ones.
    AppLogger.instance.w(
      'FestivalProvider: no bundled dates for year $year; '
      'falling back to 2026 dates. Push Remote Config to fix.',
    );
    return base;
  }
  return base.map((f) {
    final d = overrides[f.id];
    if (d == null) return f;
    return Festival(
      id: f.id,
      name: f.name,
      sanskritName: f.sanskritName,
      date: d,
      shortDesc: f.shortDesc,
      explainer: f.explainer,
      deity: f.deity,
      emoji: f.emoji,
      category: f.category,
      howToObserve: f.howToObserve,
      readingVerseId: f.readingVerseId,
    );
  }).toList();
}
