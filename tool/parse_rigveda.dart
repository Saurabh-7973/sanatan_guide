// ============================================================
// Rigveda Parser — combines two authoritative sources:
//
// SANSKRIT: DharmicData (github.com/bhavykhatri/DharmicData)
//   Source: GRETIL Van Nooten & Holland critical edition
//   Licence: ODbL (Open Database Licence)
//
// ENGLISH: Griffith 1896 (sanskritweb.net/rigveda/griffith.pdf)
//   Proofread edition by Ricardo Fakiera, 2013
//   Translation: Public Domain (Griffith died 1906)
//
// USAGE:
//   1. Clone DharmicData: git clone https://github.com/bhavykhatri/DharmicData.git /tmp/DharmicData
//   2. Download PDF: curl -L http://www.sanskritweb.net/rigveda/griffith.pdf -o /tmp/griffith_rigveda.pdf
//   3. Extract text: pdftotext /tmp/griffith_rigveda.pdf /tmp/griffith_rigveda.txt
//   4. Run: dart run tool/parse_rigveda.dart
//   5. Verify bundled DB: dart run tool/verify_rigveda_db.dart
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

const String _griffithTxt = '/tmp/griffith_rigveda.txt';
const String _dharmicDir = '/tmp/DharmicData/Rigveda';
const String _dbPath = 'assets/db/sanatan_guide.db';

void main() {
  // Validate inputs
  for (final f in [_griffithTxt, _dbPath]) {
    if (!File(f).existsSync()) {
      print('❌ Not found: $f');
      exit(1);
    }
  }
  if (!Directory(_dharmicDir).existsSync()) {
    print('❌ Not found: $_dharmicDir');
    print(
        '   Run: git clone https://github.com/bhavykhatri/DharmicData.git /tmp/DharmicData');
    exit(1);
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🕉  Rigveda Parser');
  print('   Sanskrit : DharmicData (GRETIL)');
  print('   English  : Griffith 1896 (proofread PDF)');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  // Step 1: Parse Griffith English
  print('\n📖 Parsing Griffith text...');
  final griffith = _parseGriffith(File(_griffithTxt).readAsStringSync());
  print('   ✓ Parsed ${griffith.length} hymns from Griffith');

  // Step 2: Parse DharmicData Sanskrit
  print('\n📖 Parsing DharmicData Sanskrit...');
  final sanskrit = _parseSanskrit();
  print('   ✓ Parsed ${sanskrit.length} hymns from DharmicData');

  // Step 3: Merge and seed
  print('\n💾 Merging and seeding DB...');
  _seedDB(griffith, sanskrit);
}

// ─── Griffith Parser ──────────────────────────────────────────

// Returns Map<'B.H' -> Map<verseNum -> text>>
// e.g. {'1.1' -> {1: 'I Laud Agni...', 2: 'Worthy is Agni...'}}
Map<String, Map<int, String>> _parseGriffith(String raw) {
  final result = <String, Map<int, String>>{};

  // Split into hymn blocks by [BB-HHH] markers
  final hymnPattern = RegExp(r'\[(\d{2})-(\d{3})\]\s*HYMN[^\n]*\n');
  final matches = hymnPattern.allMatches(raw).toList();

  for (int i = 0; i < matches.length; i++) {
    final m = matches[i];
    final book = int.parse(m.group(1)!);
    final hymn = int.parse(m.group(2)!);
    final key = '$book.$hymn';

    // Extract text between this hymn marker and next
    final start = m.end;
    final end = i + 1 < matches.length ? matches[i + 1].start : raw.length;
    final block = raw.substring(start, end).trim();

    result[key] = _parseVerses(block);
  }

  return result;
}

// Parse individual verses from a hymn block
// Verse format: digit(s) + space + text (may span multiple lines)
Map<int, String> _parseVerses(String block) {
  final verses = <int, String>{};
  final lines = block.split('\n');

  int? currentVerse;
  final buffer = StringBuffer();

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;

    // Check if line starts a new verse: "1 I Laud..." or "10 Whatever..."
    final verseStart = RegExp(r'^(\d{1,2})\s+(.+)');
    final match = verseStart.firstMatch(trimmed);

    if (match != null) {
      // Save previous verse
      if (currentVerse != null && buffer.isNotEmpty) {
        verses[currentVerse] = buffer.toString().trim();
        buffer.clear();
      }
      currentVerse = int.parse(match.group(1)!);
      buffer.write(match.group(2));
    } else if (currentVerse != null) {
      // Continuation of current verse
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(trimmed);
    }
  }

  // Save last verse
  if (currentVerse != null && buffer.isNotEmpty) {
    verses[currentVerse] = buffer.toString().trim();
  }

  return verses;
}

// ─── DharmicData Sanskrit Parser ──────────────────────────────

// Returns Map<'B.H' -> Map<verseNum -> devanagari>>
Map<String, Map<int, String>> _parseSanskrit() {
  final result = <String, Map<int, String>>{};

  for (int mandala = 1; mandala <= 10; mandala++) {
    final file = File('$_dharmicDir/rigveda_mandala_$mandala.json');
    if (!file.existsSync()) {
      print('   ⚠️  Missing: ${file.path}');
      continue;
    }

    final hymns = (jsonDecode(file.readAsStringSync()) as List<dynamic>);

    for (final hymn in hymns) {
      final sukta = hymn['sukta'] as int;
      final text = hymn['text'] as String;
      final key = '$mandala.$sukta';
      result[key] = _splitSanskritVerses(text);
    }
  }

  return result;
}

// Split Sanskrit text by ॥N॥ verse markers
Map<int, String> _splitSanskritVerses(String text) {
  final verses = <int, String>{};

  // Remove the header line (first line has metadata like "९ मधुच्छन्दा...")
  final lines = text.split('\n');
  final contentLines = lines.skip(1).join('\n');

  // Also try splitting by single daṇḍa with number: ॥१॥
  // The DharmicData uses Devanagari numerals
  final devaVersePattern = RegExp(r'॥[\d१२३४५६७८९०]+॥');
  final markerMatches = devaVersePattern.allMatches(contentLines).toList();

  if (markerMatches.isEmpty) {
    // Fallback: return whole text as verse 1
    final clean = text.replaceAll(RegExp(r'\n+'), ' ').trim();
    if (clean.isNotEmpty) verses[1] = clean;
    return verses;
  }

  // Extract text between markers
  int lastEnd = 0;
  int verseNum = 1;

  for (final marker in markerMatches) {
    final verseText = contentLines
        .substring(lastEnd, marker.start)
        .replaceAll(RegExp(r'\n+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (verseText.isNotEmpty) {
      verses[verseNum] = verseText;
      verseNum++;
    }
    lastEnd = marker.end;
  }

  return verses;
}

// ─── DB Seeder ────────────────────────────────────────────────

void _seedDB(
  Map<String, Map<int, String>> griffith,
  Map<String, Map<int, String>> sanskrit,
) {
  final db = sqlite3.open(_dbPath);

  try {
    db.execute('BEGIN');
    db.execute("DELETE FROM verses WHERE scripture = 'rigveda'");

    int inserted = 0;
    int skipped = 0;

    // Known hymn counts per mandala
    const hymnCounts = {
      1: 191,
      2: 43,
      3: 62,
      4: 58,
      5: 87,
      6: 75,
      7: 104,
      8: 103,
      9: 114,
      10: 191,
    };

    for (final entry in hymnCounts.entries) {
      final mandala = entry.key;
      final hymnCount = entry.value;

      for (int hymn = 1; hymn <= hymnCount; hymn++) {
        final key = '$mandala.$hymn';
        final engVerses = griffith[key] ?? {};
        final sanVerses = sanskrit[key] ?? {};

        final label = 'Mandala $mandala — Hymn $hymn';

        // Verse indices: union of Griffith + DharmicData so we do not drop
        // Sanskrit-only hymns when the PDF line-wrap breaks English parsing.
        final verseNums = {...engVerses.keys, ...sanVerses.keys}.toList()
          ..sort();

        if (verseNums.isEmpty) {
          skipped++;
          print('   ⚠️  No verses for hymn $key (skip)');
          continue;
        }

        for (final verseNum in verseNums) {
          final english = engVerses[verseNum];
          final sanText = sanVerses[verseNum] ?? '';

          if ((english == null || english.isEmpty) && sanText.isEmpty) {
            continue;
          }

          final trimmedEn = english?.trim();
          final englishVal =
              trimmedEn == null || trimmedEn.isEmpty ? null : trimmedEn;

          db.execute('''
            INSERT OR REPLACE INTO verses (
              id, scripture, chapter_num, verse_num,
              sanskrit, english, chapter_label, translation,
              is_bookmarked, read_count, created_at
            ) VALUES (?, 'rigveda', ?, ?, ?, ?, ?, 'griffith', 0, 0, ?)
          ''', [
            'RV.$mandala.$hymn.$verseNum',
            mandala,
            verseNum,
            sanText,
            englishVal,
            label,
            DateTime.now().millisecondsSinceEpoch,
          ]);
          inserted++;
        }
      }

      print('  ✓ Mandala $mandala: done');
    }

    db.execute('COMMIT');

    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Rigveda seeding complete');
    print('   Verses inserted : $inserted');
    print('   Hymns skipped   : $skipped');
    print('   Output          : $_dbPath');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } catch (e) {
    db.execute('ROLLBACK');
    print('❌ DB error: $e');
    rethrow;
  } finally {
    db.dispose();
  }
}
