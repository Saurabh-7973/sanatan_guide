import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/data/datasources/local/app_database.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';

/// Verifies [ScriptureDao.getReadVerseCountsByScripture] against an
/// in-memory Drift DB. This DAO underpins the per-scripture read-count
/// row in the Library (commit 2fba131) — biggest user-visible bug fix
/// of the v1 final-audit sprint, so we pin its semantics.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  VersesTableCompanion verseRow({
    required String id,
    required Scripture scripture,
    required int chapterNum,
    required int verseNum,
    int readCount = 0,
    int? bookNum,
  }) =>
      VersesTableCompanion.insert(
        id: id,
        chapterNum: chapterNum,
        verseNum: verseNum,
        scripture: scripture.code,
        sanskrit: 'sanskrit',
        english: const Value('english'),
        readCount: Value(readCount),
        createdAt: DateTime(2024, 1, 1),
        bookNum: Value(bookNum),
      );

  test('empty DB → empty map', () async {
    final out = await db.scriptureDao.getReadVerseCountsByScripture();
    expect(out, isEmpty);
  });

  test('only verses with readCount > 0 are counted', () async {
    await db.into(db.versesTable).insert(verseRow(
        id: 'BG.1.1', scripture: Scripture.bhagavadGita,
        chapterNum: 1, verseNum: 1, readCount: 0));
    await db.into(db.versesTable).insert(verseRow(
        id: 'BG.1.2', scripture: Scripture.bhagavadGita,
        chapterNum: 1, verseNum: 2, readCount: 1));
    await db.into(db.versesTable).insert(verseRow(
        id: 'BG.1.3', scripture: Scripture.bhagavadGita,
        chapterNum: 1, verseNum: 3, readCount: 5));

    final out = await db.scriptureDao.getReadVerseCountsByScripture();
    expect(out, {Scripture.bhagavadGita.code: 2});
  });

  test('returns one entry per scripture present', () async {
    await db.into(db.versesTable).insert(verseRow(
        id: 'BG.1.1', scripture: Scripture.bhagavadGita,
        chapterNum: 1, verseNum: 1, readCount: 1));
    await db.into(db.versesTable).insert(verseRow(
        id: 'RV.1.1.1', scripture: Scripture.rigveda,
        bookNum: 1, chapterNum: 1, verseNum: 1, readCount: 1));
    await db.into(db.versesTable).insert(verseRow(
        id: 'KATH.1.1', scripture: Scripture.kathaUpanishad,
        chapterNum: 1, verseNum: 1, readCount: 1));

    final out = await db.scriptureDao.getReadVerseCountsByScripture();
    expect(out, {
      Scripture.bhagavadGita.code: 1,
      Scripture.rigveda.code: 1,
      Scripture.kathaUpanishad.code: 1,
    });
  });

  test('scriptures with zero reads are omitted (not zeroed)', () async {
    // Library page is responsible for defaulting absent keys to 0; the DAO
    // must not emit a row with count 0 (would skew SQL planner cost).
    await db.into(db.versesTable).insert(verseRow(
        id: 'BG.1.1', scripture: Scripture.bhagavadGita,
        chapterNum: 1, verseNum: 1, readCount: 0));

    final out = await db.scriptureDao.getReadVerseCountsByScripture();
    expect(out, isEmpty);
  });

  test('large readCount value preserved in count (not capped)', () async {
    // count(id) counts rows, not the readCount value — so even readCount=999
    // yields 1 in the result. Pins that semantic.
    await db.into(db.versesTable).insert(verseRow(
        id: 'BG.1.1', scripture: Scripture.bhagavadGita,
        chapterNum: 1, verseNum: 1, readCount: 999));

    final out = await db.scriptureDao.getReadVerseCountsByScripture();
    expect(out[Scripture.bhagavadGita.code], 1);
  });
}
