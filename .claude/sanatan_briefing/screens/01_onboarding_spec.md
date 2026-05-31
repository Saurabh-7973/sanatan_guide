# Screen 11 — Onboarding Spec

**Route:** `/onboarding/welcome`, `/onboarding/reminder`
**Mockup:** `mockups/screen-11-onboarding.html`
**Build order:** #2
**Status:** Spec complete. Reference template for other specs.

---

## Goal

Get the user from app-open to first meaningful action in under 30 seconds, while collecting only what we genuinely need to personalize the experience: their reading level + an optional reminder preference.

**Constraint:** No name field. No email. No account. No religious-affiliation question. The app should feel like opening a book, not signing up for a service.

---

## Two screens only

Previous design had 3 screens. We merged Welcome + Level Selection into one because:
- The level selection IS the welcome action — there's no reason to gate it behind a tap
- Faster onboarding = higher completion
- The page already has visual room

### Screen 1: `/onboarding/welcome`

Reached: First app launch (when `onboardingCompleted == false`)

**Layout (top to bottom):**

1. **Status bar** — system default

2. **Top spacer** — 60px

3. **ॐ logomark** — Tiro Devanagari, 64px, saffron, centered. With 16px blur saffron-glow text-shadow.

4. **Invocation watermark** — "॥ श्री गणेशाय नमः ॥" in Tiro Devanagari 14px, saffronDeep, 50% opacity, centered, 8px below logomark. Traditional invocation before beginning anything; signals the app's voice.

5. **24px gap**

6. **Welcome line** — "Welcome to Sanatan Guide" in Lora 24px w500 cream, centered.

7. **Subtitle** — "Sacred texts, with the care they deserve." in Lora italic 14.5px dText2, centered.

8. **40px gap**

9. **"How familiar are you?" prompt** — Lora 17px w500 cream, centered.

10. **12px gap**

11. **Level cards** — 3 stacked rows, each 72px tall, full-width minus 24px margins, dSurface background, 1px dDivider border, 4px radius. 16px vertical gap between cards.

   - **LeafThread** on left edge of the SELECTED card (transitions on tap)
   - **Content per card:**
     - Devanāgarī level label in Tiro Devanagari 16px saffron (e.g., "प्रारम्भ", "अध्ययन", "विद्वान्")
     - English label in Lora 15px w500 cream
     - Description in Lora italic 12.5px dText2 — single line
   - Tap → updates selected state with 200ms LeafThread slide-in animation

   **Cards:**
   - प्रारम्भ — Beginner — "I've heard of the Gītā. That's about it."
   - अध्ययन — Regular — "I've read some, I'm here to read more."
   - विद्वान् — Scholar — "I know the texts. I want a better tool."

12. **Flexible spacer**

13. **Continue button** — Saffron pill, 50px tall, 28px radius, full width minus 48px margins. Sans 13px w600 uppercase tracked. Disabled until a level is selected.

14. **Skip text button** — "Skip for now" in sans 11px dText3, centered, 16px below Continue. Tap → completes onboarding with default level=regular, reminderEnabled=false.

15. **Bottom safe area padding**

**On tap Continue:**
- Save `level` to SharedPreferences
- Navigate to `/onboarding/reminder`

**On tap Skip:**
- Save level=regular, reminderEnabled=false, onboardingCompleted=true
- Navigate to `/`

### Screen 2: `/onboarding/reminder`

**Layout (top to bottom):**

1. **Back button** — top-left, 36×36 hit target, ← chevron in dText2

2. **Centered bell glyph** — Material Icons or custom 48×48, saffron-deep, centered, 80px from top

3. **24px gap**

4. **Headline** — "A daily verse, on your terms." in Lora 24px w500 cream, centered.

5. **Subtitle** — "Pick a time when you'll actually read. Five minutes is enough." in Lora italic 14.5px dText2, centered, max-width 280px.

6. **40px gap**

7. **Toggle row** — "Daily reminder" + toggle switch. Surface card (dSurface, 1px dDivider, 4px radius). 60px tall. Lora 16px label on left, custom toggle on right.

8. **12px gap**

9. **Time row** — appears only when toggle is ON. Surface card, 60px tall.
   - Label: "Time" in Lora 16px dText1
   - Value: time in Lora 16px saffron (e.g., "7:00 AM")
   - Tap → opens TimePicker bottom sheet (from Screen 16 system chrome)

10. **Flexible spacer**

11. **Primary button** — "Begin reading" (saffron pill)
    - On tap: persist preferences, request system notification permission (if reminderEnabled), navigate to `/`

12. **Skip text** — "Set this up later" in sans 11px dText3 centered, below button

---

## Data shape

```dart
// lib/features/onboarding/onboarding_state.dart

enum UserLevel { beginner, regular, scholar }

class OnboardingState {
  final UserLevel level;
  final bool reminderEnabled;
  final TimeOfDay reminderTime;
  final int currentStep;  // 0 = welcome, 1 = reminder

  const OnboardingState({
    this.level = UserLevel.regular,
    this.reminderEnabled = false,
    this.reminderTime = const TimeOfDay(hour: 7, minute: 0),
    this.currentStep = 0,
  });

  OnboardingState copyWith({...}) {...}
}

// Riverpod provider
final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(...);
```

**Persisted via SharedPreferences (on completion):**
```dart
- user_level: "beginner" | "regular" | "scholar"
- reminder_enabled: bool
- reminder_hour: int
- reminder_minute: int
- onboarding_completed: bool (true)
```

---

## States

- **Initial** — Welcome screen, no level selected, Continue disabled
- **Level selected** — LeafThread shows on chosen card, Continue enabled
- **Reminder step (toggle off)** — Time row hidden, Begin reading enabled
- **Reminder step (toggle on)** — Time row visible, default 7:00 AM, Begin reading enabled
- **Time picker open** — bottom sheet over reminder screen

---

## Motion

- **Entry to Welcome:** ॐ glyph fades in 600ms with subtle scale 0.95→1.0. Invocation fades in 400ms 200ms-delayed. Welcome text + subtitle stagger 100ms each.
- **Level card tap:** LeafThread on previously-selected card animates out (200ms, opacity + 8px translate-x). LeafThread on newly-selected card animates in (200ms, opacity + 8px translate-x from left).
- **Continue button enable:** Fade from 50% to 100% opacity over 200ms.
- **Page transition to reminder:** Slide-left 280ms with subtle fade.
- **Toggle switch:** 220ms easeOut animation.
- **Time row reveal/hide:** AnimatedSize 240ms easeOut.

---

## Cross-refs

**Reached from:**
- App launch (when `onboarding_completed == false`)

**Routes to:**
- `/` (Home) on completion or skip
- TimePicker sheet (modal) from reminder step

**Cannot navigate to:**
- Any other screen during onboarding (back button only exits within the flow)

---

## Accessibility

- **Touch targets:** All interactive elements ≥ 44×44 px
- **Color contrast:** Cream on dBg = AA. Saffron CTA passes AA.
- **Screen reader labels:**
  - Logomark: `Semantics(label: 'Sanatan Guide')`
  - Level cards: `Semantics(label: 'Beginner level: I've heard of the Gita...', selected: isSelected, button: true)`
  - Toggle: standard Switch semantics
- **Skip option ALWAYS available** — never trap users in onboarding

---

## Known fixes (from brief §5)

None specific to Onboarding — this is a clean spec.

---

## What this spec is NOT for

- ❌ Not for "first launch of Practice tab" (different flow, no spec yet)
- ❌ Not for re-onboarding (users who reset data) — same flow, but `onboarding_completed` resets to false
- ❌ Not for system notification permission UI — that's the OS dialog, not ours

---

## Files Claude Code will create

- `lib/features/onboarding/onboarding_screen.dart` — both screens, PageView-based
- `lib/features/onboarding/onboarding_state.dart` — state + notifier
- `lib/features/onboarding/widgets/level_card.dart` — reusable card
- `lib/features/onboarding/widgets/reminder_toggle_row.dart`
- `lib/features/onboarding/widgets/time_row.dart`

---

**End of spec.**
