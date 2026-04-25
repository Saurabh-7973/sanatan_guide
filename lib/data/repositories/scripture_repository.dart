import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';
import 'package:sanatan_guide/data/datasources/local/daos/scripture_dao.dart';
import 'package:sanatan_guide/data/datasources/remote/bhagavad_gita_remote_datasource.dart';
import 'package:sanatan_guide/data/models/verse_mapper.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/domain/repositories/i_scripture_repository.dart';

/// Concrete implementation of [IScriptureRepository].
/// Source of truth: local Drift DB (offline-first).
/// Remote API calls added in a later phase.
final class ScriptureRepository implements IScriptureRepository {
  final ScriptureDao _dao;
  final BhagavadGitaRemoteDataSource? _gitaRemote;
  ScriptureRepository({
    required ScriptureDao dao,
    BhagavadGitaRemoteDataSource? gitaRemote,
  })  : _dao = dao,
        _gitaRemote = gitaRemote;

  void _recordNonFatal(String method, Object error, StackTrace st) {
    AppLogger.instance.e('ScriptureRepository.$method failed', error, st);
    try {
      FirebaseCrashlytics.instance
          .recordError(error, st, reason: 'ScriptureRepository.$method');
    } catch (_) {
      // Firebase not initialized (e.g. in tests) — skip crash reporting.
    }
  }

  @override
  Future<Either<Failure, Verse>> getVerseOfDay() async {
    try {
      final data = await _dao.getVerseOfDay();
      if (data == null) {
        return const Left(
          NotFoundFailure('No verses available for today.'),
        );
      }
      return Right(VerseMapper.fromTableData(data));
    } catch (e, st) {
      _recordNonFatal('getVerseOfDay', e, st);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Verse>> getVerseById(String id) async {
    try {
      FirebaseCrashlytics.instance.log('Opening verse $id');
    } catch (_) {}
    try {
      final data = await _dao.getVerseById(id);
      if (data != null) {
        return Right(VerseMapper.fromTableData(data));
      }
      final remote = _gitaRemote;
      final parts = id.split('.');
      if (remote != null &&
          parts.isNotEmpty &&
          parts[0].toUpperCase() == 'BG') {
        return remote.fetchVerseByCompositeId(id);
      }
      return Left(NotFoundFailure('Verse not found: $id'));
    } catch (e, st) {
      _recordNonFatal('getVerseById', e, st);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Verse>>> getChapter({
    required Scripture scripture,
    required int chapterNum,
    int? bookNum,
  }) async {
    try {
      final rows = await _dao.getChapter(
        scriptureCode: scripture.code,
        chapterNum: chapterNum,
        bookNum: bookNum,
      );
      return Right(rows.map(VerseMapper.fromTableData).toList());
    } catch (e, st) {
      _recordNonFatal('getChapter', e, st);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Verse>>> search(String query) async {
    try {
      FirebaseCrashlytics.instance.log('Search: "$query"');
    } catch (_) {}
    try {
      if (query.trim().isEmpty) return const Right([]);
      final rows = await _dao.search(query.trim());
      return Right(rows.map(VerseMapper.fromTableData).toList());
    } catch (e, st) {
      _recordNonFatal('search', e, st);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> incrementReadCount(String verseId) async {
    try {
      await _dao.incrementReadCount(verseId);
      return const Right(unit);
    } catch (e, st) {
      _recordNonFatal('incrementReadCount', e, st);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<void> markVerseRead(String verseId) async {
    try {
      await _dao.incrementReadCount(verseId);
    } catch (e, st) {
      AppLogger.instance.w('markVerseRead failed for $verseId', e, st);
    }
  }

  @override
  Future<int> getChapterVerseCount({
    required String scriptureCode,
    required int chapterNum,
    int? bookNum,
  }) =>
      _dao.getTotalVerseCountInChapter(
        scriptureCode: scriptureCode,
        chapterNum: chapterNum,
        bookNum: bookNum,
      );

  @override
  Future<int> getChapterReadCount({
    required String scriptureCode,
    required int chapterNum,
    int? bookNum,
  }) =>
      _dao.getReadVerseCountInChapter(
        scriptureCode: scriptureCode,
        chapterNum: chapterNum,
        bookNum: bookNum,
      );

  @override
  Future<Either<Failure, Unit>> updateVerseNote(
    String verseId,
    String? noteText,
  ) async {
    try {
      await _dao.updateNoteText(verseId, noteText);
      return const Right(unit);
    } catch (e, st) {
      _recordNonFatal('updateVerseNote', e, st);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Verse>> toggleBookmark(String verseId) async {
    try {
      final data = await _dao.toggleBookmark(verseId);
      if (data == null) {
        return Left(NotFoundFailure('Verse not found: $verseId'));
      }
      return Right(VerseMapper.fromTableData(data));
    } catch (e, st) {
      _recordNonFatal('toggleBookmark', e, st);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, Verse>> watchVerseOfDay() {
    return Stream.fromFuture(getVerseOfDay());
  }
}
