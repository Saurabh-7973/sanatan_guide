import 'package:fpdart/fpdart.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/domain/repositories/i_learning_repository.dart';

/// Marks a module as completed. Called when the user reaches the final card.
final class CompleteModuleUseCase {
  final ILearningRepository _repository;
  const CompleteModuleUseCase({required ILearningRepository repository})
      : _repository = repository;

  Future<Either<Failure, Unit>> execute(String moduleId) =>
      _repository.completeModule(moduleId);
}
