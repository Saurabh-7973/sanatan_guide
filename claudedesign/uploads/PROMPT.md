# Verse Detail Redesign — claude.ai Prompt

## What to do

1. Take 2 screenshots on your emulator/device:
   - `verse-detail-current.png` — verse detail screen (e.g. BG 2.47), dark mode
   - `verse-chat-current.png` — AI chat screen from verse detail, dark mode
   Save both into this folder.

2. Open https://claude.ai in your browser. NEW conversation (do not continue home chat).

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

I'm redesigning the verse detail screen of my Hindu scripture reader app — THE core reading surface, where users spend 80% of their time.

Attached:
- context-pack.md — full app context, colors, typography, spacing
- verse-detail-current.png — current screen (dark mode)
- verse-chat-current.png — AI chat screen from verse detail
- verse_detail_page.dart — current widget tree
- verse_detail_provider.dart — Riverpod state
- verse.dart — Verse entity
- verse_label.dart — label utilities (e.g. RV.1.1.1 → "Mandala 1 · Hymn 1 · Verse 1")
- app_colors.dart, app_typography.dart, app_spacing.dart — design system (use ONLY these, do not invent new tokens)

Before designing, answer these out loud so I see your reasoning:

1. **What is the user actually DOING on this screen?** Not what they see — the job to be done.
2. **Three competing attention hierarchies.** Example: (a) pure reading focus, (b) study/reference mode, (c) contemplation/meditation. Which fits a Hindu scripture reader in 2026?
3. **What does the current screen get WRONG?** Look at the screenshot. Be specific. Call out what's generic or lazy.
4. **What would a 2026 premium reading app do that mine doesn't?** Readwise, Kindle, Apple News+, BibleHub — patterns to borrow.
5. **What Hindu/Sanskrit-specific UX patterns should I use?** Examples: the ॥ double-danda, the verse number tradition, printed Gita commentaries' side-by-side layouts.

Then propose **3 WILDLY DIFFERENT directions** (not color variants):

- **Direction A — Focused reader** — everything else recedes, verse dominates
- **Direction B — Study / reference** — Sanskrit + transliteration + translation + word-meanings side-by-side, editorial
- **Direction C — Meditative / contemplative** — single verse fills screen, spacious, breath-like, minimal chrome

Build all 3 as separate HTML artifacts I can preview side-by-side. Dark mode only for round 1.

Use realistic data: Bhagavad Gita 2.47
- Sanskrit: कर्मण्येवाधिकारस्ते मा फलेषु कदाचन। मा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्तु अकर्मणि॥
- Transliteration: karmaṇy evādhikāras te mā phaleṣu kadācana / mā karmaphalahetur bhūr mā te saṅgo 'stv akarmaṇi
- English: You have the right to action alone, never to its fruits. Let not the fruits of action be your motive, nor let your attachment be to inaction.
- Hindi: कर्म करने में ही तुम्हारा अधिकार है, फल की प्राप्ति में नहीं।

Preserve ALL existing functionality (list below). Do NOT drop any flow.

**User flows to preserve:**
- Swipe left/right to navigate between verses (state-based, not routed)
- Bookmark toggle + haptic feedback
- Share as PNG card
- Transliteration toggle (show/hide)
- Personal notes (editable, persisted)
- Word-by-word meanings (shown when available)
- AI chat button → opens chat sheet for this verse
- AppBar back button → verse list

**Sections to display:**
- Scripture chip (e.g. "Bhagavad Gita")
- Verse label ("Chapter 2 · Verse 47")
- Sanskrit (always, large, TiroDevanagari, centered)
- Transliteration (optional, italic, muted)
- English (when present)
- Hindi (when present, NotoSansDevanagari)
- Word-by-word (when present)
- Personal notes (editable)
- Prev/Next bottom nav

**Constraints:**
- Use only AppColors.*, AppTypography.*, AppSpacing.* — no new tokens
- Must work light + dark
- 200% font scale must not overflow
- 60fps — no expensive build() work
- Preserve Riverpod providers exactly

After I pick a direction, convert it to Flutter — production code, using my existing constants, preserving state, no breaking changes.

Start with the 5 questions + 3 HTML directions.

---

## After Claude responds

- Read the 5 answers. If reasoning is weak, call it out ("you're pattern-matching spiritual-app tropes, try again").
- Preview all 3 HTML directions. Compare with your current screen side-by-side.
- Pick the one that matches your app's soul, not the prettiest.
- Say: "I pick Direction B. Now give me the Flutter implementation."
- Save the new code as `verse_detail_page_v2.dart` first — test alongside old. If good, replace.
- Commit to git: `git commit -m "feat(verse-detail): redesign — direction B"`
