# Verse Detail Redesign — claude.ai Prompt

## What to do

1. Take 2 screenshots on your emulator/device:
   - `verse-detail-current.png` — verse detail screen (e.g. BG 2.47), dark mode
   - `verse-chat-current.png` — AI chat screen from verse detail, dark mode
   Save both into this folder.

2. **Also drop these home reference files into the same folder** (so Claude sees the quality bar + visual family):
   - `../home-reference/home_page.dart`
   - `../home-reference/dawn_horizon.dart`
   - `../home-reference/verse_of_day_card.dart`
   - `../home-reference/almanac_tiles.dart`
   - A screenshot of the shipped Temple Dawn home → `home-temple-dawn.png`

3. Open https://claude.ai. NEW conversation (do not continue home chat).

4. Upload ALL these files:
   - `../context-pack.md`
   - `verse-detail-current.png`
   - `verse-chat-current.png`
   - `home-temple-dawn.png`
   - `home_page.dart`
   - `dawn_horizon.dart`
   - `verse_of_day_card.dart`
   - `almanac_tiles.dart`
   - `verse_detail_page.dart`
   - `verse_detail_provider.dart`
   - `verse.dart`
   - `verse_label.dart`
   - `app_colors.dart`
   - `app_typography.dart`
   - `app_spacing.dart`

5. Paste the prompt below.

---

## Prompt (copy everything between the `---` markers)

I'm redesigning the **verse detail screen** of my Hindu scripture reader app — the core reading surface where users spend 80% of their time.

**This screen must live in the same visual family as my shipped home screen ("Temple Dawn").** Study `home-temple-dawn.png`, `home_page.dart`, `dawn_horizon.dart`, `verse_of_day_card.dart`, `almanac_tiles.dart` first. Notice:
- Layered Stack architecture (background atmosphere → ornament → content)
- CustomPainter for sacred geometry (sun arc, lunar phase, mandala)
- Translucent surfaces over warm radial glow
- Saffron horizon, warm cream/near-black, no flat cards
- Typography-led hierarchy (TiroDevanagari hero, Lora body, Outfit chrome)
- Premium reading-app feel — illuminated manuscript meets 2026

**The verse screen MUST feel like the next room in this same temple.** Not a different app. Not a flat list. Not generic Material.

Attached:
- `context-pack.md` — full app context, colors, typography, spacing
- `home-temple-dawn.png` + 4 home Dart files — visual family + quality bar
- `verse-detail-current.png` — current screen (dark mode) — what to replace
- `verse-chat-current.png` — AI chat sheet from verse detail
- `verse_detail_page.dart` — current widget tree
- `verse_detail_provider.dart` — Riverpod state
- `verse.dart`, `verse_label.dart` — entity + label utilities
- `app_colors.dart`, `app_typography.dart`, `app_spacing.dart` — design tokens (use ONLY these)

---

### Step 1 — Answer these out loud (show your reasoning)

1. **What is the user actually DOING here?** Not what they see — the job-to-be-done. (Reading? Studying? Memorizing? Contemplating? All four at different moments?)
2. **What does the current screen get WRONG?** Look at `verse-detail-current.png`. Be specific. Call out what's generic, lazy, or breaks the Temple Dawn family.
3. **What atmospheric layer does the verse screen need that home doesn't?** Home has a horizon glow. What's the verse equivalent — a single oil lamp? A folio page texture? A breathing mandala? Invent.
4. **What 2026 premium reading patterns to borrow?** Readwise, Kindle, Apple News+, BibleHub. Be specific about which pattern and why.
5. **What Hindu/Sanskrit-specific UX patterns?** ॥ double-danda, verse-number tradition, printed Gita commentary side-by-side, manuscript marginalia, padapāṭha. Pick the ones that earn their place.

---

### Step 2 — Invent 3 directions (DO NOT use generic labels like "Focused / Study / Meditative")

Each direction must have:
- **A name** in the same naming family as Temple Dawn (e.g. "Lamp & Folio", "Single Breath", "Padapāṭha Press"). Invent something memorable.
- **An atmospheric mechanic** — what's the equivalent of `dawn_horizon.dart` for this direction? (e.g. CustomPainter oil-lamp glow, parchment-grain background, breathing svara mark)
- **A typographic move** — how does Sanskrit dominate? Drop-cap? Centered hero? Vertical?
- **A unique reading affordance** — something the current screen doesn't do (e.g. word-tap reveals padapāṭha inline, swipe-down dims chrome to "meditation mode", long-press on a śloka opens commentary stack)

Build all 3 as **separate HTML artifacts in phone frames with light/dark toggle** — same format as the home directions gallery. Use realistic data:

- Bhagavad Gita 2.47
- Sanskrit: कर्मण्येवाधिकारस्ते मा फलेषु कदाचन। मा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्तु अकर्मणि॥
- Transliteration: karmaṇy evādhikāras te mā phaleṣu kadācana / mā karmaphalahetur bhūr mā te saṅgo 'stv akarmaṇi
- English: You have the right to action alone, never to its fruits. Let not the fruits of action be your motive, nor let your attachment be to inaction.
- Hindi: कर्म करने में ही तुम्हारा अधिकार है, फल की प्राप्ति में नहीं।
- Word-by-word: कर्मणि (in action) · एव (alone) · अधिकारः (right) · ते (your) · मा (not) · फलेषु (in fruits) · कदाचन (ever)

---

### Step 3 — Quality bar (non-negotiable)

The Flutter conversion (after I pick) MUST match the home screen's architecture:
- **Layered Stack** with at least one atmospheric background layer (not flat Scaffold)
- **CustomPainter** for any sacred geometry — no SVG, no images
- **Translucent surfaces** with warm tints — no harsh white cards
- **Tiered radius** — `radiusHero` for verse, `radiusCard` for sections, `radiusChip` for chips, `radiusRow` for list items
- **Sliver-based scroll** with `CustomScrollView` — match home pattern
- **Split into focused widget files** — one per concept (e.g. `verse_hero.dart`, `lamp_glow.dart`, `padapatha_strip.dart`, `notes_folio.dart`)
- **Tokens only** — `AppColors.*`, `AppTypography.*`, `AppSpacing.*`. No inline styles, no hardcoded hex.

---

### Constraints (preserve, don't degrade)

User flows to preserve:
- Swipe left/right between verses (state-based, not routed)
- Bookmark toggle + haptic
- Share as PNG card
- Transliteration toggle
- Personal notes (editable, persisted)
- Word-by-word meanings
- AI chat button → opens chat sheet
- AppBar back → verse list

Sections to display (when data present):
- Scripture chip · verse label · Sanskrit · transliteration · English · Hindi · word-by-word · personal notes · prev/next nav

Technical:
- Light + dark both work
- 200% font scale, no overflow
- 60fps, no expensive build() work
- Riverpod providers preserved exactly

---

**Start now: 5 questions → 3 invented directions → HTML gallery in phone frames.**

After I pick, convert to production Flutter split into focused files (same pattern as home: `pages/verse_detail_page.dart` + `widgets/<concept>.dart`).

---

## After Claude responds

- Read the 5 answers. If any feels generic or pattern-matched ("a sacred reading experience..."), call it out: **"You're spiritual-app slopping. Re-read the home files. Try again."**
- Preview 3 HTML directions. Open `home-temple-dawn.png` next to them. Ask: does this feel like the same temple, or a different app?
- Reject any direction that doesn't have an atmospheric mechanic (a CustomPainter equivalent of dawn_horizon).
- Pick the one that extends the family while doing something home doesn't.
- Say: **"I pick [name]. Now give me the Flutter implementation, split into focused files like home."**
- Save new code as `verse_detail_page_v2.dart` first — test alongside old. If good, replace.
- Commit: `git commit -m "feat(verse-detail): redesign — [direction name]"`
