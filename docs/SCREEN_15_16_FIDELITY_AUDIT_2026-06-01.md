# Screen 15 & 16 Fidelity Audit — 2026-06-01

Verification of the two newest briefing HTML files against the live Flutter code.

- Canonical specs: `.claude/sanatan_briefing/screen-15-module-reader.html`,
  `.claude/sanatan_briefing/screen-16-system-chrome.html`
- Bar = "to spec / heritage vocabulary", NOT pixel-identical (locked decisions
  D1–D5 permit intentional deviation). Findings tagged:
  **(a)** matches spec · **(b)** intended deviation/addition · **(c)** real gap.

---

## Screen 15 — Module Reader + Complete
File: `lib/presentation/features/learning_path/pages/module_reader_page.dart`

### Matches spec (a)
- Topbar: ✕ close (left) + module name in Lora-italic saffron + "X / Y" counter in text3.
- Progress hairline: 3px saffron `LinearProgressIndicator`.
- Body is tap-anywhere (`GestureDetector` opaque); content vertically centered (Spacer 2/3).
- Step transition: 280ms slide-from-right + fade (`AnimatedSwitcher`).
- KEY VERSE: iron-red pill (8% tint, 0.5 border) + serif quote + outlined saffron "Read … in the Gītā" CTA → verse detail.
- REFLECT: diya glyph (`DiyaIcon`), small-caps "REFLECT", 22px serif question, italic footer.
- Completion: saffron check in palm-leaf `BindingLine` frame, "Module Complete" + italic module name, hairline divider, "RECOMMENDED FOR THIS MODULE" section label, book rows → `url_launcher`, full-width filled saffron "Back to Learning Path", staggered reveal.

### Real gaps (c)
1. **Intro/Concept step has no small-caps step-label.** Spec renders "INTRODUCTION" / "CONCEPT 2 OF 5 · आत्मन्" above the title; `_ContentCard` renders title+body only (data model `_CardData` has no `label` field). Structural omission.
2. **Completion check is wrapped in a saffron-tinted circle.** Spec explicitly drops the circle (the green *circle* was the stated problem) — wants a bare ✓ between two binding lines. Code reintroduced a circle (saffron, not green) + glow.
3. **Book recs render as bordered surface cards**, not the spec's borderless rows separated by hairlines; the 48px icon also lacks the spec's 1px border.
4. **Per-element ink-settle stagger absent on step *content*** (label→title→body). Only the completion screen staggers; step bodies rely on the switcher fade.
5. Minor type sizes under spec: title 24 vs 28, complete-title 30 vs 32, key-verse 20 vs 22, module name 17 vs 18; tap-hint not lowercased, CTA not uppercased.

### Intended (b)
- Extra "Read the [Scripture]" deep-link pill on completion — enhancement beyond spec.

---

## Screen 16 — System Chrome

### Matches spec (a)
- **Toast** (`shared/widgets/system_chrome.dart`): near-exact — surface2 pill, 22px radius, divider border, max 320, saffron rotated diamond, Lora 13.5 text, UPPERCASE UNDO with left hairline, 240ms slide-up+fade, 3.5s auto-dismiss, new-cancels-old.
- **Time picker** (`settings_page.dart` `showHeritageTimePicker` + `_Wheel`): custom `ListWheelScrollView` sheet, serif numerals, AM/PM toggle, drag handle, used in Settings + Onboarding.
- **Verse chevron edge toast**: first/last-verse tap shows a toast (verse_detail_page.dart:561/587) instead of a dead no-op.
- **AI chat error + RETRY pill + offline indicator** (`pandit_chat_page.dart` + `offline_banner.dart`).
- **No ads on any reading surface** — restraint honored (grep: zero `BannerAd`/`AdWidget` in scripture_reader/chat).

### Real gaps (c)
1. **Confirmation dialog ≠ spec.** Spec = centered card (312px, 55% scrim, BindingLine motif at top, two 52px flat text buttons split by a vertical hairline, destructive label in iron-red-bright text, fade+scale 200ms). Code (`showHeritageConfirmSheet`) = **bottom sheet** with a warning-icon disc + serif title/italic body + Cancel-outline + **filled** confirm pill. No BindingLine, not centered, confirm is filled not iron-red text. (Code comment admits it reuses the onboarding sheet look.)
2. **Scripture-end "finished" banner absent.** Spec: on the last verse of the last chapter of a scripture, show "You've finished the [Scripture]" italic serif + a 10px saffron diamond above the bottom bar, and a "[Scripture] · End" center label. Grep finds none in scripture_reader. Only the chapter-level chevron toast exists.
3. **Home bottom banner ad not built as specced.** Spec = 50px inline AdMob banner above the bottom nav, "AD" label, collapse-on-fail. Code uses an **app-open (full-screen) ad** (`AppOpenAdService`) instead; no inline banner widget on Home.
4. **Splash animated loader absent.** `flutter_native_splash` shows the static mark, but the spec's three AIThinkingDots loader at the bottom is effectively not shown (native splash dismissed on first frame).

### Deliberate defer / cut (b)
- **Word callout**: existing inline word-gloss form, not the spec's anchored popover-with-arrow. Deferred (Gemini-key-gated, prior decision).
- **Pull-to-refresh**: not built. Deliberately cut last session — app is fully offline + Riverpod streams are already reactive, so it has near-zero utility and contradicts the brief's restraint ethos.

---

## Bottom line
Both screens are substantially implemented and on-brand. Neither is a
pixel/structure-exact reproduction.

- **Screen 15**: faithful overall; the one notable structural miss is the
  absent step-label on intro/concept steps, plus the completion-circle
  contradiction.
- **Screen 16**: toast / picker / chat-error / ad-free-reading are solid; the
  two genuine build gaps are the **spec confirm-dialog form** and the
  **scripture-end "finished" banner**. Word-callout and pull-to-refresh are
  intentional defers/cuts; the Home banner ad diverges to an app-open strategy.
