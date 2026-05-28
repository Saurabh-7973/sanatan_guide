# Sanatan Guide — V1 Final Audit (2026-05-27, synced 2026-05-28)

User-discovered issues from Last Design & Functionality Check. Source: user
chat 2026-05-27. Classified per `feedback_classify_before_fixing` rule:
(a) bug · (b) matches-spec/intentional · (c) content-gap · (d) design-spec-not-yet-built · (e) perf/build.

Status legend: ☐ open · ◐ partial · ✓ done · ⚙ user-action.

---

## Sprint summary (2026-05-27 → 2026-05-28)

41 commits shipped. Per-feature mapping below.

| Done | Item | Commit |
|------|------|--------|
| ✓ | §15.5 notif cold-start deep-link (◐ unverified on device) | ee23838 |
| ✓ | §4 per-scripture read-count provider | 2fba131 |
| ✓ | R1 unify back chevron (5 screens) | 9d2cbcd |
| ✓ | §12 bookmark dot + §5 bookmark+tick badge | 11c0893 |
| ✓ | §6 search recents on result tap | 222fe17 |
| ✓ | §3 verse-detail pāda transliteration + translation split | 26c3005 |
| ✓ | §15a cupertino_icons | 80e7c0b |
| ✓ | §5 verse-of-total + min-left for non-BG | d814eba |
| ✓ | §9 settings footer + drop font-row icon | c49188b |
| ✓ | §9 Festival alerts real toggle | 653d37a |
| ✓ | §7 bookmarks divider + saffron pill | 4e707b1 |
| ✓ | §8 today-first; §11 heritage locked-tap | 7003de8 |
| ✓ | §3 verse-chat heritage app bar | 592e01a |
| ✓ | §3 word-gloss empty copy | 757be61 |
| ✓ | security: allowBackup=false + extraction rules | 37c1b10 |
| ✓ | perf §5: GROUP BY chapter read counts | ce2c00c |
| ✓ | privacy: Analytics opt-out | a3d3379 |
| ✓ | §14 notif permission opt-in only | 4afe347 |
| ✓ | data: Yajurveda 40-chapter + no-translit inline notice | 424cee0 |
| ✓ | ci, network_security_config | 9dd8e23 |
| ✓ | privacy: Crashlytics opt-out | 604fcc4 |
| ✓ | §6 one-line preview | f4e1db8 |
| ✓ | §6 direct-coord exclusive | 78dfdd3 |
| ✓ | §6 Pandit CTA emotional | bb90885 |
| ✓ | §13 offline banner | 81bd9fd |
| ✓ | §8 day-of festival alert scheduler | b5f50e6 |
| ✓ | §1 heritage loading/error widget pair | c9e14da |
| ✓ | §10 copy + share actions | 51709e1 |
| ✓ | §10 regenerate | 5a80b90 |
| ✓ | §10/C1 tappable citation chips | bf463e6 |
| ✓ | boot crash capture + heritage confirm sheets | 0f5bf6f |
| ✓ | build: release.sh + analyze_size.sh | e9ec553 |
| ✓ | security: gitignore + pre-commit hook | 4b373b1 |
| ✓ | §9 heritage time picker | 5e4798b |
| ✓ | Crashlytics route breadcrumbs | 4912643 |
| ✓ | docs README | 1a14e54 |
| ✓ | drop google_mobile_ads (D1), Gemini 3.5-flash (D5), save-to-notes (D3) | e28e1d6 |
| ✓ | dart format normalisation (60 files) | 3d5240e |
| ✓ | v1.0.0 CHANGELOG | 3f0a474 |
| ✓ | search test coverage (looksLikeQuestion) | c41ce9b |
| ✓ | §15b Java 11 (already in build.gradle.kts) | (no-op) |
| ✓ | §15d aot-shared-library-name meta absent | (no-op) |
| ✓ | §15e Impeller opt-out absent | (no-op) |

**Verification owed before promoting ◐ → ✓:**
- Cold-start notif deep-link → device-test per §15.5.
- Visual changes → light + dark screenshots.

---

# Open items

## §1 — Loading & error states
- ◐ **(d)** Widget pair exists (c9e14da); ~20-site sweep across every
      `AsyncValue.when` / `FutureBuilder` not yet executed.

## §2 — Onboarding
- ☐ **(b?)** Background gradient vs `screen-11-onboarding.html` — visual A/B not run.

## §3 — Verse Detail
- ⚙ Gemini key shipping decision — release builds need `--dart-define=GEMINI_API_KEY`
      or the gloss copy needs rework. Current copy honest but feature
      invisible without key. User to decide ship key vs rewrite copy.

## §4 — Library
- ⚙ **Diamond glyph colour** (Darśana grey vs faint family hue). Needs user pick.
- ◐ Stale-state invalidation post Verse→back-to-Library — provider exists
      (2fba131); confirm every read path invalidates it.

## §5 — Scripture Reader
- ☐ **(a)** Header copy swap "Mandalas → Chapters · Verses · Read" once
      `lastReadVerseId != null` for RV/Yajur (BG already does this).
- ☐ **(a)** RigVeda "Continue" card missing on chapter list — nested-id
      resolver doesn't recognise RV last-read.
- ☐ **(a)** Yajurveda Kāṇḍa-completion badge in next-kāṇḍa header.
- ☐ **(d)** Section dividers "VERSES 11–20 SĀṄKHYA BEGINS" — needs DB
      metadata for section breaks.
- ◐ **(a)** Chevron sweep ran for 5 screens (9d2cbcd); audit remaining
      drill-downs and apply `MockupBackChevron`.

## §6 — Search
- ☐ **(d)** "EMPTY (RETURNING)" state from design not built.
- ☐ **(a)** Pressing X clear → does it record query into recents? Spec check.

## §7 — Bookmarks
- ⚙ Filter chip keep/drop decision.
- ☐ **(a)** Back icon final sweep with §5.

## §8 — Festivals
- ☐ **(a)** Quarter-moon ring custom back button (currently plain chevron).
- ⚙ Today-first confirmed via 7003de8 — leave as ✓ if user happy.
- ⚙ Drik Panchang content audit + 2027–2030 bundled fallback (A3).

## §9 — Settings
- ☐ **(a)** Theme picker → segmented Light · Dark · System tabs.
- ◐ **(a)** Font slider wiring re-verify on device (LAUNCH_READINESS said ✓).
- ☐ **(a)** Daily reminder bottom sheet redo to match design.
- ☐ **(a)** Back button uniformity sweep with §5.

## §10 — AI Chat
- ☐ **(a)** Ask-AI chip on verse-detail → confirm routes to verse-scoped
      chat page (51709e1/5a80b90 added actions; routing path unverified).

## §11 — Practice
- ⚙ Inner module page decision (build vs keep placeholder).

## §12 — Credits
- ☐ **(a)** Every credit row tap → same page bug. Investigate routing in
      `screen-13-navigation-credits-feedback`.

## §13 — Pandit
- ☐ **(unknown)** Code walk: empty/error/citation/follow-up states.

## §14 — Privacy / Terms / Permissions
- ☐ **(content)** Privacy + Terms Lora-tone rewrite (Task 4 of current sprint).
- ☐ **(a)** Background-run pre-prompt screen before native dialog.

## §15.5 — Notification deep-link
- ◐ Code shipped (ee23838); cold-start device-test owed.

## §15 — Build/perf/security
- ☐ R8/proguard rules — confirm AI key not stripped.
- ⚙ Gemini API key restrictions on Google Cloud (package-name lock).
- ⚙ Firebase Remote Config rule (anyone-can-read 2027 dates).
- ☐ Drift DB ship-vs-runtime mismatch check (DB on assets).
- ☐ APK size breakdown — DB + image weights audit (47.7 MB release).

---

## Items needing **user decision** before code

- §3 Gemini key ship-in-release vs copy rework
- §4 Library glyph colour (grey vs faint hue)
- §7 Filter chip keep/drop
- §8 Festival content authenticity sign-off
- §11 Practice inner page yes/no
- §15 ⚙ external: GCP key restriction, Firebase rules audit, keystore backup

---

## Items needing **content** (your homework)

- §12 Per-credit URL data
- §14 Privacy/Terms hosted page
- App listing copy + screenshots + feature graphic

---

## Cross-cutting refactors

- **R1** — `MockupBackChevron` applied to 5 screens; remaining drill-downs pending.
- **R2** — `HeritageLoading`/`HeritageError` pair shipped; ~20-site sweep open.
- **R3** — Per-scripture read-count provider shipped (2fba131); invalidation
      audit owed.
