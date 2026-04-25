// Full scripture / module DB reseed order (project root):
//   dart run tool/seed_modules.dart
//   dart run tool/seed_level2_modules.dart
//   dart run tool/seed_upanishads.dart
//   dart run tool/seed_yoga_sutras.dart
//   dart run tool/seed_hatha_yoga.dart
//   dart run tool/seed_vishnu_sahasranama.dart
//   dart run tool/seed_manusmriti.dart
//   dart run tool/seed_mahanirvana.dart
//   dart run tool/seed_brahma_sutras.dart
//   dart run tool/seed_prashna_upanishad.dart
//   dart run tool/seed_taittiriya_upanishad.dart
//   dart run tool/seed_aitareya_upanishad.dart
//   dart run tool/fix_db_version.dart

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

Future<void> main() async {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) {
    print('❌ DB not found at $dbPath');
    exit(1);
  }
  final db = sqlite3.open(dbPath);
  try {
    // Create bookmarks table if missing
    db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks (
        verse_id TEXT NOT NULL,
        saved_at INTEGER NOT NULL,
        PRIMARY KEY (verse_id)
      )
    ''');

    // Add v5 columns to verses table if missing
    final versesCols = <String>[];
    for (final row in db.select('PRAGMA table_info(verses)')) {
      versesCols.add(row['name'] as String);
    }
    if (!versesCols.contains('book_num')) {
      db.execute('ALTER TABLE verses ADD COLUMN book_num INTEGER');
    }
    if (!versesCols.contains('chapter_label')) {
      db.execute('ALTER TABLE verses ADD COLUMN chapter_label TEXT');
    }
    if (!versesCols.contains('translation')) {
      db.execute('ALTER TABLE verses ADD COLUMN translation TEXT');
    }

    // Set schema version so Drift skips migrations
    db.execute('PRAGMA user_version = 5;');

    final version =
        db.select('PRAGMA user_version').first.values.first as int;
    final modules =
        db.select('SELECT COUNT(*) AS c FROM learning_modules').first['c'] as int;
    final cards =
        db.select('SELECT COUNT(*) AS c FROM module_cards').first['c'] as int;
    final bookmarks =
        db.select('SELECT COUNT(*) AS c FROM bookmarks').first['c'] as int;

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ DB fixed');
    print('   user_version : $version');
    print('   Modules      : $modules');
    print('   Cards        : $cards');
    print('   Bookmarks    : $bookmarks (table created)');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } finally {
    db.dispose();
  }
}
