# SANATAN GUIDE — Build Brief for Claude Code

> **Read this entire file before doing anything.** This is the canonical brief. Every other file in this repo is supporting material referenced from here. If anything in another file contradicts this one, this file wins.

---

## 0. How to read this document

This brief has six parts:
1. **What this app is** — context and stack
2. **The design system** — tokens, fonts, vocabulary, rules
3. **The cross-reference map** — every screen, how to reach it, where it links to
4. **Per-screen build instructions** — what to build for each of 16 screens/flows
5. **Known fixes** — bugs and inconsistencies in the mockups to handle
6. **What NOT to build** — v2 backlog, explicitly out of scope for v1

You will also have access to:
- `mockups/screen-NN-*.html` — visual reference for each screen
- `code/design_tokens.dart`, `design_typography.dart`, `heritage_widgets.dart` — copy these into the project

When in doubt, the order of authority is:
1. This document
2. Per-screen specs (when they exist)
3. HTML mockups (visual reference)
4. Master context original (background only)

---

## 1. What this app is

**Sanatan Guide** is a fully offline Hindu scripture reader for Android (Flutter).

- **Content:** 1,33,613 verses across 31 scriptures (Bhagavad Gītā, four Vedas, eleven Upaniṣads, Rāmāyaṇa, Mahābhārata, Bhāgavata Purāṇa, Yoga Sūtras, Tirukkuṛaḷ, and more)
- **Stack:** Flutter, Riverpod 3, Drift/SQLite, GoRouter, Firebase, AdMob, Gemini 2.5 Flash
- **Package:** `com.Saurabh7973.sanatan_guide`
- **DB version:** 5+, ~72 MB

**Non-negotiables:**
- Fully offline. The only network call is to Gemini for AI chat.
- Sanskrit is treated with care. Every verse renders in Tiro Devanagari Sanskrit. Devanāgarī is never collapsed to romanization without preserving the original.
- The voice is direct, scholarly, contrarian where useful — never generic spiritual-app copy.
- Heritage signals are restrained and meaningful, not decorative.

**Aesthetic direction:** Pre-Islamic Indian heritage — Pallava/Chola/Hoysala temples, palm-leaf manuscripts (taal patra), Vedic yantra geometry. Saffron / turmeric / iron-red / warm white / deep brown. No cool tones.

**Explicitly REJECTED:**
- Mughal motifs (onion domes, jaali screens, Persian arches)
- Generic spiritual tropes (lotus watermarks, gradient sunsets)
- Stock Hindu app design (deity images on cards, marigold borders)
- Modern card UI on the Festivals screen (use almanac column instead)
- Any decoration that adds nothing functional

---

## 2. The design system

### 2.1 Tokens

Use `design_tokens.dart`. Do not invent new colors, fonts, or spacing. The dart file is the source of truth; this section is summary.

**Dark theme (default):**
- `dBg` #0F0F0F · `dSurface` #1C1816 · `dSurface2` #251F1B
- `dSaffron` #E8820C · `dSaffronDeep` #B86908 · `dSaffronGlow` 12% saffron
- `dCream` #F2E5CE · text at 100/62/38%
- `dDivider` 18% saffron · `dDividerSoft` 8% cream
- `dIronRed` #B85A3A (borders/icons only) · `dIronRedBright` #D17048 (text — better contrast)

**Light theme:**
- `lBg` #FDFAF6 · `lSurface` #F7F2EC · `lSurface2` #EFE7D7
- `lSaffron` #C26508 · `lSaffronDeep` #8B4806 · `lSaffronGlow` 8%
- `lText1` #2A1E14 at 100/65/40%
- `lIronRed` #8B2818 · `lIronRedBright` #A53520

**Typography:**
```
fSans   = Outfit                       UI, buttons, labels, metadata
fSerif  = Lora                          Reading prose, commentary, AI replies, titles
fDeva   = Tiro Devanagari Sanskrit      Sanskrit verses (always)
fDevaUI = Noto Sans Devanagari          UI Devanāgarī (numbers, tags, short labels)
```

**Sanskrit font-size scale (Settings slider controls this):** 14 / 16 / 18 / 20 / 22 / 24 / 28 px — default 18. Exposed via `sanskritFontSizeProvider` (Riverpod), persisted to SharedPreferences, consumed by Verse Detail.

**Spacing:** 4pt grid. 4, 8, 12, 14, 16, 18, 20, 22, 24, 28, 32 px.

**Radius:** Cards 4px · pills 11-18px · sheet 12px top · button 28px.

### 2.2 The six shared visual primitives

These six elements must be implemented identically every time they appear. They are the system. All are in `heritage_widgets.dart`.

**a. `BindingLine` — palm-leaf top marker**
A horizontal saffron-faded rule with a 5×5 px rotated diamond at center. Used at the top edge of any "leaf" surface — verse cards, bookmark leaves, citation cards in AI Chat, lineage footer on Credits, share preview card.

**b. `LeafThread` — saffron 3px strip on left edge**
3 px saffron rectangle on the left edge of a card or row, top-bottom inset by 8–12 px. **Means "your place / your active / your selection."**

Appears on: Resume rows (Chapter List, Verse List), Verse anchor on AI Chat verse-anchored mode, Selected level card in Onboarding, Continue anchor on Practice, Today row on Festivals, Knot mark on Bookmarks.

Always 3 px wide. Always saffron with a subtle box-shadow glow on dark theme.

**c. `DandaCoord` — Sanskrit verse references**
Renders coordinates using the manuscript double-vertical-bar convention: `‖१·१‖` (Devanāgarī) or `‖1.1‖` (Arabic fallback). **Always saffron** when used as an anchor or coordinate.

The `toDevanagari(int)` static helper converts Arabic digits to Devanāgarī digits. **Use it everywhere you display a number that the audience would expect in Devanāgarī** — verse coordinates, chapter numbers on Chapter List, source enumeration on Credits, dates on Festivals, etc.

**d. Devanāgarī numerals broadly**
Chapter numbers (१, २, ३...), Vikram Samvat year, dates on almanac, source enumeration on Credits. Use the same `DandaCoord.toDevanagari()` helper. Render in `Fonts.deva`.

**e. Iron-red ink — RESERVED**
Iron-red is for **two purposes only**:
1. Festival names on the Festivals/Almanac screen
2. Destructive actions and labels (Clear history, Reset, dialog confirm buttons)

Do not use iron-red anywhere else. **Audit fix needed:** Screen 03 (Library) currently uses iron-red for the Smṛti glyph — this is a violation. Replace with cream/`dText2`.

On dark theme: use `dIronRedBright` for text contrast (passes WCAG AA), `dIronRed` for borders/icons only.

**f. `AIThinkingDots` — three pulsing saffron dots**
When AI is thinking, three 5×5 px saffron circles pulse with 0.2s phase offset. Use across all AI-thinking states: Verse Detail "Explain", Search Pandit, AI Chat (both modes).

Specs: 1.4s pulse cycle, opacity 0.3 ↔ 1.0. The `_opacityFor` math has been corrected — see updated `heritage_widgets.dart`.

### 2.3 Type usage rules

- **Lora regular** → screen titles, prose body, module descriptions, festival prose, verse English translation
- **Lora italic** → AI replies, commentary, taglines, tooltips, empty-state copy, "subtle" body, notes textarea content. Italic is the literary register of the app
- **Outfit sans** → all UI chrome — buttons, labels, navigation, metadata, section labels (small caps)
- **Tiro Devanagari Sanskrit** → Sanskrit verses. Line-height ≥ 1.5, font-size ≥ 14 px
- **Noto Sans Devanagari** → Devanāgarī inside UI chrome (compact spaces)

**Font fallback chain (apply globally):** Every Sanskrit/Devanāgarī style declares `fontFamilyFallback: ['Noto Sans Devanagari', 'serif']`. Configure once in `app_theme.dart`.

### 2.4 Behavioral rules

- **Read tracking:** A verse is "read" when the user spends ≥ 3 seconds on Verse Detail. Stored in `verses_read(verse_id, first_read_at)`. Streak increments on first verse-read of the day.
- **Read-pace estimates:** Default 15 sec/verse (translation only) or 25 sec/verse (with commentary). After 20+ verses, derive personal pace.
- **First-launch state (Day 0):** No "Continue · X day streak" strip on Home — replace with "Begin Foundations" path strip. Streak counter = 0. Bookmarks empty. Module 1 of Foundations is "active." If user selected "beginner" in onboarding, surface Foundations Module 1 as the primary Home CTA.
- **Festivals data:** Bundle a 5-year panchāṅga JSON (~200 KB) covering 2026–2030 as a static asset. Read by both Festivals screen and Home "Upcoming Parva" card.
- **AI Chat:** TWO modes — verse-anchored (route from Verse Detail / Search result citation) and general (route from Search "Ask the Pandit" / Home overflow). Differ only in topbar: verse-anchored shows leaf-thread + Sanskrit incipit + daṇḍa coord at top; general shows compact title "ASK THE PANDIT" with small ॐ.
- **Bookmark counts:** Show ONLY on the Bookmarks screen header. Do NOT show on Library, Chapter List, or Verse List.
- **Number formatting:** Indian format for verse counts: `1,33,613`. Standard Western for times.
- **Translation languages:** v1 ships English only. Settings shows "English" without a chevron until Hindi ships.
- **Greeting on Home:** **No name field is collected.** Greeting is `Shubh Prabhat` (or by time of day) without a name. **Audit fix:** Screen 01 mockup shows `Shubh Prabhat, Saurabh` — ignore that. Remove the name.

### 2.5 Animation rules

**Standard durations:**
- Tap feedback: 120 ms
- Card/row entry: 350–450 ms with 60 ms stagger
- Sheet entry: 280 ms cubic-bezier(0.32, 0.72, 0, 1)
- Page transition: 280 ms
- AI streaming token: word-by-word fade-in, ~30 ms/word
- Overflow menu open: 180 ms scale+fade from top-right origin
- LeafThread pulse-once: 1200 ms ease-in-out

Default easing: `Curves.easeOut` for entrances, `Curves.easeInOut` for transitions.

### 2.6 Accessibility

- Hit targets: minimum 44×44 px
- Contrast: all text passes WCAG AA on its background
- Sanskrit screen-reader: `lang: 'sa'` for Sanskrit, `'hi'` for Hindi, `'en'` for English
- Iron-red on dark = `dIronRedBright` for text (#D17048 ≈ 5.2:1), `dIronRed` for borders only

---

## 3. The cross-reference map

**This is the most important section if you've ever asked "where does this redirect from?"** It defines every screen, where it can be reached from, and where it links to.

### 3.1 Bottom navigation

Three tabs only: **Today · Practice · Texts**. No more, ever.

Bottom nav appears ONLY on the three tab root screens. Every other screen — Verse Detail, Chapter List, Verse List, AI Chat, Search, Bookmarks, Festivals, Settings, Onboarding, Credits, Feedback — does NOT show the bottom nav.

### 3.2 Topbar variants

**Home topbar:**
```
सनातन                  [search] [bookmark] [⋯]
```
Three trailing icons. Bookmark icon has optional saffron dot indicator (v2 feature; in v1 the indicator never shows). Tap ⋯ opens the overflow menu.

**Library/Texts topbar:**
```
[inline search field]   [bookmark] [⋯]
```
The inline search field is the search affordance (no separate search icon). Same overflow menu.

**Practice topbar:**
```
Practice                                [⋯]
```
Just the overflow menu. No search/bookmark needed inside a curriculum surface.

**All drill-down topbars (Chapter List, Verse List, Verse Detail, AI Chat, Search, Bookmarks, Festivals, Festival Detail, Settings, Credits, Feedback, Module reader):**
```
[ ← back ]   [context]   [optional verse-scoped actions]
```
Back button only on the left. No global search/bookmark/overflow.

### 3.3 The overflow menu (220px popover, anchored top-right)

Three items:
1. **Settings** → `/settings`
2. **Send feedback** → `/feedback`
3. **About this app** → `/credits`

55% black backdrop scrim. Tap scrim to dismiss. 180 ms scale+fade in.

### 3.4 The complete route map

```
/                          Today (Home)         [tab 1]
/practice                  Practice/Your Path   [tab 2]
/practice/module/:id       Module reader        [drill-down]
/texts                     Library              [tab 3]
/texts/:scripture          Chapter List         [drill-down]
/texts/:scripture/:ch      Verse List           [drill-down]
/texts/:scripture/:ch/:v   Verse Detail         [drill-down]
/search                    Search               [drill-down]
/bookmarks                 Bookmarks (Pothī)    [drill-down]
/festivals                 Festivals (Almanac)  [drill-down]
/festivals/:id             Festival detail      [drill-down]
/chat/:verse_id            AI Chat verse-anchor [drill-down]
/chat                      AI Chat general      [drill-down]
/settings                  Settings             [drill-down]
/settings/credits          Credits (alias /credits)
/settings/feedback         Send Feedback (alias /feedback)
/onboarding/welcome        Onboarding step 1    [no chrome]
/onboarding/reminder       Onboarding step 2    [no chrome]
```

### 3.5 Entry point matrix — where can you reach each screen FROM?

This is the table to use when you're stuck on "how do I get to X."

| Destination | Reached from | Trigger | Notes |
|---|---|---|---|
| **Home** | App launch, post-onboarding | implicit | Tab 1 |
| **Home** | Any tab root | tap "Today" tab | |
| **Practice** | Any tab root | tap "Practice" tab | |
| **Practice module** | Practice | tap unlocked module | |
| **Library** | Any tab root | tap "Texts" tab | |
| **Chapter List** | Library | tap a scripture row | |
| **Chapter List** | Home "Continue reading" | tap | Resumes user's progress |
| **Verse List** | Chapter List | tap a chapter row | |
| **Verse Detail** | Verse List | tap a verse row | |
| **Verse Detail** | Home "Verse of the Day" | tap "Read full verse" | |
| **Verse Detail** | Search results | tap a result | |
| **Verse Detail** | Search coordinate match | tap resolved card | |
| **Verse Detail** | Bookmarks | tap a saved verse | |
| **Verse Detail** | AI Chat citation | tap inline citation card | back returns to chat |
| **Verse Detail** | Festival detail | tap a related verse | |
| **Search** | Home topbar | tap search icon | Field auto-focused |
| **Search** | Library topbar | tap inline search field | Field auto-focused |
| **Bookmarks** | Home topbar | tap bookmark icon | |
| **Bookmarks** | Library topbar | tap bookmark icon | |
| **AI Chat verse-anchored** | Verse Detail | tap "Explain this verse" CTA | Pre-filled with verse-specific Q |
| **AI Chat verse-anchored** | Search results | tap "Ask follow-up" on Pandit answer | |
| **AI Chat general** | Search empty state | tap "Ask the Pandit" CTA | No verse anchor |
| **AI Chat general** | Home overflow → "Ask the Pandit" | tap | **Add this to overflow as 4th item** for general access (see 3.3 update below) |
| **Festivals** | Home "Upcoming Parva" card | tap | Primary entry |
| **Festivals** | Home overflow menu | tap "Festivals" | **Add this to overflow as 5th item** for secondary access |
| **Festival detail** | Festivals | tap a row with festival in iron-red | |
| **Settings** | Home overflow menu | tap "Settings" | |
| **Settings** | Library overflow menu | tap "Settings" | |
| **Settings** | Practice overflow menu | tap "Settings" | |
| **Credits** | Settings → "Credits & attributions" | tap row | |
| **Credits** | Home overflow → "About this app" | tap | Same destination |
| **Send Feedback** | Settings → "Send feedback" | tap row | |
| **Send Feedback** | Home overflow → "Send feedback" | tap | |
| **Notes bottom sheet** | Verse Detail action bar | tap "Notes" icon | Modal sheet, doesn't leave Verse Detail |
| **Share bottom sheet** | Verse Detail action bar | tap "Share" icon | Modal sheet, doesn't leave Verse Detail |
| **Privacy Policy** | Settings → "Privacy Policy" | tap row | Opens external URL via browser |
| **Terms of Service** | Settings → "Terms of Service" | tap row | Opens external URL via browser |
| **Onboarding** | First launch only | implicit | Skipped on subsequent launches |

### 3.6 Overflow menu — UPDATED to 5 items

The overflow menu listed in 3.3 expands to 5 items, in this order:

1. **Settings** → `/settings`
2. **Festivals & Calendar** → `/festivals` *(secondary entry)*
3. **Ask the Pandit** → `/chat` *(general mode AI chat)*
4. **Send feedback** → `/feedback`
5. **About this app** → `/credits`

This solves three audit issues at once: Festivals has a stable secondary entry, AI Chat general mode is reachable without going through Search, and Settings/Credits/Feedback are all in one place.

### 3.7 Back-stack behavior

- **Tab roots** (Home, Practice, Texts): swiping back exits the app or returns to previous tab
- **Drill-down screens:** back returns to the previous screen (the one that opened this one)
- **AI Chat citation tap → Verse Detail:** back returns to the chat with conversation preserved
- **Modal sheets** (Notes, Share, overflow menu): back/scrim-tap dismisses the sheet only

### 3.8 Deep links (for share feature and AdMob redirects)

URL scheme: `sanatanguide://`

- `sanatanguide://verse/{scripture}/{ch}/{v}` → Verse Detail
- `sanatanguide://chapter/{scripture}/{ch}` → Verse List
- `sanatanguide://scripture/{scripture}` → Chapter List

Plus the public-web equivalent at `https://sanatanguide.app/{scripture}/{ch}/{v}` for non-app recipients of shared verses.

---

## 4. Per-screen build instructions

For each screen, I list: mockup file, route, what to build, and any cross-screen connection notes.

### Screen 1 — Home (Today)
- **Route:** `/`
- **Mockup:** `screen-01-home.html`
- **Build order:** #3 (after core widgets + Onboarding)
- **What to build:**
  - Topbar: सनातन brand + Search/Bookmark/⋯ icons (3.2)
  - Greeting block: time-aware greeting only (no name)
  - Panchāṅga inscriptional line + Vikram Samvat year
  - Verse-of-the-Day hero card (BindingLine top+bottom + LeafThread NOT used here)
  - "Continue reading" strip (LeafThread used here for resume affordance)
  - "Your Path · Foundations" strip
  - "Upcoming Parva" pill at bottom → routes to `/festivals`
- **Cross-refs:** Search icon → `/search`. Bookmark icon → `/bookmarks`. ⋯ → overflow menu. "Read full verse" → `/texts/:scripture/:ch/:v`. Continue strip → `/texts/:scripture/:ch/:v` at last position. Path strip → `/practice/module/:id`. Upcoming Parva → `/festivals`.
- **States:** default, loading, error, first-day (no progress yet)
- **Audit fix:** Mockup shows "Shubh Prabhat, Saurabh" — strip the name. Mockup doesn't show new topbar — add Search/Bookmark/⋯ icons per Screen 13 mockup.

### Screen 2 — Verse Detail
- **Route:** `/texts/:scripture/:ch/:v`
- **Mockup:** `screen-02-verse-detail.html`
- **Build order:** #7 (after reading flow chain)
- **What to build:**
  - Compact topbar: back + scripture+chapter context + bookmark icon + share icon
  - Progress rail (chapter X / Y)
  - The Leaf: BindingLine top, verse coord (DandaCoord), Sanskrit (tappable words), BindingLine bottom
  - Word callout (tap a Sanskrit word → 220px floating callout with deva + IAST + meaning + grammar)
  - Transliteration section
  - Translation section (left-aligned Lora, attribution right-aligned)
  - "Explain this verse" CTA card → tap routes to `/chat/:verse_id` with the question pre-filled
  - Bottom utility bar: prev/next chevrons + Translation switcher + Listen + Notes + (5 things in one strip)
- **Cross-refs:** "Explain this verse" → `/chat/:verse_id`. Bookmark icon toggles bookmark (no navigation). Share icon → opens Share bottom sheet (modal). Notes icon → opens Notes bottom sheet (modal). Word tap → inline callout (no navigation).
- **States:** default, word-tapped, AI commentary expanded (if "Explain" was inline rather than chat), AI thinking, loading, error
- **Audit fix:** "Listen" icon — remove from v1 OR show but tap opens a "Coming soon" sheet. Recommendation: **remove from v1**, makes the bottom bar 4 actions instead of 5.

### Screen 3 — Library (Texts)
- **Route:** `/texts`
- **Mockup:** `screen-03-library.html`
- **Build order:** #4
- **What to build:**
  - Topbar: inline search field + Bookmark + ⋯
  - Hero stat: "1,33,613 verses · 31 scriptures"
  - Section: Vedas (2×2 grid, 3:2 Sulba ratio)
  - Section: Upaniṣads (rows)
  - Section: Itihāsa & Purāṇa (rows)
  - Section: Dharmaśāstra & Sūtra literature (rows)
  - Section: Tamil traditions (rows, name in Tamil script)
- **Cross-refs:** Search field tap → `/search` with field auto-focused. Bookmark icon → `/bookmarks`. ⋯ → overflow menu. Each scripture row → `/texts/:scripture`.
- **Audit fix:** Smṛti glyph in mockup uses iron-red — **change to dCream or dText2**. Iron-red is reserved for Festivals + destructive only.

### Screen 4 — Chapter List
- **Route:** `/texts/:scripture`
- **Mockup:** `screen-04-chapter-list.html`
- **Build order:** #5
- **What to build:**
  - Compact topbar: back + scripture name + scripture-units count ("18 chapters · 700 verses")
  - Resume row (with LeafThread + one-time pulse) when user has a position
  - Chapter rows: Devanāgarī chapter number (१ २ ३) + Sanskrit chapter title + English title + reading time + hairline progress
  - Different scriptures use different unit names (Parvas for Mahābhārata, Kāṇḍas for Rāmāyaṇa, Maṇḍalas for Rigveda)
- **Cross-refs:** Tap a row → `/texts/:scripture/:ch`. Resume row → `/texts/:scripture/:ch/:v` at last position.

### Screen 5 — Verse List
- **Route:** `/texts/:scripture/:ch`
- **Mockup:** `screen-05-verse-list.html`
- **Build order:** #6
- **What to build:**
  - Compact topbar with chapter context + hairline progress
  - Resume row (LeafThread) when applicable
  - Verse rows with DandaCoord (‖१‖, ‖२‖) + Sanskrit incipit + English gist
  - Three row states: read / unread / bookmarked
  - Verse jumper sticky right edge (Devanāgarī numeral scrubber) for chapters with 30+ verses
- **Cross-refs:** Tap a verse row → `/texts/:scripture/:ch/:v`.

### Screen 6 — Search
- **Route:** `/search`
- **Mockup:** `screen-06-search.html`
- **Build order:** #9
- **What to build:**
  - Topbar: back + search field (auto-focused if routed in)
  - Empty state: "Recent" section (if any) + "Search any way" section (By phrase / Sanskrit word / coordinate / question)
  - Coordinate detection: typing "BG 2.47" surfaces a saffron-leaf-thread "Direct match" card above results
  - Results grouped by scripture, with match highlighting (saffron tint on matched substring)
  - "Ask the Pandit" CTA at bottom of empty state → routes to `/chat` (general mode)
  - Search-as-you-type with 3-saffron-dots thinking indicator
- **Cross-refs:** Coordinate-match card → `/texts/:scripture/:ch/:v`. Result row → `/texts/:scripture/:ch/:v`. "Ask the Pandit" → `/chat` (general). Recent search → re-runs query. "View all" on group → expanded results filtered to scripture.
- **States:** empty (returning user with recents), empty (no recents — skip Recent section), typing+coord-detected, results grouped, searching (loading), Pandit answer with cited verses.

### Screen 7 — Bookmarks
- **Route:** `/bookmarks`
- **Mockup:** `screen-07-bookmarks.html`
- **Build order:** #8
- **What to build:**
  - Topbar: back + "पोथी · Your collection" + count
  - Sort tabs: Recent / By scripture
  - Each saved verse renders as a leaf: BindingLine top + saffron knot-mark (silk thread) upper-right + verse content + optional italic-serif personal note line
  - Empty state: three abstract leaves on saffron thread
- **Cross-refs:** Tap a leaf → `/texts/:scripture/:ch/:v`. Tap the knot-mark → unbookmark with undo toast.
- **Naming:** Route is `/bookmarks`. Display name on the screen header is "पोथी · Your collection." In settings rows and elsewhere, use "Bookmarks."

### Screen 8 — Festivals
- **Route:** `/festivals`
- **Mockup:** `screen-08-festivals.html`
- **Build order:** #10
- **What to build:**
  - Top: Panchāṅga banner (all 5 limbs: Tithi, Vāra, Nakṣatra, Yoga, Karaṇa)
  - Vikram Samvat year throughout
  - Almanac column layout (NOT festival cards) — each day = horizontal row with Gregorian date + lunar phase circle + tithi/nakṣatra + festival name in iron-red (`dIronRedBright`)
  - Filter strip: All / Major parvas / Vrats / Regional
  - Today row marked with LeafThread
- **Cross-refs:** Tap a row with a festival → `/festivals/:id`.
- **Festival detail page:** typography-only, no deity images. Iron-red headline + Sanskrit name + significance prose + related verses (tap → Verse Detail).

### Screen 9 — Settings
- **Route:** `/settings`
- **Mockup:** `screen-09-settings.html`
- **Build order:** #11
- **What to build:**
  - Plain sans-serif title (no Devanāgarī decoration)
  - Sections: Appearance / Reading / Notifications / Data / About / Reset (iron-red)
  - Appearance: 3-segment Auto/Light/Dark theme picker
  - Reading: Font-size slider (7 ticks → SanskritScale), Sanskrit display preferences, Language ("English" no chevron for v1)
  - Notifications: Daily reminder toggle + time picker
  - Data: Storage info (72.1 MB), Export bookmarks
  - About: App version (centered footer), Credits & attributions row, Privacy Policy (external), Terms of Service (external)
  - Reset: iron-red destructive section with confirmation dialog
- **Cross-refs:** Credits & attributions row → `/credits`. Send feedback row → `/feedback`. Privacy/Terms → external URL via browser. Reset → confirmation dialog.

### Screen 10 — AI Chat (verse-anchored mode)
- **Route:** `/chat/:verse_id`
- **Mockup:** `screen-10-ai-chat.html`
- **Build order:** #10
- **What to build:**
  - Persistent verse anchor at top: LeafThread + daṇḍa coord + Sanskrit incipit + scripture name
  - User messages: compact rounded sans-serif bubbles right-aligned with saffron tint
  - AI replies: flowing Lora italic prose, NO bubbles
  - Inline citation cards mid-reply: BindingLine motif + daṇḍa coord + Sanskrit + English + arrow → tap routes to Verse Detail
  - Verse-specific suggested questions (3-4 chips)
  - Input bar at bottom: "Ask about this verse..." placeholder
  - 3-saffron-dots thinking indicator
- **Cross-refs:** Citation tap → `/texts/:scripture/:ch/:v`. Back returns to Verse Detail (the screen that opened this chat).

### Screen 11 — Onboarding
- **Route:** `/onboarding/welcome`, `/onboarding/reminder`
- **Mockup:** `screen-11-onboarding.html`
- **Build order:** #2 (right after core widgets)
- **What to build:**
  - 2 screens total (NOT 3)
  - Screen 1: Welcome+level combined. Logomark ॐ + invocation watermark "॥ श्री गणेशाय नमः ॥" + 3 level cards (Beginner/Regular/Scholar) with LeafThread on selected
  - Screen 2: Daily reminder prompt with bell glyph + time picker BEFORE system permission prompt
  - Skip option on every screen
- **Cross-refs:** Onboarding completion → routes to `/`. If beginner selected, Home shows "Begin Foundations" as primary CTA instead of Continue.
- **Persisted prefs:** `level` (default: regular), `reminderEnabled` (default: false), `reminderTime` (default: 7:00 AM), `onboardingCompleted` (set true on exit).

### Screen 12 — Practice / Your Path
- **Route:** `/practice`
- **Mockup:** `screen-12-practice.html`
- **Build order:** #11
- **What to build:**
  - Topbar: "Practice" title + ⋯
  - 7-day week strip (NOT full-month calendar) — streak visualization, secondary
  - Continue anchor: next module with LeafThread (5th appearance of leaf-thread vocabulary)
  - Curriculum is primary: Foundations section with 8 modules connected by a continuous vertical hairline + diamond knots
  - Deepening locked section visible below Foundations
  - "III. Mastery" horizon card hints at future scope without unlocking
- **Cross-refs:** Tap a module → `/practice/module/:id`. Locked module shows toast: "Complete X more Foundations modules to unlock."
- **Voice note:** Use the user's actual app copy where it exists (e.g., "108 Upanishads exist. Ten of them contain everything."). Saurabh's copy is more compelling than placeholders in mockups.

### Screen 13 — Navigation / Credits / Feedback
- **Routes:** Topbar (composed into Home/Library), `/credits`, `/feedback`
- **Mockup:** `screen-13-navigation-credits-feedback.html`
- **Build order:** #14 (last)
- **What to build:**
  - Home/Library topbar icons (Search/Bookmark/⋯)
  - Overflow menu (5 items per 3.6 above)
  - Credits screen: sūtra-style enumeration (१ २ ३ in saffron) + sections grouped by domain + lineage footer with BindingLine and Bṛhadāraṇyaka blessing
  - Feedback flow: 2 states (pick kind → compose)
- **Cross-refs:** All overflow items routed per 3.4. Credits external-link arrows on GRETIL/sacred-texts/Project Madurai rows open browser.
- **Required Credits sources (do not omit):** GRETIL, sacred-texts.com/Griffith, Project Madurai (Tirukkuṛaḷ), indic-transliteration library, the four fonts (OFL), Flutter/Riverpod/Drift stack.

### Screen 14 — Missing flows (NEW)
- **Mockup:** `screen-14-missing-flows.html`
- **Build order:** AI Chat general #10 (alongside verse-anchored). Notes #7. Share #7.
- **What to build:**

  **AI Chat general mode (`/chat`):**
  - Same chrome as verse-anchored EXCEPT compact title block at top: small ॐ + "ASK THE PANDIT" small-caps (no verse anchor strip)
  - Empty state: large ॐ + question + 4 example chips
  - Conversation: same message styling as verse-anchored
  - Input placeholder: "Ask anything about the texts..." (distinct from verse-anchored)
  - "New conversation" + icon top-right when conversation exists

  **Notes bottom sheet (modal from Verse Detail):**
  - Header: "Your note" + verse coord (DandaCoord, saffron)
  - Lora italic textarea, 200-char limit, counter bottom-right
  - Actions: Delete (tertiary, only when editing) · Cancel · Save (primary, disabled until content)
  - One note per verse; existing notes appear on Bookmarks screen
  - Drift table: `notes(verse_id PRIMARY KEY, text TEXT, created_at, updated_at)`

  **Share bottom sheet (modal from Verse Detail):**
  - Three-segment format chooser: Sanskrit only / + Translation (default) / Full citation
  - Live preview card with BindingLine + DandaCoord + content + deep link
  - Actions: Copy text · Share (invokes system share sheet)
  - **Canonical format strings — do not deviate:**
    ```
    Sanskrit only:
    {deva}
    
    — {scripture} {coord}
    {deep_link}
    
    + Translation:
    {deva}
    
    "{translation}"
    
    — {scripture} {coord}
    {deep_link}
    
    Full citation:
    {deva}
    
    {transliteration}
    
    "{translation}"
    
    — {scripture} {coord} ({attribution})
    {deep_link}
    ```

---

## 5. Known fixes — handle while building

These are the audit findings. Address each before shipping.

### 5.1 Critical (will cause real bugs)

1. **Home greeting:** Remove user's name. Use `Shubh Prabhat` / time-of-day only.
2. **Library Smṛti glyph:** Change from iron-red to cream/`dText2`. Iron-red is reserved.
3. **AIThinkingDots phase math:** Use the corrected logic in `heritage_widgets.dart` (triangle wave, not the broken version in mockup CSS).
4. **Iron-red text on dark:** Force `dIronRedBright` (#D17048). Festivals iron-red text especially.

### 5.2 High (will cause inconsistency)

5. **Home topbar:** Add Search/Bookmark/⋯ icons. The Screen 01 mockup is stale on this; use Screen 13 mockup as the topbar reference.
6. **Bookmarks naming:** Route `/bookmarks`. Screen display "पोथी · Your collection." Settings row and casual references: "Bookmarks."
7. **Festivals secondary entry:** Add to overflow menu (item 2). Primary entry is still Home Upcoming Parva card.
8. **AI Chat general mode:** Build it. Screen 14 covers the design. Add `/chat` route in addition to `/chat/:verse_id`.
9. **Font fallback chain:** Add `fontFamilyFallback: ['Noto Sans Devanagari', 'serif']` to all Sanskrit text styles globally in `app_theme.dart`.

### 5.3 Medium (will save time)

10. **Notes feature:** Build per Screen 14. Drift table + Verse Detail action + Bookmarks display + bottom sheet.
11. **Share feature:** Build per Screen 14. Modal sheet with format chooser + canonical format strings.
12. **Listen icon:** Remove from Verse Detail bottom bar in v1. Audio is v2.
13. **Sanskrit font-size provider:** Riverpod provider, persisted to SharedPreferences, read by Verse Detail, set by Settings slider.
14. **Bottom nav appearance rule:** Bottom nav appears ONLY on Today/Practice/Texts root screens.

### 5.4 Spec gaps to fill before building

15. Generate per-screen specs for screens 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14 using the prompt template in `HOW_TO_BRIEF_CLAUDE_CODE.md`. Don't build a screen without a spec. The spec is reviewed by Saurabh before code is written.

---

## 6. What NOT to build — v2 backlog

Do NOT implement any of these in v1, even if they seem easy. They're documented here so you know what's intentionally out of scope.

| Feature | Why not v1 | What to do instead |
|---|---|---|
| Hindi translation layer | Corpus not yet seeded | English only. Settings shows "English" with no chevron. |
| Audio recitation | No audio files, no licensing | Remove Listen icon from Verse Detail. |
| Bookmark cross-device sync | No backend in v1 | The saffron dot indicator on Bookmark icon stays in design but never lights up. |
| Bookmark collections / tags | Adds DB complexity | Filter strip is "Recent / By scripture" only. |
| Search semantic mode | Embedding infrastructure not built | Search is text-matching + coord detection only. AI chat is the semantic surface. |
| Share-as-image card | Image rendering is heavy | Share is text + deep link only. |
| Multi-language UI | i18n infrastructure not set up | UI strings in English. |
| Streak rescue / freeze tokens | Habit feature, scope creep | Streak breaks on missed day, no mitigation. |
| Verse-of-the-day in notification body | Local notif limits + design | Notification is plain reminder; user opens app to see the verse. |
| Persisted AI chat history | Storage + UX complexity | AI chat is per-session. "New conversation" clears it. |
| Verse history scroll | Niche feature | The progress rail on Verse Detail is enough. |
| Pro/paid tier | No payment integration | App is free with AdMob ads (existing). |

If a user asks for any of these in feedback, that's a v2 input. Don't build it in v1.

---

## 7. Implementation order

| # | Build | Why this order |
|---|---|---|
| 1 | `design_tokens.dart`, `design_typography.dart`, `heritage_widgets.dart` | Foundation for everything |
| 2 | Verify the 6 primitives render correctly with a dev-preview page | Catch issues before they propagate |
| 3 | Onboarding (Screens 11) | Entry point; sets up prefs |
| 4 | Home/Today (Screen 1) with new topbar | Landing surface |
| 5 | Library (Screen 3) | Branches into reading flow |
| 6 | Chapter List (Screen 4) | Reading flow |
| 7 | Verse List (Screen 5) | Reading flow |
| 8 | Verse Detail (Screen 2) + Notes sheet + Share sheet (from Screen 14) | Core reading + verse-scoped actions |
| 9 | Bookmarks (Screen 7) | Depends on read flow |
| 10 | Search (Screen 6) | Depends on corpus + verse routing |
| 11 | AI Chat — verse-anchored (Screen 10) + AI Chat general (Screen 14) | Both together; share infrastructure |
| 12 | Festivals (Screen 8) + Festival detail | Depends on bundled panchāṅga data |
| 13 | Practice / Your Path (Screen 12) | Depends on read tracking |
| 14 | Settings (Screen 9) | Late; depends on all toggles |
| 15 | Credits (Screen 13) + Send Feedback (Screen 13) | Last; small screens behind Settings |

---

## 8. The operating procedure

**Each build session uses this prompt template:**

```
TASK: Build the [SCREEN NAME] screen for Sanatan Guide.

CONTEXT:
- Read SANATAN_GUIDE_BUILD_BRIEF.md fully if you haven't already.
- Reference mockup: mockups/screen-[XX]-[name].html
- All tokens: lib/core/theme/design_tokens.dart
- All text styles: lib/core/theme/design_typography.dart
- All shared widgets: lib/core/widgets/heritage_widgets.dart
- Per-screen spec (if it exists): .claude/screen_specs/[XX]_*.md

CONSTRAINTS:
- Riverpod for state, GoRouter for navigation
- Use ONLY tokens from design_tokens.dart — no hardcoded colors/fonts
- Use ONLY styles from design_typography.dart — no inline TextStyles  
- Use shared widgets from heritage_widgets.dart for binding lines,
  leaf threads, daṇḍa coordinates, AI thinking dots, Sanskrit text
- Both dark and light themes must work from day one
- Match the mockup visually; structure, hierarchy, motion must match

REMINDER FROM SECTION 3 OF THE BRIEF:
- Bottom nav appears ONLY on Today / Practice / Texts
- Search/Bookmark/⋯ topbar icons only on Home and Library
- Drill-down screens have back-button only
- This screen is reached from: [list from section 3.5 entry matrix]
- This screen routes to: [list per-screen instructions]

DELIVERABLE:
- New file at lib/features/[feature_name]/[screen_name].dart
- Providers at lib/features/[feature_name]/providers/
- All states from the spec (default, loading, empty, error)
- Both themes rendering correctly
- Animations from the spec

PROCESS:
1. Read the spec file and mockup. Confirm you understand.
2. List the files you plan to create.
3. Show the provider/state shape before writing UI.
4. Build the screen.
5. Run `flutter analyze` and fix issues.
6. Show me the result.

Do NOT proceed past step 2 without my approval.
```

**For visual fixes:** "The [element] doesn't match the mockup. The mockup shows [describe]. Adjust."

**For state fixes:** "The [empty/loading/error] state isn't right. The spec/brief says [reference section]. Fix."

**For token violations:** "You used a hardcoded [color/font/size]. Replace with the token from design_tokens.dart."

**For violations of these rules:** Quote the relevant section of this brief back. "Section 3.2 says drill-down screens have back-button only — your Verse Detail topbar has Bookmark and Share, which is correct. But you've added Search, which is not. Remove it."

---

## 9. Final note

The point of this brief: **Claude Code never has to ask "where does this redirect from?" or "what does this look like?" or "is this in v1?"** Every answer is in this file, the per-screen specs, the mockups, or the design tokens.

If Claude Code asks something already in this brief, point it back at the section. Don't re-explain.

If Claude Code suggests deviating from the brief, push back. The brief is the brief. We iterate after v1 ships.

— End of brief —
