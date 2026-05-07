# Screen Spec — Search

> **Build order:** #7 (after Verse List 05)
> **Mockup file:** `New Design/screen-06-search.html`
> **Routes:** `/search` (push from Library and Today/Home; back to caller)
> **Replaces:** `lib/presentation/features/search/pages/search_page.dart` (already migrated to WarmBackdrop baseline; full rewrite to spec)
> **State management:** Riverpod
> - `searchQueryProvider` — `String` (debounced controller-driven)
> - `searchResultsProvider(query)` — `AsyncValue<SearchResults>` family with grouped scripture results
> - `recentSearchesProvider` — `AsyncValue<List<RecentSearch>>` from SharedPreferences
> - `coordinateMatchProvider(query)` — derived: parses "BG 2.47", "Gita 11.37", "Katha 1.2.18", returns nullable `(scriptureId, chapterNum, verseNum)`
> - `panditAnswerProvider(query)` — `AsyncValue<PanditAnswer>` family (curated prose + cited verses); only fetched on explicit "Ask the Pandit" tap, not on every keystroke

---

## Purpose

Search is the cross-scripture primary affordance. Users arrive with three intents: **find a verse they remember** (phrase or coordinate), **explore a Sanskrit term**, or **ask a question** that needs guidance. The screen serves all three from one input — no upfront filter chips, no taxonomy. Results group by scripture; when a coordinate is detected, the direct match jumps to the top.

The Pandit (AI) is a peer affordance to text search, not an after-thought.

---

## Layout (top to bottom)

1. **Status bar** (system, 44 px)
2. **Search top bar** (`padding 8px 16px 14px`, height ~58 px):
   - **Back chevron** (36 × 36 hit, 20 px stroke icon, `text-1`).
   - **Search field** (flex 1, height 44 px, border-radius 26 px, `1 px solid` border, padding `0 16px`, gap 10 px between children):
     - Magnifier icon left (16 × 16 stroke, `text-3` idle, `saffron` when active/typing).
     - `TextField` flex 1, `Fonts.sans` 14 px, `letter-spacing 0.005em`, no decoration. Placeholder: `Search verse, phrase, or coordinate…` in `text-3`.
     - Clear-X icon right (14 × 14 stroke, `text-3`) — **rendered only when query.isNotEmpty**. Tap clears.
   - Field state: idle (`divider-soft` border, transparent fill) vs active (`saffron @ 0.18` border, `saffron @ 0.06` fill on dark). Animate the border color over 180 ms when focus changes.
3. **Body** swaps based on state:

### State: empty (default + returning users)

A. **Recent section** (`margin-top: 22px, padding: 0 24px 0`, only when `recentSearchesProvider != null && length > 0`; max 5 items):
   - Section label `RECENT` (`Fonts.sans` 9.5 px w600, `letter-spacing 0.28em uppercase`, `text-3`, padding-bottom 12 px). The label has a trailing `flex: 1` 1-px hairline (`divider-soft`) extending to the right edge.
   - Suggest rows (12 px vertical padding, flex `align-items: flex-start`, gap 14 px, `border-bottom: 1px solid divider-soft`):
     - **Icon** (22 × 22, flex-shrink 0, margin-top 2 px) — circular clock outline with hands (history).
     - **Body** (flex 1):
       - **Title** — `Fonts.serif` 14.5 px, line-height 1.35, `text-1`, max 1 line ellipsis. The title can be Devanāgarī (`.deva` variant: `Fonts.deva` 15 px) for Sanskrit-word recents.
       - **Meta** — `Fonts.sans` 10.5 px w500, `letter-spacing 0.04em`, `text-3`. Pattern: `{N} results · {scriptureNames}` or `{N} verses across {M} scriptures` or `{Scripture} {ch}.{verse} — direct`.
     - **Arrow** (8 × 14 chevron-right, opacity 0.4) — flex-shrink 0, margin-top 6 px.
   - Tap a recent → set query, run search.

B. **"Search any way" section** (same `sec` styling, label `SEARCH ANY WAY`):
   - Four suggest rows. **Not selectable** (no `onTap`); they're guidance, not actions.
     1. **By phrase** — three-line icon (text). Meta: `"you have a right to action…"`
     2. **By Sanskrit word** — block-letter "h"-like glyph. Title is Devanāgarī (`.deva`): `कर्म`. Meta: `By Sanskrit word — Devanāgarī or IAST`.
     3. **By coordinate** — small page glyph. Meta: `"BG 2.47" · "Gita 11.37" · "Katha 1.2.18"`.
     4. **By question** — speaker-bubble glyph. Meta: `"What is dharma?" · "How to find peace?"` Last row has no bottom border.

C. **Pandit CTA card** (`margin: 22px 24px 0`, padding `18px 18px 18px 22px`, border-radius 4 px, `1 px solid divider`, gap 14 px):
   - **Glyph** (32 × 32 circle, `Fonts.deva` 16 px) — `ॐ` centered, `saffron` color, `saffron @ 0.12` background.
   - **Body** (flex 1):
     - Label `ASK THE PANDIT` (`Fonts.sans` 9 px w600, `letter-spacing 0.24em uppercase`, `saffron`).
     - Text (`Fonts.serif italic` 13.5 px, line-height 1.4, `text-1`): `Pose a question. Receive guidance with verse citations.`
   - **Arrow** (14 × 14 short-arrow-with-shaft, `saffron @ 70%`, flex-shrink 0).
   - Tap → focus the search field, set placeholder/affordance to "Ask…" mode, OR open a dedicated Pandit page (defer the pandit-mode switch to v2; v1 just focuses the field).

### State: typing — coordinate detected

When `coordinateMatchProvider(query) != null`:
   - **Coord-resolved card** (`margin: 14px 24px 0`, padding `12px 14px 12px 18px`, border-radius 4 px, gap 12 px). Same saffron LeafThread + 90deg gradient as the verse-list resume anchor.
   - **Glyph** (Devanāgarī numeral, `Fonts.deva` 18 px, line-height 1, `cream`/`text-1`) — `२.४७`.
   - **Body** (flex 1):
     - Label `DIRECT MATCH` (`Fonts.sans` 9 px w600, `letter-spacing 0.24em uppercase`, `saffron`).
     - Text (`Fonts.serif` 14 px, line-height 1.3, `text-1`): `**Bhagavad Gītā · Chapter 2 · Verse 47**` (bold within serif via w500).
   - **Arrow** (14 × 14 short-arrow, `saffron`).
   - Tap → `/browse/{scriptureId}/verse/{verseId}`.
   - Below the card: `Or related verses` (results-meta style) + result groups for the scripture's other matches.

### State: typing — results

A. **Results meta** (`padding: 18px 24px 6px`, `Fonts.sans` 9.5 px w600, `letter-spacing 0.24em uppercase`, `text-3`):
   - Pattern: `{N saffron-italic-12} MATCHES ACROSS {M saffron-italic-12} SCRIPTURES`.
   - The numeric tokens are `Fonts.serif italic` 12 px w500, `letter-spacing 0`, no uppercase, `saffron`.

B. **Result group** (`margin-top: 14px`):
   - Header (`padding: 0 24px 10px`, `border-bottom: 1px solid divider`, flex `align-items: baseline justify-content: space-between`):
     - Left: Devanāgarī title (`Fonts.deva` 14 px, `cream`/`text-1`) + space + italic English (`Fonts.serif italic` 11.5 px, `text-2`). Ex: `भगवद्गीता Bhagavad Gītā`.
     - Right: count + `view all` affordance (`Fonts.sans` 9 px w600, `letter-spacing 0.18em uppercase`, `text-3`, `saffron` for "view all" portion). Tappable when count > displayed items.
   - Result rows (`padding: 12px 24px`, flex `align-items: flex-start gap: 14px`, `border-bottom: 1px solid divider-soft`):
     - **Coord mark** (44 px wide, `Fonts.deva` 12 px line-height 1.4, `padding-top: 1px`, flex-shrink 0). Pattern `‖chapter·verse‖` for 2-level (BG, Manu, MNT, BS), `‖book·ch·verse‖` for 3-level (Mbh, BhP, RV, AV, ChU, BĀU, Rām). Use existing `DandaCoord.multipart`.
     - **Body** (flex 1, min-width 0):
       - Sanskrit (`Fonts.deva` 14 px, line-height 1.5, 4 px gap). Match highlighting: matched substring rendered as `TextSpan` with `fontWeight: w500` and `background: saffron @ 0.18`. Single-line ellipsis.
       - English (`Fonts.serif italic` 12 px, line-height 1.45, `text-3`). Match highlighting: same pattern, weight w500 (drop italic on the matched span), `background: saffron @ 0.18`. Single-line ellipsis.
   - Tap a row → `/browse/{scriptureId}/verse/{verseId}`.

C. **View all expansion**: tap "view all" → expand the group inline to show all results from that scripture (collapsed back via second tap on "view all" → "collapse"). Don't push a new screen.

### State: searching

   - Results meta: `Searching across 31 scriptures` + a 3-dot typing indicator (saffron, 4 px dots, 200 ms cycle each, total 600 ms loop).
   - Below: 2 fake group headers (skeleton bars 12 px / 140 px and 9 px / 60 px) with 2 skeleton result rows each (44 × 14 mark + 14 px / 90% body + 11 px / 75% body).
   - Skeleton background: `saffron @ 0.08`, 1.6 s ease-in-out shimmer 0.5 → 0.85 → 0.5 opacity.

### State: Pandit answer

When the user explicitly invokes Pandit and an answer arrives:
   - Replace results body with the `pandit-answer` card (`margin: 18px 24px 0`, padding 22 px, border-radius 4 px, `1 px solid divider`).
   - Header row (gap 10 px, margin-bottom 14 px):
     - Glyph (24 × 24 circle, `Fonts.deva` 13 px, `ॐ`, saffron on `saffron @ 0.12` bg).
     - Title `THE PANDIT SAYS` (`Fonts.sans` 10 px w600, `letter-spacing 0.22em uppercase`, `text-1`).
     - Source label right (`Fonts.sans` 9 px, `letter-spacing 0.16em uppercase`, `text-3`): `AI · GEMINI`.
   - Prose paragraph (`Fonts.serif` 14 px, line-height 1.6, `text-1`).
   - Citations section: `CITED VERSES` label, then `pandit-citation-row`s with daṇḍa-mark coord + italic-serif fragment + 8 × 12 chevron arrow. Each citation is tap-to-verse.

### State: error

   - `ErrorStateWidget` inside the body slot. Header bar stays. Retry invalidates `searchResultsProvider(currentQuery)`.

---

## Animations

- **Search field focus**: border color tween over 180 ms (`Curves.easeOut`).
- **Coord-resolved card**: slides in from top over 200 ms with 0.04 slideY + fade. One-shot per query change.
- **Result rows**: ink-settle 350 ms fade + 0.02 slideY, 18 ms stagger capped at 8 rows per group.
- **Typing indicator**: 3 saffron dots with 200 ms phase offset, 1.2 s loop.

---

## Heritage primitives used

| Primitive | Purpose |
|---|---|
| `LeafThread` | Coord-resolved card left edge (no pulse — the card is transient by design). |
| `DandaCoord` | Result-row coord marks + pandit-answer citation marks. |
| `WarmBackdrop` | Already in baseline. Use `intensity: 0.6`. |
| `arabicToDevanagari(int)` | Coord glyph in coord-resolved card (२.४७). |

---

## Do / don't

✅ **Do**
- Show recent searches above the "search any way" guidance — returning users find them first.
- Detect coordinates eagerly and surface a direct match card before results.
- Group results by scripture; cap each group to 3 rows with a "view all" affordance for high-frequency terms (`dharma` → 87 BG hits).
- Highlight matches in both Sanskrit and English with saffron weight + tint.
- Render Devanāgarī coordinates on cards and rows; consistency with verse list and verse detail.
- Make the Pandit CTA peer-level with text search, not buried below.

❌ **Don't**
- Do not show the All / Sanskrit / English / Hindi filter chips — premature filtering.
- Do not show a magnifying-glass-in-circle empty state illustration; the search bar already communicates emptiness.
- Do not invoke the Pandit endpoint on every keystroke — it costs $ + latency. Only on explicit tap.
- Do not let one common term dominate the result list; cap 3 rows per group + "view all".
- Do not use the `<TextField>`'s default rounded outline — replace with the spec's saffron-bordered pill.
- Do not animate match highlights; the saffron is loud enough.

---

## Acceptance criteria

1. `search_page.dart` driven by ≤ 3 widget classes plus state-specific bodies (Empty, Coord, Results, Pandit, Searching, Error). No filter chips remain.
2. Coordinate detection covers: `BG 2.47`, `Gita 2.47`, `Katha 1.2.18`, `BG.2.47` (dot variant), with case-insensitive scripture aliases (BG, Gita, Bhagavad, Katha, KaU…). Falls through to text search when no match.
3. Search field rounded pill (26 px radius, 44 px height) replaces the old Material outlined input.
4. Match highlighting works on both Sanskrit and English, visible in dark + light.
5. Recent searches persist across app restarts via `SharedPreferences`, capped at 20 entries (display top 5).
6. Pandit endpoint not called until explicit tap; Pandit CTA visible from empty state and from a corner of the typing state.
7. Analyzer clean. Widget tests:
   - empty state: recent rows + 4 intent rows + Pandit CTA visible.
   - coord typing: coord-resolved card visible when query is a recognized coordinate.
   - typing 'dharma': result groups render with daṇḍa coord marks; "view all" affordance shown when group count > 3.
   - clearing query restores empty state.
8. Hit target ≥ 48 px on every tappable element (suggest rows, result rows, coord-resolved card, Pandit CTA, view-all).
9. Screen built on `extendBodyBehindAppBar: true` + transparent Scaffold + `WarmBackdrop(intensity: 0.6)` for visual continuity.

---

## Open questions for build phase

- **Pandit page vs in-search answer**: spec describes both an inline pandit-answer card and a Pandit CTA. v1 ship: keep CTA in empty + typing states; pandit answers render as inline card after tap (no full-page push). Defer dedicated Pandit page until usage data warrants it.
- **`coordinateMatchProvider` regex**: needs to handle Devanāgarī coord input too (`२.४७`). Implement after core ASCII parsing works.
- **Match-highlight performance**: highlighting requires per-result substring scan. Use Drift FTS5 if/when migrated; for v1, do client-side scan over the existing `searchResultsProvider` returns. Cap result body length at ~80 chars to keep highlight fast.
- **"Search across 31 scriptures" string**: hard-code 31 for now; eventually compute from `Scripture.values.length`.
