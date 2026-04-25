# Sanatan Guide — Architecture Reference
> Keep this open in Cursor as a second tab while building.

## Folder Structure (complete)

```
sanatan_guide/
├── .cursor/rules/cursorrules.mdc   ← Cursor AI rules (project rules; applied per Cursor settings)
├── analysis_options.yaml           ← Strict linting
├── pubspec.yaml
│
├── lib/
│   ├── main.dart                   ← App entry point, Firebase init, ProviderScope
│   ├── app.dart                    ← MaterialApp.router setup
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart  ← App-wide constants (pagination size, etc.)
│   │   │   ├── app_strings.dart    ← All hardcoded strings (English default)
│   │   │   └── asset_paths.dart    ← Asset path constants
│   │   ├── errors/
│   │   │   ├── failures.dart       ← sealed class Failure + subclasses
│   │   │   └── exceptions.dart     ← App-specific exceptions
│   │   ├── extensions/
│   │   │   ├── string_extensions.dart
│   │   │   ├── context_extensions.dart
│   │   │   └── either_extensions.dart
│   │   ├── router/
│   │   │   ├── app_router.dart     ← GoRouter config, all routes defined here
│   │   │   └── app_routes.dart     ← Route name constants
│   │   └── utils/
│   │       ├── app_logger.dart     ← Logger singleton
│   │       └── date_utils.dart     ← Panchang / tithi date helpers
│   │
│   ├── domain/                     ← PURE DART — zero Flutter imports
│   │   ├── entities/
│   │   │   ├── verse.dart          ← Verse entity (freezed)
│   │   │   ├── chapter.dart
│   │   │   ├── scripture.dart      ← Scripture enum + entity
│   │   │   ├── learning_module.dart
│   │   │   ├── user_progress.dart  ← streak, completion %, bookmarks
│   │   │   └── festival.dart
│   │   ├── repositories/           ← Abstract interfaces
│   │   │   ├── i_scripture_repository.dart
│   │   │   ├── i_learning_repository.dart
│   │   │   ├── i_progress_repository.dart
│   │   │   └── i_festival_repository.dart
│   │   └── usecases/
│   │       ├── get_verse_usecase.dart
│   │       ├── get_chapter_usecase.dart
│   │       ├── search_scriptures_usecase.dart
│   │       ├── get_verse_of_day_usecase.dart
│   │       ├── mark_verse_bookmark_usecase.dart
│   │       ├── update_learning_progress_usecase.dart
│   │       ├── get_user_streak_usecase.dart
│   │       └── get_festivals_usecase.dart
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   ├── app_database.dart       ← @DriftDatabase root
│   │   │   │   ├── tables/
│   │   │   │   │   ├── verses_table.dart
│   │   │   │   │   ├── chapters_table.dart
│   │   │   │   │   ├── modules_table.dart
│   │   │   │   │   └── progress_table.dart
│   │   │   │   └── daos/
│   │   │   │       ├── scripture_dao.dart
│   │   │   │       ├── progress_dao.dart
│   │   │   │       └── festival_dao.dart
│   │   │   └── remote/
│   │   │       └── gita_api_client.dart    ← Dio client for vedicscriptures API
│   │   ├── models/                         ← DTOs (freezed + json_serializable)
│   │   │   ├── verse_dto.dart
│   │   │   ├── chapter_dto.dart
│   │   │   └── festival_dto.dart
│   │   └── repositories/                  ← Implements domain interfaces
│   │       ├── scripture_repository.dart
│   │       ├── learning_repository.dart
│   │       └── progress_repository.dart
│   │
│   └── presentation/
│       ├── theme/
│       │   ├── app_theme.dart      ← ThemeData light + dark
│       │   ├── app_colors.dart     ← All colour constants
│       │   ├── app_typography.dart ← All TextStyle definitions
│       │   └── app_spacing.dart    ← Spacing scale (4pt grid)
│       ├── shared/
│       │   └── widgets/
│       │       ├── sanskrit_text.dart     ← SanskritText widget (Tiro font, correct sizing)
│       │       ├── verse_card.dart        ← Shareable verse card
│       │       ├── loading_indicator.dart
│       │       ├── error_widget.dart
│       │       └── streak_badge.dart
│       └── features/
│           ├── onboarding/
│           │   ├── pages/
│           │   │   └── onboarding_page.dart
│           │   ├── widgets/
│           │   │   └── user_type_selector.dart
│           │   └── providers/
│           │       └── onboarding_provider.dart
│           ├── home/
│           │   ├── pages/home_page.dart
│           │   ├── widgets/
│           │   │   ├── verse_of_day_card.dart
│           │   │   ├── panchang_summary_card.dart
│           │   │   ├── streak_display.dart
│           │   │   └── festival_countdown_card.dart
│           │   └── providers/home_provider.dart
│           ├── scripture_reader/
│           │   ├── pages/
│           │   │   ├── scripture_reader_page.dart
│           │   │   └── verse_detail_page.dart
│           │   ├── widgets/
│           │   │   ├── verse_display.dart
│           │   │   ├── translation_panel.dart
│           │   │   └── audio_player_bar.dart
│           │   └── providers/
│           │       ├── scripture_reader_provider.dart
│           │       └── audio_player_provider.dart  ← Global, non-dispose
│           ├── learning_path/
│           │   ├── pages/
│           │   │   ├── learning_path_page.dart
│           │   │   └── module_detail_page.dart
│           │   ├── widgets/
│           │   │   ├── module_card.dart
│           │   │   └── progress_bar.dart
│           │   └── providers/
│           │       └── learning_path_provider.dart
│           ├── search/
│           │   ├── pages/search_page.dart
│           │   ├── widgets/search_result_item.dart
│           │   └── providers/search_provider.dart
│           ├── festivals/
│           │   ├── pages/
│           │   │   ├── festivals_page.dart
│           │   │   └── festival_detail_page.dart
│           │   └── providers/festivals_provider.dart
│           └── settings/
│               ├── pages/settings_page.dart
│               └── providers/settings_provider.dart
│
└── test/                           ← Mirrors lib/ structure
    ├── domain/
    │   ├── entities/
    │   └── usecases/
    ├── data/
    │   ├── datasources/
    │   └── repositories/
    └── presentation/
        └── features/
```

---

## Layer Dependency Rules (STRICT)

```
presentation → domain  ✅
presentation → data    ❌  Never. Only through domain interfaces via Riverpod DI.
data → domain          ✅  Implements domain interfaces
domain → data          ❌  Never. Domain knows nothing about data.
domain → presentation  ❌  Never.
core → anything        ❌  Core is standalone, no app layer imports
```

---

## State Machine for AsyncNotifier

Every feature notifier should handle these states explicitly:
```dart
// ✅ Correct — explicit loading/error/data
final class VerseReaderNotifier extends AutoDisposeAsyncNotifier<VerseState> {
  @override
  Future<VerseState> build() async {
    // Runs on first watch. Re-runs when dependencies change.
    final chapter = ref.watch(selectedChapterProvider);
    final verses = await ref.watch(
      getChapterUseCaseProvider.notifier
    ).execute(GetChapterParams(chapterId: chapter));
    
    return verses.fold(
      (failure) => throw failure,     // AsyncValue.error
      (data) => VerseState(verses: data),
    );
  }
}

// In the widget:
ref.watch(verseReaderProvider).when(
  loading: () => const LoadingIndicator(),
  error: (err, stack) => AppErrorWidget(failure: err as Failure),
  data: (state) => VerseList(verses: state.verses),
);
```

---

## DI Pattern (how providers wire together)

```dart
// 1. Data source (in data/datasources/)
@riverpod
ScriptureDao scriptureDao(ScriptureDaoRef ref) {
  return ref.watch(appDatabaseProvider).scriptureDao;
}

// 2. Repository (in data/repositories/)
@riverpod
IScriptureRepository scriptureRepository(ScriptureRepositoryRef ref) {
  return ScriptureRepository(
    localDataSource: ref.watch(scriptureDaoProvider),
    remoteDataSource: ref.watch(gitaApiClientProvider),
  );
}

// 3. Use case (in domain/usecases/ — wired in presentation/features/*/providers/)
@riverpod
GetVerseUseCase getVerseUseCase(GetVerseUseCaseRef ref) {
  return GetVerseUseCase(
    repository: ref.watch(scriptureRepositoryProvider),
  );
}

// 4. Notifier consumes use case
@riverpod
class VerseReaderNotifier extends AutoDisposeAsyncNotifier<VerseState> {
  @override
  Future<VerseState> build() async {
    final useCase = ref.watch(getVerseUseCaseProvider);
    // ...
  }
}
```

---

## TDD Workflow for Each Feature

```
1. Write entity (domain/entities/) — data class, freezed, no logic
2. Write repository interface (domain/repositories/) — abstract methods
3. Write use case (domain/usecases/) — single public execute() method
4. Write use case TEST first (test/domain/usecases/) — mock the repo
5. Implement use case to make test pass
6. Write DAO (data/datasources/local/) — Drift queries
7. Write repository impl (data/repositories/) — maps DTO ↔ entity
8. Write repository TEST (test/data/repositories/) — mock DAO
9. Wire Riverpod providers
10. Write Notifier + Notifier TEST
11. Build UI — widget tests for critical interactions
```

---

## Cursor + Claude Division of Labour

| Task | Use | Why |
|------|-----|-----|
| Boilerplate files (DTO, entity skeleton) | Cursor | Mechanical, pattern-based |
| Architecture decisions | Claude | Reasoning required |
| Drift schema + complex queries | Claude | Gets SQLite/FTS5 right |
| Riverpod providers + wiring | Cursor (with rules) | Mechanical with good rules |
| Complex state machines | Claude | Logic-heavy |
| Audio player integration | Claude | Non-obvious edge cases |
| Test writing | Both | Cursor scaffold, Claude reviews logic |
| Debugging production bugs | Claude | Root cause reasoning |
| UI widget code | Cursor | Fast, mostly mechanical |
| Sanskrit rendering edge cases | Claude | Research-backed |
| Performance optimisation | Claude | Profiling + reasoning |
