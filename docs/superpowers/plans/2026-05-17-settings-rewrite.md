# Settings Restyle Implementation Plan (S4)

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans.
> Obeys roadmap D1–D5. Spec authority: `.claude/screen_specs/11_settings_spec.md`.
> Visual ref: `New Design/screen-09-settings.html`.
> **This is a visual restyle of a working 607-line file. PRESERVE every provider
> and behavior; change presentation only.** Read the spec's "Behaviors to
> PRESERVE" + "Deviations" sections before starting — they are binding.

**Goal:** Re-skin `settings_page.dart` to the heritage language (WarmBackdrop,
`AppText.sectionLabel` headers + hairlines, six ordered sections, iron-red Reset)
without changing any provider wiring or behavior.

**Architecture:** Keep `SettingsPage` a `ConsumerWidget`. Replace the Material
`ListTile`/`SegmentedButton` chrome with heritage rows (mirror the Credits
`_SectionHeader`/row idiom). Each existing `_XxxTile`'s **logic moves verbatim**
into a restyled row widget; only the wrapping presentation changes.

**Tech Stack:** Flutter, Riverpod, Material 3, dual theme, `AppText.*`, tokens.

**Pre-step already done in S4:** `_FeedbackTile.onTap` → `context.push('/feedback')`
(committed `f152105`). Do not re-do it.

---

## File map

- Rewrite: `lib/presentation/features/settings/pages/settings_page.dart`
- Test: `test/presentation/features/settings/settings_page_test.dart`
- No provider/data files change. No Verse Detail change.

Provider imports to keep (all still used): `font_size_provider`,
`locale_provider`, `notification_time_provider`, `theme_mode_provider`,
`user_experience_level_provider`, `streak_service`, `analytics_service`,
`package_info_plus`, `url_launcher`, `go_router`, `app_localizations`.
Add: `design_tokens`, `design_typography`. Likely droppable after restyle:
`typography_extensions` (`context.ts`), `app_colors`, `app_spacing` — confirm
zero remaining refs before removing imports.

---

### Task 1: Heritage shell widgets

Add private widgets mirroring Credits' idiom (see
`credits_page.dart` `_SectionHeader`). Build them first so every row uses them.

- [ ] **Step 1:** Add to settings_page.dart:

```dart
// Section header: uppercase sectionLabel + 1px hairline (Credits idiom).
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.isDark});
  final String title;
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 4),
      padding: const EdgeInsets.only(bottom: 8),
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(color: divider))),
      child: Text(title.toUpperCase(),
          style: AppText.sectionLabel(color: text3)),
    );
  }
}

// Generic row: leading icon + title (+ optional subtitle) + trailing widget.
class _Row extends StatelessWidget {
  const _Row({
    required this.isDark,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });
  final bool isDark;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;
  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final iron = isDark ? DColors.ironRedBright : LColors.ironRedBright;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final fg = danger ? iron : text1;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: danger ? iron : saffron),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontFamily: Fonts.sans,
                          fontSize: 14,
                          color: fg)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: TextStyle(
                            fontFamily: Fonts.serif,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            color: text2)),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2:** `flutter analyze` the file (will still reference old tiles —
      that's fine until Task 2). Commit.

```bash
git add lib/presentation/features/settings/pages/settings_page.dart
git commit -m "feat(settings): heritage section-header + row shell widgets"
```

---

### Task 2: Port each section into the shell (logic verbatim)

For EACH existing tile, move its provider logic into a `_Row` (or keep its
control as the `trailing:`). Do not alter `ref.watch`/`ref.read`/dialog/sheet
logic — only the surrounding widget. Map (current → new):

| Current (line range) | New row | Section |
|---|---|---|
| `_ThemeTile` (136–185) | `_Row` + existing `SegmentedButton` as `trailing` | Appearance |
| `_FontSizeTile` (278–311) | `_Row` titled "Reading font size", `Slider` row as a full-width child below (keep `fontSizeProvider` logic) | Reading |
| `_LanguageTile` (190–243) | `_Row` subtitle = current label, `onTap` opens existing dialog | Reading |
| `_ExperienceLevelTile` (418–507) | `_Row` subtitle = `level.displayTitle`, `onTap` opens existing sheet | Reading |
| `_NotificationTimeTile` (315–358) | `_Row` "Daily verse reminder", `trailing` = existing time `TextButton` | Notifications |
| (new) Festival alerts | `_Row` "Festival alerts" / subtitle "Day before each major parva", `onTap: null`, no control (deferred per spec) | Notifications |
| (new) Storage | `_Row` "Storage" / subtitle static size, `onTap: null` | Data |
| (new) Export bookmarks | `_Row` "Export bookmarks", `onTap: null` (deferred per spec) | Data |
| `_ClearHistoryTile` (362–414) | `_Row` "Clear reading history" / subtitle, `onTap` = existing confirm dialog | Data |
| `_AppVersionTile` (511–535) | `_Row` "Sanatan Guide", `trailing` = version `Text` (keep `PackageInfo` FutureBuilder) | About |
| `_CreditsTile` (592–607) | `_Row` "Credits & attributions", chevron, `onTap: () => context.push('/credits')` | About |
| `_LinkTile` ×2 (539–562) | `_Row` Privacy / Terms, external-arrow trailing, existing `launchUrl` | About |
| `_FeedbackTile` (566–588) | `_Row` "Send feedback", chevron, `onTap: () => context.push('/feedback')` (already routed) | About |

- [ ] **Step 1:** Rewrite `SettingsPage.build` body to a `ListView` of
      `_SectionHeader` + `_Row`s in the spec's six-section order, `WarmBackdrop`
      Stack, plain "Settings" AppBar title (drop `context.ts.displayMedium` →
      `AppText` or a plain sans `TextStyle`). Keep `extendBodyBehindAppBar` +
      the `kToolbarHeight + paddingOf` top pad pattern.
- [ ] **Step 2:** Move each tile's logic into its `_Row`. Delete the old
      `_XxxTile` classes once ported. For the font slider, keep the `A …slider… A`
      row but wrap in the new section visual.
- [ ] **Step 3:** Remove now-unused imports (`typography_extensions`,
      `app_colors`, `app_spacing`) **only after** `grep` shows zero refs.
- [ ] **Step 4:** `flutter analyze` clean. `flutter test` (full) green —
      existing settings behaviors must not regress.
- [ ] **Step 5:** Commit.

```bash
git add lib/presentation/features/settings/pages/settings_page.dart
git commit -m "feat(settings): restyle to heritage spec 11 (logic preserved)"
```

---

### Task 3: Reset section

Spec §6: iron-red "Reset all settings" → confirm dialog clearing prefs.

- [ ] **Step 1:** Add a `_ResetRow` (`_Row` with `danger: true`) under a
      `_SectionHeader('Reset')`. `onTap` shows an `AlertDialog` (mirror
      `_ClearHistoryTile._showConfirmDialog` styling) titled "Reset all
      settings?"; on confirm, reset the existing notifiers to defaults:
      `themeModeProvider`→system, `fontSizeProvider`→`kDefaultFontSize`,
      `localeProvider`→null, `notificationTimeProvider`→its default,
      `userExperienceLevelProvider`→its default. Use each notifier's existing
      setter (no new persistence code). Snackbar "Settings reset".
- [ ] **Step 2:** analyze + full test green. Commit.

```bash
git add lib/presentation/features/settings/pages/settings_page.dart
git commit -m "feat(settings): iron-red Reset section with confirm dialog"
```

---

### Task 4: Widget test

- [ ] **Step 1:** `test/presentation/features/settings/settings_page_test.dart`
      — pump `SettingsPage` inside `ProviderScope` + `MaterialApp.router`
      (router with no-op `/credits` `/feedback` routes; copy provider-override
      setup from an existing settings-touching test if one exists, else mock
      SharedPreferences via `SharedPreferences.setMockInitialValues({})`).
      Assert: six section headers present (APPEARANCE/READING/NOTIFICATIONS/
      DATA/ABOUT/RESET); theme `SegmentedButton` present; "Clear reading
      history" row present; light theme pumps with `tester.takeException()`
      null. Tapping "Credits & attributions" navigates to the stub `/credits`.
- [ ] **Step 2:** Run; fix any RenderFlex (Expanded/maxLines). Full suite green.
- [ ] **Step 3:** Commit.

```bash
git add test/presentation/features/settings/settings_page_test.dart
git commit -m "test(settings): six sections, theme control, both themes"
```

---

### Task 5: Acceptance walk

- [ ] Walk every `.claude/screen_specs/11_settings_spec.md` acceptance bullet
      literally against running app/widget test.
- [ ] Confirm NO behavior regression: toggle theme, drag font slider, open
      language dialog, open experience sheet, open time picker, open clear-
      history dialog — each still calls its original provider/service.
- [ ] Confirm Verse Detail still honors `fontSizeProvider` (visual check or
      existing verse-detail test still green).
- [ ] Honest note: on-device visual smoke (both themes) owed to user.
- [ ] Mark S4 ✅ in roadmap; add "bookmark export deferred" to roadmap risks.
- [ ] Commit roadmap update.

---

## Self-review

- **Spec coverage:** six sections, Reset, deferred rows, preserve-list all
  mapped to Tasks 1–5. Audit #13 explicitly out (already satisfied — verified
  `verse_detail_page.dart:915`).
- **Placeholder scan:** shell widget code given in full; per-section porting is
  a precise lift-from-line-range table, not vague TODOs.
- **Type consistency:** `_SectionHeader(title,isDark)`, `_Row(...)`,
  `_ResetRow` used consistently; existing provider names unchanged.
- **Risk:** highest blast-radius file of the project. Mitigation: logic moved
  verbatim, full test suite must stay green, behavior-regression checklist in
  Task 5, deferred rows explicitly faked-safe (onTap null), no Verse Detail or
  provider edits.
