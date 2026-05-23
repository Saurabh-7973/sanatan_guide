# How to Brief Claude Code

This is your **standard operating procedure** for getting a screen built end-to-end without re-explaining context every time.

---

## Step 1 — One-time repo setup

Add these files to your repo:

```
.claude/
  MASTER_CONTEXT.md              ← read on every session
  MASTER_CONTEXT_ADDENDUM.md     ← navigation + sub-screens
  screen_specs/
    01_onboarding_spec.md
    02_home_spec.md
    ...
    13_navigation_spec.md
mockups/
  screen-01-home.html
  ...
  screen-13-navigation-credits-feedback.html
lib/core/theme/
  design_tokens.dart             ← already provided
  design_typography.dart         ← already provided
lib/core/widgets/
  heritage_widgets.dart          ← already provided
```

**One-time session prompt:**

```
Read .claude/MASTER_CONTEXT.md and .claude/MASTER_CONTEXT_ADDENDUM.md fully
before doing anything else. This is the design system for Sanatan Guide.
You will refer back to these for every screen. Do not deviate from them
without explicit instruction.

Confirm you have read and understood before proceeding.
```

---

## Step 2 — Per-screen prompt template

Fill in the bracketed parts:

```
TASK: Build the [SCREEN NAME] screen for Sanatan Guide.

CONTEXT:
- Read .claude/screen_specs/[XX_screen_name_spec.md] in full.
- Reference visual: mockups/screen-[XX]-[name].html
- All design tokens are in lib/core/theme/design_tokens.dart
- All shared widgets are in lib/core/widgets/heritage_widgets.dart
- The master design system is in .claude/MASTER_CONTEXT.md
  and .claude/MASTER_CONTEXT_ADDENDUM.md — refer back as needed.

CONSTRAINTS:
- Riverpod for state. GoRouter for navigation.
- Use ONLY tokens from design_tokens.dart — no hardcoded colors/fonts.
- Use ONLY styles from design_typography.dart — no inline TextStyles.
- Use existing widgets from heritage_widgets.dart for binding lines,
  leaf threads, daṇḍa coordinates, AI thinking dots, Sanskrit text.
- Both dark and light themes must work from day one.
- Match the mockup visually — allow for natural Flutter rendering
  differences, but structure, hierarchy, and motion must match.

DELIVERABLE:
- New file at lib/features/[feature_name]/[screen_name].dart
- Providers at lib/features/[feature_name]/providers/
- All states from the spec (default, loading, empty, error)
- Both themes rendering correctly
- Animations from the spec

PROCESS:
1. Read the spec file. Confirm understanding.
2. List the files you plan to create.
3. Show me the provider/state shape before writing UI.
4. Build the screen.
5. Run `flutter analyze` and fix any issues.
6. Show me the result.

Do NOT proceed without my approval after step 2.
```

---

## Step 3 — Iteration prompts

After Claude Code shows the first version, iterate with compact prompts:

**Visual fix:** "The [element] doesn't match the mockup. In the mockup it is [describe]. Adjust."

**State fix:** "The [empty/loading/error] state isn't right. The spec says [reference]. Fix."

**Token violation:** "You used a hardcoded [color/font/size]. Replace with token from design_tokens.dart."

**Heritage primitive fix:** "Use HeritageWidgets.[Widget] from heritage_widgets.dart instead of reimplementing."

---

## Order of work

| Step | What |
|------|------|
| 0 | Drop in `design_tokens.dart`, `design_typography.dart`, `heritage_widgets.dart` |
| 1 | Verify core widgets render correctly with a dev preview page |
| 2 | Onboarding |
| 3 | Today / Home (includes topbar with Search/Bookmark/⋯) |
| 4 | Library / Texts |
| 5 | Chapter List |
| 6 | Verse List |
| 7 | Verse Detail |
| 8 | Bookmarks (Pothī) |
| 9 | Search |
| 10 | AI Chat |
| 11 | Festivals |
| 12 | Practice / Your Path |
| 13 | Settings |
| 14 | Credits & Attributions |
| 15 | Send Feedback |

---

## Tips

- **Don't paste MASTER_CONTEXT.md inline.** Point Claude Code to it. Keeps prompts short and context windows clean.
- **One screen per session is ideal.** Switching screens mid-session causes context drift.
- **HTML mockup is ground truth for visual layout.** When Claude Code asks "should this be x or y?", point to the HTML.
- **If Claude Code suggests deviating from the spec, push back.** "The spec says X. Build X. We'll iterate later if needed."
- **After each screen ships, update MASTER_CONTEXT.md** if any decision was refined.

---

## Generating specs for screens that don't have one yet

For screens without a spec, generate one from the HTML mockup once:

```
Read mockups/screen-[XX]-[name].html, .claude/MASTER_CONTEXT.md,
and .claude/MASTER_CONTEXT_ADDENDUM.md.

Generate a screen spec following the format of
.claude/screen_specs/01_onboarding_spec.md.

Output it as .claude/screen_specs/[XX]_[name]_spec.md.

The spec must include:
- Purpose
- Layout (top to bottom, with all elements)
- All states (default, loading, empty, error)
- Animations
- Data persisted (if any)
- Tokens & widgets used
- Don'ts
- Acceptance criteria

Do not invent behavior the mockup or master context doesn't define.
If a behavior is unclear, list it in a "Decisions needed" section
at the end and stop.
```

You review the generated spec, edit if needed, then use the per-screen prompt to build it.

---

## Final note

The point of this system: **Claude Code never has to ask you what something looks like or what something does.** Every answer is in MASTER_CONTEXT.md, the addendum, the screen spec, the mockup HTML, or the design tokens.

If Claude Code asks a question that's already answered in those files, point it at the file and ask it to re-read.
