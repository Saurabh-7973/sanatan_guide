// Verifies Tirukkural rows in assets/db/sanatan_guide.db (Project Madurai Tamil in `sanskrit`).
//
// Canonical work: 1,330 kurals in 133 adhikarams (chapters) of 10 verses each.
// IDs: TK.1 … TK.1330 (global kural index).
//
// Usage: dart run tool/verify_tirukkural_db.dart
// Exit 1 if DB missing or zero rows. Warns on missing kurals or English gaps.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

const _expectedKurals = 1330;
const _expectedAdhikarams = 133;

void main() {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) {
    stderr.writeln('❌ DB not found: $dbPath');
    exit(1);
  }

  final db = sqlite3.open(dbPath);
  try {
    final total = db.select(
      "SELECT COUNT(*) AS c FROM verses WHERE scripture = 'tirukkural'",
    ).first['c'] as int;
    stdout.writeln('Tirukkural verses in DB: $total / $_expectedKurals expected');
    if (total == 0) {
      stderr.writeln(
        '❌ No rows. Run: python3 tool/parse_tirukkural.py (needs network to Project Madurai)',
      );
      exit(1);
    }

    final rows = db.select(
      "SELECT id FROM verses WHERE scripture = 'tirukkural'",
    );
    final have = <int>{};
    for (final r in rows) {
      final id = r['id'] as String;
      if (!id.startsWith('TK.')) continue;
      final n = int.tryParse(id.substring(3));
      if (n != null) {
        have.add(n);
      }
    }

    final missing = <int>[];
    for (var k = 1; k <= _expectedKurals; k++) {
      if (!have.contains(k)) {
        missing.add(k);
      }
    }
    if (missing.isNotEmpty) {
      stderr.writeln(
        '\n⚠️  ${missing.length} kural(s) missing vs canonical 1–$_expectedKurals:',
      );
      const maxShow = 40;
      for (var i = 0; i < missing.length && i < maxShow; i++) {
        stderr.writeln('   • TK.${missing[i]}');
      }
      if (missing.length > maxShow) {
        stderr.writeln('   … (${missing.length - maxShow} more)');
      }
    }

    final perChapter = <int, int>{};
    for (var c = 1; c <= _expectedAdhikarams; c++) {
      perChapter[c] = 0;
    }
    final chRows = db.select('''
      SELECT chapter_num, COUNT(*) AS c FROM verses
      WHERE scripture = 'tirukkural' GROUP BY chapter_num
    ''');
    for (final r in chRows) {
      perChapter[r['chapter_num'] as int] = r['c'] as int;
    }
    final badChapters = <String>[];
    for (var c = 1; c <= _expectedAdhikarams; c++) {
      final n = perChapter[c] ?? 0;
      if (n != 10) {
        badChapters.add('Adhikaram $c: $n verses (expected 10)');
      }
    }
    if (badChapters.isNotEmpty) {
      stderr.writeln('\n⚠️  Adhikaram verse count(s) off canonical 10:');
      for (final b in badChapters) {
        stderr.writeln('   • $b');
      }
    }

    final missingEn = db.select('''
      SELECT COUNT(*) AS c FROM verses
      WHERE scripture = 'tirukkural'
        AND (english IS NOT NULL AND TRIM(english) != '')
    ''').first['c'] as int;
    if (missingEn == 0) {
      stderr.writeln(
        '\n⚠️  No English column data (Tamil-only seed from `parse_tirukkural.py`; add PD translation pass when available).',
      );
    }

    final minRow = db.select('''
      SELECT id FROM verses WHERE scripture = 'tirukkural'
      ORDER BY chapter_num ASC, verse_num ASC LIMIT 1
    ''').first;
    final maxRow = db.select('''
      SELECT id FROM verses WHERE scripture = 'tirukkural'
      ORDER BY chapter_num DESC, verse_num DESC LIMIT 1
    ''').first;
    stdout.writeln('\n   First row: ${minRow['id']}  |  Last row: ${maxRow['id']}');

    if (missing.isEmpty && badChapters.isEmpty) {
      stdout.writeln('\n✅ All $_expectedKurals kurals present; 133 adhikarams × 10.');
    }
  } finally {
    db.dispose();
  }
}
