import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/core/services/notification_service.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/data/datasources/local/app_database_provider.dart';
import 'package:sanatan_guide/data/datasources/local/daos/scripture_dao.dart';
import 'package:sanatan_guide/data/datasources/remote/bhagavad_gita_remote_datasource.dart';
import 'package:sanatan_guide/data/repositories/scripture_repository.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/domain/repositories/i_scripture_repository.dart';
import 'package:sanatan_guide/domain/usecases/get_verse_of_day_usecase.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/notification_time_provider.dart';

part 'verse_of_day_provider.g.dart';

// ── Dependency providers ──────────────────────────────────────────────────

/// Provides [ScriptureDao] once the DB is ready.
@riverpod
Future<ScriptureDao> scriptureDao(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.scriptureDao;
}

/// Remote API for Bhagavad Gita when verses are not bundled in SQLite.
@riverpod
BhagavadGitaRemoteDataSource bhagavadGitaRemoteDataSource(Ref ref) {
  return BhagavadGitaRemoteDataSource();
}

/// Provides [IScriptureRepository] backed by the local DB.
@riverpod
Future<IScriptureRepository> scriptureRepository(Ref ref) async {
  final dao = await ref.watch(scriptureDaoProvider.future);
  final gitaRemote = ref.watch(bhagavadGitaRemoteDataSourceProvider);
  return ScriptureRepository(dao: dao, gitaRemote: gitaRemote);
}

/// Provides [GetVerseOfDayUseCase] ready to execute.
@riverpod
Future<GetVerseOfDayUseCase> getVerseOfDayUseCase(Ref ref) async {
  final repo = await ref.watch(scriptureRepositoryProvider.future);
  return GetVerseOfDayUseCase(repository: repo);
}

// ── Feature provider ─────────────────────────────────────────────────────

/// The verse displayed on the Home screen today.
/// KeepAlive — verse doesn't change within a session; avoids
/// unnecessary re-fetches on tab switches.
@Riverpod(keepAlive: true)
Future<Either<Failure, Verse>> verseOfDay(Ref ref) async {
  final useCase = await ref.watch(getVerseOfDayUseCaseProvider.future);
  final result = await useCase.execute();

  // User-set time + enabled flag from Settings. Watching them here is fine
  // because verseOfDay rebuilds when either pref changes — the schedule
  // call below re-fires with fresh hour/minute or cancels outright.
  final enabled = ref.watch(notificationEnabledProvider);
  final time = ref.watch(notificationTimeProvider);

  // Schedule tomorrow's notification when today's verse loads successfully.
  // This ensures the notification content always matches today's verse.
  // Fire-and-forget — notification failure must not affect verse display.
  result.fold(
    (_) {}, // failure — skip notification scheduling
    (verse) {
      if (!enabled) {
        NotificationService.cancelDailyNotification();
        return;
      }
      // Build notification content
      final title = '${verse.scripture.displayName} · ${getVerseLabel(verse)}';

      // Truncate primary text to ~100 chars for notification body
      final en = verse.english?.trim();
      final sk = verse.sanskrit.trim();
      final rawBody = (en != null && en.isNotEmpty)
          ? en
          : (sk.isNotEmpty ? sk : 'Text not available for this verse');
      final body =
          rawBody.length > 100 ? '${rawBody.substring(0, 97)}…' : rawBody;

      // Schedule — unawaited intentionally (fire and forget)
      NotificationService.scheduleDailyVerseNotification(
        verseId: verse.id,
        title: title,
        body: body,
        hour: time.hour,
        minute: time.minute,
      );
    },
  );

  return result;
}
