# Screen Spec — Verse Detail

> **Build order:** #8 (closes the core reading flow: Library → Chapter List → Verse List → **Verse Detail**)
> **Mockup file:** `New Design/screen-02-verse-detail.html`
> **Routes:** `/browse/:scriptureId/verse/:verseId` (push from Verse List, Search results, Bookmarks, Home verse card, AI Chat citations). `verseId` is the `{Code}.{ch}.{v}` form (e.g. `BG.1.1`); the scriptureId path segment is informational. Keep the existing route shape — don't restructure the router for this build.
> **Replaces:** `lib/presentation/features/scripture_reader/pages/verse_detail_page.dart` (1349 lines — full rewrite, gut the chrome)
> **State management:** Riverpod
> - `verseDetailProvider(verseId)` — `AsyncValue<Either<Failure, Verse>>` (exists)
> - `verseExplanationProvider(verseId)` — `Future<VerseExplanation?>` (exists — the cached AI commentary)
> - `verseCommentariesProvider(verseId)` — `Future<List<Commentary>>` (exists — scholarly, separate from AI)
> - `adjacentVerseIdsProvider(verseId)` — `({String? prevId, String? nextId})` (exists)
> - `transliterationEnabledProvider` — `Future<bool>` (exists — persisted toggle)
> - `bookmarkedVerseIdsProvider` / bookmark toggle (exists in bookmarks feature)
> - `font_prefs.fontSizeProvider` — Sanskrit body scale 14–28 px (exists)
> - **NEW** `verseChapterPositionProvider(verseId)` — `Future<({int index, int total})?>` — the verse's 1-based position in its chapter and the chapter's verse count, for the progress rail. Null when unknown (e.g. API-only Gītā with no local chapter rows → fall back to `BhagavadGitaChapters`).

---

## Purpose

The verse is the destination. Everything before this screen was navigation; this is where the user *reads*. The Sanskrit verse sits inside a **palm-leaf** — top and bottom binding lines, folio margins — and that leaf is the whole reading surface. Translation flows below as book prose, not a quote-card. Tapping a Sanskrit word reveals its meaning in a callout while the rest of the page dims. "Explain this verse" is the natural next layer: a specific contextual question, not a generic "Ask AI" button — it expands into a Commentary card, or routes into AI Chat for follow-ups.

**Kill the chrome.** The old screen had: an orange flower-yantra, a "BG" bubble, a "Translation on" pill, a vertical "BHAGAVAD GITA" ribbon, a "CH 1 V 1" stack, a bottom verse label, a bottom edit pencil, a gutter rail, a SanctumCard, share-card scaffolding. Almost none of it carried information. The verse coordinate moves *inside* the leaf as inscriptional small-caps. The bottom utility bar consolidates Translation-switcher / Listen / Notes / prev / next into one strip.

---

## Layout (top to bottom)

1. **Status bar** (system, 44 px). Screen built behind it: `extendBodyBehindAppBar: true`, transparent `Scaffold`, `WarmBackdrop(intensity: 0.6)`.
2. **Top bar** (`padding: 6px 20px 14px`, flex space-between, vertically centered):
   - **Back chevron** (left, 36 × 36 hit, 20 px stroke `M12 4l-6 6 6 6`). `context.canPop() ? pop() : go('/browse')`.
   - **Context block** (center, `flex: 1, text-align: center`):
     - **Scripture title** — `Fonts.serif italic`, 15 px w500, line-height 1, `text-1`. Ex: `Bhagavad Gītā`.
     - **Chapter coord** (4 px gap below) — `Fonts.deva` for the Devanāgarī chapter name when known (e.g. `अर्जुनविषादयोग`), else `Fonts.sans` 10 px w600 `letter-spacing 0.22em uppercase` `text-3`. Loading state shows `LOADING VERSE`.
   - **Actions** (right, flex, gap 4 px):
     - **Bookmark toggle** (36 × 36 hit, 18 px glyph). Filled saffron path `M4 2h10v15l-5-3.5L4 17V2z` when bookmarked; same path stroked `text-1` 1.6 px when not. Tap toggles + light haptic. Optimistic.
     - **Share** (36 × 36 hit, 18 px) — three-circle share glyph (`M5.7 8l6.6-3M5.7 10l6.6 3` + 3 circles r2). Tap → system share sheet with verse text + coord (`Bhagavad Gītā 1.1` + Sanskrit + English + attribution). Plain text share; **no rendered share-card** — that scaffolding (`share_card_generator.dart`, `share_card_widget.dart`) is deleted.
3. **Progress rail** (`margin: 0 24px 12px`, flex, `align-items: center, gap: 10px`, `Fonts.sans` 9.5 px w600 `letter-spacing 0.16em uppercase` `text-3`):
   - Left: `{index} / {total}` (Arabic). Ex: `1 / 47`.
   - Center: hairline track, `flex: 1, height: 1px`, `divider-soft` background, `saffron` fill width = `index / total`.
   - Right: `{percent}%` rounded (e.g. 1/47 = 2.1 % → `2%`).
   - **Hidden entirely** when `verseChapterPositionProvider` is null (single-verse scriptures, unknown position) — don't render a broken rail.
4. **Scrolling content** (`screen-content`, fills remaining height above util bar):
   - **The leaf** (`margin: 8px 24px 0, padding: 28px 4px 24px, position: relative`):
     - **Top binding line** — `BindingLine` heritage primitive at `top: 0`, full width inside the leaf. Saffron-faded rule + 6 × 6 rotated diamond at center. Dark mode: diamond glows (`box-shadow 0 0 6px saffron@40%`).
     - **Bottom binding line** — same, at `bottom: 0`.
     - **Verse coordinate** (`text-align: center, margin-bottom: 22px`, `Fonts.sans` 10 px w600 `letter-spacing 0.28em uppercase` `saffron`): `Chapter {roman} · Verse {N}`. Ex: `Chapter I · Verse 1`. Roman numerals for the chapter; Arabic for the verse. (Optional trailing `.frac` part — `Fonts.serif` 11 px, separated by a 1 px × 12 px divider — reserved for ranged verses like `1.16–1.18`; render only when the verse spans multiple numbers.)
     - **Sanskrit verse** (`Fonts.deva`, base 24 px scaled by `fontSizeProvider`, `line-height: 1.95`, `text-align: center`, `letter-spacing 0.005em`, `cream`/`text-1`, `padding: 0 6px`):
       - Rendered as a `Wrap`/`RichText` of tappable **word spans** (split on whitespace; punctuation `।` `॥` `।।` stays attached to the preceding word or rendered as its own non-tappable span). Source: `verse.sanskrit`, stripped of Vedic svara accents for the reading pass (`stripVedicAccents`).
       - **Tapped word:** the word turns `saffron` with a 1.5 px saffron underline; the rest of the screen (transliteration + translation + explain trigger) dims to `opacity: 0.45`; a **word callout** appears anchored below the word.
   - **Word callout** (only when a word is selected; absolutely positioned within the leaf or as an `OverlayPortal`):
     - Width 220 px, `padding: 14px 18px`, `background: surface-2`, `border: 1px solid divider`, `border-radius: 4px`, `box-shadow: 0 8px 24px black@50%`. Small upward caret (8 px rotated square, border-left+top `divider`) pointing at the word.
     - **Devanāgarī word** — `Fonts.deva` 18 px `cream`/`text-1`.
     - **IAST transliteration** (4 px gap) — `Fonts.serif italic` 12 px `saffron`. Ex: `dharma-kṣetre`.
     - **Meaning** (8 px gap) — `Fonts.serif` 13 px `text-2`, line-height 1.5.
     - **Grammar tag** (`margin-top: 10px, padding-top: 10px, border-top: 1px dashed divider-soft`) — `Fonts.sans` 9 px w600 `letter-spacing 0.2em uppercase` `text-3`. Ex: `noun · locative · neuter`. Only when grammar metadata exists on the `WordMeaning`.
     - Source: match the tapped word against `verse.wordMeanings` (by surface form, then by prefix). **No match → no callout** (don't show an empty box). Tap anywhere outside → dismiss, un-dim.
   - **Transliteration section** (`margin: 32px 24px 0`, only when `transliterationEnabledProvider == true` AND `verse.transliteration != null`):
     - **Section rule** — flex `[line — LABEL — line]`, `gap: 12px, margin-bottom: 14px`. Lines: `flex: 1, height: 1px, divider`. Label: `Fonts.sans` 9.5 px w600 `letter-spacing 0.28em uppercase` `saffron` — `Transliteration`.
     - Body: `Fonts.serif italic` 14 px `line-height 1.75 text-align: center text-2`, `padding: 0 8px`. IAST text with line breaks preserved (or `||1-1||` style danda markers from source).
   - **Translation section** (`margin: 32px 24px 0`):
     - Same section rule, label `Translation`.
     - Body: `Fonts.serif` (regular, **not** italic) 16 px `line-height 1.7` **`text-align: left`** `text-1`, `padding: 0 8px`. Flowing prose — Geeta Press / Chinmaya convention, reads like a book, not a quote card. Source: **`verse.english`** (note: `verse.translation` holds the *translator id* — e.g. `griffith`, `sivananda` — **not** the translation text; map it to a display name for the attribution row, don't render it as prose). Wrap any quoted dialogue in standard double-quotes if the source uses them.
     - **Attribution** (`margin-top: 12px`, `Fonts.sans` 10 px w500 `letter-spacing 0.18em uppercase` `text-align: right text-3`, `padding-right: 8px`): `— {translator display name}` derived from `verse.translation`. Ex: `sivananda` → `— Swami Sivananda`. Omit the row if no translator metadata.
   - **Explain trigger** (`margin: 24px, padding: 16px 20px, border-radius: 4px, border: 1px solid divider, background: linear-gradient(180deg, saffron@4%, transparent)`, flex `align-items: center, gap: 14px`, `:active { opacity: 0.6 }`) — shown **only when no cached `VerseExplanation` exists** for this verse:
     - **Glyph** (32 × 32 circle, `background: saffron-glow`, `Fonts.deva` 16 px `saffron`, centered): `ॐ`.
     - **Body** (`flex: 1, min-width: 0`):
       - **Label** — `Fonts.sans` 9 px w600 `letter-spacing 0.24em uppercase` `saffron` — `EXPLAIN THIS VERSE`.
       - **Question** (2 px gap) — `Fonts.serif italic` 14 px `text-1`. A *specific* contextual one-liner about this verse — not "Ask AI about this verse". Generated from a per-verse hook or a templated question (`Why does {scripture} {coord}…?` / `What does {first key word} mean here?`). Build phase: ship a small templated generator keyed off the verse coord + first `wordMeaning`; the curated-question content task is a follow-up. Ex: `Why does the Gītā begin here, with a blind king's question?`
     - **Arrow** (right, 8 × 14 chevron `M1 1l6 6-6 6`, `text-3`).
     - Tap → start AI explanation: optimistically swap the trigger for the **explain card** in `thinking` state, call `GeminiService`, persist the result via `verseExplanationProvider`'s repo on success.
   - **Explain card** (`margin: 24px, padding: 22px, border-radius: 4px, border: 1px solid divider, background: surface, position: relative`) — shown when a `VerseExplanation` exists OR is in flight:
     - **Header** (flex `align-items: center, gap: 10px, margin-bottom: 14px`):
       - **Glyph** (24 × 24 circle, `saffron-glow` bg, `Fonts.deva` 13 px `saffron`): `ॐ`.
       - **Title** — `Fonts.sans` 10 px w600 `letter-spacing 0.22em uppercase` `saffron` — `COMMENTARY`.
       - **Source** (`margin-left: auto`) — `Fonts.sans` 9 px `letter-spacing 0.16em uppercase` `text-3` — `AI · GEMINI`.
     - **Prose** — `Fonts.serif` 14.5 px `line-height 1.72` `text-1`. Paragraphs separated by 12 px. Render Markdown-ish: `*emphasis*` → italic (used for transliterated terms like *dharmakṣetre*). Source: `VerseExplanation.explanationText`.
       - **Thinking state:** last paragraph is `[muted text "Reflecting on this verse"]  [AIThinkingDots]` — reuse the `AIThinkingDots` heritage primitive (5×5 px, 4 px gap, 1.4 s pulse, 0.2 s phase offset). Streamed tokens append before the dots; dots removed when stream completes.
     - **Follow-ups** (`margin-top: 18px, padding-top: 16px, border-top: 1px dashed divider-soft`, flex column gap 8 px) — only after the explanation is complete:
       - **Label** — `Fonts.sans` 9 px w600 `letter-spacing 0.22em uppercase` `text-3, margin-bottom: 4px` — `ASK FURTHER`.
       - **Chips** — each `Fonts.serif italic` 13 px `padding: 8px 12px, border: 1px solid divider-soft, border-radius: 4px, text-2`, `:active { opacity: 0.6 }`. 2–3 chips of suggested follow-up questions (from the explanation payload, or templated). Tap → route into **AI Chat** (`/browse/{scriptureId}/verse/{verseId}/chat` (with the seed question passed via `extra`)) with this verse anchored — AI Chat is the only place follow-up conversations happen (per MASTER_CONTEXT §6.4). The back stack preserves this screen.
   - **Bottom spacer** — 8 px (default/AI states) so the last element clears the util bar shadow.
5. **Bottom utility bar** (`flex-shrink: 0`, NOT scrolling; `margin: 8px 20px 16px` + safe-area bottom inset, `padding: 6px, border-radius: 32px, background: surface`, flex `align-items: center, gap: 4px`):
   - **Prev** (`flex: 0 0 44px, height: 44px`, chevron `M10 3l-5 5 5 5`). Disabled (`opacity 0.4`, `text-3`, no tap) when `adjacentVerseIds.prevId == null`. Tap → navigate to prev verse **in place** (replace, don't push — keep back stack shallow). Light haptic.
   - **Translation switcher** (`flex: 1, height: 44px`, eye glyph + label `Translation`, `Fonts.sans` 11 px w500 `letter-spacing 0.06em`). Tap → toggle `transliterationEnabledProvider` (shows/hides the transliteration section). When on, the button gets `.primary` styling: `background: saffron-glow, color: saffron`. (v1: only the IAST transliteration toggle lives here — the multi-translator picker is a later content task; if multiple translators exist, this becomes a bottom sheet, but ship the toggle now.)
   - **Listen** (`flex: 1, height: 44px`, clock/play glyph + label `Listen`). Audio playback of the verse recitation. Build phase: **stub** — if no audio asset for the verse, render disabled (`opacity 0.4`); wire TTS or bundled recitation later. Don't fake it.
   - **Notes** (`flex: 1, height: 44px`, chevron-down glyph + label `Notes`). Tap → bottom sheet with a `TextField` bound to `verse.noteText`; save persists via the notes DAO. If a note exists, the label/glyph render `saffron`.
   - **Next** (`flex: 0 0 44px, height: 44px`, chevron `M6 3l5 5-5 5`). Disabled when `adjacentVerseIds.nextId == null`. Tap → next verse in place. Light haptic.
   - **Swipe affordance:** horizontal swipe on `screen-content` → prev/next verse (same as the util-bar arrows). Two faint 3 px × 36 px `divider`-coloured vertical hints at the screen left/right edges, `opacity 0.4`, only when prev/next exists in that direction.
   - **Read-tracking:** the verse counts as "read" after ≥ 3 s on this screen (per MASTER_CONTEXT §6 streak rule). Increment `verses_read(verse_id, first_read_at)`; bump the daily streak on the first verse-read of the day. (Keep the existing `StreakService` wiring — just don't let the rewrite drop it.)

---

## States

### Default — verse loaded, no AI commentary yet
Top bar with title + coord. Progress rail. Leaf with binding lines, coord, Sanskrit. Transliteration section only if the toggle is on. Translation prose + attribution. Explain trigger at the bottom. Util bar fully active.

### Word tapped
A Sanskrit word is `saffron` + underlined; everything below the leaf is `opacity 0.45`; the word callout floats below the tapped word. Tap-away dismisses.

### AI commentary — cached
No explain trigger. Leaf renders **compressed**: `padding-top: 20px, padding-bottom: 18px`, Sanskrit at `font-size: 18px, line-height: 1.7` (independent of the reading-scale slider — this is the "context, not focus" size). Explain card with header, prose, follow-up chips.

### AI thinking
Same compressed leaf. Explain card with header + partial/streaming prose; final line is `Reflecting on this verse …` + `AIThinkingDots`. No follow-up chips yet. Util bar stays active (the user can still navigate away).

### Loading
- Top bar: scripture title shows if known from the route/previous screen (we usually do — the verse list passed `scriptureId`); coord shows `LOADING VERSE`.
- Progress rail **hidden** (we don't know position yet).
- Leaf: binding lines render; coord is a 140 × 10 px shimmer bar; Sanskrit is four shimmer bars (~80 %, 90 %, 75 %, 85 % width, 18 px tall, 18 px gap, centered).
- Transliteration + Translation sections: section rules render with their labels; bodies are 2–3 shimmer bars.
- Explain trigger not rendered.
- Util bar: prev/next active (we have adjacent IDs from the route), Translation/Listen/Notes disabled.

### Error
- Top bar with scripture title + `अर्जुनविषादयोग`-style coord if known.
- **Error banner** (`margin: 32px 24px 0, padding: 22px, border-radius: 4px, text-align: center, border: 1px dashed iron-red, background: iron-red@6%`):
  - Glyph: 36 × 36 circle, `iron-red@12%` bg, `Fonts.deva` 18 px `iron-red`, `!`.
  - Title: `Fonts.serif italic` 15 px `text-1` — `This verse couldn't be loaded`.
  - Body: `Fonts.sans` 12 px `text-2`, line-height 1.5 — `The text might be missing from your offline library. You can retry, or return to the chapter.`
  - Retry: `Fonts.sans` 11 px w600 `letter-spacing 0.2em uppercase` `saffron` — `↻  Try again`. Invalidates `verseDetailProvider(verseId)`.
- **"Or read instead" fallback** (`margin: 24px, text-align: center`): label `OR READ INSTEAD` (`Fonts.sans` 11 px `letter-spacing 0.18em uppercase` `text-3`), then 1–2 rows (`padding: 14px 18px, border: 1px solid divider-soft, border-radius: 4px`, flex space-between):
  - Next verse in chapter (if adjacent ID known): title `{scripture} {ch}.{v+1}` + subtitle = its incipit/coord name.
  - Return to chapter: title `Return to chapter` + subtitle `{chapter name} · {N} verses`. Tap → pop to verse list.
  - Both have a `text-3` chevron `M1 1l6 6-6 6` on the right.
- `iron-red` here is the *only* place destructive/failure colour appears on this screen (MASTER_CONTEXT §11). Use `dIronRedBright` (#D17048) for the **text** in dark mode, `dIronRed` only for the border.
- Util bar: prev/next active, others disabled.

---

## Animations

- **Ink-settle entry** for the verse, cascading down the leaf and sections:
  - Sanskrit: `.fadeIn(700.ms, delay: 100.ms).slideY(begin: 0.02, end: 0)`.
  - Transliteration body: same, `delay: 250.ms`.
  - Translation body: same, `delay: 380.ms`.
  - The verse "settles like ink on the folio." Don't animate the binding lines or coord — they're the frame, they're just there.
- **Word callout:** `.fadeIn(160.ms).scaleXY(begin: 0.96, end: 1, alignment: Alignment.topCenter)`. Dim transition on the rest of the page: 200 ms.
- **Leaf compress** (when AI card appears): animate `padding` + Sanskrit font-size over 250 ms `Curves.easeOut` — the leaf gracefully yields focus to the commentary.
- **AI thinking dots:** the `AIThinkingDots` primitive (don't re-implement the pulse).
- **Verse navigation (prev/next/swipe):** cross-fade the leaf + sections (150 ms out, 150 ms in) — not a slide; the leaf stays put, only the text changes. Keeps the "same folio, turning" feel.
- **Tap feedback:** `splashColor: transparent, highlightColor: saffron@4%` on all tappable rows (consistent with Chapter/Verse List).

---

## Heritage primitives used

| Primitive | Purpose |
|---|---|
| `BindingLine` | Top + bottom edges of the leaf. |
| `AIThinkingDots` | Explain-card thinking state. |
| `DandaCoord` | **Not used here** — daṇḍa punctuation in the Sanskrit (`।` `॥`) is part of `verse.sanskrit`, rendered inline as plain text, not a separate widget. |
| `LeafThread` | Not used on this screen — the binding lines do the framing job; reserve `LeafThread` for resume-anchors elsewhere. |
| `WarmBackdrop` | Page background, `intensity: 0.6`. |
| `arabicToDevanagari(int)` | Only if a Devanāgarī verse numeral is shown anywhere; the coord uses Roman+Arabic, so likely unused. |

---

## Do / don't

✅ **Do**
- Make the leaf the whole reading surface — binding lines top and bottom, folio margins, Sanskrit centered inside it.
- Put the verse coordinate *inside* the leaf as inscriptional small-caps (`Chapter I · Verse 1`). It is the heritage signal; nothing else needs to be.
- Make Sanskrit words individually tappable; reveal Devanāgarī + IAST + meaning + grammar in a callout; dim the rest of the page to 45 % while a word is selected.
- Left-align the translation as flowing serif *prose* with a translator attribution — book, not quote-card.
- Treat "Explain this verse" as a *specific* contextual question, and route follow-ups into AI Chat (the single chat surface).
- Compress the leaf (smaller Sanskrit, tighter padding) when the AI commentary card is shown — context yields to focus.
- Consolidate Translation-toggle / Listen / Notes / prev / next into the single bottom utility bar.
- Keep the ≥ 3 s read-tracking + streak increment working through the rewrite.
- Keep the existing route shape (`/browse/:scriptureId/verse/:verseId`) and the `.../chat` child route; don't restructure the router.

❌ **Don't**
- No orange flower-yantra, mandala, sun arc, or any large illustration. The leaf is the design.
- No "BG" bubble, no vertical "BHAGAVAD GITA" ribbon, no "CH 1 V 1" stack, no "Translation on" pill, no bottom verse label, no bottom edit pencil, no gutter rail, no `SanctumCard`. Delete `gutter_rail.dart`, `sanctum_card.dart`, `share_card_widget.dart`, `share_card_generator.dart` if nothing else imports them.
- Don't center the translation. Centered = quote-card. Left-aligned prose = scripture book.
- Don't show the explain trigger when a `VerseExplanation` is already cached — show the card.
- Don't show an empty word callout when the tapped word has no `WordMeaning` match — just don't open one.
- Don't render the progress rail when position is unknown — a `? / ?` rail is worse than no rail.
- Don't push a new route for prev/next — replace in place. The back stack should return the user to the verse list, not walk them backwards verse by verse.
- Don't build a rendered/screenshot share-card. Plain-text system share only.
- Don't fake the Listen button — disable it until real audio exists.
- Don't apply the reading-scale slider to the *compressed* leaf Sanskrit (18 px is fixed in the AI-commentary state).
- Don't use `iron-red` anywhere except the error banner.

---

## Acceptance criteria

1. `verse_detail_page.dart` ≤ ~450 lines. Single canonical layout for every scripture, driven by `Verse` + `Scripture.shortCode` — no `switch` on scripture for layout.
2. The leaf renders with `BindingLine` top and bottom and the coord inside it; no painter, no decorative illustration anywhere on the screen.
3. Tapping a Sanskrit word with a matching `WordMeaning`: word turns saffron + underlined, page below dims to 0.45, callout appears with Devanāgarī / IAST / meaning (and grammar tag iff metadata present). Tapping outside dismisses and un-dims. Tapping a word with no match opens nothing.
4. Translation renders left-aligned, `Fonts.serif` regular, 16 px, with `— {translator}` right-aligned below when translator metadata exists.
5. Reading-scale slider (`fontSizeProvider`) scales the *default-state* Sanskrit between 14 and 28 px; the *AI-commentary-state* Sanskrit stays 18 px regardless.
6. Explain trigger present iff no cached `VerseExplanation`; tapping it shows the explain card in thinking state with `AIThinkingDots`, then the completed prose + 2–3 follow-up chips; tapping a chip routes to `/browse/{scriptureId}/verse/{verseId}/chat` with this verse anchored.
7. Progress rail shows `index / total` + `percent%` when `verseChapterPositionProvider` resolves non-null, and is absent otherwise. Verify Gītā 1.1 → `1 / 47 · 2%`.
8. Bottom utility bar: prev/next disabled (40 % opacity, no tap) at chapter/scripture boundaries; Translation toggle flips the transliteration section and gets `.primary` styling when on; Listen disabled when no audio asset; Notes opens an editable note sheet and renders saffron when a note exists.
9. Horizontal swipe on the content navigates prev/next (in place), matching the util-bar arrows; faint edge hints appear only when navigation in that direction is possible.
10. ≥ 3 s dwell marks the verse read and bumps the streak on the day's first read (regression-test the `StreakService` call still fires).
11. Loading state matches mockup geometry (coord shimmer, 4 Sanskrit bars, section-rule labels visible, util bar prev/next active) and doesn't reflow when data lands. Error state shows the iron-red banner + retry + "or read instead" rows.
12. Analyzer clean. Widget test asserts: (a) word-tap → callout + dim, (b) explain trigger hidden when explanation cached, (c) prev disabled at first verse / next disabled at last, (d) translation is left-aligned & non-italic, (e) progress rail absent when position unknown.
13. Screen built behind `extendBodyBehindAppBar: true` + transparent `Scaffold` + `WarmBackdrop(intensity: 0.6)`.

---

## Open questions for build phase

- **Word splitting & matching:** `verse.sanskrit` is a multi-line string with `।`/`॥` daṇḍas and `<br>`-equivalent newlines. Split on Unicode whitespace; keep daṇḍas as their own non-tappable spans. Match a tapped surface form against `WordMeaning.word` exactly, then by stripped-sandhi prefix. **Default:** exact match only for build #8; fuzzy/sandhi matching is a follow-up. Words with no match are still styled as normal text (not tappable-looking).
- **`verseChapterPositionProvider`:** new provider — for local verses, `getVersePositionInChapter(scriptureId, chapterNum, verseNum)` via the DAO (count of verses with smaller `verseNum` + chapter total). For API-only Gītā, derive from `BhagavadGitaChapters.byNumber(ch).verseCount` and `verseNum`. Return null for single-unit scriptures (Yoga Sūtra padas? — verify) where a "chapter" isn't meaningful.
- **Explain question generator:** templated for build #8 (`String explainQuestion(Verse v)` in `core/utils/`). Curated per-verse hooks (a small JSON, Gītā first) are a content follow-up.
- **Notes sheet:** there's an existing notes DAO + `verse.noteText` — verify the wiring and reuse; don't rebuild the persistence.
- **Audio (`Listen`):** no audio assets bundled yet. Ship the button disabled; design the asset path convention (`assets/audio/{scriptureCode}/{ch}_{v}.mp3`?) but don't implement playback in build #8.
- **`reading_mode_provider`:** the old screen had a reading-mode toggle (focus mode?). Confirm whether the new util bar absorbs it or it's dropped — likely dropped; the leaf *is* the focus mode.
