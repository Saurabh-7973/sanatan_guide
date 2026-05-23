# Sanatan Guide — Master Design Context

**Read this first.** This document is the single source of truth for how the app looks, feels, and is built. Every screen spec assumes you have read this. Do not deviate from these rules without explicit instruction.

---

## 1. What this app is

Sanatan Guide is a fully offline Hindu scripture reader for Android (Flutter). It contains 1,33,613 verses across 31 scriptures with translations and commentary. The user reads, bookmarks, follows guided learning paths, and asks AI about specific verses (using the offline corpus as ground truth).

**Stack:**
- Flutter, Riverpod 3, Drift/SQLite, GoRouter, Firebase, AdMob, Gemini 2.5 Flash
- Fonts: Tiro Devanagari Sanskrit, Noto Sans Devanagari, Lora, Outfit
- Package: `com.Saurabh7973.sanatan_guide`
- DB version: 5+, ~72 MB

**Non-negotiable principles:**
- Fully offline. No external calls except AI chat (Gemini).
- Sanskrit is treated with care. Every verse uses Tiro Devanagari Sanskrit. Devanāgarī is never collapsed to romanization without preserving the original.
- The voice is direct, scholarly, contrarian where useful — never generic spiritual app copy.
- Heritage signals are restrained and meaningful, not decorative.

---

## 2. Aesthetic direction

**Pre-Islamic Indian heritage.** Pallava/Chola/Hoysala temples, palm-leaf manuscripts (taal patra), Vedic yantra geometry. Color palette: saffron / turmeric / iron-red / warm white / deep brown — no cool tones.

**Explicitly REJECTED:**
- Mughal motifs (onion domes, jaali screens, Persian arches)
- Generic spiritual tropes (lotus watermarks, gradient sunsets)
- Stock Hindu app design (deity images on cards, marigold borders)
- Modern card UI on the Festivals screen (use almanac column instead)
- Any decoration that adds nothing functional

---

## 3. Design tokens

**Use these exact values. Do not invent new colors, fonts, or spacing. Use design_tokens.dart for the canonical values.**

### Colors — Dark theme (default)
- `dBg` #0F0F0F · `dSurface` #1C1816 · `dSurface2` #251F1B
- `dSaffron` #E8820C · `dSaffronDeep` #B86908 · `dSaffronGlow` 12% saffron
- `dCream` #F2E5CE · text hierarchy at 100/62/38% cream
- `dDivider` 18% saffron · `dDividerSoft` 8% cream
- `dIronRed` #B85A3A (borders) · `dIronRedBright` #D17048 (text)

### Colors — Light theme
- `lBg` #FDFAF6 · `lSurface` #F7F2EC · `lSurface2` #EFE7D7
- `lSaffron` #C26508 · `lSaffronDeep` #8B4806 · `lSaffronGlow` 8%
- `lText1` #2A1E14 at 100/65/40%
- `lIronRed` #8B2818 · `lIronRedBright` #A53520

### Typography
```
fSans   = Outfit                       UI, buttons, labels, metadata
fSerif  = Lora                          Reading prose, commentary, AI replies, titles
fDeva   = Tiro Devanagari Sanskrit      Sanskrit verses (always)
fDevaUI = Noto Sans Devanagari          UI Devanāgarī (numbers, tags, short labels)
```

**Sanskrit font-size scale:** 14 / 16 / 18 / 20 / 22 / 24 / 28 px — default 18.

### Spacing
4pt grid. Use multiples: 4, 8, 12, 14, 16, 18, 20, 22, 24, 28, 32 px.

### Radius
- Cards / leaves: 4 px
- Pills / chips: 11–18 px (snug to text)
- Bottom sheet: 12 px top corners
- Phone preview: 44 px (Android frame)

---

## 4. Shared visual vocabulary (used across all screens)

These six elements must be implemented identically every time they appear. They are the system.

### 4.1 Palm-leaf binding-line + diamond hole
A horizontal saffron-faded rule with a 5×5 px rotated diamond at center. Used at the top edge of "leaf" elements — verse cards, bookmark leaves, citation cards in AI Chat, the lineage footer on Credits.

### 4.2 Saffron leaf-thread (3 px strip)
A 3 px saffron rectangle on the **left edge** of a card or row, top-bottom inset by 8–12 px. Means **"your place / your active / your selection."**

Appears on: Resume rows (Chapter List, Verse List), Verse anchor on AI Chat, Selected level card in Onboarding, Continue anchor on Practice, Today row on Festivals, Knot mark on Bookmarks.

Always 3 px wide. Always saffron with a subtle box-shadow glow on dark theme.

### 4.3 Daṇḍa-marked verse coordinates
Verse references use the Sanskrit double-vertical-bar convention: `‖१·१‖` (Devanāgarī) or `‖1.1‖` (Arabic fallback). **Always render in saffron** when used as an anchor or coordinate.

### 4.4 Devanāgarī numerals
Chapter numbers, verse counts, dates, time, version markers — render in Devanāgarī where the audience would expect it. Used in: Chapter List chapter numbers, Practice module knots, Credits source enumeration, almanac dates.

### 4.5 Iron-red ink
**Reserved for two purposes only:**
1. Festival names on the Festivals/Almanac screen
2. Destructive actions and labels (Clear history, Reset, dialog confirm buttons)

This is a clean semantic split. **Do not use iron-red anywhere else.**

### 4.6 Three-saffron-dots AI thinking indicator
When the AI is thinking, three small saffron dots pulse with 0.2s phase offset. Use across all AI-thinking states: Verse Detail "Explain", Search Pandit, AI Chat.

Specs: 5×5 px circles, 4 px gap, 1.4 s pulse cycle, opacity 0.3 ↔ 1.0.

---

## 5. Type usage (which font where)

**Lora serif (regular):** screen titles, prose body, module descriptions, festival prose, verse English translation.

**Lora serif (italic):** AI replies, commentary, taglines, tooltips, empty-state copy, "subtle" body. Italic is the system's voice for "literary register."

**Outfit sans:** all UI chrome — buttons, labels, navigation, metadata, section labels (small caps).

**Tiro Devanagari Sanskrit:** Sanskrit verses. Always with breathing room — line-height ≥ 1.5, font-size ≥ 14 px.

**Noto Sans Devanagari:** Devanāgarī inside UI chrome.

---

## 6. Behavioral rules

### 6.1 Read-tracking semantics
A verse is "read" when the user spends ≥ 3 seconds on the verse-detail screen. Track in `verses_read(verse_id, first_read_at)`. Streak increments on first verse-read of the day.

### 6.2 First-launch state
Day 0 (no history):
- No "Continue · X day streak" strip on Home — replace with "Begin Foundations" path strip
- Streak counter = 0
- Bookmarks = empty state
- Module 1 of Foundations is "active"

### 6.3 Festivals data
Bundle a 5-year panchāṅga JSON (~200 KB compressed) covering 2026–2030. Static asset, not computed. Read by both Festivals screen and Home "Upcoming Parva" card.

### 6.4 AI Chat as single surface
- Verse Detail "Explain this verse" → routes into AI Chat with the verse anchored
- Search "Ask the Pandit" → single curated answer, but tapping "Ask follow-up" routes into AI Chat
- AI Chat is the *only* place follow-up conversations happen
- Citation cards in AI replies navigate to Verse Detail (chat preserved on back stack)

### 6.5 Read-pace estimates
Default: 15 sec/verse (translation only) or 25 sec/verse (with commentary). After 20+ verses read, derive personal pace.

### 6.6 Bookmark counts
Show bookmark count **only on the Bookmarks screen header**. Do not show on Library, Chapter List, or Verse List.

### 6.7 Number formatting
Indian format for verse counts: `1,33,613`. Standard Western for times and small numbers.

### 6.8 Translation languages
v1 ships with **English only.** Settings shows "English" without a chevron (no picker) until Hindi ships.

### 6.9 Greeting on Home
**No name field is collected.** Greeting is `Shubh Prabhat` (or by time-of-day) without a name.

---

## 7. Navigation architecture

### Bottom navigation (3 tabs)
`[ Today ]  [ Practice ]  [ Texts ]` — three tabs only. Do NOT add Search / Bookmarks / Settings as tabs.

### Home & Library topbar trailing icons
Home: `[search] [bookmark] [⋯]` — three icons on the right.
Library: inline search field + `[bookmark] [⋯]` (the inline field is the search affordance).

- **Search icon** → `/search` with field auto-focused
- **Bookmarks icon** → `/bookmarks`. Small saffron dot indicator if there are new bookmarks (v2 affordance; in v1 the indicator never shows)
- **Overflow (⋯)** → popover menu (220 px, anchored top-right) with: Settings · Send feedback · About this app. 55%-black backdrop scrim. Tap scrim to dismiss.

### Drill-down screens
Chapter List, Verse List, Verse Detail, AI Chat, Festivals, Practice modules — **back button only.** Do not surface Search/Bookmarks/Settings here.

Verse Detail has its own verse-scoped action bar (bookmark-toggle, share, "Explain this verse").

### Routes
```
/                       Today (Home)
/practice              Practice / Your Path
/practice/module/:id   Module reader
/texts                 Library
/texts/:scripture      Chapter List
/texts/:scripture/:ch  Verse List
/texts/:scripture/:ch/:v  Verse Detail
/search                Search
/bookmarks             Bookmarks (Pothī)
/festivals             Festivals (Almanac)
/festivals/:id         Festival detail
/chat/:verse_id        AI Chat (verse-anchored)
/settings              Settings
/settings/credits      Credits & Attributions (alias: /credits)
/settings/feedback     Send Feedback (alias: /feedback)
/onboarding/welcome    Welcome + level
/onboarding/reminder   Reminder permission
```

---

## 8. Animation & motion

**Default easing:** `Curves.easeOut` for entrances, `Curves.easeInOut` for transitions.

**Standard durations:**
- Tap feedback: 120 ms
- Card/row entry: 350–450 ms with 60 ms stagger
- Sheet/dialog entry: 200 ms
- Page transition: 280 ms
- AI streaming token: word-by-word fade-in, ~30 ms per word
- Overflow menu open: 180 ms scale+fade from top-right origin

---

## 9. Accessibility

- **Hit targets:** minimum 44×44 px
- **Contrast:** all text passes WCAG AA on its background
- **Sanskrit screen-reader:** use `lang: 'sa'` for Sanskrit text, `'hi'` for Hindi, `'en'` for English
- **Font size slider** (Settings) controls Sanskrit body 14–28 px
- **Iron-red on dark** must be `dIronRedBright` for text contrast; `dIronRed` for borders/icons only

---

## 10. File / code structure

```
lib/
  core/
    theme/
      design_tokens.dart       (colors, spacing, durations)
      design_typography.dart   (text styles)
      app_theme.dart           (ThemeData composition)
    widgets/
      heritage_widgets.dart    (BindingLine, LeafThread, DandaCoord, AIThinkingDots, SanskritText)
  features/
    home/
    verse_detail/
    library/
    chapter_list/
    verse_list/
    search/
    bookmarks/
    festivals/
    settings/
      credits_page.dart
      feedback_page.dart
    ai_chat/
    practice/
    onboarding/
```

Build the **core/widgets** primitives first. Every screen uses them.

---

## 11. Open decisions resolved (do not relitigate)

| Decision | Resolution |
|---|---|
| Greeting personalization | No name field. "Shubh Prabhat" alone. |
| Read tracking | View-based, 3 sec threshold |
| Hindi translation | Not in v1. English only. |
| Panchāṅga source | Bundled 5-year JSON |
| Festivals nav | Reached from Home "Upcoming Parva", not a 4th tab |
| AI Chat scope | Single chat surface; Verse Detail/Search route into it |
| Bookmark counts | Only on Bookmarks screen, not Library/Chapter/Verse |
| Iron-red usage | Festivals + destructive actions ONLY |
| Streak first day | No streak strip, show Foundations path strip |
| Identity in onboarding | No "Curious Hindu". Levels are Beginner/Regular/Scholar |
| Search/Bookmarks/Settings entry | Home topbar icons + overflow (⋯) menu |
| Credits screen | Sūtra-style enumeration with Devanāgarī numerals |
| Feedback | Two-step: pick kind → compose. v1 composes email |
| Privacy/Terms | Open external URLs (no internal screen) |

---

## 12. Order of implementation

1. **Core widgets** (heritage_widgets.dart) — verify with dev preview before any screen
2. **Onboarding** — entry point
3. **Today / Home** — landing surface (includes topbar with Search/Bookmark/⋯)
4. **Library → Chapter List → Verse List → Verse Detail** — core reading flow
5. **Bookmarks** — depends on read flow
6. **Search** — depends on corpus + verse routing
7. **AI Chat** — depends on verse routing
8. **Festivals** — depends on bundled data
9. **Practice / Your Path** — depends on read tracking
10. **Settings** — late; depends on toggles
11. **Credits & Feedback** — last; small screens behind Settings

---

End of master context. See `MASTER_CONTEXT_ADDENDUM.md` for navigation architecture and sub-screens (Credits, Send Feedback). Screen specs in `screens/` reference everything here without restating it.
