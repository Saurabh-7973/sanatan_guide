# Screen Spec — Navigation Architecture, Credits, Send Feedback

> **Build order:** Topbar #3 (with Home); Credits #14; Feedback #15
> **Mockup file:** `mockups/screen-13-navigation-credits-feedback.html`
> **Routes:** `/credits` (and `/settings/credits`), `/feedback` (and `/settings/feedback`)

This spec covers three connected pieces: (a) the Home/Library topbar with Search/Bookmark/⋯ icons, (b) the Credits & Attributions screen, (c) the Send Feedback screen.

---

## Part A — Home & Library topbar

### A.1 Home topbar

**Layout (left to right):**
1. Brand wordmark `सनातन` — Tiro Devanagari, 22 px, saffron
2. Flex spacer
3. Three trailing icon buttons (40×40 hit target, transparent background, 20×20 SVG icon, stroke-width 1.6):
   - Search (magnifying glass)
   - Bookmark (folded bookmark glyph) — with optional small dot indicator (6×6 saffron circle, top-right of icon button at coords 10,10) that appears when there are new/unread bookmarks (v2 affordance; in v1 the indicator never shows)
   - Overflow (⋯ horizontal three dots)

Topbar padding: 6 px top, 14 px bottom, 24 px left (for brand), 16 px right.

### A.2 Library topbar

Same as Home topbar EXCEPT no separate search icon — the inline search field at the top of the list is the search affordance. So trailing icons are:
- Bookmark
- Overflow (⋯)

### A.3 Overflow menu

**Trigger:** Tap the ⋯ icon. Active icon background fills with `dSaffronGlow` (12% saffron).

**Visual:**
- Backdrop scrim: 55% black, full-screen, dismissible on tap
- Menu popover: 220 px wide, anchored top-right at coordinates (right: 16, top: 80)
- Background: dark theme `dSurface2`, light theme `#fff`
- Border: 1 px `dDivider` / `lDivider`
- Radius: 8 px
- Shadow: `Glows.overflowMenuDark`
- Entry animation: 180 ms scale (0.98 → 1.0) + fade, transform-origin top-right

**Items (each row):**
- 13 px vertical padding, 18 px horizontal
- Icon (16×16, opacity 0.7, saffron color)
- Label (Outfit, 13.5 px, w500, `dText1`)
- 1 px `dDividerSoft` separator between rows (none on last)

**Three items:**
1. Settings (sun/gear icon) → routes to `/settings`, dismisses menu
2. Send feedback (paper plane / pen icon) → routes to `/feedback`
3. About this app (info circle icon) → routes to `/credits`

### A.4 Drill-down screens

Chapter List, Verse List, Verse Detail, AI Chat, Festivals, Practice modules:
- Back-button only on the topbar
- NO search/bookmark/overflow icons

Exception — Verse Detail has its own action bar with bookmark-toggle, share, "Explain this verse" (verse-scoped, not navigation).

### A.5 Acceptance criteria — topbar

- [ ] Home topbar shows brand + 3 icons (search, bookmark, ⋯)
- [ ] Library topbar shows inline search field + 2 icons (bookmark, ⋯)
- [ ] Search icon → `/search` with autofocus
- [ ] Bookmark icon → `/bookmarks`
- [ ] ⋯ icon opens overflow menu with backdrop scrim
- [ ] Menu items route correctly (Settings → `/settings`, Feedback → `/feedback`, About → `/credits`)
- [ ] Tap scrim dismisses menu
- [ ] Drill-down screens have back-button only

---

## Part B — Credits & Attributions

### Route
`/credits` (also `/settings/credits` as alias)

### Layout

1. **Back-arrow topbar** (no title text; clean)
2. **Hero block** (24 px h-padding, 14 px bottom):
   - Small-caps label: "श्रद्धा · WITH GRATITUDE" — `AppText.sectionLabel`, saffron
   - Title: "Credits & Attributions" — Lora 26 px w500, line-height 1.15, letter-spacing -0.02em
   - Prose (Lora italic 14 px, line-height 1.6):
     > "Every verse in this app comes from a real academic source. Nothing is invented. The texts are public domain; the digitisation work that made them readable is not. We acknowledge it here."

3. **Sections** — grouped by domain, with these headers:
   - "Vedas & Upaniṣads"
   - "Itihāsa & Purāṇa" (if applicable to your sources)
   - "Darśana texts"
   - "Tamil traditions"
   - "Tools used in preparing this app"

   Each section header is small-caps `AppText.sectionLabel` in `dText3` with a 1 px bottom border in `dDivider`.

4. **Credit row structure** (per row):
   - Padding: 14 px vertical
   - Gap: 14 px between marker and body
   - Devanāgarī numeral marker (१ २ ३...) in `Fonts.deva`, 14 px, saffron, 16 px wide column, center-aligned
   - Body:
     - Title (Lora 15 px w500). May contain inline saffron Devanāgarī term (e.g., `GRETIL`)
     - Description (Lora italic 12.5 px, line-height 1.5)
     - Meta line (`AppText.sectionLabel` style at 9.5 px): "Universität Göttingen · Public domain"
   - External-link arrow (11×11 SVG, opacity 0.4, top-aligned) on rows that link externally
   - 1 px `dDividerSoft` between rows (none on last)
   - Numerals reset to १ at the start of each section

5. **Lineage footer** (28 px top margin, 24 px h-margin, 32 px bottom):
   - Bordered card (1 px `dDivider`), radius 4 px, padding 22 px, background `dSurface`
   - Top: `BindingLine` widget (palm-leaf binding marker)
   - Centered Devanāgarī blessing (Lora `Fonts.deva`, 18 px, line-height 1.4):
     > सर्वे भवन्तु सुखिनः ।  
     > सर्वे सन्तु निरामयाः ॥
   - Attribution (Lora italic 12.5 px, line-height 1.5):
     > "May all be happy. May all be free of suffering."  
     > — Bṛhadāraṇyaka Upaniṣad 1.4.14

### Required sources (do not omit)

These must appear in v1:

| Section | Entry |
|---|---|
| Vedas & Upaniṣads | GRETIL — Göttingen Register of Electronic Texts (Vedas, Chāndogya/Bṛhadāraṇyaka Upaniṣads, Bhāgavata Purāṇa, Yoga Sūtras, etc.) |
| Vedas & Upaniṣads | Ralph T.H. Griffith's Vedic translations — sacred-texts.com |
| Tamil traditions | Project Madurai — Tirukkuṛaḷ |
| Tools | indic-transliteration (Python) — IAST ↔ Devanāgarī |
| Tools | Tiro Devanagari Sanskrit · Lora · Outfit · Noto Sans Devanagari — OFL |
| Tools | Flutter · Riverpod · Drift — BSD · MIT · Apache 2.0 |

Plus any specific Purāṇa or smaller Upaniṣad sources used in your seeding.

### Animations
Credit rows fade up with 40 ms stagger.

### Acceptance criteria — Credits

- [ ] Back arrow returns to previous (Settings or Home)
- [ ] All required sources present
- [ ] Sections grouped by domain (not alphabetical)
- [ ] Devanāgarī numerals (१ २ ३) used for enumeration, in saffron
- [ ] External-link arrows on rows that link out
- [ ] Lineage footer with BindingLine widget + Bṛhadāraṇyaka blessing
- [ ] Both themes render correctly
- [ ] Fade-up animation on row entry

---

## Part C — Send Feedback

### Route
`/feedback` (also `/settings/feedback` as alias)

### State A — Pick Kind

**Layout:**
1. Back-arrow topbar
2. Hero block (24 px h-padding):
   - Title: "Send feedback" — Lora 24 px w500
   - Prose (Lora italic 13.5 px, line-height 1.55):
     > "We read every message. The app is built and maintained by one person — your reports and ideas shape what comes next."
3. Section label "WHAT KIND OF FEEDBACK?" with 1 px bottom border
4. Four kind rows:

| Title | Description | Icon |
|---|---|---|
| Bug report | "Something is broken or behaves unexpectedly." | exclamation in circle |
| Idea or suggestion | "A feature you'd love to see." | star outline |
| Text or translation error | "A typo, misattribution, or scholarly correction." | document with lines |
| Something else | "A general thought or thanks." | speech / circle |

Each row:
- 14 px vertical padding
- 32×32 circle icon (1 px border `dDivider`, 14 px SVG inside, saffron color)
- Title (Lora 15 px w500) + description (Lora italic 12.5 px line-height 1.4)
- Right chevron arrow
- 1 px `dDividerSoft` separator

Tap routes to **State B** with the kind pre-selected.

### State B — Compose

**Layout:**
1. Back-arrow topbar (back returns to State A)
2. Hero with updated prose based on selected kind. Example for "Text or translation error":
   - Title: "Text or translation error"
   - Prose: "Be specific where you can — verse coordinate, scripture name, what looks wrong. The more context, the faster the fix."
3. Compose section:
   - Meta row (14 px vertical, 1 px bottom border):
     - Saffron pill (rounded 14 px) showing kind name with small icon, 5 px vertical / 12 px horizontal padding
     - Right side: "v1.0.0 · build 1" in `AppText.metaLabel`, `dText3`, right-aligned
   - Textarea (min 220 px tall):
     - Lora regular 14.5 px, line-height 1.65, padding 18 px vertical
     - Placeholder: kind-specific (e.g., "Describe what you noticed. Include verse coordinate (e.g., BG 2.47) where relevant.")
     - Background: transparent, no border
   - Attachment checkboxes (12 px vertical, 1 px top border on first):
     - "Attach device info (OS, app version, locale)" — **default checked**
     - "Allow me to reply via email" — **default unchecked**
     - Checkbox: 18×18 rounded 4 px, 1.5 px border. Checked = filled saffron with white check.
4. Bottom action area:
   - Primary "Send" button — disabled until textarea has content

### Submission

For v1: Open `mailto:` with subject `[Sanatan Guide · {kind}]` and body containing:
- User's message
- Optional device info if checked: OS, app version, locale, build
- "Allow reply" flag (informational)

Email destination: `feedback@sanatanguide.app` (or your real address).

For v2+: Replace with a backend POST. UI stays identical.

### Acceptance criteria — Feedback

- [ ] State A shows 4 kind rows
- [ ] Tapping a kind routes to State B with kind pre-selected
- [ ] Compose state shows saffron pill with kind + version metadata
- [ ] "Attach device info" defaulted ON, "Allow reply" defaulted OFF
- [ ] Send disabled while textarea empty
- [ ] Send opens `mailto:` (v1) with proper subject/body
- [ ] Back from State B returns to State A
- [ ] Both themes render correctly

---

## Tokens & widgets used (all three parts)

- All token usage from MASTER_CONTEXT § 3
- `BindingLine` widget for Credits lineage footer
- `DandaCoord.toDevanagari(int)` helper to render numerals १ २ ३...
- `AppText.sectionLabel`, `AppText.subtitle`, `AppText.rowLabel`, `AppText.rowSub`, `AppText.moduleTitle`, `AppText.moduleDesc`, `AppText.meta`, `AppText.primaryButton`, `AppText.commentary`, `AppText.invocation` (for `सनातन` brand if desired)
- No new widgets needed — compose from existing primitives

---

## Don'ts

- ❌ Don't add a hamburger menu anywhere
- ❌ Don't add Search/Bookmarks/Settings as bottom-nav tabs
- ❌ Don't surface topbar icons on drill-down screens
- ❌ Don't add deity images, mandalas, or lotus motifs to Credits
- ❌ Don't make the Feedback compose textarea single-line
- ❌ Don't default "Allow reply by email" to ON — privacy-respecting defaults
- ❌ Don't list credits alphabetically — group by domain
- ❌ Don't use Lora italic for the textarea body (regular, not italic)
- ❌ Don't render verse coordinates anywhere on Credits — coordinates are for verse refs, not source enumeration
