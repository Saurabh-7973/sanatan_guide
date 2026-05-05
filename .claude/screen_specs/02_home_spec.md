# Screen Spec — Home (Today)

> **Build order:** #3 (after onboarding)
> **Mockup file:** `New Design/screen-01-home.html`
> **Routes:** `/home` (root tab — bottom nav: Today)
> **State management:** Riverpod
> - `homeGreetingProvider` (time-aware greeting)
> - `panchangProvider` (today's panchang line)
> - `verseOfDayProvider` (AsyncValue<Verse>)
> - `continueReadingProvider` (AsyncValue<ReadingProgress?>)
> - `learningPathProvider` (AsyncValue<NextModule?>)
> - `nextFestivalProvider` (AsyncValue<Festival?>)

---

## Purpose

The Today screen. One opens the app and sees: where the cosmos is right now (panchang), today's verse to read, where to continue, the next learning module, and the upcoming festival. **No sunrise illustration, no deity images, no card decoration.** The Panchang and the Sanskrit verse are themselves the visual heritage.

---

## Layout (top to bottom)

1. **Status bar** (system, 44 px)
2. **Greeting block** (`paddingTop: 12`, centered):
   - Greeting line — `AppText.subtitle` italic serif, 17 px
     - Time-aware: "Shubh Prabhat, {name}" (5–11 AM), "Namaste, {name}" (11–17), "Shubh Sandhya, {name}" (17–21), "Shubh Ratri, {name}" (21–5)
     - First-day variant: "Welcome, {name}"
     - **No name fallback:** if no name (we don't collect one in onboarding) → "Shubh Prabhat" (single string, no comma)
   - Panchang line (Devanāgarī, `Fonts.deva`, 14 px, letter-spacing 0.06em, centered):
     `वैशाख · शुक्ल त्रयोदशी · गुरुवार`
     - Separator dots are 4 px saffron circles
   - Vikram Samvat line (5 px below panchang, `Fonts.sans`, 11 px, letter-spacing 0.16em, uppercase, saffron):
     `VIKRAM SAMVAT 2083`
     - First-day variant: `DAY ONE · VS 2083`
   - **Incised rule** below (18 px top margin) — 88 px wide hairline + center diamond (5 px, rotated 45°, saffron)
3. **Verse hero card** (28 px top margin, full-bleed within 24 px content padding):
   - Border-radius 4 px, padding `28px 22px 26px`
   - **Background (dark):** linear-gradient + `dSurface`, plus `inset` 1 px saffron-glow on top
   - **Background (light):** repeating 3 px palm-leaf grain stripe + `lSurface`, plus 1 px saffron border inset
   - **Top binding-line** at 14 px from top (use `BindingLine` widget from `heritage_widgets.dart`)
   - **Bottom binding-line** at 14 px from bottom
   - **Verse meta** (centered, saffron, `Fonts.sans` 10 px w600, letter-spacing 0.22em uppercase):
     `❁  Bhagavad Gītā · 11 · 37  ❁`
     - The two `❁` are pushpikā glyphs at 12 px (saffron-deep on dark; iron-red on light)
     - **First-day variant:** meta reads `❁  Your first verse  ❁`
   - **Sanskrit verse** (22 px margin top, `Fonts.deva`, 22 px, line-height 1.85, centered, `dCream`/`lText1`)
     - Each pāda on its own line
     - End with `॥` daṇḍa
   - **Verse divider** (22 px margin top + bottom): hairline 24 px — small-caps "TRANSLATION" in saffron — hairline 24 px
     - First-day variant: replace label with source attribution (e.g. `Taittirīya Up. 2.1`)
   - **Translation** (`AppText` italic serif, 14.5 px, line-height 1.65, centered, `dText2`/`lText2`)
   - **CTA row** (22 px margin top, centered, saffron): `Read full verse →` (sans 12 px w600, letter-spacing 0.16em uppercase)
     - First-day variant: `Begin reading →`
   - **Animations on entry:**
     - Sanskrit fades up: 700 ms, delay 100 ms, ease-out
     - Translation fades up: 700 ms, delay 300 ms
     - CTA fades up: 700 ms, delay 500 ms
4. **Continue Reading strip** (24 px margin top, only if user has progress):
   - Padding `14px 18px`, radius 4 px, `dSurface` + 1 px `dDividerSoft`
   - Left: 38 px circular icon — saffron-glow background, saffron book/bookmark glyph
   - Body:
     - Label: small-caps `Continue · 2 day streak` (sans 9.5 px w600, letter-spacing 0.22em, `dText3`)
     - Title: `Bhagavad Gītā · 1.2` (`AppText.moduleTitle` 15 px serif w500, `dText1`)
     - Progress beads row (6 px margin top): 8 beads, each 12×2 px, 4 px gap; filled = saffron, empty = `dDividerSoft`
   - Right: chevron arrow 8×14, `dText3`
   - Tappable → routes to `/scripture/{id}/verse/{verseId}`
5. **Your Path strip** (next module, same shell as Continue strip):
   - Icon glyph: upward arrow / mountain (path metaphor)
   - Label: `Your Path · Foundations`
   - Title: e.g. `The Five Core Concepts` (14 px in this strip)
   - Meta line: `Fonts.sans` 12 px, `dText2` — `10 min · module 2 of 8`
   - Tappable → routes to `/learning/module/{id}`
6. **Festival pill** (18 px margin top):
   - Padding `14px 18px`, radius 4 px, `dSurface` + 1 px `dDividerSoft`
   - Left side:
     - 22 px moon glyph — radial gradient `#F2E5CE → #D4B896 → #6e5641` on dark; `#fff8eb → #d9c39a → #8a6e44` on light. Plain `Container` w/ `BoxDecoration(gradient: RadialGradient, shape: BoxShape.circle)`.
     - Festival name: italic serif 14 px — `<Devanāgarī tag in Fonts.deva 13px saffron, 8 px right margin>` `Guru Pūrṇimā`
   - Right side: small-caps `90 DAYS` (sans 11 px w500, letter-spacing 0.18em, `dText3`)
   - Tappable → routes to `/festivals` with that festival highlighted
7. **Bottom spacer** (24 px)
8. **Bottom nav** (managed by `ScaffoldWithNavBar`, do not duplicate inside this screen)

---

## States

### Default
All providers `AsyncData`. Render full layout above.

### Loading (any of: panchang, verseOfDay, continue, path)
- Greeting line still renders (deterministic, no fetch needed)
- Panchang line replaced by `Skeleton` (height 12 px, width 180 px, shimmer 1.6 s ease-in-out, 50% → 85% → 50% opacity)
- Verse card structure renders (binding-lines visible) but inside:
  - Verse meta replaced by skeleton (10 px × 140 px) between two `❁`
  - Sanskrit lines: 4 skeleton rows alternating widths (medium 85%, short 60%, medium 85%, short 60%, height 16 px each, 12 px gap)
  - Translation block: 3 skeleton rows (10 × 70%, 10 × 70%, 10 × 50%, centered)
- Continue strip + Path strip render with `opacity: 0.6 / 0.4`, icon replaced by skeleton circle 38×38, body replaced by 2 skeleton rows
- **Festival pill is hidden during loading** (don't reserve space)

### Error — verse-of-day fetch failed
- Greeting + panchang still render normally (panchang doesn't depend on verse fetch)
- Replace verse card with `error-banner`:
  - 32 px margin top, 18×22 padding, radius 4 px, dashed 1 px `dIronRed` border, `rgba(184,90,58,0.06)` background fill, centered
  - 32 px iron-red glyph circle on top with `!` in `Fonts.deva` 18 px
  - Title (italic serif 15 px, `dText1`): `Today's verse couldn't be retrieved`
  - Body (sans 12 px, `dText2`, line-height 1.5): `Your library is intact. The daily selection just needs another moment.`
  - Retry button (sans 11 px w600, letter-spacing 0.2em uppercase, saffron): `↻  Try again` — tap re-invokes `verseOfDayProvider`
- Continue + Path + Festival pill **still render** below the banner. Failure of one provider does not blank the screen.

### First-time / Day One (no continue progress, onboarding just finished)
- Greeting line: `Welcome, {name}`
- VS line: `DAY ONE · VS 2083`
- Verse meta: `❁  Your first verse  ❁`
- Verse text uses Taittirīya Upaniṣad śānti mantra:
  ```
  ॐ सह नाववतु ।
  सह नौ भुनक्तु ।
  सह वीर्यं करवावहै ॥
  ```
- Sanskrit size override: 23 px (one notch larger; this is a ceremonial moment)
- Divider label: `Taittirīya Up. 2.1` (italic serif source line, replaces "TRANSLATION" small-caps)
- Translation: `May we be protected together. May we be nourished together. May we work together with great vigour.`
- CTA: `Begin reading →`
- **First-time CTA card** below the verse (replaces Continue strip):
  - 28 px margin top, padding 22×24, radius 4 px, `dSurface`, 1 px `dDivider` saffron border, centered
  - Opener line in `Fonts.deva` 14 px saffron, letter-spacing 0.04em, 14 px bottom margin: `॥ श्री गणेशाय नमः ॥`
  - Title (`AppText.screenTitle` 22 px serif w500, line-height 1.35, 10 px bottom margin): `Where will you begin?`
  - Body (italic serif 14 px, line-height 1.55, `dText2`, 22 px bottom margin): `Eight foundation modules introduce the essentials. Or step directly into a scripture.`
  - Pill button (saffron fill, `#1a1208` text, sans 13 px w600, padding 13×28, radius 30 px, uppercase, letter-spacing 0.08em): `Open Foundations` → routes `/learning`
- Below the CTA (18 px margin top, centered, sans 11 px, `dText3`, letter-spacing 0.16em uppercase): `or browse the library →` — tappable → routes `/library`
- Festival pill is **omitted** on day-one (avoid feeling crowded)

---

## Data sources

```dart
class HomeData {
  final String greetingName;          // from prefs; null → no comma in greeting
  final TimeOfDay deviceNow;          // determines greeting variant
  final Panchang panchang;            // tithi/nakshatra/vaar/masa, vikram samvat year
  final Verse verseOfDay;             // selected by date seed → deterministic per day
  final ReadingProgress? lastRead;    // most recent verse with chapter+verse position + 8-bead progress through current chapter
  final NextModule? nextModule;       // next pending learning_path module
  final Festival? upcomingFestival;   // soonest festival with daysUntil
  final bool isFirstDay;              // onboardingCompletedAt == today
  final int streakDays;               // current daily-read streak
}
```

- **Verse-of-day selection:** seeded by ISO date (YYYY-MM-DD). Same verse for every user on the same day. Curated whitelist (avoid violent / context-heavy verses for cold cohort).
- **Streak:** counts consecutive days where `verseOpenedAt` exists. Reset rule = 1 calendar-day grace.
- **Continue Reading:** `lastRead.chapterId` → progress beads = `read_in_chapter / total_in_chapter`, capped to 8 visible beads (proportional fill, not 1:1).

---

## Tokens & widgets used

- `DColors.{bg, surface, saffron, saffronDeep, saffronGlow, cream, text1, text2, text3, divider, dividerSoft, ironRed}` + light variants
- `AppText.{screenTitle, subtitle, sectionLabel, moduleTitle, moduleDesc, primaryButton, textButton, invocation}`
- `Fonts.{sans, serif, deva, devaUI}`
- `BindingLine` (top + bottom) — saffron-deep gradient + 6×6 rotated diamond hole, glow on dark
- `IncisedRule` (88 px wide, center diamond) — reusable from heritage widgets, or inline `CustomPaint` if not yet extracted
- `Skeleton` shimmer — 1.6 s ease-in-out, 50→85→50 opacity, `rgba(232,130,12,0.08)` fill
- Standard `Curves.easeOut` for fade-up entrance

**No** ornament painters, **no** GangaWaveBackdrop, **no** WarmBackdrop on this screen. The verse card itself carries the visual weight.

---

## Don't

- ❌ Don't add a sunrise illustration, lotus watermark, mandala, or deity glyph anywhere on this screen.
- ❌ Don't use cards with shadows. The verse card has a 1 px inset border + flat surface.
- ❌ Don't auto-advance the verse-of-day at midnight while the screen is open. Only refresh on next foreground.
- ❌ Don't show "good morning" emoji. Time-aware greetings are textual only.
- ❌ Don't show all three strips (continue/path/festival) in skeleton form — show only the structure that has *some* deterministic data. Hide festival pill during loading.
- ❌ Don't render Devanāgarī numerals in verse meta (`Bhagavad Gītā · 11 · 37`) — those numbers stay Latin in the meta line. Devanāgarī numerals are reserved for in-verse references and the Sanctum gutter (verse detail spec).
- ❌ Don't fail-blank the screen on any single provider error. Verse error → show banner; other providers keep rendering.
- ❌ Don't re-fetch verseOfDay on pull-to-refresh; only on explicit retry button or app foreground after midnight.

---

## Acceptance criteria

- [ ] Light + dark themes render correctly with palm-leaf grain visible in light verse card
- [ ] Greeting reflects device time and falls back gracefully when no name is stored
- [ ] Panchang line renders Devanāgarī correctly (no font-fallback boxes); Vikram Samvat year is current
- [ ] Verse hero card has top + bottom binding lines with rotated-diamond holes; glow only in dark mode
- [ ] Sanskrit + translation + CTA fade-up sequence matches the 100/300/500 ms timings
- [ ] Continue strip shows 8 progress beads with correct filled count
- [ ] Path strip routes to `/learning/module/{nextModule.id}`
- [ ] Festival pill shows Devanāgarī name + Roman + days countdown; tap routes to `/festivals`
- [ ] Loading state shows shimmering skeletons with structural binding-lines still visible
- [ ] Error state shows iron-red dashed banner with retry; other strips remain interactive
- [ ] First-day variant: shows śānti mantra, hides Festival pill, shows "Where will you begin?" CTA
- [ ] No emoji icons, no painter ornaments, no `WarmBackdrop` on this screen
- [ ] All text uses `AppText` styles — no inline `TextStyle` definitions
- [ ] All Devanāgarī verse text uses `Fonts.deva` (Tiro Devanagari Sanskrit), all Devanāgarī UI tags use `Fonts.devaUI` (Noto Sans Devanagari)
- [ ] Pull-to-refresh re-fetches panchang + continue + path + festival; verse-of-day only refreshes on retry tap or app foreground
