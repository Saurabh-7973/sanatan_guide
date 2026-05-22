// lib/core/panchanga/panchanga.dart
//
// A self-contained pañcāṅga calculator. Given an instant it derives the five
// aṅgas — tithi, vāra, nakṣatra, yoga, karaṇa — from the Sun's and Moon's
// ecliptic longitudes.
//
// Astronomy: low-precision solar theory (Meeus, "Astronomical Algorithms",
// ch. 25) and an abridged lunar series (ch. 47, ~35 largest longitude terms).
// Accuracy is sub-arcminute for the Sun and a few arcseconds for the Moon —
// far inside the 12° tithi / 13°20′ nakṣatra buckets. ΔT and the small
// planetary/E-factor corrections are omitted (< 0.001° effect on the
// Moon−Sun elongation).
//
// This is a *computed* almanac. It is religiously load-bearing — verify the
// engine against an independent reference (see panchanga_test.dart) before
// relying on it, and keep the "consult your local pandit" disclaimer in the
// UI for regional variation.

import 'dart:math' as math;

import 'package:sanatan_guide/core/panchanga/panchanga_names.dart';

enum Paksha {
  shukla('शुक्ल', 'Śukla'),
  krishna('कृष्ण', 'Kṛṣṇa');

  const Paksha(this.deva, this.iast);
  final String deva;
  final String iast;
}

/// The five aṅgas of the pañcāṅga for one instant.
class Panchanga {
  const Panchanga({
    required this.instant,
    required this.tithiIndex,
    required this.paksha,
    required this.tithi,
    required this.nakshatraIndex,
    required this.nakshatra,
    required this.yogaIndex,
    required this.yoga,
    required this.karanaIndex,
    required this.karana,
    required this.vara,
  });

  final DateTime instant;

  /// 0–29 over the lunar month (0 = first tithi of Śukla pakṣa).
  final int tithiIndex;
  final Paksha paksha;

  /// The tithi name (Pūrṇimā / Amāvāsyā substituted for the 15th).
  final PanchangaName tithi;

  /// 0–26 from Aśvinī.
  final int nakshatraIndex;
  final PanchangaName nakshatra;

  /// 0–26 from Viṣkambha.
  final int yogaIndex;
  final PanchangaName yoga;

  /// 0–59 over the lunar month.
  final int karanaIndex;
  final PanchangaName karana;

  final PanchangaName vara;

  /// e.g. `शुक्ल त्रयोदशी`.
  String get tithiLabelDeva => '${paksha.deva} ${tithi.deva}';

  /// e.g. `Śukla Trayodaśī`.
  String get tithiLabelIast => '${paksha.iast} ${tithi.iast}';
}

// ── Engine ─────────────────────────────────────────────────────────────────

const double _deg2rad = math.pi / 180.0;

double _norm360(double x) {
  final r = x % 360.0;
  return r < 0 ? r + 360.0 : r;
}

/// Julian Day for [instant] (converted to UTC).
double julianDay(DateTime instant) {
  final utc = instant.toUtc();
  var year = utc.year;
  var month = utc.month;
  final dayFraction =
      utc.day + (utc.hour + utc.minute / 60.0 + utc.second / 3600.0) / 24.0;
  if (month <= 2) {
    year -= 1;
    month += 12;
  }
  final a = (year / 100).floor();
  final b = 2 - a + (a / 4).floor();
  return (365.25 * (year + 4716)).floor() +
      (30.6001 * (month + 1)).floor() +
      dayFraction +
      b -
      1524.5;
}

/// Sun's apparent ecliptic longitude, degrees, mean equinox of date.
double sunLongitude(double t) {
  final l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
  final m = (357.52911 + 35999.05029 * t - 0.0001537 * t * t) * _deg2rad;
  final c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * math.sin(m) +
      (0.019993 - 0.000101 * t) * math.sin(2 * m) +
      0.000289 * math.sin(3 * m);
  final trueLong = l0 + c;
  final omega = (125.04 - 1934.136 * t) * _deg2rad;
  return _norm360(trueLong - 0.00569 - 0.00478 * math.sin(omega));
}

// Abridged lunar longitude series — [D, M, M', F, coefficient×1e-6 deg].
const List<List<int>> _moonTerms = [
  [0, 0, 1, 0, 6288774],
  [2, 0, -1, 0, 1274027],
  [2, 0, 0, 0, 658314],
  [0, 0, 2, 0, 213618],
  [0, 1, 0, 0, -185116],
  [0, 0, 0, 2, -114332],
  [2, 0, -2, 0, 58793],
  [2, -1, -1, 0, 57066],
  [2, 0, 1, 0, 53322],
  [2, -1, 0, 0, 45758],
  [0, 1, -1, 0, -40923],
  [1, 0, 0, 0, -34720],
  [0, 1, 1, 0, -30383],
  [2, 0, 0, -2, 15327],
  [0, 0, 1, 2, -12528],
  [0, 0, 1, -2, 10980],
  [4, 0, -1, 0, 10675],
  [0, 0, 3, 0, 10034],
  [4, 0, -2, 0, 8548],
  [2, 1, -1, 0, -7888],
  [2, 1, 0, 0, -6766],
  [1, 0, -1, 0, -5163],
  [1, 1, 0, 0, 4987],
  [2, -1, 1, 0, 4036],
  [2, 0, 2, 0, 3994],
  [4, 0, 0, 0, 3861],
  [2, 0, -3, 0, 3665],
  [0, 1, -2, 0, -2689],
  [2, 0, -1, 2, -2602],
  [2, -1, -2, 0, 2390],
  [1, 0, 1, 0, -2348],
  [2, -2, 0, 0, 2236],
  [0, 1, 2, 0, -2120],
  [0, 2, 0, 0, -2069],
  [2, -2, -1, 0, 2048],
];

/// Moon's ecliptic longitude, degrees, mean equinox of date.
double moonLongitude(double t) {
  final t2 = t * t;
  final t3 = t2 * t;
  final t4 = t3 * t;

  final lp = 218.3164477 +
      481267.88123421 * t -
      0.0015786 * t2 +
      t3 / 538841.0 -
      t4 / 65194000.0;
  final d = 297.8501921 +
      445267.1114034 * t -
      0.0018819 * t2 +
      t3 / 545868.0 -
      t4 / 113065000.0;
  final m = 357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000.0;
  final mp = 134.9633964 +
      477198.8675055 * t +
      0.0087414 * t2 +
      t3 / 69699.0 -
      t4 / 14712000.0;
  final f = 93.2720950 +
      483202.0175233 * t -
      0.0036539 * t2 -
      t3 / 3526000.0 +
      t4 / 863310000.0;

  var sum = 0.0;
  for (final term in _moonTerms) {
    final arg =
        (term[0] * d + term[1] * m + term[2] * mp + term[3] * f) * _deg2rad;
    sum += term[4] * math.sin(arg);
  }
  return _norm360(lp + sum / 1000000.0);
}

/// Lahiri (Chitrapakṣa) ayanāṃśa, degrees. Linear model: 23.853° at J2000.0
/// drifting 50.2388″ per year — accurate to a few arcseconds for this era.
double lahiriAyanamsa(double t) => 23.853 + 1.39552 * t;

/// Computes the pañcāṅga for [instant].
///
/// Pass the instant whose aṅgas you want. For a traditional "day" value, pass
/// that day's local sunrise (the aṅga prevailing at sunrise names the day).
Panchanga computePanchanga(DateTime instant) {
  final t = (julianDay(instant) - 2451545.0) / 36525.0;

  final sun = sunLongitude(t);
  final moon = moonLongitude(t);

  // Tithi & karaṇa from the Moon−Sun elongation.
  final elongation = _norm360(moon - sun);
  final tithiIndex = (elongation / 12.0).floor().clamp(0, 29);
  final paksha = tithiIndex < 15 ? Paksha.shukla : Paksha.krishna;
  final inPaksha = tithiIndex % 15;
  final tithi = (paksha == Paksha.krishna && inPaksha == 14)
      ? amavasya
      : tithiNames[inPaksha];

  final karanaIndex = (elongation / 6.0).floor().clamp(0, 59);
  final PanchangaName karana;
  if (karanaIndex == 0) {
    karana = karanaKimstughna;
  } else if (karanaIndex <= 56) {
    karana = movableKaranas[(karanaIndex - 1) % 7];
  } else if (karanaIndex == 57) {
    karana = karanaShakuni;
  } else if (karanaIndex == 58) {
    karana = karanaChatushpada;
  } else {
    karana = karanaNaga;
  }

  // Nakṣatra from the sidereal lunar longitude.
  final sidereal = _norm360(moon - lahiriAyanamsa(t));
  final nakshatraIndex = (sidereal / (360.0 / 27.0)).floor().clamp(0, 26);

  // Yoga from the summed longitudes.
  final yogaIndex =
      (_norm360(sun + moon) / (360.0 / 27.0)).floor().clamp(0, 26);

  return Panchanga(
    instant: instant,
    tithiIndex: tithiIndex,
    paksha: paksha,
    tithi: tithi,
    nakshatraIndex: nakshatraIndex,
    nakshatra: nakshatraNames[nakshatraIndex],
    yogaIndex: yogaIndex,
    yoga: yogaNames[yogaIndex],
    karanaIndex: karanaIndex,
    karana: karana,
    vara: varaNames[instant.weekday - 1],
  );
}

// ── Lunar month (amānta, adhika-aware) ──────────────────────────────────────

/// The sidereal solar rāśi for [instant]: 0 = Meṣa … 11 = Mīna.
int solarRashi(DateTime instant) {
  final t = (julianDay(instant) - 2451545.0) / 36525.0;
  return (_norm360(sunLongitude(t) - lahiriAyanamsa(t)) / 30.0).floor() % 12;
}

/// An amānta lunar month — its name index and whether it is an adhika māsa.
class LunarMonth {
  const LunarMonth(this.index, this.isAdhika);

  /// Caitra = 0 … Phālguna = 11.
  final int index;

  /// True for an adhika (Puruṣottama / leap) māsa — a lunar month that
  /// spans no saṅkrānti. It carries the following nija month's name.
  final bool isAdhika;
}

const double _synodicMonth = 29.530588861;

/// Moon−Sun elongation at [instant], signed to (−180°, 180°] — zero at the
/// new moon, rising ~12°/day.
double _signedElongation(DateTime instant) {
  final t = (julianDay(instant) - 2451545.0) / 36525.0;
  final e = _norm360(moonLongitude(t) - sunLongitude(t));
  return e > 180.0 ? e - 360.0 : e;
}

/// The instant of the new moon at or before [date].
///
/// Adhika-māsa detection turns on whether a saṅkrānti falls inside a
/// lunar month — a knife-edge that day-granular sampling cannot resolve,
/// so the new moon is pinned to the second by bisection.
DateTime _newMoonOnOrBefore(DateTime date) {
  final e = _signedElongation(date);
  final daysSince = (e >= 0 ? e : e + 360.0) / 360.0 * _synodicMonth;
  final guess = date.subtract(Duration(minutes: (daysSince * 1440.0).round()));
  var lo = guess.subtract(const Duration(days: 2));
  var hi = guess.add(const Duration(days: 2));
  for (var i = 0; i < 42; i++) {
    final mid = lo.add(Duration(seconds: hi.difference(lo).inSeconds ~/ 2));
    if (_signedElongation(mid) < 0) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return lo;
}

/// The amānta lunar month containing [date].
///
/// A nija month is named after the rāśi the Sun occupies at its starting
/// new moon (Sun in Meṣa → Vaiśākha). A month spanning no saṅkrānti — the
/// Sun in one rāśi from new moon to new moon — is an adhika māsa and
/// carries the following nija month's name.
LunarMonth lunarMonthOf(DateTime date) {
  final start = _newMoonOnOrBefore(date);
  final nextStart = _newMoonOnOrBefore(start.add(const Duration(days: 31)));
  final startRashi = solarRashi(start);
  final nextRashi = solarRashi(nextStart);
  return LunarMonth((startRashi + 1) % 12, startRashi == nextRashi);
}
