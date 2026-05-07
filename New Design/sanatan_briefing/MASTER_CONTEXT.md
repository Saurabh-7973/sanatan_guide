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

**Use these exact values. Do not invent new colors, fonts, or spacing.**

### Colors — Dark theme (default)
```dart
const dBg = Color(0xFF0F0F0F);
const dSurface = Color(0xFF1C1816);
const dSurface2 = Color(0xFF251F1B);
const dSaffron = Color(0xFFE8820C);
const dSaffronDeep = Color(0xFFB86908);
const dSaffronGlow = Color(0x1FE8820C); // 12% saffron
const dCream = Color(0xFFF2E5CE);
const dText1 = Color(0xFFF2E5CE);
const dText2 = Color(0x9EF2E5CE); // 62%
const dText3 = Color(0x61F2E5CE); // 38%
const dDivider = Color(0x2EE8820C); // 18% saffron
const dDividerSoft = Color(0x14F2E5CE); // 8% cream
const dIronRed = Color(0xFFB85A3A);
const dIronRedBright = Color(0xFFD17048);
```

### Colors — Light theme
```dart
const lBg = Color(0xFFFDFAF6);
const lSurface = Color(0xFFF7F2EC);
const lSurface2 = Color(0xFFEFE7D7);
const lSaffron = Color(0xFFC26508);
const lSaffronDeep = Color(0xFF8B4806);
const lSaffronGlow = Color(0x14C26508); // 8%
const lCream = Color(0xFF2A1E14);
const lText1 = Color(0xFF2A1E14);
const lText2 = Color(0xA62A1E14); // 65%
const lText3 = Color(0x662A1E14); // 40%
const lDivider = Color(0x40C26508); // 25% saffron
const lDividerSoft = Color(0x1A2A1E14); // 10%
const lIronRed = Color(0xFF8B2818);
const lIronRedBright = Color(0xFFA53520);
```

### Typography
```dart
// Family roles — DO NOT swap.
const fSans = 'Outfit';                  // UI, buttons, labels, metadata
const fSerif = 'Lora';                   // Reading prose, commentary, AI replies, titles
const fDeva = 'Tiro Devanagari Sanskrit'; // Sanskrit verses (always)
const fDevaUI = 'Noto Sans Devanagari';   // UI Devanāgarī (numbers, tags, short labels)
```

**Font sizes (Sanskrit reading scale, set in Settings slider):**
14 / 16 / 18 / 20 / 22 / 24 / 28 px — default 18.

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
A horizontal saffron-faded rule with a 5×5 px rotated diamond at center. Used at the top edge of "leaf" elements — verse cards, bookmark leaves, citation cards in AI Chat.

```
   ─────────────────────  ◇  ─────────────────────
```

Implementation: a hairline gradient (transparent → saffron-deep → transparent) with a small square rotated 45° centered.

### 4.2 Saffron leaf-thread (3 px strip)
A 3 px saffron rectangle on the **left edge** of a card or row, top-bottom inset by 8–12 px. Means **"your place / your active / your selection."**

Appears on:
- Resume row on Chapter List
- Resume anchor on Verse List
- Verse anchor on AI Chat
- Selected level card in Onboarding
- Continue anchor on Practice/Your Path
- Today row on Festivals (almanac)
- Knot mark on Bookmarks (different shape but same color)

Always 3 px wide. Always saffron with a subtle box-shadow glow on dark theme.

### 4.3 Daṇḍa-marked verse coordinates
Verse references use the Sanskrit double-vertical-bar convention: `‖१·१‖` (Devanāgarī) or `‖1.1‖` (Arabic fallback for unsupported environments).

**Always render in saffron** when used as an anchor or coordinate. Used in: Verse List rows, Search results, Bookmarks, AI Chat citations, Verse Detail header.

### 4.4 Devanāgarī numerals
Chapter numbers, verse counts, dates, time, version markers — render in Devanāgarī numerals where the audience would expect it (Sanskrit context). With Arabic numerals adjacent only when essential for parseability.

```
१ २ ३ ४ ५ ६ ७ ८ ९ ० (= 1 2 3 4 5 6 7 8 9 0)
```

### 4.5 Iron-red ink (`dIronRed` / `lIronRed`)
**Reserved for two purposes only:**
1. Festival names on the Festivals/Almanac screen
2. Destructive actions and labels (Clear history, Reset, dialog confirm buttons)

This is a clean semantic split. **Do not use iron-red anywhere else.**

### 4.6 Three-saffron-dots AI thinking indicator
When the AI is thinking, three small saffron dots pulse with 0.2s phase offset. **Use this single vocabulary across all AI-thinking states:** Verse Detail "Explain", Search Pandit, AI Chat.

Specs: 5×5 px circles, 4 px gap, 1.4 s pulse cycle, opacity 0.3 ↔ 1.0.

---

## 5. Type usage (which font where)

**Lora serif (regular):** screen titles, prose body, module descriptions, festival prose, verse English translation.

**Lora serif (italic):** AI replies, commentary, taglines, tooltips, empty-state copy, "subtle" body. Italic is the system's voice for "literary register."

**Outfit sans:** all UI chrome — buttons, labels, navigation, metadata, section labels (small caps). All-caps section labels use 0.16–0.32 em letter-spacing.

**Tiro Devanagari Sanskrit:** Sanskrit verses. Always with breathing room — line-height ≥ 1.5, font-size ≥ 14 px.

**Noto Sans Devanagari:** Devanāgarī inside UI chrome (e.g., section header `भगवद्गीता`, app name in footer).

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
- Citation cards in AI replies are tappable and navigate to Verse Detail (chat preserved on back stack)

### 6.5 Read-pace estimates
Default: 15 sec/verse (translation only) or 25 sec/verse (with commentary). After user has read 20+ verses, derive personal pace from `verses_read` and use that for chapter time estimates.

### 6.6 Bookmark counts
Show bookmark count **only on the Bookmarks screen header**. Do not show counts on Library, Chapter List, or Verse List. Bookmarked verses show the saffron knot-mark on Verse List rows (binary indicator only).

### 6.7 Number formatting
Indian format throughout for verse counts: `1,33,613` (not `133,613`). For times and small numbers, standard Western format is fine.

### 6.8 Translation languages
v1 ships with **English only**. Hindi font is loaded but Hindi corpus is not in v1. The Settings "Translation language" row should display "English" without a chevron (no picker) until Hindi is shipped.

### 6.9 Bottom navigation
Three tabs: **Today · Practice · Texts**. Festivals is reached from Today's "Upcoming Parva" card. Settings, Bookmarks, Search are reached from header icons on Today.

### 6.10 Greeting on Home
**No name field is collected in onboarding.** Greeting is `Shubh Prabhat` (or `Shubh Sandhya` etc. by time-of-day) without a name. Do not personalize with a name.

---

## 7. Animation & motion

**Default easing:** `Curves.easeOut` for entrances, `Curves.easeInOut` for transitions.

**Standard durations:**
- Tap feedback: 120 ms
- Card/row entry: 350–450 ms with 60 ms stagger
- Sheet/dialog entry: 200 ms
- Page transition: 280 ms
- AI streaming token: word-by-word fade-in, ~30 ms per word

**Scrolling animations** are subtle — never distracting from reading.

---

## 8. Accessibility

- **Hit targets:** minimum 44×44 px
- **Contrast:** all text passes WCAG AA on its background (auto for dark, manual check for light cream-on-warm-white)
- **Devanāgarī screen-reader handling:** use proper Sanskrit lang tag (`lang: 'sa'`) for Sanskrit text, `lang: 'hi'` for Hindi. Translations use `lang: 'en'`.
- **Font size slider** (Settings) controls Sanskrit body text from 14 to 28 px. Translations scale proportionally.
- **Iron-red on dark** must always be `dIronRedBright` (#D17048), not `dIronRed` (#B85A3A), for contrast — `dIronRed` is only for borders / icons / non-text.

---

## 9. File / code structure (Flutter)

Suggested layout — adjust to your existing patterns:

```
lib/
  core/
    theme/
      design_tokens.dart       (colors above)
      design_typography.dart   (text styles)
      app_theme.dart           (ThemeData composition)
    widgets/
      binding_line.dart        (palm-leaf binding marker)
      leaf_thread.dart         (saffron 3px left strip)
      danda_coord.dart         (‖१·१‖ widget)
      ai_thinking_dots.dart    (three saffron pulsing dots)
      sanskrit_text.dart       (Tiro Devanagari wrapper)
      heritage_divider.dart    (hairline rule with optional diamond)
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
    ai_chat/
    practice/
    onboarding/
```

Build the **core/widgets** primitives first. Every screen uses them. Once they exist, screens compose quickly.

---

## 10. What "done" means for each screen

A screen is done when:
1. It implements all states defined in its spec (default, loading, empty, error if applicable)
2. It uses only the design tokens above — no hardcoded colors or fonts
3. It uses the shared widgets from `core/widgets/` — no reimplementation of binding lines or leaf threads
4. Both dark and light themes work
5. It matches the HTML mockup visually (allowing for natural Flutter rendering differences)
6. Devanāgarī, Sanskrit verses, and dāṇḍa coordinates are rendered correctly
7. Animations are present where the spec calls for them (especially the saffron leaf-thread pulse on entry, AI thinking dots, and module knot transitions)

---

## 11. Open decisions resolved (do not relitigate)

These were debated and decided. Build to them:

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
| Streak first day | No streak strip, show Foundations path strip instead |
| Identity in onboarding | No "Curious Hindu" framing. Levels are Beginner/Regular/Scholar |

---

## 12. Order of implementation

Build in this order. Each step depends on the previous.

1. **Core widgets first.** `binding_line`, `leaf_thread`, `danda_coord`, `ai_thinking_dots`, `sanskrit_text`. Without these, every screen will diverge.
2. **Onboarding** — gives you a working app from launch
3. **Today / Home** — the landing surface
4. **Library / Texts → Chapter List → Verse List → Verse Detail** — the core reading flow
5. **Bookmarks** — depends on read flow
6. **Search** — depends on a corpus and verse routing
7. **AI Chat** — depends on verse routing
8. **Festivals** — depends on bundled data
9. **Practice / Your Path** — depends on read tracking
10. **Settings** — last; depends on everything else for toggles

---

End of master context. The screen specs in `screens/` reference everything here without restating it.
