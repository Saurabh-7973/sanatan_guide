# Screen Spec — Bookmarks (Pothī)

> **Build order:** #8 (after Search 06)
> **Mockup file:** `New Design/screen-07-bookmarks.html`
> **Routes:** `/bookmarks` (tab nav + push from chapter list / verse detail / search)
> **Replaces:** `lib/presentation/features/bookmarks/pages/bookmarks_page.dart` (already migrated to WarmBackdrop baseline; full rewrite to spec)
> **State management:** Riverpod
> - `enrichedBookmarksProvider` — `Stream<List<EnrichedBookmark>>` (verseId, sanskrit, english, scripture, savedAt, optional note) — already exists.
> - `bookmarkSortProvider` — `StateProvider<BookmarkSort>` with values `recent` and `byScripture`.
> - `bookmarkNoteProvider(verseId)` — derived from `EnrichedBookmark.note`.

---

## Purpose

The bookmarks screen is the user's *pothī* — their personal bundle of saved verses. Every other reading app says "Saved Verses." This screen says what the thing actually is.

Each bookmark is a **leaf**, not a card: top binding line + central diamond hole + saffron knot-mark in the upper right. The leaf vocabulary echoes verse-detail's binding lines. Sanskrit incipit dominates the surface. A 1-line italic-serif personal note (when present) appears below — the highest-leverage feature most reading apps skip.

Two views: **Recent** (default) and **By scripture** (heavy-user mode). Empty state teaches; loading state mirrors the leaf shape.

---

## Layout (top to bottom)

1. **Status bar** (system, 44 px)
2. **Top bar** (`padding 6px 20px 14px`, gap 12 px):
   - **Back chevron** (36 × 36 hit, 20 px stroke icon, `text-1`).
   - **Spacer** (flex 1).
   - **Magnifier action** (36 × 36 hit, 18 px stroke icon, `text-1`) — pushes `/search`.
3. **Pothī header** (`padding 4px 24px 18px`):
   - **Title row** (gap 14 px, `align-items: baseline`, margin-bottom 4 px):
     - Devanāgarī `पोथी` — `Fonts.deva`, 26 px, line-height 1, `letter-spacing 0.005em`, `cream`/`text-1`.
     - English `Your collection` — `Fonts.serif` 22 px w500, `letter-spacing -0.015em`, line-height 1, `text-1`.
   - **Meta line** (12 px gap, `Fonts.sans` 11 px w500, `letter-spacing 0.16em uppercase`, `text-3`):
     - Pattern: `{N} VERSES SAVED · FROM {M} SCRIPTURES`.
     - Numeric tokens: `Fonts.serif italic` 13 px w500, `letter-spacing 0`, no uppercase, `saffron`.
     - 3 px saffron-dot separator (vertical-align middle, margin `0 8px 2px`).
4. **Sort bar** (`margin: 0 24px 8px`, padding-bottom 12 px, `border-bottom: 1px solid divider`):
   - Left: tabs (gap 18 px). Each tab `Fonts.sans` 11 px w600, `letter-spacing 0.16em uppercase`, padding-bottom 2 px, `1.5 px solid` underline (saffron when active, transparent otherwise). Tabs: `RECENT` and `BY SCRIPTURE`.
   - Right: `Filter` affordance — 12 × 12 hamburger icon + `Filter` label (`Fonts.sans` 10.5 px w500, `letter-spacing 0.06em`). v1: tap is a no-op stub showing `SnackBar('Filters coming soon')`. Wired up later.
5. **Body** swaps based on `enrichedBookmarksProvider` state and active sort tab.

### State: populated, sort = recent

   - List of leaves, ordered by `savedAt` desc.
   - Each leaf:
     - **Container** (`margin: 14px 24px 0`, padding `18px 18px 16px`, border-radius 4 px, `surface` background, no border).
     - **Top binding line** (absolute, left 18 / right 18 / top 8, height 12 px, flex `align-items: center`):
       - Two `flex: 1, height: 1px` rules, separated by a centered diamond hole (5 × 5, rotated 45°, `divider` color).
     - **Knot-mark** (absolute, top 14, right 18, 14 × 14 wrapper):
       - 7 × 7 saffron diamond (rotated 45°, `saffron` filled). Suggests the silk thread tying the leaf.
     - **Coord line** (margin-top 18 px, margin-bottom 10 px, `Fonts.sans` 9.5 px w600, `letter-spacing 0.24em uppercase`, `text-3`):
       - `<dev-num>{Devanāgarī coord}</dev-num> · {SHORTCODE} · {UNIT_LABEL}` — e.g. `२·४७ · BG · CHAPTER 2`.
       - `dev-num` span: `Fonts.deva` 11 px, `letter-spacing 0`, `saffron`, `margin-right 2px`.
     - **Sanskrit** — `Fonts.deva` 16 px, line-height 1.55, `letter-spacing 0.005em`, `cream`/`text-1`, max 2 lines ellipsis. Source: first line(s) of `verse.sanskrit` up to ~80 chars.
     - **English** — `Fonts.serif italic` 13 px, line-height 1.45, `text-2`, max 2 lines ellipsis. Single-double-quoted: `"…"` wrapping the translation fragment.
     - **Note** (only when `bookmark.note != null && note.isNotEmpty`):
       - `padding-top 12px`, `border-top: 1px dashed divider-soft`.
       - Icon (11 × 11 pencil glyph, `text-3`, margin-top 2 px) + body (`Fonts.serif italic` 12 px, line-height 1.45, `text-2`).
     - **Footer** (margin-top 12 px, flex space-between, `Fonts.sans` 10.5 px, `letter-spacing 0.04em`, `text-3`):
       - Left: scripture glyph (5 × 5 saffron square, slightly rotated for organic feel) + scripture display name (`Fonts.serif italic` 11.5 px, `text-2`).
       - Right: relative date — `2 days ago` for ≤ 30 days; `27 Apr 2026` (Mon abbrev + day + year) otherwise. Use intl/local formatter.
   - Tap leaf → `/browse/{scriptureId}/verse/{verseId}`.

### State: populated, sort = by scripture

   - Same leaves, but grouped under `_GroupHeader`:
     - `padding: 22px 24px 12px`, `border-bottom: 1px solid divider`, flex space-between baseline:
       - Left: Devanāgarī title (`Fonts.deva` 14 px, `cream`/`text-1`) + space + italic-serif English (`Fonts.serif italic` 11.5 px, `text-2`). Mirrors search result-group header.
       - Right: count `{N} verses` (`Fonts.sans` 9 px w600, `letter-spacing 0.18em uppercase`, `text-3`).
   - Within each group, the `coord` line on each leaf drops the SHORTCODE (header carries it): `२·४७ · CHAPTER 2`.
   - Sort within a group: most recently saved first.
   - Group order: by total bookmark count desc, ties broken by most recent saved.

### State: empty (zero bookmarks)

   - **Pothī header** still rendered (without meta line — `0 verses saved` message replaced with empty illustration).
   - **Empty illustration** (centered, `padding 48px 32px`):
     - 3 abstract leaves stacked at slight angles, suspended on a saffron vertical thread (CSS positioned in mockup; in Flutter use a `CustomPaint` or simply 3 stacked containers with `Transform.rotate` and a thin `saffron` `VerticalDivider` behind).
   - **Title** `Your pothī awaits` — `Fonts.serif` 18 px w500, line-height 1.3, `text-1`, centered.
   - **Body** — `Fonts.serif` 13 px, line-height 1.55, `text-2`, centered, max 2 lines: `Save a verse, and it joins your collection — like a leaf bound in your own bundle. Add a note about why it spoke to you.`
   - **CTA** `Begin reading` (`Fonts.sans` 11 px w600, `letter-spacing 0.18em uppercase`, `saffron`) + 12 × 12 short-arrow-with-shaft. Tap → `context.go('/library')` (or `/home` if accessed from tab).

### State: loading

   - Pothī header rendered with full title; meta line replaced with `220 × 10 px` shimmer.
   - Sort bar rendered (tabs visible).
   - 3 leaf skeletons (matching leaf padding):
     - Top binding line (rendered in real saffron — visual continuity).
     - 9 px / 150 px shimmer for coord.
     - 14 px / 90% width for Sanskrit.
     - 11 px / 80% + 11 px / 60% for English.
     - No knot-mark (no real bookmark to "tie").
   - Skeleton background: `saffron @ 0.08`, 1.6 s shimmer.

### State: error

   - `ErrorStateWidget` in body slot, retry invalidates `enrichedBookmarksProvider`.

---

## Animations

- **Leaf entry**: `flutter_animate` `.fadeIn(duration: 350.ms).slideY(begin: 0.02, end: 0)`. 25 ms stagger capped at 6 leaves.
- **Sort tab swap**: cross-fade body over 200 ms when active tab changes. Don't push a new screen.
- **Empty illustration**: subtle `slideY(begin: 0.04, end: 0)` + fade on first paint.
- **Knot-mark hover** (web only — desktop test build): no-op for v1.
- **Tap feedback**: `splashColor: transparent`, `highlightColor: saffron @ 0.04`.

---

## Heritage primitives used

| Primitive | Purpose |
|---|---|
| `BindingLine` | Top binding line on each leaf — extract as `_LeafBinding(width)` if not already in heritage_widgets. |
| `WarmBackdrop` | Already in baseline. Use `intensity: 0.6`. |
| `arabicToDevanagari(int)` | Coord numerals (`२·४७`, `१·३·१४`). |
| `DandaCoord` | NOT used here — leaf coord renders without daṇḍa flanks (the dot separator carries the role). |

New primitive to add:
- `_KnotMark` — small saffron diamond + thin vertical thread suggestion. Reuse on bookmark-affordance icons elsewhere later.

---

## Do / don't

✅ **Do**
- Use the word **"Pothī"** (पोथी) in the header. The English subtitle "Your collection" carries semantics for non-readers.
- Show enough Sanskrit incipit to recognize the verse without tapping in (~80 chars / 2 lines).
- Render personal notes prominently — they compound in value over years.
- Render Devanāgarī coord numerals on every leaf.
- Default sort to Recent; show By scripture only when user picks it.
- Empty state teaches *why* the user should bookmark, not just *how*.

❌ **Don't**
- Do not show "BG.1.1" pill chips — coord line carries the location with proper Devanāgarī numerals.
- Do not show a calendar icon next to dates; the date itself is the affordance.
- Do not include a "Delete" or "Edit note" affordance directly on the leaf for v1; tapping the leaf opens verse detail where bookmark/note management already lives.
- Do not animate the leaves in / out beyond entry; saved verses are durable, not transient.
- Do not show a "+" floating action button to add bookmarks; bookmarks are added from verse detail, not from the bookmarks screen.

---

## Acceptance criteria

1. `bookmarks_page.dart` ≤ 500 lines, single canonical leaf widget driven by `EnrichedBookmark`.
2. Two sort modes (Recent, By scripture) wired via `bookmarkSortProvider`; default Recent.
3. Devanāgarī coord renders correctly for 2-level (BG, Manu, MNT) and 3-level (Mbh, BhP, RV, ChU) verse IDs. Verify `२·४७`, `१·३·१४`, `१·१·१`.
4. Personal note rendered with dashed top rule when present; absent rule when not.
5. Empty state with 3-leaf illustration + "Begin reading" CTA navigates to library.
6. Loading state shows 3 leaf skeletons with real binding line.
7. Tapping a leaf navigates to verse detail.
8. Analyzer clean. Widget tests:
   - empty state visible when `enrichedBookmarksProvider` returns `[]`.
   - leaf renders Devanāgarī coord, Sanskrit, English, scripture name, date.
   - personal note rendered when present, hidden when not.
   - sort tabs swap content (Recent vs By scripture).
9. Hit target ≥ 56 px per leaf row.
10. Screen built on `extendBodyBehindAppBar: true` + transparent Scaffold + `WarmBackdrop(intensity: 0.6)`.

---

## Open questions for build phase

- **Filter affordance**: spec includes the icon + label but defers behavior. v1 stub it as a `SnackBar` placeholder; v2 tag/collection management.
- **Note editing**: bookmark notes are edited from verse detail. Confirm this flow already exists in verse_detail_page; add an `Add note` affordance there if missing.
- **Date formatter**: `2 days ago` style for ≤ 30 days, then `dd MMM yyyy` (Lora numerals?). Use `intl` `DateFormat`.
- **Empty illustration**: 3-leaves-on-thread can be `CustomPaint`, layered `Container`s with `Transform.rotate`, or an SVG asset. Cheapest is layered Containers; revisit if it looks fragile.
- **EnrichedBookmark.note field**: verify present on the Drift row + entity. If not, add a nullable string column to `bookmarks_table.dart` + propagate.
