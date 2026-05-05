# Screen Spec — Onboarding

> **Build order:** #2 (after core widgets are in place)
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
2. Invocation watermark `॥ श्री गणेशाय नमः ॥` — saffron, opacity 0.5, position 56 px from top
3. Step dots — two 5px circles, 6px gap, position 80 px from top, first one active
4. Logomark hero — vertical block:
   - `ॐ` in Tiro Devanagari, 68 px, saffron, with text-shadow glow on dark
   - "Sanatan Guide" — `AppText.screenTitle` 32 px (override), centered
   - Tagline (italic serif): "A reader for Hindu scripture — fully offline, with deep textual care."
   - Incised rule (64 px wide, hairline + center diamond)
5. Level question (28 px top padding, centered):
   - Small-caps label: "TELL US WHERE TO BEGIN"
   - Italic serif: "How familiar are you with the scriptures?"
6. Three level cards (vertically stacked, 10 px gap, 24 px horizontal padding):
   - **Beginner** — "New to the texts. Start with Foundations and gentle commentary."
   - **Regular** — "Comfortable with the basics. Read directly with optional commentary."
   - **Scholar** — "Read texts and transliteration directly. Commentary only when asked."
7. Bottom actions (24 px horizontal padding, 28 px bottom padding):
   - Primary "Continue" button (full-width, 50px tall, saffron, uppercase tracked)
   - "Skip for now" text button below

**Level card structure:**
- Border 1 px `dDividerSoft` (light: `lDividerSoft`)
- Border-radius 4 px, padding 16-22 px
- Title (Lora, 16 px, w500)
- Description (Lora italic, 13 px, line-height 1.4)
- Radio circle on right (18 px)
- **When selected:** Border becomes `dDivider`. Saffron `LeafThread` appears on left edge with `pulseOnce: true`. Radio fills with saffron dot.

**States:**
- **Default:** No card selected. Continue button is disabled (40% opacity).
- **Selected:** Card has leaf-thread + filled radio. Continue enables.
- **Tap "Skip for now":** Sets level to Regular (default), navigates to Screen 2.

**Animations on entry:**
- ॐ fades up (700 ms)
- Title fades up (200 ms delay, 600 ms)
- Subtitle fades up (350 ms delay, 500 ms)
- Meta + rule fade up (480 ms delay, 500 ms)
- Question section fades up (600 ms delay)
- Level cards fade up with 60 ms stagger starting at 700 ms
- Bottom actions fade up at 900 ms

### Screen 2 — Daily Reminder

**Layout:**
1. Status bar
2. Step dots (second one active, 80 px from top — no invocation watermark on this screen)
3. Reminder hero (110 px top padding, centered):
   - Bell glyph in 64 px circle with two faint concentric saffron rings
   - Title "A verse a day" (Lora, 26 px, w500)
   - Body (Lora italic, 14.5 px): "A short morning notification with one verse — chosen for the day. You can change or silence it any time."
4. Time block (32 px top margin, 24 px horizontal):
   - Bordered card with small-caps label "REMIND ME AT"
   - Time display "7 : 00" (Lora, 38 px, saffron)
   - AM/PM toggle (rounded pills, AM active by default)
5. Spacer (flex)
6. Bottom actions:
   - Primary "Enable reminder" button
   - "Not now" text button

**Behavior:**
- Tapping "Enable reminder" triggers system notification permission prompt, then schedules daily local notification at the chosen time.
- Tapping "Not now" sets `reminderEnabled = false` and proceeds to Home.
- Tapping the time block opens a bottom-sheet time picker (same vocabulary as Settings).

**On completion:** Mark `onboardingCompleted = true`, persist preferences, route to `/home`.

---

## Data persisted

```dart
class OnboardingPrefs {
  final UserLevel level;          // beginner | regular | scholar (default: regular)
  final bool reminderEnabled;     // default: false
  final TimeOfDay reminderTime;   // default: 7:00 AM
  final bool onboardingCompleted; // set to true on exit
}
```

Persist using SharedPreferences or your existing prefs system. Read in `home_screen.dart` to determine which Today greeting variant to show.

---

## Tokens & widgets used

- `DColors.saffron` / `LColors.saffron`, `dCream`, `dText1`, `dText2`, `dDivider`, `dDividerSoft`
- `AppText.screenTitle`, `AppText.subtitle`, `AppText.sectionLabel`, `AppText.moduleTitle` (for level card titles), `AppText.moduleDesc`, `AppText.primaryButton`, `AppText.textButton`, `AppText.invocation`
- `LeafThread` (with `pulseOnce: true`) on selected card
- `Fonts.deva` for the ॐ logomark and invocation
- Standard `Curves.easeOut` for fades

---

## Don't

- ❌ Don't add a name field. Greeting on Home is name-less.
- ❌ Don't add a third "identity" question (no "Curious Hindu" framing). Levels are purely about scripture familiarity.
- ❌ Don't add a third level beyond Beginner/Regular/Scholar.
- ❌ Don't add a deity image, mandala, or lotus. The ॐ wordmark is the only logomark.
- ❌ Don't request notification permission on Screen 1. Wait for Screen 2 tap on "Enable reminder."
- ❌ Don't auto-skip to home if onboarding completes. Let the navigation animate naturally.

---

## Acceptance criteria

- [ ] Both dark and light themes render correctly
- [ ] All three level cards selectable; only one selected at a time
- [ ] Continue button disabled until a level is selected
- [ ] "Skip for now" routes to Screen 2 with `level = regular`
- [ ] Step dots reflect current screen (1 or 2)
- [ ] Animations match mockup (ॐ fade-in sequence, leaf-thread pulse on selection)
- [ ] Time picker bottom sheet works on Screen 2
- [ ] Notification permission prompt only fires on "Enable reminder" tap
- [ ] On completion, prefs are persisted and `/home` is loaded
- [ ] Skipping at any point still completes onboarding with sensible defaults
- [ ] Sanskrit `ॐ` and `॥ श्री गणेशाय नमः ॥` use Tiro Devanagari font
- [ ] All text uses styles from `AppText` — no inline `TextStyle` definitions
