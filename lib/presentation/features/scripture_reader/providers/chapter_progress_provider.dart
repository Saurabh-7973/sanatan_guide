import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanatan_guide/data/datasources/local/app_database_provider.dart';

part 'chapter_progress_provider.g.dart';

/// Returns how many verses have been read in a given chapter.
@riverpod
Future<int> chapterReadCount(
  Ref ref,
  String scriptureCode,
  int chapterNum,
  int? bookNum,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.scriptureDao.getReadVerseCountInChapter(
    scriptureCode: scriptureCode,
    chapterNum: chapterNum,
    bookNum: bookNum,
  );
}
