# Screen Spec — Verse List

> **Build order:** #6 (after Chapter List 04)
> **Mockup file:** `New Design/screen-05-verse-list.html`
> **Routes:** `/scripture/:scriptureId/:chapterNum` (push from Chapter List, or directly from single-chapter scriptures); back to Chapter List or Library.
> **Replaces:** `lib/presentation/features/scripture_reader/pages/verse_list_page.dart` (389 lines)
> **State management:** Riverpod
> - `chapterVersesProvider(scriptureId, chapterNum, bookNum?)` — `AsyncValue<Either<Failure, List<Verse>>>`
> - `chapterReadCountProvider(scriptureId, chapterNum, bookNum?)` — int
> - `bookmarkedVerseIdsProvider` — `Set<String>`
> - `nextUnreadVerseProvider(scriptureId, chapterNum, bookNum?)` — `Verse?`
> - `lastReadVerseProvider(scriptureId, chapterNum, bookNum?)` — `int?`

---

## Purpose

User picked a chapter. Show every verse in it, scannably. The Sanskrit incipit is where the verse *lives*; English is the recognition aid. Three glance-level states (unread / read / bookmarked) communicated through one column on the right edge. Long chapters get a Devanāgarī verse-jumper for 300-verse Mahābhārata-class chapters.

**Density matters here.** Users scanning 47 or 300 verses need information per pixel; chapter list got breathing room because 18 chapters fit easily.

---

## Layout (top to bottom)

1. **Status bar** (system, 44 px)
2. **Top bar** (height 46 px, padding `6px 20px 10px`):
   - Back chevron only (36 × 36, 20 px stroke). Title lives in the header below.
3. **Compact chapter header** (`padding: 0 24px 14px`):
   - **Title row** (flex, `align-items: baseline, justify-content: space-between, gap: 14px, margin-bottom: 6px`):
     - **Devanāgarī chapter title** (left, `Fonts.deva`, 18 px, line-height 1.1, `letter-spacing 0.005em`, `cream`/`text-1`). Ex: `अर्जुनविषादयोग`
     - **Chapter number badge** (right, `Fonts.sans`, 9.5 px w600, `letter-spacing 0.22em uppercase`, `saffron`, flex-shrink 0). Pattern: `CH {N} · {SCRIPTURE_CODE}`. Ex: `CH 1 · BG`. (Codes: `BG`, `BP`, `RV`, `MB`, `RM`, `YS`, `HYP`, etc. — 2-3 letters from `Scripture.shortCode`.)
   - **English subtitle** (12 px gap below title row) — `Fonts.serif italic`, 13 px, `text-2`. Ex: `The Yoga of Arjuna's Grief`
   - **Hairline progress** — 1.5 px, border-radius 1 px, `divider-soft` track, `saffron` fill (only rendered if `readCount > 0`).
   - **Progress meta row** (6 px gap, flex space-between, `Fonts.sans`, 9 px w600, `letter-spacing 0.18em uppercase`, `text-3`):
     - Left: `{N saffron} OF {Total} READ` — `{N}` is `saffron` colour.
     - Right: `{percent}%` — rounded down (e.g. 27.8 % → `28%`).
4. **Resume anchor** (margin `14px 24px 0`, only when `nextUnreadVerseProvider != null`):
   - Border-radius 4 px, padding `14px 16px 14px 20px`, `border 1px solid divider`, `linear-gradient(90deg, saffron@7%, saffron@2% 60%, transparent)`.
   - **Leaf-thread:** 3 px wide saffron rule, `top 10px bottom 10px left 0`, border-radius 2 px. Dark mode adds `box-shadow: 0 0 6px saffron@40%`.
   - Body (flex 1, `min-width: 0`):
     - **Label** (`Fonts.sans` 9 px w600, `letter-spacing 0.24em uppercase`, `saffron`) — `CONTINUE`.
     - **Incipit** (4 px gap) — `Fonts.deva`, 14 px, line-height 1.3, `cream`/`text-1`, single-line ellipsis. First ~30 chars of next-unread verse Sanskrit.
     - **Meta** (3 px gap) — `Fonts.sans`, 10.5 px, `text-2`. Pattern: `Verse {N} — next unread`.
   - **Arrow** (right, `saffron @ 70%`, 14 × 14, short-arrow-with-shaft).
   - Tap → `/verse/{scriptureId}/{chapterNum}/{verseNum}`.
   - **No pulse animation** — verse list lives behind chapter list, the leaf-thread is enough as visual continuity. Reserve pulse for chapter list only.
5. **Verses section** (`margin-top: 14px`, padding `0 24px`):
   - **Section label** (`Fonts.sans` 9.5 px w600, `letter-spacing 0.28em uppercase`, `text-3`, padding-bottom 10 px, `border-bottom: 1px solid divider`):
     - Default: `ALL VERSES`.
     - When sub-sections in use (long chapters with editor-curated boundaries): omit and use sub-section headers instead.
6. **Verse row** (`padding: 11px 0 12px`, flex, `align-items: flex-start, gap: 14px, border-bottom: 1px solid divider-soft`):
   - Hit target ≥ 56 px overall. `:active { opacity: 0.55 }`.
   - **Daṇḍa mark** (38 px wide, centered, flex-shrink 0, `padding-top: 1px`):
     - Pattern: `‖{deva-num}‖` rendered as plain `Text`, `Fonts.deva`, 14 px, line-height 1.4, `letter-spacing -0.02em`.
     - The double-vertical-bar `‖` is U+2016 (DOUBLE VERTICAL LINE). Devanāgarī numeral between, no space. Ex: `‖१‖`, `‖१२‖`, `‖२४७‖`.
     - Colour: `saffron` (default). De-emphasized when read (see states).
   - **Body** (flex 1, `min-width: 0`):
     - **Sanskrit** — `Fonts.deva`, 14.5 px, line-height 1.4, `letter-spacing 0.005em`, `cream`/`text-1`, single-line ellipsis. First ~36 chars of `verse.sanskrit`.
     - **English** (3 px gap) — `Fonts.serif italic`, 12 px, line-height 1.4, `text-3`, single-line ellipsis. First ~50 chars of `verse.english.translation`. Wrap quoted translations in standard double-quotes when present.
   - **State indicator** (right, 14 px wide, flex-shrink 0, `padding-top: 4px`):
     - **Unread** (default): empty (no glyph; preserve column width for alignment).
     - **Read** (in `chapterReadCountProvider` and verse-id matches read-set): 11 × 14 saffron checkmark — small inline check.
     - **Bookmarked**: 11 × 14 saffron filled bookmark glyph (path: `M0 0h11v14l-5.5-3.5L0 14V0z`). Read + bookmarked uses bookmark glyph (saffron); read-state checkmark drops out.
   - **Read row** (`isRead == true`):
     - Daṇḍa mark colour drops to `text-3` (both `‖` and numeral).
     - Sanskrit colour drops to `text-2`.
     - English keeps `text-3`.
     - State indicator stays at `saffron` (checkmark or bookmark).
   - **Bookmarked indicator wins over read** when both true — show bookmark glyph, not checkmark.
   - Tap → `/verse/{scriptureId}/{chapterNum}/{verseNum}`.
7. **Sub-section headers** (only when `verse.sectionLabel != null` AND chapter has > 60 verses):
   - `margin-top: 18px, padding: 8px 0 10px, border-bottom: 1px solid divider`. Inserted between verse rows when section label changes.
   - `Fonts.sans`, 9 px w600, `letter-spacing 0.32em uppercase`, `saffron` (left), `text-3` after the dot.
   - Layout: flex space-between.
     - Left: `VERSES {start}—{end}` (Arabic numerals) `· {section name}`. Ex: `VERSES 11–20 · SĀṄKHYA BEGINS`.
     - Right: `{deva start}` — `Fonts.deva`, 13 px, w400, `letter-spacing 0`, no uppercase, `cream`/`text-1`. Ex: `११`.
   - Section labels come from per-scripture editorial JSON (curated, not auto-generated). Build phase: ship empty map, add Bhagavad Gītā Ch 2 + Mahābhārata Bhīṣma Parva Ch 25 (Gītā section) as seed. Other chapters render without sub-section headers — graceful degradation.
8. **Verse jumper** (sticky right, only when `verses.length >= 40`):
   - **Position:** `Stack` overlay — `right: 8px, top: 70px, bottom: 30px`, width 22 px.
   - **Container:** padding `8px 0`, border-radius 12 px, `background: surface @ 60% + backdrop blur 8px`. Dark uses `1C1816 @ 60%`; light uses `F7F2EC @ 85%`.
   - **Markers:** every 10th verse rounded down. For 47 verses → markers at 1, 11, 21, 31, 41 (5 markers). For 72 verses → 1, 11, 21, 31, 41, 51, 61, 71 (8 markers). For 247 verses → 1, 21, 41, 61, ... 241 (every 20) — clamp to 8 markers max via dynamic step.
   - Each marker: `Fonts.deva`, 11 px, line-height 1, `padding 2px 0`, `text-3`. Active marker: `saffron`, `transform: scale(1.2)`. (Active = closest decade to top-visible verse.)
   - **Drag interaction:** vertical pan scrolls the list to the corresponding verse. Tap on a marker scrolls (animated, 300 ms ease-out) to its verse.
   - **Hover/drag tooltip:** small saffron pill with current verse number (`Fonts.deva`, 14 px). Anchored to the right of the jumper, follows pointer y-position. (iOS Contacts alpha-scroll feel.)
   - Hidden when verse count < 40. Always hidden in loading state.
9. **Bottom safe area** — 24 px gap before safe-area inset.

---

## States

### Default — partway through, < 40 verses
Header with hairline + meta. Resume anchor visible. Verse list dense. No verse-jumper.

### Long chapter — ≥ 40 verses
Same as default + verse-jumper sticky on right. Sub-section headers if curated editorial labels exist.

### First visit (`readCount == 0`)
Header hides hairline progress and progress meta. Resume anchor still shown — points to verse 1 (or verse with smallest verseNum). Same density.

### Read row de-emphasized
When verse is in read-set, daṇḍa numeral and Sanskrit drop one tone; English stays muted; saffron checkmark replaces empty state column.

### Bookmarked
Saffron bookmark glyph in state column. Wins over read state visually (one icon, not stacked).

### Loading
- Header devanāgarī title and English subtitle render at full opacity (we know the chapter metadata client-side from `BhagavadGitaChapters` const or from `ChapterOutline` cached on the previous page).
- Progress hairline + meta swap to a 200 × 10 px shimmer.
- 8 verse-row skeletons: `38 × 18 px` daṇḍa block; body has 14 px (60 % w) + 11 px (80 % w) bars.
- Resume anchor not rendered during loading.
- Verse jumper hidden during loading.

### Error
`ErrorStateWidget` in body slot below header. Retry invalidates `chapterVersesProvider`. Header (with chapter title and number) stays.

---

## Animations

- **Ink-settle entry** (`flutter_animate` `.fadeIn(duration: 350.ms).slideY(begin: 0.02, end: 0)`):
  - Stagger by `20 ms × index` so row N animates at `40 + 20N` ms after build, capped at 9 rows. Rows 10+ render statically. Entry feels like ink settling on a page.
- **Verse-jumper:** no animation on idle; spring-back to active marker after drag ends (200 ms `Curves.easeOut`).
- **Tap feedback:** same as Chapter List — `splashColor: transparent`, `highlightColor: saffron@4%`.

---

## Heritage primitives used

| Primitive | Purpose |
|---|---|
| `LeafThread` | Resume anchor's left edge. |
| `DandaCoord` | Not needed — daṇḍa marks render as plain Text using U+2016. (Don't try to draw them with custom paint.) |
| `arabicToDevanagari(int)` | Both verse numerals and verse-jumper markers. |
| `BookmarkGlyph` | Inline 11 × 14 SVG-style path. New `lib/presentation/shared/widgets/glyphs/bookmark_glyph.dart` — reuse on bookmarks page if shape matches. |

---

## Do / don't

✅ **Do**
- Use double-vertical-bar `‖` (U+2016) flanking Devanāgarī numerals as the verse mark — it *is* the manuscript verse-end punctuation, not decoration.
- Sanskrit dominates the row; English helps recognition. Reverse the old hierarchy.
- Three states (read / unread / bookmarked) in one column. Bookmark wins over read visually.
- Make the verse jumper drag-scrubbable — the markers are interactive, not labels.
- Give long chapters editorial sub-section headers when curated; hide them silently otherwise.
- Single canonical layout: one widget for every scripture, driven by `Verse` + `Chapter`.

❌ **Don't**
- Do not show an empty bookmark icon on unbookmarked verses. The state of "not bookmarked" doesn't need a UI element. (Kill the leftover `_VerseRow` empty bookmark column.)
- Do not show "verse N of M" on every row — the jumper carries position; the row carries content.
- Do not paint a sun arc, mandala, or any large illustration. The list density is the design.
- Do not use the verse-jumper for chapters with < 40 verses — it adds visual noise without paying for itself.
- Do not show the jumper during loading or error.
- Do not stack read-checkmark and bookmark-glyph; collapse to one icon (bookmark wins).
- Do not let the sub-section header text wrap. If a label is too long, truncate with ellipsis on the *English label*, not on `VERSES N—M`.

---

## Acceptance criteria

1. `verse_list_page.dart` stays ≤ 400 lines (single canonical layout). All scripture-specific behaviour driven by `scriptureId` + `Scripture.shortCode`, no `switch` on layout.
2. Resume anchor renders within 1 frame after `nextUnreadVerseProvider` resolves.
3. Daṇḍa marks render correctly for verses 1–999 (Mahābhārata Śāntiparva Ch 247 has 245 verses; some Vedic suktas exceed 200). Verify ‖१००‖, ‖२४७‖, ‖९९९‖.
4. Verse-jumper dynamically picks step (10 default, 20 for ≥ 200 verses, 50 for ≥ 500). Max 8 markers.
5. Verse-jumper drag scrolls the underlying `ListView` smoothly (60 fps on a Pixel 5; profile build).
6. Loading skeleton matches mockup row geometry; doesn't reflow when data lands.
7. Analyzer clean. Widget test asserts: (a) jumper hidden when verses < 40, (b) read-row de-emphasis applied, (c) bookmark wins over read state, (d) sub-section header inserted at correct boundary.
8. Hit target ≥ 48 px on every verse row.
9. Screen built behind `extendBodyBehindAppBar: true` + transparent Scaffold + `WarmBackdrop(intensity: 0.6)`.

---

## Open questions for build phase

- **Verse incipit length** (resume anchor + row Sanskrit): hard-cap at 36 chars or use `TextOverflow.ellipsis` + `maxLines: 1`? **Default: ellipsis on `maxLines: 1`** — let the layout decide based on width, don't pre-truncate.
- **`verse.sectionLabel` source:** field on `Verse` entity? Likely missing — add as nullable string + ship empty for now. Editorial seeding (Gītā Ch 2 sections) is a follow-up content task, not part of build #6.
- **Single-chapter scriptures** entering directly from Library: do they need a back chevron pointing at Library (not Chapter List)? Same icon either way; `context.pop()` handles it as long as router doesn't insert Chapter List. Verify router during build.
