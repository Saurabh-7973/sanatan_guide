# Verse Detail Redesign — claude.ai Prompt

## What to do

1. Take 2 screenshots on your emulator/device:
   - `verse-detail-current.png` — verse detail screen (e.g. BG 2.47), dark mode
   - `verse-chat-current.png` — AI chat screen from verse detail, dark mode
   Save both into this folder.

2. Open https://claude.ai. NEW conversation.

3. Upload ALL these files:
   - `../context-pack.md`
   - `verse-detail-current.png`
   - `verse-chat-current.png`
   - `verse_detail_page.dart`
   - `verse_detail_provider.dart`
   - `verse.dart`
   - `verse_label.dart`
   - `app_colors.dart`
   - `app_typography.dart`
   - `app_spacing.dart`

4. Paste the prompt below.

---

## Prompt (copy everything between the `---` markers)

I'm redesigning the **verse detail screen** of my Hindu scripture reader app. This is THE core surface — users spend 80% of their time here reading single verses across 30+ scriptures (Gita, Vedas, Upanishads, Puranas, etc.).

I want **bold, original UI**. Don't pattern-match other spiritual apps. Don't play it safe. Surprise me — but back every move with craft.

Attached:
- `context-pack.md` — palette, typography, spacing, fonts, philosophy
- `verse-detail-current.png` — current screen (dark) — what to replace
- `verse-chat-current.png` — AI chat sheet (preserve this flow)
- `verse_detail_page.dart` — current widget tree
- `verse_detail_provider.dart` — Riverpod state
- `verse.dart`, `verse_label.dart` — entity + label utilities
- `app_colors.dart`, `app_typography.dart`, `app_spacing.dart` — design tokens

---

### Step 1 — Reasoning (answer out loud)

1. **Job-to-be-done.** What is the user actually doing — reading, studying, memorising, contemplating? Probably all four at different moments. Which moment does the screen optimise for, and how does it switch to the others without becoming a settings panel?
2. **What the current screen gets wrong.** Look at `verse-detail-current.png`. Be specific. Call out generic Material patterns, weak hierarchy, wasted space, broken rhythm.
3. **Premium reading patterns from outside the spiritual-app ghetto.** Readwise, Kindle, Apple News+, Are.na, Substack, FT app, NYT Cooking. Pick concrete patterns and say what you'd steal — and what you'd reject.
4. **Hindu/Sanskrit-specific UX moves that earn their place.** ॥ double-danda as glyph, padapāṭha as inline gloss, manuscript marginalia, folio numbers, vertical Devanagari, śruti vs smṛti distinction. Pick the ones that aren't decoration — the ones that change what the user can DO.
5. **What you're refusing.** Name 2-3 spiritual-app clichés you will not use (e.g. lotus icons, generic "om" headers, gradient bubbles, fake parchment textures, glassmorphism cards, neon saffron). Explain why.

---

### Step 2 — Invent 3 wildly different directions

Three should feel like **three different design philosophies**, not three skins of the same idea. Each must have:

- **A name** that captures the philosophy (e.g. "Editorial Folio", "Negative Space", "Vertical Manuscript", "Reading Reduction"). Invent something that telegraphs the move.
- **A core insight** — one sentence on what this direction believes about reading scripture in 2026.
- **A signature mechanic** — the ONE thing that makes this direction unmistakable. Could be:
  - An atmospheric layer (CustomPainter geometry, parchment grain, oil-lamp glow, breathing svara, dawn horizon, etc.) — OR
  - A radical layout move (vertical Sanskrit, two-column scholar split, single-line per screen, swipe-stacks per translation) — OR
  - A reading affordance the current screen doesn't have (tap-word padapāṭha, long-press commentary stack, gesture-driven chrome fade, scroll-driven zoom on Sanskrit, side-by-side translations)
- **A typographic identity** — how Sanskrit dominates. Hero centered? Drop-cap? Vertical? Stacked half-verses with caesura? Decide and defend.
- **A motion idea** — one tasteful interaction (chrome fade on scroll, breath pulse on a glyph, slide between verses with paper-feel, page-turn). One only — no animation theatre.

Build all 3 as **separate HTML artifacts in phone frames with light/dark toggle per frame** — gallery layout, side-by-side, so I can compare.

Use realistic data — Bhagavad Gita 2.47:
- Sanskrit: कर्मण्येवाधिकारस्ते मा फलेषु कदाचन। मा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्तु अकर्मणि॥
- Transliteration: karmaṇy evādhikāras te mā phaleṣu kadācana / mā karmaphalahetur bhūr mā te saṅgo 'stv akarmaṇi
- English: You have the right to action alone, never to its fruits. Let not the fruits of action be your motive, nor let your attachment be to inaction.
- Hindi: कर्म करने में ही तुम्हारा अधिकार है, फल की प्राप्ति में नहीं।
- Word-by-word: कर्मणि (in action) · एव (alone) · अधिकारः (right) · ते (your) · मा (not) · फलेषु (in fruits) · कदाचन (ever)

---

### Step 3 — UX quality bar (non-negotiable, applies to all 3)

These are the floor. Hit them or don't ship.

**Typography**
- Sanskrit hero ≥ 28sp, line-height ≥ 2.0, letter-spacing tuned for Devanagari (not Lora's default)
- Translation body 16–18sp, line-height 1.5–1.6, max line length 45–75 characters
- Three-tier hierarchy minimum (hero / section / chrome) — visible at a glance
- Use TiroDevanagari for Sanskrit, NotoSansDevanagari for Hindi, Lora for English body, Outfit for UI chrome — never substitute

**Contrast & accessibility**
- WCAG AA minimum: text ≥ 4.5:1 against background, large text ≥ 3:1
- 200% font scale must reflow without overflow or clipping
- All interactive targets ≥ 48×48dp
- Semantic labels on icon-only buttons

**Performance**
- 60fps on mid-range Android — no expensive build() work, no layout thrash on scroll
- `CustomScrollView` + slivers, not nested scrollables
- `const` constructors everywhere static
- Heavy widgets (verse content, word-by-word) split out so rebuilds are scoped

**Visual craft**
- Use only `AppColors.*`, `AppTypography.*`, `AppSpacing.*` — no inline TextStyle, no hardcoded hex, no magic numbers
- Tiered radius — `radiusHero` for verse, `radiusCard` for sections, `radiusChip` for chips, `radiusRow` for list items
- At least one atmospheric layer per direction (Stack with background paint or texture) — never flat Scaffold
- Light AND dark must both work and feel intentional (not auto-inverted)

**Surprise me with the layout. Hold the line on the bar above.**

---

### Constraints — preserve, don't degrade

User flows:
- Swipe left/right between verses (state-based, not routed)
- Bookmark toggle + haptic
- Share as PNG card
- Transliteration toggle (show/hide)
- Personal notes (editable, persisted)
- Word-by-word meanings (when present)
- AI chat button → opens chat sheet
- AppBar back → verse list

Sections (when data present):
- Scripture chip · verse label · Sanskrit · transliteration · English · Hindi · word-by-word · personal notes · prev/next nav

Riverpod providers preserved exactly — no behavioural drift.

---

**Start now: 5-question reasoning → 3 invented directions → HTML gallery in phone frames with light/dark toggle.**

After I pick one, convert to production Flutter — split into focused widget files (one per concept), tokens-only, sliver-based, light + dark verified.

---

## After Claude responds

- Read the 5 answers. If anything is generic ("a sacred reading experience…", "calming and serene…"), call it out: **"Spiritual-app slop. Re-read step 1.5. Try again."**
- Compare 3 directions side-by-side with current screen. Ask: which one would make me re-open the app tomorrow?
- Reject any direction without a signature mechanic — if you can swap it for the others without losing identity, it has none.
- Pick the boldest direction that still hits the UX bar.
- Say: **"I pick [name]. Now give me the Flutter implementation, split into focused widget files."**
- Save new code as `verse_detail_page_v2.dart` first — test alongside old. If good, replace.
- Commit: `git commit -m "feat(verse-detail): redesign — [direction name]"`
