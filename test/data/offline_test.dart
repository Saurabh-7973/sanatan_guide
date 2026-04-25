import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/data/datasources/local/app_database.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';

/// Verifies that the Drift database works fully offline:
/// create tables, insert data, query verses, bookmarks, and search —
/// all without any network access.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  VersesTableCompanion makeVerse({
    required String id,
    required String scripture,
    int chapterNum = 1,
    int verseNum = 1,
    String sanskrit = 'ॐ',
    String? english,
  }) =>
      VersesTableCompanion.insert(
        id: id,
        chapterNum: chapterNum,
        verseNum: verseNum,
        scripture: scripture,
        sanskrit: sanskrit,
        english: Value(english),
        isBookmarked: const Value(false),
        readCount: const Value(0),
        createdAt: DateTime(2024, 1, 1),
      );

  group('Offline database operations', () {
    test('can insert and query a verse', () async {
      await db.into(db.versesTable).insert(
            makeVerse(
              id: 'BG.1.1',
              scripture: Scripture.bhagavadGita.code,
              sanskrit: 'धृतराष्ट्र उवाच',
              english: 'Dhritarashtra said:',
            ),
          );

      final verse = await db.scriptureDao.getVerseById('BG.1.1');

      expect(verse, isNotNull);
      expect(verse!.id, 'BG.1.1');
      expect(verse.sanskrit, 'धृतराष्ट्र उवाच');
      expect(verse.english, 'Dhritarashtra said:');
    });

    test('verse of the day works with seeded data', () async {
      for (var i = 1; i <= 5; i++) {
        await db.into(db.versesTable).insert(
              makeVerse(
                id: 'BG.1.$i',
                scripture: Scripture.bhagavadGita.code,
                verseNum: i,
                sanskrit: 'verse $i',
                english: 'Verse $i translation',
              ),
            );
      }

      final verse = await db.scriptureDao.getVerseOfDay();

      expect(verse, isNotNull);
      expect(verse!.id, startsWith('BG.1.'));
    });

    test('bookmark toggle works offline', () async {
      await db.into(db.versesTable).insert(
            makeVerse(
              id: 'BG.2.47',
              scripture: Scripture.bhagavadGita.code,
              chapterNum: 2,
              verseNum: 47,
            ),
          );

      final toggled = await db.scriptureDao.toggleBookmark('BG.2.47');

      expect(toggled, isNotNull);
      expect(toggled!.isBookmarked, isTrue);

      final unToggled = await db.scriptureDao.toggleBookmark('BG.2.47');
      expect(unToggled!.isBookmarked, isFalse);
    });

    test('search returns matching verses offline', () async {
      await db.into(db.versesTable).insert(
            makeVerse(
              id: 'BG.2.47',
              scripture: Scripture.bhagavadGita.code,
              chapterNum: 2,
              verseNum: 47,
              english: 'You have a right to perform your prescribed duties',
            ),
          );
      await db.into(db.versesTable).insert(
            makeVerse(
              id: 'BG.3.19',
              scripture: Scripture.bhagavadGita.code,
              chapterNum: 3,
              verseNum: 19,
              english: 'Therefore always perform your duty without attachment',
            ),
          );

      final results = await db.scriptureDao.search('duty');

      expect(results, isNotEmpty);
      expect(results.every((r) => r.english!.contains('dut')), isTrue);
    });

    test('chapter query returns ordered verses', () async {
      for (var i = 3; i >= 1; i--) {
        await db.into(db.versesTable).insert(
              makeVerse(
                id: 'BG.1.$i',
                scripture: Scripture.bhagavadGita.code,
                verseNum: i,
                sanskrit: 'verse $i',
              ),
            );
      }

      final chapter = await db.scriptureDao.getChapter(
        scriptureCode: Scripture.bhagavadGita.code,
        chapterNum: 1,
      );

      expect(chapter.length, 3);
      expect(chapter[0].verseNum, 1);
      expect(chapter[1].verseNum, 2);
      expect(chapter[2].verseNum, 3);
    });

    test('empty database returns null for verse of day', () async {
      final verse = await db.scriptureDao.getVerseOfDay();
      expect(verse, isNull);
    });

    test('learning modules table exists and is queryable', () async {
      final modules = await db.select(db.learningModulesTable).get();
      expect(modules, isEmpty);
    });
  });
}
