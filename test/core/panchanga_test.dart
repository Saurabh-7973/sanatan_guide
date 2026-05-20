import 'package:flutter_test/flutter_test.dart';

import 'package:sanatan_guide/core/panchanga/panchanga.dart';

/// The pañcāṅga engine is verified against two independent textbook
/// references — Meeus's worked lunar example and the astronomical equinox.
///
/// NOTE: the `screen-08-festivals.html` mockup prints pañcāṅga values for
/// May 2026 that do NOT match this (verified) engine — those mockup values
/// are illustrative placeholders, not a real almanac. The almanac UI must
/// render the engine's output, not the mockup's printed numbers.
void main() {
  group('engine verified against textbook references', () {
    test('Moon longitude matches Meeus worked example 47.a', () {
      // Meeus, "Astronomical Algorithms", example 47.a: 1992 April 12, 0h TD.
      // Geocentric ecliptic longitude λ ≈ 133.162659° (mean equinox of date).
      final t =
          (julianDay(DateTime.utc(1992, 4, 12)) - 2451545.0) / 36525.0;
      expect(moonLongitude(t), closeTo(133.1627, 0.05));
    });

    test('Sun longitude is ~0° at the March 2026 equinox', () {
      // Vernal equinox 2026: ~20 March 14:46 UTC — Sun apparent longitude 0°.
      final t = (julianDay(DateTime.utc(2026, 3, 20, 14, 46)) - 2451545.0) /
          36525.0;
      final lon = sunLongitude(t);
      final delta = lon > 180 ? 360 - lon : lon;
      expect(delta, lessThan(0.1));
    });

    test('Lahiri ayanāṃśa is ~24.2° for 2026', () {
      final t = (julianDay(DateTime.utc(2026, 1, 1)) - 2451545.0) / 36525.0;
      expect(lahiriAyanamsa(t), closeTo(24.21, 0.1));
    });
  });

  group('structural sanity', () {
    test('every aṅga index stays in range over a full year', () {
      for (var d = 0; d < 365; d++) {
        final p =
            computePanchanga(DateTime.utc(2026, 1, 1).add(Duration(days: d)));
        expect(p.tithiIndex, inInclusiveRange(0, 29));
        expect(p.karanaIndex, inInclusiveRange(0, 59));
        expect(p.nakshatraIndex, inInclusiveRange(0, 26));
        expect(p.yogaIndex, inInclusiveRange(0, 26));
      }
    });

    test('tithi advances ~one per day and wraps over a synodic month', () {
      final seen = <int>{};
      var prev = computePanchanga(DateTime.utc(2026, 1, 1)).tithiIndex;
      var wraps = 0;
      for (var d = 1; d <= 30; d++) {
        final cur =
            computePanchanga(DateTime.utc(2026, 1, 1).add(Duration(days: d)))
                .tithiIndex;
        seen.add(cur);
        // Day-to-day step is 0 or 1 tithis (or a wrap 29 → 0).
        final step = cur - prev;
        expect(step == 0 || step == 1 || step == -29, isTrue,
            reason: 'day $d: $prev → $cur');
        if (step == -29) wraps++;
        prev = cur;
      }
      expect(wraps, 1); // exactly one new-moon wrap in ~30 days
      expect(seen.length, greaterThan(20)); // most tithis visited
    });

    test('Pūrṇimā falls only in Śukla pakṣa, Amāvāsyā only in Kṛṣṇa', () {
      for (var d = 0; d < 60; d++) {
        final p =
            computePanchanga(DateTime.utc(2026, 4, 1).add(Duration(days: d)));
        if (p.tithi.iast == 'Pūrṇimā') expect(p.paksha, Paksha.shukla);
        if (p.tithi.iast == 'Amāvāsyā') expect(p.paksha, Paksha.krishna);
      }
    });

    test('vāra tracks the weekday', () {
      final p = computePanchanga(DateTime.utc(2026, 5, 4)); // a Monday
      expect(p.vara.iast, 'Somavāra');
    });
  });
}
