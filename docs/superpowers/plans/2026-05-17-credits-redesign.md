# Credits Redesign Implementation Plan (S2)

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans.
> Obeys roadmap decisions D1–D5. Spec authority:
> `.claude/screen_specs/13_navigation_credits_feedback_spec.md` Part B.
> Visual ref: `New Design/mockups/screen-13-navigation-credits-feedback.html`
> (frames: "Credits top", "Credits scrolled", "Light · Credits").

**Goal:** Replace the old WarmBackdrop credits screen with the heritage design —
sūtra-numbered domain sections, lineage footer with BindingLine + Bṛhadāraṇyaka
blessing — so it matches the spec-built screens (the user's "app not uniform" fix).

**Architecture:** Rewrite `credits_page.dart` in place (D5; git is the rollback).
Reuse the real `contentCredits` data for scripture sections; add an
`appToolCredits` list for the "Tools used" section (GRETIL, Project Madurai,
indic-transliteration, fonts, Flutter/Riverpod/Drift — spec's required sources).

**Tech Stack:** Flutter, Material 3, dual theme, `DandaCoord.toDevanagari`,
`BindingLine`, `AppText.*`, design tokens.

---

## File map

- Modify: `lib/core/constants/content_credits.dart` — add `AppToolCredit` + `appToolCredits`
- Modify (rewrite): `lib/presentation/features/settings/pages/credits_page.dart`
- Test: `test/presentation/features/settings/credits_page_test.dart`

Keep `contentCredits` (30+ scripture sources) unchanged — real data, grouped by
`CreditCatalogSection.catalogTitle`. Sections render in that enum order; the
Tools section is appended last.

---

### Task 1: Add app-tool credits data

**Files:**
- Modify: `lib/core/constants/content_credits.dart` (append at end of file)

- [ ] **Step 1: Append the model + data**

```dart

/// A non-scripture credit: digitisation sources, libraries, fonts, stack.
/// Rendered in the "Tools used in preparing this app" section.
class AppToolCredit {
  const AppToolCredit({
    required this.title,
    required this.description,
    required this.meta,
    this.linksOut = false,
  });

  final String title;
  final String description;
  final String meta;

  /// Renders the external-link arrow when true (row points to a public site).
  final bool linksOut;
}

const List<AppToolCredit> appToolCredits = [
  AppToolCredit(
    title: 'GRETIL — Göttingen Register of Electronic Texts in Indian Languages',
    description:
        'Source Sanskrit e-texts for several Vedas, Upaniṣads, the '
        'Bhāgavata Purāṇa and the Yoga Sūtras.',
    meta: 'Universität Göttingen · Public domain',
    linksOut: true,
  ),
  AppToolCredit(
    title: 'sacred-texts.com — Ralph T.H. Griffith & others',
    description:
        'Public-domain English Vedic and epic translations digitised by the '
        'Internet Sacred Text Archive.',
    meta: 'sacred-texts.com · Public domain',
    linksOut: true,
  ),
  AppToolCredit(
    title: 'Project Madurai',
    description:
        'Digitised the Tirukkuṛaḷ and other classical Tamil texts.',
    meta: 'projectmadurai.org · Free electronic texts',
    linksOut: true,
  ),
  AppToolCredit(
    title: 'indic-transliteration',
    description:
        'IAST ↔ Devanāgarī transliteration used throughout the reader.',
    meta: 'Open source · MIT',
    linksOut: true,
  ),
  AppToolCredit(
    title: 'Tiro Devanagari Sanskrit · Lora · Outfit · Noto Sans Devanagari',
    description: 'The four typefaces this app is set in.',
    meta: 'SIL Open Font License 1.1',
  ),
  AppToolCredit(
    title: 'Flutter · Riverpod · Drift',
    description: 'The framework, state layer and local database.',
    meta: 'BSD · MIT · Apache 2.0',
  ),
];
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/core/constants/content_credits.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/constants/content_credits.dart
git commit -m "feat(credits): add app-tool credits data (GRETIL, fonts, stack)"
```

---

### Task 2: Rewrite credits_page.dart to the heritage spec

**Files:**
- Rewrite: `lib/presentation/features/settings/pages/credits_page.dart`

Spec 13 §B requirements encoded:
- Back-arrow topbar, NO title text
- Hero: `श्रद्धा · WITH GRATITUDE` (AppText.sectionLabel, saffron) → "Credits &
  Attributions" (Lora 26 w500, lh 1.15) → prose (Lora italic 14, lh 1.6)
- Scripture sections from `contentCredits` grouped by `section.catalogTitle`
  (enum order), then a final "Tools used in preparing this app" section from
  `appToolCredits`
- Section header: AppText.sectionLabel in dText3 + 1px dDivider bottom border
- Row: 14px v-pad; 16px-wide centred Devanāgarī numeral (Fonts.deva, 14, saffron)
  via `DandaCoord.toDevanagari(i)` — numerals **reset to १ per section**; body =
  title (Lora 15 w500) + description (Lora italic 12.5 lh1.5) + meta
  (AppText.meta ~9.5); external-link arrow (opacity .4) when the row links out;
  1px dDividerSoft between rows, none after last
- Lineage footer: bordered card (1px dDivider, radius 4, pad 22, bg surface),
  `BindingLine(isDark:)` on top, centred blessing
  `सर्वे भवन्तु सुखिनः ।\nसर्वे सन्तु निरामयाः ॥` (Fonts.deva 18 lh1.4) +
  attribution (Lora italic 12.5) "— Bṛhadāraṇyaka Upaniṣad 1.4.14"
- Row entrance: fade-up, 40ms stagger (TweenAnimationBuilder, capped index)
- Don'ts: no verse coords, no deity/mandala/lotus, group by domain, numerals
  saffron, external arrows on linking rows

- [ ] **Step 1: Replace the whole file**

```dart
// lib/presentation/features/settings/pages/credits_page.dart
//
// Credits & Attributions — heritage spec 13 Part B. Sūtra-numbered domain
// sections + Bṛhadāraṇyaka lineage footer. Scripture data from contentCredits;
// tool data from appToolCredits.

import 'package:flutter/material.dart';
import 'package:sanatan_guide/core/constants/content_credits.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

/// One render row, source-agnostic (scripture or tool).
class _Row {
  const _Row({
    required this.title,
    required this.description,
    required this.meta,
    required this.linksOut,
  });
  final String title;
  final String description;
  final String meta;
  final bool linksOut;
}

class _Section {
  const _Section(this.title, this.rows);
  final String title;
  final List<_Row> rows;
}

List<_Section> _buildSections() {
  final sections = <_Section>[];
  for (final s in CreditCatalogSection.values) {
    final rows = contentCredits
        .where((c) => c.section == s)
        .map((c) => _Row(
              title: c.displayName,
              description: c.translators.join(' · '),
              meta: c.licenseNote == null
                  ? '${c.source} · ${c.licenseLabel}'
                  : '${c.source} · ${c.licenseLabel} · ${c.licenseNote}',
              linksOut: c.source.contains('.'),
            ))
        .toList();
    if (rows.isNotEmpty) sections.add(_Section(s.catalogTitle, rows));
  }
  sections.add(_Section(
    'Tools used in preparing this app',
    appToolCredits
        .map((t) => _Row(
              title: t.title,
              description: t.description,
              meta: t.meta,
              linksOut: t.linksOut,
            ))
        .toList(),
  ));
  return sections;
}

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final sections = _buildSections();

    final blocks = <Widget>[
      _Hero(isDark: isDark),
      const SizedBox(height: 28),
    ];
    var animIndex = 0;
    for (final section in sections) {
      blocks.add(_SectionHeader(title: section.title, isDark: isDark));
      for (var i = 0; i < section.rows.length; i++) {
        blocks.add(_FadeUp(
          index: animIndex++,
          child: _CreditRow(
            numeral: DandaCoord.toDevanagari(i + 1),
            row: section.rows[i],
            isDark: isDark,
            showDivider: i != section.rows.length - 1,
          ),
        ));
      }
      blocks.add(const SizedBox(height: 28));
    }
    blocks.add(_LineageFooter(isDark: isDark));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: text1),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SafeArea(
            top: false,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: kToolbarHeight + MediaQuery.paddingOf(context).top,
                bottom: 32,
              ),
              children: blocks,
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.isDark});
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('श्रद्धा · WITH GRATITUDE',
            style: AppText.sectionLabel(color: saffron)),
        const SizedBox(height: 12),
        Text(
          'Credits & Attributions',
          style: TextStyle(
            fontFamily: Fonts.serif,
            fontSize: 26,
            fontWeight: FontWeight.w500,
            height: 1.15,
            letterSpacing: -0.5,
            color: text1,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Every verse in this app comes from a real academic source. '
          'Nothing is invented. The texts are public domain; the '
          'digitisation work that made them readable is not. We '
          'acknowledge it here.',
          style: TextStyle(
            fontFamily: Fonts.serif,
            fontStyle: FontStyle.italic,
            fontSize: 14,
            height: 1.6,
            color: text2,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.isDark});
  final String title;
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: divider)),
      ),
      child: Text(title.toUpperCase(),
          style: AppText.sectionLabel(color: text3)),
    );
  }
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({
    required this.numeral,
    required this.row,
    required this.isDark,
    required this.showDivider,
  });
  final String numeral;
  final _Row row;
  final bool isDark;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final sep = isDark ? DColors.dividerSoft : LColors.dividerSoft;

    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: sep))
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 16,
            child: Text(
              numeral,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Fonts.deva,
                fontSize: 14,
                color: saffron,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    color: text1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  row.description,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontStyle: FontStyle.italic,
                    fontSize: 12.5,
                    height: 1.5,
                    color: text2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(row.meta, style: AppText.meta(color: text3, size: 9.5)),
              ],
            ),
          ),
          if (row.linksOut)
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 2),
              child: Icon(Icons.north_east,
                  size: 11, color: text3.withValues(alpha: 0.6)),
            ),
        ],
      ),
    );
  }
}

class _LineageFooter extends StatelessWidget {
  const _LineageFooter({required this.isDark});
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    final surface = isDark ? DColors.surface : LColors.surface;
    final divider = isDark ? DColors.divider : LColors.divider;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    return Container(
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: divider),
      ),
      child: Column(
        children: [
          BindingLine(isDark: isDark),
          const SizedBox(height: 18),
          Text(
            'सर्वे भवन्तु सुखिनः ।\nसर्वे सन्तु निरामयाः ॥',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontSize: 18,
              height: 1.4,
              color: saffron,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"May all be happy. May all be free of suffering."\n'
            '— Bṛhadāraṇyaka Upaniṣad 1.4.14',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontStyle: FontStyle.italic,
              fontSize: 12.5,
              height: 1.5,
              color: text2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fade-up entrance, 40 ms stagger (index capped so deep rows still animate).
class _FadeUp extends StatelessWidget {
  const _FadeUp({required this.index, required this.child});
  final int index;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final delayMs = (index.clamp(0, 14)) * 40;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + delayMs),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 8), child: child),
      ),
      child: child,
    );
  }
}
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/presentation/features/settings/pages/credits_page.dart`
Expected: `No issues found!` (note: removes the old `context.ts` / AppColors /
AppSpacing usage — confirm no other file imports symbols from this file; only
`CreditsPage` is referenced, by the router).

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/features/settings/pages/credits_page.dart
git commit -m "feat(credits): rewrite to heritage spec 13 Part B"
```

---

### Task 3: Widget test

**Files:**
- Create: `test/presentation/features/settings/credits_page_test.dart`

- [ ] **Step 1: Write the test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/features/settings/pages/credits_page.dart';

void main() {
  testWidgets('Credits renders hero, sūtra numerals, blessing footer',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreditsPage()));
    await tester.pump(const Duration(seconds: 1)); // settle fade-ups

    expect(find.text('श्रद्धा · WITH GRATITUDE'), findsOneWidget);
    expect(find.text('Credits & Attributions'), findsOneWidget);
    expect(find.textContaining('Bṛhadāraṇyaka Upaniṣad'), findsOneWidget);
    expect(find.textContaining('GRETIL'), findsOneWidget);
    // Devanāgarī numeral marker for the first row of a section.
    expect(find.text('१'), findsWidgets);
  });

  testWidgets('Credits renders in light theme without overflow',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      home: const CreditsPage(),
    ));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run — expect PASS**

Run: `flutter test test/presentation/features/settings/credits_page_test.dart`
Expected: PASS. If a RenderFlex overflow appears (as in S1 T3), constrain the
offending Text with `Expanded`/`maxLines` and re-run.

- [ ] **Step 3: Full suite + commit**

Run: `flutter analyze` → clean. `flutter test` → all green.

```bash
git add test/presentation/features/settings/credits_page_test.dart
git commit -m "test(credits): heritage layout, sūtra numerals, blessing, both themes"
```

---

### Task 4: Acceptance walk

- [ ] Walk spec 13 §B acceptance literally:
  - [ ] Back arrow returns to previous (Settings or overflow)
  - [ ] All required sources present (GRETIL, sacred-texts/Griffith, Project
        Madurai, indic-transliteration, fonts OFL, Flutter/Riverpod/Drift)
  - [ ] Sections grouped by domain (not alphabetical) — enum order + Tools last
  - [ ] Devanāgarī numerals (१ २ ३), saffron, reset per section
  - [ ] External-link arrows on rows that link out
  - [ ] Lineage footer: BindingLine + Bṛhadāraṇyaka blessing
  - [ ] Both themes render (light test asserts no exception)
  - [ ] Fade-up on row entry
- [ ] Note honestly: on-device visual smoke (both themes) still owed — same
      constraint as S1 (agent can't drive a device).
- [ ] Mark S2 ✅ in the roadmap subsystem table.
- [ ] Commit roadmap update.

---

## Self-review

- **Spec coverage:** §B.1–B footer all mapped to Task 2; required-sources table
  → Task 1 `appToolCredits` + existing `contentCredits` (Griffith/sacred-texts
  already in scripture rows). Numerals reset per section (loop resets `i`).
- **Placeholder scan:** none — full file content given.
- **Type consistency:** `_Row`/`_Section`/`_buildSections`/`AppToolCredit`/
  `appToolCredits`/`DandaCoord.toDevanagari` used identically.
- **D2 check:** uses lib `DandaCoord.toDevanagari`, `BindingLine(isDark:)`,
  `AppText.sectionLabel/meta` — all verified to exist in lib.
- **Don'ts honored:** no DandaCoord *widget* (no ‖ ‖ coords), no deity/lotus,
  domain grouping, saffron numerals, external arrows conditional.
