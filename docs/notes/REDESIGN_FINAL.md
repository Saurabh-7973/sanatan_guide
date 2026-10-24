# Redesign — final decisions (single source of truth)

> **Task 54 deliverable.** Synthesized from `REDESIGN_GEMINI.md`, `REDESIGN_DEEPSEEK.md`, `REDESIGN_GPT.md`, `REDESIGN_GROK.md`.  
> **Last updated:** April 2026 (Composer pass — **Opus 4.6 or reviewer**: confirm tables against repo before release sign-off.)  
> **Rule:** Implementation follows **this file**, not the four source docs. Re-open synthesis only if product direction changes.

---

## 1. North star

- **Sacred minimalism** (GPT + Grok): calm, manuscript-adjacent, warm — not festival-loud or “database browser.”
- **Readable first**: Sanskrit and translations get priority; chrome and gimmicks lose.
- **Three destinations** (DeepSeek + GPT + Grok, overruled Gemini): **Home · Path · Library** — bookmarks stay secondary (AppBar / entry points), not a fourth tab.
- **Offline performance**: no heavy textures, particle storms, or Hero-on-every-row patterns that hurt 140k+ verses.
- **Respectful visuals**: geometric hints and metaphors OK; avoid kitsch, noisy OM pulses, or deity photo hero art (DeepSeek/Grok ideas toned down here).

---

## 2. Conflict matrix (how the four models disagreed)

| Topic | Gemini | DeepSeek | GPT | Grok | **Final decision** |
|--------|--------|----------|-----|------|---------------------|
| Tab count | 4 (add Saved) | 3 | 3 | 3 | **3 tabs.** Bookmarks via Library AppBar + elsewhere. |
| Tab labels | (implied Home/Learn/Browse) | Home / Learn / Browse | Today / Path / Library | Home / Path / Library | **Home / Path / Library** (GPT naming, shipped). |
| Primary saffron | Terracotta `#D9663D` | Kesariya `#FF9933` | Keep `#E8820C`, use sparingly | Keep `#E8820C` + glow | **Keep `#E8820C`** — brand already established; no full palette migration for v1. |
| Dark scaffold | Warm charcoal | AMOLED `#000000` + gold body | `#0B0A09` | `#12100E` optional | **Keep `#0F0F0F`** warm near-black (`AppColors.bgDark`). No AMOLED-first (LCD + “cheap” risk per prior notes). |
| Dark Sanskrit | — | Gold `#FFD700` | — | Warm ivory `#E8D9C0` | **Warm ivory** for long reading: target **`#E8D9C0`** on dark (`sanskritTextOnDark`); **not** full gold body (strain). |
| UI font | Outfit OK | Replace Outfit → Inter/Lexend | Less UI weight | Outfit perfect | **Keep Outfit** — switching font family is low ROI vs. spacing/type scale work. |
| Verse “meaning” flow | Immersive bar, swipe-only nav | **Layered peek** (Sanskrit only → reveal) | Progressive disclosure sections | Modes Focus/Scholar/Beginner + bottom bar | **Linear stack + FilterChips reading modes + bottom prev/next** (Grok simplified + DeepSeek swipe haptics where useful). **Skip** strict 3-layer peek for v1 (complexity). |
| Bottom nav | — | OM drawer “More” | — | Floating translucent + blur | **Solid `NavigationBar`** in shell — **skip** translucent/blur (accessibility + M3 simplicity). |
| Home streak | Week strip top | Mala beads + pulse OM | Minimal text | Heatmap + flame | **Streak row + milestone strip + GitHub-style heatmap** (always visible grid — not collapsible; verify UX). |
| Library layout | Masonry | Accordion sections | Segments + softer cards | Carousels + grids | **Grouped sections + featured carousel** (no masonry/accordion v1). |
| Chapter list (Gita) | Timeline | **Chakra wheel** | Progress rings | 2-col grid cards | **Chakra wheel → v2+** (high build cost); v1 = **cards + progress** improvements first. |

---

## 3. Typography

| Decision | Value | Sources | Status |
|----------|-------|---------|--------|
| Sanskrit display line height | **2.2** | Gemini, DeepSeek, Grok; GPT ~2.1 | **DONE** (`AppTypography` / verse use) |
| Sanskrit letter spacing (large) | **0.8** | DeepSeek, Grok | **DONE** |
| Sanskrit size (verse emphasis) | **24–26sp** range; hero can use `sanskritLarge` | All agree “more room” | **DONE / tune** — verify verse detail uses appropriate scale |
| English body | **Left-aligned, never justified** | Gemini (strongest) | **DONE** — enforce in new copy |
| Hindi body minimum | **17sp** where Hindi body shown | Grok | **DO** — audit Hindi `Text` styles |
| Lora / Tiro / Outfit / Noto | Keep stack | Consensus except DeepSeek UI font | **DONE** |

---

## 4. Verse detail (heart screen)

| Decision | Detail | Status |
|----------|--------|--------|
| Order | Sanskrit → transliteration → translation (± Hindi per data) | **DONE** |
| Reading modes | `FilterChip` row: All / Sanskrit / Sanskrit+transliteration / Translation only | **DONE** |
| Word meanings | Collapsed by default; expand control | **DONE** |
| Swipe between verses | `PageView` + haptics | **DONE** |
| AppBar | Collapse / immersive on scroll | **DONE** |
| Notes | Bottom sheet, not inline wall | **DONE** |
| Bottom bar | Prev / next + position | **DONE** |
| Section **dividers** | Subtle between Sanskrit / translit / translation | **DO** |
| Share as image | `ShareCardGenerator` + offscreen card | **DONE** |
| Sanskrit on dark | Warm ivory **`#E8D9C0`** | **DO** — align tokens if any screen still uses brown-on-dark |
| Radial / vignette on verse | Very subtle, dark only optional | **DO** (after dividers) |

**Deferred (v2+):** DeepSeek layered-only-Sanskrit-first flow; voice notes; per-word chip → bottom sheet; Grok tiny Sanskrit previews in bottom bar.

---

## 5. Home (“daily spiritual dashboard”)

| Decision | Detail | Status |
|----------|--------|--------|
| Feel | Dashboard of **ritual cues**, not clutter | **In progress** (task 55) |
| Verse of day | Hero card, Sanskrit forward | **DONE** |
| Streak | Compact row + emoji | **DONE** |
| Milestone badges | Row of levels (earned vs locked) | **DONE** |
| Heatmap | ~30-day read history, **locale weekday columns** | **DONE** (always expanded — spec said collapsible; **product chose** always-on for discoverability) |
| Daily suggestion | Panchang weekday → verse deep link | **DONE** |
| Experience level | Beginner/scholar tips on suggestion card + Settings | **DONE** |
| Learning summary | “X of Y modules” → Path | **DONE** (partial 55) |
| Panchang / festival | Compact / row access | **DONE** |
| Continue reading | Chip / row | **DONE** |
| Subtle radial gradient | Home (and optionally verse) in dark | **DO** |

**Skipped for v1:** pulsing OM header, pull-to-reveal OM (Grok), FAB random verse, mala literal UI (DeepSeek), Quick Library edge drawer.

---

## 6. Navigation

| Decision | Status |
|----------|--------|
| 3 tabs: **Home · Path · Library** | **DONE** |
| Bookmarks: AppBar on Library, not tab | **DONE** |
| Festivals: Home + route | **DONE** |
| Settings: gear AppBar | **DONE** |

---

## 7. Dark mode

| Decision | Status |
|----------|--------|
| Scaffold `#0F0F0F` warm black | **DONE** |
| Surfaces warm brown tiers (`surfaceDark`, etc.) | **DONE** |
| Borders `borderDark` / `dividerDark` | **DONE** |
| No AMOLED + gold body as default | **Decision** (see matrix) |
| Second pass after big UI churn | **DO** (task 58) |

---

## 8. Scripture library

| Decision | Status |
|----------|--------|
| Category sections (not flat list) | **DONE** |
| Featured carousel (“core” texts) | **DONE** |
| Descriptions + sampler badge where needed | **DONE** |
| Sanskrit name prominence vs English | **DO** (task 57) |
| Inline verse/chapter progress on rows | **DO** (task 57) |

**Skipped v1:** masonry, accordion-only layout, Gita-only chakra wheel (defer).

---

## 9. Micro-interactions

| Decision | Status |
|----------|--------|
| Verse open fade / motion | **DONE** (verify intensity) |
| Bookmark feedback | **DONE** |
| Haptics on verse change | **DONE** |
| Meaningful route transitions | **DONE** |
| Shimmer suppressed when load < ~200ms | **DO** |
| Chapter **progress ring** on chapter list | **DO** |

**Skipped:** particle streak splash, bookmark gold particles, unlock sound.

---

## 10. Reusable components (build order)

| Component | Role | Priority |
|-----------|------|----------|
| **SacredCard** | Warm border, 12–16dp radius, dark-aware surfaces | **DO** — unify Home/Library |
| **VersePreviewTile** | Search, bookmarks, lists | **DO** |
| **ScriptureHeader** | Emoji + SK name + EN name + count + blurb | **DO** — library rows |
| **ProgressIndicator** (refined) | Chapter / module, warm circular where it fits | **DO** |

**Skipped v1:** `MalaProgressIndicator`, `GlowingAppBar`, `AnimatedOM`, `ProgressDiya` — too decorative for current engineering budget.

---

## 11. Color tokens (locked for v1)

Keep **`#E8820C`** saffron and existing `AppColors` hierarchy. Optional **tint** tweaks only with design QA — no wholesale rename to terracotta/Kesariya without a versioned “rebrand” decision.

---

## 12. Implementation order (post–task 54)

1. Verse detail: **section dividers** + Sanskrit dark ivory audit.  
2. **Hindi 17sp** audit.  
3. **SacredCard** + **VersePreviewTile** + **ScriptureHeader** (supports task 57).  
4. Home: **subtle radial gradient** (dark), task **55** dashboard polish (density, spacing, “one scroll” rule).  
5. Library task **57** (cards, counts, SK prominence).  
6. Shimmer fast-load skip + chapter **progress rings**.  
7. **Dark mode pass** (task 58) after surface area stabilizes.

---

## 13. Reference

- **AWESOME_RESOURCES.md** — Mobbin, Laws of UX, checklist design, a11y lists.  
- **SOLO_DEV_ROADMAP.md** / **CURRENT_SPRINT.md** — sequencing and effort.

---

*End of REDESIGN_FINAL.md. Do not treat the four `REDESIGN_*.md` inputs as authoritative; use this file and code.*
