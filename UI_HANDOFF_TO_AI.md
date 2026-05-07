# Sanatan Guide — UI Handoff Doc

**Goal of this doc:** give another AI (DeepSeek / GPT / etc.) enough context to redesign every screen in this Flutter app. The current UI uses ~25 hand-coded `CustomPainter` ornaments (mandala, torana, jaali lattice, lotus, kalash, peacock, palm leaf, oil lamp, etc.) that look amateurish. We want a higher-quality replacement strategy and per-screen redesigns.

The receiving AI should output: (a) revised screen layouts, (b) recommended asset strategy per screen (SVG vs photo vs Lottie vs solid), (c) Flutter widget code that compiles against the existing tokens / providers / routes. Do **not** introduce new dependencies without flagging.

---

## 1. App overview

**Sanatan Guide** — Hindu scripture reader + daily-practice app. Solo-dev indie (Flutter). Hindi + English (`l10n`). Free with light ads (AdMob, native + app-open + interstitial inside module reader). Live in production.

Core jobs:
1. Read scripture (Bhagavad Gita full + Upanishads + Puranas + selected Vedas + stotras + sutras). Each verse: Sanskrit, transliteration, English, Hindi, commentaries, AI explanation, AI chat.
2. Daily verse-of-day, panchang almanac (vāra, tithi, next parva), upcoming festival, streak.
3. Structured learning path — 8 Foundation modules (Level 1) + Advanced (Level 2 unlocks at 4/8 done). Each module = card-deck reader.
4. Bookmarks, full-text search, festival calendar, settings, onboarding (experience-level picker).

Visual aim per CLAUDE.md / DESIGN_SYSTEM.md: **"Temple Dawn"** — warm cream palette in light mode, saffron-tinted dark mode, editorial typography, *not* SaaS. Currently fails because hand-painted ornaments look like dollar-store clip art.

---

## 2. Hard constraints (must NOT break)

Receiving AI must respect these — they're checked into the codebase, changing them breaks things.

### 2.1 Tech stack
- Flutter 3.x, Dart 3.x, Material 3.
- State: **Riverpod** (`flutter_riverpod ^3.0.0`) — code-gen via `riverpod_generator` (files end in `.g.dart`).
- Navigation: **GoRouter** (`go_router ^14.2.7`).
- Local DB: Drift, `assets/db/sanatan_guide.db`. Read-only for UI work.
- Localization: `flutter gen-l10n`, generated to `lib/l10n/generated/`.
- Animations: `flutter_animate` already in deps — preferred over hand-rolled tweens.
- Already in `pubspec.yaml`: `google_fonts`, `cached_network_image`, `shimmer`, `flutter_svg`, `lottie`, `share_plus`, `url_launcher`, `package_info_plus`, `haptic_feedback`, `fpdart`, `google_mobile_ads`, `firebase_*`, `gemini` (Google Generative AI).

### 2.2 Folder layout (do NOT move files)
```
lib/
  core/
    router/         app_routes.dart, app_router.dart   ← do not touch routes
    services/       streak, gemini, audio, ad, notification, analytics
    constants/      bhagavad_gita_chapters.dart, content_credits.dart
    utils/          panchang_utils.dart, verse_label.dart, verse_text.dart
    extensions/     typography_extensions.dart        ← context.ts.<style>
  domain/           entities + repositories + usecases (clean arch — ignore)
  data/             daos, datasources, festivals/festival_data_2026.dart
  presentation/
    theme/          app_colors.dart, app_typography.dart, app_spacing.dart, app_theme.dart
    shared/widgets/ sacred_card.dart, sacred_ornaments.dart (the bad painters),
                    scaffold_with_nav_bar.dart, shimmer_loading.dart, verse_preview_tile.dart,
                    empty_state_widget.dart, error_state_widget.dart, native_ad_widget.dart
    features/
      home/         pages/home_page.dart + widgets/* + providers/*
      scripture_reader/  pages/{scripture_library, chapter_list, verse_list, verse_detail, verse_chat} + widgets/* + providers/*
      learning_path/     pages/{learning_path, module_reader} + providers/*
      festivals/         pages/festival_calendar_page.dart
      bookmarks/         pages/bookmarks_page.dart
      search/            pages/search_page.dart
      settings/          pages/settings_page.dart, credits_page.dart
      onboarding/        pages/onboarding_page.dart
```

### 2.3 Design-token rules (enforced)
- **Never** inline `TextStyle`, `Color`, or padding values in a widget. Always import:
  - `AppColors.<token>` from `presentation/theme/app_colors.dart`
  - `AppTypography.<style>` (or shorthand `context.ts.<style>` from `core/extensions/typography_extensions.dart`)
  - `AppSpacing.<token>` from `presentation/theme/app_spacing.dart`
- New tokens are OK — add them to those files. Don't sprinkle hex codes.
- Use `Theme.of(context).brightness == Brightness.dark` for dark-mode branching. Both modes must be designed.

### 2.4 Routes (do NOT rename — deep links + analytics depend on them)
```
/                                              splash
/onboarding
/home                                          (shell — bottom nav)
/learn                                         (shell)
/learn/:moduleId                               module reader (no shell)
/browse                                        (shell — Library)
/browse/:scriptureId                           chapter list
/browse/:scriptureId/chapter/:chapterNum       verse list
/browse/:scriptureId/verse/:verseId            verse detail (no shell)
/browse/:scriptureId/verse/:verseId/chat       AI chat (no shell)
/festivals                                     (shell)
/bookmarks                                     (shell)
/search
/settings
/credits
```

Bottom nav has 3 tabs: **Today (`/home`)**, **Practice (`/learn`)**, **Texts (`/browse`)**. Festivals + bookmarks reachable from in-screen entry points, not the nav bar.

### 2.5 Fonts (declared in `pubspec.yaml`)
- `TiroDevanagari` — Sanskrit display (large/medium/small).
- `NotoSansDevanagari` — Hindi body text.
- `Lora` — English serif (display + body in scripture/editorial contexts).
- `Outfit` — UI sans (labels, buttons, nav, captions, section headers).
- All four loaded via local font files. Don't switch to Google Fonts CDN — offline-first matters.

---

## 3. Design tokens (verbatim — copy these into the redesign)

### 3.1 Colors (`AppColors`)

```dart
// Brand
saffron        = #E8820C   // primary accent (light mode + buttons)
saffronOnDark  = #F4A830   // brighter saffron for dark mode contrast
onSaffron      = #FFFFFF   // text/icon on saffron fill
deepRed        = #8B0000   // secondary, anchors, verse-number badges
gold           = #FFD700   // sparingly, festival badges

// Light surfaces (warm, NOT pure white)
cream            = #FDFAF6   // scaffold bg
surface          = #F7F2EC   // cards
surfaceVariant   = #EDE8E2   // input fields

// Dark surfaces (warm near-black, NOT #000000)
bgDark            = #0F0F0F   // scaffold
surfaceDark       = #1C1816   // cards
surfaceElevated   = #221E1B   // sheets / modals
surfaceHighest    = #2A2520   // chips

// Text — light mode
textPrimary    = #1A1210
textSecondary  = #6B6360
textHint       = #9E9A97

// Text — dark mode
textOnDark           = #F0EBE5
textSecondaryOnDark  = #9B9390

// Semantic
success / successLight = #2E7D32 / #C8E6C9
error   / errorLight   = #B71C1C / #FFCDD2
warning / warningLight = #F57F17 / #FFF9C4

// Dividers / borders
divider     = #E0D9CF      borderLight  = #CCC5BB
dividerDark = #2E2A27      borderDark   = #3A3531

// Scripture text colors
sanskritText        = #2D1B00   // Sanskrit on light
sanskritTextOnDark  = #E8D9C0
translitText        = #5A3E28   // italic transliteration
englishText         = #1A1A1A

// Saffron opacity variants (use these — don't .withValues hand-rolled)
saffronFaint  = saffron @ 8%    // chip/icon bg
saffronMuted  = saffron @ 12%   // badge, hover
saffronLight  = saffron @ 15%   // card fill
saffronBorder = saffron @ 30%   // accent border
deepRedMuted  = deepRed @ 12%
successMuted  = success @ 30%
borderFaint(Dark) = border @ 40%

// Warm grey (neutral UI — replaces saffron when not sacred)
warmGrey10 = #F2EDE6   // hover/selected on cream
warmGrey50 = #8A7968   // secondary UI / meta
warmGrey80 = #3A322B   // primary text on cream (softer than textPrimary)

// Share-card bg (warmer than #0F0F0F)
shareCardBg = #0F0B07

// Scripture-library category accents (left border per chip)
catItihasa   = #C45C2A     catVeda      = #B85C1C
catUpanishad = #6B5B95     catDarshana  = #9B7928
catStotra    = #B56576     catShastra   = #8D6E63
catTantra    = #7B5B8A     catTamil     = #9B5E3A
```

### 3.2 Typography (`AppTypography` / `context.ts.*`)

```
sanskritLarge   TiroDevanagari    32 / lh 2.4 / ls 0.8
sanskritMedium  TiroDevanagari    22 / lh 2.0 / ls 0.3
sanskritSmall   TiroDevanagari    18 / lh 2.0 / ls 0.2

transliteration Lora italic       15 / lh 1.6 / ls 0.3   color translitText
hindiLarge      NotoSansDevanagari 18 / lh 1.6
hindiBody       NotoSansDevanagari 16 / lh 1.6

displayLarge    Lora w600         32 / lh 1.3 / ls -0.5  // hero text
displayMedium   Lora w600         24 / lh 1.3            // appbar titles
titleLarge      Lora w600         20 / lh 1.35           // card titles, module titles
titleMedium     Lora w600         17 / lh 1.4            // subsection titles
labelXLarge     Outfit w500       15 / lh 1.4            // body buttons, nav labels
bodyLarge       Lora              18 / lh 1.6            // verse English
bodyMedium      Lora              16 / lh 1.6
labelLarge      Outfit w600       16 / lh 1.3            // CTAs
labelMedium     Outfit w500       14
labelSmall      Outfit w500       12  color textSecondary
caption         Outfit            13  color textSecondary
sectionLabel    Outfit w700       11 / ls 1.5            // UPPERCASE headers
cardLabel       Outfit w600       12 / ls 0.5  saffron   // KEY VERSE / ANCHOR
captionHighlight Outfit w600      13           saffron   // streak count, %
emojiBanner     22 / lh 1     emojiInline      15 / lh 1
```

### 3.3 Spacing + radius (`AppSpacing`)

```
xs 4    sm 8    md 12   lg 16   xl 24   xxl 32   xxxl 48   huge 64
cardPadding 16   pagePadding 24   sectionGap 32   listItemSpacing 12

// Tiered radius (use these, not a single global radius)
radiusRow   4    list rows / manuscript page feel
radiusChip  8    small chips, badges
radiusCard  16   content cards
radiusHero  24   verse-of-day, featured scripture
radiusSheet 20   share card, bottom sheets

verseLineHeight 1.9   bodyLineHeight 1.6   labelLineHeight 1.3
```

---

## 4. The painter problem — what to kill, what to keep

`lib/presentation/shared/widgets/sacred_ornaments.dart` is **2187 lines** of `CustomPainter` widgets. They look bad. List + verdict:

| Widget | Lines | Used in | Verdict |
|---|---|---|---|
| `MandalaBackdrop` | 23–145 | almanac icons / settings header | **REPLACE** with subtle SVG mandala (Noun Project) faded to 6% opacity, or kill entirely |
| `ToranaArch` | 147–284 | verse-of-day card crown | **REPLACE** — this is the worst offender. Use a hand-illustrated SVG temple arch (or just drop, let typography carry the card) |
| `VineFlourish` | 286–372 | verse-of-day divider | **REPLACE** with Unicode `❦` / `༄` glyph in Lora, or a 1px hairline + diamond, or thin SVG flourish |
| `JaaliLattice` | 374–489 | verse-of-day backdrop, hero cards | **REPLACE** with tileable SVG jaali pattern at 5–8% opacity (search "jali pattern svg" — many CC0 sources) |
| `LotusMedallion` | 491–617 | onboarding, learning path | **REPLACE** with SVG lotus from `flaticon` or commission Fiverr ₹500 illustration |
| `KalashFinial` | 618–759 | verse-of-day top corners | **DROP** — corners don't need decoration. Or replace with a single dot/diamond accent |
| `GangaWaveBackdrop` | 761–929 | onboarding bg | **REPLACE** with photo (unsplash: ghats / temple silhouette / dawn over river) blurred + dark overlay |
| `SeedlingIcon`, `DiyaIcon`, `ScrollIcon` | 931–1151 | various small icons | **REPLACE** with `phosphor_flutter` or `lucide_icons` package — already has clean glyphs |
| `PeacockIllustration` | 1153–1387 | empty states, settings | **REPLACE** with Lottie animation or commissioned SVG. Peacock is too detailed for hand-painting |
| `ForestDappleBackdrop` | 1389–1433 | unused-ish backdrop | **DROP** |
| `NalandaArchBackdrop` | 1435–1497 | scripture library appbar | **REPLACE** with a faint photo or full SVG arch. Currently too geometric |
| `PalmLeafBorder` | 1499–1544 | section dividers | **REPLACE** with a 1px hairline + center glyph, or a thin SVG strip |
| `PrasadTrayIllustration` | 1546–1634 | bookmarks empty state | **REPLACE** with a single SVG icon ("bookmark / saved verses / empty plate") — a tray painted in Flutter looks cartoonish |
| `DiyaFlameIcon` | 1636–1688 | streak indicator | **KEEP** if cleaned up — a single flame is paintable, but consider Lottie for a flicker animation |
| `TempleStaircaseBackdrop` | 1690–1738 | learning path appbar | **REPLACE** with photo (temple steps, low-saturation) or solid color |
| `PeepalTreeBackdrop` | 1740–1811 | settings / onboarding | **REPLACE** with SVG silhouette or photo |
| `DhyanaAsanaBackdrop` | 1813–1884 | onboarding meditation step | **REPLACE** with photo or commissioned SVG |
| `OilLampRowDivider` | 1886–end | settings section dividers | **REPLACE** with a `Divider(thickness:1, color: dividerLight/Dark)` plus a centered diya glyph or single Unicode ornament |

Also kill / rework:
- `lib/presentation/features/home/widgets/dawn_horizon.dart` — sun + rays painter behind verse card. The radial gradient is OK, the ray strokes look stiff. **Replace with** pure radial-gradient backdrop (no rays), or an SVG horizon with subtle texture.
- `lib/presentation/features/home/widgets/almanac_tiles.dart` `_SunPainter` / `_MoonPainter` / `_MandalaPainter` — small icons inside the almanac tiles. Workable but plain. **Replace with** `phosphor_flutter` (sun, moon-stars, sparkle) or simple SVG.
- `lib/presentation/shared/widgets/scaffold_with_nav_bar.dart` `_SunriseIconPainter`, `_LotusIconPainter`, `_ScrollIconPainter` — bottom-nav icons. Acceptable but generic. **Replace with** `phosphor_flutter` (sun-horizon, flower-lotus, scroll) for a more uniform stroke.

### Recommended replacement strategy (priority order)

1. **Phosphor / Lucide icons** (`phosphor_flutter`, `lucide_icons`) — for all small UI icons. Free, consistent stroke, drop-in replace `Icons.*` and painter icons.
2. **Static SVGs in `assets/svg/`** — for ornaments (jaali, torana, vine, mandala, lotus). Source from:
   - The Noun Project (CC license, ₹0–500 one-time)
   - Freepik (filter: vector + free)
   - SVGRepo (CC0)
   - Fiverr — ₹500–2000 buys a custom 5-piece ornament set
3. **Lottie** — for *one* hero animation (e.g. verse-of-day shimmer, streak diya flicker). Not for chrome.
4. **Photos** (unsplash / pexels — both free for commercial) — for full-bleed backdrops (onboarding, library appbar, festival hero). Apply: `ColorFiltered` desaturate + dark overlay + `BackdropFilter` blur, so the photo reads as texture not literal.
5. **Pure typography + dividers** — for everything else. The app's strongest asset is the type stack (TiroDevanagari + Lora). Stop fighting it with painted noise.

### Asset folders to add
```
assets/
  svg/ornaments/    jaali.svg, torana.svg, vine_flourish.svg, lotus_medallion.svg, mandala.svg
  svg/icons/        diya_flame.svg, conch.svg, om.svg
  lottie/           streak_flame.json, dawn_loop.json
  images/           ghats_dawn.jpg, temple_steps.jpg, peepal_silhouette.jpg, jaali_texture.png
```
Add to `pubspec.yaml` under `flutter: assets:`.

---

## 5. Per-screen briefs

Format per screen: **Route · Purpose · Data shown · Interactions · Current chrome · What to redesign**.

### 5.1 Splash → Onboarding

- **Route:** `/` → `/onboarding` (if not seen)
- **File:** `lib/presentation/features/onboarding/pages/onboarding_page.dart`
- **Purpose:** 2-step intro. Step 0 = welcome + skip. Step 1 = experience-level picker (`UserExperienceLevel.beginner | curious | practitioner | scholar`).
- **Data:** none on read; writes `userExperienceLevelProvider` and `OnboardingService.markComplete()` then `context.go('/home')`.
- **Interactions:** Continue button, Skip (top-right X), back arrow on step 1, level radio cards on step 1.
- **Current chrome:** `GangaWaveBackdrop` (CustomPainter waves) full-bleed behind both steps. Slide transition between steps. Skip uses `_skipToHome()`.
- **Redesign asks:**
  - Replace `GangaWaveBackdrop` with one of: blurred photo of ghats at dawn, OR full-bleed solid `cream`/`bgDark` with a single SVG ornament top-right.
  - Step 0: large display heading (Lora 32) "Welcome to Sanatan Guide", short subtitle (bodyLarge), big primary CTA "Begin", small text-button "Skip for now".
  - Step 1: 4 selectable level cards. Each card = icon + title + 1-line description. Use Phosphor icons (Seedling, Compass, Flame, BookOpen). Card selected state = saffron border + `saffronFaint` fill.
  - Animations: `flutter_animate` fade+slide on step transition (already present, keep).

### 5.2 Home / Today

- **Route:** `/home`
- **File:** `lib/presentation/features/home/pages/home_page.dart`
- **Purpose:** daily landing — verse of day, panchang almanac, upcoming festival, learning progress, streak.
- **Data (Riverpod):**
  - `verseOfDayProvider` → `Either<Failure, Verse>` (Sanskrit, English, scripture, chapter, verseNum)
  - `modulesProvider` → list of `LearningModule`
  - `lastReadVerseProvider` → resume hint
  - `currentStreakProvider` → int days
  - `festivalsProvider` → list of `Festival` (date, name, isToday, isPast)
  - panchang derived from `PanchangUtils.getVaraForDate(now)` and `getTithiForDate(now)` (no provider)
- **Sections (current order):** HomeAppBar (greeting + search + settings) → DawnHorizon painter → VerseOfDayCard → AlmanacTiles → FestivalBanner → PathCard → StreakLine.
- **Interactions:**
  - Tap verse-of-day → `/browse/{scriptureCode}/verse/{verseId}`
  - Tap any almanac tile → festival calendar (currently only the next-parva tile is wired)
  - Tap festival banner → `/festivals`
  - Tap path card → `/learn` (or resume specific module)
  - Pull to refresh → invalidates verse + modules providers
  - Search icon → `/search`, Settings icon → `/settings`
- **Current chrome:** `_DawnBackground` radial gradient (saffron from top, fades). `DawnHorizon` painter (sun + 5 rays). VerseOfDay card uses `JaaliLattice` backdrop + `KalashFinial` corners + `ToranaArch` crown + `VineFlourish` divider. AlmanacTiles use `_SunPainter` / `_MoonPainter` / `_MandalaPainter` icons.
- **Redesign asks:**
  - Keep the radial dawn gradient behind everything (it's the only painter that works).
  - Drop `DawnHorizon`, kalash, torana, jaali — let the verse card stand on typography + warm card color + thin saffron border.
  - Verse card layout: small `cardLabel` "VERSE OF THE DAY · BG 2.47" → large Sanskrit (TiroDevanagari 32) → 1px divider with centered `❦` glyph → English (Lora 18 italic) → footer row with reference + "Read →" arrow. Card radius `radiusHero` (24), border `saffronBorder`, surface `surface @ 80%`.
  - Almanac tiles: 3 equal columns (vāra / tithi / next parva). Each tile: phosphor icon (Sun / MoonStars / Sparkle) → label `sectionLabel` → title `titleMedium` → sub `captionHighlight`. Border `saffronBorder`, radius `radiusCard`, no painter icons.
  - Festival banner: full-bleed photo (festival-themed) with dark overlay + countdown chip + name + CTA. If no festival in next 7 days, show subtle "next celebration in N days" text-only row.
  - Path card: progress bar + "{N} of 8 modules" + last-read module title + "Continue" button.
  - Streak: row of 7 day-circles, current day filled saffron, others outlined; or single big number with diya glyph. Drop the painter flame if used.

### 5.3 Learning Path

- **Route:** `/learn`
- **File:** `lib/presentation/features/learning_path/pages/learning_path_page.dart`
- **Purpose:** 2-level module list. Level 1 = 8 Foundation modules. Level 2 unlocks at 4/8 done.
- **Data:** `modulesProvider` → `Either<Failure, List<LearningModule>>`. Each module has `id`, `title`, `subtitle`, `level (1|2)`, `sequence`, `isCompleted`, `cardCount`.
- **Sections:** Level 1 header → streak calendar (7-day) → Level 1 module cards (timeline-style with vertical connector) → Level 2 header (locked / unlocked) → Level 2 cards.
- **Interactions:** Tap card → `/learn/{moduleId}`. Locked Level 2 cards show lock icon, disabled state.
- **Current chrome:** AppBar `flexibleSpace` = `TempleStaircaseBackdrop` painter. Modules animated in with `flutter_animate` fade+slideY.
- **Redesign asks:**
  - Drop the staircase painter. Use a simple `AppBar` with `Lora 24` title "Your Path" and a thin saffron underline accent OR a low-opacity photo (temple steps) blurred.
  - Module cards: vertical timeline with a 2px saffron dotted connector between cards. Each card = number badge (01, 02, …) + title (titleLarge) + subtitle (bodyMedium textSecondary) + status chip (`Not started` / `In progress · 3 of 7` / `Completed`).
  - Completed cards: muted saffron tint, checkmark badge.
  - Level 2 locked state: full-card grey overlay + center lock icon + "Complete 4 of 8 to unlock".
  - Streak calendar: keep but simplify — 7 small circles in a row, today highlighted.

### 5.4 Module Reader

- **Route:** `/learn/:moduleId` (no shell — fullscreen)
- **File:** `lib/presentation/features/learning_path/pages/module_reader_page.dart`
- **Purpose:** card-deck reader for a learning module. Swipe / button through cards.
- **Data:** `moduleDetailProvider(moduleId)` → `ModuleDetail` with list of cards (text card, verse card, image card, etc).
- **Interactions:** Next / previous button at bottom, progress dots at top, optional verse tap → verse detail. On finish → mark module complete (writes `currentStreakProvider`) + show interstitial ad on every Nth completion.
- **Current chrome:** various sacred-ornament backdrops per card type (mandala, peepal, dhyana asana, etc.). Looks busy.
- **Redesign asks:**
  - Strip all backdrops. Each card = clean centered text on cream/dark surface.
  - Top: thin progress bar (saffron) + "Card N of M" label. No painter dots.
  - Bottom: prev / next buttons. Final card → primary button "Mark complete".
  - Verse-cards inside the deck: bordered card with Sanskrit + translation only — same component as verse-of-day but smaller (radius `radiusCard`, sanskrit `sanskritMedium`).
  - Use `flutter_animate` cross-fade between cards.

### 5.5 Scripture Library

- **Route:** `/browse`
- **File:** `lib/presentation/features/scripture_reader/pages/scripture_library_page.dart`
- **Purpose:** Browse all scriptures grouped by category (Itihasa, Veda, Upanishad, Darshana, Stotra, Shastra, Tantra, Tamil/Bhakti).
- **Data:** static list of `_BrowseSpec` (id, title, sanskrit, description, verseCount, emoji). Some flagged `isSampler` (highlights only, not full text).
- **Sections:** category sections in `_BrowseSection` groups, each with a section header + list of scripture cards.
- **Interactions:** Tap card → `/browse/{scriptureId}` (chapter list) or `/browse/{id}/chapter/1` for single-chapter scriptures (Mandukya, Isha, etc).
- **Current chrome:** AppBar `flexibleSpace` = `NalandaArchBackdrop` painter. Cards are simple.
- **Redesign asks:**
  - Drop the arch painter. Use a clean AppBar with title "Library" + bookmark action icon.
  - Each scripture card: emoji (already present) + title `titleLarge` + sanskrit name `sanskritSmall` + description `bodyMedium textSecondary` + verse count chip `labelSmall` + sampler badge if `isSampler` (deepRedMuted bg, "Highlights" label).
  - Card left border = category accent color (`AppColors.catItihasa` etc, already defined).
  - Card radius `radiusCard`, border `borderFaint` (light) / `borderFaintDark` (dark).
  - Section headers `sectionLabel` (uppercase + tracking) with optional 1px hairline below.

### 5.6 Chapter List

- **Route:** `/browse/:scriptureId`
- **File:** `lib/presentation/features/scripture_reader/pages/chapter_list_page.dart`
- **Purpose:** List chapters for a multi-chapter scripture. Shows progress per chapter (e.g. "12 of 47 verses read").
- **Data:** `chapterOutlineProvider(scriptureId)`, `chapterProgressProvider`.
- **Sections:** AppBar with scripture title, body = list of chapter rows.
- **Each row:** chapter number / Sanskrit title / English title (`bhagavad_gita_chapters.dart` for BG) / verse count / progress bar.
- **Redesign asks:**
  - Clean list-row layout (`radiusRow` 4dp). Each row: leading number badge (saffron when in progress, green when completed) → primary title (`titleMedium`) → secondary line (`labelSmall` — verse count + progress %).
  - Inline 1px progress bar (saffron) at the bottom of each row, hidden if 0%.
  - Sticky section header at top showing scripture name + total progress.

### 5.7 Verse List

- **Route:** `/browse/:scriptureId/chapter/:chapterNum`
- **File:** `lib/presentation/features/scripture_reader/pages/verse_list_page.dart`
- **Purpose:** All verses in a chapter, scrollable list.
- **Data:** `chapterVersesProvider(scriptureId, chapterNum, bookNum?)` → `Either<Failure, List<Verse>>`.
- **Each row:** verse number + first line of Sanskrit (`sanskritSmall`) + English preview (`bodyMedium` 2 lines max) + bookmark icon.
- **Interactions:** Tap row → verse detail. Bookmark toggles `bookmarksProvider`.
- **Redesign asks:**
  - Use `verse_preview_tile.dart` shared widget. Compact tile: leading verse-number badge (`deepRedMuted` bg, deepRed text) → 2-line preview → trailing bookmark.
  - Sticky search bar at top of list (per-chapter find).
  - Continue-reading FAB if `chapterProgressProvider` has a last-read verse — jumps user there.

### 5.8 Verse Detail (the most important screen)

- **Route:** `/browse/:scriptureId/verse/:verseId` (no shell)
- **File:** `lib/presentation/features/scripture_reader/pages/verse_detail_page.dart` (1349 lines — biggest screen)
- **Purpose:** Read one verse in full: Sanskrit + transliteration + Hindi + English + commentaries (multiple authors) + AI explanation + share.
- **Data (Riverpod):**
  - `verseDetailProvider(verseId)` → `VerseDetail` (verse, neighbors, commentaries, AI explanation cache)
  - `bookmarksProvider`
  - `readingModeProvider` (light / dark / sepia toggle for reader)
  - `fontSizeProvider` (sm / md / lg / xl)
  - `chapterProgressProvider`
- **Sections (vertical scroll):**
  1. AppBar with back, verse label (e.g. "BG 2.47"), prev/next chevrons, more menu (share, copy, font-size, reading-mode)
  2. Sanskrit (`sanskritLarge`, centered)
  3. Transliteration (italic, Lora)
  4. Hindi translation (NotoSansDevanagari)
  5. English translation (Lora bodyLarge)
  6. Section header "Commentary" → expandable cards per commentator (Shankara, Ramanuja, Madhva, etc — `commentary_formatting.dart` defines styles)
  7. Section header "AI Explanation" → Gemini-generated, with citations + "Ask follow-up" button → `/browse/.../verse/.../chat`
  8. Footer: prev verse button | Share button | next verse button
- **Interactions:** Tap word in Sanskrit → padapāṭha popup (per-word meaning) — currently inline-on-tap. Long-press verse → action sheet (copy, share, bookmark). Pinch / font-size buttons resize body. Reading-mode toggle in app-bar menu changes scaffold bg + text color (sepia = warm paper).
- **Current chrome:** sanctum_card.dart wraps each block; `gutter_rail.dart` is a left margin rail with verse-number anchor. share_card_widget renders an Instagram-ratio export.
- **Redesign asks:**
  - Keep the structure (it's good). Strip the chrome decoration:
    - Verse label appbar: small top bar, left = back chevron, center = `BG 2.47` in `labelLarge` Outfit caps + tracking, right = bookmark + more.
    - Reader body: `pagePadding` 24dp, max-width clamp ~720px on tablets.
    - Sanskrit block: `sanskritLarge` centered, line-height 2.4. Add a deepRed drop-cap on first character (Lora 64) — *editorial signal*.
    - Transliteration: italic Lora 15, color `translitText`, max-width 60ch.
    - Translations: each language as a labeled block — `cardLabel` "हिन्दी" / "ENGLISH" → body. Alternate left-aligned blocks separated by 1px hairline.
    - Commentary: collapsible cards. Expanded card = author name `titleMedium` + tradition tag `labelSmall` + body `bodyMedium`. Saffron 2px left bar when expanded.
    - AI explanation block: distinct visual treatment — `surfaceHighest` bg, small "AI" chip, `bodyMedium` text, citations inline with footnote-style superscripts.
  - Drop any backdrops / mandala / jaali under text.
  - Keep `flutter_animate` micro-fades for block reveal on scroll-into-view.
  - Reading-mode sepia: scaffold #F4ECDD, text #2D1B00, no other change.
  - Share-card (`share_card_widget.dart`): keep, but redesign using only typography + thin saffron border + verse label. Output 1080×1350.

### 5.9 Verse Chat (AI)

- **Route:** `/browse/:scriptureId/verse/:verseId/chat`
- **File:** `lib/presentation/features/scripture_reader/pages/verse_chat_page.dart`
- **Purpose:** Ask Gemini follow-up questions about the verse. Rate-limited per day (`GeminiRateLimit.maxPerDay`).
- **Data:** local `_messages` list of `ChatMessage` (user / assistant). System prompt embeds verse Sanskrit + English + scripture name. Remaining quota shown in footer.
- **Sections:** AppBar with verse label + remaining-quota chip → message list (user-right, assistant-left bubbles) → input bar with send button + suggestion chips ("Explain like I'm new", "How does this apply today?", "Cite related verses").
- **Redesign asks:**
  - Bubbles: user = saffron-filled rounded (radius 16, top-right 4 to point), assistant = `surface` filled (radius 16, top-left 4), small avatar dot.
  - Loading state: 3-dot pulse animation (use `flutter_animate`) inside an empty assistant bubble.
  - Suggestion chips above the input: scrollable horizontal row of `radiusChip` 8 chips, only shown when message list is empty or last message was assistant.
  - Quota chip in app-bar: `cardLabel` style, `saffronMuted` bg, "{N} / {max} today".
  - Empty state: small Phosphor `Sparkle` icon + "Ask anything about this verse" + first 3 suggestion chips below.

### 5.10 Festival Calendar

- **Route:** `/festivals`
- **File:** `lib/presentation/features/festivals/pages/festival_calendar_page.dart`
- **Purpose:** List of all 2026 festivals (Drik Panchang North-Indian Purnimant), grouped Upcoming / Earlier this year.
- **Data:** `festivalsProvider` → `List<Festival>` with `name`, `date`, `description`, emoji, `isToday`, `isPast`.
- **Sections:** Source disclaimer caption → Upcoming section → Earlier section (muted).
- **Interactions:** Tap tile → expandable description; some link to a verse or learning module.
- **Redesign asks:**
  - Tile: emoji (`emojiBanner`) leading → name `titleMedium` → date `captionHighlight` → countdown chip if upcoming. Trailing chevron.
  - "Today" tile: full-saffron-border + `saffronLight` bg + "TODAY" badge.
  - Past tiles: `textSecondary` text, no border accent.
  - Section dividers: `sectionLabel` uppercase + 1px hairline.
  - Header: AppBar "Festival Calendar" + small calendar icon. No backdrop painter.
  - Optional: monthly chip filter row (Jan–Dec) at the top.

### 5.11 Bookmarks

- **Route:** `/bookmarks`
- **File:** `lib/presentation/features/bookmarks/pages/bookmarks_page.dart`
- **Purpose:** Saved verses across all scriptures.
- **Data:** `enrichedBookmarksProvider` → list of `Bookmark` joined with `Verse`.
- **Empty state:** `PrasadTrayIllustration` painter + "Your offerings await" text.
- **Redesign asks:**
  - Replace the prasad-tray painter with a simple bookmark SVG (or Phosphor `BookmarkSimple`) at 96px, muted saffron, plus the existing copy.
  - List = `verse_preview_tile.dart` reused. Group by scripture (sticky headers).
  - Trailing remove-bookmark icon on each row with confirm bottom-sheet.
  - AppBar: title "Saved Verses" + count badge (already present).

### 5.12 Search

- **Route:** `/search`
- **File:** `lib/presentation/features/search/pages/search_page.dart`
- **Purpose:** Full-text search across all verses (Sanskrit / transliteration / English).
- **Data:** `searchQueryProvider`, `searchResultsProvider(query)`. Debounced typing.
- **Sections:** AppBar with embedded search field (auto-focused) → recent searches (when empty) → results list (when query) → empty/error states.
- **Redesign asks:**
  - Search field full-width in app-bar, pill-shaped (radius 21), `surfaceVariant` bg, leading magnifier icon, clear-X when typing.
  - Empty state: list of recent + suggested queries (chips), small caption "Try: karma, dharma, atman".
  - Result tile: highlight matched substring in saffron, scripture chip on the right (`labelSmall` + category color).
  - Loading: shimmer 5 fake tiles.

### 5.13 Settings

- **Route:** `/settings`
- **File:** `lib/presentation/features/settings/pages/settings_page.dart`
- **Purpose:** Theme, font size, language (en/hi), notification time, clear history, experience level, about, version, credits, links.
- **Sections (current):** Appearance → Language → Notifications → Data → Reading → About. Each section uses `OilLampRowDivider` painter between sections.
- **Redesign asks:**
  - Replace `OilLampRowDivider` with a 32dp gap + `sectionLabel` uppercase header for each section. No painted lamps.
  - Tiles: standard Material list-tile feel but with `radiusRow` 4dp tap target, leading icon (Phosphor), title `bodyMedium`, value as trailing `labelSmall textSecondary`, chevron.
  - Theme tile: 3 segmented options (Light / Dark / System) inline, no dialog.
  - Font-size tile: A- / current sample / A+ inline stepper.
  - About → version + credits + privacy + rate-app + open-source links.

### 5.14 Credits

- **Route:** `/credits`
- **File:** `lib/presentation/features/settings/pages/credits_page.dart`
- **Purpose:** Attribute scripture sources, translators, fonts, icons.
- **Data:** static list from `core/constants/content_credits.dart`.
- **Redesign asks:**
  - Plain list of credit groups. Each group = `sectionLabel` header → list of `bodyMedium` lines + optional source URL link.
  - No backdrop ornament.

### 5.15 Bottom nav (shell)

- **File:** `lib/presentation/shared/widgets/scaffold_with_nav_bar.dart`
- **3 tabs:** Today / Practice / Texts. Custom painter icons currently — sunrise arc, lotus, scroll.
- **Redesign asks:**
  - Replace painter icons with Phosphor: `SunHorizon`, `Flower` (or `Lotus` from custom set), `Scroll`. Selected = filled saffron, unselected = `warmGrey50` outline.
  - Pill-shaped nav bar (radius `radiusSheet` 20, already done) with subtle shadow on light, no shadow on dark.
  - Active indicator: small saffron dot above the icon, not a full pill.

---

## 6. Recurring patterns to apply everywhere

- **Empty states:** centered icon (Phosphor 96px, `saffronMuted`) + bodyLarge headline + caption subtitle + optional CTA. No painter illustrations.
- **Loading states:** use `shimmer_loading.dart` shapes — already built per screen. Keep.
- **Error states:** use `error_state_widget.dart` with `Phosphor.WarningCircle` icon + retry button.
- **Section headers:** `sectionLabel` uppercase + tracking 1.5 + optional 1px hairline below.
- **Cards:** `radiusCard` 16, `borderFaint(Dark)` 1px, surface `AppColors.surface` (light) or `surfaceDark` (dark). Subtle shadow only on light mode (`black @ 4%`, blur 8, y 2).
- **Buttons:**
  - Primary: saffron fill, `onSaffron` text, `labelLarge`, radius 10, padding 24/14.
  - Secondary: text button, `deepRed` (light) or `#FF6B6B` (dark) text, no fill.
  - Tertiary chip: `surfaceVariant` fill, `labelSmall`.
- **Hairlines:** 1px `divider` (light) / `dividerDark` (dark). Never use `Divider` default thickness.
- **Drop caps:** for editorial sections (verse English, module-card titles) — Lora 64 saffron drop-cap on first letter.
- **60–30–10 color rule:** 60% surface (cream / bgDark), 30% text + dividers, 10% saffron + deepRed accents. Don't paint saffron everywhere.

---

## 7. What NOT to change

- Don't rename routes.
- Don't add a state-management library other than Riverpod.
- Don't change the DB schema or domain entities.
- Don't pull in heavyweight packages (no `gradient_widgets`, no `glass_kit`, no `neumorphic_*`). Material 3 + the existing tokens are enough.
- Don't break Hindi (NotoSansDevanagari must remain the Hindi body font; `text-direction: ltr` everywhere — no RTL).
- Don't add comments inside generated code (`*.g.dart`, `*.freezed.dart`).

---

## 8. Output expected from receiving AI

For each screen, return:

1. Annotated wireframe (ASCII or Markdown) of the new layout.
2. Asset list — exact SVG / photo files needed (with filename + suggested source URL or commission spec).
3. Drop-in Flutter widget code:
   - Imports `AppColors`, `AppTypography` (`context.ts.*`), `AppSpacing` only.
   - Uses existing providers (named in §5).
   - Uses existing routes (named in §2.4).
   - Adds `phosphor_flutter` to `pubspec.yaml` if used (call this out — single new dep is OK).
   - No new design tokens unless explicitly justified, then added to the right `app_*.dart` file.
4. Diff against the current file (or full replacement if file is < 200 lines).
5. List of painter widgets it deletes from `sacred_ornaments.dart` and any imports to remove.

That's the full handoff. Hand this doc + the linked source files to the other AI.
