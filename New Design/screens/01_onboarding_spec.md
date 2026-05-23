# Screen Spec — Onboarding

> **Build order:** #2 (after core widgets)
> **Mockup file:** `mockups/screen-11-onboarding.html`
> **Routes:** `/onboarding/welcome`, `/onboarding/reminder`
> **State management:** Riverpod (`onboardingProvider`)

---

## Purpose

Calibrate the app to the user's familiarity level (Beginner/Regular/Scholar) and let them opt into a daily reminder before the system permission prompt. **Two screens total.** Skipped users get sensible defaults.

---

## Screens

### Screen 1 — Welcome + Level Selection

**Layout (top to bottom):**
1. Status bar (system)
2. Invocation watermark `॥ श्री गणेशाय नमः ॥` — saffron, opacity 0.5, 56 px from top
3. Step dots — two 5px circles, 6px gap, 80 px from top, first active
4. Logomark hero (vertical block):
   - `ॐ` in Tiro Devanagari, 68 px, saffron, text-shadow glow on dark
   - "Sanatan Guide" — Lora serif, 32 px, w500, centered
   - Tagline (italic serif): "A reader for Hindu scripture — fully offline, with deep textual care."
   - Incised rule (64 px hairline + center diamond)
5. Level question (28 px top padding, centered):
   - Small-caps label: "TELL US WHERE TO BEGIN"
   - Italic serif: "How familiar are you with the scriptures?"
6. Three level cards (stacked, 10 px gap, 24 px h-padding):
   - **Beginner** — "New to the texts. Start with Foundations and gentle commentary."
   - **Regular** — "Comfortable with the basics. Read directly with optional commentary."
   - **Scholar** — "Read texts and transliteration directly. Commentary only when asked."
7. Bottom actions:
   - Primary "Continue" button (full-width, 50px, saffron, uppercase tracked)
   - "Skip for now" text button below

**Level card:**
- Border 1px `dDividerSoft`, radius 4px, padding 16–22px
- Title (Lora 16px w500) + description (Lora italic 13px)
- Radio circle (18px) on right
- **Selected:** Border → `dDivider`. `LeafThread(pulseOnce: true)` on left edge. Radio fills with saffron dot.

**States:**
- Default: No selection. Continue disabled (40% opacity).
- Selected: Card has leaf-thread + filled radio. Continue enables.
- "Skip for now": Sets `level = regular`, navigates to Screen 2.

**Entry animations:**
- ॐ fades up (700ms)
- Title fades up (200ms delay, 600ms)
- Subtitle fades up (350ms delay, 500ms)
- Meta + rule fade up (480ms delay)
- Question section fades up (600ms delay)
- Level cards fade up with 60ms stagger from 700ms
- Bottom actions fade up at 900ms

### Screen 2 — Daily Reminder

**Layout:**
1. Status bar
2. Step dots (second active, 80px from top — no invocation here)
3. Reminder hero (110px top padding, centered):
   - Bell glyph in 64px circle with two faint concentric saffron rings
   - Title "A verse a day" (Lora 26px w500)
   - Body (Lora italic 14.5px): "A short morning notification with one verse — chosen for the day. You can change or silence it any time."
4. Time block (32px top margin):
   - Bordered card with small-caps label "REMIND ME AT"
   - Time display "7 : 00" (Lora 38px, saffron)
   - AM/PM toggle (rounded pills, AM active by default)
5. Spacer (flex)
6. Bottom actions:
   - Primary "Enable reminder" button
   - "Not now" text button

**Behavior:**
- "Enable reminder" → system notification permission prompt → schedule daily local notification
- "Not now" → `reminderEnabled = false`, proceed to Home
- Tap time block → bottom-sheet time picker (same vocabulary as Settings)

**On completion:** `onboardingCompleted = true`, persist prefs, route to `/`.

---

## Data persisted

```dart
class OnboardingPrefs {
  final UserLevel level;          // beginner | regular | scholar (default: regular)
  final bool reminderEnabled;     // default: false
  final TimeOfDay reminderTime;   // default: 7:00 AM
  final bool onboardingCompleted; // set true on exit
}
```

Persist via SharedPreferences. Read in Home to determine greeting variant.

---

## Tokens & widgets used

- `DColors.saffron`/`LColors.saffron`, `dCream`, `dText1`, `dText2`, `dDivider`, `dDividerSoft`
- `AppText.screenTitle`, `AppText.subtitle`, `AppText.sectionLabel`, `AppText.moduleTitle`, `AppText.moduleDesc`, `AppText.primaryButton`, `AppText.textButton`, `AppText.invocation`
- `LeafThread(pulseOnce: true)` on selected card
- `Fonts.deva` for ॐ logomark and invocation

---

## Don't

- ❌ Don't add a name field. Greeting on Home is name-less.
- ❌ Don't add a third "identity" question (no "Curious Hindu" framing).
- ❌ Don't add a third level beyond Beginner/Regular/Scholar.
- ❌ Don't add a deity image, mandala, or lotus.
- ❌ Don't request notification permission on Screen 1.
- ❌ Don't auto-skip to home. Let navigation animate naturally.

---

## Acceptance criteria

- [ ] Dark and light themes render correctly
- [ ] All three level cards selectable; only one selected at a time
- [ ] Continue disabled until a level is selected
- [ ] "Skip for now" routes to Screen 2 with `level = regular`
- [ ] Step dots reflect current screen
- [ ] Animations match mockup (ॐ fade-in sequence, leaf-thread pulse)
- [ ] Time picker bottom sheet works on Screen 2
- [ ] Notification permission only fires on "Enable reminder" tap
- [ ] Prefs persisted, `/` loaded on completion
- [ ] Skipping completes onboarding with sensible defaults
- [ ] Sanskrit `ॐ` and invocation use Tiro Devanagari
- [ ] All text uses `AppText.*` — no inline `TextStyle`
