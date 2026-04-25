import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/domain/repositories/i_scripture_repository.dart';
import 'package:sanatan_guide/domain/usecases/get_verse_by_id_usecase.dart';

class MockScriptureRepository extends Mock implements IScriptureRepository {}

void main() {
  late GetVerseByIdUseCase useCase;
  late MockScriptureRepository mockRepository;

  final testVerse = Verse(
    id: 'BG.11.12',
    chapterNum: 11,
    verseNum: 12,
    scripture: Scripture.bhagavadGita,
    sanskrit: 'test',
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockRepository = MockScriptureRepository();
    useCase = GetVerseByIdUseCase(repository: mockRepository);
  });

  group('GetVerseByIdUseCase', () {
    test('execute(\'BG.11.12\') — repository succeeds → Right(verse)', () async {
      // Arrange
      when(() => mockRepository.getVerseById('BG.11.12'))
          .thenAnswer((_) async => Right(testVerse));

      // Act
      final result = await useCase.execute('BG.11.12');

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (verse) {
          expect(verse.id, equals('BG.11.12'));
          expect(verse.chapterNum, equals(11));
          expect(verse.verseNum, equals(12));
        },
      );
    });

    test(
        'execute(\'BG.99.99\') — repository returns NotFoundFailure → Left',
        () async {
      // Arrange
      when(() => mockRepository.getVerseById('BG.99.99')).thenAnswer(
        (_) async => const Left(NotFoundFailure('Verse not found: BG.99.99')),
      );

      // Act
      final result = await useCase.execute('BG.99.99');

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) {
          expect(f, isA<NotFoundFailure>());
          expect(f.message, contains('BG.99.99'));
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('execute — repository is called once with correct ID', () async {
      // Arrange
      when(() => mockRepository.getVerseById(any()))
          .thenAnswer((_) async => Right(testVerse));

      // Act
      await useCase.execute('BG.11.12');

      // Assert
      verify(() => mockRepository.getVerseById('BG.11.12')).called(1);
    });
  });
}
