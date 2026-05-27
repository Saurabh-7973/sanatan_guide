import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/data/datasources/local/app_database.dart';

/// Verifies the commentaries table + DAO round-trip through an in-memory
/// Drift database (schema v9).
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  CommentariesTableCompanion makeCommentary({
    required String id,
    required String verseId,
    String tradition = 'advaita',
    String author = 'Adi Shankaracharya',
    String translator = 'A. Mahadeva Sastri',
    String sourceUrl = 'https://archive.org/details/bhagavadgitawith00shan',
    String license = 'public_domain',
    String? textEnglish,
    String? textSanskrit,
  }) =>
      CommentariesTableCompanion.insert(
        id: id,
        verseId: verseId,
        tradition: tradition,
        author: author,
        sourceUrl: sourceUrl,
        license: license,
        createdAt: DateTime(2024, 1, 1),
        textEnglish: Value(textEnglish),
        textSanskrit: Value(textSanskrit),
        translator: Value(translator),
      );

  group('CommentariesDao', () {
    test('empty verse returns empty list, not null', () async {
      final rows = await db.scriptureDao.getCommentariesByVerseId('BG.2.47');
      expect(rows, isEmpty);
    });

    test('insert + fetch round-trip preserves every provenance field',
        () async {
      await db.into(db.commentariesTable).insert(
            makeCommentary(
              id: 'shankara_gita_2.47',
              verseId: 'BG.2.47',
              textSanskrit: 'कर्मण्येवाधिकारस्ते ...',
              textEnglish:
                  'Thy right is to work only, but never to its fruits ...',
            ),
          );

      final rows = await db.scriptureDao.getCommentariesByVerseId('BG.2.47');

      expect(rows, hasLength(1));
      final c = rows.first;
      expect(c.id, 'shankara_gita_2.47');
      expect(c.tradition, 'advaita');
      expect(c.author, 'Adi Shankaracharya');
      expect(c.translator, 'A. Mahadeva Sastri');
      expect(c.license, 'public_domain');
      expect(c.sourceUrl, contains('archive.org'));
      expect(c.textSanskrit, startsWith('कर्मण्य'));
      expect(c.textEnglish, contains('right is to work'));
    });

    test('multiple traditions per verse are ordered by tradition name',
        () async {
      await db.into(db.commentariesTable).insert(
            makeCommentary(
              id: 'ramanuja_gita_2.47',
              verseId: 'BG.2.47',
              tradition: 'vishishtadvaita',
              author: 'Ramanujacharya',
            ),
          );
      await db.into(db.commentariesTable).insert(
            makeCommentary(
              id: 'shankara_gita_2.47',
              verseId: 'BG.2.47',
            ),
          );

      final rows = await db.scriptureDao.getCommentariesByVerseId('BG.2.47');

      expect(rows.map((r) => r.tradition), ['advaita', 'vishishtadvaita']);
    });

    test('only rows for requested verse come back', () async {
      await db.into(db.commentariesTable).insert(
            makeCommentary(id: 'a', verseId: 'BG.2.47'),
          );
      await db.into(db.commentariesTable).insert(
            makeCommentary(id: 'b', verseId: 'BG.3.19'),
          );

      final rows = await db.scriptureDao.getCommentariesByVerseId('BG.2.47');
      expect(rows, hasLength(1));
      expect(rows.single.id, 'a');
    });

    test(
        'orphan-row behaviour is documented: commentaries survive if verse deleted, '
        'so seeders must use verse_id matching a real verse', () async {
      // No FK constraint is declared today — this test pins that decision
      // so we notice if someone adds ON DELETE CASCADE later.
      await db.into(db.commentariesTable).insert(
            makeCommentary(id: 'orphan', verseId: 'BG.999.999'),
          );
      final rows = await db.scriptureDao.getCommentariesByVerseId('BG.999.999');
      expect(rows, hasLength(1),
          reason: 'commentary is reachable even without a matching verse row — '
              'seed tool allowlist is the defence, not the schema.');
    });

    test('Sanskrit-only and English-only rows are both queryable', () async {
      await db.into(db.commentariesTable).insert(
            makeCommentary(
              id: 'sa-only',
              verseId: 'BG.2.47',
              textSanskrit: 'केवल संस्कृतम्',
              translator: '',
            ),
          );
      await db.into(db.commentariesTable).insert(
            makeCommentary(
              id: 'en-only',
              verseId: 'BG.2.47',
              tradition: 'dvaita',
              textEnglish: 'English only',
              textSanskrit: null,
            ),
          );

      final rows = await db.scriptureDao.getCommentariesByVerseId('BG.2.47');
      expect(rows, hasLength(2));

      final sa = rows.firstWhere((r) => r.id == 'sa-only');
      final en = rows.firstWhere((r) => r.id == 'en-only');
      expect(sa.textEnglish, isNull);
      expect(en.textSanskrit, isNull);
    });
  });
}
