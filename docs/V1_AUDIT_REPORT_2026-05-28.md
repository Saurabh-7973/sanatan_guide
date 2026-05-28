# V1 — Code Audits (2026-05-28)

Solo audits run alongside the sprint sync. Each section is a finding +
recommendation. Source files referenced inline.

---

## §A — APK Size Breakdown

**Total arm64-v8a APK:** 47.4 MB (per `unzip -l`).

| Component | Size | % of APK | Notes |
|---|--:|--:|---|
| `assets/db/sanatan_guide.db.gz` | 13.96 MB | 29.4% | gzip of 65 MB DB. Decompressed at first launch. |
| `lib/arm64-v8a/libflutter.so` | 11.04 MB | 23.3% | Flutter engine. Not reducible. |
| `lib/arm64-v8a/libapp.so` | 9.24 MB | 19.5% | Dart AOT. Reducible only by code-trimming. |
| `classes.dex` | 5.63 MB | 11.9% | Java + Kotlin + Firebase + drift codegen. |
| `lib/arm64-v8a/libsqlite3.so` | 1.53 MB | 3.2% | SQLite native. Acceptable. |
| `assets/icons/ic_foreground.png` | 1.38 MB | 2.9% | **Big launcher icon — investigate.** |
| `assets/fonts/TiroDevanagariSanskrit-{Regular,Italic}.ttf` | 1.40 MB combined | 2.9% | Sanskrit IAST rendering. Worth it. |
| `assets/fonts/NotoSansDevanagari-{Regular,Medium,SemiBold,Bold}.ttf` | 885 KB combined | 1.9% | Devanāgarī body text. |
| `assets/fonts/Lora-{...}.ttf` | 670 KB combined | 1.4% | Heritage serif (5 weights). |
| `resources.arsc` | 414 KB | 0.9% | Android resources. |
| Everything else | ~1 MB | ~2.1% | |

**Findings:**

1. **`assets/icons/ic_foreground.png` at 1.38 MB is oversized for an adaptive
   icon foreground.** A 432×432 PNG with alpha at ~24 KB is typical (cf the
   notification icon `ic_notification_om.png` at 7 KB). Suggest downscaling
   and re-quantising; saving ~1.3 MB.
2. **Lora bundles 5 weights.** Audit which weights the app actually uses;
   stripping unused weights could save ~130 KB each. Check
   `lib/presentation/theme/design_typography.dart` for the active set.
3. **DB.gz at 14 MB is the single biggest line.** Already gzipped, so no
   easy compression win. If a future v1.1 needs to trim, the FTS5 index
   (rebuilt on first run) could ship as `content=''` and be repopulated
   client-side from a smaller seed.

**Not actionable in v1:**
- `libflutter.so`, `libapp.so`, dex are baseline costs.
- google_mobile_ads is already dropped (commit e28e1d6).

---

## §B — R8/ProGuard — Gemini Key Strip Check

**Verdict:** Safe. The key is never an obfuscation target.

`lib/core/services/gemini_service.dart:12` reads the key via
`String.fromEnvironment('GEMINI_API_KEY', defaultValue: '')`. Dart's
`String.fromEnvironment` is **a compile-time constant** — the value
specified by `--dart-define=GEMINI_API_KEY=...` is inlined into the AOT
snapshot as a literal `String` at build time. There is no runtime
property lookup that R8 could strip.

**Implications:**
- If the build runs without `--dart-define=GEMINI_API_KEY=...`, the key
  is the empty string and AI features (Pandit chat, verse-detail
  word-gloss, ask-this-verse) all return early in
  `GeminiService.isEnabled`. No crash, just no AI.
- If the key is supplied, it ends up inside `libapp.so`. Anyone with a
  copy of the APK can extract it via `objdump` or `strings`.
  **Recommendation:** rely on the GCP package-name + SHA-1 restriction
  for the key, not on obfuscation. Without that restriction, the key is
  effectively public the moment it ships.

**Proguard rules state:** `android/app/proguard-rules.pro` already
preserves Firebase, drift, flutter_local_notifications, GSON, and
TypeAdapter/Factory classes. AdMob keep removed alongside the dep drop.
No issues.

---

## §C — Drift DB Ship-vs-Runtime Schema Mismatch

**Verdict:** Pinned but fragile. Document the contract.

`lib/data/datasources/local/app_database.dart:40` declares
`schemaVersion => 9`. `openAppDatabaseConnection()` (line 146) extracts
the bundled `assets/db/sanatan_guide.db.gz` to the app's documents
directory on first launch.

**The contract:** The bundled DB must already be at schema v9 — i.e. it
must contain:
- All tables registered in `@DriftDatabase` annotation (`versesTable`,
  `learningModulesTable`, `moduleCardsTable`, `moduleExtrasTable`,
  `userModuleProgressTable`, `bookmarksTable`, `verseExplanationsTable`,
  `commentariesTable`).
- All v4 columns on `versesTable`: `bookNum`, `chapterLabel`,
  `translation`, `noteText`.
- The two indexes from `_createIndexes` (lines 86-99).
- The FTS5 virtual table `verses_fts` + the 3 sync triggers (`verses_ai`,
  `verses_ad`, `verses_au`).
- A row in `__schema_version` (drift's bookkeeping table) recording
  schemaVersion 9.

**Risk:** Drift only runs `onUpgrade` when it sees `__schema_version`
behind by N. If the bundled DB carries no `__schema_version` row, Drift
treats it as schema 1 and runs migrations 1→9. Most of those migrations
create tables that already exist → `SQLITE_ERROR: table verses already
exists`, which crashes startup.

**Recommended verification (run once before each release):**
```bash
# extract and read schema_version from the bundled DB
gunzip -k -c assets/db/sanatan_guide.db.gz > /tmp/check.db
sqlite3 /tmp/check.db 'SELECT * FROM __schema_version'
# expect: 1|9 (or similar — version column == 9)
sqlite3 /tmp/check.db '.schema verses_fts'
# expect: CREATE VIRTUAL TABLE verses_fts USING fts5(...)
```

If `__schema_version` is missing or != 9, regenerate the bundled DB by
running the app once with `onCreate` letting drift build from scratch,
then copying the resulting DB file back to `assets/db/`.

**Size sentinel guard:** `openAppDatabaseConnection()` lines 152-163
already deletes the runtime DB if it's < 1 MB (treating it as a stale
extract). Good defensive code — keep.

---

## §D — Pandit Chat Code Walk

File: `lib/presentation/features/chat/pages/pandit_chat_page.dart` (758 lines).

| State | Built? | Notes |
|---|---|---|
| Empty (no messages) | ✓ | `_EmptyState` at line 187 — suggestion chips via `onSuggestion`. |
| Offline | ✓ | `OfflineBanner` at line 184 reacts to connectivity_plus stream. |
| Loading | ✓ | `_Conversation` receives `loading: _loading`; `_send()` sets it true. |
| Specific Gemini error | ✓ | `GeminiException` caught at line 121 → `_error = e.message`. |
| Generic network error | ✓ | catch-all at line 128 → "Couldn't reach the Pandit". |
| Rate limit reached | ✓ | `_remaining <= 0` → `_error = 'Daily question limit reached.'` |
| AI disabled (no key) | ✓ | `GeminiService.isEnabled` gates `_canSend`; `_EmptyState.aiEnabled` propagates. |
| Citation chip render | ✓ | Replies go through `AiRichProse` (covered by new tests). |
| Clear conversation | ✓ | `_clearConversation` clears messages + error. |

**Gaps worth filing:**

1. **No retry button.** When an error fires, the user can only re-type the
   last question. A small "Try again" pill below the error message would
   re-submit the last user-turn without retyping. Low effort.
2. **Follow-up chips not generated from AI replies.** Only the empty
   state offers suggestions. After a reply, the user has to think of the
   next question. Spec'd in `screen-13-pandit-chat.html`? Verify against
   design.
3. **Rate-limit message lacks reset hint.** "Daily question limit
   reached." doesn't tell the user when it resets. Suggest:
   "Daily question limit reached — resets at midnight local."
4. **AI disabled state pushes user into a dead end.** With
   `GeminiService.isEnabled == false`, the empty state still shows
   suggestion chips but tapping them does nothing (`_send()` returns
   early). The chips should be visibly disabled OR the empty state
   should explain why AI is unavailable.

---

## §E — Summary of solo-doable follow-ups

| Item | Effort | File |
|---|---|---|
| Downsize `ic_foreground.png` from 1.38 MB | 5 min | `assets/icons/ic_foreground.png` |
| Trim unused Lora weights | 15 min audit | check `design_typography.dart` |
| Add `.schema __schema_version` check to `scripts/release.sh` | 10 min | `scripts/release.sh` |
| Add "Try again" pill on Pandit error | 30 min | `pandit_chat_page.dart` |
| Add midnight-reset hint to rate-limit error | 5 min | `pandit_chat_page.dart:88,94` |
| Visually disable suggestion chips when AI off | 15 min | `pandit_chat_page.dart` `_EmptyState` |

---

## §F — Known bugs found during test writing (2026-05-28)

Already noted in test files; tracking here so they don't get lost:

1. **`bareCitationRe` swallows Devanāgarī digits in alias root.**
   `lib/presentation/shared/widgets/ai_rich_prose.dart:201-205`. The
   alias character-class `[A-Za-zĀ-žऀ-ॿ’\-]` covers U+0900–U+097F,
   which includes Devanāgarī digits U+0966–U+096F. So "BG २.४७" never
   matches as bare; only `(BG २.४७)` works because `citationRe` uses
   a different class. Fix: exclude U+0966–U+096F from the alias class.
2. **`kathaUpanishad` doc claims 3-level, parser is 2-level.**
   `lib/core/utils/coordinate_parser.dart:173-180` doc-comment example
   `Katha 1.2.18` does not parse (kathaUpanishad is absent from
   `_isThreeLevel` at line 157-170). Either move kathaUpanishad into
   `_isThreeLevel` (if data is Adhyāya.Vallī.Mantra) or fix the
   doc-comment example.
