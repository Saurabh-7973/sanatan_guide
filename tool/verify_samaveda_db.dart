// Verifies Samaveda rows in assets/db/sanatan_guide.db (Griffith pipeline).
//
// Usage: dart run tool/verify_samaveda_db.dart
// Exit 1 if no rows or DB missing. Warns if English or Sanskrit coverage looks wrong.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

void main() {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) {
    stderr.writeln('❌ DB not found: $dbPath');
    exit(1);
  }

  final db = sqlite3.open(dbPath);
  try {
    final total = db.select(
      "SELECT COUNT(*) AS c FROM verses WHERE scripture = 'samaveda'",
    ).first['c'] as int;
    stdout.writeln('Samaveda verses in DB: $total');
    if (total == 0) {
      stderr.writeln('❌ No Samaveda verses. Run: python3 tool/parse_samaveda_html.py tool/sources/samaveda.html');
      exit(1);
    }

    final missingEn = db.select('''
      SELECT COUNT(*) AS c FROM verses
      WHERE scripture = 'samaveda' AND (english IS NULL OR TRIM(english) = '')
    ''').first['c'] as int;
    final missingSk = db.select('''
      SELECT COUNT(*) AS c FROM verses
      WHERE scripture = 'samaveda' AND (sanskrit IS NULL OR TRIM(sanskrit) = '')
    ''').first['c'] as int;

    if (missingEn > 0) {
      stderr.writeln('⚠️  $missingEn verse(s) lack English.');
    }
    if (missingSk > 0) {
      stderr.writeln(
        '⚠️  $missingSk verse(s) lack Sanskrit (expected until a Sanskrit source is merged; Griffith HTML is English-only).',
      );
    }

    final range = db.select('''
      SELECT MIN(id) AS a, MAX(id) AS b FROM verses WHERE scripture = 'samaveda'
    ''').first;
    stdout.writeln('   Range: ${range['a']} … ${range['b']}');

    if (missingEn == 0) {
      stdout.writeln('✅ Griffith English coverage: all rows have English.');
    }
  } finally {
    db.dispose();
  }
}
