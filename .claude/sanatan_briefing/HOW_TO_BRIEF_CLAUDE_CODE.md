# How to brief Claude Code for Sanatan Guide

Operating procedure for using this briefing package with Claude Code.

---

## One-time setup

1. Unzip `sanatan_briefing.zip` into `.claude/sanatan_briefing/` at your repo root
2. Copy code files into your Flutter project:
   - `code/design_tokens.dart` → `lib/core/theme/design_tokens.dart`
   - `code/design_typography.dart` → `lib/core/theme/design_typography.dart`
   - `code/heritage_widgets.dart` → `lib/core/widgets/heritage_widgets.dart`
3. Add the four fonts to `pubspec.yaml`:
   - Tiro Devanagari Sanskrit
   - Noto Sans Devanagari
   - Lora (regular + italic + 500 + 600)
   - Outfit (300 + 400 + 500 + 600 + 700)

---

## Session opening (paste once per Claude Code session)

```
Read .claude/sanatan_briefing/SANATAN_GUIDE_BUILD_BRIEF.md fully before
doing anything else.

This is the canonical brief for Sanatan Guide v1. Every other file in
.claude/sanatan_briefing/ is supporting material referenced from it.
If anything contradicts the brief, the brief wins.

Confirm you've read it. Then ask me which screen to start with.
```

---

## Per-screen prompt template

```
TASK: Build the [SCREEN NAME] screen.

REFERENCES:
- Mockup: .claude/sanatan_briefing/mockups/screen-[XX]-[name].html
- Brief section §4 (per-screen instructions) and §3.5 (entry matrix)
- Spec (if exists): .claude/sanatan_briefing/screens/[XX]_*.md
- Tokens: lib/core/theme/design_tokens.dart
- Styles: lib/core/theme/design_typography.dart
- Widgets: lib/core/widgets/heritage_widgets.dart

RULES:
- Riverpod for state, GoRouter for navigation
- ONLY tokens from design_tokens.dart — no hardcoded colors/fonts
- ONLY styles from design_typography.dart — no inline TextStyles
- Use heritage widgets — don't reimplement BindingLine, LeafThread, etc.
- Both themes must work from day one
- Match the mockup: structure, hierarchy, motion

CROSS-REFS (from brief §3.5 entry matrix):
- This screen is reached from: [paste from the entry matrix]
- This screen routes to: [list per-screen instructions]

PROCESS:
1. Read the spec and mockup. Confirm understanding.
2. List files you plan to create.
3. Show the provider/state shape before writing UI.
4. Build the screen.
5. Run `flutter analyze`, fix issues.
6. Show me the result.

Do NOT proceed past step 2 without my approval.
```

---

## Meta-prompt: generating a per-screen spec from the mockup

For the 11 screens that don't have specs yet (everything except Onboarding and Screen 13):

```
TASK: Generate a per-screen design spec for Screen [XX] — [NAME].

INPUTS:
- Mockup: .claude/sanatan_briefing/mockups/screen-[XX]-[name].html
- Brief: .claude/sanatan_briefing/SANATAN_GUIDE_BUILD_BRIEF.md
- Reference spec format: .claude/sanatan_briefing/screens/01_onboarding_spec.md

OUTPUT:
- A markdown spec file at .claude/sanatan_briefing/screens/[XX]_[name]_spec.md
- Follow the EXACT structure of the reference spec
- Include: route, build order, what to build (broken into logical chunks), 
  data shape (Drift tables, Riverpod providers, state classes), states 
  (default, loading, empty, error), cross-refs (entry from + exit to), 
  motion, accessibility notes, and any known fixes from brief §5.

DO NOT BUILD. Generate the spec only. I will review before you build.
```

After Claude Code generates the spec, READ IT YOURSELF, edit if needed, then use the per-screen prompt to build.

---

## Correction prompts

**For visual mismatches:**
```
The [element] doesn't match the mockup. The mockup shows [describe].
Adjust accordingly.
```

**For state errors:**
```
The [empty/loading/error] state isn't right. The brief/spec says
[quote relevant section]. Fix it.
```

**For token violations:**
```
You used a hardcoded [color/font/size] on line [N]. Replace it with the
token from design_tokens.dart.
```

**For cross-reference confusion:**
```
This screen is reached from [list per entry matrix in §3.5] and routes
to [list per §4]. Check your navigation logic against this.
```

**For deviation requests:**
```
The brief doesn't allow this. Section [N] says [quote].
Either keep the existing approach or surface this as a question for
Saurabh to decide. Don't deviate unilaterally.
```

---

## Build order

Build in this order. Don't skip ahead — later screens depend on earlier widgets.

| # | Build |
|---|---|
| 1 | Core foundation: `design_tokens.dart`, `design_typography.dart`, `heritage_widgets.dart`, system chrome widgets from Screen 16 (toast, dialog, time picker, splash) |
| 2 | Onboarding (Screen 11) — uses time picker |
| 3 | Home (Screen 1) with new topbar + AdMob banner |
| 4 | Library (Screen 3) |
| 5 | Chapter List (Screen 4) |
| 6 | Verse List (Screen 5) |
| 7 | Verse Detail (Screen 2) + Notes sheet + Share sheet + Word callout + edge cases |
| 8 | Bookmarks (Screen 7) |
| 9 | Search (Screen 6) |
| 10 | AI Chat — verse-anchored + general (Screens 10, 14) + error states + offline indicator |
| 11 | Festivals + Festival detail (Screen 8) |
| 12 | Practice + Module Reader + Module Complete (Screens 12, 15) |
| 13 | Settings (Screen 9) with theme transition + time picker sheet |
| 14 | Credits + Send Feedback (Screen 13) |
| 15 | Splash screen configuration + launch icon |

---

## What to do when Claude Code gets stuck

**It asks "where does X redirect from?"**
→ Point at brief §3.5 entry matrix. Don't re-explain.

**It asks "what does Y look like?"**
→ Point at mockup file and section in brief.

**It suggests building a v2 feature**
→ Point at `V2_BACKLOG.md`. Reject.

**It says "the mockup doesn't show this state"**
→ Check brief §5 known fixes first. Then the per-screen instructions in §4.

**It can't figure out which widget primitive to use**
→ Brief §2.2 lists all six. They're in `heritage_widgets.dart`.

**It generates Material defaults for toast/dialog/picker**
→ Reject. Brief §4 Screen 16 specifies custom versions.

---

## What NOT to do

- ❌ Don't ask Claude Code to "build the whole app." Build one screen at a time.
- ❌ Don't have Claude Code generate spec + code in one session — it will hallucinate.
- ❌ Don't approve a spec without reading it.
- ❌ Don't let Claude Code skip step 1 (read brief) and step 2 (list files) of the per-screen template.
- ❌ Don't let Claude Code invent new tokens, fonts, or widgets without asking.
- ❌ Don't iterate on UI visually without referencing the mockup. Mockup is the contract.

---

## Final mental model

You are the lead. Claude Code is a fast intern with great hands and no taste yet. The brief is the design contract. The mockups are the visual contract. Your job is to enforce both.

After v1 ships, then you iterate.
