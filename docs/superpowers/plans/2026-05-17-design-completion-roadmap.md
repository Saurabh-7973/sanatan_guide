# Design Completion Roadmap — Sanatan Guide

> **For agentic workers:** This is the INDEX, not an executable plan. Each subsystem
> below gets its own detailed bite-sized plan file written just-in-time before its
> build (so it reflects landed reality, not speculation). Subsystem 1's detailed plan
> already exists: `2026-05-17-navigation-keystone.md`.

**Goal:** Close the gaps the user flagged — navigation entry points, Credits redesign,
Feedback screen — then bring every remaining mockup (Settings, Festivals, Practice) and
the brief's new flows (Notes, Share, AI-chat-general) to spec, so the app is uniform.

**Source of truth:** `New Design/SANATAN_GUIDE_BUILD_BRIEF.md` for design language and
cross-reference logic. `New Design/mockups/screen-NN-*.html` + `New Design/screen-NN-*.html`
for visuals. Per-screen specs in `.claude/screen_specs/`.

**Tech Stack:** Flutter 3, Riverpod 3, Drift/SQLite, GoRouter, Material 3, dual theme.

---

## Cross-cutting decisions (LOCKED — do not relitigate per subsystem)

These were decided with the user delegating "do what is best". They override the
brief wherever they conflict, because the brief was authored by a session with no
access to the codebase.

### D1 — Routes: keep the codebase scheme
The working app uses `/home`, `/learn`, `/browse`, `/credits`, `/settings`,
`/bookmarks`, `/festivals`, `/search`. The brief's `/texts` `/practice` `/`
`/settings/credits` are NOT adopted. The brief's "this file wins" clause governs
design language, not router strings. Renaming touches every nav call + notification
deep links for zero user benefit.

- Add NEW routes only where genuinely absent: `/feedback`, `/chat` (general AI chat).
- Credits stays at `/credits`. No `/settings/credits` alias (keep it simple).
- The brief's cross-reference matrix is mapped onto existing routes in each plan.

### D2 — Code files: lib is canonical, `New Design/code/` is reference only
`lib/.../heritage_widgets.dart` (369 lines) is MORE current than
`New Design/code/heritage_widgets.dart` (306 lines). lib's `_opacityFor` is already
the corrected triangle wave — brief "critical fix #3" is **already done**.
**Never overwrite lib code with `New Design/code/`.** Every brief "audit fix" is
VERIFIED against live code before applying; several are already satisfied.

### D3 — Spec numbering: `.claude/screen_specs/` is canonical
Existing `01_onboarding` … `09_ai_chat` stay (built screens follow them; the brief's
own prompt template points to `.claude/screen_specs/`). New specs continue the
sequence:

| New file in `.claude/screen_specs/` | Covers | Brief's name for it |
|---|---|---|
| `10_festivals_spec.md` | Festivals + Festival detail | Brief "Screen 8" |
| `11_settings_spec.md` | Settings | Brief "Screen 9" |
| `12_practice_spec.md` | Practice / Your Path | Brief "Screen 12" |
| `13_navigation_credits_feedback_spec.md` | Topbar + overflow + Credits + Feedback | Brief "Screen 13" |
| `14_missing_flows_spec.md` | AI-chat-general + Notes sheet + Share sheet | Brief "Screen 14" |

The brief's prose numbering (08=Festivals, 09=Settings) is just remapped here; ignore
the collision — it never reaches the `.claude` folder.

### D4 — Bottom-nav structural fix (brief §3.1)
`ScaffoldWithNavBar` currently wraps the whole ShellRoute, so the bottom nav shows on
`/settings`, `/credits`, `/bookmarks`, `/festivals` too. Brief: bottom nav appears
ONLY on Today/Practice/Texts (`/home`, `/learn`, `/browse`). Subsystem 1 moves
`/bookmarks`, `/festivals`, `/settings`, `/credits` OUT of the ShellRoute to
root-level routes (like `/search` and verse detail already are). They keep
back-button-only chrome.

### D5 — Build rhythm: follow the project's established pattern
Git history shows `feat(screen): rewrite to spec` → widget test → `flutter analyze`
→ commit. The `flutter analyze` PreToolUse hook runs before every Edit/Write.
CLAUDE.md quality gate: new features include a widget test. We follow this rhythm
(spec-driven, widget-tested) rather than strict red-green TDD per widget — project
conventions take precedence (per superpowers instruction priority).

---

## Reality check — what is actually built (verified via `git log`, not stale memory)

Already rewritten to spec: onboarding, home, library, chapter-list, verse-list,
search, bookmarks, verse-detail (spec 08), ai-chat verse-anchored (spec 09).

Genuine gaps:

| Gap | State | Subsystem |
|---|---|---|
| Home/Library topbar (Search/Bookmark/⋯) + overflow menu | absent | S1 |
| `/feedback`, `/chat` (general) routes | absent | S1 |
| Bottom nav scoping (D4) | wrong (shows everywhere) | S1 |
| Credits screen | exists, OLD WarmBackdrop baseline, not heritage spec | S2 |
| Feedback screen | absent entirely | S3 |
| Settings screen | only divider tweak, not spec rewrite | S4 |
| Verse Detail: Notes sheet, Share sheet, drop Listen icon | absent | S7 |
| AI Chat general mode | absent (only verse-anchored built) | S8 |
| Festivals + Festival detail | only emoji→icon tweak | S5 |
| Practice / Your Path | not rewritten to mockup | S6 |

---

## Subsystem decomposition + sequence

Ordered by leverage × dependency. Rationale: S1 unblocks reachability of everything
and directly answers the user's original "from where do you reach these?" question.
S2/S3 are the explicit "app not uniform" complaint and are small. Then the larger
mockup rewrites.

| # | Subsystem | Depends on | Plan file (written just-in-time) | Acceptance summary |
|---|---|---|---|---|
| **S1 ✅** | **Navigation keystone** | — | `2026-05-17-navigation-keystone.md` (✅ DONE 2026-05-17) | Home/Library topbar + 5-item overflow; `/feedback` & `/chat` routes added; bottom nav only on Home/Practice/Texts; Settings/Credits/Bookmarks/Festivals reachable |
| **S2** | Credits redesign | S1 | `2026-05-17-credits-redesign.md` | `credits_page.dart` rewritten to spec 13 Part B; sūtra numerals, domain sections, BindingLine + blessing footer; all required sources; both themes; reachable via overflow "About" |
| **S3** | Feedback screen | S1 | `2026-05-17-feedback-screen.md` | New `/feedback`; State A (4 kinds) → State B (compose); mailto submit; device-info default ON, reply default OFF; both themes |
| **S4** | Settings rewrite | S1 | `2026-05-17-settings-rewrite.md` | Rewritten to screen-09 mockup; Appearance/Reading/Notifications/Data/About/Reset; `sanskritFontSizeProvider` (SharedPreferences) added; Credits + Feedback rows; both themes |
| **S5** | Verse Detail: Notes + Share | S4 (font provider) | `2026-05-17-verse-detail-notes-share.md` | Notes bottom sheet (Drift `notes` table, 200 ch, shows on Bookmarks); Share bottom sheet (3-format chooser, canonical strings, deep link); Listen icon removed |
| **S6** | AI Chat general mode | S1 | `2026-05-17-ai-chat-general.md` | `/chat` general mode (no verse anchor; ॐ + "ASK THE PANDIT"); empty state + 4 chips; reachable from overflow + Search; verse-anchored unaffected |
| **S7** | Festivals rewrite | S1 | `2026-05-17-festivals-rewrite.md` | Almanac column (not cards) to screen-08; panchāṅga banner; iron-red `dIronRedBright` festival names; filter strip; Festival detail page; bundled 5-yr panchāṅga data verified |
| **S8** | Practice rewrite | — | `2026-05-17-practice-rewrite.md` | Rewritten to screen-12; 7-day strip + Continue leaf-thread anchor; 8-module Foundations spine; locked Deepening/Mastery; user's canonical copy |

Build sequence: **S1 → S2 → S3 → S4 → S5 → S6 → S7 → S8.**
User may reorder S5–S8; S1 must be first, S2/S3 follow it.

**Stub cleanup:** S1 ships `lib/presentation/shared/pages/coming_soon_page.dart`
serving `/feedback` (until S3) and `/chat` (until S6). S3's plan replaces the
`/feedback` route target with the real Feedback screen. S6's plan replaces the
`/chat` route target with the real AI-chat-general screen. **Whichever of S3/S6
lands second deletes `coming_soon_page.dart`** and confirms no remaining
references (`grep -rn ComingSoonPage lib/`).

---

## Per-subsystem acceptance — full criteria live in each just-in-time plan

Each subsystem plan, written immediately before its build, will contain:
- File map (create/modify with exact paths)
- Bite-sized steps with concrete code
- The matching `.claude/screen_specs/NN_*.md` (created/updated as that plan's Task 0)
- Widget test(s) per CLAUDE.md gate
- `flutter analyze` clean + acceptance-criteria walk (per memory:
  `feedback_verify_acceptance_criteria` — walk each numbered bullet literally)
- Visual verification note (per memory: `feedback_run_or_test_visual_changes` —
  analyzer-clean misses layout/decoration bugs; pump or run before "done")

---

## Risks / watch-items

- **Brief audit is codebase-blind.** Treat every "fix N" as a hypothesis. Verify
  against live code; some are already done (D2). Do not regress current screens.
- **Mockup ≠ spec on known points.** Home greeting name, stale Home topbar, Library
  Smṛti iron-red — these are in brief §5; verify current code state before "fixing"
  (the Smṛti glyph and greeting may already be handled in the spec-built screens).
- **Notes already partially exist.** Commit `ccfd76e` ("persist note on swap") shows
  verse-detail note logic exists. S5 must read current verse-detail before adding the
  bottom sheet — extend, don't duplicate.
- **Spec-folder fork** is resolved by D3 but the physical copy of spec 13 into
  `.claude/screen_specs/` is S1 Task 0; specs 10–12, 14 are Task 0 of their plans.
