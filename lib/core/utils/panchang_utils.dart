import 'package:flutter/foundation.dart';

// ── Vara (weekday) ────────────────────────────────────────────────────────

@immutable
class VaraInfo {
  const VaraInfo({
    required this.varaName,
    required this.deity,
    required this.significance,
    required this.emoji,
  });

  final String varaName;
  final String deity;
  final String significance;
  final String emoji;
}

// ── Tithi (lunar day) ─────────────────────────────────────────────────────

@immutable
class TithiInfo {
  const TithiInfo({
    required this.tithiName,
    required this.paksha,
    required this.significance,
  });

  final String tithiName; // e.g. 'Ekadashi'
  final String paksha; // 'Shukla Paksha' or 'Krishna Paksha'
  final String significance; // one-line meaning
}

// ── Nakshatra (lunar mansion) ─────────────────────────────────────────────

@immutable
class NakshatraInfo {
  const NakshatraInfo({
    required this.nakshatraName,
    required this.deity,
    required this.significance,
  });

  final String nakshatraName; // e.g. 'Pushya'
  final String deity; // e.g. 'Brihaspati'
  final String significance; // one-line meaning
}

// ── Hindu month / year ───────────────────────────────────────────────────

@immutable
class HinduDateInfo {
  const HinduDateInfo({
    required this.monthName,
    required this.vikramSamvatYear,
  });

  final String monthName;
  final int vikramSamvatYear;
}

// ── Greeting ─────────────────────────────────────────────────────────────

String greetingForTimeOfDay(DateTime now) {
  final hour = now.hour;
  if (hour >= 5 && hour < 11) return 'Shubh Prabhat';
  if (hour >= 11 && hour < 17) return 'Namaste';
  if (hour >= 17 && hour < 21) return 'Shubh Sandhya';
  return 'Shubh Ratri';
}

// ── Panchang utils ────────────────────────────────────────────────────────

abstract final class PanchangUtils {
  // ── Hindu month & Vikram Samvat year ─────────────────────────────────────
  //
  // Amanta system: month starts at new moon.
  // Reference: Jan 29, 2025 new moon = start of Magha (month index 10).
  // Vikram Samvat year changes at Chaitra Shukla Pratipada (~March/April).

  static const List<String> _hinduMonthNames = [
    'Chaitra',
    'Vaishakha',
    'Jyeshtha',
    'Ashadha',
    'Shravana',
    'Bhadrapada',
    'Ashwin',
    'Kartik',
    'Margashirsha',
    'Pausha',
    'Magha',
    'Phalguna',
  ];

  static HinduDateInfo getHinduDate(DateTime date) {
    const referenceNewMoonMs = 1738151760000; // Jan 29, 2025 12:36 UTC
    const synodicDays = 29.53058868;
    const msPerDay = 86400000.0;
    const referenceMonthIndex = 10; // Magha

    final daysSinceRef =
        (date.toUtc().millisecondsSinceEpoch - referenceNewMoonMs) / msPerDay;

    final lunarMonths = (daysSinceRef / synodicDays).floor();
    final monthIndex = (referenceMonthIndex + lunarMonths) % 12;

    // VS year: Chaitra (index 0) onwards = Gregorian year + 57
    // Before Chaitra (Pausha..Phalguna) = Gregorian year + 56
    final vsYear =
        monthIndex >= 0 && monthIndex <= 8 ? date.year + 57 : date.year + 56;

    return HinduDateInfo(
      monthName: _hinduMonthNames[monthIndex],
      vikramSamvatYear: vsYear,
    );
  }

  // ── Vara ────────────────────────────────────────────────────────────────

  static VaraInfo getVaraForDate(DateTime date) {
    return switch (date.weekday) {
      1 => const VaraInfo(
          varaName: 'Somavara',
          deity: 'Shiva',
          significance:
              'Monday — presided by Chandra. Auspicious for fasting and Shiva worship.',
          emoji: '🌙',
        ),
      2 => const VaraInfo(
          varaName: 'Mangalavara',
          deity: 'Hanuman',
          significance:
              'Tuesday — presided by Mangala. Auspicious for strength and courage.',
          emoji: '🔴',
        ),
      3 => const VaraInfo(
          varaName: 'Budhavara',
          deity: 'Vishnu',
          significance:
              'Wednesday — presided by Budha. Auspicious for learning and trade.',
          emoji: '💚',
        ),
      4 => const VaraInfo(
          varaName: 'Guruvara',
          deity: 'Brihaspati',
          significance:
              'Thursday — presided by Brihaspati. Most auspicious for the Guru.',
          emoji: '🟡',
        ),
      5 => const VaraInfo(
          varaName: 'Shukravara',
          deity: 'Lakshmi',
          significance:
              'Friday — presided by Shukra. Auspicious for beauty and abundance.',
          emoji: '🌸',
        ),
      6 => const VaraInfo(
          varaName: 'Shanivara',
          deity: 'Shani',
          significance:
              'Saturday — presided by Shani. Day of discipline and karmic reflection.',
          emoji: '🪐',
        ),
      7 => const VaraInfo(
          varaName: 'Ravivara',
          deity: 'Surya',
          significance:
              'Sunday — presided by Surya. Auspicious for vitality and clarity.',
          emoji: '☀️',
        ),
      _ => const VaraInfo(
          varaName: 'Ravivara',
          deity: 'Surya',
          significance: 'Sunday — presided by Surya.',
          emoji: '☀️',
        ),
    };
  }

  // ── Tithi ────────────────────────────────────────────────────────────────
  //
  // Calculation approach:
  //   Reference new moon: Jan 29, 2025 at 12:36 UTC
  //   Synodic month: 29.53058868 days
  //   30 tithis per synodic month → each tithi ≈ 0.98435 days
  //   Tithis 0–14 = Shukla Paksha (Pratipada → Purnima)
  //   Tithis 15–29 = Krishna Paksha (Pratipada → Amavasya)
  //   Accuracy: ±1 tithi (sufficient for informational display)

  static TithiInfo getTithiForDate(DateTime date) {
    const referenceNewMoonMs = 1738151760000; // Jan 29 2025 12:36 UTC in ms
    const synodicDays = 29.53058868;
    const msPerDay = 86400000.0;

    final daysSinceRef =
        (date.toUtc().millisecondsSinceEpoch - referenceNewMoonMs) / msPerDay;

    // Normalise to [0, synodicDays)
    final daysInCycle = daysSinceRef % synodicDays;
    final cyclePosition =
        daysInCycle < 0 ? daysInCycle + synodicDays : daysInCycle;

    // Map to tithi index 0–29
    final tithiIndex = (cyclePosition / synodicDays * 30).floor().clamp(0, 29);

    if (tithiIndex < 15) {
      // Shukla Paksha
      return TithiInfo(
        tithiName: _shuklaTithiNames[tithiIndex],
        paksha: 'Shukla Paksha',
        significance: _shuklaTithiSignificance[tithiIndex],
      );
    } else {
      // Krishna Paksha (index 15 = Krishna Pratipada)
      final krishnaIndex = tithiIndex - 15;
      return TithiInfo(
        tithiName: _krishnaTithiNames[krishnaIndex],
        paksha: 'Krishna Paksha',
        significance: _krishnaTithiSignificance[krishnaIndex],
      );
    }
  }

  // ── Nakshatra ─────────────────────────────────────────────────────────────
  //
  // Calculation approach:
  //   The Moon moves through all 27 nakshatras in 27.32166 days (sidereal month)
  //   Reference: Moon was at nakshatra index 6 (Punarvasu) on Jan 1, 2000 UTC
  //   Each nakshatra = 360° / 27 = 13.333°
  //   Accuracy: ±1 nakshatra (sufficient for informational display)

  static NakshatraInfo getNakshatraForDate(DateTime date) {
    const referenceMs = 946684800000; // Jan 1 2000 00:00 UTC in ms
    const siderealDays = 27.32166;
    const msPerDay = 86400000.0;
    const referenceNakshatraIndex = 6; // Punarvasu on Jan 1 2000

    final daysSinceRef =
        (date.toUtc().millisecondsSinceEpoch - referenceMs) / msPerDay;

    final cyclesElapsed = daysSinceRef / siderealDays;
    final fractionalCycle = cyclesElapsed - cyclesElapsed.floor(); // 0.0 to 1.0

    final rawIndex = (fractionalCycle * 27).floor() + referenceNakshatraIndex;
    final nakshatraIndex = rawIndex % 27;

    return NakshatraInfo(
      nakshatraName: _nakshatraNames[nakshatraIndex],
      deity: _nakshatraDeities[nakshatraIndex],
      significance: _nakshatraSignificance[nakshatraIndex],
    );
  }

  // ── Tithi data ────────────────────────────────────────────────────────────

  // ── Devanagari name maps (for the Home panchang line) ──────────────────

  static const Map<String, String> _hinduMonthDeva = {
    'Chaitra': 'चैत्र',
    'Vaishakha': 'वैशाख',
    'Jyeshtha': 'ज्येष्ठ',
    'Ashadha': 'आषाढ़',
    'Shravana': 'श्रावण',
    'Bhadrapada': 'भाद्रपद',
    'Ashwin': 'आश्विन',
    'Kartik': 'कार्तिक',
    'Margashirsha': 'मार्गशीर्ष',
    'Pausha': 'पौष',
    'Magha': 'माघ',
    'Phalguna': 'फाल्गुन',
  };

  static const Map<String, String> _hinduMonthIast = {
    'Chaitra': 'Caitra',
    'Vaishakha': 'Vaiśākha',
    'Jyeshtha': 'Jyeṣṭha',
    'Ashadha': 'Āṣāḍha',
    'Shravana': 'Śrāvaṇa',
    'Bhadrapada': 'Bhādrapada',
    'Ashwin': 'Āśvina',
    'Kartik': 'Kārttika',
    'Margashirsha': 'Mārgaśīrṣa',
    'Pausha': 'Pauṣa',
    'Magha': 'Māgha',
    'Phalguna': 'Phālguna',
  };

  static const Map<String, String> _tithiDeva = {
    'Pratipada': 'प्रतिपदा',
    'Dwitiya': 'द्वितीया',
    'Tritiya': 'तृतीया',
    'Chaturthi': 'चतुर्थी',
    'Panchami': 'पञ्चमी',
    'Shashthi': 'षष्ठी',
    'Saptami': 'सप्तमी',
    'Ashtami': 'अष्टमी',
    'Navami': 'नवमी',
    'Dashami': 'दशमी',
    'Ekadashi': 'एकादशी',
    'Dwadashi': 'द्वादशी',
    'Trayodashi': 'त्रयोदशी',
    'Chaturdashi': 'चतुर्दशी',
    'Purnima': 'पूर्णिमा',
    'Amavasya': 'अमावस्या',
  };

  static const Map<String, String> _pakshaDeva = {
    'Shukla Paksha': 'शुक्ल',
    'Krishna Paksha': 'कृष्ण',
  };

  static const Map<String, String> _varaDeva = {
    'Somavara': 'सोमवार',
    'Mangalavara': 'मङ्गलवार',
    'Budhavara': 'बुधवार',
    'Guruvara': 'गुरुवार',
    'Shukravara': 'शुक्रवार',
    'Shanivara': 'शनिवार',
    'Ravivara': 'रविवार',
  };

  static String monthDeva(String monthName) =>
      _hinduMonthDeva[monthName] ?? monthName;

  /// IAST transliteration of a Hindu lunar month name (e.g. `Vaiśākha`).
  static String monthIast(String monthName) =>
      _hinduMonthIast[monthName] ?? monthName;

  static String tithiDeva(String tithiName) =>
      _tithiDeva[tithiName] ?? tithiName;

  static String pakshaDeva(String paksha) => _pakshaDeva[paksha] ?? paksha;

  static String varaDeva(String varaName) => _varaDeva[varaName] ?? varaName;

  static const List<String> _shuklaTithiNames = [
    'Pratipada',
    'Dwitiya',
    'Tritiya',
    'Chaturthi',
    'Panchami',
    'Shashthi',
    'Saptami',
    'Ashtami',
    'Navami',
    'Dashami',
    'Ekadashi',
    'Dwadashi',
    'Trayodashi',
    'Chaturdashi',
    'Purnima',
  ];

  static const List<String> _krishnaTithiNames = [
    'Pratipada',
    'Dwitiya',
    'Tritiya',
    'Chaturthi',
    'Panchami',
    'Shashthi',
    'Saptami',
    'Ashtami',
    'Navami',
    'Dashami',
    'Ekadashi',
    'Dwadashi',
    'Trayodashi',
    'Chaturdashi',
    'Amavasya',
  ];

  static const List<String> _shuklaTithiSignificance = [
    'Beginning of the waxing moon. Auspicious for new beginnings.',
    'The second lunar day. Favourable for building relationships.',
    'Third day — Tritiya. Auspicious for ceremonies and travel.',
    'Chaturthi — day of Ganesha. Remove obstacles before proceeding.',
    'Panchami — the fifth. Auspicious for learning and the arts.',
    'Shashthi — day of Kartik. Favourable for warriors and leaders.',
    'Saptami — day of Surya. Auspicious for action and vitality.',
    'Ashtami — powerful mid-point. Day of Durga in both pakshas.',
    'Navami — nine, the number of completion. Favourable for tapas.',
    'Dashami — tenth day. Auspicious for dharmic action.',
    'Ekadashi — most sacred tithi. Fast from grain. Hari worship.',
    'Dwadashi — completion of Ekadashi fast. Offer to ancestors.',
    'Trayodashi — day of Kamadeva. Auspicious for love and family.',
    'Chaturdashi — vigil before the full moon. Shiva is honoured.',
    'Purnima — the full moon. Highest point of lunar energy.',
  ];

  static const List<String> _krishnaTithiSignificance = [
    'First day of the waning moon. Reflect on the month past.',
    'Dwitiya Krishna. Quiet and introspective day.',
    'Tritiya Krishna. Good for completion of pending work.',
    'Chaturthi Krishna — Sankashti. Ganesha frees one from difficulty.',
    'Panchami Krishna. Day for study and quiet contemplation.',
    'Shashthi Krishna. Auspicious for discipline and structure.',
    'Saptami Krishna. Moderate energy — avoid major decisions.',
    'Ashtami Krishna — powerful. Day of Kali and deep transformation.',
    'Navami Krishna. Introspective. Ancestor remembrance.',
    'Dashami Krishna. Complete outstanding obligations today.',
    'Ekadashi — most sacred tithi in both pakshas. Fast from grain.',
    'Dwadashi Krishna. End of Ekadashi fast. Dana and charity.',
    'Trayodashi Krishna — Pradosha. Evening Shiva worship.',
    'Chaturdashi Krishna — Shiva Chaturdashi. Deep Shiva practice.',
    'Amavasya — the new moon. Ancestor rites (Shraddha). Rest and reflect.',
  ];

  // ── Nakshatra data ────────────────────────────────────────────────────────

  static const List<String> _nakshatraNames = [
    'Ashwini',
    'Bharani',
    'Krittika',
    'Rohini',
    'Mrigashira',
    'Ardra',
    'Punarvasu',
    'Pushya',
    'Ashlesha',
    'Magha',
    'Purva Phalguni',
    'Uttara Phalguni',
    'Hasta',
    'Chitra',
    'Swati',
    'Vishakha',
    'Anuradha',
    'Jyeshtha',
    'Mula',
    'Purva Ashadha',
    'Uttara Ashadha',
    'Shravana',
    'Dhanishtha',
    'Shatabhisha',
    'Purva Bhadrapada',
    'Uttara Bhadrapada',
    'Revati',
  ];

  static const List<String> _nakshatraDeities = [
    'Ashwini Kumaras',
    'Yama',
    'Agni',
    'Brahma',
    'Chandra',
    'Rudra',
    'Aditi',
    'Brihaspati',
    'Naga',
    'Pitrs',
    'Bhaga',
    'Aryaman',
    'Savitar',
    'Vishwakarma',
    'Vayu',
    'Indra-Agni',
    'Mitra',
    'Indra',
    'Nirrti',
    'Apas',
    'Vishvedevas',
    'Vishnu',
    'Ashta Vasus',
    'Varuna',
    'Aja Ekapada',
    'Ahir Budhnya',
    'Pushan',
  ];

  static const List<String> _nakshatraSignificance = [
    'Healing and new beginnings.',
    'Transformation and karmic reckoning.',
    'Power and purification.',
    'Growth, fertility, and beauty. Highly auspicious.',
    'Searching, creativity, gentle energy.',
    'Intensity, storm, and deep renewal.',
    'Return, restoration, and maternal care.',
    'Nourishment and care. Most auspicious nakshatra.',
    'Wisdom and serpent intelligence.',
    'Ancestral power and royal dignity.',
    'Rest, pleasure, and creative expression.',
    'Partnership, generosity, and healing.',
    'Skill, craftsmanship, and dexterity.',
    'Artistry and brilliant illumination.',
    'Independence, flexibility, and trade.',
    'Purpose, dual focus, and achievement.',
    'Devotion, friendship, and loyalty.',
    'Courage, seniority, and power.',
    'Root energy, dissolution, and liberation.',
    'Invincibility and water-purification.',
    'Universal victory and righteousness.',
    'Listening, learning, and Vishnu\'s grace.',
    'Abundance, music, and martial energy.',
    'Healing mystery and Varuna\'s wisdom.',
    'Intensity and fierce austerity.',
    'Depth, compassion, and cosmic waters.',
    'Completion, protection, and safe arrival.',
  ];
}
