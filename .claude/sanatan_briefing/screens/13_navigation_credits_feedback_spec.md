# Screen 13 — Navigation Chrome, Credits, Send Feedback Spec

**Routes:** Topbar composed into Home/Library/Practice · `/credits` · `/feedback`
**Mockup:** `mockups/screen-13-navigation-credits-feedback.html`
**Build order:** #14 (last)

---

## Part A — Topbar icons (Home + Library)

The Home and Library topbars share three trailing icons. This part defines them.

### Icons (in order, left to right after the brand/search field)

1. **Search icon** (Home only; Library has inline search field instead)
   - 20×20 magnifying glass, dText1 color
   - 40×40 hit target
   - Tap → `/search` with field auto-focused

2. **Bookmark icon**
   - 20×20 bookmark glyph (outlined, not filled), dText1 color
   - 40×40 hit target
   - Tap → `/bookmarks`
   - Optional saffron dot indicator (designed in for v2; never shown in v1)

3. **Overflow ⋯ icon**
   - Three 1.7px circles, dText1 color
   - 40×40 hit target
   - Tap → open Overflow Menu popover

### Overflow Menu popover

- **Position:** Top-right, anchored to the ⋯ icon, 12px below the topbar
- **Container:** 220px wide, dSurface2 background, 1px dDivider border, 8px radius
- **Shadow:** 0 8px 24px rgba(0,0,0,0.4) on dark, 0 4px 16px rgba(0,0,0,0.08) on light
- **Backdrop:** 55% black full-screen, dismissible on tap
- **Animation:** 180ms scale 0.96→1.0 + fade from top-right transform origin

**Five items (in order):**

| Order | Label | Route | Icon |
|---|---|---|---|
| 1 | Settings | `/settings` | gear |
| 2 | Festivals & Calendar | `/festivals` | calendar |
| 3 | Ask the Pandit | `/chat` | ॐ in deva font |
| 4 | Send feedback | `/feedback` | speech bubble |
| 5 | About this app | `/credits` | info circle |

**Each row:**
- 44px tall (hit target)
- 16px horizontal padding
- Icon (16×16) on left, dText2 color
- Label in Lora 14.5px w400 dText1
- 1px dDividerSoft bottom border (except last row)
- Tap → dismiss menu (180ms reverse animation) + navigate

---

## Part B — Credits screen (`/credits`)

### Layout

1. **Topbar** — Compact back-only. Title "About this app" in Lora italic 16px saffron.

2. **Hero header** — Centered, 60px top padding:
   - ॐ logomark in Tiro Devanagari 56px saffron with glow
   - 12px gap
   - "Sanatan Guide" in Lora 24px w500 cream, centered
   - Version "v1.0.0" in sans 11px dText3 small-caps tracked, centered, 4px below

3. **48px gap**

4. **Mission paragraph** — Lora italic 15px line-height 1.7, dText2, centered, max-width 320px, 24px horizontal padding:
   > "An offline reader for the Hindu corpus — 1,33,613 verses across 31 scriptures. Made for readers who want depth without dogma."

5. **40px gap**

6. **Sūtra-style enumerated sections** — Each section follows this pattern:
   - Section header: Devanāgarī numeral (१, २, ३...) in Tiro Devanagari 18px saffron + section name in Lora italic 17px cream. 1px dDividerSoft bottom border with 12px padding-bottom.
   - Section body: list of attributions, each row 44px tall, separated by 1px dDividerSoft.

   **Sections:**

   **१ · Textual Sources**
   - GRETIL — Göttingen Register of Electronic Texts in Indian Languages → external link
   - sacred-texts.com (Griffith translations) → external link
   - Project Madurai (Tirukkuṛaḷ corpus) → external link
   - indic-transliteration library → external link

   **२ · Typography**
   - Tiro Devanagari Sanskrit — Indian Type Foundry (OFL)
   - Lora — Cyreal (OFL)
   - Outfit — Indian Type Foundry (OFL)
   - Noto Sans Devanagari — Google (OFL)

   **३ · Built with**
   - Flutter — Google
   - Riverpod, Drift, GoRouter — open source ecosystem
   - Gemini AI — Google (for AI chat)

   **४ · Made by**
   - Saurabh Upadhyay — solo developer
   - "Sanatan Guide is not affiliated with any religious organization."

   **External-link rows:** Show small ↗ arrow on right edge (11×11, dText3). Tap → opens URL via url_launcher.

7. **Lineage footer** — At bottom of scroll:
   - BindingLine widget
   - 24px vertical padding
   - Bṛhadāraṇyaka blessing in Tiro Devanagari 13px saffronDeep, centered:
     > सर्वे भवन्तु सुखिनः ।
     > सर्वे सन्तु निरामयाः ।
     > सर्वे भद्राणि पश्यन्तु ।
     > मा कश्चिद् दुःखभाग्भवेत् ॥
   - 12px gap
   - English translation in Lora italic 12.5px dText3, centered:
     > "May all be happy. May all be free from illness. May all see what is good. May none suffer." — Bṛhadāraṇyaka Upaniṣad 1.4.14
   - BindingLine widget

---

## Part C — Send Feedback flow (`/feedback`)

### Step 1: Pick kind

1. **Topbar** — Back-only. Title "Send feedback" in Lora italic 16px saffron.

2. **80px top padding**

3. **Heading** — "What's on your mind?" in Lora 22px w500 cream, centered, max-width 280px.

4. **Subhead** — "Pick the kind of message — it helps me get to your note faster." in Lora italic 13.5px dText2, centered, 14px below heading.

5. **32px gap**

6. **Four kind cards** — Stacked, 16px gap between, 24px horizontal margin:
   - **Bug report** — "Something is broken, behaving wrong, or crashing."
   - **Idea** — "A feature, content, or improvement you'd like."
   - **Text error** — "A translation, transliteration, or Sanskrit typo."
   - **Something else** — "Anything that doesn't fit the others."

   Each card: 64px tall, dSurface, 1px dDivider, 4px radius. Title in Lora 15px w500 cream. Description in Lora italic 12.5px dText2.

7. **Tap a card** → navigates to compose step with `kind` pre-selected.

### Step 2: Compose

1. **Topbar** — Back to step 1 + "Send feedback" title

2. **Kind label** — Small-caps sans 10px tracked dText3 ("BUG REPORT" / "IDEA" / etc.), 16px top padding, 24px horizontal

3. **Subject field** — Optional, single-line text input. Outfit 15px. Placeholder "Brief subject (optional)". Bottom border 1px dDividerSoft. 14px vertical padding.

4. **24px gap**

5. **Body field** — Multi-line text area, min-height 240px. Lora 15px line-height 1.6 cream. Placeholder "Describe what's on your mind. The more specific, the better — line numbers, scripture coordinates, exact wording all help."

6. **Char counter** — bottom-right of body, sans 10px dText3, "0 / 2000"

7. **Flexible spacer**

8. **Email row (optional)** — "Reply email (optional)" label + input field. Small note: "Only if you want a response. Otherwise leave blank."

9. **Primary "Send" button** — Saffron pill, full-width minus 48px margins, disabled until body has ≥10 chars

### On Send tap

- Compose mailto link: `mailto:feedback@sanatanguide.app?subject=[KIND] Subject&body=BODY` (or POST to a hosted endpoint if Saurabh sets one up later — v1 uses mailto)
- Open in system email client
- After return, show toast "Thanks. I'll read every word."
- Pop back to previous screen

---

## Data shape

```dart
// Credits doesn't need state — it's a static screen with hard-coded
// attributions. Just a stateless widget reading from a const list.

class CreditEntry {
  final String name;
  final String? subtitle;  // license, role
  final String? url;       // null = no external link
}

const creditSections = <(String, String, List<CreditEntry>)>[
  ('१', 'Textual Sources', [
    CreditEntry(name: 'GRETIL', subtitle: 'Göttingen Register...', url: 'https://gretil.sub.uni-goettingen.de/'),
    // ...
  ]),
  // ...
];

// Feedback state
enum FeedbackKind { bug, idea, textError, other }

class FeedbackState {
  final FeedbackKind? kind;
  final String subject;
  final String body;
  final String email;
}
```

---

## States

**Topbar/Overflow:**
- Closed (default)
- Open (menu visible, backdrop scrim)

**Credits:**
- Loaded (default — all content static, no loading)

**Feedback Step 1:**
- Default

**Feedback Step 2:**
- Empty (Send disabled)
- Has content < 10 chars (Send disabled)
- Has content ≥ 10 chars (Send enabled)
- Sending (button shows AIThinkingDots, disabled)
- Sent (toast shown, popped back)

---

## Cross-refs

**Topbar icons reachable from:**
- Home (all 3 icons)
- Library (Bookmark + ⋯ only; search is inline field)
- Practice (only ⋯)

**Credits reached from:**
- Settings → "Credits & attributions" row
- Home/Library/Practice overflow → "About this app"

**Feedback reached from:**
- Settings → "Send feedback" row
- Home/Library/Practice overflow → "Send feedback"

**Routes to:**
- Each overflow menu item → its respective route
- External link in Credits → opens browser via url_launcher
- Send button → opens system email client via mailto

---

## Motion

- Overflow menu: 180ms scale 0.96→1.0 + fade from top-right
- Backdrop: 200ms fade
- Menu row tap: 100ms ripple in dSaffronGlow before navigating
- Feedback step 1 → 2: 280ms slide-left page transition
- Send button while sending: AIThinkingDots inside button, button bg fades to 60% opacity

---

## Accessibility

- Overflow menu rows: `Semantics(label: 'Settings', button: true, onTap: ...)`
- Credits external links: `Semantics(label: 'GRETIL, opens external link', link: true)`
- Feedback body field: `Semantics(label: 'Feedback body', multiline: true, maxLength: 2000)`
- Kind cards: `Semantics(label: 'Bug report. Something is broken, behaving wrong, or crashing.', button: true)`

---

## Known fixes

None specific.

---

## Files Claude Code will create

- `lib/core/widgets/app_topbar.dart` — composable topbar with icon slots
- `lib/core/widgets/overflow_menu.dart` — the popover + items
- `lib/features/credits/credits_screen.dart`
- `lib/features/credits/widgets/credit_section.dart`
- `lib/features/feedback/feedback_screen.dart`
- `lib/features/feedback/feedback_state.dart`
- `lib/features/feedback/widgets/kind_card.dart`

---

**End of spec.**
