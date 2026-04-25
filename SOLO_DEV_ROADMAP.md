# Sanatan Guide — Solo Developer Roadmap (Zero Budget)
> Realistic, prioritized plan for a single developer using AI tools.
> Every item tagged: what you CAN do now vs. what needs resources later.

---

## Philosophy

**Ship narrow. Ship excellent. Expand with traction.**

You have one unfair advantage: AI-assisted development speed.  
You have one constraint: zero budget, one person.  
The plan is designed around this reality.

---

## Current State (Audit Summary — April 2026)

### What's Built
- Clean Architecture (domain/data/presentation) with Riverpod
- Offline-first Drift/SQLite DB (71 MB bundled)
- 11 screens (Home, Onboarding, Browse, Chapter, Verse, Search, Bookmarks, Festivals, Learning Path, Module Reader, Scripture Library)
- Streak tracking (backend) + Continue Reading
- Panchang (Vara, Tithi, Nakshatra)
- Festival Calendar 2026
- Shareable verse card generation
- Notifications infrastructure
- Firebase Analytics + Crashlytics
- AdMob integration

### Content Seeded (in DB) — counts from `assets/db/sanatan_guide.db` (April 2026)

| Scripture | Notes | Verse count |
|-----------|--------|---------------|
| bhagavad_gita | Complete | 700 |
| rigveda | Full seed; see sprint 59 re hymn-level gaps | 9,508 |
| samaveda | Griffith English via `parse_samaveda_html.py`; Sanskrit column often empty until merged | 1,719 |
| yajurveda | 40 adhyayas; **46** English gaps, **30** Sanskrit gaps — `verify_yajurveda_db.dart` | 1,978 |
| atharvaveda | 20 kaandas; ~25 English gaps — see `verify_atharvaveda_db.dart` | 5,627 |
| ramayana | GRETIL Sanskrit — `verify_ramayana_db.dart` | 18,761 |
| mahabharata | **Parva 10 missing** — `verify_mahabharata_db.dart`; Sanskrit-only | 72,770 |
| bhagavata_purana | 12 skandas GRETIL — `verify_bhagavata_purana_db.dart`; Sanskrit-only | 14,031 |
| arthashastra | | 5,371 |
| tirukkural | **4** kurals missing — `verify_tirukkural_db.dart`; Tamil only | 1,326 |
| Upanishads (11+), Yoga/Hatha/Brahma/Vishnu SA/Manusmriti/etc. | Per seed scripts | see DB |
| Learning modules | 17 × cards | see app |

### Composer sprint living status (for Opus / reviewers — no need to re-ask)

**Source of truth for task order:** `CURRENT_SPRINT.md`. **This blurb** is updated when Composer finishes or partially completes work so verification can run without ping-pong.

| Sprint block | Done (Composer mark → verify: Opus 4.6) | Pending / partial |
|--------------|----------------------------------------|---------------------|
| Week 7–8 UX 50–58 | Streak badges, heatmap, daily suggestion, onboarding level, **REDESIGN_FINAL.md**, home dashboard, verse detail polish, library cards, dark/bookmarks/search pass | Full-device dark audit optional pre-store |
| Bug + UI Pass (Apr 17) | **Onboarding back nav fixed** (canPop:false, X button, step-slide animation); **module resume at correct card**; **_advance fallback → /learn**; **all 17 module book recs corrected**; **"Read in App" CTA** on completion cards; **UI polish** — home/learning-path/module-reader/scripture-library magic numbers → AppSpacing constants; category colors → AppColors; streak calendar `_kCellSize`; `flutter analyze` 0 issues | Verify on device: onboarding back, module resume, book recs |
| Content 59 | `verify_rigveda_db.dart`, parser union logic | Bundled DB: Mandala 1 **190/191** hymns until re-seed from `/tmp` inputs |
| Content 60 | `verify_atharvaveda_db.dart`, two-pass `parse_atharvaveda_txt.py` | **25** verses still missing English until full `av.txt` re-import |
| Content 61 | `verify_samaveda_db.dart` | Griffith **English** present in DB; **Sanskrit** still empty rows until DharmicData (or similar) merge — track as enhancement |
| Content 62 | `verify_yajurveda_db.dart`, `parse_yajurveda.dart` + `parse_yajurveda_html.py` | Bundled DB: all **40** adhyayas populated; **46** rows still `griffith_pending` / missing English; **30** missing Sanskrit until DharmicData + HTML alignment |
| Content 63 | `verify_tirukkural_db.dart`, `parse_tirukkural.py` | **1,326 / 1,330** — gaps **72, 753, 781, 1293**; English TBD |
| Content 64 | `verify_ramayana_db.dart`, `parse_ramayana.py` | **~18.7k** verses, **7** kandas; Sanskrit-only; English TBD |
| Content 65 | `verify_mahabharata_db.dart`, `parse_mahabharata.py` | **~72.8k** verses; **Parva 10** empty in bundle; English TBD |
| Content 66 | `verify_bhagavata_purana_db.dart`, `parse_bhagavata_purana.py` | **~14k** verses, **12** skandas; English TBD |
| UI 67 | `lib/presentation/features/scripture_reader/pages/scripture_library_page.dart` | “Selected highlights” only for true samplers; displayed counts match bundled DB |
| Release 68 | `pubspec.yaml` **1.1.0+2** | **You:** `flutter build appbundle`, Play Console, What’s New |
| AI 69–71 | `verse_explanations` table (Drift **v8**), `verse_explanation.dart`, `verseExplanationProvider`, `tool/generate_ai_explanations.dart` | **You:** `GEMINI_API_KEY=… dart run tool/generate_ai_explanations.dart`, merge rows into shipped DB if you want explanations in the bundle |
| Commentary 76–78 (Opus 4.7, 2026-04-24) | `commentaries_table.dart` (schema **v9**, index on verse_id), `Commentary` entity, `ScriptureDao.getCommentariesByVerseId`, `verseCommentariesProvider`, `_CommentariesBlock` on verse detail, `commentary_formatting.dart` helpers, `tool/seed_shankara_commentary.dart` with PD source + license allowlist, `tool/sources/shankara_gita.template.json`. **Tests 21/21 green** (dao 5, seed-tool 10, formatter 6). | **You:** OCR / transcribe Shankara Gita Bhashya (GRETIL Sanskrit + Mahadeva Sastri 1897 English) into `tool/sources/shankara_gita.json`, run `dart run tool/seed_shankara_commentary.dart --input tool/sources/shankara_gita.json`, rebundle DB. Commentary section on verse detail is invisible until rows exist. |
| i18n 79 / 81 (Opus 4.7, 2026-04-24) | `l10n.yaml`, `lib/l10n/app_en.arb` + `app_hi.arb`, generated `AppLocalizations`, `localeProvider`, `MaterialApp.router` wired with delegates + supportedLocales, language picker in Settings (`_LanguageTile`), commentary block migrated as the pattern. Tests 3/3. | **You:** incremental ARB migration of remaining hardcoded UI strings; native-speaker polish pass on Hindi strings before ship. |
| Audio 82 (Opus 4.7, 2026-04-24) | `AudioService` interface + `FakeAudioService`, `audioServiceProvider` (Riverpod, keepAlive), `audioPlaybackStateProvider` stream. Tests 6/6. | **You:** `flutter pub add just_audio audio_service` (+ platform setup), implement `JustAudioService` against the interface, swap default in provider; supply PD audio URLs. |
| Structural refactor (Opus 4.7, 2026-04-24) | Extracted `ExpandableSection`, `verseSectionDivider`, `CommentariesBlock`, `AiExplanationBlock`, `VerseContentSliver` (+ `_SanskritBlock` + `_TamilBlock` + `stripVedicAccents`) into `scripture_reader/widgets/` and `core/utils/`. `verse_detail_page.dart` **1529 → 898 lines (−41%)**. `flutter analyze --fatal-infos` clean. | Future: `verse_detail_page.dart` still contains `_VerseScaffold`, `_VerseNavBar`, `_TranslationToggle`, `_NotesBottomSheet`, `_BookmarkAction` — further splitting optional. |
| Widget tests + coverage (Opus 4.7, 2026-04-24) | `test/presentation/commentaries_block_test.dart` — 7 widget tests using `ProviderScope` overrides (empty, English l10n, **Hindi l10n**, expand/collapse, CC-BY-SA license, multi-tradition, Sanskrit-only). `test/core/verse_text_test.dart` — 7 unit tests for `stripVedicAccents` pinning its de-facto anusvara-stripping behaviour. **Total suite: 137/137 green, 18 test files.** | — |
| i18n migration round 2 (Opus 4.7, 2026-04-24) | ARB strings expanded ~5 → ~40 keys (Settings page, nav, common, verse-of-day, bookmarks, search). English + Hindi covered. Settings page migrated as the pattern. | You: incremental migration of remaining ~150 hardcoded strings across the app; native-speaker polish on Hindi. |
| Ultimate review — security + perf + architecture (Opus 4.7, 2026-04-24) | **Security:** secrets via `String.fromEnvironment` / `--dart-define` (not in source); `.env` gitignored; SQL uses parameterized `Variable.withString`; FTS5 sanitises `"` in queries; `url_launcher` uses `canLaunchUrl` gate + `externalApplication` mode (no in-app WebView — no XSS surface); all launched URLs are app-hardcoded; Crashlytics records only error + reason, no user data. **Architecture:** presentation → domain → data layers clean; Riverpod DI, Drift local DB, fpdart Either for failures — no inconsistencies. **Performance:** `flutter analyze --fatal-infos` passes; no N+1 DB queries; no non-lazy list rendering in lib; no `await` in `for` loops; 4 Theme.of calls in 855-line library page (acceptable). **No blocking findings.** | See "Known non-blockers" below. |

**Cleanup staging (Opus 4.7, 2026-04-24):** 15 files totalling **3.2 MB** (code exports, per-AI redesign docs superseded by REDESIGN_FINAL.md, conversation bundles) moved to `_review_delete/` with a README. No code references moved content. Delete with `rm -rf _review_delete/` when reviewed.

**Known non-blockers (2026-04-24):**
- User's personal `noteText` on verses is stored locally in SQLite at rest on device. Not exfiltrated anywhere. If the app ever adds cloud sync, note content becomes user data subject to the usual encryption-in-transit / at-rest considerations.
- `tool/sources/wyv/` contains archived Sacred-Text Archive HTML with embedded Google Tag Manager JS. **Not shipped in the app** (only `assets/db/`, `assets/fonts/`, `assets/images/`, `assets/icons/` are bundled). Safe but adds ~bulk to the repo.
- `verse_detail_page.dart` still contains `_VerseScaffold`, `_VerseNavBar`, `_TranslationToggle`, `_NotesBottomSheet`, `_BookmarkAction` (898 lines total). Further splitting is optional — all are tightly coupled to `VerseDetailPage` state.
- ~150 hardcoded English strings remain in the UI outside Settings + commentary block. Covered keys have English + Hindi; rest need incremental migration.
- `just_audio` not yet added to `pubspec.yaml`; default audio provider is `FakeAudioService`. No verse-detail play button wired yet.

**Verification commands (repo root):**  
`dart run tool/verify_rigveda_db.dart` · `dart run tool/verify_atharvaveda_db.dart` · `dart run tool/verify_samaveda_db.dart` · `dart run tool/verify_yajurveda_db.dart` · `dart run tool/verify_tirukkural_db.dart` · `dart run tool/verify_ramayana_db.dart` · `dart run tool/verify_mahabharata_db.dart` · `dart run tool/verify_bhagavata_purana_db.dart`

### What's NOT Built
- i18n / multi-language
- FTS5 search (using LIKE — slow); see `CURRENT_SPRINT` / DAO TODO
- AI features (Phase 3 in sprint)
- Audio
- Commentary system (beyond verse text)
- Subscription / monetization
- User accounts / auth
- Community features
- **Note:** Settings, streak UI, gamification v1, library cards, and redesign items above are **shipped** — see `REDESIGN_FINAL.md` and `CURRENT_SPRINT.md` for detail.

---

## THE PLAN

### Legend
- 🟢 **DO NOW** — Zero cost, you + AI can build it
- 🟡 **DO SOON** — Zero cost but needs time/research
- 🔴 **DO LATER** — Needs money, partnerships, or traction first
- ⚪ **NEVER (solo)** — Requires a team; park it

---

## TIER 1: SHIP V1 (Weeks 1–4)
> Goal: Get on Play Store with a genuinely excellent Gita + Upanishads experience.

### 1A. Fix Critical MVP Gaps

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 1 | **Streak counter on Home screen** — data exists, just wire UI (flame icon + count next to greeting) | 2 hrs | 🟢 |
| 2 | **Settings page** — dark/light toggle, notification time picker, font size slider, about/credits, clear cache | 1 day | 🟢 |
| 3 | **App icon + splash screen** — design with AI image gen (Midjourney/DALL-E free tier or Figma), Om motif, saffron/indigo | 3 hrs | 🟢 |
| 4 | **Remove NativeAdWidget from v1** — ship ad-free initially, earn trust (add ads later when you have users) | 30 min | 🟢 |
| 5 | **Verify IAST rendering** — write a test that checks every diacritic (ā ī ū ṭ ḍ ṇ ś ṣ ḥ ṃ) renders in Tiro Devanagari Sanskrit font | 2 hrs | 🟢 |
| 6 | **Verify offline works** — airplane mode test, document in README | 1 hr | 🟢 |
| 7 | **Fix search — upgrade to FTS5** — `scripture_dao.dart` explicitly marks this as TODO, LIKE won't scale on 71MB DB | 1 day | 🟢 |
| 8 | **Create `.env.example`** with Firebase/AdMob keys template | 15 min | 🟢 |

### 1B. Polish the Reading Experience

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 9 | **Reading mode toggle** — Sanskrit only / Sanskrit + transliteration / Translation only — per the redesign docs (all 4 suggested this) | 1 day | 🟢 |
| 10 | **Font size control** — slider in Settings, persisted via SharedPreferences, affects verse display | 3 hrs | 🟢 |
| 11 | **Verse swipe navigation** — PageView for prev/next verse (Gemini redesign doc recommends this) | 4 hrs | 🟢 |
| 12 | **Chapter progress indicator** — show X/Y verses read per chapter (data already tracked via readCount) | 3 hrs | 🟢 |
| 13 | **Smooth page transitions** — flutter_animate is already a dependency, add subtle fade/slide | 2 hrs | 🟢 |
| 14 | **Scripture library grouping** — group by category (Shruti, Smriti, Darshana, etc.) instead of flat list | 3 hrs | 🟢 |

### 1C. Content Quality Pass

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 15 | **Audit Gita translations** — spot-check 50 random verses against authoritative sources (Gita Supersite, Swami Gambirananda) | 4 hrs | 🟢 |
| 16 | **Audit Upanishad content** — verify 11 Upanishads have consistent formatting, no broken Sanskrit | 4 hrs | 🟢 |
| 17 | **Mark "sampler" scriptures clearly** — Vedas/Puranas show "Selected Highlights" badge so users don't think content is missing | 2 hrs | 🟢 |
| 18 | **Add scripture descriptions** — 2-3 sentence intro for each scripture visible in the library (what it is, why read it) | 3 hrs | 🟢 |
| 19 | **Content attribution** — credits screen listing all translation sources (Griffith, Ganguli, etc.) with licensing notes | 2 hrs | 🟢 |

### 1D. Play Store Readiness

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 20 | **Play Store listing copy** — title, short desc, full desc with keywords | 2 hrs | 🟢 |
| 21 | **Screenshots** — 5-8 screenshots of real app screens (phone frame mockups via screenshots.pro or Figma) | 3 hrs | 🟢 |
| 22 | **Feature graphic** (1024×500) — AI-generated + Figma polish | 1 hr | 🟢 |
| 23 | **Privacy policy page** — host on GitHub Pages (free), required for Play Store | 2 hrs | 🟢 |
| 24 | **`flutter build appbundle`** — test release build, verify ProGuard, check APK size (<30MB target) | 3 hrs | 🟢 |
| 25 | **Content rating questionnaire** — fill out Play Console form | 30 min | 🟢 |
| 26 | **Play Console developer account** — $25 one-time fee (only "cost" in the entire v1) | — | 🟢 |

**V1 Total Effort: ~2-3 weeks of focused work**

---

## TIER 2: EARN FIRST 1,000 USERS (Weeks 5–12)
> Goal: Get real users, real reviews, real retention data.

### 2A. Organic Distribution (Zero Cost)

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 27 | **r/hinduism presence** — answer 2-3 questions/week genuinely for 4+ weeks BEFORE mentioning the app | Ongoing | 🟢 |
| 28 | **r/sanskrit** — share transliteration tips, reference the app's IAST accuracy as proof of concept | Ongoing | 🟢 |
| 29 | **Quora answers** — "best Bhagavad Gita app" "best Hindu scripture app" — detailed, helpful answers | Ongoing | 🟢 |
| 30 | **Daily verse graphics** — auto-generate from ShareCardGenerator, post on Instagram/X | 15 min/day | 🟢 |
| 31 | **WhatsApp family groups** — share app with extended family, ask for honest feedback | Once | 🟢 |
| 32 | **YouTube Shorts** — screen recordings of app in action, 30-60 seconds, "Did you know this verse means..." | 2 hrs/week | 🟡 |
| 33 | **GitHub open-source the non-proprietary parts** — seed scripts, parsers → builds developer credibility | 1 day | 🟡 |

### 2B. Retention Engineering

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 34 | **Gamification v1** — badge system on top of existing streak (3-day, 7-day, 30-day, 100-day badges with Hindu motifs) | 2 days | 🟢 |
| 35 | **Reading streak calendar** — GitHub-style heatmap on Home using readHistory data (already tracked) | 1 day | 🟢 |
| 36 | **Push notification tuning** — festival-aware daily verse, Ekadashi alerts, auspicious day content | 1 day | 🟢 |
| 37 | **"What to read today" suggestion** — based on Panchang (e.g., Monday → Shiva content, Thursday → Guru-related verses) | 1 day | 🟢 |
| 38 | **Review prompt** — after 7-day streak OR finishing first chapter OR completing first learning module | 3 hrs | 🟢 |
| 39 | **Onboarding survey** — Beginner/Regular/Scholar → adjust home screen content recommendations | 1 day | 🟢 |

### 2C. Content Expansion (Zero Cost, Your Time)

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 40 | **Complete Rigveda** — DharmicData Sanskrit + Griffith English pipeline already half-built (`parse_rigveda.dart`) | 2 days | 🟢 |
| 41 | **Complete Atharvaveda** — parser exists, English pending from Griffith/Bloomfield PD sources | 2 days | 🟢 |
| 42 | **Complete Samaveda + Yajurveda** — parsers + HTML sources partially exist | 2 days | 🟢 |
| 43 | **Ramayana** — Python parser exists (`parse_ramayana.py`), source: Griffith PD translation | 2 days | 🟡 |
| 44 | **Mahabharata** — parser exists (`parse_mahabharata.py`), Ganguli PD translation (massive — prioritize Bhishma Parva + Shanti Parva) | 3 days | 🟡 |
| 45 | **Bhagavata Purana** — parser exists, selected cantos from PD sources | 2 days | 🟡 |
| 46 | **Tirukkural** — parser exists, PD Tamil + English; supports Tamil user persona | 1 day | 🟡 |
| 47 | **Arthashastra** — parser exists, Shamasastry PD translation | 1 day | 🟡 |

### 2D. UX Improvements

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 48 | **Implement best ideas from the 4 redesign docs** — synthesize Gemini/DeepSeek/GPT/Grok recommendations into one design pass | 1 week | 🟢 |
| 49 | **Scripture library → beautiful cards** with scripture category icons (Shruti/Smriti/Darshana) | 2 days | 🟢 |
| 50 | **Home screen redesign** — add streak badge, reading progress ring, "Today's Panchang" card, learning progress | 2 days | 🟢 |
| 51 | **Verse detail page polish** — progressive disclosure (tap to expand word meanings), better typography hierarchy | 1 day | 🟢 |
| 52 | **Dark mode audit** — every screen tested in dark, ensure pure dark (#1A1A2E) not muddy grey | 3 hrs | 🟢 |

---

## TIER 3: DIFFERENTIATE (Months 3–6)
> Goal: Build features NO competitor has. This is where you win or lose.

### 3A. AI Features (Zero/Low Cost)

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 53 | **AI Verse Explanation v1** — tap any verse → plain-language explanation generated by Gemini/Claude API (free tiers: Gemini 1.5 Flash = free 15 RPM) | 3 days | 🟢 |
| 54 | **"Ask about this verse" chat** — user types follow-up questions, AI responds citing the verse + related verses | 3 days | 🟢 |
| 55 | **Cross-scripture connections** — AI generates "Related verses" linking Gita → Upanishads → Yoga Sutras | 2 days | 🟢 |
| 56 | **Pre-generate explanations** — run AI on all 700 Gita verses offline, store in DB (no API cost per user) | 1 day | 🟢 |
| 57 | **AI disclaimer** — every AI response shows "AI-generated explanation. Always refer to traditional commentaries." | 1 hr | 🟢 |

**Cost reality:** Gemini 1.5 Flash free tier = 15 requests/minute, 1M tokens/day. For a solo app with <10K users, this is effectively free. Pre-generate heavy content offline to minimize runtime API calls.

### 3B. Cross-Scripture Search (Your #1 Differentiator)

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 58 | **FTS5 virtual table** — index all verses across all scriptures | 1 day | 🟢 |
| 59 | **Search results grouped by scripture** — "karma" → Gita (12 results) + Upanishads (5) + Yoga Sutras (3) | 1 day | 🟢 |
| 60 | **Search suggestions / autocomplete** — popular terms: dharma, karma, atman, brahman, moksha | 3 hrs | 🟢 |
| 61 | **Semantic search v1** — use pre-computed embeddings (sentence-transformers, run once offline, store vectors in SQLite) | 3 days | 🟡 |

### 3C. Commentary System

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 62 | **Commentary entity + table** — `commentaries` table: verse_id, tradition, author, text | 2 hrs | 🟢 |
| 63 | **Seed Shankaracharya commentary on Gita** — PD (Advaita tradition, pre-8th century) from freely available sources | 2 days | 🟢 |
| 64 | **Commentary toggle on verse detail** — expandable section showing available commentaries | 1 day | 🟢 |
| 65 | **Seed Ramanujacharya commentary** — PD (Vishishtadvaita, pre-12th century) | 2 days | 🟡 |
| 66 | **Side-by-side comparison view** — Advaita vs Vishishtadvaita vs Dvaita on same verse | 2 days | 🟡 |
| 67 | **ISKCON / Chinmaya commentary** — ⚠️ COPYRIGHTED — requires licensing deal | — | 🔴 |

### 3D. Audio (Progressive Approach)

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 68 | **TTS Sanskrit recitation** — use device TTS or Google Cloud TTS free tier (4M chars/month free) for basic chanting | 2 days | 🟢 |
| 69 | **Source free audio** — archive.org has PD Gita recitations; parse, trim, map to verses | 3 days | 🟡 |
| 70 | **Audio player UI** — play/pause, speed control, auto-advance to next verse | 2 days | 🟢 |
| 71 | **Professional studio recording** — Gita chapter 1–18 by trained reciter | — | 🔴 |

### 3E. i18n / Multi-Language

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 72 | **Set up flutter_localizations + .arb files** — English first, Hindi second | 1 day | 🟢 |
| 73 | **Hindi UI translation** — all UI strings (not scripture content, just buttons/labels/navigation) | 1 day | 🟢 |
| 74 | **Tamil UI translation** — use AI for first draft, get a Tamil speaker to review | 1 day | 🟡 |
| 75 | **Telugu / Gujarati / Marathi** — AI-draft + community review | — | 🟡 |

---

## TIER 4: MONETIZE (Month 6+)
> Goal: Generate revenue. Only after you have 5,000+ users with proven retention.

### 4A. What You Can Build (Zero Cost Infrastructure)

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 76 | **RevenueCat integration** — free for <$2.5K MTR; handles both Play Store + App Store subscriptions | 2 days | 🟢 |
| 77 | **Paywall screen** — beautiful, non-aggressive, shows value (not a gate on Day 1) | 1 day | 🟢 |
| 78 | **Free tier definition** — ALL scriptures (1 translation), daily verse, basic bookmarks, Dharma 101 | Design | 🟢 |
| 79 | **Premium tier (India ₹99/mo)** — multiple commentaries, AI chat, advanced search, audio, offline packs | Design | 🟢 |
| 80 | **Lifetime ad removal (₹99 one-time)** — simplest first monetization test | 3 hrs | 🟢 |
| 81 | **Daana (donation) button** — frame as "Support Sanskrit Preservation", show after 7-day streak | 3 hrs | 🟢 |

### 4B. What Needs Traction First

| # | Task | When | Tag |
|---|------|------|-----|
| 82 | **Diaspora tier ($9.99/mo)** — only when you have measurable diaspora users | 5K+ diaspora users | 🔴 |
| 83 | **Content IAP packs** — "Complete Vedas Pack" etc. — only when library is actually complete | Full content | 🔴 |
| 84 | **Family sharing** — needs auth system first | Auth built | 🔴 |

---

## TIER 5: SCALE (Year 1+)
> Only pursue after proven PMF (Product-Market Fit) with 10K+ DAU.

### 5A. Community Features

| # | Task | Effort | Tag |
|---|------|--------|-----|
| 85 | **User accounts (Supabase Auth — free tier)** — email + Google sign-in | 3 days | 🟡 |
| 86 | **Cloud bookmark sync** — Supabase free tier (500MB, 50K MAU) | 2 days | 🟡 |
| 87 | **Verse annotations v1** — users can add public notes to any verse (Genius.com model) | 1 week | 🔴 |
| 88 | **Study groups** — shared reading plans with progress tracking | 2 weeks | 🔴 |
| 89 | **Discussion threads per verse** — moderated, requires community guidelines | 2 weeks | 🔴 |

### 5B. Platform Expansion

| # | Task | Tag |
|---|------|-----|
| 90 | **iOS App Store launch** — Flutter makes this "free" technically, but $99/year Apple dev fee | 🟡 |
| 91 | **Web app (Flutter web)** — good for SEO, diaspora discovery | 🟡 |
| 92 | **Wear OS widget** — daily verse on smartwatch | 🔴 |
| 93 | **Android widget** — daily verse on home screen | 🟡 |

### 5C. Things That Need Money

| # | Item | Estimated Cost | When |
|---|------|---------------|------|
| 94 | Professional Sanskrit audio (full Gita) | $5K–15K | After 10K users |
| 95 | Sanskrit scholar advisor (part-time) | ₹15–25K/month | When revenue covers it |
| 96 | UI/UX designer (contract) | ₹30–50K one-time | Before major redesign |
| 97 | Temple partnerships (travel + relationship building) | ₹20–50K | Year 2 |
| 98 | Licensed commentaries (ISKCON, Chinmaya) | Negotiation-based | Year 2 |
| 99 | Paid user acquisition (Google Ads) | ₹50K+/month | When LTV > CAC proven |
| 100 | Kids Mode content (illustrations, simplified stories) | $3K–10K | When diaspora tier exists |
| 101 | VR Temple experiences | $50K+ | Year 3+ / never solo |
| 102 | Live Gurukul classes | Partnerships | Year 3+ |

### 5D. Things to Never Build Solo ⚪

- VR Temple experiences (need 3D artists, massive budget)
- Live streaming infrastructure (use YouTube/Zoom instead)
- B2B/Institutional tier (needs sales team)
- White-label solution (enterprise product, not solo-dev scope)
- Full Mahabharata + all 18 Puranas (content too vast without a team)

---

## EXECUTION CALENDAR

### Month 1: Ship V1
```
Week 1: Tasks 1-8 (Fix MVP gaps)
Week 2: Tasks 9-14 (Polish reading experience)
Week 3: Tasks 15-19 (Content quality) + Tasks 20-26 (Store readiness)
Week 4: Final testing → SHIP TO PLAY STORE
```

### Month 2: First Users
```
Week 5-6: Tasks 27-33 (Organic distribution begins)
Week 7-8: Tasks 34-39 (Retention features) + Tasks 48-52 (UX polish)
```

### Month 3: Content Expansion
```
Week 9-10: Tasks 40-47 (Complete Vedas, add Ramayana/Mahabharata highlights)
Week 11-12: Tasks 53-57 (AI features v1)
```

### Month 4-5: Differentiation
```
Tasks 58-66 (Search + Commentary)
Tasks 68-70 (Audio v1)
Tasks 72-75 (i18n)
```

### Month 6: Monetize
```
Tasks 76-81 (Subscription infrastructure)
Evaluate: Do you have 5K+ users? Good retention? If yes → invest further.
If no → analyze why, pivot content/marketing strategy.
```

---

## KEY METRICS TO TRACK (All Free via Firebase Analytics)

| Metric | V1 Target | Month 3 Target | Month 6 Target |
|--------|-----------|----------------|----------------|
| Total installs | 500 | 3,000 | 10,000 |
| DAU | 50 | 300 | 1,000 |
| D1 retention | 40%+ | 45%+ | 50%+ |
| D7 retention | 20%+ | 25%+ | 30%+ |
| D30 retention | 10%+ | 15%+ | 20%+ |
| Avg session duration | 5 min | 7 min | 10 min |
| Play Store rating | 4.3+ | 4.5+ | 4.7+ |
| Reviews | 20+ | 100+ | 500+ |
| Avg streak | 3 days | 5 days | 8 days |
| Crash-free rate | 99%+ | 99.5%+ | 99.5%+ |

---

## CURATED RESOURCE LISTS (Your Knowledge Arsenal)

> See **AWESOME_RESOURCES.md** for 48 curated "awesome" lists evaluated for this project.
> Key ones to use at each tier:
>
> - **Tier 1 (Ship V1):** awesome-flutter, awesome-firebase, awesome-ASO, awesome-a11y, awesome-privacy-engineering
> - **Tier 2 (First Users):** Mobbin + Laws of UX + Checklist Design (UI polish), awesome-i18n (Hindi store listing)
> - **Tier 3 (Differentiate):** awesome-local-first, awesome-sqlite (sync architecture), Riverpod guide (advanced patterns)
> - **Tier 4 (Monetize):** awesome-ASO 2026 guide (retention-based ranking), India localization guide

---

## FREE TOOLS & SERVICES (Your Arsenal)

| Tool | What For | Free Tier |
|------|----------|-----------|
| Firebase Analytics | User behavior tracking | Unlimited |
| Firebase Crashlytics | Crash reporting | Unlimited |
| Firebase Remote Config | Feature flags, A/B testing | Unlimited |
| Supabase | Auth + DB + Storage (future) | 500MB DB, 50K MAU |
| RevenueCat | Subscription management | <$2.5K MTR |
| Gemini API | AI verse explanations | 15 RPM, 1M tokens/day |
| GitHub Pages | Privacy policy, landing page | Free |
| Figma | UI design | Free for 3 files |
| Canva | Marketing graphics, screenshots | Free tier |
| AI (Cursor/Claude) | Code generation, content drafts | Your current tools |
| archive.org | PD audio, texts | Free |
| sacred-texts.com | PD scripture translations | Free (attribute) |
| DharmicData (GitHub) | Sanskrit text corpus | MIT license |

---

## THE THREE RULES

1. **Don't build what you can't fill.** An empty "Community" tab is worse than no tab. An "Audio" button that says "Coming Soon" on every verse kills trust.

2. **Complete > Comprehensive.** 700 Gita verses with perfect Sanskrit, beautiful UI, working offline, and a great reading experience beats 10,000 verses across 30 scriptures with broken formatting.

3. **Ship, measure, then decide.** Every feature after v1 should be justified by user data, not by the masterplan's ambition.

---

*Last updated: April 2026*
*For: Solo developer with AI-assisted development*
*Cost: $25 (Play Console fee) — everything else is free*
