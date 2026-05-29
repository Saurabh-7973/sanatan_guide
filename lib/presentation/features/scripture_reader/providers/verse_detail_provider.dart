import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanatan_guide/core/constants/preferences_keys.dart';
import 'package:sanatan_guide/core/constants/bhagavad_gita_chapters.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/data/datasources/local/app_database_provider.dart';
import 'package:sanatan_guide/domain/entities/commentary.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/domain/entities/verse_explanation.dart';
import 'package:sanatan_guide/domain/usecases/get_verse_by_id_usecase.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';

part 'verse_detail_provider.g.dart';

/// Prev/next when Gita verses are not stored locally (API-only); IDs still BG.ch.v.
({String? prevId, String? nextId})? _adjacentBhagavadGitaIds(String verseId) {
  final parts = verseId.split('.');
  if (parts.length != 3 || parts[0].toUpperCase() != 'BG') return null;
  final ch = int.tryParse(parts[1]);
  final v = int.tryParse(parts[2]);
  if (ch == null || v == null || ch < 1 || ch > 18) return null;

  String? prevId;
  if (v > 1) {
    prevId = 'BG.$ch.${v - 1}';
  } else if (ch > 1) {
    final prevMax = BhagavadGitaChapters.byNumber(ch - 1).verseCount;
    prevId = 'BG.${ch - 1}.$prevMax';
  }

  String? nextId;
  final maxV = BhagavadGitaChapters.byNumber(ch).verseCount;
  if (v < maxV) {
    nextId = 'BG.$ch.${v + 1}';
  } else if (ch < 18) {
    nextId = 'BG.${ch + 1}.1';
  }
  return (prevId: prevId, nextId: nextId);
}

// ── Shared Preferences ────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) =>
    SharedPreferences.getInstance();

// ── Transliteration Toggle ────────────────────────────────────────────────
// Persisted preference: whether to show IAST transliteration on verse detail.


@riverpod
class TransliterationEnabled extends _$TransliterationEnabled {
  @override
  Future<bool> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return prefs.getBool(PrefsKeys.transliterationEnabled) ?? false;
  }

  Future<void> toggle() async {
    final current = await future;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final next = !current;
    await prefs.setBool(PrefsKeys.transliterationEnabled, next);
    state = AsyncData(next);
  }
}

// ── Use case providers ────────────────────────────────────────────────────

@riverpod
Future<GetVerseByIdUseCase> getVerseByIdUseCase(Ref ref) async {
  final repo = await ref.watch(scriptureRepositoryProvider.future);
  return GetVerseByIdUseCase(repository: repo);
}

// ── Verse detail (family — keyed by verseId) ──────────────────────────────

@riverpod
Future<Either<Failure, Verse>> verseDetail(Ref ref, String verseId) async {
  final useCase = await ref.watch(getVerseByIdUseCaseProvider.future);
  return useCase.execute(verseId);
}

/// Optional AI explanation row for this verse (null if not generated yet).
@riverpod
Future<VerseExplanation?> verseExplanation(Ref ref, String verseId) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final row = await db.scriptureDao.getVerseExplanationByVerseId(verseId);
  if (row == null) {
    return null;
  }
  return VerseExplanation(
    verseId: row.verseId,
    explanationText: row.explanationText,
    generatedAt: row.generatedAt,
    modelVersion: row.modelVersion,
  );
}

/// Scholarly commentaries for this verse (empty list when none seeded).
@riverpod
Future<List<Commentary>> verseCommentaries(Ref ref, String verseId) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final rows = await db.scriptureDao.getCommentariesByVerseId(verseId);
  return [
    for (final r in rows)
      Commentary(
        id: r.id,
        verseId: r.verseId,
        tradition: r.tradition,
        author: r.author,
        textEnglish: r.textEnglish,
        textSanskrit: r.textSanskrit,
        translator: r.translator,
        sourceUrl: r.sourceUrl,
        license: r.license,
        createdAt: r.createdAt,
      ),
  ];
}

// ── Verse position in chapter ─────────────────────────────────────────────
// 1-based index of the verse within its chapter + the chapter's verse count,
// for the verse-detail progress rail. Null when the position can't be
// determined (single-unit scriptures, or no chapter metadata).

@riverpod
Future<({int index, int total})?> verseChapterPosition(
  Ref ref,
  String verseId,
) async {
  final parts = verseId.split('.');
  // Bhagavad Gītā: contiguous 1..N verses per chapter, metadata is static.
  if (parts.length == 3 && parts[0].toUpperCase() == 'BG') {
    final ch = int.tryParse(parts[1]);
    final v = int.tryParse(parts[2]);
    if (ch != null && v != null && ch >= 1 && ch <= 18) {
      final total = BhagavadGitaChapters.byNumber(ch).verseCount;
      if (total <= 0) return null;
      return (index: v.clamp(1, total), total: total);
    }
  }

  final db = await ref.watch(appDatabaseProvider.future);
  final row = await db.scriptureDao.getVerseById(verseId);
  if (row == null) return null;

  final verses = await db.scriptureDao.getChapter(
    scriptureCode: row.scripture,
    chapterNum: row.chapterNum,
    bookNum: row.bookNum,
  );
  if (verses.isEmpty) return null;
  // Nested texts (Ṛgveda Sukta etc.) repeat verseNum across the chapter,
  // so verseNum-sort scrambles. Match the verse-list page's logic.
  final flat = verses.map((v) => v.verseNum).toSet().length == verses.length;
  final sorted = [...verses]..sort(
      flat
          ? (a, b) => a.verseNum.compareTo(b.verseNum)
          : (a, b) => compareVerseIds(a.id, b.id),
    );
  final idx = sorted.indexWhere((e) => e.id == verseId);
  if (idx < 0) return null;
  return (index: idx + 1, total: sorted.length);
}

// ── Adjacent verse IDs ────────────────────────────────────────────────────
// Prev/next in canonical (book_num, chapter_num, verse_num, id) order in DB.

@riverpod
Future<({String? prevId, String? nextId})> adjacentVerseIds(
  Ref ref,
  String verseId,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final dao = db.scriptureDao;

  final current = await dao.getVerseById(verseId);
  if (current == null) {
    return _adjacentBhagavadGitaIds(verseId) ?? (prevId: null, nextId: null);
  }

  // Nested-id texts (RV.M.S.V, MBH.P.C.V, etc.) repeat verseNum across the
  // chapter, so the DAO's SQL ORDER BY (book_num, chapter_num, verse_num, id)
  // mis-orders them — all sukta-verse-1s cluster, then verse-2s, etc.
  // Fetch the chapter and sort by natural id order in Dart. Within-chapter
  // only; cross-Maṇḍala swipe is out of scope for v1.
  final isNested = verseId.split('.').length >= 4;
  if (isNested) {
    final verses = await dao.getChapter(
      scriptureCode: current.scripture,
      chapterNum: current.chapterNum,
      bookNum: current.bookNum,
    );
    if (verses.isEmpty) return (prevId: null, nextId: null);
    final sorted = [...verses]..sort((a, b) => compareVerseIds(a.id, b.id));
    final idx = sorted.indexWhere((e) => e.id == verseId);
    if (idx < 0) return (prevId: null, nextId: null);
    return (
      prevId: idx > 0 ? sorted[idx - 1].id : null,
      nextId: idx < sorted.length - 1 ? sorted[idx + 1].id : null,
    );
  }

  // Flat texts (Gītā, Upaniṣads, etc.) — DAO ORDER BY is correct and gives
  // cross-chapter siblings for free.
  final prevRow =
      await dao.getPrevVerse(current.scripture, verseId, current: current);
  final nextRow =
      await dao.getNextVerse(current.scripture, verseId, current: current);

  return (prevId: prevRow?.id, nextId: nextRow?.id);
}
