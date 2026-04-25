import 'package:fpdart/fpdart.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/domain/repositories/i_scripture_repository.dart';

/// Returns the verse designated for today.
/// Thin delegation to [IScriptureRepository.getVerseOfDay].
/// All day-seeding logic lives in the repository implementation.
final class GetVerseOfDayUseCase {
  final IScriptureRepository _repository;

  const GetVerseOfDayUseCase({required IScriptureRepository repository})
      : _repository = repository;

  Future<Either<Failure, Verse>> execute() => _repository.getVerseOfDay();
}
