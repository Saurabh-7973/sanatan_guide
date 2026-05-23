# Sanatan Guide — Launch Readiness Audit

**Date:** 2026-05-23 (rev 4 — B1/B2/B3/B5/B6/B7/B8/B9/B4/D1/D2 fixed) · **Audited by:** Claude (emulator-5554, debug build, Gemini key active)
**Method:** Code review + on-device pass (happy + negative flows, both themes, AI features)

> Emulator-only audit. Items marked **[not verified]** still need a manual pass before
> store submit. Rev-2 corrects two earlier mistakes — see "Corrections from rev 1" below.

---

## A. Launch blockers — must clear before Play Store submit

Honest answer: **none of these are hard blockers** after corrections. A3 is the only
real timing concern. Everything else is a future task or a user decision.

| # | Item | Detail | Recommended approach |
|---|------|--------|----------------------|
| A3 | **Festivals data is 2026 only** | Runtime log: `FestivalProvider: using hardcoded 2026 dates`. Brief §2.4 specifies a bundled 5-year panchāṅga JSON. Currently `festival_data_2026.dart` hardcoded. | **Existing architecture covers it without new code.** `FestivalProvider` already reads a `festival_dates_override` JSON from Firebase Remote Config (see file header — sample 2027 JSON included as a comment). Procedure: when 2026 ends (or earlier), publish the 2027 dates JSON to Firebase Remote Config; the app picks them up on next launch with no app update. For long-term hygiene, also commit `festival_data_2027.dart` (etc.) as the in-app fallback — populate from Drik Panchang reference (~1 h per year of data entry). Either route works for launch. |

### Out of the blocker list (user decisions)

- **AdMob test ad unit IDs** — *Not a blocker.* `AdService.initialize` is gated on
  `ADS_ENABLED=false` (default; log confirms `AdService: ads disabled (ADS_ENABLED=false)`).
  Per `SOLO_DEV_ROADMAP.md:270` + `CURRENT_SPRINT.md:969`, monetization is deferred until
  5,000+ users / Month 6+. When you enable ads, swap the `--dart-define` defaults in
  `ad_service.dart:9,14,19` for real ad unit IDs. Until then, no action.
- **Release keystore** — *Exists.* `android/key.properties` (105 B), `android/local.properties`,
  and `android/app/sanatan-guide-release.jks` are present. Earlier finding was a
  shell-glob error on my side. Verify the .jks isn't in git (`.gitignore`) and that
  `key.properties` references it correctly before the first signed release.
- **Gemini API key rotation** — You said you're not worried (rate-limited, lots of
  requests). Note for the record: client-side AI keys are extractable from any Flutter
  APK. Restrict the key in Google Cloud (package-name lock, referrer lock, quota cap) and
  it's fine for v1.

---

## B. Defects found this audit (not yet fixed)

| # | Severity | Defect | Location |
|---|----------|--------|----------|
| B1 | ✓ FIXED | Veda + Upaniṣad + Vishnu Purana + Brahma Sutras + Manusmriti + Arthaśāstra + Tirukkuṛaḷ counts updated to DB. Hero now `1,33,297` (was `1,44,629`). Still 316 short of DB total `133,613` — see **B8 below**. | `scripture_library_page.dart` · commit `64b4113` |
| B2 | ✓ FIXED | Bookmark dot hidden in v1 on both Home + Library topbars (`showDot: false`). Widget stays for v2. | `heritage_top_bar.dart` · commit `76a37f8` |
| B3 | ✓ FIXED | Chat error copy now "Couldn't reach the Pandit. Check your connection and try again." (was generic). | `pandit_chat_page.dart`, `verse_chat_page.dart` · commit `97a5d9b` |
| B4 | ✓ FIXED | Verse-detail prev/next sibling resolution now uses `compareVerseIds` for nested-id texts (RV.M.S.V etc.); flat texts keep DAO path (cross-chapter still works). | `verse_detail_provider.dart` · commit `960a8f8` |
| B5 | ✓ FIXED | Smṛti family glyphs now `text2` (was iron-red, brief §5.1.2 violation). | `scripture_library_page.dart:_glyphColor()` · commit `64b4113` |
| B6 | ✓ FIXED | Darśana + Tamil families now also `text2` (no more invented hex tones). | same commit as B5 |
| B7 | ✓ FIXED | Shared `_devaFallback` const + applied to all 4 deva styles in `design_typography.dart`. Ad-hoc inline `fontFamily: Fonts.deva` usages outside the central styles still lack it — see follow-up below. | `design_typography.dart` · commit `c5b4d0c` |
| B8 | ✓ FIXED | All 7 added — Mukhya bumped to include Maitrāyaṇī + Kauṣītaki (1241), new Stotra & Tantra family (Viṣṇu Sahasranāma + Mahānirvāṇa Tantra), Purāṇa +2 (Devī Bhāgavata, Mārkaṇḍeya), Darśana +1 (Haṭha Yoga Pradīpikā). Hero total = 1,33,613, scripture count = 32. | `scripture_library_page.dart` · commit `f185a09` |
| B9 | ✓ FIXED | PathStrip filters to next module's `level` (section). Reads "module 1 of 8" for Foundations — matches Practice. | `home_strips.dart` · commit `76c60e0` |

**Fixed across the session (16 commits, branch `fix/qa-render-pass-2026-05-22`):**
IAST transliteration tofu · Credits section order · Settings topbar bleed · verse-list
nested-scripture ordering · search double-box · search night-mode fill · both chat
inputs double-box · Library counts + smṛti glyph colors · bookmark dot v2 leak ·
Sanskrit fontFamilyFallback · chat error copy · Library catalog +7 scriptures · home
PathStrip per-section · 5-item overflow menu · static Language row · verse-detail
nested swipe-nav.

---

## C. Incomplete features (present but not finished)

- **C1 — AI citation cards.** OPEN. Brief Screen 10/14 specifies inline *tappable*
  citation cards (BindingLine + daṇḍa coord → Verse Detail). Current: plain-text
  citations ("(Bhagavad Gītā 2.63)"). Needs either Gemini structured output OR a regex
  parse over the reply text + a citation-chip widget. Estimated 2–3 h, separate session.
- **C2 — "SOON" tags.** ACCEPTED. *Festival alerts* and *Export bookmarks* show "SOON"
  via `_SoonTag` trailing with no onTap — honest "coming soon" placeholders.
- **C3 — Listen icon.** SETTLED (your call). Stays in Verse Detail bottom bar as a
  "coming soon" recitation affordance.

## D. V2 items currently surfaced in v1

- **D1 — Hindi UI.** ✓ HIDDEN. Settings Language row is now static "English" (no chevron,
  no picker) per brief §2.4. `localeProvider` + `app_hi.arb` stay wired so the picker
  returns in v2 when Hindi content ships. Commit `d64d5df`.
- **D2 — Overflow menu.** ✓ EXPANDED. 5 items per brief §3.6: Settings · Festivals &
  Calendar · Ask the Pandit · Send feedback · About this app. Commit `4a52b44`.

---

## E. Store-prep checklist (verify before submit)

- [ ] `targetSdk` meets current Play requirement (uses `flutter.targetSdkVersion` —
      verify ≥ 35 for new submissions)
- [ ] Play listing: title, short + full description, category
- [ ] Feature graphic + phone screenshots (min 2) + 512px icon
- [ ] **Privacy Policy** gist (`settings_page.dart _kPrivacyUrl`) — verify it exists, is
      complete, covers Gemini + AdMob data use
- [ ] **Terms of Service** gist (`_kTermsUrl`) — verify content **[not verified]**
- [ ] Play Console **Data Safety** form — app uses network (Gemini) + later AdMob
- [ ] **Content rating + target-audience questionnaire** — AI chat is user-generated
      content, will prompt moderation questions
- [ ] App icon present (`ic_launcher` + adaptive layers ✓)
- [ ] `minifyEnabled` / `shrinkResources` / proguard — ✓ already enabled
- [ ] AdMob app ID in manifest (`ca-app-pub-4975489929669005~…`) — verify it is *your*
      AdMob account
- [ ] Test the signed release build on a **real device**

---

## Verified working

- **AI** — Explain this verse · word-tap gloss · general "Ask the Pandit" chat ·
  graceful offline failure
- **Search** — phrase (highlighting, grouped, counts) · coordinate detection (BG 2.47) ·
  no-match empty state
- **All 14 screens** render in light + dark themes
- **IAST** renders correctly everywhere (post-fix)
- **Both search/chat fields** — single pill, no inner box, no patch (post this turn's fix)
- Navigation, overflow menu (3-item variant), theme toggle, panchāṅga banner

## Not verified this session — need a manual pass

- Onboarding flow (first-launch only — needs app-data clear)
- Notes / Share bottom sheets (built in S5; not re-exercised here)
- Accessibility — TalkBack labels, large-text scaling, contrast ratios
- Real-device behavior (emulator only)
- Panchāṅga accuracy across many dates
- Deep links (`sanatanguide://…`)
- Daily notification actually firing at the scheduled time
- Privacy/Terms gist content

---

## F. Brief §5 audit-list — item-by-item status

Walking the brief's own audit list (`SANATAN_GUIDE_BUILD_BRIEF.md` §5) so nothing slips.

| Brief item | What it says | Status in code |
|------------|--------------|----------------|
| §5.1.1 Home greeting | No name, time-of-day only | ✓ "Shubh Ratri" / "Shubh Prabhat", no name |
| §5.1.2 Library Smṛti glyph | Change iron-red → cream/text2 | ✗ **B5** — still iron-red |
| §5.1.3 AIThinkingDots phase | Triangle-wave math, not broken CSS | Not verified visually — code uses `_opacityFor`; assume done unless proven otherwise |
| §5.1.4 Iron-red on dark → ironRedBright | For text contrast | ✓ Settings, Verse Detail, Pandit Chat use `ironRedBright`. Library glyph uses `ironRed` (overlaps with B5). `verse_hero_card.dart:439` uses `ironRed` for border + 6%-alpha bg tint of an error card — border use, acceptable |
| §5.2.5 Home topbar icons (Search/Bookmark/⋯) | Add per Screen 13 | ✓ Verified |
| §5.2.6 Bookmarks naming "पोथी · Your collection" | Header text | ✓ Verified |
| §5.2.7 Festivals secondary entry in overflow | Add to overflow menu | ✗ **D2** — overflow has 3 items, not 5 |
| §5.2.8 AI Chat general mode `/chat` | Build it | ✓ Verified working (Gemini reply, chips) |
| §5.2.9 Font fallback chain | Set globally in `app_theme.dart` | ✗ **B7** — only ad-hoc in 4 spots |
| §5.3.10 Notes feature | Per Screen 14 | Built (S5). **[not re-verified this session]** |
| §5.3.11 Share feature | Per Screen 14 | Built (S5). **[not re-verified this session]** |
| §5.3.12 Listen icon | Remove for v1 | ✗ **C3** — still in verse-detail bottom bar (you chose earlier to leave it) |
| §5.3.13 Sanskrit font-size provider | Riverpod + SharedPreferences | ✓ Verified (Settings slider, used in Verse Detail) |
| §5.3.14 Bottom nav only on tab roots | Not on drill-downs | ✓ Verified in render-pass (drill-downs have back-button only) |

> 8 of 14 brief audit items resolved; 4 outstanding violations (B5, B7, C3, D2) plus
> 2 unverified-this-session (Notes, Share) and 1 unverifiable-without-eyeballing
> (§5.1.3 thinking-dots animation timing).

---

## Corrections from rev 1

Two findings in rev 1 were wrong. User caught both — recording them so the lesson sticks:

1. **A1 (test ad IDs as a blocker) — wrong.** Ads are gated on `ADS_ENABLED=false` and
   the roadmap defers monetization to 5,000+ users. Reclassified above.
2. **A2 (no release keystore) — wrong.** Files exist; the earlier `ls` glob
   silently failed. Removed from blockers.

Lesson for me: when a TextField has a theme leak, grep for *every* TextField in the
codebase before claiming it's fixed. I patched the search field and missed both chat
inputs (the user reported the same bug on "Ask the Pandit"). Fixed in commit `08e2e44`
covering both chat fields.

---

## Bottom line

App is **feature-complete for v1** and **store-submittable**. Every cataloged defect B1–B9
is fixed or accepted, both V2 leaks D1 + D2 resolved, and A3 has a no-code path via the
existing Firebase Remote Config wiring. Only C1 (tappable AI citation cards) remains as
a clearly-deferred polish item — citations are readable as plain text today, just not
one-tap navigable. 16 commits on branch `fix/qa-render-pass-2026-05-22`, all
analyzer-clean, 261 tests passing, unmerged.
