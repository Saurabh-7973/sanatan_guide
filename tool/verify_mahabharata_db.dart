// Verifies Mahabharata rows in assets/db/sanatan_guide.db (GRETIL Sanskrit per parva).
//
// IDs: MBH.{parva}.{chapter}.{verse} — parva 1–18.
//
// Usage: dart run tool/verify_mahabharata_db.dart
// Exit 1 if DB missing or zero rows. Warn (exit 0) if any parva 1–18 is empty — partial seed.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

const _parvas = 18;

final _idParva = RegExp(r'^MBH\.(\d+)\.');

void main() {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) {
    stderr.writeln('❌ DB not found: $dbPath');
    exit(1);
  }

  final db = sqlite3.open(dbPath);
  try {
    final total = db.select(
      "SELECT COUNT(*) AS c FROM verses WHERE scripture = 'mahabharata'",
    ).first['c'] as int;
    stdout.writeln('Mahabharata verses in DB: $total');
    if (total == 0) {
      stderr.writeln(
        '❌ No rows. Run: python3 tool/parse_mahabharata.py (network; 18 GRETIL files)',
      );
      exit(1);
    }

    final perParva = <int, int>{for (var i = 1; i <= _parvas; i++) i: 0};
    final rows = db.select(
      "SELECT id FROM verses WHERE scripture = 'mahabharata'",
    );
    for (final r in rows) {
      final id = r['id'] as String;
      final m = _idParva.firstMatch(id);
      if (m == null) {
        continue;
      }
      final pnum = int.parse(m.group(1)!);
      if (pnum >= 1 && pnum <= _parvas) {
        perParva[pnum] = (perParva[pnum] ?? 0) + 1;
      }
    }

    final gaps = <String>[];
    for (var p = 1; p <= _parvas; p++) {
      final n = perParva[p] ?? 0;
      stdout.writeln('  Parva $p: $n verses');
      if (n == 0) {
        gaps.add('Parva $p has no verses (re-run parser or check GRETIL fetch)');
      }
    }

    final missingEn = db.select('''
      SELECT COUNT(*) AS c FROM verses
      WHERE scripture = 'mahabharata'
        AND (english IS NOT NULL AND TRIM(english) != '')
    ''').first['c'] as int;
    if (missingEn == 0) {
      stderr.writeln(
        '\n⚠️  No English column data (Sanskrit-only GRETIL seed; Ganguli translation pass TBD).',
      );
    }

    if (gaps.isNotEmpty) {
      stderr.writeln('\n⚠️  Incomplete parva coverage (bundled DB may be partial):');
      for (final g in gaps) {
        stderr.writeln('   • $g');
      }
    } else {
      stdout.writeln('\n✅ All $_parvas parvas have verses.');
    }
  } finally {
    db.dispose();
  }
}
