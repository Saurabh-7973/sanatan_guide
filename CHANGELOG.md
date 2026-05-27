# Changelog

All notable changes to Sanatan Guide are documented here. Dates use ISO 8601;
versions follow Semantic Versioning.

## [Unreleased]

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
