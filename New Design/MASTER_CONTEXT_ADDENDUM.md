# MASTER_CONTEXT.md — Addendum (Navigation Architecture)

> Add this section to your MASTER_CONTEXT.md, or keep as a separate file the screen specs reference.

---

## 13. Navigation architecture

### 13.1 Bottom navigation (3 tabs)

```
[ Today ]  [ Practice ]  [ Texts ]
```

Three tabs only. **Do not add Search / Bookmarks / Settings as tabs.** That signals shallow structure and crowds the nav.

### 13.2 Home topbar (trailing icons)

The Home screen's topbar has three trailing icons, left to right:

```
सनातन                          [search] [bookmark] [⋯]
```

- **Search** (magnifying glass) → routes to `/search` with field auto-focused
- **Bookmarks** (bookmark glyph) → routes to `/bookmarks`. Shows a small saffron dot indicator if there are new/unread bookmarks (v2 feature; in v1 the indicator never shows)
- **Overflow (⋯)** → opens a popover menu (220 px wide, anchored top-right) with three items:
  - Settings → `/settings`
  - Send feedback → `/feedback`
  - About this app → `/credits` (same destination as Settings → Credits & attributions)

Overflow menu appears with a 55%-black backdrop scrim. Tap scrim to dismiss. Menu items animate in with a brief 180ms ease-out scale/fade from top-right origin.

### 13.3 Library topbar

The Library/Texts screen has its inline search field at the top of the list (existing pattern). Tapping it routes to `/search` with field auto-focused. **Same Search screen, two entry points.**

The Library topbar also has trailing icons for **Bookmarks** and **Overflow (⋯)** — same as Home. Search is not needed as a separate icon here because the inline field is already present.

### 13.4 Drill-down screens (no entry-point icons)

Chapter List, Verse List, Verse Detail, AI Chat, Festivals, Practice modules, and all sub-screens have **only a back button** in their topbar. The user is in a reading or focus flow — do not surface Search/Bookmarks/Settings here.

Exception: Verse Detail has its own action bar with bookmark-toggle, share, and "Explain this verse" — these are verse-scoped actions, not navigation.

### 13.5 Routes summary

```
/                       → Today (Home)
/practice              → Practice / Your Path
/practice/module/:id   → Module reader
/texts                 → Library
/texts/:scripture      → Chapter List
/texts/:scripture/:ch  → Verse List
/texts/:scripture/:ch/:v → Verse Detail
/search                → Search
/bookmarks             → Bookmarks (Pothī)
/festivals             → Festivals (Almanac)
/festivals/:id         → Festival detail
/chat/:verse_id        → AI Chat (verse-anchored)
/settings              → Settings
/settings/credits      → Credits & Attributions (also /credits)
/settings/feedback     → Send Feedback (also /feedback)
/onboarding/welcome    → Welcome + level
/onboarding/reminder   → Reminder permission
```

---

## 14. Sub-screens behind Settings

### 14.1 Credits & Attributions (`/credits`)

Reached from Settings → "Credits & attributions" and from Home overflow → "About this app".

**Structure:**
1. Back-arrow topbar
2. Hero block: small-caps label "श्रद्धा · WITH GRATITUDE" + title "Credits & Attributions" + italic-serif intro prose
3. Sections grouped by domain (not alphabetical):
   - Vedas & Upaniṣads
   - Itihāsa & Purāṇa
   - Darśana texts
   - Tamil traditions
   - Tools used in preparing this app
4. Each credit row: Devanāgarī numeral marker (१ २ ३...) + title + italic description + meta line (license/source)
5. External-link arrow on rows that link out (GRETIL, sacred-texts.com, Project Madurai)
6. Lineage footer: palm-leaf binding-line frame with the Bṛhadāraṇyaka Upaniṣad blessing `सर्वे भवन्तु सुखिनः` and attribution

**Sūtra-style numbering** — each entry uses Devanāgarī numerals (१ २ ३) in saffron, mirroring how classical Sanskrit śāstras enumerate their sources.

**Required attributions** (do not omit any):
- GRETIL (Göttingen) — Vedas, Chāndogya & Bṛhadāraṇyaka Upaniṣads, Bhāgavata Purāṇa, Yoga Sūtras
- sacred-texts.com / Ralph T.H. Griffith — Vedic English translations
- Project Madurai — Tirukkuṛaḷ
- indic-transliteration (Python library) — IAST ↔ Devanāgarī
- Fonts — Tiro Devanagari Sanskrit, Lora, Outfit, Noto Sans Devanagari (Google Fonts, OFL)
- Flutter, Riverpod, Drift — development stack

Plus any additional sources used in seeding (e.g., specific Purāṇa parsers).

### 14.2 Send Feedback (`/feedback`)

Reached from Settings → "Send feedback" and from Home overflow.

**Two states:**

**State A — Pick kind:**
- Back-arrow topbar
- Hero: title "Send feedback" + italic prose framing
- Section label "WHAT KIND OF FEEDBACK?"
- Four kind rows, each with circle icon + title + italic description + arrow:
  - **Bug report** — "Something is broken or behaves unexpectedly."
  - **Idea or suggestion** — "A feature you'd love to see."
  - **Text or translation error** — "A typo, misattribution, or scholarly correction."
  - **Something else** — "A general thought or thanks."

**State B — Compose:**
- Back-arrow topbar (back goes to State A)
- Hero updates with selected kind's name + tailored prose ("Be specific where you can...")
- Selected kind appears as a saffron pill at top with version metadata ("v1.0.0 · build 1") on the right
- Multi-line textarea with kind-specific placeholder
- Two checkboxes:
  - "Attach device info (OS, app version, locale)" — **defaulted ON**
  - "Allow me to reply via email" — defaulted OFF (privacy-respecting)
- Primary CTA "Send" at bottom, disabled until message has content

**Submission:** v1 can simply compose an email to a known address (e.g., `feedback@sanatanguide.app`) with kind/version/device-info pre-filled in subject and body. v2 can add a backend endpoint. The UI is the same either way.

### 14.3 Privacy Policy & Terms of Service

These open external URLs via the browser (no internal screen). Settings rows show the small external-link arrow icon (↗) to signal "leaves the app."

URLs to set (you said the policy is at a public gist):
- Privacy: `https://gist.github.com/Saurabh7973/...` (existing)
- Terms: TBD — can reuse the privacy gist with a Terms section appended, or create a separate page

### 14.4 About this app

Maps to the same Credits screen for v1. If you want a separate "About" later (changelog, version history, philosophy), that's a v2 addition.

---

## 15. Voice in sub-screens

The Credits and Feedback screens use the **same direct, contrarian voice** as the rest of the app:

- Credits opening: *"Every verse in this app comes from a real academic source. Nothing is invented. The texts are public domain; the digitisation work that made them readable is not. We acknowledge it here."*
- Feedback opening: *"We read every message. The app is built and maintained by one person — your reports and ideas shape what comes next."*

These lines do work. They differentiate Sanatan Guide from competitors (most scripture apps don't acknowledge sources properly, and most don't tell users a real person reads feedback). Keep this language.

---

## 16. Implementation notes

- The Home topbar SVG icons (search, bookmark, overflow) should live in `lib/core/widgets/topbar_icons.dart` or be inlined as small icon widgets. Use 20×20 SVG strokes, weight 1.6.
- The overflow menu can be implemented with Flutter's `showMenu()` or as a custom `PopupMenuButton` styled with the design tokens. Either is fine — the visual match matters more than the mechanism.
- The Credits screen's `१ २ ३` numerals use `Fonts.deva` (Tiro Devanagari Sanskrit) with `DColors.saffron` color. Use the helper `DandaCoord.toDevanagari(int)` from `heritage_widgets.dart` to convert numbers.
- The Feedback compose state: textarea uses `Fonts.serif` (Lora regular, not italic). Placeholder uses `Fonts.serif` italic.

---

End of addendum. The screen 13 mockup at `mockups/screen-13-navigation-credits-feedback.html` shows all six frames: Home topbar dark/light, overflow menu open, Credits top + scrolled, Feedback pick + compose.
