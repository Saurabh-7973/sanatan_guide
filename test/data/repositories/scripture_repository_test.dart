import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/data/datasources/local/app_database.dart';
import 'package:sanatan_guide/data/datasources/local/daos/scripture_dao.dart';
import 'package:sanatan_guide/data/repositories/scripture_repository.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';

class MockScriptureDao extends Mock implements ScriptureDao {}

void main() {
  late ScriptureRepository repository;
  late MockScriptureDao mockDao;

  final tableRow = VersesTableData(
    id: 'BG.1.1',
    chapterNum: 1,
    verseNum: 1,
    scripture: Scripture.bhagavadGita.code,
    sanskrit: 'धृतराष्ट्र उवाच',
    english: 'Dhritarashtra said:',
    isBookmarked: false,
    readCount: 0,
    createdAt: DateTime(2024, 1, 1),
  );

  final testVerse = Verse(
    id: 'BG.1.1',
    chapterNum: 1,
    verseNum: 1,
    scripture: Scripture.bhagavadGita,
    sanskrit: 'धृतराष्ट्र उवाच',
    english: 'Dhritarashtra said:',
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockDao = MockScriptureDao();
    repository = ScriptureRepository(dao: mockDao);
  });

  group('ScriptureRepository', () {
    test('getVerseOfDay — success maps to Right(Verse)', () async {
      when(() => mockDao.getVerseOfDay()).thenAnswer((_) async => tableRow);

      final result = await repository.getVerseOfDay();

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail('Expected Right, got $f'),
        (v) {
          expect(v.id, testVerse.id);
          expect(v.scripture, Scripture.bhagavadGita);
          expect(v.sanskrit, testVerse.sanskrit);
        },
      );
      verify(() => mockDao.getVerseOfDay()).called(1);
    });

    test('getVerseOfDay — null row → Left(NotFoundFailure)', () async {
      when(() => mockDao.getVerseOfDay()).thenAnswer((_) async => null);

      final result = await repository.getVerseOfDay();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) {
          expect(f, isA<NotFoundFailure>());
          expect(f.message, contains('No verses'));
        },
        (_) => fail('Expected Left'),
      );
    });

    test('getVerseOfDay — dao throws → Left(DatabaseFailure)', () async {
      when(() => mockDao.getVerseOfDay()).thenThrow(Exception('db error'));

      final result = await repository.getVerseOfDay();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<DatabaseFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('toggleBookmark — success returns updated verse', () async {
      final updatedRow = VersesTableData(
        id: tableRow.id,
        chapterNum: tableRow.chapterNum,
        verseNum: tableRow.verseNum,
        scripture: tableRow.scripture,
        sanskrit: tableRow.sanskrit,
        english: tableRow.english,
        isBookmarked: true,
        readCount: tableRow.readCount,
        createdAt: tableRow.createdAt,
      );
      when(() => mockDao.toggleBookmark('BG.1.1'))
          .thenAnswer((_) async => updatedRow);

      final result = await repository.toggleBookmark('BG.1.1');

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail('Expected Right, got $f'),
        (v) => expect(v.isBookmarked, isTrue),
      );
      verify(() => mockDao.toggleBookmark('BG.1.1')).called(1);
    });

    test('search — empty query returns Right([]) without calling dao',
        () async {
      final result = await repository.search('   ');

      expect(result, const Right<Failure, List<Verse>>([]));
      verifyNever(() => mockDao.search(any()));
    });
  });
}
