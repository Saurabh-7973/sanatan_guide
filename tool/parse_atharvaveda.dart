// tool/parse_atharvaveda.dart
// Sanskrit: DharmicData Atharvaveda Shaunak (GRETIL)
// English: run after this: python3 tool/parse_atharvaveda_txt.py /tmp/av.txt
// Verify: dart run tool/verify_atharvaveda_db.dart
// Run: dart run tool/parse_atharvaveda.dart

import 'dart:convert';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

const _dharmicDir = '/tmp/DharmicData/AtharvaVeda';
const _dbPath = 'assets/db/sanatan_guide.db';

void main() {
  if (!Directory(_dharmicDir).existsSync()) {
    print('❌ Not found: $_dharmicDir');
    exit(1);
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🕉  Atharvaveda Parser');
  print('   Sanskrit : DharmicData (GRETIL) Shaunak');
  print('   English  : run parse_atharvaveda_txt.py after (Griffith)');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final db = sqlite3.open(_dbPath);
  try {
    db.execute('BEGIN');
    db.execute("DELETE FROM verses WHERE scripture = 'atharvaveda'");

    int inserted = 0;
    int kaandasDone = 0;

    for (int k = 1; k <= 20; k++) {
      final file = File('$_dharmicDir/atharvaveda_kaanda_$k.json');
      if (!file.existsSync()) {
        print('   ⚠️  Missing kaanda $k');
        continue;
      }

      final suktas =
          (jsonDecode(file.readAsStringSync()) as List<dynamic>);

      for (final s in suktas) {
        final kaanda = s['kaanda'] as int;
        final sukta = s['sukta'] as int;
        final text = s['text'] as String;
        final verses = _splitVerses(text);

        for (final v in verses.entries) {
          db.execute('''
            INSERT OR REPLACE INTO verses (
              id, scripture, chapter_num, verse_num,
              sanskrit, english, chapter_label, translation,
              is_bookmarked, read_count, created_at
            ) VALUES (?, 'atharvaveda', ?, ?, ?, ?, ?, 'griffith_pending', 0, 0, ?)
          ''', [
            'AV.$kaanda.$sukta.${v.key}',
            kaanda,
            v.key,
            v.value,
            null,
            'Kaanda $kaanda — Sukta $sukta',
            DateTime.now().millisecondsSinceEpoch,
          ]);
          inserted++;
        }
      }

      kaandasDone++;
      print('   ✓ Kaanda $k done');
    }

    db.execute('COMMIT');
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Atharvaveda: $inserted verses inserted');
    print('   Kaandas: $kaandasDone / 20');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
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
