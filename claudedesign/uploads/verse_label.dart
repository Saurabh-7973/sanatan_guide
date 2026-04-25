import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';

/// `/browse/:scriptureId/chapter/:chapterNum` with optional `?book=` for multi-book texts.
String browseChapterPath({
  required String scriptureCode,
  required int chapterNum,
  int? bookNum,
}) {
  final base = '/browse/$scriptureCode/chapter/$chapterNum';
  if (bookNum != null) {
    return '$base?book=$bookNum';
  }
  return base;
}

/// Same as [browseChapterPath] using fields from [verse].
String browseChapterPathForVerse(Verse verse) => browseChapterPath(
      scriptureCode: verse.scripture.code,
      chapterNum: verse.chapterNum,
      bookNum: verse.bookNum,
    );

/// `/browse/:scriptureId/verse/:verseId`
String browseVersePath({
  required String scriptureCode,
  required String verseId,
}) =>
    '/browse/$scriptureCode/verse/$verseId';

/// Short numeric fragment from composite [verse.id] for compact list labels.
String compactVerseLocationLabel(Verse verse) {
  final parts = verse.id.split('.');
  if (parts.length >= 4) return '${parts[1]}.${parts[2]}.${parts[3]}';
  if (parts.length == 3) return '${parts[1]}.${parts[2]}';
  if (parts.length == 2) return parts[1];
  return '${verse.verseNum}';
}

/// Maps the first segment of [verseId] (e.g. `BG.1.1` → `bg`) to GoRouter
/// `/browse/:scriptureId` codes.
String scriptureCodeFromVerseId(String verseId) {
  final head = verseId.split('.').first.toLowerCase();
  return switch (head) {
    'bg' => 'bhagavad_gita',
    'rv' => 'rigveda',
    'sv' => 'samaveda',
    'yv' => 'yajurveda',
    'av' => 'atharvaveda',
    'cu' => 'chandogya_upanishad',
    'bau' => 'brihadaranyaka_upanishad',
    'mbh' => 'mahabharata',
    'ram' => 'ramayana',
    'bp' => 'bhagavata_purana',
    'kas' => 'arthashastra',
    'tk' => 'tirukkural',
    'vp' => 'vishnu_purana',
    'db' => 'devi_bhagavata_purana',
    'mp' => 'markandeya_purana',
    'vs' => 'vishnu_sahasranama',
    'mnt' => 'mahanirvana_tantra',
    'mai' => 'maitrayani_upanishad',
    'mu' => 'mandukya_upanishad',
    'isha' => 'isha_upanishad',
    'ke' => 'kena_upanishad',
    'munk' => 'mundaka_upanishad',
    'kath' => 'katha_upanishad',
    'pu' => 'prashna_upanishad',
    'tu' => 'taittiriya_upanishad',
    'au' => 'aitareya_upanishad',
    'su' => 'shvetashvatara_upanishad',
    'ku' => 'kaushitaki_upanishad',
    'bs' => 'brahma_sutras',
    'ys' => 'yoga_sutras',
    'hyp' => 'hatha_yoga_pradipika',
    'ms' => 'manusmriti',
    _ => 'bhagavad_gita',
  };
}

/// Human-readable location label derived from [Verse.id] (e.g. `RV.1.1.1`).
String getVerseLabel(Verse verse) {
  final parts = verse.id.split('.');
  if (parts.isEmpty) {
    return 'Verse ${verse.verseNum}';
  }
  final head = parts[0];
  if (head == 'RV' && parts.length >= 4) {
    return 'Mandala ${parts[1]} · Hymn ${parts[2]} · Verse ${parts[3]}';
  }
  if (head == 'AV' && parts.length >= 4) {
    return 'Kaanda ${parts[1]} · Sukta ${parts[2]} · Verse ${parts[3]}';
  }
  if (head == 'CU' && parts.length >= 4) {
    return 'Prapathaka ${parts[1]} · Khanda ${parts[2]} · Verse ${parts[3]}';
  }
  if (head == 'BAU' && parts.length >= 4) {
    return 'Adhyaya ${parts[1]} · Brahmana ${parts[2]} · Verse ${parts[3]}';
  }
  if (head == 'MBH' && parts.length >= 4) {
    return 'Parva ${parts[1]} · Chapter ${parts[2]} · Verse ${parts[3]}';
  }
  if (head == 'RAM' && parts.length >= 4) {
    return 'Kanda ${parts[1]} · Sarga ${parts[2]} · Verse ${parts[3]}';
  }
  if (head == 'BP' && parts.length >= 4) {
    return 'Skanda ${parts[1]} · Chapter ${parts[2]} · Verse ${parts[3]}';
  }
  if (head == 'KAS' && parts.length >= 4) {
    return 'Book ${parts[1]} · Chapter ${parts[2]} · Verse ${parts[3]}';
  }
  if (head == 'TK' && parts.length >= 2) {
    return 'Kural ${parts[1]}';
  }
  if (head == 'YV' && parts.length >= 3) {
    return 'Adhyaya ${parts[1]} · Verse ${parts[2]}';
  }
  if (head == 'SV' && parts.length >= 2) {
    return 'Verse ${parts[1]}';
  }
  if (head == 'BG' && parts.length >= 3) {
    return 'Chapter ${parts[1]} · Verse ${parts[2]}';
  }
  return 'Verse ${verse.verseNum}';
}
