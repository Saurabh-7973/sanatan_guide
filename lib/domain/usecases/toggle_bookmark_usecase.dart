import 'package:fpdart/fpdart.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/domain/repositories/i_scripture_repository.dart';

/// Toggles bookmark state for a verse and returns the updated [Verse].
/// Returns [NotFoundFailure] if the verse id is unknown.
final class ToggleBookmarkUseCase {
  final IScriptureRepository _repository;
  const ToggleBookmarkUseCase({required IScriptureRepository repository})
      : _repository = repository;

  Future<Either<Failure, Verse>> execute(String verseId) =>
      _repository.toggleBookmark(verseId);
}
