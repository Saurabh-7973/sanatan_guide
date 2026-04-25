// tool/seed_database.dart
//
// Standalone Dart script. Run from project root:
//   dart run tool/seed_database.dart
//
// Fetches all 700 Bhagavad Gita verses from vedicscriptures.github.io
// and writes them into assets/db/sanatan_guide.db
//
// Run this once. Commit the resulting .db file.
// The app copies it to device storage on first launch.

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

// Exact verse counts per chapter in the Bhagavad Gita
const _chapterVerseCounts = [
  47,
  72,
  43,
  42,
  29,
  47,
  30,
  28,
  34,
  42,
  55,
  20,
  35,
  27,
  20,
  24,
  28,
  78,
];

// These must match the Scripture enum codes in lib/domain/entities/scripture.dart
const _scriptureCode = 'bhagavad_gita';

// ID prefix — matches the format expected by domain layer: 'BG.1.1'
const _idPrefix = 'BG';

Future<void> main() async {
  final outputPath = p.join('assets', 'db', 'sanatan_guide.db');

  // Ensure output directory exists
  Directory(p.dirname(outputPath)).createSync(recursive: true);

  // Delete existing file so we start clean
  final dbFile = File(outputPath);
  if (dbFile.existsSync()) {
    dbFile.deleteSync();
    _log('Deleted existing DB at $outputPath');
  }

  final db = sqlite3.open(outputPath);

  try {
    _createSchema(db);

    final createdAt = DateTime.now().millisecondsSinceEpoch;
    var inserted = 0;
    var failed = 0;

    db.execute('BEGIN TRANSACTION');

    final stmt = db.prepare('''
      INSERT INTO verses (
        id, chapter_num, verse_num, scripture,
        sanskrit, transliteration, hindi, english,
        word_meaning, is_bookmarked, read_count, created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NULL, 0, 0, ?)
    ''');

    for (var ch = 1; ch <= 18; ch++) {
      final verseCount = _chapterVerseCounts[ch - 1];
      _log('\nChapter $ch — fetching $verseCount verses...');

      for (var v = 1; v <= verseCount; v++) {
        final id = '$_idPrefix.$ch.$v';
        final url = 'https://vedicscriptures.github.io/slok/$ch/$v';

        try {
          final response = await http.get(
            Uri.parse(url),
            headers: {'Accept': 'application/json'},
          );

          if (response.statusCode != 200) {
            _log('  ✗ HTTP ${response.statusCode} for $id');
            failed++;
            continue;
          }

          final data = jsonDecode(response.body) as Map<String, dynamic>;

          final sanskrit = (data['slok'] as String? ?? '').trim();
          if (sanskrit.isEmpty) {
            _log('  ✗ Empty Sanskrit for $id — skipping');
            failed++;
            continue;
          }

          final transliteration = (data['transliteration'] as String?)?.trim();

          // Extract best available Hindi translation
          final hindi = _extractHindi(data);

          // Extract best available English translation
          final english = _extractEnglish(data);

          stmt.execute([
            id,
            ch,
            v,
            _scriptureCode,
            sanskrit,
            transliteration,
            hindi,
            english,
            createdAt,
          ]);

          inserted++;
          stdout.write('  ✓ $id\r');

          // Brief pause — be respectful to the public API
          await Future.delayed(const Duration(milliseconds: 80));
        } on SocketException catch (e) {
          _log('  ✗ Network error for $id: $e');
          failed++;
        } catch (e) {
          _log('  ✗ Error for $id: $e');
          failed++;
        }
      }

      _log('  Chapter $ch done');
    }

    stmt.dispose();
    db.execute('COMMIT');

    // Verify
    final count =
        db.select('SELECT COUNT(*) AS c FROM verses').first['c'] as int;

    _log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _log('✅ Seeding complete');
    _log('   Inserted : $inserted');
    _log('   Failed   : $failed');
    _log('   In DB    : $count');
    _log('   Output   : $outputPath');
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (count < 700) {
      _log(
          '⚠️  Got $count verses — expected at least 700. Re-run to retry failed ones.');
      exitCode = 1;
    }
  } catch (e, st) {
    db.execute('ROLLBACK');
    _log('❌ Fatal error: $e\n$st');
    exitCode = 1;
  } finally {
    db.dispose();
  }
}

// ── Schema ────────────────────────────────────────────────────────────────────
// Column names and types MUST match the Drift-generated schema exactly.
// created_at is stored as microseconds since epoch (Drift default for DateTime).

void _createSchema(Database db) {
  db.execute('''
    CREATE TABLE IF NOT EXISTS verses (
      id            TEXT    PRIMARY KEY NOT NULL,
      chapter_num   INTEGER NOT NULL,
      verse_num     INTEGER NOT NULL,
      scripture     TEXT    NOT NULL,
      sanskrit      TEXT    NOT NULL,
      transliteration TEXT,
      hindi         TEXT,
      english       TEXT,
      word_meaning  TEXT,
      is_bookmarked INTEGER NOT NULL DEFAULT 0
                            CHECK (is_bookmarked IN (0, 1)),
      read_count    INTEGER NOT NULL DEFAULT 0,
      note_text     TEXT,
      created_at    INTEGER NOT NULL
    )
  ''');
  _log('Schema ready');
}

// ── Translation extractors ────────────────────────────────────────────────────
// The vedicscriptures dataset has 21+ translators. Each entry is a map with:
//   "ht" → Hindi text
//   "et" → English text
// We try preferred translators first, fall back to any available.

String? _extractHindi(Map<String, dynamic> data) {
  // Preferred Hindi translators in order
  for (final key in ['tej', 'san', 'ramsukh', 'jaya']) {
    final t = data[key];
    if (t is Map<String, dynamic>) {
      final ht = (t['ht'] as String?)?.trim();
      if (ht != null && ht.isNotEmpty) return ht;
    }
  }
  // Fall back: scan all keys for any 'ht' field
  for (final entry in data.entries) {
    if (entry.value is Map<String, dynamic>) {
      final ht = (entry.value['ht'] as String?)?.trim();
      if (ht != null && ht.isNotEmpty) return ht;
    }
  }
  return null;
}

String? _extractEnglish(Map<String, dynamic> data) {
  // Preferred English translators in order
  for (final key in ['siva', 'purohit', 'chinmay', 'adi', 'gambir', 'anand']) {
    final t = data[key];
    if (t is Map<String, dynamic>) {
      final et = (t['et'] as String?)?.trim();
      if (et != null && et.isNotEmpty) return et;
    }
  }
  // Fall back: scan all keys for any 'et' field
  for (final entry in data.entries) {
    if (entry.value is Map<String, dynamic>) {
      final et = (entry.value['et'] as String?)?.trim();
      if (et != null && et.isNotEmpty) return et;
    }
  }
  return null;
}

void _log(String message) => print(message);
