import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';
import 'package:sanatan_guide/data/datasources/local/daos/bookmarks_dao.dart';
import 'package:sanatan_guide/data/datasources/local/daos/learning_dao.dart';
import 'package:sanatan_guide/data/datasources/local/daos/scripture_dao.dart';
import 'package:sanatan_guide/data/datasources/local/tables/bookmarks_table.dart';
import 'package:sanatan_guide/data/datasources/local/tables/commentaries_table.dart';
import 'package:sanatan_guide/data/datasources/local/tables/learning_modules_table.dart';
import 'package:sanatan_guide/data/datasources/local/tables/module_cards_table.dart';
import 'package:sanatan_guide/data/datasources/local/tables/module_extras_table.dart';
import 'package:sanatan_guide/data/datasources/local/tables/user_module_progress_table.dart';
import 'package:sanatan_guide/data/datasources/local/tables/verse_explanations_table.dart';
import 'package:sanatan_guide/data/datasources/local/tables/verses_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    VersesTable,
    LearningModulesTable,
    ModuleCardsTable,
    ModuleExtrasTable,
    UserModuleProgressTable,
    BookmarksTable,
    VerseExplanationsTable,
    CommentariesTable,
  ],
  daos: [ScriptureDao, LearningDao, BookmarksDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createIndexes(m);
          await _createFts5(m);
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from <= 1) {
            await m.createTable(learningModulesTable);
            await m.createTable(moduleCardsTable);
            await m.createTable(moduleExtrasTable);
            await m.createTable(userModuleProgressTable);
          }
          if (from <= 2) {
            await m.addColumn(versesTable, versesTable.noteText);
          }
          if (from <= 3) {
            await m.createTable(bookmarksTable);
          }
          if (from <= 4) {
            await m.addColumn(versesTable, versesTable.bookNum);
            await m.addColumn(versesTable, versesTable.chapterLabel);
            await m.addColumn(versesTable, versesTable.translation);
          }
          if (from <= 5) {
            await _createIndexes(m);
          }
          if (from <= 6) {
            await _createFts5(m);
          }
          if (from <= 7) {
            await m.createTable(verseExplanationsTable);
          }
          if (from <= 8) {
            await m.createTable(commentariesTable);
            await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_commentaries_verse_id '
              'ON commentaries (verse_id)',
            );
          }
          if (from <= 9) {
            // Audit D-3: verse_explanations lookups go by verse_id; the
            // implicit primary-key index covers `id` only. At 1000+
            // cached explanations the scan cost is noticeable.
            await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_verse_explanations_verse_id '
              'ON verse_explanations (verse_id)',
            );
          }
        },
      );

  Future<void> _createIndexes(Migrator m) async {
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_verses_scripture_chapter '
      'ON verses (scripture, chapter_num, book_num, verse_num)',
    );
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_verses_scripture '
      'ON verses (scripture)',
    );
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_commentaries_verse_id '
      'ON commentaries (verse_id)',
    );
    await m.database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_verse_explanations_verse_id '
      'ON verse_explanations (verse_id)',
    );
  }

  /// Creates the FTS5 virtual table, populates it from existing verses,
  /// and installs triggers to keep it in sync on insert/update/delete.
  Future<void> _createFts5(Migrator m) async {
    final db = m.database;

    await db.customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS verses_fts USING fts5(
        id, sanskrit, transliteration, hindi, english,
        content='verses', content_rowid='rowid'
      )
    ''');

    // Populate FTS index from existing data
    await db.customStatement(
      "INSERT INTO verses_fts(verses_fts) VALUES('rebuild')",
    );

    // Keep FTS in sync when rows change
    await db.customStatement('''
      CREATE TRIGGER IF NOT EXISTS verses_ai AFTER INSERT ON verses BEGIN
        INSERT INTO verses_fts(rowid, id, sanskrit, transliteration, hindi, english)
        VALUES (new.rowid, new.id, new.sanskrit, new.transliteration, new.hindi, new.english);
      END
    ''');

    await db.customStatement('''
      CREATE TRIGGER IF NOT EXISTS verses_ad AFTER DELETE ON verses BEGIN
        INSERT INTO verses_fts(verses_fts, rowid, id, sanskrit, transliteration, hindi, english)
        VALUES ('delete', old.rowid, old.id, old.sanskrit, old.transliteration, old.hindi, old.english);
      END
    ''');

    await db.customStatement('''
      CREATE TRIGGER IF NOT EXISTS verses_au AFTER UPDATE ON verses BEGIN
        INSERT INTO verses_fts(verses_fts, rowid, id, sanskrit, transliteration, hindi, english)
        VALUES ('delete', old.rowid, old.id, old.sanskrit, old.transliteration, old.hindi, old.english);
        INSERT INTO verses_fts(rowid, id, sanskrit, transliteration, hindi, english)
        VALUES (new.rowid, new.id, new.sanskrit, new.transliteration, new.hindi, new.english);
      END
    ''');

    AppLogger.instance.i('FTS5 index created and populated');
  }
}

Future<QueryExecutor> openAppDatabaseConnection() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final dbFile = File(path.join(dbFolder.path, 'sanatan_guide.db'));

  // Size sentinel: bundled DB is ~65 MB. Anything < 1 MB is a stale/empty
  // remnant from a previously failed extract — wipe + re-extract.
  const minViableBytes = 1 * 1024 * 1024;
  final exists = dbFile.existsSync();
  final tooSmall = exists && dbFile.lengthSync() < minViableBytes;
  if (tooSmall) {
    AppLogger.instance.w(
      'Runtime DB at ${dbFile.path} is ${dbFile.lengthSync()} bytes — '
      'treating as stale and re-extracting from bundled .gz.',
    );
    try {
      await dbFile.delete();
    } catch (_) {}
  }

  if (!dbFile.existsSync()) {
    try {
      final compressed = await rootBundle.load('assets/db/sanatan_guide.db.gz');
      final bytes = compressed.buffer.asUint8List();
      // gzip.decode on a 14 MB blob → ~65 MB takes ~600-900 ms on a low-end
      // device. Run it on a worker isolate so the splash screen stays
      // animated and the main thread doesn't drop frames during the very
      // first cold launch.
      final decoded = await compute(_gzipDecode, bytes);
      await dbFile.writeAsBytes(decoded, flush: true);
      AppLogger.instance.i(
        'Bundled DB decompressed to: ${dbFile.path} '
        '(${compressed.lengthInBytes >> 20}MB -> ${decoded.length >> 20}MB)',
      );
    } catch (e, st) {
      AppLogger.instance.w(
        'Bundled DB not found in assets — starting with empty DB.',
        e,
        st,
      );
    }
  }

  return NativeDatabase.createInBackground(dbFile);
}

/// Top-level so `compute` can serialize it to a background isolate.
List<int> _gzipDecode(Uint8List bytes) => gzip.decode(bytes);
