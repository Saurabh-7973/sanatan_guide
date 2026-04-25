import 'package:fpdart/fpdart.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';

/// Abstract contract for all scripture data access.
/// Implemented in data/repositories/scripture_repository.dart.
/// Domain layer depends on this interface — never on the implementation.
abstract interface class IScriptureRepository {
  /// Returns the verse designated for today.
  /// The implementation determines which verse based on day-of-year seeding.
  /// Returns [NotFoundFailure] if the DB has no verses for this scripture yet.
  Future<Either<Failure, Verse>> getVerseOfDay();

  /// Returns a single verse by its composite ID (e.g. 'BG.1.1').
  Future<Either<Failure, Verse>> getVerseById(String id);

  /// Returns all verses for a given chapter.
  /// [bookNum] selects a book/kanda/skanda when the scripture uses [book_num].
  Future<Either<Failure, List<Verse>>> getChapter({
    required Scripture scripture,
    required int chapterNum,
    int? bookNum,
  });

  /// Full-text search across sanskrit, hindi, english, transliteration.
  /// Returns empty list (not failure) if no results.
  Future<Either<Failure, List<Verse>>> search(String query);

  /// Increments the read count for a verse.
  /// Fire-and-forget in the use case — failures are logged, not surfaced.
  Future<Either<Failure, Unit>> incrementReadCount(String verseId);

  /// Marks a verse as read for progress tracking (increments read_count).
  Future<void> markVerseRead(String verseId);

  /// Total verse count in a chapter (for completion detection).
  Future<int> getChapterVerseCount({
    required String scriptureCode,
    required int chapterNum,
    int? bookNum,
  });

  /// How many verses in a chapter have been read at least once.
  Future<int> getChapterReadCount({
    required String scriptureCode,
    required int chapterNum,
    int? bookNum,
  });

  /// Updates the personal note text for a verse.
  /// Pass null to clear the note.
  Future<Either<Failure, Unit>> updateVerseNote(
    String verseId,
    String? noteText,
  );

  /// Toggles bookmark for [verseId] and returns the verse with updated flag.
  Future<Either<Failure, Verse>> toggleBookmark(String verseId);

  /// Reactive stream of verse of the day — updates at midnight.
  Stream<Either<Failure, Verse>> watchVerseOfDay();
}
