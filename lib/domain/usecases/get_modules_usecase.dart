import 'package:fpdart/fpdart.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/domain/entities/learning_module.dart';
import 'package:sanatan_guide/domain/repositories/i_learning_repository.dart';

/// Returns all learning modules with user progress merged in.
final class GetModulesUseCase {
  final ILearningRepository _repository;
  const GetModulesUseCase({required ILearningRepository repository})
      : _repository = repository;

  Future<Either<Failure, List<LearningModule>>> execute() =>
      _repository.getModules();
}
