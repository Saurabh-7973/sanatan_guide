import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/domain/repositories/i_scripture_repository.dart';
import 'package:sanatan_guide/domain/usecases/get_verse_of_day_usecase.dart';

class MockScriptureRepository extends Mock implements IScriptureRepository {}

void main() {
  late GetVerseOfDayUseCase useCase;
  late MockScriptureRepository mockRepository;

  // A valid test verse to use across tests
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
    mockRepository = MockScriptureRepository();
    useCase = GetVerseOfDayUseCase(repository: mockRepository);
  });

  group('GetVerseOfDayUseCase', () {
    test('execute — returns verse when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.getVerseOfDay())
          .thenAnswer((_) async => Right(testVerse));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (verse) => expect(verse.id, equals('BG.1.1')),
      );
      verify(() => mockRepository.getVerseOfDay()).called(1);
    });

    test('execute — returns Failure when repository fails', () async {
      // Arrange
      const failure = DatabaseFailure('DB read failed');
      when(() => mockRepository.getVerseOfDay())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<DatabaseFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('execute — repository is called exactly once', () async {
      // Arrange
      when(() => mockRepository.getVerseOfDay())
          .thenAnswer((_) async => Right(testVerse));

      // Act
      await useCase.execute();
      await useCase.execute();

      // Assert — called twice across two execute() calls
      verify(() => mockRepository.getVerseOfDay()).called(2);
    });
  });
}
