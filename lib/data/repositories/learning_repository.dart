import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';
import 'package:sanatan_guide/data/datasources/local/daos/learning_dao.dart';
import 'package:sanatan_guide/data/models/learning_module_mapper.dart';
import 'package:sanatan_guide/domain/entities/learning_module.dart';
import 'package:sanatan_guide/domain/repositories/i_learning_repository.dart';

/// Local Drift implementation of [ILearningRepository].
final class LearningRepository implements ILearningRepository {
  LearningRepository({required LearningDao dao}) : _dao = dao;

  final LearningDao _dao;
  void _recordNonFatal(String method, Object error, StackTrace st) {
    AppLogger.instance.e('LearningRepository.$method failed', error, st);
    try {
      FirebaseCrashlytics.instance
          .recordError(error, st, reason: 'LearningRepository.$method');
    } catch (_) {
      // Firebase not initialized (e.g. in tests) — skip crash reporting.
    }
  }

  Future<Either<Failure, List<LearningModule>>> _loadModules() async {
    try {
      final rows = await _dao.getAllModulesOrdered();
      final progressList = await _dao.getAllProgress();
      final progressById = {
        for (final p in progressList) p.moduleId: p,
      };
      return Right(
        rows.map((row) {
          final p = progressById[row.id];
          return LearningModuleMapper.moduleWithProgress(
            row,
            cardsRead: p?.cardsRead ?? 0,
            isCompleted: p?.isCompleted ?? false,
          );
        }).toList(),
      );
    } catch (e, st) {
      _recordNonFatal('_loadModules', e, st);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LearningModule>>> getModules() => _loadModules();

  @override
  Future<Either<Failure, ModuleDetail>> getModuleDetail(String moduleId) async {
    try {
      FirebaseCrashlytics.instance.log('Opening module $moduleId');
    } catch (_) {}
    try {
      final row = await _dao.getModuleById(moduleId);
      if (row == null) {
        return Left(NotFoundFailure('Module not found: $moduleId'));
      }
      final progress = await _dao.getProgress(moduleId);
      final module = LearningModuleMapper.moduleWithProgress(
        row,
        cardsRead: progress?.cardsRead ?? 0,
        isCompleted: progress?.isCompleted ?? false,
      );
      final cardRows = await _dao.getCardsForModule(moduleId);
      final cards =
          cardRows.map(LearningModuleMapper.fromCardRow).toList(growable: false);
      final extras = await _dao.getExtrasForModule(moduleId);
      return Right(
        ModuleDetail(
          module: module,
          cards: cards,
          anchorVerseId: extras?.anchorVerseId,
          anchorVerseNote: extras?.anchorVerseNote,
          reflectionQuestion: extras?.reflectionQuestion,
        ),
      );
    } catch (e, st) {
      _recordNonFatal('getModuleDetail', e, st);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markCardRead({
    required String moduleId,
    required int cardSequence,
    required int totalCards,
  }) async {
    try {
      await _dao.markCardRead(
        moduleId: moduleId,
        cardSequence: cardSequence,
      );
      return const Right(unit);
    } catch (e, st) {
      _recordNonFatal('markCardRead', e, st);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> completeModule(String moduleId) async {
    try {
      await _dao.completeModule(moduleId);
      return const Right(unit);
    } catch (e, st) {
      _recordNonFatal('completeModule', e, st);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<LearningModule>>> watchModules() {
    late final StreamController<Either<Failure, List<LearningModule>>> controller;
    StreamSubscription<void>? subModules;
    StreamSubscription<void>? subProgress;

    Future<void> push() async {
      final result = await _loadModules();
      if (!controller.isClosed) {
        controller.add(result);
      }
    }

    controller = StreamController<Either<Failure, List<LearningModule>>>(
      onListen: () {
        push();
        subModules = _dao.watchModulesOrProgress().listen((_) => push());
        subProgress = _dao.watchProgressChanges().listen((_) => push());
      },
      onCancel: () {
        subModules?.cancel();
        subProgress?.cancel();
        if (!controller.isClosed) {
          controller.close();
        }
      },
    );

    return controller.stream;
  }
}
