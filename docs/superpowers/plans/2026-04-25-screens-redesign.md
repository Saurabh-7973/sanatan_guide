# Sanatan Guide — Screens Redesign (Plan B) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the 23 sacred ornament painters (already built in Plan A) into the 12 app screens, starting with the Verse Detail "Sanctum" direction and working outward to all secondary screens.

**Architecture:** Two new shared widgets (SanctumCard, GutterRail) underpin the verse detail redesign. Each subsequent task is a targeted substitution in one file — emoji/icon swaps, empty-state replacements, and backdrop injections. Home screen untouched throughout.

**Tech Stack:** Flutter 3.x, Dart 3.x, Riverpod 3, CustomPainter painters in `sacred_ornaments.dart` (already built), Lora/TiroDevanagari fonts (already registered).

**Spec reference:** `docs/superpowers/specs/2026-04-25-full-redesign-design.md` and `claudedesign/components/direction-sanctum.jsx`

**Quality gate after every task:** `flutter analyze` must report zero errors. No emojis in presentation layer.

---

## File Map

### New files
- `lib/presentation/features/scripture_reader/widgets/sanctum_card.dart` — reusable collapsible card with left saffron accent bar
- `lib/presentation/features/scripture_reader/widgets/gutter_rail.dart` — 48 px left column for Sanctum verse detail

### Modified files
- `lib/presentation/features/scripture_reader/pages/verse_detail_page.dart` — Sanctum layout (Task 3)
- `lib/presentation/features/onboarding/pages/onboarding_page.dart` — emoji → drawn icons + GangaWaveBackdrop (Task 4)
- `lib/presentation/features/search/pages/search_page.dart` — PeacockIllustration (Task 5)
- `lib/presentation/features/bookmarks/pages/bookmarks_page.dart` — PrasadTrayIllustration empty state (Task 6)
- `lib/presentation/features/festivals/pages/festival_calendar_page.dart` — DiyaFlameIcon replacing emoji (Task 7)
- `lib/presentation/features/settings/pages/settings_page.dart` — OilLampRowDivider replacing Divider (Task 8)
- `lib/presentation/features/settings/pages/credits_page.dart` — InscriptionBorderBackdrop header (Task 9)
- `lib/presentation/features/scripture_reader/pages/scripture_library_page.dart` — NalandaArchBackdrop header (Task 10)
- `lib/presentation/features/scripture_reader/pages/verse_chat_page.dart` — DhyanaAsanaBackdrop (Task 11)
- `lib/presentation/features/learning_path/pages/learning_path_page.dart` — TempleStaircaseBackdrop (Task 12)
- `lib/presentation/features/learning_path/pages/module_reader_page.dart` — PeepalTreeBackdrop (Task 12)

---

## Task 1: SanctumCard widget

**Files:**
- Create: `lib/presentation/features/scripture_reader/widgets/sanctum_card.dart`
- Test: `test/presentation/widgets/sanctum_card_test.dart`

- [ ] **Step 1: Create `sanctum_card.dart`**

```dart
// lib/presentation/features/scripture_reader/widgets/sanctum_card.dart
import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// Reusable sanctum-style card: surface bg, border, left 3 px saffron accent,
/// optional collapse chevron. Matches direction-sanctum.jsx `SanctumCard`.
class SanctumCard extends StatefulWidget {
  const SanctumCard({
    super.key,
    required this.title,
    required this.child,
    this.collapsible = false,
    this.initiallyExpanded = true,
    this.headerAction,
  });

  final String title;
  final Widget child;
  final bool collapsible;
  final bool initiallyExpanded;
  final Widget? headerAction;

  @override
  State<SanctumCard> createState() => _SanctumCardState();
}

class _SanctumCardState extends State<SanctumCard> {
  late bool _open;

  @override
  void initState() {
    super.initState();
    _open = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant SanctumCard old) {
    super.didUpdateWidget(old);
    if (old.initiallyExpanded != widget.initiallyExpanded &&
        widget.collapsible) {
      _open = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final saff = isDark ? AppColors.saffronOnDark : AppColors.saffron;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: border),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.collapsible
                ? () => setState(() => _open = !_open)
                : null,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                _open ? AppSpacing.sm : AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      color: saff,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.title.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (widget.headerAction != null) widget.headerAction!,
                  if (widget.collapsible) ...[
                    if (widget.headerAction != null)
                      const SizedBox(width: AppSpacing.xs),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.textSecondaryOnDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: widget.child,
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState:
                _open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Write widget test**

```dart
// test/presentation/widgets/sanctum_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/sanctum_card.dart';

Widget _wrap(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('SanctumCard shows title and child', (tester) async {
    await tester.pumpWidget(_wrap(const SanctumCard(
      title: 'Translation',
      child: Text('Some content'),
    )));
    expect(find.text('TRANSLATION'), findsOneWidget);
    expect(find.text('Some content'), findsOneWidget);
  });

  testWidgets('SanctumCard collapses on tap when collapsible', (tester) async {
    await tester.pumpWidget(_wrap(const SanctumCard(
      title: 'Word by Word',
      collapsible: true,
      child: Text('word content'),
    )));
    expect(find.text('word content'), findsOneWidget);
    await tester.tap(find.text('WORD BY WORD'));
    await tester.pumpAndSettle();
    expect(find.text('word content'), findsNothing);
  });

  testWidgets('SanctumCard dark mode renders', (tester) async {
    await tester.pumpWidget(_wrap(
      const SanctumCard(title: 'Test', child: Text('dark')),
      dark: true,
    ));
    expect(find.text('TEST'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Run tests**

```
flutter test test/presentation/widgets/sanctum_card_test.dart
```

Expected: 3 tests PASS.

- [ ] **Step 4: Run analyze**

```
flutter analyze lib/presentation/features/scripture_reader/widgets/sanctum_card.dart
```

Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/scripture_reader/widgets/sanctum_card.dart \
        test/presentation/widgets/sanctum_card_test.dart
git commit -m "feat: add SanctumCard widget with saffron accent bar and collapse"
```

---

## Task 2: GutterRail widget

**Files:**
- Create: `lib/presentation/features/scripture_reader/widgets/gutter_rail.dart`
- Test: `test/presentation/widgets/gutter_rail_test.dart`

- [ ] **Step 1: Create `gutter_rail.dart`**

```dart
// lib/presentation/features/scripture_reader/widgets/gutter_rail.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';

/// 48 px left gutter for the Sanctum verse-detail layout.
/// Contains: vertical saffron rule, scripture code stamp, rotated
/// scripture name, and chapter/verse number display.
class GutterRail extends StatelessWidget {
  const GutterRail({super.key, required this.verse});

  final Verse verse;

  static String _abbrev(String code) => switch (code) {
        'bhagavad_gita' => 'BG',
        'rigveda' => 'RV',
        'samaveda' => 'SV',
        'yajurveda' => 'YV',
        'atharvaveda' => 'AV',
        'yoga_sutras' => 'YS',
        'bhagavata_purana' => 'BP',
        'vishnu_sahasranama' => 'VS',
        'tirukkural' => 'TK',
        'ramayana' => 'RM',
        'mahabharata' => 'MB',
        _ => code
            .split('_')
            .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
            .take(2)
            .join(),
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saff = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    final muted = isDark
        ? AppColors.textSecondaryOnDark
        : AppColors.textSecondary;
    final textC = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final abbrev = _abbrev(verse.scripture.code);

    return SizedBox(
      width: 48,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              // Vertical saffron gradient rule
              Positioned(
                top: 12,
                bottom: 12,
                left: 23,
                child: Container(
                  width: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        saff.withValues(alpha: 0),
                        saff.withValues(alpha: 0.5),
                        saff.withValues(alpha: 0.5),
                        saff.withValues(alpha: 0),
                      ],
                      stops: const [0, 0.2, 0.8, 1],
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  const SizedBox(height: 16),

                  // Scripture code stamp
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.saffronFaint,
                      border: Border.all(color: saff),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      abbrev,
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: saff,
                        height: 1,
                      ),
                    ),
                  ),

                  // Rotated scripture name (fills remaining middle space)
                  Expanded(
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          verse.scripture.displayName.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4,
                            color: muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                  ),

                  // CH / verse number stamp
                  Column(
                    children: [
                      Text(
                        'CH',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 10,
                          letterSpacing: 1,
                          color: muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${verse.chapterNum}',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textC,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'V',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 10,
                          letterSpacing: 1,
                          color: muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${verse.verseNum}',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: saff,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Write widget test**

```dart
// test/presentation/widgets/gutter_rail_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/gutter_rail.dart';

Verse _fakeVerse() => Verse(
      id: 'BG.2.47',
      scripture: Scripture(
        code: 'bhagavad_gita',
        displayName: 'Bhagavad Gita',
      ),
      chapterNum: 2,
      verseNum: 47,
      sanskrit: 'कर्मण्येवाधिकारस्ते',
    );

Widget _wrap(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(body: SizedBox(height: 600, child: child)),
    );

void main() {
  testWidgets('GutterRail shows scripture abbreviation', (tester) async {
    await tester.pumpWidget(_wrap(GutterRail(verse: _fakeVerse())));
    expect(find.text('BG'), findsOneWidget);
  });

  testWidgets('GutterRail shows chapter and verse numbers', (tester) async {
    await tester.pumpWidget(_wrap(GutterRail(verse: _fakeVerse())));
    expect(find.text('2'), findsOneWidget);
    expect(find.text('47'), findsOneWidget);
  });

  testWidgets('GutterRail dark mode renders', (tester) async {
    await tester.pumpWidget(_wrap(GutterRail(verse: _fakeVerse()), dark: true));
    expect(find.text('BG'), findsOneWidget);
  });
}
```

**Important:** `Verse` and `Scripture` constructors must match the actual entity definitions. Read `lib/domain/entities/verse.dart` and `lib/domain/entities/scripture.dart` before writing the test to verify field names and required params.

- [ ] **Step 3: Run tests**

```
flutter test test/presentation/widgets/gutter_rail_test.dart
```

Expected: 3 tests PASS.

- [ ] **Step 4: Analyze**

```
flutter analyze lib/presentation/features/scripture_reader/widgets/gutter_rail.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/scripture_reader/widgets/gutter_rail.dart \
        test/presentation/widgets/gutter_rail_test.dart
git commit -m "feat: add GutterRail widget for Sanctum verse detail layout"
```

---

## Task 3: Verse Detail — Sanctum layout

**Files:**
- Modify: `lib/presentation/features/scripture_reader/pages/verse_detail_page.dart`

**Context:** `_VerseScaffoldState.build()` currently returns a `Scaffold` with `body: Stack([...shareCard, ...hintOverlay, GestureDetector(CustomScrollView([SliverAppBar, TranslationToggle, VerseContentSliver, AiExplanationBlock, CommentariesBlock]))])`. We replace this with a flat `Scaffold(appBar: AppBar, body: Row(GutterRail, SingleChildScrollView(Column)))`. All existing state logic (`_templeMode`, `_plainSanskritReading`, `_wordMeaningsExpanded`, `_showTranslit`, `_noteController`, haptics, analytics) is untouched.

**What changes in `_VerseScaffoldState.build()`:**

Replace the existing `return Scaffold(...)` (from line 378 to ~line 558) with:

```dart
@override
Widget build(BuildContext context) {
  final verse = widget.verse;
  final adjacent = ref.watch(adjacentVerseIdsProvider(verse.id));
  final prevId = adjacent.asData?.value.prevId;
  final nextId = adjacent.asData?.value.nextId;
  final hasNote = _noteController.text.trim().isNotEmpty ||
      (verse.noteText != null && verse.noteText!.isNotEmpty);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final saff = isDark ? AppColors.saffronOnDark : AppColors.saffron;
  final muted = isDark
      ? AppColors.textSecondaryOnDark
      : AppColors.textSecondary;

  return Scaffold(
    appBar: AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
        onPressed: widget.onBack,
      ),
      actions: [
        _BookmarkAction(verseId: verse.id),
        if (GeminiService.isEnabled)
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: 'Ask about this verse',
            color: AppColors.warmGrey50,
            onPressed: () => context.push(
              '/browse/${verse.scripture.code}/verse/${verse.id}/chat',
            ),
          ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          tooltip: 'Share verse',
          onPressed: () {
            AnalyticsService.verseShared(verse.id);
            ShareCardGenerator.captureAndShare(
              repaintKey: widget.shareCardKey,
              verse: verse,
            );
          },
        ),
      ],
    ),
    body: Stack(
      children: [
        // Offscreen share card
        Transform.translate(
          offset: const Offset(-10000, 0),
          child: RepaintBoundary(
            key: widget.shareCardKey,
            child: ShareCardWidget(verse: verse),
          ),
        ),

        // Temple mode hint overlay
        if (_showTempleHint)
          Positioned(
            bottom: 96,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _showTempleHint ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusChip),
                    ),
                    child: const Text(
                      'Double-tap to enter Temple mode',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Sanctum main layout
        GestureDetector(
          onDoubleTap: _toggleTempleMode,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 300 &&
                prevId != null) {
              try { Haptics.vibrate(HapticsType.light); } catch (_) {}
              widget.onGoToVerse(prevId);
              return;
            }
            if (details.primaryVelocity != null &&
                details.primaryVelocity! < -300 &&
                nextId != null) {
              try { Haptics.vibrate(HapticsType.light); } catch (_) {}
              widget.onGoToVerse(nextId);
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left gutter rail
              GutterRail(verse: verse),

              // Right scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: _SanctumContent(
                    verse: verse,
                    isDark: isDark,
                    saff: saff,
                    muted: muted,
                    plainSanskritReading: _plainSanskritReading,
                    canStripAccents: _canStripVedicAccents(verse),
                    isTirukkural: _isTirukkuralVerse(verse),
                    onToggleAccents: () => setState(() {
                      _plainSanskritReading = !_plainSanskritReading;
                    }),
                    wordMeaningsExpanded: _wordMeaningsExpanded,
                    onToggleWordMeanings: () => setState(() {
                      _wordMeaningsExpanded = !_wordMeaningsExpanded;
                    }),
                    showTranslitOverride: _showTranslit,
                    onToggleTranslit: () => setState(() {
                      _showTranslit = !_showTranslit;
                    }),
                    noteController: _noteController,
                    onNoteChanged: _onNoteChanged,
                    onOpenNotes: _showNotesSheet,
                    hasNote: hasNote,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),

    bottomNavigationBar: AnimatedOpacity(
      opacity: _templeMode ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
      child: IgnorePointer(
        ignoring: _templeMode,
        child: _VerseNavBar(
          verse: verse,
          prevId: prevId,
          nextId: nextId,
          onGoToVerse: widget.onGoToVerse,
          onOpenNotes: _showNotesSheet,
          hasNote: hasNote,
        ),
      ),
    ),
  );
}
```

**New `_SanctumContent` widget** — add this private class at the bottom of `verse_detail_page.dart`, before the `_VerseNavBar` class:

```dart
/// Right-column content for the Sanctum verse detail layout.
class _SanctumContent extends ConsumerWidget {
  const _SanctumContent({
    required this.verse,
    required this.isDark,
    required this.saff,
    required this.muted,
    required this.plainSanskritReading,
    required this.canStripAccents,
    required this.isTirukkural,
    required this.onToggleAccents,
    required this.wordMeaningsExpanded,
    required this.onToggleWordMeanings,
    required this.showTranslitOverride,
    required this.onToggleTranslit,
    required this.noteController,
    required this.onNoteChanged,
    required this.onOpenNotes,
    required this.hasNote,
  });

  final Verse verse;
  final bool isDark;
  final Color saff;
  final Color muted;
  final bool plainSanskritReading;
  final bool canStripAccents;
  final bool isTirukkural;
  final VoidCallback onToggleAccents;
  final bool wordMeaningsExpanded;
  final VoidCallback onToggleWordMeanings;
  final bool showTranslitOverride;
  final VoidCallback onToggleTranslit;
  final TextEditingController noteController;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onOpenNotes;
  final bool hasNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(readingModeProvider);
    final fontSize = ref.watch(font_prefs.fontSizeProvider);
    final showSanskrit =
        mode == ReadingMode.all || mode == ReadingMode.sanskrit;
    final showTranslit = mode == ReadingMode.all || showTranslitOverride;
    final showTranslation =
        mode == ReadingMode.all || mode == ReadingMode.translationOnly;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Translation toggle pill
          const _TranslationToggle(),
          const SizedBox(height: AppSpacing.md),

          // Scripture chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.saffronFaint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: saff,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  verse.scripture.displayName,
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: saff,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Sanskrit / Tamil block
          if (showSanskrit && verse.sanskrit.isNotEmpty) ...[
            if (isTirukkural)
              _TamilInline(verse: verse, isDark: isDark)
            else
              _SanskritInline(
                verse: verse,
                plain: plainSanskritReading,
                canStrip: canStripAccents,
                onToggleAccents: onToggleAccents,
                fontSize: fontSize,
                isDark: isDark,
              ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Accent-toggle hint
          if (showSanskrit &&
              verse.sanskrit.isNotEmpty &&
              canStripAccents)
            Text(
              plainSanskritReading
                  ? 'Tap Sanskrit to show Vedic accents'
                  : 'Tap Sanskrit for plain reading',
              style: TextStyle(
                fontSize: 11,
                color: muted.withValues(alpha: 0.6),
              ),
            ),

          // Transliteration toggle link
          if (!showTranslit &&
              mode != ReadingMode.all &&
              verse.transliteration != null &&
              verse.transliteration!.isNotEmpty &&
              showSanskrit) ...[
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: onToggleTranslit,
              child: Text(
                showTranslitOverride
                    ? 'Hide pronunciation'
                    : 'Show pronunciation',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 13,
                  color: saff,
                  decoration: TextDecoration.underline,
                  decorationColor: saff,
                ),
              ),
            ),
          ],

          // Transliteration label + text
          if (showTranslit &&
              verse.transliteration != null &&
              verse.transliteration!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(
                    width: 20, height: 1, color: isDark
                    ? AppColors.borderDark
                    : AppColors.border),
                const SizedBox(width: 8),
                Text(
                  'TRANSLITERATION',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              verse.transliteration!,
              style: TextStyle(
                fontFamily: 'Lora',
                fontStyle: FontStyle.italic,
                fontSize: fontSize,
                height: 1.7,
                color: isDark ? const Color(0xFFB8A88E) : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
          ],

          // Translation card
          if (showTranslation &&
              ((verse.english != null && verse.english!.isNotEmpty) ||
                  (verse.hindi != null && verse.hindi!.isNotEmpty)))
            SanctumCard(
              title: 'Translation',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (verse.english != null && verse.english!.isNotEmpty) ...[
                    Text(
                      verse.english!,
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: fontSize,
                        height: 1.65,
                        color: isDark
                            ? AppColors.textOnDark
                            : AppColors.textPrimary
                                .withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                  if (verse.hindi != null && verse.hindi!.isNotEmpty) ...[
                    if (verse.english != null && verse.english!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.border,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Text(
                      'HINDI',
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      verse.hindi!,
                      style: TextStyle(
                        fontFamily: 'NotoSansDevanagari',
                        fontSize: math.max(15.0, fontSize),
                        height: 1.7,
                        color: isDark
                            ? AppColors.textOnDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Translation hidden hint
          if (!showTranslation &&
              (verse.english != null && verse.english!.isNotEmpty)) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => ref
                  .read(readingModeProvider.notifier)
                  .setMode(ReadingMode.all),
              child: Text(
                'Translation hidden · tap to show',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 12,
                  color: saff.withValues(alpha: 0.7),
                  decoration: TextDecoration.underline,
                  decorationColor: saff.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],

          // Word-by-word card
          if (verse.wordMeanings != null &&
              verse.wordMeanings!.isNotEmpty)
            SanctumCard(
              title: 'Word by Word',
              collapsible: true,
              initiallyExpanded: wordMeaningsExpanded,
              child: Column(
                children: verse.wordMeanings!.map((wm) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        SizedBox(
                          width: 86,
                          child: Text(
                            wm.word,
                            style: TextStyle(
                              fontFamily: 'TiroDevanagari',
                              fontSize: 17,
                              color: isDark
                                  ? AppColors.sanskritTextOnDark
                                  : AppColors.sanskritText,
                            ),
                          ),
                        ),
                        Text(
                          '·',
                          style: TextStyle(color: muted, fontSize: 13),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            wm.meaning,
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: fontSize,
                              color: isDark
                                  ? AppColors.textOnDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // Your Reflection card
          SanctumCard(
            title: 'Your Reflection',
            headerAction: GestureDetector(
              onTap: onOpenNotes,
              child: Text(
                'Edit',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: saff,
                ),
              ),
            ),
            child: noteController.text.trim().isEmpty
                ? Text(
                    'Tap Edit to add your reflection on this verse.',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                      height: 1.7,
                      color: muted,
                    ),
                  )
                : Text(
                    noteController.text.trim(),
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                      height: 1.7,
                      color: isDark
                          ? AppColors.textOnDark
                          : AppColors.textPrimary,
                    ),
                  ),
          ),

          // Ask the Guide row
          if (GeminiService.isEnabled) ...[
            GestureDetector(
              onTap: () => context.push(
                '/browse/${verse.scripture.code}/verse/${verse.id}/chat',
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.saffronFaint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: saff.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      color: saff,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ask the Guide',
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textOnDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Context, meaning, Sanskrit terms',
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: saff,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Commentaries block
          CommentariesBlock(verseId: verse.id),

          // Swipe hint
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Swipe left or right to navigate',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: muted.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }
}

// ── Inline Sanskrit block for Sanctum layout ─────────────────────────────

class _SanskritInline extends StatelessWidget {
  const _SanskritInline({
    required this.verse,
    required this.plain,
    required this.canStrip,
    required this.onToggleAccents,
    required this.fontSize,
    required this.isDark,
  });

  final Verse verse;
  final bool plain;
  final bool canStrip;
  final VoidCallback onToggleAccents;
  final double fontSize;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text = plain && canStrip
        ? stripVedicAccents(verse.sanskrit)
        : verse.sanskrit;
    final color =
        isDark ? AppColors.sanskritTextOnDark : AppColors.sanskritText;
    final scale = fontSize / font_prefs.kDefaultFontSize;

    return GestureDetector(
      onTap: canStrip ? onToggleAccents : null,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'TiroDevanagari',
          fontSize: 24 * scale,
          height: 2.0,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _TamilInline extends StatelessWidget {
  const _TamilInline({required this.verse, required this.isDark});

  final Verse verse;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      verse.sanskrit,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 24,
        height: 2.0,
        color: isDark ? AppColors.sanskritTextOnDark : AppColors.sanskritText,
      ),
    );
  }
}
```

**Also add these imports** to the top of `verse_detail_page.dart`:

```dart
import 'dart:math' as math;
import 'package:sanatan_guide/core/utils/verse_text.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/reading_mode_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/gutter_rail.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/sanctum_card.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/font_size_provider.dart'
    as font_prefs;
```

**Remove `VerseContentSliver` import** from `verse_detail_page.dart` (it is no longer used):

```dart
// Remove this line:
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/verse_content_sliver.dart';
```

- [ ] **Step 1: Apply changes to `verse_detail_page.dart`**

Read the current file first, then:
1. Add the new imports (dart:math, verse_text, reading_mode_provider, gutter_rail, sanctum_card, font_size_provider as font_prefs)
2. Remove the `verse_content_sliver.dart` import (and `AiExplanationBlock` import if AiExplanationBlock is moved — but keep it since CommentariesBlock uses it)
3. Replace the `_VerseScaffoldState.build()` method body (lines 370–558 of original file) with the new Sanctum build shown above
4. Add `_SanctumContent`, `_SanskritInline`, `_TamilInline` private classes after `_VerseScaffoldState` class and before `_VerseNavBar`

- [ ] **Step 2: Analyze**

```
flutter analyze lib/presentation/features/scripture_reader/pages/verse_detail_page.dart
```

Fix any issues before moving on. Common: unused import of verse_content_sliver, missing `math` import, missing `context` in `_SanctumContent` (it's a ConsumerWidget, so use `context` from `build(context, ref)`).

- [ ] **Step 3: Run existing tests**

```
flutter test test/presentation/widgets/
```

Expected: All pass. If `sacred_ornaments_test.dart` fails due to unrelated reasons, investigate before proceeding.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/scripture_reader/pages/verse_detail_page.dart
git commit -m "feat: verse detail Sanctum layout — GutterRail + SanctumCards"
```

---

## Task 4: Onboarding — GangaWave backdrop + drawn icons

**Files:**
- Modify: `lib/presentation/features/onboarding/pages/onboarding_page.dart`

**Context:** 
- `Text('🕉', fontSize:48)` at top of step 1 → `Text('ॐ', style: TextStyle(fontFamily:'TiroDevanagari', fontSize:56, color:AppColors.saffron))`
- `_LevelCard(emoji:'🌱')` → `_LevelCard(icon: const SeedlingIcon(size:32))`
- `_LevelCard(emoji:'🪔')` → `_LevelCard(icon: const DiyaIcon(size:32))`
- `_LevelCard(emoji:'📜')` → `_LevelCard(icon: const ScrollIcon(size:32))`
- `_PathCard(emoji:'🌱')` → `_PathCard(icon: const TempleStairsIcon(size:32))`
- `_PathCard(emoji:'🪔')` → `_PathCard(icon: const DiamondKnotIcon(size:32))`
- `_PathCard(emoji:'📖')` → `_PathCard(icon: const OpenScrollIcon(size:32))`
- Scaffold body: wrap existing content in a `Stack` with `GangaWaveBackdrop` at bottom (IgnorePointer)

**Changes:**

1. **Add imports** to onboarding_page.dart:
```dart
import 'package:sanatan_guide/presentation/shared/widgets/sacred_ornaments.dart';
```

2. **Change `_LevelCard` constructor**: rename `emoji` field to `icon`, change type from `String` to `Widget`:
```dart
// Before:
final String emoji;
// Usage: Text(emoji, fontSize: 28)

// After:
final Widget icon;
// Usage: SizedBox(width: 32, height: 32, child: icon)
```

3. **Change `_PathCard` constructor**: same pattern.

4. **Replace `Text('🕉', ...)` with**:
```dart
Text(
  'ॐ',
  style: TextStyle(
    fontFamily: 'TiroDevanagari',
    fontSize: 56,
    color: AppColors.saffron,
    height: 1,
  ),
)
```

5. **Wrap Scaffold body** in a Stack to add GangaWaveBackdrop. Find the body widget (likely a PageView or SafeArea) and wrap it:
```dart
body: Stack(
  children: [
    // Background
    const Positioned.fill(
      child: IgnorePointer(child: GangaWaveBackdrop()),
    ),
    // Original body content (PageView / SafeArea etc.)
    _existingBodyWidget,
  ],
),
```

- [ ] **Step 1: Read the onboarding file** to locate exact line numbers for each change before editing.

- [ ] **Step 2: Apply all changes**

Apply in order: imports → _LevelCard field → _PathCard field → OM text → Scaffold body Stack.

- [ ] **Step 3: Analyze**

```
flutter analyze lib/presentation/features/onboarding/pages/onboarding_page.dart
```

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/onboarding/pages/onboarding_page.dart
git commit -m "feat: onboarding drawn icons + GangaWaveBackdrop, no emojis"
```

---

## Task 5: Search — PeacockIllustration

**Files:**
- Modify: `lib/presentation/features/search/pages/search_page.dart`

**Context:**
- `_EmptyPrompt` has a 72×72 circle Container with `Icon(Icons.auto_stories_outlined, size:32, color:AppColors.warmGrey50)` → replace with `PeacockIllustration(size:200)` (no circle container)
- Search bar `prefixIcon: const Icon(Icons.search_rounded, size:20, color:AppColors.textHint)` → replace with `SizedBox(width:20, height:20, child: PeacockIllustration(singleFeather:true, size:20))`
- Add `import 'package:sanatan_guide/presentation/shared/widgets/sacred_ornaments.dart';`

**Changes:**

1. **Empty state:**
```dart
// Before: Container(width:72, height:72, decoration:BoxDecoration(shape:BoxShape.circle,...), child: Icon(Icons.auto_stories_outlined,...))
// After:
PeacockIllustration(size: 200)
```

2. **Search bar prefix icon:**
```dart
// Before: prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textHint)
// After:
prefixIcon: Padding(
  padding: const EdgeInsets.all(12),
  child: PeacockIllustration(singleFeather: true, size: 20),
),
```

- [ ] **Step 1: Read search_page.dart** to find exact lines for empty state icon and prefixIcon.

- [ ] **Step 2: Apply changes**

Add import, replace empty state icon, replace prefixIcon.

- [ ] **Step 3: Analyze**

```
flutter analyze lib/presentation/features/search/pages/search_page.dart
```

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/search/pages/search_page.dart
git commit -m "feat: search page PeacockIllustration hero + feather search icon"
```

---

## Task 6: Bookmarks — PrasadTray empty state

**Files:**
- Modify: `lib/presentation/features/bookmarks/pages/bookmarks_page.dart`

**Context:**
- `_EmptyState` currently renders `Text('—', fontSize:72, fontFamily:'Lora', color:AppColors.warmGrey50)` as the illustration and "Your saved verses will appear here" as the message.
- Replace `Text('—', ...)` with `PrasadTrayIllustration(size: 160)`
- Change primary text to "Your offerings await"
- Keep secondary descriptive text as-is

**Changes:**

1. Add import:
```dart
import 'package:sanatan_guide/presentation/shared/widgets/sacred_ornaments.dart';
```

2. Replace illustration widget:
```dart
// Before: Text('—', style: TextStyle(fontSize: 72, fontFamily: 'Lora', color: AppColors.warmGrey50))
// After:
PrasadTrayIllustration(size: 160)
```

3. Change heading text:
```dart
// Before: 'Your saved verses will appear here'  (or similar)
// After: 'Your offerings await'
```

- [ ] **Step 1: Read bookmarks_page.dart** to find exact current text strings and line numbers.

- [ ] **Step 2: Apply all three changes.**

- [ ] **Step 3: Analyze**

```
flutter analyze lib/presentation/features/bookmarks/pages/bookmarks_page.dart
```

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/bookmarks/pages/bookmarks_page.dart
git commit -m "feat: bookmarks PrasadTrayIllustration empty state"
```

---

## Task 7: Festivals — DiyaFlameIcon

**Files:**
- Modify: `lib/presentation/features/festivals/pages/festival_calendar_page.dart`

**Context:**
- `_FestivalTile` uses `Text(festival.emoji, fontSize:28)` to show the festival icon. The `festival` is a domain entity with an `.emoji` String field — we do NOT change the entity. We just stop rendering `festival.emoji` and render `DiyaFlameIcon(size:28)` instead.
- The Hero tag `'festival_emoji_${festival.id}'` wraps the text. We keep the Hero widget but change the child.

**Change:**
```dart
// Before:
Hero(
  tag: 'festival_emoji_${festival.id}',
  child: Text(festival.emoji, style: TextStyle(fontSize: 28)),
)
// After:
Hero(
  tag: 'festival_emoji_${festival.id}',
  child: DiyaFlameIcon(size: 28),
)
```

- [ ] **Step 1: Read festival_calendar_page.dart** to confirm the exact Hero/Text structure and any festival detail page that might also render `festival.emoji` (if found, replace there too).

- [ ] **Step 2: Add import and apply change.**

```dart
import 'package:sanatan_guide/presentation/shared/widgets/sacred_ornaments.dart';
```

- [ ] **Step 3: Analyze**

```
flutter analyze lib/presentation/features/festivals/pages/festival_calendar_page.dart
```

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/festivals/pages/festival_calendar_page.dart
git commit -m "feat: festivals DiyaFlameIcon replaces emoji rendering"
```

---

## Task 8: Settings — OilLampRowDivider

**Files:**
- Modify: `lib/presentation/features/settings/pages/settings_page.dart`

**Context:**
- 5 `const Divider(indent: AppSpacing.pagePadding, endIndent: AppSpacing.pagePadding)` between sections (verified at approximately lines 43, 49, 55, 61, 67 of settings_page.dart).
- Replace each with `const OilLampRowDivider()`.

**Change (applied 5 times):**
```dart
// Before:
const Divider(indent: AppSpacing.pagePadding, endIndent: AppSpacing.pagePadding)
// After:
const OilLampRowDivider()
```

- [ ] **Step 1: Read settings_page.dart** to confirm exact Divider appearances and locations.

- [ ] **Step 2: Add import and replace all 5 Dividers.**

```dart
import 'package:sanatan_guide/presentation/shared/widgets/sacred_ornaments.dart';
```

- [ ] **Step 3: Analyze**

```
flutter analyze lib/presentation/features/settings/pages/settings_page.dart
```

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/settings/pages/settings_page.dart
git commit -m "feat: settings OilLampRowDivider replaces plain Divider"
```

---

## Task 9: Credits — InscriptionBorderBackdrop header

**Files:**
- Modify: `lib/presentation/features/settings/pages/credits_page.dart`

**Context:**
- `CreditsPage.build()` returns `Scaffold(appBar: AppBar(...), body: ListView(...))`.
- Add `InscriptionBorderBackdrop` as a header row at the top of the ListView children list (before `_DisclaimerBanner`).

**Change:**
In `body: ListView(children: [const _DisclaimerBanner(), ...])`, prepend:

```dart
children: [
  // Inscription border at page top
  const SizedBox(
    height: 32,
    child: InscriptionBorderBackdrop(),
  ),
  const SizedBox(height: AppSpacing.md),
  const _DisclaimerBanner(),
  // ... rest unchanged
],
```

- [ ] **Step 1: Add import and apply change to credits_page.dart.**

```dart
import 'package:sanatan_guide/presentation/shared/widgets/sacred_ornaments.dart';
```

- [ ] **Step 2: Analyze**

```
flutter analyze lib/presentation/features/settings/pages/credits_page.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/features/settings/pages/credits_page.dart
git commit -m "feat: credits page InscriptionBorderBackdrop header"
```

---

## Task 10: Scripture Library — NalandaArchBackdrop header

**Files:**
- Modify: `lib/presentation/features/scripture_reader/pages/scripture_library_page.dart`

**Context:**
- `ScriptureLibraryPage.build()` returns `Scaffold(appBar: AppBar(title: Text('Library')), body: const _LibraryBody())`.
- Add `NalandaArchBackdrop` behind the AppBar title area. Simplest approach: replace `AppBar` title with a `Stack`-based header, OR use `AppBar.flexibleSpace` to layer the backdrop behind the title.

**Recommended approach** — use `AppBar.flexibleSpace`:
```dart
appBar: AppBar(
  title: Text('Library', style: context.ts.displayMedium),
  centerTitle: false,
  flexibleSpace: const IgnorePointer(
    child: NalandaArchBackdrop(),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.bookmark_rounded),
      color: AppColors.warmGrey50,
      tooltip: 'Saved verses',
      onPressed: () => context.go(AppRoutes.bookmarks),
    ),
  ],
),
```

- [ ] **Step 1: Add import and apply `flexibleSpace` change.**

```dart
import 'package:sanatan_guide/presentation/shared/widgets/sacred_ornaments.dart';
```

- [ ] **Step 2: Analyze**

```
flutter analyze lib/presentation/features/scripture_reader/pages/scripture_library_page.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/features/scripture_reader/pages/scripture_library_page.dart
git commit -m "feat: scripture library NalandaArchBackdrop in AppBar"
```

---

## Task 11: Verse Chat — DhyanaAsanaBackdrop

**Files:**
- Modify: `lib/presentation/features/scripture_reader/pages/verse_chat_page.dart`

**Context:**
- `VerseChatPage.build()` returns `Scaffold(appBar: AppBar(...), body: state.when(...))`.
- Add `DhyanaAsanaBackdrop` behind the AppBar using `flexibleSpace`, identical pattern to Task 10.

**Change:**
```dart
appBar: AppBar(
  title: Column(...),   // unchanged
  centerTitle: false,
  flexibleSpace: const IgnorePointer(
    child: DhyanaAsanaBackdrop(),
  ),
),
```

- [ ] **Step 1: Add import and apply change.**

- [ ] **Step 2: Analyze**

```
flutter analyze lib/presentation/features/scripture_reader/pages/verse_chat_page.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/features/scripture_reader/pages/verse_chat_page.dart
git commit -m "feat: verse chat DhyanaAsanaBackdrop in AppBar"
```

---

## Task 12: Learning Path + Module Reader — Temple Staircase + Peepal

**Files:**
- Modify: `lib/presentation/features/learning_path/pages/learning_path_page.dart`
- Modify: `lib/presentation/features/learning_path/pages/module_reader_page.dart`

**Context:**
- `LearningPathPage` has `Scaffold(appBar: AppBar(title: Text('Your Path')))` — add `TempleStaircaseBackdrop` via `flexibleSpace`.
- `ModuleReaderPage` has a Scaffold body — wrap the body content in a `Stack` with `PeepalTreeBackdrop` centered behind content.

**Learning path change:**
```dart
appBar: AppBar(
  title: Text('Your Path', style: context.ts.displayMedium),
  centerTitle: false,
  flexibleSpace: const IgnorePointer(
    child: TempleStaircaseBackdrop(),
  ),
),
```

**Module reader change** — read `module_reader_page.dart` first to find the body structure, then wrap:
```dart
body: Stack(
  children: [
    // Peepal tree background
    const Positioned.fill(
      child: IgnorePointer(child: PeepalTreeBackdrop()),
    ),
    // Original body content
    _existingBodyWidget,
  ],
),
```

- [ ] **Step 1: Read `module_reader_page.dart` build method** to find the exact body structure before editing.

- [ ] **Step 2: Apply changes to both files.**

```dart
import 'package:sanatan_guide/presentation/shared/widgets/sacred_ornaments.dart';
```

- [ ] **Step 3: Analyze both files.**

```
flutter analyze lib/presentation/features/learning_path/pages/learning_path_page.dart
flutter analyze lib/presentation/features/learning_path/pages/module_reader_page.dart
```

- [ ] **Step 4: Run full test suite.**

```
flutter test
```

Expected: All tests pass.

- [ ] **Step 5: Final analyze across entire project.**

```
flutter analyze
```

Expected: Zero errors (infos/warnings acceptable if pre-existing).

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/features/learning_path/pages/learning_path_page.dart \
        lib/presentation/features/learning_path/pages/module_reader_page.dart
git commit -m "feat: learning path TempleStaircase + module reader PeepalTree backdrops"
```

---

## Self-review against spec

**Spec coverage check:**

| Spec requirement | Covered by task |
|---|---|
| Verse Detail Sanctum direction (GutterRail + SanctumCards) | Task 3 |
| SanctumCard reusable widget | Task 1 |
| GutterRail widget | Task 2 |
| Onboarding — GangaWaveBackdrop + drawn icons | Task 4 |
| Search — PeacockIllustration empty state + search icon | Task 5 |
| Bookmarks — PrasadTray + "Your offerings await" | Task 6 |
| Festivals — DiyaFlameIcon | Task 7 |
| Settings — OilLampRowDivider | Task 8 |
| Credits — InscriptionBorderBackdrop | Task 9 |
| Scripture Library — NalandaArchBackdrop | Task 10 |
| Verse Chat — DhyanaAsanaBackdrop | Task 11 |
| Learning Path — TempleStaircaseBackdrop | Task 12 |
| Module Reader — PeepalTreeBackdrop | Task 12 |
| Home screen untouched | Not in plan (correct) |
| Zero emojis in presentation layer | All tasks eliminate emoji rendering |
| All ornaments work in both brightness modes | Painters already isDark-aware from Plan A |

**Gaps / notes:**
- `_TranslationToggle` is kept in Sanctum layout at top of right column (preserved functionality).
- `AiExplanationBlock` is replaced by the inline "Ask the Guide" row in Task 3; `CommentariesBlock` is kept inline below SanctumCards.
- `VerseContentSliver` file is preserved (not deleted) — just not imported by verse_detail_page.dart anymore.
- `verse.wordMeanings` expansion state in `_SanctumContent` uses `wordMeaningsExpanded` prop passed from parent state — matches the `SanctumCard(initiallyExpanded: wordMeaningsExpanded)` pattern. The `onToggleWordMeanings` callback is passed but `SanctumCard` handles its own open/close state internally (the prop only sets the initial value). This is intentional — SanctumCard's collapse is self-contained.
