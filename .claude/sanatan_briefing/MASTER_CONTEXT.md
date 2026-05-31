# MASTER CONTEXT — Sanatan Guide

> Background reference. The `SANATAN_GUIDE_BUILD_BRIEF.md` is the canonical document. This file fills in deeper context where the brief is terse.

---

## 1. The app, in one line

A fully offline, scholarly, heritage-respecting reader for Hindu scripture — 1,33,613 verses across 31 texts — with a small AI tutor that can explain any verse.

## 2. Who it's for

Three audiences, in this rough order:

1. **English-speaking diaspora Hindus** (US, UK, Canada, Australia) who grew up with stories but never had structured access to the texts themselves. They want depth without dogma.
2. **Indian millennials and Gen Z** who can read Devanāgarī comfortably but want clean translations and modern interaction (search, AI, bookmarks).
3. **Curious non-Hindus** — scholars, comparative-religion readers, philosophers — who want academic-grade access without the politics or kitsch.

NOT for: nationalist users looking for ideological reinforcement. NOT for: devotional users seeking ritual content (puja apps, mantra timers, deity wallpapers — those exist already).

## 3. The voice

**Direct. Scholarly. Restrained.** Saurabh's own writing in the app sets the tone. Examples from his real copy:

- "108 Upanishads exist. Ten of them contain everything."
- "Before the verses, the framework."
- "Hinduism is not a religion in the Abrahamic sense — it has no founder, no single scripture, no creed to recite."

What we DON'T write:
- ❌ "Discover the wisdom of the ancient sages" (generic spiritual)
- ❌ "Unlock divine knowledge today" (gamified)
- ❌ "Begin your spiritual journey 🙏" (emoji)
- ❌ "Top 5 Bhagavad Gita quotes" (clickbait)

The voice should sound like a knowledgeable friend who respects you enough to assume you can handle nuance.

## 4. The aesthetic, deeper than the brief

The brief says "pre-Islamic Indian heritage." Here's the longer version:

**Source materials studied:**
- Pallava temple inscriptions (Mahabalipuram, 7th c.)
- Chola bronze iconography (10th-12th c.) — for line quality, not figuration
- Hoysala temple wall reliefs (Belur, 12th c.) — for the density and discipline of carving
- Palm-leaf manuscripts (taal patra) from Kerala and Odisha — for binding-line motif, ink color, the way text fills a leaf
- Vedic śulba-sūtra geometry — proportions for cards (3:2 Sulba ratio for Vedas grid)
- Mughal-era manuscripts — **excluded intentionally** because they post-date the Sanskrit cultural moment

**Color palette logic:**
- **Saffron** (#E8820C) — kāṣāya, the renunciant's color, the flag color, the dye of the manuscript ink. The hero.
- **Cream** (#F2E5CE) — palm-leaf yellow, aged paper. Text and surface.
- **Iron-red** (#B85A3A) — the cinnabar/red-ochre used in some manuscripts to mark important passages, deity names, or festival days. **Reserved** specifically because manuscripts reserved it.
- **Deep brown / charcoal** (#0F0F0F dark; #2A1E14 light) — ink color, sandstone shadow. The page background.

No blue, no green, no purple — the cool side of the spectrum is foreign to this material culture.

**Typography logic:**
- **Tiro Devanagari Sanskrit** for verses — designed by an Indian type designer for sacred-text rendering. Has proper conjuncts, anusvāra placement, virāma handling.
- **Lora** for body text — a serif with manuscript warmth that works for both English prose and a literary register.
- **Outfit** for UI chrome — geometric sans, contemporary, doesn't fight the serif for attention.
- **Noto Sans Devanagari** as fallback — handles edge cases where Tiro doesn't have a glyph.

## 5. What "heritage signals" mean (and don't mean)

The six primitives in the brief (binding-line, leaf-thread, daṇḍa-coord, Devanāgarī numerals, iron-red ink, AI-thinking dots) are **borrowed manuscript conventions, repurposed for UI**. Each one does work:

- **BindingLine**: marks "this is a leaf-shaped reading surface"
- **LeafThread**: marks "your place / your active / your selection" (the saffron thread tied around a manuscript section)
- **DandaCoord**: gives verse references the same typographic weight they have in print editions
- **Devanāgarī numerals**: signals that we respect the audience's literacy in the script
- **Iron-red ink**: the manuscript reserved this color; so do we
- **AI thinking dots**: not heritage, but ties our AI surface to a recognizable Sanatan Guide vocabulary

What heritage signals are NOT:
- ❌ Marigold borders
- ❌ Lotus watermarks
- ❌ Deity images on cards
- ❌ "Vedic gold" gradients
- ❌ Sanskrit-styled English fonts
- ❌ Diya/lamp icons everywhere
- ❌ Om symbols as decoration

These are decorations that gesture at Hinduism without engaging with its actual material history. Sanatan Guide engages.

## 6. Why no nationalism

A reader scanning the app should NOT be able to identify it with any political position. The app is about the texts, not about contemporary politics. Decisions that follow from this:

- No saffron flags or political iconography
- No "rashtra," "bhārat," or geopolitical framing in copy
- No Ram-temple, Ayodhya, or contemporary religious-political topics
- AI chat avoids political topics (handled in Gemini system prompt)
- Festivals coverage is pan-Hindu and pan-regional (Onam, Pongal, Durga Puja, Diwali, Holi, Vaisakhi all treated equally)

The texts themselves are universal. The app reflects that.

## 7. The economic model

- **Free to download and use.** No paywall.
- **AdMob banner** on Home screen only. No interstitials, no rewarded ads, no native ads in reading flow.
- **Reading flow is sacred** — no ads on Verse Detail, Chapter List, Verse List, AI Chat, Search, Bookmarks, Festivals, Settings, Practice, Module Reader.
- **No data collection** beyond what AdMob requires for ad personalization (which is itself minimized via low-data-collection mode).
- **No user accounts** in v1. All state is local SharedPreferences + SQLite.

V2 may add a "Remove ads + cloud sync" IAP at ~₹99/year. Not v1.

## 8. The technical philosophy

- **Offline-first.** Everything except AI chat works on a plane.
- **Database-first.** Content is in SQLite (Drift), not network. App size includes all 1.3 lakh verses.
- **Lean.** Target APK size <80 MB. Currently ~72 MB.
- **Fast.** Cold start <2 seconds on a mid-range Android phone.
- **Accessible.** Hit targets 44×44, WCAG AA contrast, `lang` attributes for screen readers.
- **No analytics SDKs** beyond Firebase Crashlytics for crashes. No Mixpanel, Amplitude, etc.

## 9. The Gemini AI chat

- Uses Gemini 2.5 Flash (cheaper, faster, sufficient quality)
- System prompt embeds: "Respond in the voice of a learned but humble Sanskrit teacher. Cite verses by scripture and coordinate. Don't invent verses. Decline political questions. Decline questions about other religions except for direct comparison when the user asks. Keep responses under 200 words unless asked for depth."
- Citations rendered as inline cards in chat — tap to navigate to verse
- Two modes: **verse-anchored** (chat about one specific verse) and **general** (free-form questions)
- v1 chat is **per-session** — no persistence. Reduces complexity, avoids privacy concerns.

## 10. Saurabh's working style (for Claude Code to know)

- **Direct feedback preferred.** No hedging, no praise sandwiches.
- **Brutal honesty wanted.** If something is wrong, say so directly.
- **Output-focused.** Copy-paste-ready code; full methods not patch diffs; single-block terminal commands; tables and markdown over conversational prose.
- **Pushes back on inflated content.** Don't pad. Don't repeat. Don't summarize unless asked.
- **Brevity is a value.** A short, dense answer beats a long, well-meaning one.
- **Decisions over options.** If asked "what should I do?", give a recommendation with reasoning, not a 5-option menu.

---

**End of master context. The brief is the contract. This is the why behind it.**
