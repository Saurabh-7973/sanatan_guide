// Verifies bundled Rigveda coverage in assets/db/sanatan_guide.db.
//
// Usage: dart run tool/verify_rigveda_db.dart
// Exit 0 = expected hymn counts per mandala; exit 1 = gaps or DB missing.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

const Map<int, int> _expectedHymnsPerMandala = {
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

void main() {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) {
    stderr.writeln('❌ DB not found: $dbPath');
    exit(1);
  }

  final db = sqlite3.open(dbPath);
  try {
    final total = db.select(
      "SELECT COUNT(*) AS c FROM verses WHERE scripture = 'rigveda'",
    ).first['c'] as int;
    stdout.writeln('Rigveda verses in DB: $total');

    final gaps = <String>[];
    for (final e in _expectedHymnsPerMandala.entries) {
      final m = e.key;
      final want = e.value;
      final rows = db.select('''
        SELECT COUNT(DISTINCT
          CAST(
            SUBSTR(
              SUBSTR(id, 4),
              INSTR(SUBSTR(id, 4), '.') + 1,
              INSTR(SUBSTR(SUBSTR(id, 4), INSTR(SUBSTR(id, 4), '.') + 1), '.') - 1
            ) AS INT
          )
        ) AS hymns
        FROM verses
        WHERE id LIKE 'RV.$m.%'
      ''');
      final have = (rows.first['hymns'] as int?) ?? 0;
      if (have != want) {
        gaps.add('Mandala $m: expected $want hymns, found $have');
      }
      stdout.writeln('  Mandala $m: $have / $want hymns');
    }

    final sansEmpty = db.select('''
      SELECT COUNT(*) AS c FROM verses
      WHERE scripture = 'rigveda' AND (sanskrit IS NULL OR TRIM(sanskrit) = '')
    ''').first['c'] as int;
    if (sansEmpty > 0) {
      stderr.writeln(
        '\n⚠️  Warning: $sansEmpty Rigveda rows have empty Sanskrit '
        '(re-run parse_rigveda when DharmicData is available).',
      );
    }

    if (gaps.isNotEmpty) {
      stderr.writeln('\n❌ Rigveda verification failed:');
      for (final g in gaps) {
        stderr.writeln('   • $g');
      }
      exit(1);
    }

    stdout.writeln('\n✅ Rigveda hymn coverage matches canonical counts.');
  } finally {
    db.dispose();
  }
}
