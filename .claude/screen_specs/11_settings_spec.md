# Screen Spec — Settings (11)

> Canonical per roadmap D3. Derived from brief §"Screen 9 — Settings" +
> `New Design/screen-09-settings.html` + the current working
> `settings_page.dart` (607 lines, 7 live providers). **This is a visual
> restyle: preserve every existing provider and behavior; change presentation
> only.** Routes: `/settings` (root route, back-button chrome — done in S1).

## Intent

Bring Settings to the heritage visual language of the spec-built screens
(Credits/Feedback): WarmBackdrop, plain sans title, `AppText.sectionLabel`
section headers with hairline divider, restrained rows, iron-red Reset section.
No functional regressions.

## Sections & order (per screen-09 mockup)

1. **Appearance** — Theme (3-segment Auto/Light/Dark)
2. **Reading** — Reading font size (slider) · Translation language ·
   Scripture experience
3. **Notifications** — Daily verse reminder (time) · Festival alerts (see §Deviations)
4. **Data** — Storage (informational) · Export bookmarks (see §Deviations) ·
   Clear reading history (confirm dialog)
5. **About** — App version (footer-style) · Credits & attributions →
   `/credits` · Privacy Policy (external) · Terms of Service (external) ·
   Send feedback → `/feedback`
6. **Reset** — Reset all settings (iron-red, confirm dialog)

## Visual rules

- Topbar: back arrow + plain title "Settings" (sans, no Devanāgarī decoration).
- `WarmBackdrop` background; `extendBodyBehindAppBar`.
- Section header: `AppText.sectionLabel(color: text3)`, uppercase, 24px h-pad,
  with a 1px `divider` bottom hairline (match Credits `_SectionHeader`).
- Rows: 14px vertical, 24px h-pad; leading 20px icon in `text2`/`saffron`
  where the mockup tints it; title Lora/sans per existing; trailing control
  (segment / slider / value / chevron / external arrow) unchanged in behavior.
- Reset section header + its row label in iron-red **`dIronRedBright`**
  (`lIronRedBright` light) — brief §2.6 contrast rule.
- Dark + light from day one (every color via `DColors`/`LColors` ternary).

## Behaviors to PRESERVE verbatim (do not rewrite logic)

- `themeModeProvider` 3-segment + `AnalyticsService.darkModeToggled`
- `fontSizeProvider` slider (min `kMinFontSize` 12 / max `kMaxFontSize` 24);
  it is persisted and consumed by Verse Detail (`verse_detail_page.dart:915`)
  — **audit #13 already satisfied**; do not add a new provider or touch
  Verse Detail.
- `localeProvider` language dialog (System/English/Hindi, `_none_` sentinel)
- `notificationTimeProvider` time picker (saffron-themed picker)
- `StreakService.instance.clearAllHistory()` + `currentStreakProvider`
  invalidation + confirm dialog (Clear reading history)
- `userExperienceLevelProvider` bottom sheet + `AnalyticsService`
- `PackageInfo` version line
- Privacy/Terms `launchUrl` external (existing gist URLs)
- Credits row already `context.push('/credits')`; Feedback row already
  `context.push('/feedback')` (fixed in S4 pre-step)

## Deviations / decisions (do NOT invent backend)

- **Translation language:** brief §2.4 — v1 ships English only; show "English"
  with no chevron when Hindi unavailable. Current code offers a Hindi option
  via `localeProvider`. KEEP existing behavior (it's a real provider); spec
  defers the "no chevron until Hindi ships" nuance as optional polish — not a
  v1 blocker, and removing a working locale switch is a regression.
- **Festival alerts (mockup row):** no provider exists. Render as a deferred
  row — visible, labeled "Day before each major parva", control disabled or
  omitted, NOT a fake toggle. Flag in the build, do not fabricate scheduling.
- **Storage (mockup row):** brief gives "72.1 MB" as static copy. Render an
  informational line with the bundled-DB size as static text. Do NOT build a
  storage-sizing service.
- **Export bookmarks (mockup row):** no export mechanism exists. Defer —
  visible row, "coming soon"/disabled, NOT a broken tap. Real export is a
  later subsystem if the user wants it (note in roadmap risks).
- **Font slider scale:** brief wants discrete 7-tick `SanskritScale.sizes`
  (14–28). Current is continuous 12–24 driving `sanskritScale` ratio. Changing
  the scale shape risks the Verse-Detail wiring; treat as **optional polish**,
  not part of the restyle. If done, must re-verify Verse Detail visually.

## Acceptance criteria

- [ ] Topbar: back + plain "Settings" title; WarmBackdrop; no bottom nav
- [ ] Six sections in order, each with `sectionLabel` header + hairline
- [ ] Theme 3-segment still toggles + analytics fires
- [ ] Font slider still reads/writes `fontSizeProvider` (Verse Detail honors it)
- [ ] Language dialog unchanged; experience-level sheet unchanged
- [ ] Notification time picker unchanged (saffron theme)
- [ ] Clear history confirm dialog → `StreakService.clearAllHistory` unchanged
- [ ] Credits row → `/credits`; Feedback row → `/feedback`; Privacy/Terms external
- [ ] Reset section in `*IronRedBright`; "Reset all settings" → confirm dialog
      that clears prefs (theme/font/locale/notif/level) and shows a snackbar
- [ ] Deferred rows (Festival alerts, Storage, Export bookmarks) render but do
      not fake functionality
- [ ] Dark + light both correct; `flutter analyze` clean; widget test green
- [ ] On-device visual smoke (both themes) — owed to user (agent can't drive)

## Don'ts

- ❌ Don't remove or rewire any working provider
- ❌ Don't fabricate Festival-alert scheduling, storage sizing, or bookmark export
- ❌ Don't add a new font provider or modify Verse Detail (audit #13 satisfied)
- ❌ Don't show bottom nav (S1 moved /settings out of the shell)
- ❌ Don't use iron-red outside the Reset section
