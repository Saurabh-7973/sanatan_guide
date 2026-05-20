# S7 — Festivals & Panchāṅga Almanac

> **Status:** spec + plan (build pending). The roadmap's
> `2026-05-17-festivals-rewrite.md` was never written; this replaces it.
> **Source of truth:** `New Design/screen-08-festivals.html`. No
> `.claude/screen_specs/10_*` file exists — this doc is the spec.

## What screen-08 actually is

Not a festival *list* — a **daily panchāṅga almanac**. Every `day-row` shows
the date, a moon-phase glyph, the tithi (paksha + name), the nakṣatra, and any
festivals falling that day. A "Today's Panchāṅga" banner sits on top. So S7
cannot be done as a restyle of the current upcoming/past festival list — the
target is a different structure that is panchāṅga-dependent end to end.

## The hard dependency — a panchāṅga engine

The banner and every almanac row need tithi / nakṣatra / yoga / karaṇa.
None of that data exists in the repo. It must be **computed** (this is what a
panchāṅga *is* — not fabrication), but it is religiously load-bearing:
devotees time fasts and observances on tithi. **A wrong tithi shipped is
worse than none.**

### Engine approach — `lib/core/panchanga/`

- **Dependency:** add `astronomia` (pub.dev, MIT, 160 pub points — Meeus
  algorithms; `moonposition`, `solar`, `sidereal`). Vetted 2026-05-20;
  `vedic_panchanga_dart` rejected (license unknown), `myanmar_calendar_widget`
  rejected (unmaintained). See [[project-s7-festivals-blocker]].
- **Compute** (all from the Sun's and Moon's apparent ecliptic longitude at
  a given instant, IST/local noon for a day's nominal value):
  - `tithi = floor(((moonLong − sunLong) mod 360) / 12)` → 0–29.
  - `paksha`: tithi < 15 → Śukla, else Kṛṣṇa; in-paksha index = tithi % 15 + 1.
  - `nakshatra = floor((siderealMoonLong mod 360) / (360/27))` → 0–26, where
    `siderealMoonLong = tropicalMoonLong − ayanāṃśa`. Use Lahiri ayanāṃśa via
    a linear approximation from a base epoch (~24.21° at 2026.0, ~50.29″/yr).
  - `yoga = floor(((sunLong + moonLong) mod 360) / (360/27))` → 0–26.
  - `karaṇa = floor(2 × tithiFraction)` within the tithi → 11-name cycle.
  - `vāra` = weekday (sūrya-based; simple `DateTime.weekday`).
- **Name tables** (Devanāgarī + IAST): 15 tithi, 27 nakṣatra, 27 yoga,
  11 karaṇa, 7 vāra. Put in `panchanga_names.dart`.
- **API:** `Panchanga computePanchanga(DateTime instant, {double latitude,
  double longitude})` → a value class with the five aṅgas + display strings.

### Verification — REQUIRED, human-in-the-loop

Unit tests must check the engine against **independently sourced** reference
values (Drik Panchang or a trusted ephemeris) for ~5 known dates spanning
both pakṣas. Do NOT generate "expected" values from the same code — that is
circular. Full-moon / new-moon dates are independently verifiable anchors
(e.g. the mockup asserts 6 May 2026 = Śukla Pūrṇimā — confirm before relying
on it). This cross-check is a human step; flag it in the build session.
Keep the existing "consult your local pandit for regional variations"
disclaimer regardless.

## Festival dates — already handled

`festival_provider.dart` already overrides festival dates from Firebase
Remote Config (`festival_dates_override`, JSON map keyed by festival id),
falling back to the hardcoded `festivals2026`. 5-year coverage = push more
years through RC. **No festival-date engine needed.** Do not rebuild this.

## Entity change

`Festival` needs a **category** for the filter strip (All / Major parvas /
Vrats / Regional). Add `enum FestivalCategory { majorParva, vrat, regional }`
and a `category` field; backfill the 12 entries in `festival_data_2026.dart`.
(`emoji` is already superseded by `DiyaFlameIcon` — leave or remove.)

## UI build — `festival_calendar_page.dart` → heritage almanac

1. **Top bar** — back/heritage chrome per screen-08.
2. **Panchāṅga banner** — "Today's Panchāṅga": tithi headline (Devanāgarī) +
   Gregorian date + 4 cells (Vāra / Nakṣatra / Yoga / Karaṇa), each
   Devanāgarī value + IAST. Driven by `computePanchanga(DateTime.now())`.
3. **Filter strip** — horizontally scrollable pills: All / Major parvas /
   Vrats / Regional. Filters the almanac's festival entries by `category`.
4. **Almanac column** — day rows over a window (e.g. current month + a few
   months ahead). Each row: date num + vāra, moon-phase glyph (derived from
   tithi), tithi (paksha + Devanāgarī name), nakṣatra, and any festivals that
   day (Devanāgarī + English + meta). **Today** highlighted. Festival names
   in iron-red (`dIronRedBright` / `lIronRedBright`) per the heritage rule.
   Sticky month header.
5. **Festival detail page** — heritage restyle of the existing
   `_FestivalDetailPage` (hero glyph, name, Sanskrit, full date, explainer,
   "How to observe" steps). Move it to its own file / a real route.

## Build order

1. Add `astronomia`; build `core/panchanga/` engine + name tables.
2. Engine unit tests — verify against external reference dates (human check).
3. `Festival` category enum + field + backfill data.
4. Rewrite `festival_calendar_page.dart` to the almanac (banner, filter,
   day rows) — heritage tokens, both themes.
5. Festival detail heritage restyle.
6. Widget tests; `flutter analyze`; full suite green.
7. On-device visual smoke (both themes) — owed to the user.

## Risks

- **Panchāṅga accuracy** is the whole ballgame — gate the merge on the
  reference-verified engine tests, not just "compiles + renders".
- `astronomia` API surface is unverified — confirm `moonposition`/`solar`
  return apparent geocentric ecliptic longitude (apply nutation/aberration
  if the package gives mean values).
- Almanac over a long window = many `computePanchanga` calls — compute lazily
  per visible row (`ListView.builder`), or precompute a month at a time.
