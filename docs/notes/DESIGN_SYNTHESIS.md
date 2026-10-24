# Sanatan Guide — AI Design Synthesis
**Sources:** GPT-4o · Gemini 2.5 Pro · Claude Opus 4.7 · DeepSeek · Grok 3  
**Reviewed by:** Claude Opus 4.7 (meta-critique applied — see corrections section)  
**Date:** 2026-04-17  

---

## Overarching Philosophy (5/5 unanimous)

All five models opened with the same diagnosis:  
> "The app is a database wrapper, not a sacred space."

The single design shift: **every screen must invite a specific emotional state**, not just present data.
- **Stillness** — cream/warm-dark palette, generous whitespace
- **Reverence** — Sanskrit as visual hero, saffron used like a temple flame (rare and precious)
- **Ritual** — daily entry points, first-verse ceremony, focus/Temple mode

---

## Cross-Cutting Decisions (Unanimous — implement without debate)

| Decision | All 5 said | Implementation |
|----------|-----------|----------------|
| **Saffron economy** | Max 3–5 uses per screen. One primary action only. | Depends on design tokens existing first (Phase 0) |
| **Sanskrit as hero** | 32px minimum in verse detail; 2.4+ line height | `AppTypography.sanskritLarge`: 32px, height 2.4 ✅ done |
| **Dark mode = premium** | Dark mode is the "sacred" aesthetic; lead marketing with it | Default onboarding to dark on Step 1 screen |
| **Focus mode ("Temple mode")** | Tap/double-tap → hide ALL chrome. Tap again → restore | verse_detail_page.dart; market as "Temple mode" |
| **First verse ceremony** | After onboarding → full-screen verse before Home | New `first_verse_page.dart` |
| **Replace emoji in Library** | Emojis cheapen texts; use Devanagari monograms | "गी" / "ऋ" / "उ" etc — one TiroDevanagari letter per scripture |
| **Chapter list → vertical list** | Kill the number-pad grid. Single-column editorial list | Rewrite BG chapter grid |
| **Custom nav icons** | Line-art only; saffron when selected, warmGrey50 unselected | 3 custom `CustomPainter` icons |
| **Tab rename** | "Today" unanimous; "Texts" vs "Library" split | **Today · Practice · Texts** (see split decision below) |
| **Empty states** | Typography/diya/lotus — not Material icons | Sanskrit punctuation OR custom SVG |
| **Share card: 4:5 ratio** | 1080×1350px dark bg, Sanskrit hero | Phase 0 — ship before finishing content |
| **Remove section headers from Home** | "TODAY / YOUR PATH / STREAK" = SaaS dashboard | Already partially done; complete removal |
| **Verse of the Day = Home hero** | 60% viewport, full-width, no competing sections | Home page hero redesign |
| **Module Reader: remove "Tap anywhere" hint** | Disappears after first card | One-shot hint with `SharedPreferences` |
| **Panchang: circular display** | Tithi centered, Vara/Paksha/Nakshatra as compass points | New `_PanchangCircle` widget |

---

## Split Decisions (resolved — with reasoning, not just votes)

### Sanskrit size in Verse Detail
- 4 models: 32px · DeepSeek: 40px
- **Decision: 32px** — already implemented; 40px risks overflow on small phones

### Reading mode control in Verse Detail
- All 5 say: remove `SegmentedButton` from top
- **Decision:** Sanskrit always visible. Single "Show/Hide translation" toggle pill below divider. "Show pronunciation" text link below Sanskrit. ✅ partially built.

### Share card Sanskrit size
- GPT: 24–28px · Gemini/Grok: 32px · Claude/DeepSeek: 42px
- **Decision: 42px** — majority vote says 32px, but the minority has better reasoning. At 32px, the Sanskrit gets lost in WhatsApp auto-previews. The share card must dominate at thumbnail size. Override majority.

### Tab labels: "Journey" vs "Practice"
- GPT: Journey · Gemini: Journey · DeepSeek: Journey · Grok: Journey · Claude: **Practice**
- 4/5 say "Journey" — but this is where design isn't voting.
- **Decision: "Practice"** — In Hindu tradition, *sadhana* means regular spiritual practice, not travel metaphor. "Journey" has become cliché (every productivity app uses it). "Practice" has actual cultural weight and signals discipline over gamification. One strong opinion beats four weak agreements.
- **Final tab names: Today · Practice · Texts**

### Learning Path visual
- 3 models (Claude + Gemini + DeepSeek): straight vertical line
- 2 models (GPT + Grok): winding path
- **Decision: Straight vertical connecting line** — winding path risks feeling gamified (Duolingo). Vertical line with module nodes = editorial, adult, ascent metaphor.

### Onboarding Om treatment
- **Decision:** TiroDevanagari ॐ, 96px, saffron, fades in 400ms. Full-screen. No gradient behind it — whitespace is the design.

### Scripture identity system in Library
- Claude: Devanagari monograms only
- DeepSeek: Per-scripture gradient backgrounds + geometric icons
- Others: various
- **Decision: Devanagari monograms ONLY. Drop per-scripture color gradients.**
- Reason: 50+ scriptures with unique gradients becomes a fruit basket — saffron Gita next to indigo Veda next to red Ramayana starts looking like children's book covers. Monograms scale to 50+ items cleanly, reuse TiroDevanagari, stay neutral and deeply Indic.
- **Exception:** The single *featured hero card* at top of Library may use a subtle gradient for that one spotlighted text. Not across every tile.

---

## Recovered Details (dropped in first synthesis — add back)

These were in the AI responses but got lost. All high-leverage, low-cost:

| Detail | Source | Where |
|--------|--------|--------|
| **Devanagari numerals on share card** — "गीता · २.४७" not "BG 2.47" | Claude Opus | Share card; costs nothing; single biggest "art not screenshot" signal |
| **"Temple mode"** as the marketing name for focus mode | Claude Opus | verse_detail_page.dart marketing copy; App Store screenshot headline |
| **Dot ladder for chapter progress** — 18 tiny circles (4px), saffron filled/empty | Claude Opus | chapter_list_page.dart intro block; richer at-a-glance than a bar |
| **Roman numerals for level headers** — "I · Foundation" in Lora 32px w300 | Claude Opus | learning_path_page.dart; thin serif Roman = manuscript foliation, not SaaS |
| **Em-dash as empty state** — single "—" in warmGrey30 at 40px for bookmarks | Claude Opus | bookmarks_page.dart; typographic empty states age 10× better than illustrations |
| **Sanskrit punctuation "॥" for path empty state** | Claude Opus | learning_path_page.dart empty state |
| **"Show pronunciation" link italic in Lora** | Multiple | verse_detail_page.dart |
| **Card type background colors in Module Reader** | Claude Opus | content=cream, anchor verse=saffron-tinted cream, reflection=cooler grey, completion=saffron wash |

---

## New Design Tokens Required

**These must exist before the saffron economy pass can run. This is Phase 0.**

### AppColors additions
```dart
// Warm grey palette
static const Color warmGrey10  = Color(0xFFF2EDE6); // hover/selected on cream
static const Color warmGrey50  = Color(0xFF8A7968); // secondary UI, meta text
static const Color warmGrey80  = Color(0xFF3A322B); // primary text on cream (softer than near-black)

// Already in plan (confirm these exist):
// saffronFaint  = Color(0x14E8820C); // 8%
// saffronMuted  = Color(0x1FE8820C); // 12%
// saffronBorder = Color(0x4DE8820C); // 30%
```

### AppTypography additions (the missing middle)
```dart
// These are the "editorial calm" additions — without them, everything is
// either 11px metadata or 24px+ display. The jump is why the app reads as SaaS.
static const TextStyle titleLarge = TextStyle(
  fontFamily: _serif, fontSize: 20, fontWeight: FontWeight.w600, height: 1.35,
);
static const TextStyle titleMedium = TextStyle(
  fontFamily: _serif, fontSize: 17, fontWeight: FontWeight.w600, height: 1.4,
);
static const TextStyle labelXLarge = TextStyle(
  fontFamily: _ui, fontSize: 15, fontWeight: FontWeight.w500, height: 1.4,
);
```

### Tiered Border Radius (replace 12px-everywhere)
```dart
// Current: cardRadius: 12px — the "SaaS tell." Same radius everywhere = UI.
// New tiered system:
static const double radiusRow    = 4.0;  // list rows — manuscript page feel
static const double radiusChip   = 8.0;  // small chips
static const double radiusCard   = 16.0; // content cards
static const double radiusHero   = 24.0; // hero cards (VoD, featured scripture)
static const double radiusSheet  = 20.0; // share card, bottom sheets
```
Apply with `AppSpacing.radiusCard` etc. (3-hour find-and-replace, enormous visual impact.)

### AppSpacing addition
```dart
static const double xxxxl = 64.0; // between major sections on sacred screens
```

---

## Execution Order (Corrected for Solo Dev Reality)

> You're solo, building evenings, with content seeding still ahead of UI.
> The original Week 1–4 plan ignores your fixed build order.

### Phase 0 — Do now, during content seeding (1–2 evenings each, don't touch seeded screens)
1. **Design tokens PR** — warmGrey palette + missing type scale + tiered radius system  
2. **Share card redesign** — 4:5, 42px Sanskrit, Devanagari numerals (२.४७), 3-dot divider, corner marks  
   *Rationale: every share that happens before you fix this is a lost acquisition. It's your only viral loop.*

### Phase 1 — After content complete (highest visual leverage per hour)
3. **Saffron economy pass** — all screens; requires Phase 0 tokens  
4. **Verse Detail: remove SegmentedButton + implement Temple mode** — your most critical screen  
5. **Home: hero VoD + remove section headers + compact streak footer**

### Phase 2 — Structural rebuilds
6. **Chapter List: grid → vertical editorial list** with dot ladder progress  
7. **Library: Devanagari monograms** (drop gradients; single featured hero card only)  
8. **Design tokens: radius tiering** applied across all widgets  

### Phase 3 — Navigation + onboarding
9. **Tab rename: Today · Practice · Texts**  
10. **Bottom nav: 3 custom line-art icons** (line-art, 2px stroke, saffron selected / warmGrey50 unselected)  
11. **Onboarding: ॐ SVG redesign + Sanskrit blessing line**  
12. **First Verse Ceremony page**

### Phase 4 — Polish before Play Store
13. **Empty states: SacredEmptyState widget** (em-dash for bookmarks, ॥ for path, · for search)  
14. **Learning Path: vertical connecting line + Roman numeral level headers**  
15. **Module Reader: card-type background colors** (content/anchor/reflection/completion)  
16. **Panchang: circular widget**

---

## Screen-by-Screen Reference

### Verse Detail (Phase 1, screen 4)
| Task | Change |
|------|--------|
| Remove SegmentedButton | "Show/Hide translation" toggle pill below divider |
| Temple mode | Double-tap Sanskrit → fade all chrome (200ms easeInOutCubic); double-tap to restore |
| First-use hint | "Double-tap to enter Temple mode" — fades after 3s, stored in SharedPreferences, never shown again |
| Three-dot divider | Replace `Divider` with 3 saffron dots (4px) centered, 24px spacing above/below |
| Scripture name label | Remove ALL CAPS saffron "BHAGAVAD GITA" banner — redundant |
| Background texture | Barely-visible mandala pattern, warmGrey10 on cream, 6% opacity, bottom-right margin (not behind verse) |

### Home (Phase 1, screen 5)
| Task | Change |
|------|--------|
| Hero VoD | Full-width minus 20px, 24px radius, cream card, 2px×32px saffron dash at top as only saffron |
| Remove all headers | "TODAY" / "YOUR PATH" / "STREAK" → gone |
| Continue reading | Text row (no card/border): "Continue where you left" + snippet + reference |
| Streak footer | Single line at bottom: "🪔 Seven days of practice" Outfit 13px w500 saffron |
| Remove DailySuggestion | Redundant with VoD |

### Chapter List (Phase 2, screen 6)
| Task | Change |
|------|--------|
| Kill 3-col grid | Single-column vertical list, 88px rows |
| Row anatomy | Left: chapter number Lora 32px w300 warmGrey50; Center: Sanskrit name 17px + English theme 13px italic; Right: circular progress arc 24px |
| Dot ladder intro | 18 tiny 4px circles at top of screen; saffron filled = read, warmGrey10 = unread |
| Replace LinearProgressIndicator | Circular arc per row |

### Library (Phase 2, screen 7)
| Task | Change |
|------|--------|
| Devanagari monograms | Map each scripture → 1–2 Devanagari chars in TiroDevanagari 24px, saffron, on 44px cream disc |
| Drop per-scripture gradients | All scripture tiles: same warm treatment; monogram IS the identity |
| Featured hero card | Single card only; subtle gradient for that one spotlighted text |
| Category headers | Lora 18px w600 warmGrey80 (not 11px uppercase) |

### Share Card (Phase 0)
| Property | Value |
|----------|-------|
| Aspect ratio | 4:5 (1080×1350px) |
| Background | #0F0B07 (warmer than pure black) |
| Sanskrit | TiroDevanagari 42px, warm ivory #EFE4D0, centered, max 4 lines |
| Divider | 2 saffron dots (4px), 24px apart, centered |
| Translation | Lora italic 22px, warm ivory 80% opacity |
| Verse reference | **Devanagari numerals: "गीता · २.४७"** — not "BG 2.47" |
| Corner marks | 4 tiny 2px×8px L-shapes in saffron (25% opacity) at inner frame corners |
| Branding | 10px saffron dot, outside inner frame, bottom-right. No wordmark. |

### Learning Path (Phase 4)
| Task | Change |
|------|--------|
| Level headers | Roman numeral in Lora 32px w300 warmGrey50: "I · Foundation" |
| Connecting line | 1px vertical warm grey 20%, left edge, linking module nodes |
| Module state | In-progress: saffron left bar 3px; Locked: full opacity + "After Module X" text, NOT dimmed |
| Remove heatmap from top | Move to home footer (single line) |

### Empty States (Phase 4)
| Screen | Empty state |
|--------|-------------|
| Bookmarks | "—" em-dash, Lora italic, warmGrey30, 40px |
| Learning Path | "॥" Sanskrit double-danda, warmGrey30, 40px |
| Search (no results) | "·" single dot, warmGrey30, 48px |
| All + copy | Existing copy is good — just swap the icons |

---

## What NOT to implement

| Idea | Why cut |
|------|---------|
| Winding path / Duolingo map | Too gamified for spiritual audience |
| Per-scripture gradient colors across all tiles | Fruit basket at 50+ scriptures; monograms are the system |
| Masonry grid for bookmarks | Inconsistent card heights break rhythm |
| Filter chips (All/Verses/Translations/Keywords) in search | 95% of users don't understand the distinction |
| Sanskrit tab names (Darshan/Sadhana/Shastra) | Alienates diaspora beginners |
| Share card wordmark | Reduces shareability — feels like an ad |
| Horizontal scroll onboarding path cards | Implicit gesture; vertical more accessible |

---

## Saffron Economy — Specific Audit

### Legitimate saffron uses (keep)
1. Single primary CTA button per screen
2. Currently active item only (current chapter, active module, playing verse)
3. Filled bookmark icon
4. Streak flame/number (if on screen)
5. Devanagari monogram letter in scripture disc
6. 2px×32px hairline accent on VoD hero card (one per Home)
7. Selected nav tab icon
8. Share card Sanskrit + corner marks + reference

### Remove saffron from (replace with warmGrey50)
- Section headers ("TODAY", "YOUR PATH") → already partially done
- Progress bars (non-current items) → warmGrey30
- Category left-borders on scripture tiles → remove entirely
- Chip/badge borders → warmGrey10 border or no border
- Meta text (verse counts, dates, timestamps) → warmGrey50
- Read indicator dots on verse list → 1px×12px saffron hairline (barely visible)
- All icon tints in default/unselected state → warmGrey50

---

## The Three to Ship This Phase (from Opus)

> "Ship those three this month. The rest can follow."

1. **Design tokens + radius tiering** — 2 days. The whole app stops feeling like a dashboard.
2. **Share card redesign** — 1 day. Every share becomes user-acquisition before you even launch.
3. **Saffron economy pass** — 2 days. Transforms perceived quality more than the next nine priorities combined.

---

## Closing Principle (DeepSeek)

> "The trillion-dollar version of Sanatan Guide is not the one with the most features.  
> It's the one where opening the app feels like entering a quiet temple,  
> and reading a verse feels like receiving a gift."

**The app's brand isn't a color or a typeface — it's the discipline to let sacred content breathe.**
