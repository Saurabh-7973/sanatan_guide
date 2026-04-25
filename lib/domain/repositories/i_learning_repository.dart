import 'package:fpdart/fpdart.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/domain/entities/learning_module.dart';

/// Abstract contract for all learning data access.
abstract interface class ILearningRepository {
  /// Returns all modules ordered by level then sequence.
  /// Includes user progress (isCompleted, cardsRead) merged in.
  Future<Either<Failure, List<LearningModule>>> getModules();

  /// Returns full detail for one module including all cards, anchor, reflection.
  Future<Either<Failure, ModuleDetail>> getModuleDetail(String moduleId);

  /// Records that the user has read a specific card.
  /// Idempotent — calling it twice has the same effect as once.
  Future<Either<Failure, Unit>> markCardRead({
    required String moduleId,
    required int cardSequence,
    required int totalCards,
  });

  /// Marks a module as fully completed. Sets completedAt timestamp.
  Future<Either<Failure, Unit>> completeModule(String moduleId);

  /// Reactive stream of all modules with live progress.
  Stream<Either<Failure, List<LearningModule>>> watchModules();
}
