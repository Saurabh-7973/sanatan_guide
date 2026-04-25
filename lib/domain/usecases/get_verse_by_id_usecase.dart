import 'package:fpdart/fpdart.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/domain/repositories/i_scripture_repository.dart';

/// Fetches a single verse by its composite ID (e.g. 'BG.11.12').
/// Returns [NotFoundFailure] if verse does not exist in the local DB.
final class GetVerseByIdUseCase {
  final IScriptureRepository _repository;
  const GetVerseByIdUseCase({required IScriptureRepository repository})
      : _repository = repository;

  Future<Either<Failure, Verse>> execute(String verseId) =>
      _repository.getVerseById(verseId);
}
