# Changelog

All notable changes to Sanatan Guide are documented here. Dates use ISO 8601;
versions follow Semantic Versioning.

## [Unreleased]

## [1.0.0-rc] — 2026-05-29 (production-readiness pass)

### Added
- **Crashlytics**
  - R8 mapping upload pinned in `android/app/build.gradle.kts` so
    obfuscated stack traces deobfuscate in the Crashlytics console.
  - Hidden QA gesture: triple-tap the version label in Settings to
    throw an uncaught exception, verifying the symbolication pipeline
    end-to-end on real release builds.
- **GeminiService — quality + reliability**
  - In-memory LRU cache (100 entries) keyed by model + systemContext +
    history digest + userMessage. Repeated identical asks return
    instantly without re-paying network or billing.
  - Circuit breaker: 3 failures within 60 s opens the breaker for
    2 minutes. While open, `ask()` short-circuits with a friendly
    error — saves 6 s timeout per attempt during regional outages.
  - 5xx and network/timeout count toward the breaker; 4xx
    (auth, quota) do not.
- **Notifications**
  - Deep-link payload validation in `notification_service.dart` — the
    cold-start + warm-tap callbacks now run the payload through
    `parseScriptureCoordinate` + reject path-traversal characters
    before routing.
- **Pandit chat**
  - 2000-character client-side prompt cap with maxLength on the text
    field + on-send guard. Refuses pasted-blob abuse before it hits
    Gemini billing.
- **Festivals calendar**
  - "Earlier this year" past months now collapse behind a tappable
    header with rotating chevron + count badge, default closed.
    Calendar reads forward-by-default.
- **Settings**
  - Theme picker swapped from icon-only SegmentedButton to text
    labels ("Light · Dark · Auto") matching design mockup.
  - Backdrop wash added on Home + Library — both screens were the
    only ones still using a flat scaffold bg color. Bottom-nav
    rotation now reads consistent.
- **Reader**
  - Chapter list header swap "MAṆḌALAS / KĀṆḌAS → CHAPTERS · VERSES
    · READ" now triggers on either readChapters > 0 OR `hasStarted`
    (last-read pointer), so the swap happens immediately on resume
    even while the per-chapter GROUP BY is mid-invalidation.
  - Chapter list converted to CustomScrollView + SliverList.builder
    so long lists (Mahābhārata 18 parvas, Bhāgavata Purāṇa 12
    skandhas) render lazily.
- **Search**
  - Tapping the X to clear the field now saves the query into recents
    before clearing — abandoned typed queries are remembered.

### Changed
- **SharedPreferences key registry** — `PrefsKeys` (lib/core/constants/
  preferences_keys.dart) expanded from 4 → 27 static keys + 2 dynamic
  prefixes. 15 files swept replacing inline `_kFooKey` strings with
  `PrefsKeys.X`. Future additions go through the registry.
- **GeminiService timeout** — 10 s implicit → 6 s explicit per
  request. Worst case 12 s (primary + fallback).
- **`scriptureReadCountsProvider` is now `keepAlive: true`** — Library
  remounts no longer re-issue the GROUP BY between bottom-nav
  round-trips.
- **DB gunzip moved to a background isolate** via `compute()`. Splash
  screen stays animated on the very first cold launch (~600-900 ms
  off the main thread).
- **APK slim** — `assets/icons/ic_foreground.png` (1.38 MB) moved out
  of the runtime bundle (was only used by `flutter_launcher_icons` at
  build time). `Lora-Bold.ttf` (131 KB) dropped — codebase audit
  confirmed only w500/w600 + italic are referenced with the serif
  family. Net ~1.5 MB APK reduction; arm64 release is now 39 MB.
- **AdId permissions removed via manifest merge** — Firebase Analytics
  auto-adds four AdId / Privacy-Sandbox permissions; all four
  overridden with `tools:node="remove"` so the merged manifest matches
  the "v1 ships without ads" story. Play Console Data Safety form's
  "Device or other IDs" question can stay "No".

### Fixed
- **`bareCitationRe` Devanāgarī digits** — the regex's alias-letter
  class swallowed U+0966-U+096F. "BG २.४७" never separated into
  alias + numeric. Range split + negative-lookahead trailing
  boundary; both forms ("(BG २.४७)" and bare "BG २.४७") now parse.
- **`parseScriptureCoordinate` Katha doc-comment** — example
  "Katha 1.2.18" did not parse (kathaUpanishad is 2-level in the
  bundled DB, not 3-level). Updated example to "Katha 1.18".

### Security
- **Git history scrub** — `git filter-repo` rewrote all 230+ commits
  to: drop the live Gemini API key from `BUILD_COMMANDS.md`, swap
  the author email to a personal account, drop a `_review_delete/`
  bundle that carried a full source export with Firebase keys, drop
  an employer design-system reference folder, and drop personal
  device-audit + Claude Code config files. Followed by GCP key
  rotation + Android package + SHA-1 restriction.
- **Crashlytics + Analytics opt-out wiring** verified honoured on
  boot via `setCrashlyticsCollectionEnabled` and
  `setAnalyticsCollectionEnabled` reading `PrefsKeys.privacy*Enabled`
  before `runApp`.

### Docs
- `docs/V1_AUDIT_REPORT_2026-05-28.md` — code audit covering APK
  breakdown, R8/key safety, Drift schema contract, Pandit code walk.
- `docs/V1_ARCHITECTURE_AUDIT_2026-05-28.md` — 13-dimension
  architecture audit (composite 7/10) with v1.1 + v2 refactor
  roadmap.
- `docs/PRE_PRODUCTION_TEST_2026-05-29.md` — systems-level pre-launch
  audit on real Samsung A015 (cold start 1789 ms, PSS 229 MB,
  APK 39 MB, debuggable=false, R8 mapping.txt 21 MB).
- `docs/legal/{privacy,terms}.md` — Lora-tone Privacy Policy + Terms
  drafts.
- `store_assets/` — Play Store listing copy + screenshot capture
  plan + feature-graphic prompt.
- `scripts/verify_festival_dates.md` — 48-row checklist for
  cross-checking 2027-2030 dates against Drik Panchang.

### Build
- `scripts/release.sh` now gzip-extracts and validates the bundled
  DB before kicking off Gradle: `PRAGMA user_version=6` + verse
  count ≥ 20K. Fails fast if the bundled DB regresses.
- Schema bumped 9 → 10: adds
  `idx_verse_explanations_verse_id` on the AI-explanation cache.
- `LICENSE` file added at repo root.

## [1.0.0] — 2026-05-27 (v1 final-audit sprint)

### Added
- **Notifications**
  - Cold-start deep-link routing (`getNotificationAppLaunchDetails`) — tapping
    a verse notification from a killed app process now lands on the verse
    detail page instead of Home.
  - Day-of festival alert scheduler, gated on the new `Festival alerts`
    Settings switch. Schedules up to 30 upcoming festivals over 120 days at
    the user's chosen daily-reminder hour; sync runs from Settings toggle
    and from app boot.
  - Notification permission requested only when the user explicitly opts in
    (onboarding reminder step or Settings switch) — no more hostile native
    dialogs at launch.
- **Library**
  - Per-scripture verse read counts (GROUP BY query) — Ṛgveda, Yajurveda,
    Atharvaveda, etc. now show "N verses read" suffix, not just the
    previously-hardcoded BG count.
  - Mukhya Upaniṣads aggregate row sums reads across all 13 individual
    upaniṣad codes.
  - Yajurveda full 40-chapter listing (dropped bogus 3-kāṇḍa curated
    placeholder that shadowed the DB).
- **Reader**
  - Transliteration renders one pāda per line; trailing `||verse||` marker
    is stripped (`formatTransliteration`).
  - Translation splits multi-sentence prose onto one sentence per line
    (`formatTranslation`), with decimal-safe sentence boundary lookahead.
  - "Verse N of M" + `~N min left` minutes-to-read estimate on the Continue
    Reading card for non-BG scriptures.
  - Chapter list header trims the unit row ("MAṆḌALAS") once the user has
    started reading a rollup scripture — orientation noise after first read.
  - Section dividers (decade headers + AI theme suffix when key present).
  - Bookmark + read tick badge on verse list rows (was: bookmark only).
  - No-translit inline notice when the toggle is on but the verse has none.
- **Search**
  - Recents save on result tap, not just keyboard submit.
  - Direct coord match (`BG 2.47`) is exclusive — drops the
    "OR RELATED VERSES" sidebar.
  - Pandit CTA also triggers on emotional / situational queries
    (grief, anxiety, lost, suffering, "i feel"…) beyond grammar-shaped
    questions.
  - Single-line Sanskrit + English previews in result tiles (was 2-line).
- **Bookmarks**
  - Topbar bookmark dot (saffron) when user has ≥1 saved verse.
  - Empty-state saffron pill CTA (was a plain underline link).
  - Leaf-note divider solid (was dashed per older mockup).
- **AI Chat (Pandit + verse-scoped)**
  - Heritage-toned app bar on verse-scoped chat.
  - Action row under each AI reply: copy · save-to-notes · share ·
    regenerate (regenerate only on most-recent bubble).
  - Tappable bare-citation chips in AI prose — `BG 2.47`, `Kaṭha 1.2.18`
    etc. open the verse without parentheses required.
  - Word-gloss empty copy reworded — no `GEMINI_API_KEY` leak in
    user-facing copy.
  - Gemini upgraded to `gemini-3.5-flash` with automatic single-shot
    fallback to `gemini-2.5-flash` on 404/400. Override-able via
    `--dart-define=GEMINI_MODEL`.
- **Settings**
  - Privacy section: Analytics opt-out + Crashlytics opt-out switches.
  - Festival alerts real toggle (was "SOON").
  - Heritage time picker (two scroll wheels) replaces Material dial.
  - Heritage confirmation sheets for "Clear reading history" + "Reset all
    settings".
  - Brand footer with version + build + "Made in Bhārata".
- **Practice**
  - Locked-tap heritage bottom sheet (was a SnackBar).
- **Festivals**
  - Calendar window starts at today (was first-of-month).
- **Chrome / system**
  - Unified `MockupBackChevron` across 11 screens.
  - Crashlytics route breadcrumbs (push/pop/replace trail in crash reports).
  - Offline banner (`connectivity_plus`) on Pandit + verse-scoped chat.
  - `runZonedGuarded` boot wrapper.

### Security
- `allowBackup="false"` + `dataExtractionRules.xml` (cloud backup / device
  transfer excluded for every domain — local-only state).
- `network_security_config.xml` pinning trust to system CAs only.

### Performance
- One GROUP BY per scripture for chapter read counts — replaces N
  per-chapter watches.
- `google_mobile_ads` dependency dropped — ~5 MB APK reduction + no
  deprecated-API warnings.

### Build / Dev
- `scripts/release.sh` (App Bundle), `scripts/analyze_size.sh`,
  `scripts/install_git_hooks.sh` + pre-commit `flutter analyze` gate.
- `.github/workflows/flutter.yml` (analyze + test).
- `LAUNCH_ASSESSMENT_2026-05-27.md` audit doc.

### Removed
- `google_mobile_ads` (deferred to v2).
- Dead `native_ad_widget.dart`.

### Dependencies
- Added: `connectivity_plus ^7.1.1`, `cupertino_icons ^1.0.8`.
- Removed: `google_mobile_ads`.

## [0.9.0] - 2026-04-24

### Initial Release

**Scripture Library**
- Bhagavad Gita — 700 verses (Sanskrit, IAST, English, Hindi)
- Vedas (Rig, Yajur, Sama, Atharva) — verse-level access
- Upanishads, Puranas, Arthashastra, Manusmriti
- Full-text search across 133K+ verses (offline, FTS5)

**Learning Modules**
- Structured learning paths grouped by level and sequence
- Anchor verses and commentary cards per module

**Daily Practice**
- Daily verse notification (scheduled, reboot-safe)
- Streak counter with milestone tracking
- Bookmarks persisting across sessions

**AI Explanations**
- Gemini 2.5 Flash integration for contextual verse interpretation
- Rate-limited to 10 questions/day per device

**Platform**
- Offline-first: all scripture data bundled in SQLite (Drift)
- Dark and light themes
- Share-card generation for verses
- Firebase Analytics + Crashlytics
- AdMob monetization (native, interstitial, app-open)
