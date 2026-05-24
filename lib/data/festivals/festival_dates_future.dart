// lib/data/festivals/festival_dates_future.dart
//
// Estimated Gregorian dates for the 12 v1 festivals across 2027-2030.
// Bundled as the in-app fallback so the app keeps showing correct dates
// after 2026 ends, even without a Firebase Remote Config update.
//
// ⚠ These are best-effort estimates derived from standard pañcāṅga
// conventions (e.g. Diwali = Kṛṣṇa Caturdaśī / Amāvasyā of Kārttika,
// Holi = Phālguna Pūrṇimā). They MUST be verified against Drik Panchang
// (https://www.drikpanchang.com/) before the corresponding year arrives,
// and overridden via Remote Config (`festival_dates_override`) if any
// drift is found.
//
// To verify a year: open Drik Panchang's "Year View" for that year, pull
// the date for each row below, and either confirm or push an override.

final Map<int, Map<String, DateTime>> futureFestivalDates = {
  2027: {
    'makar_sankranti': _d(2027, 1, 14),
    'maha_shivratri': _d(2027, 2, 17),
    'holi': _d(2027, 3, 24),
    'ram_navami': _d(2027, 4, 16),
    'hanuman_jayanti': _d(2027, 4, 22),
    'guru_purnima': _d(2027, 7, 19),
    'janmashtami': _d(2027, 9, 4),
    'ganesh_chaturthi': _d(2027, 9, 9),
    'navratri': _d(2027, 10, 2),
    'dussehra': _d(2027, 10, 11),
    'diwali': _d(2027, 11, 5),
    'dev_deepawali': _d(2027, 11, 14),
  },
  2028: {
    'makar_sankranti': _d(2028, 1, 14),
    'maha_shivratri': _d(2028, 2, 6),
    'holi': _d(2028, 3, 12),
    'ram_navami': _d(2028, 4, 4),
    'hanuman_jayanti': _d(2028, 4, 10),
    'guru_purnima': _d(2028, 7, 6),
    'janmashtami': _d(2028, 8, 23),
    'ganesh_chaturthi': _d(2028, 8, 28),
    'navratri': _d(2028, 9, 20),
    'dussehra': _d(2028, 9, 29),
    'diwali': _d(2028, 10, 24),
    'dev_deepawali': _d(2028, 11, 2),
  },
  2029: {
    'makar_sankranti': _d(2029, 1, 14),
    'maha_shivratri': _d(2029, 2, 25),
    'holi': _d(2029, 3, 30),
    'ram_navami': _d(2029, 4, 23),
    'hanuman_jayanti': _d(2029, 4, 29),
    'guru_purnima': _d(2029, 7, 26),
    'janmashtami': _d(2029, 9, 11),
    'ganesh_chaturthi': _d(2029, 9, 16),
    'navratri': _d(2029, 10, 8),
    'dussehra': _d(2029, 10, 17),
    'diwali': _d(2029, 11, 12),
    'dev_deepawali': _d(2029, 11, 21),
  },
  2030: {
    'makar_sankranti': _d(2030, 1, 14),
    'maha_shivratri': _d(2030, 2, 14),
    'holi': _d(2030, 3, 19),
    'ram_navami': _d(2030, 4, 12),
    'hanuman_jayanti': _d(2030, 4, 18),
    'guru_purnima': _d(2030, 7, 15),
    'janmashtami': _d(2030, 8, 31),
    'ganesh_chaturthi': _d(2030, 9, 5),
    'navratri': _d(2030, 9, 27),
    'dussehra': _d(2030, 10, 6),
    'diwali': _d(2030, 10, 27),
    'dev_deepawali': _d(2030, 11, 10),
  },
};

DateTime _d(int y, int m, int d) => DateTime(y, m, d);
