# Screen Spec — Library

> **Build order:** #4 (after Home)
> **Mockup file:** `New Design/screen-03-library.html`
> **Routes:** `/library` (root tab — bottom nav: Texts)
> **State management:** Riverpod
> - `libraryStatsProvider` (total verses + scripture count, computed from DB)
> - `scriptureFamiliesProvider` (AsyncValue<List<Family>>, grouped + ordered)
> - `librarySearchQueryProvider` (StateProvider<String>, debounced 200 ms)
> - `librarySearchResultsProvider` (AsyncValue<List<ScriptureMatch>>)

---

## Purpose

The full corpus, structured the way a Sanskrit library is actually structured — **Śruti / Smṛti taxonomy** in six families. Rows, not cards. The user finds a scripture, sees their reading progress next to it, and drills in. This is a catalog screen, not a feed.

---

## Layout (top to bottom, scroll container)

1. **Status bar** (system, 44 px)
2. **Library header** (padding `8px 24px 18px`):
   - Title: `Library` — `AppText.screenTitle` 32 px serif w500, letter-spacing -0.02em, line-height 1
   - Stats line (10 px margin top, sans 11 px w500, letter-spacing 0.16em uppercase, `dText3`):
     `1,33,613 verses  ·  31 scriptures`
     - Numbers (`1,33,613`, `31`) wrapped in `Fonts.serif` italic 13 px, letter-spacing 0, no uppercase, saffron color
     - Use Indian-format comma grouping (`1,33,613`, not `133,613`). Implement via a small helper, do **not** rely on intl default.
     - Separator: 4 px saffron circle, 10 px horizontal margin
3. **Search bar** (margin `16px 24px 0`):
   - 44 px tall, radius 28 px, padding `0 18px`, `dSurface` + 1 px `dDividerSoft`
   - Left: search glyph SVG (16 × 16, current-color stroke 1.6 px) — `dText2` resting, **saffron when focused**
   - Input: sans 14 px, letter-spacing 0.01em, placeholder `Find a scripture...` (placeholder = `dText3`)
   - When non-empty: trailing 14 × 14 close-X (saffron) — clears query
   - Focus state: 1 px saffron border (replaces `dDividerSoft`)
4. **Family list** (one `Family` block per taxonomy):
   - Iterate the six families in order: Śruti, Itihāsa, Purāṇa, Darśana, Dharmaśāstra, Tamil
   - 32 px margin top before the first family; 0 between (each family already has its sticky header providing visual break)
   - Each family animates in on first render: fade-up 500 ms ease-out, staggered 60 ms per family (`60 / 120 / 180 / 240 / 300 / 360 ms`)
5. **Bottom nav** (managed by `ScaffoldWithNavBar`)

---

## Family block structure

### Sticky header

- Position: sticky to the top of `screen-content` (under any scroll offset). Use `SliverPersistentHeader` (pinned: true) inside a `CustomScrollView`.
- Padding `0 24px 14px`, with `padding-top: 16px` inside an inner `Column`
- Backdrop: blur 8 px + 85% bg color (`rgba(15,15,15,0.85)` dark / `rgba(253,250,246,0.9)` light) — implement with `BackdropFilter(filter: ImageFilter.blur(sigmaX:8, sigmaY:8))` over a translucent container
- Inner column (1 px bottom border in `dDivider` / `lDivider`):
  - **Devanāgarī family name** (`Fonts.deva`, 22 px, line-height 1, letter-spacing 0.02em, saffron, 4 px bottom margin)
    - `श्रुति` / `इतिहास` / `पुराण` / `दर्शन` / `धर्मशास्त्र` / `தமிழ் சாஸ்திரம்`
    - **Tamil family uses Tamil script** (Noto Sans Tamil if present in fonts, else system fallback). Don't transliterate to Devanagari.
  - **Row** (baseline-aligned, space-between):
    - English label: italic serif 13 px w500, `dText1` — e.g. `Śruti — that which is heard`
    - Meta: sans 9 px w600, letter-spacing 0.22em uppercase, `dText3` — e.g. `5 TEXTS`
  - **Description** (8 px margin top, italic serif 12.5 px, line-height 1.5, `dText2`, padding-right 40 px to avoid running into meta):
    - Śruti: `The earliest, eternal revelations — the Vedas and principal Upaniṣads.`
    - Itihāsa: `Stories that happened — Rāma, the Pāṇḍavas, the Gītā within.`
    - Purāṇa: `Cosmology, devotion, and the līlās of the divine.`
    - Darśana: `The condensed teachings — yoga, vedānta, and the schools of thought.`
    - Dharmaśāstra: `Law, ethics, and the conduct of life across the four āśramas.`
    - Tamil: `The southern stream — ethics in couplets, devotion in song.`

### Family contents

Two render modes:

#### A. **Vedas grid** (Śruti family only, for the four Vedas)
- 2×2 grid, margin `8px 24px 0`, gap 10 px
- Each `VedaCell`:
  - Aspect ratio **3 : 2** (Sulba Sutra brick proportion)
  - Padding `14px 14px 12px`, radius 4 px, `dSurface` + 1 px `dDividerSoft` border
  - Top: `Fonts.deva` 16 px, line-height 1.2, `dCream` — e.g. `ऋग्वेद`
    - Below: `Fonts.serif` 13 px w500, `dText1`, 2 px margin top — e.g. `Ṛg Veda`
  - Bottom: meta sans 10 px w500, letter-spacing 0.14em uppercase, `dText3` — e.g. `10,552 mantras`
  - Tap → routes to `/scripture/{vedaId}`
- The four cells (in this order): `ऋग्वेद Ṛg Veda · 10,552 mantras`, `सामवेद Sāma Veda · 1,875 mantras`, `यजुर्वेद Yajur Veda · 1,975 mantras`, `अथर्ववेद Atharva Veda · 5,977 mantras`

#### B. **Scripture rows** (everything else, plus the Mukhya Upaniṣads inside Śruti below the Vedas grid)
- Padding `16px 24px`, full-width tap target, 1 px bottom border `dDividerSoft` (none on last row of family)
- `:active` background tint: `rgba(232,130,12,0.04)` dark / `rgba(194,101,8,0.04)` light, 180 ms ease
- Layout (Row, 14 px gap):
  1. **Family glyph** — 8×8 px diamond (rotated 45°), color depends on family:
     - Śruti: `dSaffron` / `lSaffron`
     - Smṛti (Itihāsa, Purāṇa, Dharmaśāstra): `dIronRed` / `lIronRed`
     - Darśana: `#C9A467` (dark) / `#A47B30` (light)
     - Tamil: `#B07642` (dark) / `#8B5226` (light)
  2. **Body** (Expanded, min-width 0):
     - Devanāgarī name: `Fonts.deva` 17 px, line-height 1.2, letter-spacing 0.005em, `dCream` / `lText1` — e.g. `भगवद्गीता`
       - Tamil exception: Tirukkuṟaḷ renders as `திருக்குறள்` in `Fonts.sans` (Outfit) 15 px because Tiro Devanagari doesn't cover Tamil and Outfit has acceptable Tamil fallback chains
     - English name: `Fonts.serif` 15 px w500, letter-spacing -0.005em, line-height 1.25, 4 px margin top, `dText1` — e.g. `Bhagavad Gītā`
     - Meta line: sans 11 px, line-height 1.4, `dText3` — composed of:
       - Verse count in italic serif 12 px, `dText2`, 6 px right margin: e.g. `700 verses`
       - Middle dot ` · ` then unit-of-organization in sans w500: `18 chapters`
       - **Read indicator (saffron, sans w500)** appended only if user has read ≥1 verse: ` · 1 verse read` (or `· 12 verses read`, `· 1 chapter read` once chapter completed)
  3. **Right chevron** — 8×14 SVG, `dText3`, 0.4 opacity, `>` shape

#### Family contents matrix

| Family | Render | Scriptures (in order) |
|---|---|---|
| Śruti | Vedas grid + 1 row | 4 Vedas (grid), then `मुख्य उपनिषद् ११ — The Mukhya Upaniṣads — 1,876 verses · 11 principal texts` (row, 8 px margin above) |
| Itihāsa | Rows | `भगवद्गीता Bhagavad Gītā 700 / 18 chapters`, `रामायण Rāmāyaṇa 18,761 / 7 kāṇḍas`, `महाभारत Mahābhārata 72,770 / 18 parvas` |
| Purāṇa | Rows | `श्रीमद्भागवतम् Bhāgavata Purāṇa 14,031 / 12 cantos`, `विष्णुपुराण Viṣṇu Purāṇa 6,000 / 6 aṁśas` |
| Darśana | Rows | `योगसूत्र Yoga Sūtras of Patañjali 195 sūtras / 4 pādas`, `ब्रह्मसूत्र Brahma Sūtras 555 sūtras / 4 adhyāyas` |
| Dharmaśāstra | Rows | `मनुस्मृति Manusmṛti 2,684 / 12 chapters`, `अर्थशास्त्र Arthaśāstra 5,348 / 15 books` |
| Tamil | Rows | `திருக்குறள் Tirukkuṟaḷ 1,330 couplets · Tiruvaḷḷuvar` |

Row tap → routes to `/scripture/{id}` (chapter list for that text).

---

## States

### Default
All 6 families render. Reading-progress per scripture is fetched from the same provider and merged into the row meta line.

### Loading (any family list provider pending)
- Library header + search bar render normally
- Stats line right side replaced by skeleton (10 px × 180 px)
- Below, a single skeleton block stands in for the family list:
  - 22 px tall × 80 px wide skeleton (the Devanāgarī family name)
  - 12 px × 60% (English subtitle)
  - 11 px × 80% (description)
  - For Śruti: 2×2 skeleton grid with 3:2 aspect-ratio cells
  - For others: 3 stacked skeleton rows, 50 px tall, 12 px gap
- No animation stagger during loading; just steady shimmer (1.6 s, 50→85→50 opacity)

### Search active (`query.isNotEmpty`)
- Replace **everything below the search bar** (entire family list and its sticky headers) with a search results list
- Above results: small-caps count line in padding `18px 24px 8px` — sans 10 px w600, letter-spacing 0.22em, `dText3` — e.g. `3 RESULTS`
- Each `SearchResultRow` (padding `14px 24px`, 1 px bottom border `dDividerSoft`, tappable):
  1. **Devanāgarī snippet** (60 px fixed width, `Fonts.deva` 14 px, `dText3`) — the matching script-name
  2. **Body** (Expanded):
     - Name: `Fonts.serif` 14 px, `dText1`, 2 px bottom margin — with **matched substring wrapped in saffron `w500`** (use `RichText` + `TextSpan`, case-insensitive match)
     - Family tag: sans 10 px, letter-spacing 0.16em uppercase, `dText3` — e.g. `ITIHĀSA · 700 VERSES`
  3. Chevron — same 8×14 saffron-text-3 chevron
- Search bar gets focus styling: 1 px saffron border, search glyph turns saffron, trailing close-X appears
- Empty results: render the empty-state block (margin `40px 24px 0`, padding 32×22, dashed `0.15` cream border, radius 4 px, centered):
  - Glyph: `Fonts.deva` 28 px saffron — `?` or `॥` (use `॥`)
  - Title: italic serif 16 px, `dText1`, 6 px bottom margin — `No scripture matches "{query}"`
  - Body: serif 13 px, line-height 1.5, `dText2` — `Try a different spelling — Devanāgarī or Roman both work.`
- Esc / close-X / blur returns to family list (clears query)

### Search results — match logic
- Match against: scripture's English name (case-insensitive), English alias list (e.g. `Gita`, `Geeta`), Devanāgarī name (substring), and Tamil name (substring) where applicable.
- Order results by:
  1. Exact prefix match in English name
  2. Substring match in English name
  3. Match in Devanāgarī
  4. Match in alias list
- Ties broken by canonical order (Itihāsa before Purāṇa, etc.)

---

## Scroll behavior

- Use `CustomScrollView` with one `SliverPadding(SliverList(library header + search))` then **per-family** a `SliverPersistentHeader(pinned: true)` for the family header followed by a `SliverList` (or `SliverGrid` for Śruti's Vedas) of contents.
- Sticky header transitions: as a new family scrolls under the previous header, the previous header animates **out** while the new one animates **in** (no stacking — only one header visible at a time). `SliverPersistentHeader` default behavior achieves this.

---

## Tokens & widgets used

- `DColors.{bg, surface, saffron, saffronDeep, saffronGlow, cream, text1, text2, text3, divider, dividerSoft, ironRed}` + light variants
- Hardcoded family-glyph colors for Darśana (`#C9A467` / `#A47B30`) and Tamil (`#B07642` / `#8B5226`) — these are not in `DColors`, define them as private constants in the screen file
- `AppText.{screenTitle, sectionLabel}`, plus inline `TextStyle` only for the verse-count italic serif (since it's a one-off mid-line variant)
- `Fonts.{sans, serif, deva}`
- `BackdropFilter` for sticky-header blur
- Skeleton shimmer (same recipe as Home)

**No** ornament painters, **no** `WarmBackdrop`, **no** `SacredOrnaments` overlay on this screen.

---

## Don't

- ❌ Don't use cards. The library is rows. A card's drop-shadow says "product"; this is a catalog.
- ❌ Don't show Devanāgarī letter-circles next to scripture names (the old `गी` placeholder). The 8×8 family-color diamond is the only glyph.
- ❌ Don't auto-expand or collapse families. They are all visible always.
- ❌ Don't show family count badges with "NEW" or "POPULAR". The only badge is `N TEXTS` (count) and `N verse(s) read` (progress).
- ❌ Don't render Tirukkuṟaḷ in Devanāgarī. Use Tamil script.
- ❌ Don't use `intl`'s default number formatter for stats — implement Indian-format grouping (1,33,613) explicitly.
- ❌ Don't put bottom nav inside this screen — it lives in `ScaffoldWithNavBar`.
- ❌ Don't use a separate search screen. Inline search replaces the family list in place.
- ❌ Don't show family descriptions on the row screens (chapter list, verse list) — descriptions are a Library-only affordance.

---

## Acceptance criteria

- [ ] Six families render in order: Śruti, Itihāsa, Purāṇa, Darśana, Dharmaśāstra, Tamil
- [ ] Vedas appear as a 2×2 grid with 3:2 aspect cells, in the order Ṛg / Sāma / Yajur / Atharva
- [ ] Mukhya Upaniṣads renders as a single row inside Śruti, **after** the Vedas grid
- [ ] Tamil family header uses Tamil script (`தமிழ் சாஸ்திரம்`); Tirukkuṟaḷ row uses `திருக்குறள்`
- [ ] Family headers stick to top during scroll; only one header visible at a time
- [ ] Stats line uses Indian-format comma grouping (`1,33,613`, not `133,613`)
- [ ] Reading progress (`· N verse(s) read`) shows in saffron next to scripture meta when present
- [ ] Search activates inline; family list is fully hidden during search
- [ ] Search highlights matched substring in saffron `w500` (case-insensitive)
- [ ] Search empty state renders with `॥` glyph + helpful copy
- [ ] Light + dark themes both render with correct family-glyph colors
- [ ] Loading state shows shimmer skeletons preserving the structural shape
- [ ] All Devanāgarī uses `Fonts.deva` (Tiro Devanagari Sanskrit)
- [ ] All English UI uses `Fonts.serif` (Lora) for prose / italic-meta and `Fonts.sans` (Outfit) for labels
- [ ] No painter ornaments, no `WarmBackdrop`, no card-with-shadow on this screen
- [ ] Tap on Veda cell, scripture row, and search result correctly routes to `/scripture/{id}`
