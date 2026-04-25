// tool/parse_yajurveda.dart
// Sanskrit: DharmicData Vajasaneyi Madhyadina Samhita (GRETIL)
// English: Pending (Griffith 1899 — add when browser access available)
// Run: dart run tool/parse_yajurveda.dart

import 'dart:convert';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

const _dharmicFile =
    '/tmp/DharmicData/Yajurveda/vajasneyi_madhyadina_samhita.json';
const _dbPath = 'assets/db/sanatan_guide.db';

void main() {
  if (!File(_dharmicFile).existsSync()) {
    print('❌ Not found: $_dharmicFile');
    exit(1);
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🕉  Yajurveda Parser');
  print('   Sanskrit : DharmicData (GRETIL) Madhyadina');
  print('   English  : Pending');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final chapters =
      (jsonDecode(File(_dharmicFile).readAsStringSync()) as List<dynamic>);
  print('   Chapters loaded: ${chapters.length}');

  final db = sqlite3.open(_dbPath);
  try {
    db.execute('BEGIN');
    db.execute("DELETE FROM verses WHERE scripture = 'yajurveda'");

    int inserted = 0;

    for (final ch in chapters) {
      final chapterNum = ch['adhyaya'] as int;
      final text = ch['text'] as String;
      final verses = _splitVerses(text);

      for (final v in verses.entries) {
        db.execute('''
          INSERT OR REPLACE INTO verses (
            id, scripture, chapter_num, verse_num,
            sanskrit, english, chapter_label, translation,
            is_bookmarked, read_count, created_at
          ) VALUES (?, 'yajurveda', ?, ?, ?, '', ?, 'griffith_pending', 0, 0, ?)
        ''', [
          'YV.$chapterNum.${v.key}',
          chapterNum,
          v.key,
          v.value,
          'Adhyaya $chapterNum',
          DateTime.now().millisecondsSinceEpoch,
        ]);
        inserted++;
      }
    }

    db.execute('COMMIT');
    print('✅ Yajurveda: $inserted verses inserted');
  } catch (e) {
    db.execute('ROLLBACK');
    print('❌ $e');
    rethrow;
  } finally {
    db.dispose();
  }
}

Map<int, String> _splitVerses(String text) {
  final verses = <int, String>{};
  final lines = text.split('\n');
  // skip header line
  final content = lines.skip(1).join('\n');

  final pattern = RegExp(r'।।\s*[\d१२३४५६७८९०]+\s*।।');
  final markers = pattern.allMatches(content).toList();

  if (markers.isEmpty) {
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.isNotEmpty) verses[1] = clean;
    return verses;
  }

  int lastEnd = 0;
  int verseNum = 1;
  for (final m in markers) {
    final v = content
        .substring(lastEnd, m.start)
        .replaceAll(RegExp(r'\n+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (v.isNotEmpty) verses[verseNum++] = v;
    lastEnd = m.end;
  }
  return verses;
}
