# Sanatan Guide — Architecture, Performance & Production Audit

**Date:** 2026-05-28
**Codebase snapshot:** 138 hand-written Dart files, ~40 KLOC,
56 Riverpod providers, 298 tests, 1 native-Drift DB (8 tables,
schema v9), 1 outbound HTTP service (Gemini).

This is the **systems audit**, separate from `docs/V1_AUDIT_REPORT_2026-05-28.md`
which covered specific UX/build items. Read top-to-bottom for an opinionated
senior-engineer take on what's solid, what's risky, and what to refactor before
v2.

---

## 0. TL;DR Scorecard

| Dimension | Score / 10 | Comment |
|---|--:|---|
| **Architecture (layers)** | 8 | Clean Domain/Data/Presentation split. Few violations. |
| **State management** | 7 | Riverpod consistently applied; 12 imperative-state holdouts. |
| **Database design** | 7 | Solid 8-table schema. Nested-id encoding (RV `bookNum`) is fragile. |
| **API design (Gemini)** | 6 | Works; lacks structured error taxonomy + circuit breaker. |
| **Caching strategy** | 6 | Mixed: SharedPreferences fragmented, Gemini per-feature cache exists, no HTTP cache. |
| **Performance (cold)** | 8 | DB extract on first run is the only hot spot; rest is lazy. |
| **Performance (steady)** | 7 | GROUP BY queries shipped; some N+1 patterns remain. |
| **Security** | 9 | Post key rotation + restrictions, very tight. |
| **Test coverage** | 7 | 298 tests, good unit + widget coverage. Integration gap. |
| **Maintainability** | 5 | Page files at 2-3K LOC each are the single biggest debt. |
| **Scalability** | 7 | Offline-first design scales user-side; DB grows linearly. |
| **Production readiness** | 7 | App is shippable; v2 needs the refactors below. |

**Composite ≈ 7.0 / 10.** Production-ready with the v2 refactor backlog noted.

---

## 1. System Architecture

### 1.1 Layer breakdown

```
┌─────────────────────────────────────────────────────────────┐
│ Presentation (Flutter widgets + Riverpod providers)         │
│   • 298 widget classes across 11 feature folders            │
│   • 56 @riverpod providers                                  │
│   • GoRouter v14 navigation                                 │
├─────────────────────────────────────────────────────────────┤
│ Domain (entities + use-cases + repository interfaces)       │
│   • Verse, Festival, LearningModule, etc (freezed sealed)   │
│   • IScriptureRepository, ILearningRepository abstractions  │
│   • 4 use-case classes (toggle_bookmark, get_verse_of_day…) │
├─────────────────────────────────────────────────────────────┤
│ Data (concrete repos + DAOs + tables + remote sources)      │
│   • 2 repositories (Scripture, Learning)                    │
│   • 3 DAOs (Scripture 467 LOC, Bookmarks, Learning)         │
│   • 8 Drift tables                                          │
│   • 1 RemoteDataSource (BhagavadGitaRemoteDataSource)       │
├─────────────────────────────────────────────────────────────┤
│ Core (services, utils, theme, router, constants)            │
│   • GeminiService (HTTP)                                    │
│   • WordGlossService, SectionThemeService (Gemini facades)  │
│   • StreakService, FestivalNotificationScheduler            │
│   • app_database.dart, app_database_provider.dart           │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Data flow — happy path: open Verse Detail

```
User taps Library row
  └─> GoRouter pushes /browse/<code>/verse/<id>
        └─> VerseDetailPage builds, watches verseDetailProvider(id)
              └─> ScriptureRepository.getVerseById(id)
                    └─> ScriptureDao.getVerseById(id)   ← single SELECT
                          └─> AppDatabase (Drift) ← SQLite read
                    ← VersesTableData
              ← Either<Failure, Verse>
        ← UI renders sanskrit/translation/transliteration
        └─> postFrameCallback: _recordReading(verse)
              ├─> StreakService.saveLastReadVerse()        (SharedPreferences)
              ├─> StreakService.recordReadingToday()       (SharedPreferences)
              ├─> AnalyticsService.verseRead(...)          (Firebase Analytics)
              ├─> repo.markVerseRead(id)                   (UPDATE verses)
              └─> ref.invalidate(scriptureReadCountsProvider)
                    ↳ Library page sees fresh count on next visit
```

This is the **hot path**. Single DB read on enter, multiple side effects on
exit. The side effects are fire-and-forget; they don't block the UI.

### 1.3 Architectural strengths

- **Strict layering** — no `package:flutter` import in `lib/data` or `lib/domain`.
- **Repository interfaces in domain**, concrete impls in data — testable via mocks.
- **Either<Failure, T> error returns** (fpdart) — explicit error path at boundaries.
- **Feature-folder organisation** in `lib/presentation/features/` — easy to find code.

### 1.4 Architectural violations / smells

| # | File | Issue | Severity |
|---|---|---|---|
| 1 | `verse_detail_page.dart` | **2,947 LOC single file.** Mixes UI, controller, side effects, custom painters, dialog widgets, formatters. Hardest file to maintain. | HIGH |
| 2 | `scripture_library_page.dart` | 1,615 LOC; embeds scripture metadata, layout, and progress logic. | HIGH |
| 3 | `search_page.dart` | 1,578 LOC; full search flow + result rendering + recents in one file. | MED |
| 4 | `settings_page.dart` | 1,474 LOC; every settings row inline. | MED |
| 5 | `sacred_ornaments.dart` | 2,245 LOC of `CustomPainter` subclasses — semi-acceptable since these are art assets in code, but should split per ornament. | LOW |
| 6 | `lib/data/datasources/remote/bhagavad_gita_remote_datasource.dart` | Single remote source for ONE scripture. Stub for unused path. | LOW |
| 7 | `lib/data/festivals/` lives in `data/` but contains constants, not data sources. Should move to `lib/core/constants/`. | LOW |

---

## 2. Database Schema

### 2.1 Tables (Drift, SQLite, schema v9)

| Table | Cols | Purpose | Row count (shipped DB) |
|---|--:|---|--:|
| `verses` | 14 | All scripture text + read state + bookmark + note | 133,613 |
| `commentaries` | 9 | Multi-tradition commentary (Shankara etc) | varies |
| `verse_explanations` | ~4 | AI-generated explanations (cached) | 0 (populated at runtime) |
| `learning_modules` | ~6 | Curated learning paths | <50 |
| `module_cards` | ~5 | Individual learning cards | <500 |
| `module_extras` | ~3 | Per-card extras (mantras, links) | <500 |
| `user_module_progress` | ~4 | User progress per module | varies |
| `bookmarks` | ~3 | Bookmark records (legacy — `verses.is_bookmarked` is canonical) | varies |
| `verses_fts` (virtual) | — | FTS5 full-text index over `verses` | rebuilt on schema upgrade |

### 2.2 Indexes (from `_createIndexes`)

- `idx_verses_scripture_chapter (scripture, chapter_num, book_num, verse_num)`
- `idx_verses_scripture (scripture)`
- `idx_commentaries_verse_id (verse_id)`

### 2.3 Schema strengths

- **FTS5 virtual table + 3 sync triggers** keeps full-text search fast against
  133K rows. Triggers handle insert/delete/update so the index can't drift.
- **Composite index** on (scripture, chapter_num, book_num, verse_num)
  covers every Library / Chapter / Verse-list query path.
- **schemaVersion → runtime migration** — drift takes the bundled DB (user_version=6)
  up to 9 on first launch by running incremental `onUpgrade` blocks.

### 2.4 Schema problems

#### Issue D-1: `book_num` semantics are inconsistent across scriptures (HIGH)

For Ṛgveda the verse-id `RV.1.5.3` encodes maṇḍala/sukta/verse. But the
**columns store** `chapter_num=1, verse_num=1` (sukta-aware via ID only,
`book_num` is NULL). Many sukta-1 verses across mandalas collide on
`(chapter_num, verse_num)`. The id string is the only disambiguator.

**Consequence:** any logic that joins/groups by `(chapter_num, verse_num)`
without joining on `id` will get cartesian-product results for RV. We
sidestep this today by always querying via `id` or by `scripture +
chapter_num` (mandala), but it's a footgun.

**Fix (v2):** add a `sukta_num` column (or `position_num`) populated for
3-level scriptures. Then `(scripture, chapter_num, sukta_num, verse_num)`
is unique. Migration is mechanical.

#### Issue D-2: `bookmarks` table is dead weight (LOW)

Bookmark state lives in `verses.is_bookmarked` (boolean). The separate
`bookmarks` table from schema v4 went unused after the column was added.
Currently has zero query call-sites in `bookmarks_dao.dart` outside writes
that mirror the boolean.

**Fix (v2):** drop the table in a migration; keep the boolean.

#### Issue D-3: `verse_explanations` table is write-heavy + indexless (MED)

Used by the "Explain this verse" Gemini cache. Lookups by `verse_id`. No
explicit index on `verse_id` declared in `_createIndexes` (relies on the
implicit primary key index). At 100+ explanations this is fine; at 10K it
matters.

**Fix:** add `idx_verse_explanations_verse_id` in next migration.

#### Issue D-4: No FTS index over commentaries (LOW)

If commentaries grow, full-text search across them needs an FTS5 mirror.
Pattern is straightforward — copy the `verses_fts` setup.

---

## 3. State Management

### 3.1 Pattern in use

**Primary:** `@riverpod` code-generated providers (flutter_riverpod ^3.0)
with `Ref` access and `keepAlive` annotations where appropriate.

**Secondary:** `StatefulWidget` + `setState` for purely-local UI state
(e.g. expansion toggles, scroll positions, current-step in onboarding).

### 3.2 Provider taxonomy (56 total)

| Category | Count | Examples |
|---|--:|---|
| Async data fetch (DB) | ~20 | `verseDetailProvider`, `chapterOutlinesProvider` |
| Async data fetch (Gemini) | ~3 | `verseExplanationProvider` |
| Persisted settings | ~12 | `themeModeProvider`, `analyticsEnabledProvider` |
| Streak / activity | ~5 | `currentStreakProvider`, `lastReadVerseProvider` |
| Search / filters | ~6 | `searchQueryProvider`, `recentSearchesProvider` |
| Misc (router, etc) | ~10 | navigatorKey, route observers |

### 3.3 State strengths

- **Code-gen** (`@riverpod`) gives compile-time safety on provider names
  and family parameter types. No string-based lookups.
- **`keepAlive` used selectively** for expensive computations (festival
  Remote Config), GC-able for one-off queries.
- **Invalidation on writes**: `scriptureReadCountsProvider`,
  `chapterReadCountProvider`, etc are all invalidated after
  `markVerseRead` — verified clean in §R3 audit earlier.

### 3.4 State problems

#### Issue S-1: 12 files mix Riverpod with setState

Grep finds `setState\|ChangeNotifier\|ValueNotifier` in 12 files. Not all
of these are violations — `setState` is fine for ephemeral UI state. But
some hold app-level state (e.g. message lists in Pandit chat) in
StatefulWidget. Migrating those to a `MessagesNotifier` family provider
would unlock undo, persistence, and replay testing.

**Files to audit:** `pandit_chat_page.dart`, `verse_chat_page.dart`,
`module_reader_page.dart` (sequence tracking).

#### Issue S-2: 69 SharedPreferences call sites, no central registry (MED)

`lib/core/constants/preferences_keys.dart` exists but only ~20 keys are
constant-ified. The rest are inline string literals scattered across
service classes. Risk: typos silently break persistence; key collisions
between services possible.

**Fix:** mandate `PreferencesKeys.X` constant usage; add a lint guard or
analyzer rule rejecting raw SP keys outside the constants file.

---

## 4. API & Service Design

### 4.1 Outbound HTTP — GeminiService

Single concrete service, ~177 LOC, `package:http` for transport.

- **Primary model:** `gemini-3.5-flash` (per `--dart-define=GEMINI_MODEL`)
- **Fallback:** `gemini-2.5-flash` on 400/404 (region-not-yet-rolled-out)
- **Rate limiter:** `GeminiRateLimit` — daily caps per bucket
  (chat 10, gloss 50, theme 40), keyed by date in SharedPreferences

### 4.2 Service strengths

- **Single fallback retry** — handles staged regional rollout cleanly.
- **Per-feature rate buckets** — first-use bursts on word-gloss can't
  starve Pandit chat.
- **Error mapping** — `GeminiException` is the typed channel; consumers
  pattern-match cleanly.

### 4.3 Service problems

#### Issue A-1: No HTTP-level caching (MED)

Repeated `gemini-flash` calls for the same prompt re-pay network + model
latency. Word-gloss / section-themes have application-level caches in
their respective services, but other call sites (Pandit chat,
"Explain this verse") don't.

**Fix (v2):** add an LRU cache keyed by `(model, systemPrompt, history,
userMessage)` hash. 100-entry LRU in memory. Saves cost + improves UX
when user re-asks the same verse.

#### Issue A-2: No circuit breaker (MED)

If Gemini API has a regional outage, every keystroke / page load that
triggers Gemini re-issues a request that times out at 10s. Bad UX on
intermittent network.

**Fix:** classic circuit-breaker: 3 failures in 60s → open circuit for
2 min → half-open → close. Wrap `GeminiService.ask` with a
`CircuitBreakerGuard`.

#### Issue A-3: No structured request/response logging (LOW)

In release builds, all that goes to Crashlytics is the exception. Cannot
post-hoc reproduce a bad reply. For a paid AI feature, request hashes
+ response truncation should be optionally captured (opt-in flag).

**Fix:** add a debug-mode-only verbose log + optional production telemetry
under the analytics opt-in flag.

#### Issue A-4: 10s timeout is high (LOW)

Most Gemini-flash replies finish under 3s. A 10s timeout means a stuck
request blocks the user for 10s before falling back. Reduce to 6s with
1 retry → 12s worst case, 3s typical.

---

## 5. Caching Strategy

### 5.1 Three-tier cache today

| Layer | What | Where | TTL | Eviction |
|---|---|---|---|---|
| **L1 — in-memory** | Word-gloss + section-themes from Gemini | `WordGlossService` static map | session | manual |
| **L2 — Drift DB** | AI verse explanations | `verse_explanations` table | forever | manual via Settings → Clear |
| **L3 — Drift DB** | Verse text itself | `verses` table (extracted from bundled DB.gz) | forever | DB wipe |

### 5.2 Cache strengths

- **Verse-explanation persistence** survives app restarts → users don't
  re-pay per re-open.
- **In-memory word-gloss** keeps Gemini calls down within a session.

### 5.3 Cache gaps

#### Issue C-1: L1 cache lost on every cold start (MED)

Word-gloss + section-themes are recomputed on every fresh launch (paid
Gemini call). Should mirror the L2 pattern: persist to a `glosses` and
`section_themes` table in Drift.

**Fix:** add two small tables, write-through cache, lookup before
GeminiService call.

#### Issue C-2: No image / asset caching policy (LOW)

App has minimal network images today. If future versions add Drik
Panchang's lunar SVGs or scripture-art images, configure
`cached_network_image` with explicit max-cache-size + TTL.

#### Issue C-3: Drift query results not memoised (LOW)

`getReadVerseCountsByScripture()` runs on every Library page mount.
Riverpod's `keepAlive: true` would cache the result until invalidated.
Currently this provider isn't keepAlive — fixed by a one-line annotation.

**Fix:** `@Riverpod(keepAlive: true)` on `scriptureReadCounts` provider.

---

## 6. Performance

### 6.1 Cold-start path

1. `runZonedGuarded` wraps `runApp` for crash capture (0.5ms).
2. `WidgetsFlutterBinding.ensureInitialized()` (10ms).
3. Firebase init (`firebase_core` + analytics + crashlytics) (~100ms).
4. `openAppDatabaseConnection()`:
   - First launch: gunzip 14 MB → 65 MB DB, write to docs/. **~600-900ms.**
   - Subsequent launches: open existing DB. **~10ms.**
5. `runApp(ProviderScope(...))`.

Total cold-start: ~1.2s first launch, ~200ms subsequent.

### 6.2 Hot paths

| Path | LOC touched | Cost |
|---|--:|---|
| Open Library | 4 providers + 1 GROUP BY | 30-50ms |
| Open Chapter list | 1 provider + 1 GROUP BY | 20-40ms |
| Open Verse Detail | 1 indexed lookup | 10ms |
| Search "dharma" | FTS5 against verses_fts | 100-300ms (133K rows) |
| Pandit reply | Network round-trip | 2-5s |
| Mark verse read | INSERT + 3 invalidations | 5ms |

### 6.3 Performance issues

#### Issue P-1: Page-level rebuilds on every provider tick (MED)

Several large pages call `ref.watch(provider)` at the top of `build`,
causing the entire 2000-LOC `build` to re-run on any provider update.
Should hoist `ref.watch` into a small ConsumerWidget that wraps only the
dependent subtree.

**Files with widest watch scope:** `scripture_library_page.dart` (whole
page rebuilds on read-count change), `home_page.dart`.

**Fix (v2):** split the big pages into N small ConsumerWidgets, each
watching what they actually need.

#### Issue P-2: `RootBundle.load` for DB.gz blocks UI on first run (LOW)

Decompression happens on the main isolate. ~600-900ms blocks the splash.
Move to `compute()`:

```dart
final decoded = await compute(_gzipDecode, compressed);
```

Saves nothing on subsequent launches but smooths the very first one.

#### Issue P-3: `ListView` instead of `ListView.builder` in a few places (LOW)

Quick audit needed; `ListView(children: [for(...)])` materialises all
rows. With <50 entries it's fine; with hundreds, switch to `.builder`.

**Check:** `chapter_list_page.dart:304` already uses ListView with
`List.generate` (50+ rows) — convert to `ListView.builder`.

### 6.4 Performance wins already shipped

- **GROUP BY query** for chapter read counts (one query vs N watches) —
  see `scripture_dao.dart:252`.
- **Tree-shaken Material icons** — 1.6 MB → 8.7 KB (99.5% reduction) per
  build log.
- **Lora-Bold dropped** (131 KB), `ic_foreground.png` moved out of
  runtime bundle (1.38 MB) — see commit `a984083`.
- **Drift `NativeDatabase.createInBackground`** moves DB I/O off the
  main isolate.

---

## 7. Security

### 7.1 Posture (post 2026-05-28 rotation)

✅ Gemini API key:
- Stored as `String.fromEnvironment` compile-time constant.
- Restricted to Android app package + 2 SHA-1s (debug + release).
- Restricted to Generative Language API only.
- Old leaked key revoked + scrubbed from git history via filter-repo.

✅ Firebase API key:
- Public-by-design per Google docs. No security implication.
- Restrictions ride on same GCP package + SHA-1 lock.

✅ Network:
- `usesCleartextTraffic="false"` + `networkSecurityConfig` enforces TLS.

✅ Data:
- `allowBackup="false"` + `dataExtractionRules` block ADB backup
  exfiltration on rooted devices.
- All user data (notes, bookmarks, history) lives in app-private DB
  + SharedPreferences. No cloud sync.

✅ R8/proguard:
- `isMinifyEnabled = true`, `isShrinkResources = true`.
- Keep rules for Firebase, drift, flutter_local_notifications, GSON.

✅ Code obfuscation: AOT-compiled Dart is functionally obfuscated.
String constants (including the Gemini key after build) are still
extractable, but useless without the matching package + SHA-1.

### 7.2 Remaining gaps

#### Issue Sec-1: No App Check (MED)

Firebase Analytics + Crashlytics events can be spoofed by a re-signed APK
or an attacker with the apiKey. App Check (Play Integrity) verifies the
requesting app's identity server-side.

**Fix:** enable Firebase App Check with Play Integrity provider before
production. ~30 min setup.

#### Issue Sec-2: Deep-link payload not validated (LOW)

Notification deep-link reads `payload` as a verse-id and pushes the
route. A malicious notification (rare but possible if another app
spoofs your channel) could route to arbitrary GoRouter paths.

**Fix:** validate against `parseScriptureCoordinate` before navigating.
Drop unparseable payloads silently.

#### Issue Sec-3: No SSL pinning (LOW)

Gemini API + Firebase already use Google-issued certs from the system
trust store. SSL pinning would prevent MITM on a device with a
user-installed root CA. Heavy infra cost for low marginal benefit.
Skip unless paid-AI usage spikes.

#### Issue Sec-4: Input length not capped on Pandit prompts (LOW)

`pandit_chat_page.dart` doesn't enforce a max prompt length. A user
could paste 50KB of text → Gemini billing impact. Cap at 2000 chars
client-side.

---

## 8. Production-Readiness Checklist

Items below are gating; pass all before promoting to Production track.

### 8.1 ✅ Already done

- [x] Release keystore set up + offsite-backed
- [x] R8/proguard rules in place
- [x] Crashlytics opt-out wired
- [x] Analytics opt-out wired
- [x] Network security config (system CAs only)
- [x] No HTTP cleartext
- [x] Notification cold-start deep-link code shipped
- [x] CI workflow (GitHub Actions)
- [x] Privacy + Terms drafts
- [x] APK size <50 MB
- [x] Pre-commit analyzer hook
- [x] 298 tests passing

### 8.2 ☐ Still owed

- [ ] **App Check** (Firebase) — Play Integrity provider
- [ ] **Deep-link payload validation** — see Sec-2
- [ ] **Crashlytics test crash** — confirm reporting works on release build
- [ ] **Cold-start notif deep-link device test** — see V1 audit §15.5
- [ ] **Play Console fills** — Data Safety + IARC + AAB upload
- [ ] **24-hour Internal Testing soak** — at least 1 device-day before Production
- [ ] **`firebase_crashlytics` symbol upload** — wire `--upload-symbols` to release script for legible stack traces

---

## 9. Refactor Roadmap (post-v1)

### 9.1 Pri-1: Split the giant page files (HIGH)

`verse_detail_page.dart` at 2,947 LOC is the single biggest maintenance
risk. Proposed split:

```
lib/presentation/features/scripture_reader/pages/
  verse_detail_page.dart                   (controller + scaffold, ~400 LOC)
  verse_detail/
    sections/
      _sanskrit_section.dart               (~200 LOC)
      _translation_section.dart            (~200 LOC)
      _word_meanings_section.dart          (~300 LOC)
      _explain_card_section.dart           (~300 LOC)
      _commentary_section.dart             (~200 LOC)
      _action_row.dart                     (~150 LOC)
    chrome/
      _verse_chrome_frame.dart             (~200 LOC)
      _verse_back_chevron.dart             (~50 LOC)
    painters/
      _dashed_line_painter.dart            (~30 LOC)
```

Equivalent treatment for `scripture_library_page.dart`,
`search_page.dart`, `settings_page.dart`.

**Target:** no file >800 LOC outside of `sacred_ornaments.dart` (art
asset) and freezed generated files.

### 9.2 Pri-2: Centralise Gemini caching (MED)

Move L1 (in-memory) caches into Drift tables: `glosses`, `section_themes`.
Add `LRUCache<String, GeminiReply>` for hot prompts.

### 9.3 Pri-3: Schema cleanup (MED)

- Drop `bookmarks` table (D-2).
- Add `sukta_num` to `verses` (D-1).
- Index `verse_explanations(verse_id)` (D-3).
- Bump schema to v10 with one migration block.

### 9.4 Pri-4: SharedPreferences key registry (MED)

All 69 inline keys → `PreferencesKeys.X` constants. Add custom lint.

### 9.5 Pri-5: Wrap Gemini with circuit breaker + tighter timeout (LOW)

Per §4.3. 6s timeout, 3-failure/60s circuit, 2-min cool-down.

### 9.6 Pri-6: HTTP cache layer (LOW)

LRU around `GeminiService.ask`. Saves repeated identical asks.

---

## 10. Proposed File-Structure Refinements

### 10.1 Move misclassified files

| Current path | Proposed path | Reason |
|---|---|---|
| `lib/data/festivals/festival_data_2026.dart` | `lib/core/constants/festivals/festival_data_2026.dart` | It's hardcoded data, not a data source. |
| `lib/data/festivals/festival_dates_future.dart` | `lib/core/constants/festivals/festival_dates_future.dart` | Same. |
| `lib/data/datasources/remote/bhagavad_gita_remote_datasource.dart` | Delete | Unused stub. |
| `lib/data/datasources/local/` | `lib/data/local/` | Drop the redundant `datasources/` segment. |

### 10.2 Add missing layers

- `lib/core/cache/` — centralise LRU cache + Drift-backed cache mixin.
- `lib/core/network/` — house `GeminiService`, `HttpClient`,
  CircuitBreaker, RetryPolicy. Pull out of `lib/core/services/`.
- `lib/presentation/shared/widgets/states/` — group HeritageLoading,
  HeritageError, OfflineBanner, EmptyStateWidget.

### 10.3 Naming consistency

- All `_*Provider` files → `*_provider.dart` (~80% already follow).
- All page files → `<feature>_page.dart` (~95% already follow).
- Use-cases → `<verb>_<noun>_usecase.dart` (already consistent).

---

## 11. Test Coverage Picture

| Layer | Tests | Coverage feel |
|---|--:|---|
| `lib/domain/entities/` | 1 | Entities are mostly freezed; not much to test. |
| `lib/domain/usecases/` | 3 | Solid — toggle_bookmark, get_verse_by_id, get_verse_of_day covered. |
| `lib/core/` | ~10 | Good — panchanga, verse_text, word_gloss_service, audio_service, coordinate_parser, section_theme_service. |
| `lib/data/` | 3 | Light — commentary_dao, offline, scripture_repository. Missing: per-DAO query tests. |
| `lib/presentation/` | ~270 | Heavy — widget tests for every page. |

**Gap:** integration tests via `package:integration_test`. Zero today.
For v2: add 5 golden flows:
1. Cold start → daily verse renders → tap → verse-detail opens.
2. Pandit chat: type → reply with citation chip → tap chip → verse opens.
3. Bookmark a verse → leave + return → bookmark persists.
4. Settings → Reset all → confirm → all SharedPreferences cleared.
5. Notification cold-start → deep-link → verse opens (the §15.5 issue).

---

## 12. Scalability Lens

### 12.1 What scales linearly

| Axis | Today | Cap before refactor |
|---|--:|--:|
| Verses in DB | 133K | ~10M (SQLite + FTS5 comfortable to 10M) |
| Users on a device | 1 | not multi-user — would need accounts |
| Scriptures | ~35 | 200+ (Library is `ListView`, hits its `.builder` limit at ~50) |
| Festivals/year | 12 | 100+ |
| Languages | 1 (English UI; multilingual scripture text) | 5+ (i18n infra in place via `l10n/`) |

### 12.2 What does NOT scale

- **Inline strings everywhere** — no `arb` entries for most UI text yet.
  Localising means a sweep.
- **Per-page bundle of constants** (`scripture_chapters.dart` 900 LOC) —
  fine today, hard to localise.
- **Bundled DB at 14 MB gz / 65 MB extracted** — adding more scriptures
  pushes both numbers. Plan: split into a core-DB (BG + Vedas + main
  Upanishads, ~5 MB gz) + optional-download per-scripture packs.

### 12.3 Massive-traffic note

This is an offline-first reading app. There is **no server** in scope.
"Traffic" maps to:
- **Gemini API spend** — capped per-bucket per-user-per-day; modest.
- **Firebase free-tier limits** — Analytics + Crashlytics + RC fit
  comfortably at 100K MAU; revisit at 1M MAU.

**Cost per MAU**: ~$0 (no server) plus Gemini at ~$0.10/MAU/month if every
user fully uses Pandit + word-gloss (rough — most won't).

---

## 13. Verdict

**Sanatan Guide is shippable today.** The architecture is sound, the
security posture is tight post key-rotation, and the test suite carries
real signal. The biggest single sin is the multi-thousand-LOC page
files — that's the v2 mandate. Database schema and caching have
identified small improvements, none blocking.

**Recommended v1.0 ship sequence:**
1. Finish Production-Readiness Checklist §8.2 (App Check + Crashlytics
   test crash + notif deep-link device test + Play Console flow).
2. Internal Testing soak 3 days.
3. Promote to Production.

**Recommended v1.1 (4-6 weeks post-launch):**
1. Split `verse_detail_page.dart`.
2. Persist Gemini glosses to Drift.
3. Schema cleanup (drop bookmarks table, add sukta_num, index explanations).

**Recommended v2.0 (3-6 months post-launch):**
1. Integration test suite (5 golden flows).
2. Circuit breaker + tighter timeouts on GeminiService.
3. Optional per-scripture DB packs (split bundled asset).
4. i18n sweep — full `arb`-coverage for UI strings.
