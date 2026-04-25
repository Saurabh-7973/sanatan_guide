// Verifies Bhagavata Purana rows in assets/db/sanatan_guide.db (GRETIL Sanskrit).
//
// IDs: BP.{skanda}.{chapter}.{verse} — book_num = skanda 1–12.
//
// Usage: dart run tool/verify_bhagavata_purana_db.dart
// Exit 1 if DB missing or zero rows. Warn if any skanda 1–12 is empty.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

const _skandas = 12;

void main() {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) {
    stderr.writeln('❌ DB not found: $dbPath');
    exit(1);
  }

  final db = sqlite3.open(dbPath);
  try {
    final total = db.select(
      "SELECT COUNT(*) AS c FROM verses WHERE scripture = 'bhagavata_purana'",
    ).first['c'] as int;
    stdout.writeln('Bhagavata Purana verses in DB: $total');
    if (total == 0) {
      stderr.writeln(
        '❌ No rows. Run: python3 tool/parse_bhagavata_purana.py (network; GRETIL)',
      );
      exit(1);
    }

    final gaps = <String>[];
    for (var s = 1; s <= _skandas; s++) {
      final n = db.select(
        "SELECT COUNT(*) AS c FROM verses WHERE scripture = 'bhagavata_purana' AND book_num = ?",
        [s],
      ).first['c'] as int;
      stdout.writeln('  Skanda $s: $n verses');
      if (n == 0) {
        gaps.add('Skanda $s has no verses');
      }
    }

    final missingEn = db.select('''
      SELECT COUNT(*) AS c FROM verses
      WHERE scripture = 'bhagavata_purana'
        AND (english IS NOT NULL AND TRIM(english) != '')
    ''').first['c'] as int;
    if (missingEn == 0) {
      stderr.writeln(
        '\n⚠️  No English column data (Sanskrit-only GRETIL seed; translation pass TBD).',
      );
    }

    if (gaps.isNotEmpty) {
      stderr.writeln('\n⚠️  Incomplete skanda coverage:');
      for (final g in gaps) {
        stderr.writeln('   • $g');
      }
    } else {
      stdout.writeln('\n✅ All $_skandas skandas have verses.');
    }
  } finally {
    db.dispose();
  }
}
