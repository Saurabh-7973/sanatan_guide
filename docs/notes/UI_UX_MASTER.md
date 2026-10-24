# Sanatan Guide — UI/UX Master Plan
> Single source of truth for every screen, every component, every navigation flow.
> Update this file before touching code. Reference this file during code review.

**Last updated:** April 17, 2026 (AI Synthesis Pass)  
**Status:** Active — supersedes all previous redesign docs

---

## 0. Multi-AI Synthesis — Agreed Decisions

*Five AI systems (GPT, Gemini, Grok, DeepSeek, Perplexity) were consulted on 5 key UX questions. Below are the consensus verdicts. Disagreements are noted with the chosen resolution.*

### Q1 — Home Screen: UNANIMOUS — Cut to 4 sections, move streak/heatmap to Path tab

**All 5 AIs agree:** The home screen is cluttered because it mixes consumption (reading) with administration (streaks, gamification). Home should feel like a quiet temple, not a dashboard.

**Verdict — New home order (4 sections max):**
1. Verse of the Day — **hero, full-width, nothing above it**
2. Continue Reading — single actionable card (only if user has a last-read verse)
3. TODAY — Panchang + festival merged into **one compact card** (one line each, not two separate widgets)
4. What to Read Today — the daily suggestion, last

**Remove entirely from home:** Streak header, badge strip, reading heatmap → **move to Path tab only**

**Reference:** Headspace home = 1 hero + 1 secondary card. Calm = same. 6 sections violates the "one primary action" principle all 5 AIs cited independently.

---

### Q2 — Verse Detail: 4/5 say keep current order; TOP segmented control for reading mode

**Order (confirmed by 4/5 AIs):** Sanskrit → Transliteration → English → Hindi

*Gemini alone suggested flipping English before Transliteration. Overruled — Sanskrit-to-pronunciation-to-meaning respects the traditional parampara (lineage) of learning. Beginners who want meaning immediately use Reading Mode: Translation Only.*

**Progressive disclosure — Verdict:**
- **Visible by default:** Sanskrit + English translation only
- **One tap to reveal:** Transliteration ("Show pronunciation" link below Sanskrit)
- **Expandable sections:** Hindi, Word-by-word meanings, AI Explanation
- One "Deepen this verse" accordion that expands all three at once (Gemini's suggestion — excellent)

**Reading mode toggle — Verdict:** Move from bottom chips bar to a **top segmented control** (3 pills) placed directly under the verse label: `Sanskrit | Full | English`. Bottom bar stays navigation-only: `← Prev | 47 of 700 | Next →`. *(4/5 AIs recommended removing the toggle from the bottom. GPT, Gemini, Grok all explicitly said the bottom bar competes with navigation.)*

**Sanskrit as hero — Agreed enhancements:**
- Increase from 26px → **32px** TiroDevanagari (4/5 AIs said 26px is too small)
- Line height 2.2 → **2.4**
- Add **generous padding** (32px horizontal + 24px vertical around the Sanskrit block alone)
- Translation at 80% opacity initially so Sanskrit has absolute visual dominance

---

### Q3 — Library: Categorized list with horizontal category filter pills at top

**Layout verdict:** Categorized vertical list (already implemented) is correct. Add **horizontal scrollable category pills at the top** (like Calm's "Collections") that jump to each section. This was suggested by 3/5 AIs and adds no complexity.

**For massive scriptures (Rigveda, Mahabharata):** Card must show three pieces of data on one line: `9,500 verses • 108 Highlights • Full text`. A "Start Here" button (saffron) on the card opens a curated 10-verse sampler. "Full text" is secondary.

**Featured section:** Horizontal carousel at very top (4-5 large cards). Already implemented. Keep.

---

### Q4 — Learning Path: Heatmap to Path tab ONLY; soft spiritual gamification

**Heatmap — Unanimous:** Move 30-day reading heatmap **exclusively to Path tab**. Remove from Home. All 5 AIs agreed independently. Redundancy kills focus.

**Gamification tone — Unanimous:** Light touch. "Calm-like" not "Duolingo-like." No harsh penalties for missed days. Progress as gentle milestone, not aggressive streak.

**Locked modules — Verdict:** Keep full-opacity card layout + subtle lock icon (top-right corner) + tooltip text `"Complete 4 of 8 Level 1 modules to unlock"`. **Do not grey out** — violates the warm palette rule and feels corporate. The lock should feel like a sacred gate, not a disabled UI element. *(Grok's exact phrasing — all AIs agreed on not using grey.)*

---

### Q5 — Navigation: 3 tabs, icon + label, no drawer

**Tab count — 4/5 agree:** Keep 3 tabs (Home, Path, Library). Gemini suggested a 4th "Profile" tab — overruled for now. Bookmarks stay in Library AppBar.

**Icon + label — Unanimous:** All 5 AIs independently said icon-only is too cryptic for a spiritual audience. Use Outfit 12px labels. Active = saffron, inactive = textSecondary.

**No side drawer — Unanimous:** All 5 AIs said bottom tabs are the correct mobile pattern for daily-return apps. Side drawer hides features, feels corporate. Keep bottom tabs for the 3 core sections.

---

### Summary of Changes Required (from AI Synthesis)

| Change | Priority | Current State | Target State |
|--------|----------|---------------|--------------|
| Remove streak + heatmap from Home | HIGH | In home | Path tab only |
| Merge Panchang + festival into one compact card | HIGH | 2 separate rows | 1 combined card |
| Move "What to read today" below "Continue Reading" | MEDIUM | 2nd position | 4th position |
| Sanskrit font size 26 → 32px | HIGH | 26px | 32px |
| Sanskrit line-height 2.2 → 2.4 | MEDIUM | 2.2 | 2.4 |
| Sanskrit padding: generous 32px horizontal block | MEDIUM | standard padding | 32px h-padding block |
| Translation at 80% opacity (secondary to Sanskrit) | MEDIUM | 100% | 80% |
| Transliteration: hidden by default, tap to reveal | HIGH | always visible | "Show pronunciation" tap |
| "Deepen this verse" accordion (Hindi + words + AI) | HIGH | separate accordions | one combined section |
| Reading mode: move from bottom chips → top segmented | HIGH | bottom chips bar | top 3-pill segmented |
| Library: add horizontal category filter pills at top | LOW | no pills | category jump pills |
| Library cards: show verse count + highlights + full text | MEDIUM | varies | 3-data-point format |
| Locked modules: lock icon, NOT grey | MEDIUM | opacity-reduced | warm lock icon |
| Streak/heatmap stays on Path tab | DONE | on Path | ✓ |

---

## 1. Design Philosophy

### North Star
A beautifully bound book collection that happens to live on your phone. Every screen asks: *"Does this element help the user connect with the scripture?"* If no — it does not belong.

### Five Laws
1. **The verse is always the hero.** UI chrome exists to support reading, never to compete with it.
2. **One primary action per screen.** Home → read today's verse. Library → choose a scripture. Verse detail → read and reflect.
3. **Sacred minimalism.** Space is not empty — it is breath. Never fill it just because you can.
4. **Warm, never cold.** Saffron, cream, deep brown, aged gold. No blue, no green, no grey-corporate palette.
5. **Progressive disclosure.** Show the Sanskrit first. Let users pull more depth as they want it.

### Target User Spectrum
| Type | Behaviour | What they need |
|------|-----------|----------------|
| **Seeker** | First week, curious | Simple onboarding, Dharma 101, readable translations |
| **Practitioner** | Daily user, 3-7 min | Quick access to verse of day, streak, continue reading |
| **Scholar** | Deep reader, 20+ min | Sanskrit, transliteration, word meanings, search |

---

## 2. Design System

### 2A. Color Palette

#### Brand
| Token | Hex | Usage |
|-------|-----|-------|
| `saffron` | `#E8820C` | Primary accent — selected states, icons, section labels |
| `saffronOnDark` | `#F4A830` | Saffron variant with better contrast on dark surfaces |

#### Light Mode Surfaces
| Token | Hex | Usage |
|-------|-----|-------|
| `cream` | `#FDFAF6` | Scaffold background |
| `surface` | `#F7F2EC` | Cards, tiles |
| `surfaceVariant` | `#EDE8E2` | Search field, chips, inputs |
| `surfaceElevated` | `#EBE6E0` | Elevated modals, overlays |
| `border` | `#CCC5BB` | Card borders (light) |
| `divider` | `#E4DDD6` | Divider lines (light) |

#### Dark Mode Surfaces
| Token | Hex | Usage |
|-------|-----|-------|
| `bgDark` | `#0F0F0F` | Scaffold background |
| `surfaceDark` | `#1C1816` | Cards (warm near-black) |
| `surfaceElevated` | `#221E1B` | Modals, overlays |
| `surfaceHighest` | `#2A2520` | Chips, tags |
| `borderDark` | `#383330` | Card borders (dark) |
| `dividerDark` | `#2A2622` | Divider lines (dark) |

#### Text
| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `textPrimary` | `#1A1210` | `#F0EBE5` | Main content |
| `textSecondary` | `#6B6360` | `#9B9390` | Supporting labels |
| `textHint` | `#9E9A97` | `#6E6A68` | Placeholder, empty states |

#### Sanskrit Reader (verse_detail_page ONLY)
| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `sanskritText` | `#2D1B00` | — | Sanskrit text on light |
| `sanskritTextOnDark` | — | `#E8D9C0` | Sanskrit text on dark (warm ivory) |

#### Opacity Tokens (never use `.withValues(alpha:)` directly)
| Token | Value | Usage |
|-------|-------|-------|
| `saffronFaint` | 8% saffron | Icon backgrounds, chip fills |
| `saffronMuted` | 12% saffron | Badge backgrounds |
| `saffronLight` | 15% saffron | Card fill when selected |
| `saffronBorder` | 30% saffron | Bookmarked card border |
| `deepRedMuted` | 12% deep red | Key verse badge bg |
| `successMuted` | 30% green | Completion card border |
| `borderFaint` | 40% border | Subtle dividers |

#### Scripture Category Accents (left-border on library cards ONLY)
| Category | Token | Hex | Meaning |
|----------|-------|-----|---------|
| Itihasa | `catItihasa` | `#C45C2A` | Burnt sienna — epic grandeur |
| Veda | `catVeda` | `#B85C1C` | Deep amber — ancient light |
| Upanishad | `catUpanishad` | `#6B5B95` | Violet — mystical depth |
| Darshana & Yoga | `catDarshana` | `#9B7928` | Golden amber — wisdom |
| Stotra | `catStotra` | `#B56576` | Rose — devotion |
| Shastra | `catShastra` | `#8D6E63` | Warm brown — dharma |
| Tantra | `catTantra` | `#7B5B8A` | Muted plum — esoteric |
| Tamil Classic | `catTamil` | `#9B5E3A` | Terracotta — earth |

**Rule:** Category accents appear ONLY as left-border strips on scripture library cards. Never as background fills on any other screen.

---

### 2B. Typography

#### Font Families
| Family | Role | Files |
|--------|------|-------|
| `TiroDevanagariSanskrit` | Sanskrit display | assets/fonts/ |
| `NotoSansDevanagari` | Hindi / Devanagari body | assets/fonts/ |
| `Lora` | English scripture body | assets/fonts/ |
| `Outfit` | All UI labels, buttons, captions | assets/fonts/ |

#### Type Scale
| Style | Font | Size | Weight | Usage |
|-------|------|------|--------|-------|
| `displayLarge` | Outfit | 32 | 600 | Page hero titles |
| `displayMedium` | Outfit | 24 | 600 | Section heroes |
| `bodyLarge` | Lora | 18 | 400 | Scripture English body |
| `bodyMedium` | Outfit | 16 | 400 | UI body text |
| `labelLarge` | Outfit | 16 | 600 | Card titles |
| `labelMedium` | Outfit | 14 | 500 | Tags, list labels |
| `labelSmall` | Outfit | 12 | 500 | Metadata, counts |
| `sectionLabel` | Outfit | 11 | 700 | Section headers (UPPERCASE) |
| `cardLabel` | Outfit | 12 | 600 | Card type labels (saffron) |
| `captionHighlight` | Outfit | 13 | 600 | Counts, saffron callouts |
| `caption` | Outfit | 13 | 400 | Supporting metadata |
| `chipLabel` | Outfit | 12 | 500 | Filter chips |
| `sanskritLarge` | TiroDevanagari | 26 | 400 | Primary Sanskrit display |
| `sanskritMedium` | TiroDevanagari | 22 | 400 | Secondary Sanskrit |
| `sanskritSmall` | TiroDevanagari | 18 | 400 | Sanskrit preview in lists |

#### Critical Rules
- Sanskrit `lineHeight` must be 2.2 (it breathes)
- English body (`bodyLarge`) must never be `justified` alignment — only `left`
- Never use `TextStyle` inline in widget code. Always use `context.ts.*`
- In dark mode, Sanskrit MUST use `sanskritTextOnDark` (#E8D9C0) — brown (#2D1B00) is unreadable on dark

---

### 2C. Spacing Grid (4pt)
| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4 | Icon padding, tiny gaps |
| `sm` | 8 | Intra-component gaps |
| `md` | 12 | Default list item padding |
| `lg` | 16 | Card internal padding |
| `xl` | 24 | Between related sections |
| `xxl` | 32 | Between distinct sections |
| `xxxl` | 48 | Bottom ListView padding (nav bar) |
| `pagePadding` | 24 | Horizontal screen margins |
| `cardRadius` | 12 | Standard card border radius |
| `cardPadding` | 16 | Card internal padding |

---

### 2D. Component Inventory

| Component | File | Used In |
|-----------|------|---------|
| `SacredCard` | shared/widgets/sacred_card.dart | Search results, bookmarks, home cards |
| `VersePreviewTile` | shared/widgets/verse_preview_tile.dart | Search results, bookmarks |
| `ErrorStateWidget` | shared/widgets/error_state_widget.dart | All async screens |
| `ShimmerLoading` | shared/widgets/shimmer_loading.dart | Loading states |
| `StreakCalendar` | home/widgets/streak_calendar.dart | Home, Learning Path |
| `StreakBadgeStrip` | home/widgets/streak_badge_strip.dart | Home |
| `VerseOfDayCard` | home/widgets/verse_of_day_card.dart | Home |
| `DailySuggestionWidget` | home/widgets/daily_suggestion_widget.dart | Home |
| `LearningProgressSummary` | home/widgets/learning_progress_summary.dart | Home |
| `ScaffoldWithNavBar` | shared/widgets/scaffold_with_nav_bar.dart | All tab screens |
| `ReadingModeBar` | (in verse_detail_page) | Verse Detail |

---

## 3. Navigation Architecture

### Tab Structure
```
Bottom Nav Bar (always visible on tab screens)
├── Tab 0: Home       → /home
├── Tab 1: Path       → /learn
└── Tab 2: Library    → /browse
```

### Full Route Map
```
/ (splash)
    → /home (if onboarding done)
    → /onboarding (first launch)

/home (tab 0)
    → /search (modal, from AppBar search icon)
    → /settings (push, from AppBar gear icon)
    → /browse/:code/verse/:id (push, from VerseOfDayCard or ContinueReading)
    → /festivals (push, from festival row)

/learn (tab 1)
    → /learn/:moduleId (push, module reader — OUTSIDE shell)

/browse (tab 2)
    → /browse/:scriptureCode (push, chapter list)
        → /browse/:code/chapters/:chapterId/verses (push, verse list)
            → /browse/:code/verse/:verseId (push, verse detail — OUTSIDE shell)
    → /bookmarks (push, from AppBar bookmark icon)
    → /search (push, from AppBar search icon)

/settings → /credits (push)
```

### Back Behavior (every screen)
| Screen | Back action | Expected result |
|--------|-------------|-----------------|
| Home | — | n/a (tab, no back) |
| Path | — | n/a (tab, no back) |
| Library | — | n/a (tab, no back) |
| Onboarding | Back on step 0 → go('/home') | Skips to home |
| Onboarding | Back on step 1 → step 0 | Returns to prev step |
| Search | Back → pop() or go('/home') | Returns to caller |
| Settings | Back → pop() | Returns to home |
| Credits | Back → pop() | Returns to settings |
| Festivals | Back → pop() | Returns to home |
| Chapter List | **Back → pop()** | Returns to Library ← **MISSING BACK BUTTON BUG** |
| Verse List | **Back → pop()** | Returns to chapter list ← **MISSING BACK BUTTON BUG** |
| Verse Detail | Back → pop() | Returns to verse list / search / bookmarks |
| Module Reader | Back → pop() or go('/learn') | Returns to Path |
| Bookmarks | Back → pop() or go('/home') | Returns to Library (or wherever opened from) |

---

## 4. Feature Inventory

### Reading Features
- [x] Browse scriptures by category
- [x] Chapter list with progress bar
- [x] Verse list with read indicators
- [x] Verse detail (Sanskrit + IAST + English + Hindi)
- [x] Reading modes (All / Sanskrit / Sanskrit+IAST / Translation only)
- [x] Font size adjustment
- [x] Dark mode (warm blacks, not pure black)
- [x] Word-by-word meanings (expandable)
- [x] AI explanation (expandable, Gita only for now)
- [x] Verse navigation (prev/next bar + swipe gesture)
- [x] Share verse (share card generator)
- [x] Bookmark verse (with animation)
- [x] Notes (bottom sheet per verse)
- [x] FTS5 search across all scriptures
- [x] Search filter chips (by scripture)
- [x] Search query highlighting

### Learning Features
- [x] Dharma 101 learning modules (17 total across 2 levels)
- [x] Module card reader (spaced repetition style)
- [x] Module progress tracking (cards read)
- [x] Level unlock system (4/8 Level 1 → unlock Level 2)
- [x] Book recommendations on module completion
- [x] Scripture links from completion cards (Gita, Vedas, etc.)
- [ ] **BUG: Module resume not working** — opens at card 1 instead of last-read position

### Streak & Gamification
- [x] Daily reading streak counter
- [x] Streak badges (First Flame, Steady Seeker, Devoted Reader, Sadhaka, Tapasvi)
- [x] 30-day reading activity heatmap calendar
- [x] Clear reading history (settings)
- [ ] **BUG: Streak data not always reflecting in UI correctly**

### Personalisation
- [x] User experience level (Beginner / Serious Seeker / Scholar)
- [x] Theme mode (Light / Dark / System)
- [x] Font size slider (14–24px)
- [x] Daily verse reminder time picker

### Daily Context
- [x] Verse of the Day (random, refreshes on pull)
- [x] Daily reading suggestion (Panchang-aware, weekday-based)
- [x] Panchang display (vara + tithi + paksha)
- [x] Festival calendar (2026, verified dates)
- [x] Upcoming festival widget (with countdown)

### Content
- [x] Bhagavad Gita (700 verses, complete)
- [x] Yoga Sutras (~196 sutras)
- [x] Principal Upanishads (samplers — Katha, Mundaka, etc.)
- [x] Rigveda (~9,500 hymns)
- [x] Samaveda (1,719 verses)
- [x] Yajurveda (1,978 verses)
- [x] Atharvaveda (~5,627 verses)
- [x] Ramayana (~18,761 shlokas)
- [x] Mahabharata (~72,770 shlokas)
- [x] Tirukkural (~1,326 kurals)
- [x] + additional scriptures (Brahma Sutras, HYP, Manusmriti, etc.)
- [x] Content credits page (translator attributions)

### Bookmarks
- [x] Save/unsave any verse
- [x] View saved verses list
- [x] Swipe to delete
- [x] Navigate to verse from bookmarks

---

## 5. Screen Specifications

### Screen 1: Splash Screen
**Route:** `/`  
**Purpose:** App init, route to onboarding or home  
**AppBar:** None  
**Body:** Logo / splash image centered  
**Logic:** Check `OnboardingService.isComplete()` → redirect  
**Issues:** None known  
**Rebuild needed:** No

---

### Screen 2: Onboarding
**Route:** `/onboarding`  
**Purpose:** First-impression + collect experience level  
**Access:** Splash → first launch only  
**Back:** Step 0 → `context.go('/home')`; Step 1 → previous step  

**Step 0 Layout:**
- App icon / illustration (large, centered)
- App name: "Sanatan Guide" (displayLarge)
- Tagline: one line (caption)
- Primary button: "Begin" → step 1
- Skip link: "Already know scriptures? Skip" → `/home`

**Step 1 Layout:**
- Title: "How familiar are you with Hindu scriptures?"
- 3 option cards (Beginner / Serious Seeker / Scholar), each full-width tappable
- Each card: title + 1-line description
- Selected: saffron border + saffron checkmark
- Primary button: "Let's start" → saves level → `go('/home')`

**States:** No loading/error states needed (local selection only)

**Current Issues:**
- [ ] Skeleton shimmer doesn't match the actual content layout — because `ShimmerLoading` uses generic `VerseListShimmer` which shows verse-style rows, not option cards
- [ ] **Fix:** Only show shimmer on async operations. Onboarding has no async — remove shimmer entirely.

**Rebuild needed:** Minor — fix shimmer, ensure step transitions are smooth

---

### Screen 3: Home
**Route:** `/home`  
**Purpose:** Daily spiritual dashboard — ONE scroll, ONE primary action  
**Access:** Tab 0 (always)  
**AppBar:** `Namaskar` greeting + Hindu date subtitle; trailing: search icon + settings icon

**Body Layout (top to bottom):**

```
[NO section header]
VerseOfDayCard               ← HERO. Full width. No border. Pull-to-refresh.
SizedBox(sm)
DailySuggestionWidget        ← "What to read today" compact card

[TODAY]                      ← sectionLabel
_PanchangRow                 ← 1 compact line: emoji + "Vara · Tithi, Paksha"
SizedBox(xs)
_UpcomingFestivalRow         ← emoji + festival name + "In X days" badge

[YOUR PATH]                  ← sectionLabel
LearningProgressSummary      ← "Learning · X of 17 modules done" → /learn
SizedBox(sm)
_ContinueReadingCard         ← "Continue reading: [scripture] · [ch:v]" — ONLY if data exists

[STREAK]                     ← sectionLabel
_StreakHeader                ← "🔥 X-day streak" + badge chip; OR motivational empty state
SizedBox(xs)
StreakBadgeStrip             ← milestone badges
SizedBox(sm)
StreakCalendar               ← 30-day heatmap
```

**States:**
- Loading: each widget shows its own shimmer (VerseOfDayCard has shimmer built in)
- Error: each widget shows its own error inline
- Empty streak: `_StreakHeader` shows "Start your streak today" placeholder with motivation text

**Current Issues:**
- [ ] Empty grey box between learning card and STREAK — `_ContinueReadingCard` renders a container even when content is loading. Fix: use `lastReadAsync.when(loading: () => SizedBox.shrink(), ...)` not `.value`
- [ ] Home feels cluttered because VerseOfDayCard and DailySuggestion have inconsistent card styling — they should look like sisters
- [ ] "TODAY" and "YOUR PATH" section headers are not adding enough breathing room — increase pre-header gap to `xxl` (32px)
- [ ] LearningProgressSummary has an internal `Padding(bottom: sm)` that creates double spacing when combined with home page `SizedBox(sm)` — remove one

**Rebuild needed:** Minor layout fixes + empty state for continue reading

---

### Screen 4: Search
**Route:** `/search`  
**Purpose:** Find verses across all scriptures  
**Access:** From home AppBar search icon; from library AppBar  
**AppBar:** Back button + search TextField (full-width, rounded pill)  
**Back:** `context.pop()` or `go('/home')`

**Body Layout:**
```
_FilterChips                 ← horizontal scroll, height: 48, filter by scripture
_SearchBody:
  IF query < 2 chars → _EmptyPrompt (icon + label + suggestion chips)
  ELSE IF loading → VerseListShimmer
  ELSE IF error → ErrorStateWidget
  ELSE IF empty results → _NoResults
  ELSE → _ResultsList (count label + ListView of VersePreviewTile cards)
```

**Current Issues:**
- [x] CRASH FIXED: `_FilterChips` horizontal ListView needs `SizedBox(height: 48)` wrapper — done
- [ ] `_EmptyPrompt` icon container uses `AppColors.saffron.withValues(alpha: 0.08)` — replace with `AppColors.saffronFaint`
- [ ] `_NoResults` icon container same issue → `AppColors.textSecondary.withValues(alpha: 0.08)` — replace with surface color
- [ ] Filter chips: when ALL scriptures selected (default), the chip row shows "All" as selected. But the full list of scripture-specific filters may overflow without enough horizontal padding on Android — test on device
- [ ] FAB (hamburger icon) visible in screenshot — this should NOT be on search page. Investigate which FAB is bleeding through (possibly from parent scaffold)

**Rebuild needed:** Fix alpha tokens + FAB bleed-through

---

### Screen 5: Library (Scripture Browser)
**Route:** `/browse`  
**Purpose:** Discover and enter any scripture  
**Access:** Tab 2  
**AppBar:** "Library" title; trailing: search icon + bookmarks icon

**Body Layout:**
```
Featured carousel             ← 3-4 highlighted scriptures (horizontal scroll)
[Section headers per category]
  Scripture cards (left accent border, emoji, name, description, verse count, sampler badge)
```

**Current Issues:**
- [x] FIXED: Green tint from `catDarshana` — replaced with amber-gold
- [x] FIXED: Blue `catTamil` — replaced with warm terracotta
- [ ] Featured carousel card height may differ from library cards — unify heights
- [ ] "Selected Highlights" sampler badge still shows on scriptures that are now complete — verify `_samplerIds` is current
- [ ] Bookmarks icon in AppBar navigates to `/bookmarks` — back from bookmarks should return here, not home

**Rebuild needed:** No — minor tweaks only

---

### Screen 6: Chapter List
**Route:** `/browse/:scriptureCode`  
**Purpose:** Navigate chapters/books of a scripture  
**Access:** Library → tap scripture  

**AppBar:** Scripture name; **leading: Back button (REQUIRED)**

**Current Issues:**
- [ ] **CRITICAL: No back button for some scriptures** — user reported Vedas/Puranas have no back/home button. The AppBar likely has `automaticallyImplyLeading: true` which should show a back button on pushed routes. Investigate: does the chapter_list_page override AppBar and set `leading: null` or `automaticallyImplyLeading: false`?
- [ ] If this is accessed from a push route, `context.canPop()` should be true — but if the route is navigated via `context.go()` instead of `context.push()`, the back stack would be empty. Fix: always use `context.push('/browse/$code')` from library, never `go`.

**Rebuild needed:** Investigate leading button + ensure push navigation

---

### Screen 7: Verse List
**Route:** `/browse/:code/chapters/:chapterId/verses`  
**Purpose:** List all verses in a chapter  
**Access:** Chapter List → tap chapter  

**AppBar:** Chapter name + verse count; **leading: Back button (REQUIRED)**

**Issues:** Same as chapter list — ensure push navigation and back button present

**Rebuild needed:** Verify back button

---

### Screen 8: Verse Detail
**Route:** `/browse/:code/verse/:verseId` (OUTSIDE shell — no tab bar)  
**Purpose:** Deep reading of a single verse. The most important screen.  
**Access:** Verse List, Search results, Bookmarks, Verse of Day, Continue Reading  
**Back:** Always `context.pop()` — never `go()`

**AppBar:** Verse label (e.g. "BG 2.47") + bookmark icon + share icon; collapsible on scroll

**Body Layout (top to bottom):**
```
[Verse label + chapter name]  ← labelMedium, textSecondary
[Sanskrit]                    ← sanskritLarge, 2.2 line height, warm ivory in dark mode
[Divider]                     ← subtle, indented
[Transliteration]             ← IF reading mode shows it
[Divider]                     ← subtle
[English translation]         ← bodyLarge, Lora font, left-aligned
[Hindi translation]           ← IF available, NotoSansDevanagari
[Word meanings]               ← expandable section (tap to reveal)
[AI explanation]              ← expandable section (tap to reveal, Gita only)
[Notes section]               ← shows saved note if exists
[ReadingModeBar]              ← sticky at bottom
[Navigation bar]              ← prev verse | "X of Y" | next verse
```

**States:**
- Loading: shows last-known verse label in AppBar (no "Verse" flash bug — fixed)
- Error: ErrorStateWidget

**Issues:**
- [ ] Dark mode Sanskrit must use `sanskritTextOnDark` (#E8D9C0) — verify this is consistently applied for ALL scripture types, not just Gita
- [ ] Notes button in nav bar — does tapping notes open a bottom sheet? Verify this is wired correctly
- [ ] Back stack: if coming from Search, back should return to search results. If coming from Bookmarks, back should return to bookmarks. Ensure `context.push()` is used everywhere.

**Rebuild needed:** No — verify dark mode + notes wiring

---

### Screen 9: Learning Path (Path tab)
**Route:** `/learn`  
**Purpose:** Track learning journey through Dharma 101  
**Access:** Tab 1  
**AppBar:** None (tab screen, title in content)

**Body Layout:**
```
[Level 1 header]
  Title + subtitle
  Linear progress bar (X/8 completed)
  X of 8 completed count

StreakCalendar                ← 30-day heatmap (moved here from home for space)

[Level 1 module cards] × 8   ← staggered animation

[Level 2 header]
  If locked: "Complete 4 more modules to unlock" with progress
  If unlocked: progress bar + count

[Level 2 module cards] × 4-9
```

**Module Card States:**
| State | Icon | Border | Opacity |
|-------|------|--------|---------|
| Not started | number on saffronMuted | default | 100% |
| In progress | circular progress ring | saffronBorder | 100% |
| Completed | green checkmark | successMuted | 100% |
| Locked | padlock | default | 50% |

**Current Issues:**
- [ ] **BUG: Module progress not reflecting in UI** — when user reads 3/6 cards and returns, the card should show 3/6 and resume at card 3. Root cause: `modulesProvider` may not be invalidated on return from module reader. Fix: in `module_reader_page.dart` `dispose()`, call `ref.invalidate(modulesProvider)`.
- [ ] Streak calendar on learning path shows same data as home — consider removing from Path and keeping only on Home (reduces duplication)

**Rebuild needed:** Fix modulesProvider invalidation on dispose

---

### Screen 10: Module Reader
**Route:** `/learn/:moduleId` (OUTSIDE shell)  
**Purpose:** Card-by-card reading of a learning module  
**Access:** Learning Path → tap module  
**Back:** `context.pop()` → returns to Learning Path

**AppBar:** Module title + progress counter ("3 / 6")  
**Body:** Full-screen card swiper

**Card Types:**
| Type | Header label | Content |
|------|-------------|---------|
| Content | (card label) | Title + body text |
| Anchor Verse | "KEY VERSE" badge | Sanskrit + translation |
| Reflection | "REFLECT" label | Question + space for thought |
| Completion | — | Congratulations + book rec + scripture CTA |

**Current Issues:**
- [ ] **BUG: Resume position not working** — should open at `cardsRead.clamp(0, cards.length-1)` index, but always opens at 0. The fix was already coded in `initState` — debug why it's not working. Check if `modulesProvider` is returning stale `cardsRead=0` due to not being invalidated after last session.
- [ ] Completion card book recommendation: verify all 17 modules have correct `_books` map entries

**Rebuild needed:** Debug resume position bug

---

### Screen 11: Bookmarks
**Route:** `/bookmarks`  
**Purpose:** View all saved verses  
**Access:** Library AppBar bookmark icon  
**AppBar:** "Saved Verses" + bookmark count badge; **leading: Back button**  
**Back:** `context.pop()` → returns to Library (or wherever opened from)

**Body Layout:**
```
IF empty → _EmptyState (icon + text + Browse button)
ELSE → ListView of VersePreviewTile (card style)
  Each tile: swipeable (left OR right) to dismiss with confirmation snackbar
```

**Current Issues:**
- [ ] Back behavior: user says back lands on Home instead of Library. Root cause: if bookmarks is opened via `context.go('/bookmarks')` instead of `context.push('/bookmarks')`, GoRouter replaces the stack and there's nothing to pop to. Fix: change all navigation TO bookmarks to use `context.push('/bookmarks')`.
- [ ] VersePreviewTile for bookmarks shows `verseId` as location label (e.g. "BG.2.47") — this is the raw ID format, not the human-readable "BG 2:47". Apply `compactVerseLocationLabel()` or format it.

**Rebuild needed:** Fix navigation push + format verseId label

---

### Screen 12: Settings
**Route:** `/settings`  
**Purpose:** Configure app preferences  
**Access:** Home AppBar gear icon  
**AppBar:** "Settings" title; leading: Back button

**Sections:**
1. **Appearance** — Theme (Light/Dark/System) + Font size slider
2. **Notifications** — Daily verse reminder time
3. **Data** — Clear reading history (with confirmation dialog)
4. **Reading** — Scripture experience level
5. **About** — App version + Credits + Privacy Policy + Terms + Send Feedback

**Issues:** None critical  
**Rebuild needed:** No

---

### Screen 13: Credits
**Route:** `/credits`  
**Purpose:** Attribution for all scripture translations  
**Access:** Settings → About → "Credits & Attributions"  
**AppBar:** "Credits & Attributions" + Back button  
**Issues:** None known  
**Rebuild needed:** No

---

### Screen 14: Festival Calendar
**Route:** `/festivals`  
**Purpose:** View upcoming Hindu festivals for 2026  
**Access:** Home → festival row tap  
**AppBar:** "Festivals 2026" + Back button  
**Issues:** None critical (dates verified against Drik Panchang)  
**Rebuild needed:** No

---

## 6. Known Bugs — Prioritized

### P0 — Crashes / Breaks App
| # | Bug | File | Fix |
|---|-----|------|-----|
| P0-1 | Search page crash: "Horizontal viewport was given unbounded height" | search_page.dart:152 | ✅ FIXED — added SizedBox(height: 48) around horizontal ListView |

### P1 — Core Feature Broken
| # | Bug | File | Fix |
|---|-----|------|-----|
| P1-1 | Module reader opens at card 0 instead of last-read position | module_reader_page.dart | Verify `cardsRead` is properly invalidated in modulesProvider after each session. Debug initState resume logic. |
| P1-2 | Chapter/Verse list pages have no back button for some scriptures (Vedas, Puranas) | chapter_list_page.dart, verse_list_page.dart | Ensure these pages are navigated via `context.push()` (not `go()`) so back stack is populated. Verify AppBar `automaticallyImplyLeading` is true or add explicit back button. |
| P1-3 | Bookmarks back navigates to Home instead of Library | bookmarks_page.dart + all callers | Change all callers to use `context.push('/bookmarks')` not `context.go('/bookmarks')` |
| P1-4 | Home page: empty grey box below learning card | home_page.dart | `_ContinueReadingCard` may render during AsyncLoading. Rewrite to use `.when()` instead of `.value` |

### P2 — Visual / UX Issues
| # | Bug | File | Fix |
|---|-----|------|-----|
| P2-1 | Search page shows a FAB (hamburger menu icon) that doesn't belong | search_page.dart | Identify which scaffold is injecting this FAB and remove |
| P2-2 | Library green tint (catDarshana was teal) | app_colors.dart | ✅ FIXED — changed to amber-gold |
| P2-3 | Library blue tint (catTamil was blue) | app_colors.dart | ✅ FIXED — changed to warm terracotta |
| P2-4 | Onboarding shimmer doesn't match content structure | onboarding_page.dart | Remove shimmer from onboarding (it's all local data, no async needed) |
| P2-5 | VersePreviewTile in bookmarks shows raw verseId format | bookmarks_page.dart | Apply proper formatting to locationLabel |
| P2-6 | Home: DailySuggestion and VerseOfDayCard card styles inconsistent | home widgets | Unify card styling — both should use same surface color + border + radius |
| P2-7 | Search: `_EmptyPrompt` uses `.withValues(alpha:)` inline | search_page.dart | Replace with opacity tokens |

---

## 7. UI Anti-Patterns to Eliminate

These are patterns currently in the codebase that violate design discipline. Fix on sight:

1. **Inline `.withValues(alpha: X)` calls** — always use named opacity tokens (saffronFaint, saffronMuted, etc.)
2. **`context.go()` for navigation into sub-pages** — always use `context.push()` for pages that need back navigation
3. **`SizedBox(height: 2)`** — always use `AppSpacing.xs` (4px)
4. **Hardcoded `fontSize:` in widgets** — always use `context.ts.*` styles
5. **`automaticallyImplyLeading: false` without adding an explicit back button** — always provide back navigation
6. **Category accent colors used outside of library cards** — category colors are for left-border strips in scripture library ONLY
7. **Blue or green colors anywhere in the UI** — the palette is warm earth tones only

---

## 8. What Needs Rebuilding vs What's Good

### Good — Keep As-Is
- ✅ Verse Detail page (minor fixes only)
- ✅ Settings page
- ✅ Credits page
- ✅ Festival Calendar
- ✅ Design token system (AppColors, AppTypography, AppSpacing)
- ✅ SacredCard + VersePreviewTile components
- ✅ Search UI (post-crash fix)
- ✅ Streak calendar widget
- ✅ Shimmer loading widgets

### Needs Bug Fixes Only (no rebuild)
- 🔧 Module Reader — fix resume position
- 🔧 Learning Path — fix modulesProvider invalidation
- 🔧 Bookmarks — fix back navigation (push vs go)
- 🔧 Chapter/Verse List — fix back button (push vs go)
- 🔧 Home — fix ContinueReadingCard loading state

### Needs Minor Visual Polish
- 🎨 Home — VerseOfDayCard + DailySuggestion card styling consistency
- 🎨 Onboarding — remove unnecessary shimmer
- 🎨 Bookmarks — format verseId as human-readable label
- 🎨 Search — replace inline alpha values with tokens

### Structural Redesign (future, after bugs fixed)
- 🏗 Home: consider removing StreakBadgeStrip + StreakCalendar from home (move to Path tab only) to reduce clutter
- 🏗 Learning Path: remove duplicate StreakCalendar (already on home)
- 🏗 Onboarding: add proper experience level selection UI (option cards, not chips)

---

## 9. Implementation Sequence (Next Sprint)

**Fix in this order — no skipping:**

```
Step 1: Fix module reader resume bug
  File: module_reader_page.dart
  Check: is cardsRead being read correctly? Is modulesProvider invalidated on dispose?

Step 2: Fix back button on chapter/verse list pages
  Files: chapter_list_page.dart, verse_list_page.dart
  Check: all navigation TO these pages uses context.push(), not context.go()

Step 3: Fix bookmarks back navigation
  Files: all files that navigate to /bookmarks
  Change: context.go('/bookmarks') → context.push('/bookmarks')

Step 4: Fix ContinueReadingCard loading state (empty grey box)
  File: home_page.dart → _ContinueReadingCard
  Change: if (data == null) pattern to use .when() to handle loading separately

Step 5: Fix search FAB bleed-through
  Identify: which scaffold renders the hamburger FAB
  Remove or scope it properly

Step 6: Polish — inline alpha tokens, onboarding shimmer, bookmark verseId format
```

---

## 10. Design Review Checklist

Before marking any screen "done", verify:

- [ ] Every text style uses `context.ts.*` (no inline TextStyle in widgets)
- [ ] Every spacing uses `AppSpacing.*` (no hardcoded pixel values)
- [ ] Every color uses `AppColors.*` (no hex or `.withValues(alpha:)` inline)
- [ ] Dark mode tested: all text readable, Sanskrit warm ivory, surfaces warm dark
- [ ] Back button present on every pushed screen
- [ ] Navigation uses `context.push()` for sub-pages (not `context.go()`)
- [ ] Loading state: shimmer or `SizedBox.shrink()` — never an empty container with bg color
- [ ] Error state: `ErrorStateWidget` with retry
- [ ] Empty state: icon + label + action (never just blank)
- [ ] No blue or green anywhere in the color palette

---

*This document is the single source of truth. Edit it before starting any screen work.*
