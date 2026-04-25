// Verifies Valmiki Ramayana rows in assets/db/sanatan_guide.db (GRETIL Sanskrit).
//
// IDs: RAM.{kanda}.{sarga}.{verse} — book_num = kanda 1–7.
//
// Usage: dart run tool/verify_ramayana_db.dart
// Exit 1 if DB missing, zero rows, or any kanda 1–7 has no verses.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

const _kandas = 7;

void main() {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) {
    stderr.writeln('❌ DB not found: $dbPath');
    exit(1);
  }

  final db = sqlite3.open(dbPath);
  try {
    final total = db.select(
      "SELECT COUNT(*) AS c FROM verses WHERE scripture = 'ramayana'",
    ).first['c'] as int;
    stdout.writeln('Ramayana verses in DB: $total');
    if (total == 0) {
      stderr.writeln(
        '❌ No rows. Run: python3 tool/parse_ramayana.py (network; GRETIL TEI)',
      );
      exit(1);
    }

    final gaps = <String>[];
    for (var k = 1; k <= _kandas; k++) {
      final n = db.select(
        "SELECT COUNT(*) AS c FROM verses WHERE scripture = 'ramayana' AND book_num = ?",
        [k],
      ).first['c'] as int;
      stdout.writeln('  Kanda $k: $n verses');
      if (n == 0) {
        gaps.add('Kanda $k has no verses');
      }
    }

    final missingEn = db.select('''
      SELECT COUNT(*) AS c FROM verses
      WHERE scripture = 'ramayana'
        AND (english IS NOT NULL AND TRIM(english) != '')
    ''').first['c'] as int;
    if (missingEn == 0) {
      stderr.writeln(
        '\n⚠️  No English column data (Sanskrit-only GRETIL seed; Griffith translation pass TBD).',
      );
    }

    final sanskritGaps = db.select('''
      SELECT COUNT(*) AS c FROM verses
      WHERE scripture = 'ramayana'
        AND (sanskrit IS NULL OR TRIM(sanskrit) = '')
    ''').first['c'] as int;
    if (sanskritGaps > 0) {
      stderr.writeln('⚠️  $sanskritGaps row(s) lack Sanskrit text.');
    }

    if (gaps.isNotEmpty) {
      stderr.writeln('\n❌ Ramayana verification failed:');
      for (final g in gaps) {
        stderr.writeln('   • $g');
      }
      exit(1);
    }

    stdout.writeln('\n✅ All $_kandas kandas have verses.');
  } finally {
    db.dispose();
  }
}
