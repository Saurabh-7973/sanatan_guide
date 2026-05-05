# How to Brief Claude Code

This is your **standard operating procedure** for getting a screen built end-to-end without re-explaining context every time. Three steps.

---

## Step 1 — One-time repo setup

Add these files to your repo. Claude Code will read them automatically (it scans markdown by default).

```
.claude/
  MASTER_CONTEXT.md          ← read on every session
  screen_specs/
    01_onboarding_spec.md
    02_home_spec.md
    ...
    12_practice_spec.md
New Design/
  screen-01-home.html ... screen-12-practice.html
lib/presentation/theme/
  design_tokens.dart         ← installed
  design_typography.dart     ← installed
lib/presentation/shared/widgets/
  heritage_widgets.dart      ← installed
```

**One-time prompt to start a new Claude Code session:**

```
Read .claude/MASTER_CONTEXT.md fully before doing anything else.
This is the design system for Sanatan Guide.
You will refer back to it for every screen. Do not deviate from
its rules without explicit instruction.

Confirm you have read and understood it before proceeding.
```

---

## Step 2 — Per-screen prompt template

Paste this when starting a new screen. **Fill in only the bracketed parts.**

```
TASK: Build the [SCREEN NAME] screen for Sanatan Guide.

CONTEXT:
- Read .claude/screen_specs/[XX_screen_name_spec.md] in full.
- Reference visual: New Design/screen-[XX]-[name].html
- All design tokens are in lib/presentation/theme/design_tokens.dart
- All typography is in lib/presentation/theme/design_typography.dart
- All shared widgets are in lib/presentation/shared/widgets/heritage_widgets.dart
- The master design system (rules, vocabulary, behavior) is in
  .claude/MASTER_CONTEXT.md — refer back to it as needed.

CONSTRAINTS:
- Use Riverpod for state. Use GoRouter for navigation.
- Use ONLY tokens from design_tokens.dart — no hardcoded colors/fonts.
- Use ONLY styles from design_typography.dart — no inline TextStyles.
- Use existing widgets from heritage_widgets.dart for binding lines,
  leaf threads, daṇḍa coordinates, AI thinking dots, Sanskrit text.
- Both dark and light themes must work from day one.
- Match the mockup visually — allow for natural Flutter rendering
  differences but the structure, hierarchy, and motion must match.

DELIVERABLE:
- New file at lib/presentation/features/[feature_name]/[screen_name].dart
- New providers at lib/presentation/features/[feature_name]/providers/
- All states from the spec implemented (default, loading, empty, error)
- Both themes rendering correctly
- Animations from the spec implemented

PROCESS:
1. Read the spec file fully. Confirm understanding.
2. List the files you plan to create.
3. Show me the provider/state shape before writing UI.
4. Build the screen.
5. Run `flutter analyze` and fix any issues.
6. Show me the result.

Do NOT proceed without my approval after step 2.
```

---

## Step 3 — Iteration prompts

After Claude Code shows you the first version, iterate using these compact prompts:

**Visual fix:**
```
The [specific element] doesn't match the mockup. In the mockup it is
[describe what it should be]. Adjust and show me.
```

**State fix:**
```
The [empty / loading / error] state isn't right. The spec says
[reference the spec]. Fix.
```

**Token violation:**
```
You used a hardcoded [color / font / size]. Replace with the
appropriate token from design_tokens.dart.
```

**Heritage element fix:**
```
The [binding line / leaf thread / coord / AI dots] is not using
the shared widget. Use HeritageWidgets.[Widget] from
heritage_widgets.dart instead.
```

---

## Order of work — recommended

Build in this order. Each layer depends on the previous.

| Step | What | Why |
|------|------|-----|
| 0 | Drop in `design_tokens.dart`, `design_typography.dart`, `heritage_widgets.dart` | Foundation. Everything below uses these. |
| 1 | Build the 5 core widgets (already provided as code) — verify they render correctly with a dev page | If these are wrong, every screen will be wrong |
| 2 | Onboarding | Establishes the entry point |
| 3 | Today / Home | The landing surface |
| 4 | Library / Texts (top-level + scripture cards) | The catalog |
| 5 | Chapter List | Drill-down level 1 |
| 6 | Verse List | Drill-down level 2 |
| 7 | Verse Detail | Drill-down level 3 — the core reading experience |
| 8 | Bookmarks (Pothī) | Read-flow output |
| 9 | Search | Cross-cuts the whole corpus |
| 10 | AI Chat | Verse-detail dependent |
| 11 | Festivals | Bundled-data dependent |
| 12 | Practice / Your Path | Read-tracking dependent |
| 13 | Settings | Last; depends on everything else |

---

## Tips

- **Don't paste the whole MASTER_CONTEXT.md inline.** Just point Claude Code to it. Keeps your prompt short and your context window clean.
- **One screen per session is ideal.** When you switch screens, start a fresh chat to avoid context drift.
- **Reference the HTML mockup as ground truth for visual layout.** When Claude Code asks "should this be x or y?" — point to the HTML.
- **If Claude Code suggests deviating from the spec, push back.** "The spec says X. Build X. We'll iterate later if needed."
- **After each screen ships, update MASTER_CONTEXT.md** if any decision was refined. Keep it current.

---

## What if a spec doesn't exist yet?

For screens that don't have a spec yet, generate one from the HTML mockup using this prompt **once**, then iterate from there:

```
Read mockups/screen-[XX]-[name].html and .claude/MASTER_CONTEXT.md.

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

This generates the spec. You review it, edit if needed, then use the per-screen prompt above to build it.

---

## Final note

The whole point of this system: **Claude Code never has to ask you "what does this look like" or "what does this do."** Every answer is in MASTER_CONTEXT.md, the screen spec, the mockup HTML, or the design tokens.

If Claude Code asks a question that's already answered in those files, point it at the file and ask it to re-read.
