import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/data/datasources/local/app_database_provider.dart';
import 'package:sanatan_guide/data/datasources/local/daos/learning_dao.dart';
import 'package:sanatan_guide/data/repositories/learning_repository.dart';
import 'package:sanatan_guide/domain/entities/learning_module.dart';
import 'package:sanatan_guide/domain/repositories/i_learning_repository.dart';
import 'package:sanatan_guide/domain/usecases/complete_module_usecase.dart';
import 'package:sanatan_guide/domain/usecases/get_module_detail_usecase.dart';
import 'package:sanatan_guide/domain/usecases/get_modules_usecase.dart';

part 'learning_provider.g.dart';

// ── DI providers ──────────────────────────────────────────────────────────

@riverpod
Future<LearningDao> learningDao(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.learningDao;
}

@riverpod
Future<ILearningRepository> learningRepository(Ref ref) async {
  final dao = await ref.watch(learningDaoProvider.future);
  return LearningRepository(dao: dao);
}

@riverpod
Future<GetModulesUseCase> getModulesUseCase(Ref ref) async {
  final repo = await ref.watch(learningRepositoryProvider.future);
  return GetModulesUseCase(repository: repo);
}

@riverpod
Future<GetModuleDetailUseCase> getModuleDetailUseCase(Ref ref) async {
  final repo = await ref.watch(learningRepositoryProvider.future);
  return GetModuleDetailUseCase(repository: repo);
}

@riverpod
Future<CompleteModuleUseCase> completeModuleUseCase(Ref ref) async {
  final repo = await ref.watch(learningRepositoryProvider.future);
  return CompleteModuleUseCase(repository: repo);
}

// ── Feature providers ─────────────────────────────────────────────────────

/// All modules with user progress — used by the learning path screen.
@riverpod
Future<Either<Failure, List<LearningModule>>> modules(Ref ref) async {
  final useCase = await ref.watch(getModulesUseCaseProvider.future);
  return useCase.execute();
}

/// Full detail for one module — used by the card stack reader.
/// Family keyed by moduleId.
@riverpod
Future<Either<Failure, ModuleDetail>> moduleDetail(
  Ref ref,
  String moduleId,
) async {
  final useCase = await ref.watch(getModuleDetailUseCaseProvider.future);
  return useCase.execute(moduleId);
}
