import 'package:fpdart/fpdart.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/domain/entities/learning_module.dart';
import 'package:sanatan_guide/domain/repositories/i_learning_repository.dart';

/// Returns full module detail for the card stack reader.
final class GetModuleDetailUseCase {
  final ILearningRepository _repository;
  const GetModuleDetailUseCase({required ILearningRepository repository})
      : _repository = repository;

  Future<Either<Failure, ModuleDetail>> execute(String moduleId) =>
      _repository.getModuleDetail(moduleId);
}
