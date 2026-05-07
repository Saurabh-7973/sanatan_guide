# Screen Spec — Chapter List

> **Build order:** #5 (after Library 03)
> **Mockup file:** `New Design/screen-04-chapter-list.html`
> **Routes:** `/scripture/:scriptureId` (push from Library; back to Library)
> **Replaces:** `lib/presentation/features/scripture_reader/pages/chapter_list_page.dart` (1565 lines, ~12 bespoke layouts)
> **State management:** Riverpod
> - `chapterBrowserProvider(scriptureId)` — list of `ChapterOutline`
> - `chapterReadCountProvider(scriptureId, chapterNum, bookNum)` — int per chapter
> - `lastReadProvider(scriptureId)` — `(chapterNum, verseNum)` or null
> - `scriptureProvider(scriptureId)` — totals (chapters, verses, read)

---

## Purpose

User has chosen a scripture from Library. This screen tells them, in one glance:
1. **Where they were** (resume row, when applicable)
2. **What's inside** (compact title + counts, then full chapter list)
3. **What they've finished** (per-row hairline progress + completed-state fade)

**Designed to disappear.** The chapter list is a junction, not a destination — its job is to get the user back to the verse with one tap. No painted ornament, no large hero illustration, no bottom nav (root tabs hide on push).

---

## Layout (top to bottom)

1. **Status bar** (system, 44 px)
2. **Top bar** (height 50 px, padding `6px 20px 14px`):
   - Back chevron only (36 × 36 hit target, 20 px stroke icon, `text-1` colour). No title text — header below carries identity.
3. **Compact scripture header** (`padding 4px 24px 18px`):
   - **Devanāgarī title** — `Fonts.deva`, 22 px, line-height 1.1, `cream` (dark) / `text-1` (light), `letter-spacing 0.01em`. Ex: `भगवद्गीता`
   - **English subtitle** (4 px gap) — `Fonts.serif italic`, 14 px, `text-2`. Ex: `Bhagavad Gītā · The Song of God`
   - **Counts meta** (8 px gap) — `Fonts.sans`, 10 px w600, `letter-spacing 0.22em uppercase`, `text-3`. Pattern: `{N} CHAPTERS · {N} VERSES · {N} READ`
     - Numeric tokens (`{N}`) are `Fonts.serif italic`, 12 px w500, `letter-spacing 0`, `saffron` colour.
     - Separator is a 3 px saffron dot (`margin: 0 8px 2px`, `vertical-align: middle`).
     - Pluralization: 1 chapter / 1 verse / 0 read all stay legible (no special-case strings).
4. **Resume row** (margin `0 24px 8px`, only when `lastReadProvider != null`):
   - Border-radius 4 px, padding `16px 18px 16px 22px`, `border 1px solid divider`.
   - **Background:** `linear-gradient(90deg, saffron@7%, saffron@2% 60%, transparent)` over `surface` (dark) / `surface` (light at 6% / 1.5%).
   - **Leaf-thread:** 3 px wide saffron rule, `top 12px bottom 12px left 0`, border-radius 2 px. Dark mode adds `box-shadow: 0 0 6px saffron@40%`.
   - **One-time pulse animation** on screen entry (2.4s ease-in-out, `box-shadow` 6→12 px), then static.
   - Body (flex column, `min-width: 0` for ellipsis):
     - **Label** (`Fonts.sans` 9.5 px w600, `letter-spacing 0.24em uppercase`, `saffron`) — `CONTINUE READING`
     - **Title** (`Fonts.deva`, 16 px, line-height 1.2, `cream`/`text-1`, 4 px gap) — last chapter's Devanāgarī title.
     - **Meta** (`Fonts.sans`, 11.5 px, `text-2`, 3 px gap) — `Chapter {N} · verse {V} of {Total}`.
   - **Arrow** (right, opacity 0.6, 14 × 14, `saffron`) — short arrow with extending shaft (`m2,7h10 m8,3 l4,4-4,4`).
   - Tap → `/verse/{scriptureId}/{chapterNum}/{verseNum}` (verse detail, not verse list).
5. **Chapters section** (`margin-top: 18px`, padding `0 24px`):
   - **Section label** (`Fonts.sans` 9.5 px w600, `letter-spacing 0.28em uppercase`, `text-3`, padding-bottom 12 px, `border-bottom 1px solid divider`):
     - Default: `ALL CHAPTERS`
     - Variants by scripture:
       - Bhāgavata Purāṇa, Devī Bhāgavata, Mārkaṇḍeya Purāṇa, Viṣṇu Purāṇa: `ALL CANTOS` / `ALL SKANDHAS` (use canonical English label from `ChapterOutline.unitLabel`).
       - Ṛgveda, Atharvaveda: `ALL MAṆḌALAS` / `ALL KĀṆḌAS`.
       - Yoga Sūtras: `ALL PĀDAS`.
       - Hatha Yoga Pradīpikā: `ALL UPADEŚAS`.
       - Manusmṛti: `ALL ADHYĀYAS`.
       - Brahma Sūtras: `ALL ADHYĀYAS` (book·pada·sūtra remains in row meta).
       - Mahābhārata, Rāmāyaṇa: `ALL BOOKS` (Parva / Kāṇḍa). Sub-units handled at next level (push to a second chapter list scoped by book).
6. **Chapter row** (`padding: 14px 0`, flex row, `border-bottom: 1px solid divider-soft`, `gap: 16px`):
   - Hit target ≥ 56 px overall (row + padding). `:active { opacity: 0.5 }` for tap feedback.
   - **Numeral block** (38 px wide, centered, flex-shrink 0):
     - Devanāgarī numeral — `Fonts.deva`, 22 px, line-height 1, `saffron`. Use `arabicToDevanagari(number)`.
     - Arabic fallback (3 px gap below) — `Fonts.sans`, 9 px w600, `letter-spacing 0.16em uppercase`, `text-3`. Pattern: `CH {N}` (or `SK {N}`, `MD {N}`, `PD {N}` per scripture; from `ChapterOutline.unitCode`).
   - **Body** (flex 1, `min-width: 0`):
     - **Devanāgarī title** — `Fonts.deva`, 16 px, line-height 1.25, `letter-spacing 0.005em`, `cream`/`text-1`. Ex: `अर्जुनविषादयोग`
     - **English title** (2 px gap) — `Fonts.serif italic`, 13 px w500, line-height 1.3, `text-1` (dark) / `text-1` (light). Ex: `The Yoga of Arjuna's Grief`
     - **Meta line** (4 px gap) — `Fonts.sans`, 11 px, line-height 1.4, `text-3`. Pattern:
       - `{verses} verses · ~{minutes} min` — `verses` count is `Fonts.serif italic` 11.5 px `text-2`, padding-right 4 px.
       - When started: append ` · {N} of {Total} read` (the `{N} of {Total}` part is `saffron` w500).
       - When finished: replace with `{verses} verses · complete` (`complete` is `saffron` w500).
     - **Hairline progress** (only when `readCount > 0`, 6 px gap above): 1.5 px track, `divider-soft` background, `saffron` fill at `readCount / total` percent. Border-radius 1 px.
   - **Arrow** (right, flex-shrink 0):
     - Default: 8 × 14 chevron-right, opacity 0.4, `text-3`.
     - Completed (all verses read): 14 × 14 saffron circle with checkmark (replaces chevron). Stroke 1.4 px circle, 1.5 px tick.
   - **Completed row** (`readCount == total && total > 0`):
     - Devanāgarī numeral colour drops to `text-3`.
     - Devanāgarī title colour drops to `text-2`.
     - English title and meta keep their colours.
     - Hairline still rendered at 100 %.
   - **Reading-time computation:**
     - `minutes = (verseCount * 15 / 60).round()` — 15 sec/verse default. Min 1 min.
     - When per-user pace data exists, swap in `userReadPace` (median seconds per verse from telemetry); fall back to default until ≥ 5 verses logged.
7. **Bottom safe area** — 24 px gap before safe-area inset.

---

## States

### Default — first visit (no `lastRead`)
Shows compact header, no resume row, full chapter list. Section label is the scripture's unit label (`ALL CANTOS`, `ALL CHAPTERS`, etc.). No painter, no illustration. Header counts shows `0 read`.

### With resume — partway through
Resume row appears at top with one-time saffron-thread pulse (2.4s, after 60 ms of paint). Chapter that contains last-read verse is the resume target.

### Mid-progress — multiple chapters started/finished
Completed chapters fade to `text-2/text-3`, show 14 × 14 saffron checkmark in arrow position. Started-but-incomplete chapters show hairline progress + ` · {N} of {Total} read` meta. Untouched chapters render plainly.

### Loading
- Header devanāgarī title and English subtitle render at full opacity (we already know the scripture's metadata client-side).
- Counts meta swaps to a 200 × 10 px shimmer skeleton (`saffron @ 8%`, 1.6 s ease-in-out shimmer between 0.5 → 0.85 → 0.5 opacity).
- 5 chapter-row skeletons: `38 px × 36 px` numeral block; body has 14 px (60 % w), 11 px (80 % w), 9 px (40 % w) bars stacked. No arrow.
- No spinner. The shimmer is the loading affordance.

### Error
Use existing `ErrorStateWidget` inside the body slot (below header). Retry invalidates `chapterBrowserProvider(scriptureId)`. Header stays.

### Empty (single-chapter scripture)
For `singleChapter` set (Mandukya, Isha, Kena, Mundaka, Katha, Vishnu Sahasranama, Prashna, Taittiriya, Aitareya, Shvetashvatara, Kaushitaki, Maitrayani) — skip Chapter List entirely; Library navigates straight to Verse List. (Same behaviour as today.)

---

## Animations

- **Ink-settle entry** (`flutter_animate` `.fadeIn(duration: 400.ms).slideY(begin: 0.025, end: 0)`):
  - Stagger by `30 ms × index` (so row N animates at `60 + 30N` ms after build), capped at 8 rows. Rows 9+ render statically.
- **Resume-thread pulse** (one shot, on first build): box-shadow 6 → 12 → 6 px over 2.4 s ease-in-out. Use `AnimationController` (no continuous animation in steady state).
- **Tap feedback:** `Material(InkWell)` on each row + resume; ripple disabled (visual feels wrong with thin rules) — use `splashColor: transparent`, `highlightColor: saffron@4%` instead.

---

## Heritage primitives used

| Primitive | Purpose |
|---|---|
| `BindingLine` | Not used here — chapters use plain divider-soft hairlines. |
| `LeafThread` | Resume row's left edge (3 px saffron rule + glow). Reuse from heritage_widgets. |
| `DandaCoord` | Not on this screen (verse-list only). |
| `arabicToDevanagari(int)` | Renders chapter numerals. Lives in `core/utils/devanagari.dart` (create if missing). |

---

## Do / don't

✅ **Do**
- Use Devanāgarī numerals (१, २, ३...) for chapter numbers — every scripture, no exceptions.
- Keep the header to two lines + counts. The user navigated past "Bhagavad Gita" already — they don't need a title hero.
- Show the per-chapter hairline only when `readCount > 0`. An empty track communicates nothing.
- Surface the resume row at the top whenever `lastRead != null`. It's the primary action.
- Single canonical layout for every scripture; only the unit labels and unit codes change.

❌ **Don't**
- Do not draw the dotted progress strip across the top (the old `_DotLadder` — kill it). The chapter-count line in the header carries the same data more clearly.
- Do not add an empty "Start reading" CTA on first visit. Chapter 1 is the natural first row.
- Do not show the empty bookmark-circle icon (kill the leftover from the old `_ChapterArc`).
- Do not paint a sun arc, mandala, or palm-leaf ornament — the chapter list isn't the design star; verse-detail and home are.
- Do not differentiate scriptures with custom layouts (`_BgChapterList`, `_HYPChapterList`, `_ManuChapterList`, `_MNTChapterList`, etc.) — collapse them all into one widget driven by `ChapterOutline` + `unitLabel/unitCode`. Bespoke is technical debt.
- Do not show reading-time when `verseCount == 0` (e.g. unloaded canto outlines from Mahābhārata) — show only `{verses} verses` until counts come in.

---

## Acceptance criteria

1. `chapter_list_page.dart` shrinks from ~1565 lines to ≤ 350 lines (one canonical widget + `ChapterOutline`-driven row).
2. All 14 + scripture variants render through the same widget — no remaining `switch` on `scriptureId` in the page.
3. Resume row appears within 1 frame when `lastReadProvider` resolves; pulse runs exactly once per page open (not on rebuilds from scroll).
4. Devanāgarī numerals render correctly for chapters > 99 (BG-class scriptures cap at 18; Bhāgavata at 335 chapter ranges across cantos; Ṛgveda mandalas at 10; Mahābhārata books up to 100). Verify २३४, ३३५, १००.
5. Loading skeleton matches mockup row geometry; doesn't reflow when data lands (rows fade in over the same row positions).
6. Analyzer clean. Existing `chapter_list_page_test.dart` (if any) updated; new widget test asserts: (a) resume row visibility, (b) completed state checkmark, (c) skeleton row count = 5.
7. Hit target ≥ 48 px on every row including chapter 18 / canto 12 / mandala 10.
8. Screen built behind `extendBodyBehindAppBar: true` + transparent Scaffold + `WarmBackdrop(intensity: 0.6)` for visual continuity with stripped screens.

---

## Open questions for build phase

- **Verse-jumper for chapters with > 50 chapters** (Bhāgavata Purāṇa Canto 10 = 90 chapters; Mahābhārata Śāntiparva = 365 chapters): does this screen need it, or only Verse List? **Default: only Verse List** — chapter scrolling at 18-90 rows is fine without alpha-scroll. Revisit only if the long-canto frames feel heavy in user testing.
- **`unitLabel` / `unitCode` source of truth:** lives on `ChapterOutline` already? Check `domain/entities/chapter_outline.dart` during build; add fields if absent.
