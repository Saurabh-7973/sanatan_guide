# 🕉 THE ULTIMATE UI/UX PLAN — AGENT PROMPT
# Sanatan Guide · Flutter · Sacred Minimalism

> **HOW TO USE THIS:** Copy this entire document and paste it into any AI agent
> (Gemini, Claude, GPT-4, etc.). The agent has everything it needs.

---

## AGENT ROLE

You are a **Principal Product Designer** with 15 years of experience. You have
shipped apps at Apple (iOS Human Interface), Headspace (meditation), and
Quran Majeed (Muslim spiritual app). You have deep fluency in Hindu/Indic
cultural aesthetics and sacred design traditions. You think in systems, not
screens — every decision cascades into a coherent whole.

You have been handed the **Sanatan Guide** app and told:
*"Make it feel like a trillion-dollar company designed it. Sacred, not sterile.
Premium, not pretentious."*

Produce **The Ultimate UI/UX Plan** — a complete, implementable redesign
specification that a single Flutter developer can execute screen by screen.

---

## THE APP

**Name:** Sanatan Guide
**Platform:** iOS + Android (Flutter, Material Design 3)
**Purpose:** The definitive Hindu scripture and spiritual learning app.
Think "Kindle + Headspace + Duolingo" for Hindu scriptures — Bhagavad Gita,
Vedas, Upanishads, 50+ texts — for 1.2 billion Hindus globally.

**Brand:** *Ancient wisdom, beautifully presented.*

---

## THREE USER PERSONAS

1. **Diaspora Seeker** — 25–40yo Hindu in USA/UK/Canada. Grew up culturally
   Hindu, never understood it intellectually. Uses Headspace, Calm, Spotify.
   Judges apps by aesthetics in 3 seconds.

2. **Daily Practitioner** — 35–60yo Hindu in India. Does daily puja. Wants
   shlokas for prayer, festival dates, verse meaning. Uses WhatsApp, YouTube.
   Trusts apps that feel serious and sacred.

3. **The Scholar** — Any age. Reads Sanskrit. Wants full text, multiple
   translations, word-by-word meanings. Respects apps that treat the
   material with dignity.

---

## BRAND IDENTITY (HARD CONSTRAINTS — DO NOT CHANGE)

```
Saffron:     #E8820C   ← sparse use only (sacred moments)
Cream (bg):  #FDFAF6   ← warm, never pure white
Dark (bg):   #0F0F0F   ← warm, never pure black
Dark card:   #1C1816   ← saffron-tinted dark
Dark modal:  #221E1B   ← elevated surfaces

Sanskrit font:  TiroDevanagari  (verse display)
English font:   Lora            (body, headings)
UI font:        Outfit          (labels, buttons, captions)

Philosophy: Sacred Minimalism
  NOT "Desi kitsch" (too much orange, busy patterns)
  NOT "Corporate grey" (cold, soulless)
  = Apple meets ancient India
```

**Saffron Economy Rule:** Saffron must be SPARSE. Valid uses: active/selected
states, primary CTAs, verse-of-day accent, streak/completion moments,
category left-borders. Remove it from generic icons, decorative dividers,
every label. When everything is saffron, nothing is sacred.

---

## DESIGN SYSTEM TOKENS

```
Spacing (4pt grid):
  xs=4  sm=8  md=12  lg=16  xl=24  xxl=32  xxxl=48  huge=64
  pagePadding=24  cardPadding=16  sectionGap=32

Border Radius (tiered — emotional weight):
  radiusRow=4    list rows (manuscript feel)
  radiusChip=8   chips, badges
  radiusCard=16  content cards
  radiusHero=24  hero cards, featured content
  radiusSheet=20 bottom sheets, modals

Typography:
  sanskritLarge:  TiroDevanagari 32px, lh 2.4
  sanskritMedium: TiroDevanagari 22px, lh 2.0
  sanskritSmall:  TiroDevanagari 18px, lh 2.0
  transliteration: Lora italic 15px, lh 1.6
  displayLarge:   Lora 32px w600, lh 1.3
  displayMedium:  Lora 24px w600, lh 1.3
  titleLarge:     Lora 20px w600, lh 1.35
  titleMedium:    Lora 17px w600, lh 1.4
  bodyLarge:      Lora 18px, lh 1.6
  bodyMedium:     Lora 16px, lh 1.6
  labelLarge:     Outfit 16px w600
  labelMedium:    Outfit 14px w500
  caption:        Outfit 13px
  sectionLabel:   Outfit 11px w700, letterSpacing 1.5 (UPPERCASE)
  cardLabel:      Outfit 12px w600, saffron
```

---

## NAVIGATION

```
Bottom Nav (3 tabs):
  Tab 0: HOME   /home
  Tab 1: PATH   /learn
  Tab 2: LIBRARY /browse

Full-screen stack (no bottom nav):
  /onboarding        blocks back
  /learn/:moduleId   Module Reader (immersive)
  /browse/:id        Chapter List
  /browse/:id/chapter/:n  Verse List
  /browse/:id/verse/:id   Verse Detail ← MOST CRITICAL
  /search            fade + slide up
  /bookmarks         from Library AppBar
  /settings          from Home AppBar
  /festivals         from Home Today section
```

---

## CONTENT SCALE

```
Library: 50+ texts
  Bhagavad Gita: 700 verses / 18 chapters (most used)
  Rigveda: 10,552 verses / 10 mandalas
  Mahabharata: 100,000+ shlokas / 18 parvas
  Yoga Sutras: 196 sutras / 4 padas
  Tirukkural: 1,330 couplets / 133 chapters

Learning: ~24 modules across 3 levels (5–12 cards each)
Festivals: 50+ per year
```

---

## 12 SCREENS — AS-BUILT WITH PROBLEMS

---

### SCREEN 1: ONBOARDING

**Today:** Cream background. 🕉 emoji 48px. "Welcome to Sanatan Guide"
Lora 32px. 3 selection cards (Beginner/Regular/Scholar), thin border,
saffron on select. Saffron "Continue" button. Step 2: same background,
3 path cards, "Skip" link. Then instantly dumps user into content.

**Problems:** Tutorial-app feel. One emoji doing all brand work. Cards feel
like form checkboxes. No emotional hook. No "welcome moment" — user is
dropped into content with zero ceremony after selecting path.

---

### SCREEN 2: HOME

**Today:** AppBar: greeting 24px Lora + Hindu date + search + settings icons.
Vertical ListView: (1) VerseOfDayCard, (2) DailySuggestionWidget,
(3) "TODAY" section → panchang row + festival row, (4) "YOUR PATH" section
→ progress card + continue reading card, (5) "STREAK" section → day count.

**Problems:** Verse of Day has no visual drama. 5 sections compete — no
single entry point. Greeting too small, shares AppBar with date.
Section labels ("TODAY", "YOUR PATH") feel like SaaS dashboard. No ambient
mood, no daily ritual feeling.

---

### SCREEN 3: SEARCH

**Today:** AppBar search field. Filter chips: All/Verses/Translations/Keywords.
Empty state: generic Material icon + suggestion chips (karma, dharma, arjuna…).
Results: "47 results" label + VersePreviewTile list.

VersePreviewTile: "BG · 2.47" badge + Sanskrit first line + English first
line truncated + optional bookmark icon.

**Problems:** Suggestion chips look like 2010 tag cloud. Empty state icon
is generic Material. Results are a flat list — no visual reward. Filters
confuse most users. No search history.

---

### SCREEN 4: SCRIPTURE LIBRARY

**Today:** AppBar "Library" + bookmark icon. Featured horizontal carousel
(200px, full-width): gradient cards + 40px emoji + title + verse count.
Below: Category sections ("ITIHASA", "VEDA"…) each with scripture cards:
4dp colored left-border + 20px emoji + title + verse count + "Sampler" chip.

**Problems:** Carousel disconnected from list below. 20px emoji represents
texts with 100,000 verses. No cover art, no visual invitation. Equal weight
for all texts. "Sampler" badge — most important discoverability feature —
is invisible.

---

### SCREEN 5: CHAPTER LIST

**Today (BG):** 3-column grid of chapter cards. Each: large chapter number +
LinearProgressIndicator 4px + "Chapter N" label + Sanskrit name small +
"X/47 verses". (Other scriptures: vertical list rows.)

**Problems:** Grid looks like a number pad. Progress bar looks like
buffering. Sanskrit names illegible in small grid cards. No chapter
descriptions — Chapter 11 (Vishwarupa) looks identical to Chapter 1.

---

### SCREEN 6: VERSE LIST

**Today:** AppBar "Chapter 2". Vertical list: verse ID "BG.2.1" + first
Sanskrit line + read dot (saffron = read, grey = unread).

**Problems:** Least designed screen. Just verse IDs. No translation preview,
no verse significance. Read/unread dot invisible. 47 identical tiles.

---

### SCREEN 7: VERSE DETAIL ← MOST IMPORTANT

**Today:** SliverAppBar (floating): back + "BG · 2.47" centered (labelSmall)
+ bookmark + share. SegmentedButton: Full/Sanskrit/English (3 pills,
full-width). Content scroll: scripture name ALL CAPS saffron caption →
Sanskrit TiroDevanagari 32px centered → divider + "Show pronunciation" link
→ transliteration Lora italic 15px → divider + English Lora 18px →
expandable Hindi / word-by-word / AI explanation. Fixed bottom bar:
← Prev | Verse 47 | Notes icon | Next →

**Problems:** SegmentedButton feels like an IDE. "BHAGAVAD GITA" caps above
verse fragments reading flow. No sacred-space feeling — looks like a text
editor. "Show pronunciation" buried. Bottom bar cramped, notes icon
invisible. No ambient position context. No focus/reading mode. This is
where users sit with 5,000-year-old wisdom. It must feel like that.

---

### SCREEN 8: LEARNING PATH (Path tab)

**Today:** No AppBar. 🔥 streak + 30-day calendar grid (filled/empty circles).
"FOUNDATION" section label. Module cards (vertical list): numbered circle +
title + subtitle + arrow. States: locked (50% opacity + lock), in-progress
(saffron left border), completed (green check). More levels below.

**Problems:** Streak heatmap is first — wrong priority (did you study? vs.
what will you study?). Module cards look like a to-do list. Level headers
same visual weight as subtitles. Locked = grey/broken-looking. Zero journey
narrative. Compare to Duolingo's winding skill tree.

---

### SCREEN 9: MODULE READER (full-screen immersive)

**Today:** No AppBar. Top: LinearProgressIndicator (saffron) + "X/Y" counter
+ module title caption. Full-screen card: card type label ("CONTENT" /
"ANCHOR VERSE" / "REFLECT" in saffron) + title labelLarge + body Lora.
Anchor verse cards: Sanskrit + brief note. Reflection cards: question text.
Bottom: "Tap anywhere to continue" hint text. Final card: "Module complete"
+ book recs + "Next module."

**Problems:** "Tap anywhere to continue" patronizing after card 1. "CONTENT"
type label meaningless to user. Progress bar = buffering feel. Anchor verse
cards identical to content cards — deserve hero treatment. No atmosphere.
Completion card = PowerPoint last slide.

---

### SCREEN 10: BOOKMARKS

**Today:** AppBar "Saved Verses" + count badge. Vertical VersePreviewTile
list + swipe-to-delete. Empty state: bookmark outline 56px icon + "like a
flower at the altar" caption + "Browse the library" button.

**Problems:** Beautiful empty state copy killed by generic icon. Filled
state is just a grey list — bookmarked verses deserve more than timestamps.
No organization at all. Swipe-to-delete undiscoverable.

---

### SCREEN 11: SETTINGS

**Today:** AppBar "Settings". Sections: APPEARANCE (light/dark/system toggle),
READING PREFERENCES (font size slider + reading mode chips), ABOUT (credits,
rate, version).

**Problems:** Functional but clinical. No user profile/identity. App knows
user's level but shows nothing personal. No practice personalization.

---

### SCREEN 12: FESTIVALS / PANCHANG

**Today:** AppBar "Festivals & Panchang". Today's panchang as dense text row
(tithi, vara, nakshatra). Vertical scrollable list of festival cards:
emoji + name + date + category chip + countdown.

**Problems:** Panchang = opaque wall of Sanskrit terms. Festival cards all
identical weight (Diwali = minor observance visually). No calendar view.

---

## THE SHARE CARD (surface 13 — #1 viral loop)

PNG image card generated when user taps Share on any verse. Shared on
WhatsApp groups (200+ people), Instagram Stories, Twitter. This IS the
app's primary word-of-mouth growth mechanism.

**Current:** #0F0F0F bg. Scripture name Outfit 10px saffron caps lS 2.0.
Sanskrit TiroDevanagari 18px warm ivory centered lh 2.0. Thin brown rule.
English Lora 14px muted warm white max 3 lines. "BG · 2.47" + "Sanatan Guide"
tiny caps.

**Problem:** Looks like a developer's dark mode screenshot. Not shareable art.

---

## EXISTING INTERACTIONS

```
Gestures: swipe Verse Detail → prev/next verse (velocity >300)
          swipe Bookmarks tile → delete

Haptics: verse navigation (light), module advance (light)

Animations (flutter_animate):
  Sanskrit entry: fade + slideY, 400ms easeOutCubic
  Page transitions: slideRight / fade+slideUp, 300ms

Missing:
  Bookmark tap: needs scale + color satisfaction
  Module completion: needs celebratory pulse (not confetti)
  Reading mode switch: should animate content changing
```

---

## BUSINESS CONTEXT

- Revenue: Google AdMob (interstitial post-module + app-open ad)
- All content free. No paywall. No subscriptions.
- Primary growth: WhatsApp share card (viral loop)
- Must feel premium vs. Calm ($70/yr), Headspace, Apple Books

---

## REFERENCE APPS (be this specific when citing)

| App | Screen | What to steal |
|-----|--------|---------------|
| Headspace | Today tab | Single hero card. One action. Time-aware greeting. |
| Headspace | Meditation player | Full-screen immersive. Progress as arc. |
| Calm | Sleep Stories list | Editorial cards. Atmospheric photography. |
| Calm | Daily Calm player | Minimal chrome. Content dominates. |
| Apple Books | Reading page | Content IS design. Tap reveals chrome. |
| Quran Majeed | Surah reading | Arabic + transliteration + translation layers. |
| Day One | Journal entry | Warm, personal. Writing feels sacred. |
| Medium | Article reader | Typography as experience. 65–75 char line-length. |
| Duolingo | Skill tree | Winding path. Landscape chapters. Journey feel. |

---

## YOUR OUTPUT — THE ULTIMATE UI/UX PLAN

---

### PART 1: GLOBAL DESIGN DECISIONS (5 decisions)

**1.1 Saffron Economy** — list exactly where saffron appears and explicitly
where it must be REMOVED.

**1.2 Tab Rename + Custom Icons** — recommend names and describe the 3 custom
icons (specific metaphor, line-art vs filled, what each communicates).

**1.3 Dark Mode as Hero** — should dark be the app's identity / default
marketing mode? Justify.

**1.4 Focus Reading Mode** — define the universal reading-mode interaction:
does tapping hide/reveal chrome? Is there a dedicated button? How does
it activate/deactivate across Verse Detail and Module Reader?

**1.5 Empty State Visual Language** — propose ONE consistent metaphor for
all empty states. Must be achievable without a design team.

---

### PART 2: PER-SCREEN REDESIGN (all 12 screens + share card)

For each screen use this format:

```
## [SCREEN NAME]

Emotional Arc: (one sentence — what does the user feel when it opens?)
Hero Element: (the single dominant element above the fold)
Remove: (the one thing hurting this screen most)

Layout: (detailed — above-fold composition, scroll behavior, key measurements)
Typography: (which style for which element)
Spacing: (specific padding/gap decisions)
Color & Visual: (where saffron, surfaces, any texture)
Micro-interactions: (animations — trigger, duration, curve, widget)
Flutter Notes: (specific widget recommendations for non-obvious choices)
Reference: [App — specific screen — what to steal]
```

Spend the most words on **Verse Detail (Screen 7)** and
**Module Reader (Screen 9)**. These are the soul of the app.

---

### PART 3: CROSS-CUTTING DECISIONS

**3.1 Onboarding Flow** — describe the complete first-time user journey
from splash to first meaningful content. Include the "welcome ceremony."
Should there be a "first verse gift" moment?

**3.2 Share Card Redesign** — answer:
  1. What visual treatment stops someone scrolling WhatsApp?
  2. How to make Sanskrit feel like sacred calligraphy, not a font?
  3. Decorative element (mandala/lotus border) vs. pure typography?
  4. Aspect ratio strategy for WhatsApp (square) and Instagram Stories (9:16)?
  5. How does "Sanatan Guide" branding appear?

**3.3 Daily Notification** — what should it feel, read, and look like?
Make it feel like receiving a blessing, not a push notification.

**3.4 Animation Spec** — list every animation in the redesigned app:
trigger / duration / curve / flutter_animate technique.

---

### PART 4: PRIORITY MATRIX

| Priority | Screen | Change | Effort (S/M/L) | Impact |
|----------|--------|--------|----------------|--------|
| P0 | ... | ... | ... | ... |

P0 = This week (max impact, min effort)
P1 = This sprint
P2 = Next sprint
P3 = Nice to have

---

### PART 5: NORTH STAR SCREEN

Pick ONE screen that — if executed perfectly — would make a designer at
Apple or Headspace say "this team knows what they're doing."

Describe it in obsessive detail: every layout measurement, every animation
frame, every typographic decision. This is the screen built first to
establish the visual language for the entire app.

---

## HARD CONSTRAINTS (non-negotiable)

- Flutter Material Design 3 only. No UIKit. No custom renderers.
- Colors: Saffron #E8820C, Cream #FDFAF6, Dark #0F0F0F — fixed.
- Fonts: TiroDevanagari / Lora / Outfit — fixed.
- Sanskrit always displayed prominently — it is primary content.
- No heavy illustrations requiring a design team.
- Animations: 60fps, flutter_animate, no Lottie files.
- Contrast: 4.5:1 minimum. Tap targets: 44×44px minimum.
- Horizontal padding: 24dp (pagePadding). Never below 20dp.
- Border radius: use tiered system (4/8/16/24dp). Never 0 or 999.

---

## TONE OF RESPONSE

- **Specific.** "32dp gap between Sanskrit and English" not "add whitespace."
- **Opinionated.** If something must be torn out, say so directly.
- **Culturally aware.** Indic aesthetics ≠ generic "spiritual app."
  Reference manuscript traditions, temple proportions where appropriate.
- **Technically grounded.** Name Flutter widgets. Name packages.
- **Acknowledge what works.** Dark mode surface hierarchy, three-font
  system, spacing grid, and tiered border radius are well-designed.
  Build on them, don't replace them.

---

*Sanatan Guide · The definitive Hindu scripture app*
*Sacred Minimalism · Flutter · Material 3*
