import 'package:sanatan_guide/domain/entities/scripture.dart';

/// A parsed scripture coordinate (e.g. "BG 2.47" → BG, ch 2, verse 47).
class ScriptureCoordinate {
  const ScriptureCoordinate({
    required this.scripture,
    required this.chapterNum,
    required this.verseNum,
    this.bookNum,
  });

  final Scripture scripture;
  final int chapterNum;
  final int verseNum;
  final int? bookNum;

  /// `'BG.2.47'` style verseId built from the scripture short code + chapter
  /// + verse, or 4-segment when [bookNum] is present.
  String get verseId {
    final head = _idHeadFor(scripture);
    if (bookNum != null) {
      return '$head.$bookNum.$chapterNum.$verseNum';
    }
    return '$head.$chapterNum.$verseNum';
  }
}

/// Aliases the user might type. Order matters — longer matches first so
/// "Gita" doesn't shadow shorter strings.
const Map<String, Scripture> _aliases = {
  'bhagavad gita': Scripture.bhagavadGita,
  'bhagavad gītā': Scripture.bhagavadGita,
  'bhagavad-gita': Scripture.bhagavadGita,
  'bhagavadgita': Scripture.bhagavadGita,
  'gita': Scripture.bhagavadGita,
  'gītā': Scripture.bhagavadGita,
  'bg': Scripture.bhagavadGita,
  'rigveda': Scripture.rigveda,
  'ṛgveda': Scripture.rigveda,
  'rg veda': Scripture.rigveda,
  'rv': Scripture.rigveda,
  'samaveda': Scripture.samaveda,
  'sāmaveda': Scripture.samaveda,
  'sv': Scripture.samaveda,
  'yajurveda': Scripture.yajurveda,
  'yv': Scripture.yajurveda,
  'atharvaveda': Scripture.atharvaveda,
  'av': Scripture.atharvaveda,
  'isha': Scripture.ishaUpanishad,
  'īśa': Scripture.ishaUpanishad,
  'isavasya': Scripture.ishaUpanishad,
  'kena': Scripture.kenaUpanishad,
  'katha': Scripture.kathaUpanishad,
  'kaṭha': Scripture.kathaUpanishad,
  'prashna': Scripture.prasnaUpanishad,
  'praśna': Scripture.prasnaUpanishad,
  'mundaka': Scripture.mundakaUpanishad,
  'muṇḍaka': Scripture.mundakaUpanishad,
  'mandukya': Scripture.mandukyaUpanishad,
  'māṇḍūkya': Scripture.mandukyaUpanishad,
  'taittiriya': Scripture.taittiriyaUpanishad,
  'aitareya': Scripture.aitareyaUpanishad,
  'chandogya': Scripture.chandogyaUpanishad,
  'chāndogya': Scripture.chandogyaUpanishad,
  'brihadaranyaka': Scripture.brihadaranyakaUpanishad,
  'bṛhadāraṇyaka': Scripture.brihadaranyakaUpanishad,
  'shvetashvatara': Scripture.shvetashvataraUpanishad,
  'śvetāśvatara': Scripture.shvetashvataraUpanishad,
  'kaushitaki': Scripture.kaushitakiUpanishad,
  'kauṣītaki': Scripture.kaushitakiUpanishad,
  'maitrayani': Scripture.maitrayaniUpanishad,
  'maitrāyaṇī': Scripture.maitrayaniUpanishad,
  'yoga sutras': Scripture.yogaSutras,
  'yoga sūtras': Scripture.yogaSutras,
  'patanjali': Scripture.yogaSutras,
  'ys': Scripture.yogaSutras,
  'brahma sutras': Scripture.brahmasutras,
  'brahma sūtras': Scripture.brahmasutras,
  'bs': Scripture.brahmasutras,
  'hatha yoga pradipika': Scripture.hathaYogaPradipika,
  'haṭha yoga pradīpikā': Scripture.hathaYogaPradipika,
  'hyp': Scripture.hathaYogaPradipika,
  'ramayana': Scripture.ramayana,
  'rāmāyaṇa': Scripture.ramayana,
  'ram': Scripture.ramayana,
  'mahabharata': Scripture.mahabharata,
  'mahābhārata': Scripture.mahabharata,
  'mbh': Scripture.mahabharata,
  'vishnu purana': Scripture.vishnuPurana,
  'viṣṇu purāṇa': Scripture.vishnuPurana,
  'vp': Scripture.vishnuPurana,
  'devi bhagavata': Scripture.deviBhagavataPurana,
  'devī bhāgavata': Scripture.deviBhagavataPurana,
  'dbp': Scripture.deviBhagavataPurana,
  'bhagavata purana': Scripture.bhagavataPurana,
  'bhāgavata purāṇa': Scripture.bhagavataPurana,
  'bhagavatam': Scripture.bhagavataPurana,
  'bhāgavatam': Scripture.bhagavataPurana,
  'bhp': Scripture.bhagavataPurana,
  'markandeya': Scripture.markandeya,
  'mārkaṇḍeya': Scripture.markandeya,
  'mkp': Scripture.markandeya,
  'vishnu sahasranama': Scripture.vishnuSahasranama,
  'viṣṇu sahasranāma': Scripture.vishnuSahasranama,
  'vsn': Scripture.vishnuSahasranama,
  'arthashastra': Scripture.arthashastra,
  'arthaśāstra': Scripture.arthashastra,
  'kautilya': Scripture.arthashastra,
  'tirukkural': Scripture.tirukkural,
  'tirukkuṟaḷ': Scripture.tirukkural,
  'tk': Scripture.tirukkural,
  'manusmriti': Scripture.manusmriti,
  'manusmṛti': Scripture.manusmriti,
  'manu': Scripture.manusmriti,
  'mahanirvana': Scripture.mahanirvana,
  'mahānirvāṇa': Scripture.mahanirvana,
  'mnt': Scripture.mahanirvana,
};

/// Converts a Scripture to its verse-id head segment (e.g. BG, RV, Mbh).
String _idHeadFor(Scripture s) => switch (s) {
      Scripture.bhagavadGita => 'BG',
      Scripture.rigveda => 'RV',
      Scripture.samaveda => 'SV',
      Scripture.yajurveda => 'YV',
      Scripture.atharvaveda => 'AV',
      Scripture.ishaUpanishad => 'ISHA',
      Scripture.kenaUpanishad => 'KE',
      Scripture.kathaUpanishad => 'KATH',
      Scripture.prasnaUpanishad => 'PU',
      Scripture.mundakaUpanishad => 'MUNK',
      Scripture.mandukyaUpanishad => 'MU',
      Scripture.taittiriyaUpanishad => 'TU',
      Scripture.aitareyaUpanishad => 'AU',
      Scripture.chandogyaUpanishad => 'CU',
      Scripture.brihadaranyakaUpanishad => 'BAU',
      Scripture.shvetashvataraUpanishad => 'SU',
      Scripture.kaushitakiUpanishad => 'KU',
      Scripture.maitrayaniUpanishad => 'MAI',
      Scripture.yogaSutras => 'YS',
      Scripture.brahmasutras => 'BS',
      Scripture.hathaYogaPradipika => 'HYP',
      Scripture.ramayana => 'RAM',
      Scripture.mahabharata => 'MBH',
      Scripture.vishnuPurana => 'VP',
      Scripture.deviBhagavataPurana => 'DB',
      Scripture.bhagavataPurana => 'BP',
      Scripture.markandeya => 'MP',
      Scripture.vishnuSahasranama => 'VS',
      Scripture.arthashastra => 'KAS',
      Scripture.tirukkural => 'TK',
      Scripture.manusmriti => 'MS',
      Scripture.mahanirvana => 'MNT',
    };

/// Whether [s] uses 3 numeric coordinates (book.chapter.verse).
bool _isThreeLevel(Scripture s) => switch (s) {
      Scripture.rigveda ||
      Scripture.atharvaveda ||
      Scripture.mahabharata ||
      Scripture.ramayana ||
      Scripture.bhagavataPurana ||
      Scripture.deviBhagavataPurana ||
      Scripture.markandeya ||
      Scripture.vishnuPurana ||
      Scripture.arthashastra ||
      Scripture.chandogyaUpanishad ||
      Scripture.brihadaranyakaUpanishad =>
        true,
      _ => false,
    };

/// Parses a query string like "BG 2.47", "Gita 11.37", "Katha 1.18",
/// "BG.2.47", "RV 1:1:1" into a [ScriptureCoordinate], or null if the input
/// doesn't match a recognized coordinate pattern.
///
/// Recognizes:
/// - 2-level: `{alias}{sep}{ch}{sep}{verse}` (e.g. "BG 2.47", "Katha 1.18")
/// - 3-level: `{alias}{sep}{book}{sep}{ch}{sep}{verse}` (e.g. "RV 1.1.1")
/// - Devanāgarī numerals (२.४७) map back to 1-9 digits.
///
/// Whether a scripture is 2- or 3-level is decided by [_isThreeLevel].
/// Katha, Mundaka, Mandukya, Taittiriya, Aitareya, etc. ship as 2-level
/// in `assets/db/sanatan_guide.db` (chapter encodes Vallī/Section).
ScriptureCoordinate? parseScriptureCoordinate(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  final ascii = _devanagariToAscii(trimmed);

  // Strip leading/trailing whitespace, normalize separators to '.'.
  final normalized =
      ascii.toLowerCase().replaceAll(RegExp(r'[\s ]+'), ' ').trim();

  // Match alias prefix (longest first).
  final aliasKeys = _aliases.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));

  for (final alias in aliasKeys) {
    if (!normalized.startsWith('$alias ') &&
        !normalized.startsWith('$alias.')) {
      continue;
    }
    final scripture = _aliases[alias]!;
    final tail = normalized.substring(alias.length).trim();
    final parts =
        tail.split(RegExp(r'[\s.\:\-]+')).where((p) => p.isNotEmpty).toList();
    final nums = <int>[];
    for (final p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 1 || n > 9999) return null;
      nums.add(n);
    }
    if (_isThreeLevel(scripture) && nums.length == 3) {
      return ScriptureCoordinate(
        scripture: scripture,
        bookNum: nums[0],
        chapterNum: nums[1],
        verseNum: nums[2],
      );
    }
    if (!_isThreeLevel(scripture) && nums.length == 2) {
      return ScriptureCoordinate(
        scripture: scripture,
        chapterNum: nums[0],
        verseNum: nums[1],
      );
    }
    // 3-level scripture given 2 numbers: assume chapter+verse, no book.
    if (_isThreeLevel(scripture) && nums.length == 2) {
      return ScriptureCoordinate(
        scripture: scripture,
        chapterNum: nums[0],
        verseNum: nums[1],
      );
    }
    return null;
  }
  return null;
}

const _devNumerals = {
  '०': '0',
  '१': '1',
  '२': '2',
  '३': '3',
  '४': '4',
  '५': '5',
  '६': '6',
  '७': '7',
  '८': '8',
  '९': '9',
};

String _devanagariToAscii(String s) {
  final buf = StringBuffer();
  for (final r in s.runes) {
    final ch = String.fromCharCode(r);
    buf.write(_devNumerals[ch] ?? ch);
  }
  return buf.toString();
}
