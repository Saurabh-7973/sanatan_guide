// Verifies Atharvaveda rows in assets/db/sanatan_guide.db.
//
// Usage: dart run tool/verify_atharvaveda_db.dart
// Exit 1 if any expected kaanda (1–20) has zero verses, or DB missing.

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
      "SELECT COUNT(*) AS c FROM verses WHERE scripture = 'atharvaveda'",
    ).first['c'] as int;
    stdout.writeln('Atharvaveda verses in DB: $total');

    final gaps = <String>[];
    for (var k = 1; k <= 20; k++) {
      final n = db.select(
        "SELECT COUNT(*) AS c FROM verses WHERE scripture = 'atharvaveda' AND chapter_num = ?",
        [k],
      ).first['c'] as int;
      stdout.writeln('  Kaanda $k: $n verses');
      if (n == 0) {
        gaps.add('Kaanda $k has no verses');
      }
    }

    final missingEn = db.select('''
      SELECT id FROM verses
      WHERE scripture = 'atharvaveda'
        AND (english IS NULL OR TRIM(english) = '')
      ORDER BY id
    ''');
    final miss = missingEn.length;
    if (miss > 0) {
      stderr.writeln(
        '\n⚠️  $miss verse(s) lack English (re-run: '
        'python3 tool/parse_atharvaveda_txt.py /tmp/av.txt)',
      );
      const maxShow = 30;
      for (var i = 0; i < miss && i < maxShow; i++) {
        stderr.writeln('   • ${missingEn[i]['id']}');
      }
      if (miss > maxShow) {
        stderr.writeln('   … (${miss - maxShow} more)');
      }
    }

    if (gaps.isNotEmpty) {
      stderr.writeln('\n❌ Atharvaveda verification failed:');
      for (final g in gaps) {
        stderr.writeln('   • $g');
      }
      exit(1);
    }

    stdout.writeln('\n✅ All 20 kaandas have verses.');
    if (miss == 0) {
      stdout.writeln('✅ English present on every verse.');
    }
  } finally {
    db.dispose();
  }
}
