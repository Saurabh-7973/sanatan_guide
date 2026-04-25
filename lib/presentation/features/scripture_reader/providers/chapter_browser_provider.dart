import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/data/datasources/local/app_database_provider.dart';
import 'package:sanatan_guide/domain/entities/chapter_outline.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';

part 'chapter_browser_provider.g.dart';

// ── Chapter verse list ────────────────────────────────────────────────────
/// Fetches all verses for a given chapter.
/// Family keyed by (scriptureCode, chapterNum).
/// AutoDispose — frees memory when the user navigates away from the chapter.

@riverpod
Future<Either<Failure, List<Verse>>> chapterVerses(
  Ref ref,
  String scriptureCode,
  int chapterNum,
  int? bookNum,
) async {
  if (scriptureCode == 'bhagavad_gita') {
    if (bookNum != null) {
      return const Left(
        ValidationFailure('Bhagavad Gita has no book dimension.'),
      );
    }
    final repo = await ref.watch(scriptureRepositoryProvider.future);
    final local = await repo.getChapter(
      scripture: Scripture.bhagavadGita,
      chapterNum: chapterNum,
      bookNum: null,
    );
    return local.fold(
      (_) async => ref
          .read(bhagavadGitaRemoteDataSourceProvider)
          .fetchChapter(chapterNum),
      (verses) async {
        if (verses.isNotEmpty) {
          return Right(verses);
        }
        return ref
            .read(bhagavadGitaRemoteDataSourceProvider)
            .fetchChapter(chapterNum);
      },
    );
  }

  final repo = await ref.watch(scriptureRepositoryProvider.future);
  final scripture = ScriptureX.fromCode(scriptureCode);
  return repo.getChapter(
    scripture: scripture,
    chapterNum: chapterNum,
    bookNum: bookNum,
  );
}

/// Distinct chapters for a scripture (book + chapter + label from first verse).
@riverpod
Future<List<ChapterOutline>> chapterOutlines(
  Ref ref,
  String scriptureCode,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.scriptureDao.getChapterOutlines(scriptureCode);
}
