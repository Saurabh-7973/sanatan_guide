# Sanatan Guide — Full Redesign Spec
**Date:** 2026-04-25  
**Scope:** All screens except Home (untouched). Sacred Geography direction. Saffron/cream/dark palette unchanged.

---

## Design Principles

- **Same palette everywhere.** AppColors tokens are fixed. No new colors.
- **No emojis.** Every icon or illustration is a drawn CustomPainter or SVG path.
- **Typography-first.** Sanskrit text dominates. Ornaments serve content.
- **Each screen has one unique cultural illustration** that defines its identity.
- **Light mode opacity fix:** all existing ornament painters at 0.08 → 0.28. Dark stays 0.12.
- **Reference:** `claudedesign/components/direction-sanctum.jsx`, `direction-sutra.jsx`, screenshots from screenshots at 1.04–1.05 PM.

---

## Phase 1 — Core Reading Experience (highest priority)

### 1. Verse Detail — "Sanctum" Direction

**Reference:** `claudedesign/components/direction-sanctum.jsx`  
**Identity:** Asymmetric temple-mandapa layout. Left gutter is the structural signature.

**Layout:**
- `AppBar`: back + bookmark + share. No title text.
- `Row` fill:
  - **Left gutter (48px wide):**
    - Vertical saffron rule (full height, gradient from transparent→saffron→transparent, opacity 0.5)
    - Scripture code stamp: 36px circle, saffron border, saffron text "BG" / "MU" / etc.
    - Rotated scripture name: `transform: rotate(-90deg)`, small caps, muted color
    - CH / V label pair at bottom: chapter number large, verse number in saffron, Lora font
  - **Main column (flex 1):** scroll content
    - Scripture chip (saffron faint bg, saffron dot + name)
    - Sanskrit in `TiroDevangariSanskrit` 24sp, lineHeight 2.0, `sanskritText`/`sanskritTextOnDark`
    - Transliteration toggle header + italic Lora 14sp
    - **SanctumCard** widget (reusable): surface bg, border, left saffron 3px accent bar, collapsible
      - Translation card: English 16sp Lora + Hindi 15sp NotoSansDevanagari
      - Word by Word card (collapsible): Sanskrit word + meaning pairs
      - Your Reflection card: editable note, italic Lora
    - "Ask the Guide" row: saffron faint bg, sparkle drawn icon, chevron
- **Bottom nav:** prev verse ← swipe · CH.V · → next verse. Lora italic hint.

**New widgets:**
- `_GutterRail` — the left column
- `SanctumCard` — reusable collapsible card with saffron accent
- `_AskGuideRow` — replaces current AI explanation entry point

**Existing widgets to remove/replace:**
- `verse_content_sliver.dart` content restructured
- `verse_section_widgets.dart` — SanctumCard replaces VineFlourish dividers

---

### 2. Light Mode Opacity Fix (sacred_ornaments.dart)

All 6 painters accept `isDark` bool. Opacity table:

| Painter | Light opacity | Dark opacity |
|---------|--------------|-------------|
| MandalaBackdrop | 0.28 | 0.12 |
| ToranaArch | 0.30 | 0.15 |
| VineFlourish | 0.30 | 0.18 |
| JaaliLattice | 0.25 | 0.10 |
| LotusMedallion | 0.32 | 0.20 |
| KalashFinial | 0.28 | 0.14 |

Each widget reads `Theme.of(context).brightness` and passes `isDark` to painter.

---

## Phase 2 — Entry + Discovery Screens

### 3. Onboarding — Ganga at Sunrise

**Identity:** You arrive at the ghats before dawn. You choose a lamp to carry.

**New painters (all in `sacred_ornaments.dart`):**
- `GangaWavePainter` — full-bleed background painter:
  - Sky: vertical gradient deep violet (#1A0E2A) → burnt amber (#2D1500)
  - Sun disk: radial glow at horizon center, 2 concentric circles
  - Ghats silhouette: left + right, simple polygon fills
  - 3 wave paths: sine curves across bottom, saffron strokes at 0.4/0.3/0.2 opacity
  - Sun reflection: ellipse on water
  - Light mode: cream → warm saffron tint sky, warm grey ghats
- `SeedlingPainter` — beginner icon (sprout + 2 leaves + roots, 32px)
- `DiyaPainter` — regular icon (clay bowl + wick + teardrop flame, 32px)
- `ScrollPainter` — scholar icon (palm leaf rectangle + text lines + curl edges, 32px)

**Onboarding page changes:**
- Scaffold bg: `Stack` with `GangaWaveBackdrop` (full bleed, `IgnorePointer`)
- Level cards: replace `Text(emoji)` with `CustomPaint(painter: SeedlingPainter(...))` etc.
- CTA text: "Step into the sacred waters" (beginner) / "Continue your path" (regular/scholar)
- Step 2 path cards: replace emoji with `TempleStairsPainter`, `DiamondKnotPainter`, `OpenScrollPainter`
- TempleStairsPainter: 3 ascending steps, saffron lines
- DiamondKnotPainter: interlaced diamond knot (infinity-style), saffron
- OpenScrollPainter: unrolling scroll with text lines visible

---

### 4. Search — The Peacock of Naimisharanya

**Identity:** Before you search, a peacock stands in the forest. Each feather = a concept.

**New painters:**
- `PeacockPainter` — ink-drawing style, saffron on dark / deep brown on cream:
  - Body: ellipse
  - Neck: cubic bezier curve upward
  - Head: circle
  - Crest: 3 thin lines with dot tips
  - Tail: 7–9 radial path.cubicTo() feathers, each ending with:
    - Outer ellipse (eye ring)
    - Inner concentric circle (eye pupil)
  - Feet: 3 toe paths each side
  - Scale parameter: 200 (empty state hero) / 18 (search bar icon)
- `ForestDapplePainter` — background: overlapping circles at low opacity suggesting tree canopy

**Search page changes:**
- `_EmptyPrompt`: replace `Icons.auto_stories_outlined` container with `PeacockPainter(size: 200)` centered
- Suggestion chips: `feather-chip` style — forest-tinted bg (saffron faint), carved feel
- Search bar prefix: `SizedBox(18x18, child: CustomPaint(painter: PeacockPainter(size: 18, singleFeather: true)))` instead of `Icons.search_rounded`
- Background: `ForestDappleBackdrop` behind `_EmptyPrompt`
- No results state: peacock with folded tail (tail feathers pointing down, `PeacockPainter(tailFolded: true)`)

---

## Phase 3 — Library Tier

### 5. Scripture Library — Nalanda Halls

**Identity:** Great library of ancient India. Categories = stone hall doorways.

**New painter:**
- `NalandaArchPainter` — page header backdrop: multi-foil arch silhouette across top, saffron at 0.22 opacity. Column/pillar hints at edges.

**Scripture library page changes:**
- Header area: `Stack` with `NalandaArchPainter` behind title
- Category cards: left accent border uses existing `catItihasa`/`catVeda`/etc. colors (already in AppColors)
- Add: carved diamond ornament at card top-right corner (`CustomPaint` 16x16, accent color)
- Scripture rows: drawn book icon (SVG path) instead of any emoji

### 6. Chapter List — Temple Corridor

**Identity:** Walking a pillared corridor. Each chapter = a doorway.

**Changes:**
- Chapter number badge: use existing `LotusMedallion` painter (already built, just ensure opacity fix)
- Section between chapters: `VineFlourish` (already built) with fixed opacity
- Header: `ToranaArch` behind chapter title (already built)
- No new painters required

### 7. Verse List — Palm Leaf Manuscript

**New painter:**
- `PalmLeafBorderPainter` — thin decorative border for verse rows: leaf-vein lines at top+bottom of each card, saffron at 0.20 opacity

**Verse list changes:**
- `VersePreviewTile`: add `PalmLeafBorderPainter` as background decoration
- Verse number: existing `LotusMedallion` (already built)

---

## Phase 4 — Utility Screens

### 8. Bookmarks — The Offering Tray

**Identity:** Saved verses as flowers on a prasad tray.

**New painter:**
- `PrasadTrayPainter` — empty state illustration: lotus arrangement on water, concentric ripples, 5 lotus blooms. Saffron, 160px.

**Bookmarks page changes:**
- Empty state: replace generic icon with `PrasadTrayPainter`
- Empty text: "Your offerings await" instead of generic empty message

### 9. Festival Calendar — Night of Diyas

**New painter:**
- `DiyaFlameDrawnPainter` — 24px diya icon (clay bowl + flame, ink style) replacing any emoji diya

**Festival page changes:**
- Festival row icon: `DiyaFlameDrawnPainter` instead of emoji/calendar icon
- Upcoming festival highlight card: saffron glow border, `DiyaFlameDrawnPainter` at 32px left

### 10. Learning Path — The 64 Steps

**New painter:**
- `TempleStaircasePainter` — page header: ascending steps from bottom-left to horizon, perspective lines, saffron strokes at 0.22 opacity

**Learning path changes:**
- Header backdrop: `TempleStaircasePainter`
- Module completion indicator: drawn checkmark (lotus check) not Material checkmark
- Progress line between modules: saffron rule with dot nodes

### 11. Module Reader — Under the Peepal

**New painter:**
- `PeepalTreePainter` — background: faint peepal tree silhouette (heart-shaped leaves, branching trunk), saffron at 0.12 opacity in dark, 0.22 in light

**Module reader changes:**
- Scaffold: `Stack` with `PeepalTreePainter` centered behind content
- Section dividers: `VineFlourish` (already built)

### 12. Verse Chat — Guru's Corner

**New painter:**
- `DhyanaAsanaPainter` — background top: rishi silhouette seated in padmasana (simple outline, muted saffron, 0.15 opacity). Incense smoke: 3 wavy upward lines from base.

**Verse chat changes:**
- Scaffold top area: `DhyanaAsanaPainter` behind header
- "Ask" input area: carved stone input style (surface-elevated bg, saffron border on focus)
- AI response bubbles: `SanctumCard`-style (left saffron accent bar)

### 13. Settings — The Keeper's Chamber

**New painter:**
- `OilLampRowPainter` — section divider ornament: 3 small diya lamps in a row, saffron, 28px height

**Settings changes:**
- Each section divider: `OilLampRowPainter` replaces plain `Divider`
- Section headers: small `DiyaPainter` icon (18px) left of section title
- No emoji anywhere

### 14. Credits — Stone Inscription Wall

**New painter:**
- `InscriptionBorderPainter` — page top: horizontal carved stone border with lotus rosettes at intervals, saffron at 0.28 opacity

**Credits changes:**
- Page header: `InscriptionBorderPainter`
- Disclaimer banner: styled as "carved stone tablet" (same surface + saffron border, now at correct opacity)
- Section headers: small carved diamond ornament left of title

---

## New Files

```
lib/presentation/shared/widgets/sacred_ornaments.dart  (extend existing)
  + GangaWavePainter / GangaWaveBackdrop
  + SeedlingPainter / DiyaPainter / ScrollPainter
  + PeacockPainter / PeacockBackdrop
  + ForestDapplePainter / ForestDappleBackdrop
  + NalandaArchPainter / NalandaArchBackdrop
  + PalmLeafBorderPainter
  + PrasadTrayPainter
  + DiyaFlameDrawnPainter
  + TempleStaircasePainter
  + PeepalTreePainter / PeepalTreeBackdrop
  + DhyanaAsanaPainter / DhyanaAsanaBackdrop
  + OilLampRowPainter
  + InscriptionBorderPainter
  + TempleStairsPainter / DiamondKnotPainter / OpenScrollPainter  (onboarding path icons)

lib/presentation/features/scripture_reader/widgets/sanctum_card.dart  (new)
lib/presentation/features/scripture_reader/widgets/gutter_rail.dart   (new)
```

## Modified Files

```
lib/presentation/shared/widgets/sacred_ornaments.dart   (opacity fix + new painters)
lib/presentation/features/scripture_reader/pages/verse_detail_page.dart  (Sanctum layout)
lib/presentation/features/scripture_reader/widgets/verse_content_sliver.dart
lib/presentation/features/scripture_reader/widgets/verse_section_widgets.dart
lib/presentation/features/onboarding/pages/onboarding_page.dart
lib/presentation/features/search/pages/search_page.dart
lib/presentation/features/scripture_reader/pages/scripture_library_page.dart
lib/presentation/features/scripture_reader/pages/chapter_list_page.dart
lib/presentation/features/scripture_reader/pages/verse_list_page.dart
lib/presentation/features/bookmarks/pages/bookmarks_page.dart
lib/presentation/features/festivals/pages/festival_calendar_page.dart
lib/presentation/features/learning_path/pages/learning_path_page.dart
lib/presentation/features/learning_path/pages/module_reader_page.dart
lib/presentation/features/scripture_reader/pages/verse_chat_page.dart
lib/presentation/features/settings/pages/settings_page.dart
lib/presentation/features/settings/pages/credits_page.dart
```

---

## Implementation Order

1. `sacred_ornaments.dart` — opacity fix for all 6 existing painters (fast win, fixes light mode)
2. Verse detail — Sanctum direction (highest visibility screen)
3. Onboarding — GangaWave + drawn icons (first-run experience)
4. Search — PeacockPainter (empty state, search bar icon)
5. Scripture library → Chapter list → Verse list (library tier)
6. Bookmarks → Festivals → Learning path → Module reader (utility tier)
7. Verse chat → Settings → Credits (final polish)

---

## Quality Gates

- `flutter analyze` must pass after each screen
- No emojis anywhere in presentation layer
- All ornament painters work at both brightness modes
- Light mode: ornaments visible at ≥0.25 opacity
- Dark mode: ornaments visible at ≥0.12 opacity
- Home screen: untouched (zero changes)
