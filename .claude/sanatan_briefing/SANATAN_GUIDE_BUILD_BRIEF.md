# SANATAN GUIDE — Build Brief for Claude Code (v1.1)

> **Read this entire file before doing anything.** This is the canonical brief. Every other file in this repo is supporting material referenced from here. If anything in another file contradicts this one, this file wins.

> **What's new in v1.1:** Added Screens 15 (Module Reader + Module Complete) and 16 (System Chrome — toasts, dialogs, time picker, splash, word callout, edge cases, ad placement, error states). The brief now covers everything needed for v1 ship.

---

## 0. How to read this document

Six parts:
1. **What this app is** — context and stack
2. **The design system** — tokens, fonts, vocabulary, rules
3. **The cross-reference map** — every screen, how to reach it, where it links to
4. **Per-screen build instructions** — what to build for each of 18 screens/flows
5. **Known fixes** — bugs and inconsistencies in mockups to handle
6. **What NOT to build** — v2 backlog, explicitly out of scope

Supporting files:
- `mockups/screen-NN-*.html` — visual reference
- `code/design_tokens.dart`, `design_typography.dart`, `heritage_widgets.dart` — copy into project

Order of authority: this brief > per-screen specs > HTML mockups > everything else.

---

## 1. What this app is

**Sanatan Guide** — fully offline Hindu scripture reader for Android (Flutter).

- **Content:** 1,33,613 verses across 31 scriptures
- **Stack:** Flutter, Riverpod 3, Drift/SQLite, GoRouter, Firebase, AdMob, Gemini 2.5 Flash
- **Package:** `com.Saurabh7973.sanatan_guide`
- **DB:** v5+, ~72 MB

**Non-negotiables:** Fully offline (only AI chat hits network). Sanskrit treated with care (Tiro Devanagari Sanskrit, never collapsed to romanization). Direct, scholarly voice — never generic spiritual-app copy. Restrained heritage signals, not decorative.

**Aesthetic:** Pre-Islamic Indian heritage — Pallava/Chola/Hoysala temples, palm-leaf manuscripts, Vedic yantra geometry. Saffron / turmeric / iron-red / warm white / deep brown.

**REJECTED:** Mughal motifs, generic spiritual tropes, stock Hindu app design, modern card UI on Festivals, deity images on cards, marigold borders, any decoration that adds nothing functional.

---

## 2. The design system

### 2.1 Tokens

Use `design_tokens.dart`. Do not invent values.

**Dark theme (default):**
- `dBg` #0F0F0F · `dSurface` #1C1816 · `dSurface2` #251F1B
- `dSaffron` #E8820C · `dSaffronDeep` #B86908 · `dSaffronGlow` 12% saffron
- `dCream` #F2E5CE · text at 100/62/38%
- `dDivider` 18% saffron · `dDividerSoft` 8% cream
- `dIronRed` #B85A3A (borders/icons only) · `dIronRedBright` #D17048 (text — WCAG AA on dark)

**Light theme:** mirror values per `design_tokens.dart`.

**Typography:**
- `fSans = Outfit` — UI chrome, buttons, labels, metadata
- `fSerif = Lora` — reading prose, commentary, AI replies, titles
- `fDeva = Tiro Devanagari Sanskrit` — Sanskrit verses (always)
- `fDevaUI = Noto Sans Devanagari` — UI Devanāgarī (numbers, tags, compact)

**Sanskrit font-size scale:** 14/16/18/20/22/24/28 px (default 18). Exposed via `sanskritFontSizeProvider` Riverpod, persisted, consumed by Verse Detail.

**Spacing:** 4pt grid. 4, 8, 12, 14, 16, 18, 20, 22, 24, 28, 32 px.

**Radius:** Cards 4 · pills 11–18 · sheet 12 top · button 28.

### 2.2 The six visual primitives

All in `heritage_widgets.dart`. Implemented identically every time they appear.

**a. `BindingLine`** — palm-leaf top marker, horizontal saffron-faded rule with 5×5px rotated diamond at center. Used at top edge of "leaf" surfaces.

**b. `LeafThread`** — 3px saffron strip on left edge of card/row, top-bottom inset 8–12px. Means "your place / active / selected." Always saffron with subtle glow on dark.

**c. `DandaCoord`** — Sanskrit verse references with double-vertical-bar convention: `‖१·१‖` or `‖1.1‖`. Always saffron. The `toDevanagari(int)` helper is the canonical int→Devanāgarī numeral converter for the whole app.

**d. Devanāgarī numerals broadly** — chapter numbers, dates, Vikram Samvat year, source enumeration. Use `Fonts.deva` and `DandaCoord.toDevanagari()`.

**e. Iron-red ink — RESERVED**:
1. Festival names on Festivals/Almanac
2. Destructive actions (Reset, dialog destructive buttons)
3. **NEW: "KEY VERSE" pill on Module Reader Key Verse step** (the "featured" semantic, not destructive)

On dark theme: `dIronRedBright` for text, `dIronRed` for borders/icons only.

**f. `AIThinkingDots`** — three 5×5px saffron circles, 1.4s pulse, 0.2s phase offset, opacity 0.3↔1.0. Used for all AI thinking + pull-to-refresh indicator.

### 2.3 Type usage
- Lora regular → titles, prose body, verse English
- Lora italic → AI replies, commentary, taglines, empty-state copy, notes
- Outfit sans → all UI chrome
- Tiro Devanagari Sanskrit → Sanskrit verses (line-height ≥ 1.5, size ≥ 14px)
- Noto Sans Devanagari → UI Devanāgarī (compact spaces)

**Font fallback:** Global config in `app_theme.dart` — every Sanskrit/Devanāgarī style declares `fontFamilyFallback: ['Noto Sans Devanagari', 'serif']`.

### 2.4 Behavioral rules

- **Read tracking:** Verse "read" at ≥3 sec on Verse Detail. Stored in `verses_read(verse_id, first_read_at)`. Streak on first verse-read of day.
- **Read-pace:** Default 15 sec/verse (translation) or 25 sec/verse (with commentary). Personalize after 20+ verses.
- **First-launch (Day 0):** No streak strip — show "Begin Foundations" path strip. If beginner level selected, Home surfaces Foundations Module 1 as primary CTA.
- **Festivals:** Bundled 5-year panchāṅga JSON (~200KB) for 2026–2030.
- **AI Chat:** Two modes — verse-anchored (`/chat/:verse_id`) and general (`/chat`). Differ only in topbar.
- **Bookmark counts:** Only on Bookmarks screen header.
- **Number formatting:** Indian for counts (`1,33,613`), Western for times.
- **Translation:** v1 = English only. Settings shows "English" with no chevron.
- **Greeting:** No name collected. `Shubh Prabhat` (time-of-day) alone.

### 2.5 Motion
- Tap feedback: 120ms
- Card/row entry: 350–450ms, 60ms stagger
- Sheet entry: 280ms cubic-bezier(0.32, 0.72, 0, 1)
- Page transition: 280ms
- Toast: 240ms slide-up + fade
- Dialog: 200ms fade + 0.96→1.0 scale
- Overflow menu: 180ms scale+fade from top-right
- Word callout: 180ms fade + scale from anchor
- LeafThread pulse-once: 1200ms ease-in-out
- AI streaming: ~30ms/word fade-in

### 2.6 Accessibility
- Hit targets ≥ 44×44 px
- WCAG AA contrast for all text
- Sanskrit `lang: 'sa'`, Hindi `lang: 'hi'`, English `lang: 'en'` for screen readers
- Iron-red on dark = `dIronRedBright` for text only

---

## 3. Cross-reference map

### 3.1 Bottom navigation
Three tabs: **Today · Practice · Texts**. Period.

Bottom nav appears ONLY on tab roots. Drill-down, modal, onboarding, module reader — none show bottom nav.

### 3.2 Topbar variants
**Home:** `सनातन    [search] [bookmark] [⋯]`
**Library:** `[inline search field]  [bookmark] [⋯]`
**Practice:** `Practice                                [⋯]`
**All drill-downs:** `[←]  [context]  [verse-scoped actions]` — back-only on left

### 3.3 Overflow menu (220px popover, top-right anchor)

Five items:
1. Settings → `/settings`
2. Festivals & Calendar → `/festivals` (secondary entry)
3. Ask the Pandit → `/chat` (general AI chat)
4. Send feedback → `/feedback`
5. About this app → `/credits`

55% black scrim. 180ms animation.

### 3.4 Routes
```
/                          Today               [tab 1]
/practice                  Practice/Your Path  [tab 2]
/practice/module/:id       Module reader       [drill-down, no chrome]
/texts                     Library             [tab 3]
/texts/:scripture          Chapter List
/texts/:scripture/:ch      Verse List
/texts/:scripture/:ch/:v   Verse Detail
/search                    Search
/bookmarks                 Bookmarks (Pothī)
/festivals                 Festivals (Almanac)
/festivals/:id             Festival detail
/chat/:verse_id            AI Chat verse-anchored
/chat                      AI Chat general
/settings                  Settings
/settings/credits          Credits (alias /credits)
/settings/feedback         Send Feedback (alias /feedback)
/onboarding/welcome        Onboarding step 1
/onboarding/reminder       Onboarding step 2
```

### 3.5 Entry point matrix

| Destination | Reached from | Trigger |
|---|---|---|
| Home | Tab nav | Today tab |
| Practice | Tab nav | Practice tab |
| Practice module | Practice | Tap unlocked module |
| Module step N → step N+1 | Module step N | Tap anywhere on body |
| Module Complete | Module last step | Tap to advance |
| **Back to /practice** | **Module Complete** | **Tap "Back to Learning Path"** |
| External book URL | Module Complete | Tap recommendation row |
| Library | Tab nav | Texts tab |
| Chapter List | Library | Tap scripture row |
| Chapter List | Home Continue | Tap resume |
| Verse List | Chapter List | Tap chapter row |
| Verse Detail | Verse List | Tap verse |
| Verse Detail | Home Verse of Day | Tap read |
| Verse Detail | Search results | Tap result |
| Verse Detail | Bookmarks | Tap leaf |
| Verse Detail | AI Chat citation | Tap citation card |
| Verse Detail | Festival detail | Tap related verse |
| Verse Detail | Module Key Verse | Tap "Read BG·2·20 in the Gītā" |
| **Word callout** | **Verse Detail** | **Tap Sanskrit word** (modal overlay) |
| **Notes sheet** | **Verse Detail** | **Tap Notes icon** (modal sheet) |
| **Share sheet** | **Verse Detail** | **Tap Share icon** (modal sheet) |
| Search | Home topbar | Tap search icon |
| Search | Library topbar | Tap inline search field |
| Bookmarks | Home topbar | Tap bookmark icon |
| Bookmarks | Library topbar | Tap bookmark icon |
| AI Chat verse-anchored | Verse Detail | Tap "Explain this verse" |
| AI Chat verse-anchored | Search Pandit answer | Tap "Ask follow-up" |
| AI Chat general | Search empty | Tap "Ask the Pandit" |
| AI Chat general | Home overflow | Tap "Ask the Pandit" |
| Festivals | Home Upcoming Parva | Tap |
| Festivals | Home overflow | Tap "Festivals & Calendar" |
| Festival detail | Festivals | Tap row with festival |
| Settings | Home/Library/Practice overflow | Tap "Settings" |
| Credits | Settings → "Credits & attributions" | Tap |
| Credits | Home overflow → "About" | Tap |
| Send Feedback | Settings → "Send feedback" | Tap |
| Send Feedback | Home overflow → "Send feedback" | Tap |
| **Time picker sheet** | **Settings reminder row** | **Tap time** (modal sheet) |
| **Time picker sheet** | **Onboarding step 2** | **Tap time block** |
| **Reset dialog** | **Settings → Reset** | **Tap** (modal dialog) |
| **Toast** | **Any save/delete action** | **Implicit** |
| **Splash** | **App launch** | **System** |
| **Onboarding** | **First launch only** | **Implicit** |

### 3.6 Back-stack
- **Tab roots:** back exits app or returns to previous tab
- **Drill-downs:** back returns to previous screen
- **Module steps:** back exits module (with confirmation if mid-progress)
- **AI Chat citation → Verse Detail:** back returns to chat with state preserved
- **Modals (sheets, dialogs, overflow menu, word callout):** back dismisses modal only

### 3.7 Deep links
- `sanatanguide://verse/{scripture}/{ch}/{v}` → Verse Detail
- `sanatanguide://chapter/{scripture}/{ch}` → Verse List
- `sanatanguide://scripture/{scripture}` → Chapter List
- Web: `https://sanatanguide.app/{scripture}/{ch}/{v}` for non-app recipients

---

## 4. Per-screen build instructions

### Screen 1 — Home (Today)
Route: `/` · Mockup: `screen-01-home.html` · Build order: #3
Topbar (Search/Bookmark/⋯) + greeting (no name) + panchāṅga + Verse-of-the-Day + Continue Reading + Path strip + Upcoming Parva. **AdMob banner at bottom** (above bottom nav).
**Fix:** Mockup says "Shubh Prabhat, Saurabh" — strip name. Mockup doesn't show new topbar — use Screen 13 reference.

### Screen 2 — Verse Detail
Route: `/texts/:scripture/:ch/:v` · Mockup: `screen-02-verse-detail.html` · Build order: #8
Compact topbar + verse leaf (BindingLine top/bottom) + tap-a-word callout (see Screen 16) + transliteration + translation + "Explain this verse" CTA → `/chat/:verse_id`. Bottom utility bar: prev/next chevrons + bookmark + share + notes.
**Edge cases (from Screen 16):**
- First verse of chapter: prev disabled at 40%, tap shows toast "This is the first verse"
- Last verse of last chapter: next disabled, show "You've finished [Scripture]" banner with saffron diamond marker above bottom bar
- Bottom bar center label switches to "[Scripture] · End"
**Fix:** Remove Listen icon from v1.

### Screen 3 — Library
Route: `/texts` · Mockup: `screen-03-library.html` · Build order: #4
Inline search + Bookmark + ⋯ topbar. Hero stat. Vedas (2×2). Upaniṣads/Itihāsa/Sūtras/Tamil sections.
**Fix:** Smṛti glyph in mockup uses iron-red — change to dCream/dText2.

### Screen 4 — Chapter List
Route: `/texts/:scripture` · Mockup: `screen-04-chapter-list.html` · Build order: #5
Compact topbar + Resume row (LeafThread) + chapter rows with Devanāgarī numerals + reading time + hairline progress.

### Screen 5 — Verse List
Route: `/texts/:scripture/:ch` · Mockup: `screen-05-verse-list.html` · Build order: #6
Topbar with chapter context + Resume row + verse rows with DandaCoord (‖१‖) + Sanskrit incipit + English gist. Three states: read/unread/bookmarked. Sticky verse jumper on right edge for 30+ verses.

### Screen 6 — Search
Route: `/search` · Mockup: `screen-06-search.html` · Build order: #10
Empty state with Recent + Search-any-way sections. Coordinate detection ("BG 2.47" → direct match card). Results grouped by scripture. "Ask the Pandit" → `/chat` (general).

### Screen 7 — Bookmarks
Route: `/bookmarks` · Mockup: `screen-07-bookmarks.html` · Build order: #9
"पोथी · Your collection" header. Sort tabs (Recent/By scripture). Each saved verse as a leaf with knot-mark. Optional italic-serif note line beneath. Empty state with three leaves on saffron thread.

### Screen 8 — Festivals
Route: `/festivals` · Mockup: `screen-08-festivals.html` · Build order: #12
Panchāṅga banner (5 limbs) + Vikram Samvat year. Almanac column (NOT cards). Each row: Gregorian date + lunar phase circle + tithi/nakṣatra + festival in iron-red. Today row with LeafThread. Filter strip.

### Screen 9 — Settings
Route: `/settings` · Mockup: `screen-09-settings.html` · Build order: #14
Sections: Appearance / Reading / Notifications / Data / About / Reset (iron-red). Theme picker (3-segment Auto/Light/Dark — animates with AnimatedTheme, 320ms cross-fade). Font-size slider (7 ticks). Time picker for reminder uses sheet from Screen 16.

### Screen 10 — AI Chat (verse-anchored)
Route: `/chat/:verse_id` · Mockup: `screen-10-ai-chat.html` · Build order: #11
Verse anchor at top (LeafThread + daṇḍa + Sanskrit incipit + scripture). User bubbles right. AI in flowing Lora italic, no bubble. Inline citation cards with BindingLine motif. Three-dots thinking. "Ask about this verse..." placeholder.
**Error state (Screen 16):** "The connection couldn't reach the texts..." in italic serif + Retry button. **Offline dot** on send button when offline.

### Screen 11 — Onboarding
Routes: `/onboarding/welcome`, `/onboarding/reminder` · Mockup: `screen-11-onboarding.html` · Build order: #2
**Two screens only.** Welcome+level merged (ॐ logomark + invocation + 3 level cards with LeafThread on selected). Reminder screen with bell glyph + time picker (Screen 16) BEFORE system permission. Skip on every screen.

### Screen 12 — Practice / Your Path
Route: `/practice` · Mockup: `screen-12-practice.html` · Build order: #13
7-day week strip (NOT month). Curriculum primary. Continue anchor (LeafThread). Foundations connected modules with continuous thread + knots. Deepening locked. Mastery horizon card.
Use user's actual app copy where it exists ("108 Upanishads exist. Ten of them contain everything.").

### Screen 13 — Navigation / Credits / Feedback
Routes: topbar composed; `/credits`; `/feedback` · Mockup: `screen-13-navigation-credits-feedback.html` · Build order: #15
Home/Library topbar (Search/Bookmark/⋯). Overflow menu (5 items). Credits screen (sūtra-style enumeration + lineage footer). Feedback flow (pick kind → compose).

### Screen 14 — AI Chat general + Notes + Share
Routes: `/chat`; modals on Verse Detail · Mockup: `screen-14-missing-flows.html` · Build order: #8 (notes/share with Verse Detail) and #11 (AI Chat general alongside verse-anchored)
- AI Chat general mode (no verse anchor, compact "ASK THE PANDIT" header, 4 example chips on empty)
- Notes bottom sheet (200 char limit, italic serif, save/delete)
- Share bottom sheet (3-format chooser + preview + canonical format strings)

### Screen 15 — Module Reader + Module Complete (NEW)
Route: `/practice/module/:id` · Mockup: `screen-15-module-reader.html` · Build order: #13 (with Practice)

**Module Reader chrome:**
- Topbar: ✕ close + module name in saffron Lora italic + "X/Y" counter
- Progress bar: 3px full-bleed saffron, animates 280ms easeOut
- Body: vertically centered in available space, tap-anywhere-to-continue
- Tap hint: "tap anywhere to continue" lowercase tracked sans 11px dText3
- Step transition: 280ms slide-in from right + fade
- Step content entry: ink-settle animation with 80-340-480ms stagger

**Five step types:**

1. **INTRO** — Small-caps "INTRODUCTION" label (saffron) + 28px serif title (cream) + 16px serif body (dText2). Used for framing.

2. **CONCEPT** — Small-caps "CONCEPT N OF M · Term" label + 28px title + 16px body. Used for definitional content. Body may use `<em class="term">` for inline term emphasis (renders as non-italic saffron bold).

3. **KEY VERSE** — "KEY VERSE" pill in iron-red bright (8% tint, 1px border, 11px small-caps) — THE ONE place outside Festivals/destructive where iron-red appears. 22px serif quoted text. Saffron-outlined pill button "Read BG·2·20 in the Gītā" → routes to `/texts/BG/2/20` (back returns to module).

4. **REFLECT** — Diya/lamp glyph (saffron-deep, 36px) — replaces generic meditation icon. Small-caps "Reflect" label (saffron, 0.16em tracking). 22px serif question. Italic serif "Sit with this question. Tap to continue when ready." footer.

5. **COMPLETE** — See Module Complete below.

**Data shape:**
```dart
enum ModuleStepType { intro, concept, keyVerse, reflect, complete }

class ModuleStep {
  final String id;
  final int stepIndex;      // 1-indexed
  final int totalSteps;
  final ModuleStepType type;
  final String? label;       // small-caps section label
  final String? title;       // hero title (intro/concept)
  final String body;          // main body text
  final String? verseRef;     // "BG/2/20" — keyVerse only
  final String? verseLabel;   // display text for CTA — keyVerse only
}
```

**Module Complete screen:**
- Saffron checkmark inside palm-leaf binding-line frame (140px wide leaf with BindingLine top + bottom, checkmark glyph 40px saffron with 12px blur glow). **Replaces the green check from your live app** — green violates palette.
- "Module Complete" Lora 32px w500 cream, centered
- Module name Lora italic 18px dText2, centered
- Hairline divider
- "RECOMMENDED FOR THIS MODULE" small-caps saffron label
- Book recommendation rows: 48px square book icon (1px dDivider border, saffron book glyph) + title (Lora 15px w500) + author (Lora italic 13px) + external-link arrow. Tap opens external URL via url_launcher.
- Primary "Back to Learning Path" pill button → pops to `/practice`
- Entry animation: leaf (100ms) → title (280ms) → module name (420ms) → divider (580ms) → recommend label (660ms) → book rows (720, 780ms) → button (920ms). Sequenced, feels earned.

```dart
class BookRecommendation {
  final String title;
  final String author;
  final String url;
  final String? coverAssetPath;  // optional
}
```

**Don'ts:**
- ❌ No "Continue" button — tap-anywhere preserves the meditative flow
- ❌ No top-aligned step content — vertical center for visual calm
- ❌ No green checkmark on Complete — saffron only
- ❌ No confetti or celebration — restraint is the brand
- ❌ Iron-red only on KEY VERSE step (not on any other step type)
- ❌ Don't use Material Icons meditation glyph — use the diya/lamp

### Screen 16 — System chrome (NEW)
No single route — used app-wide · Mockup: `screen-16-system-chrome.html` · Build order: #1 (alongside core widgets)

**Toast / Snackbar:**
- Position: bottom center, 60px from safe-area bottom
- Pill (22px radius), dSurface2, 1px dDivider, max 320px wide
- Content: small saffron diamond (5×5 rotated) + Lora 13.5px message + optional "UNDO" action separated by 1px vertical divider
- Motion: slide-up 240ms easeOut + fade, auto-dismiss 3.5s, slide-down 240ms easeIn
- New toast cancels old one (no queue)
- Use for: "Verse saved", "Note saved", "Bookmark removed", "Reminder set"

**Confirmation dialog (destructive):**
- 55% black scrim, dismissible
- 312px wide, centered, dSurface2, 1px dDivider, 12px radius
- BindingLine motif at top (sideGap 10px)
- Title Lora 19px w500 cream, centered, 18px top padding
- Body Lora italic 14px line-height 1.55 dText2, centered
- Action row: 1px top divider, two equal-width buttons divided by 1px vertical center divider. Left = Cancel (dText2 sans 13px w500). Right = destructive (dIronRedBright sans 13px w600). Both 52px tall.
- Motion: fade + 0.96→1.0 scale, 200ms
- Use for: "Reset all data?", "Delete bookmark?", "Clear AI chat history?"

**Info dialog:** Same but single full-width "OK" saffron button. Use for "Export complete", "Reminder set".

**Time picker sheet:**
- Bottom sheet, 16px top corners, dSurface2
- Drag handle (36×4 dText3), header "Reminder time" Lora 17px + close ✕
- Two scroll wheels (80px wide × 168px tall) with `:` separator. Hour 1–12, minute in 5-min steps. Selected row 32px w500 saffron, others 26px dText3.
- Saffron underline + dDividerSoft bottom border on selected row
- AM/PM segmented control below wheels (saffronGlow background + saffron text on active)
- Actions: Cancel (secondary) + Save (saffron primary) right-aligned
- Used in: Settings reminder + Onboarding step 2

**Splash / launch screen:**
- Background dBg (dark always — system doesn't know theme at splash time)
- Centered ॐ in Tiro Devanagari 96px saffron with 24px blur glow
- Wordmark "सनातन" in Tiro Devanagari 26px dSaffronDeep, 12px below
- Loader: three saffron dots (AIThinkingDots pattern) at bottom, 80px from bottom
- Use `flutter_native_splash` package
- Adaptive launcher icon: same ॐ on saffron-deep with safe-zone padding

**Word callout (Verse Detail):**
- Trigger: tap Sanskrit word — word gets subtle saffron underline (4-color: 40% saffron, 6px offset)
- Container: 240px wide, dSurface2, 1px dDivider, 4px radius. Small 10×10 rotated arrow on top edge pointing at word.
- Content: Tiro Sanskrit 22px word (saffron) + Lora italic 13px IAST + Lora 14px meaning (1–2 lines) + small-caps sans 9.5px grammar tag (e.g., "NOUN · NEUTER · LOC.SG")
- Position: anchored above word with 4px gap; flip below if no room. Arrow rotates.
- Dismissal: tap outside or same word
- Motion: 180ms fade + 0.96→1.0 scale
- Words without dictionary entries don't underline on tap (no-op)

**Verse Detail edge cases:**
- First verse: prev chevron 40% opacity, tap shows toast
- Last verse of scripture: next chevron 40% opacity. Above bottom bar: "You've finished [Scripture]" in italic serif dText2 + 10×10 saffron diamond mark below. Center label = "[Scripture] · End"

**Home AdMob banner:**
- Bottom of Home only (above bottom nav), 50px tall
- 1px top border dDividerSoft
- Small "AD" small-caps 8.5px dText3 top-right of slot
- NOT on any other screen — reading flow is ad-free
- Failure: collapse banner area
- Use AdMob test IDs in dev; real IDs from Saurabh

**Error states:**
- AI Chat error: inline italic serif 14px dText2 "The connection couldn't reach the texts. The verses are still here, but the Pandit needs internet to think." + sans 12px tracked uppercase "RETRY" button with circular arrow icon
- Search Pandit error: same pattern in answer card
- Export failure: info dialog "Export failed" + "Couldn't write the file."
- Offline indicator: 10×10 iron-red-bright dot top-right of chat send button (2px dBg border), tap → tooltip "AI Chat needs internet"

**Pull-to-refresh:**
- On Library, Chapter List, Verse List, Bookmarks
- Three saffron dots (AIThinkingDots) centered, 60px above list
- "release to refresh" lowercase tracked sans 11px dText3 when crossing threshold
- Dots pulse during refresh; collapse on completion

**Theme transition:**
- Wrap MaterialApp in AnimatedTheme, 320ms duration
- Use TweenAnimationBuilder for custom colors not in ThemeData
- Wrap BindingLine and LeafThread in AnimatedContainer for smooth color transition

**Don'ts:**
- ❌ Material default snackbar/toast
- ❌ Material default time picker (too circular, too generic)
- ❌ Material default alert dialog (no BindingLine, feels disconnected)
- ❌ Ads on any reading surface
- ❌ Spinner on reading surfaces (use skeleton with verse leaf shape)
- ❌ Confetti or celebration anywhere — restraint is brand

---

## 5. Known fixes (across all mockups)

### Critical
1. Home greeting: strip name, use time-of-day only
2. Library Smṛti glyph: iron-red → cream
3. AIThinkingDots phase math: use corrected logic in `heritage_widgets.dart`
4. Iron-red text on dark: force `dIronRedBright` (#D17048)

### High
5. Home topbar: add Search/Bookmark/⋯ icons per Screen 13
6. Bookmarks naming: route `/bookmarks`, display "पोथी · Your collection", elsewhere "Bookmarks"
7. Festivals secondary entry: in overflow menu (item 2)
8. AI Chat general mode: build `/chat` route per Screen 14
9. Font fallback chain: global in `app_theme.dart`

### Medium
10. Notes feature: build per Screen 14 (Drift table + action + sheet)
11. Share feature: build per Screen 14 (sheet + format strings)
12. Listen icon: remove from Verse Detail v1
13. Sanskrit font-size provider: Riverpod, persisted
14. Bottom nav appearance: only on Today/Practice/Texts roots
15. **Module reader: build per Screen 15** (no live design existed before)
16. **Module Complete redesign: replace green check with saffron leaf-frame** (per Screen 15)
17. **All system chrome from Screen 16:** toast, dialog, time picker, splash, word callout, edge states, ad banner, error states, pull-to-refresh, theme transition

---

## 6. V2 backlog (DO NOT BUILD)

| Feature | Why not v1 |
|---|---|
| Hindi translation | No corpus |
| Audio recitation | No files, no infra. Remove Listen icon from v1 |
| Bookmark cross-device sync | No backend |
| Bookmark collections/tags | Filter is Recent/By scripture only |
| Search semantic embeddings | Text-match + coord only |
| Share-as-image card | Text + deep link only in v1 |
| Multi-language UI | English UI strings only |
| Streak rescue/freeze | Streak breaks on missed day |
| Verse-of-day in notification body | Plain reminder only |
| Persisted AI chat history | Per-session only |
| Pro/paid tier | Free + AdMob only |
| Tablet layout | Phone only |
| User accounts/social | Never (this isn't a social app) |
| Voice input/output for AI | v2 |
| Side-by-side translation comparison | Single translation v1 |
| Module quizzes | Read-only modules v1 |

---

## 7. Implementation order

| # | Build | Why |
|---|---|---|
| 1 | design_tokens, design_typography, heritage_widgets, **system chrome from Screen 16** (toast, dialog, time picker widgets) | Foundation |
| 2 | Onboarding | Entry point, uses time picker |
| 3 | Home (with new topbar + AdMob banner) | Landing |
| 4 | Library | Branches into reading flow |
| 5 | Chapter List | Reading flow |
| 6 | Verse List | Reading flow |
| 7 | Verse Detail + Notes sheet + Share sheet + Word callout + edge cases | Core reading + verse-scoped actions + system chrome integration |
| 8 | Bookmarks | Depends on read flow |
| 9 | Search | Depends on corpus + verse routing |
| 10 | AI Chat (verse-anchored + general) + error states + offline indicator | Both modes together |
| 11 | Festivals + Festival detail | Depends on bundled data |
| 12 | **Practice + Module Reader + Module Complete** | Curriculum |
| 13 | Settings (with theme transition + time picker sheet) | Late; depends on all toggles |
| 14 | Credits + Send Feedback | Last |
| 15 | Splash screen configuration + launch icon | Final polish |

---

## 8. Operating procedure

**Session-opening prompt:**

```
Read .claude/sanatan_briefing/SANATAN_GUIDE_BUILD_BRIEF.md fully before
doing anything else. This is the canonical brief for Sanatan Guide.
If anything in another file contradicts this brief, the brief wins.

Confirm understanding and tell me which screen to start with.
```

**Per-screen prompt template:**

```
TASK: Build the [SCREEN NAME] screen for Sanatan Guide.

REFERENCES:
- Mockup: mockups/screen-[XX]-[name].html
- Tokens: lib/core/theme/design_tokens.dart
- Styles: lib/core/theme/design_typography.dart  
- Widgets: lib/core/widgets/heritage_widgets.dart
- System chrome widgets: lib/core/widgets/system_chrome.dart (from Screen 16)
- Per-screen spec (if exists): .claude/sanatan_briefing/screens/[XX]_*.md

RULES:
- Riverpod for state, GoRouter for navigation
- ONLY tokens from design_tokens.dart — no hardcoded colors/fonts
- ONLY styles from design_typography.dart — no inline TextStyles  
- Use heritage widgets — don't reimplement BindingLine, LeafThread, etc.
- Both themes must work from day one
- Match mockup visually — structure, hierarchy, motion

CROSS-REFS (from brief §3.5):
- This screen is reached from: [look up in entry matrix]
- This screen routes to: [list per-screen instructions §4]

PROCESS:
1. Read spec + mockup. Confirm understanding.
2. List files you'll create.
3. Show provider/state shape before UI.
4. Build the screen.
5. Run `flutter analyze`, fix issues.
6. Show result.

Don't proceed past step 2 without my approval.
```

**For corrections:** Quote the relevant section back. "Section 3.2 says drill-down screens have back-button only — remove the Search icon from Verse Detail."

---

## 9. Final note

The point: **Claude Code never has to ask "where does this route from?" or "what does this look like?" or "is this v1?"** Every answer is in this brief, the per-screen specs, the mockups, or the design tokens.

When Claude Code asks something already in the brief, point it back at the section. Don't re-explain.

When Claude Code suggests deviating, push back. The brief is the brief. We iterate after v1 ships.

— End of brief v1.1 —
