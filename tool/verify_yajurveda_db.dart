// Verifies Yajurveda (White Yajurveda / Vājasaneyi Madhyadina) rows in assets/db/sanatan_guide.db.
//
// Pipeline: `dart run tool/parse_yajurveda.dart` (DharmicData Sanskrit) then
// `python3 tool/parse_yajurveda_html.py tool/sources/wyv/` (Griffith English).
//
// Usage: dart run tool/verify_yajurveda_db.dart
// Exit 1 if DB missing or any expected adhyaya (1–40) has zero verses.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

const _expectedBooks = 40;

void main() {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) {
    stderr.writeln('❌ DB not found: $dbPath');
    exit(1);
  }

  final db = sqlite3.open(dbPath);
  try {
    final total = db.select(
      "SELECT COUNT(*) AS c FROM verses WHERE scripture = 'yajurveda'",
    ).first['c'] as int;
    stdout.writeln('Yajurveda verses in DB: $total');
    if (total == 0) {
      stderr.writeln(
        '❌ No rows. Run: dart run tool/parse_yajurveda.dart '
        'then python3 tool/parse_yajurveda_html.py tool/sources/wyv/',
      );
      exit(1);
    }

    final gaps = <String>[];
    for (var b = 1; b <= _expectedBooks; b++) {
      final n = db.select(
        "SELECT COUNT(*) AS c FROM verses WHERE scripture = 'yajurveda' AND chapter_num = ?",
        [b],
      ).first['c'] as int;
      stdout.writeln('  Adhyaya $b: $n verses');
      if (n == 0) {
        gaps.add('Adhyaya $b has no verses');
      }
    }

    final pending = db.select('''
      SELECT COUNT(*) AS c FROM verses
      WHERE scripture = 'yajurveda' AND translation = 'griffith_pending'
    ''').first['c'] as int;
    if (pending > 0) {
      stderr.writeln('\n⚠️  $pending row(s) still have translation=griffith_pending (English not merged).');
    }

    final missingEn = db.select('''
      SELECT id FROM verses
      WHERE scripture = 'yajurveda'
        AND (english IS NULL OR TRIM(english) = '')
      ORDER BY id
    ''');
    final missEn = missingEn.length;
    if (missEn > 0) {
      stderr.writeln('\n⚠️  $missEn verse(s) lack English.');
      const maxShow = 30;
      for (var i = 0; i < missEn && i < maxShow; i++) {
        stderr.writeln('   • ${missingEn[i]['id']}');
      }
      if (missEn > maxShow) {
        stderr.writeln('   … (${missEn - maxShow} more)');
      }
    }

    final missingSk = db.select('''
      SELECT COUNT(*) AS c FROM verses
      WHERE scripture = 'yajurveda'
        AND (sanskrit IS NULL OR TRIM(sanskrit) = '')
    ''').first['c'] as int;
    if (missingSk > 0) {
      stderr.writeln(
        '\n⚠️  $missingSk verse(s) lack Sanskrit (HTML-only inserts or alignment gap).',
      );
    }

    final minRow = db.select('''
      SELECT id FROM verses WHERE scripture = 'yajurveda'
      ORDER BY chapter_num ASC, verse_num ASC LIMIT 1
    ''').first;
    final maxRow = db.select('''
      SELECT id FROM verses WHERE scripture = 'yajurveda'
      ORDER BY chapter_num DESC, verse_num DESC LIMIT 1
    ''').first;
    stdout.writeln('\n   Range: ${minRow['id']} … ${maxRow['id']}');

    if (gaps.isNotEmpty) {
      stderr.writeln('\n❌ Yajurveda verification failed:');
      for (final g in gaps) {
        stderr.writeln('   • $g');
      }
      exit(1);
    }

    stdout.writeln('\n✅ All $_expectedBooks adhyayas have verses.');
    if (missEn == 0 && missingSk == 0 && pending == 0) {
      stdout.writeln('✅ Sanskrit and English present on every verse; translation=griffith.');
    }
  } finally {
    db.dispose();
  }
}
