# Navigation Keystone Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task.
> Steps use checkbox (`- [ ]`) syntax for tracking. Read the roadmap
> `2026-05-17-design-completion-roadmap.md` first for the LOCKED cross-cutting
> decisions D1–D5; this plan obeys them.

**Goal:** Make Settings, Credits, Feedback, Festivals, Bookmarks, Search and the
general AI chat reachable via a Home/Library topbar (Search/Bookmark/⋯) + a 5-item
overflow menu, and scope the bottom nav to Today/Practice/Texts only — the structural
fix that answers the user's "from where do you reach these?" question.

**Architecture:** One shared `OverflowMenu` (scrim + animated popover) + one shared
topbar icon set, mounted on Home and Library. Router restructured so
`/bookmarks` `/festivals` `/settings` `/credits` leave the bottom-nav `ShellRoute`
and become root-level routes (back-button chrome), and two new routes `/feedback`
`/chat` are added (real screens land in S3/S6; S1 wires minimal dev stubs so the
menu is spec-complete and non-blocking).

**Tech Stack:** Flutter 3, Riverpod 3, GoRouter, Material 3, dual theme. Tokens from
`design_tokens.dart`, text styles from `design_typography.dart` (`AppText.*`).

---

## File map

- Create: `lib/presentation/shared/widgets/topbar_icons.dart` — search/bookmark/overflow CustomPainter glyphs
- Create: `lib/presentation/shared/widgets/overflow_menu.dart` — `showOverflowMenu()` + popover
- Create: `lib/presentation/shared/widgets/heritage_top_bar.dart` — `HomeTopBar`, `LibraryTopBarActions`
- Create: `lib/presentation/shared/pages/coming_soon_page.dart` — dev stub for `/feedback` & `/chat` (replaced in S3/S6)
- Modify: `lib/presentation/theme/design_tokens.dart` — add `Glows.overflowMenuDark` / `overflowMenuLight`
- Modify: `lib/core/router/app_routes.dart` — add `feedback`, `chatGeneral` constants
- Modify: `lib/core/router/app_router.dart` — move 4 routes out of shell, add 2 routes
- Modify: `lib/presentation/shared/widgets/scaffold_with_nav_bar.dart` — `_selectedIndex` no longer maps bookmarks/festivals
- Modify: `lib/presentation/features/home/pages/home_page.dart` — mount `HomeTopBar`
- Modify: `lib/presentation/features/scripture_reader/pages/scripture_library_page.dart` — add `LibraryTopBarActions`
- Modify: `lib/presentation/features/bookmarks/pages/bookmarks_page.dart` — add back-arrow to `_TopBar` if absent
- Create: `.claude/screen_specs/13_navigation_credits_feedback_spec.md` — canonical spec (Task 0)
- Test: `test/navigation/overflow_menu_test.dart`, `test/navigation/home_top_bar_test.dart`

Spec authority: `.claude/screen_specs/13_navigation_credits_feedback_spec.md` Part A.
Visual reference: `New Design/mockups/screen-13-navigation-credits-feedback.html`
(frames: Dark Home topbar, Overflow menu open, Light Home topbar).

---

### Task 0: Make spec 13 canonical (prerequisite, no code)

**Files:**
- Create: `.claude/screen_specs/13_navigation_credits_feedback_spec.md`

- [ ] **Step 1: Copy the spec into the canonical folder**

```bash
cp "New Design/screens/13_navigation_credits_feedback_spec.md" \
   ".claude/screen_specs/13_navigation_credits_feedback_spec.md"
```

- [ ] **Step 2: Prepend a routing-reconciliation note**

Add this block at the very top of the new file (above the existing `# Screen Spec` line),
because the spec's route names follow the brief, not the codebase (decision D1):

```markdown
> **Codebase route mapping (decision D1 — these override the routes named below):**
> Credits = `/credits` · Feedback = `/feedback` · Settings = `/settings`
> Festivals = `/festivals` · Search = `/search` · Bookmarks = `/bookmarks`
> AI chat general = `/chat`. There is no `/settings/credits` alias.
> The 5-item overflow (brief §3.6) supersedes the 3-item list in Part A.3 below.

```

- [ ] **Step 3: Commit**

```bash
git add ".claude/screen_specs/13_navigation_credits_feedback_spec.md"
git commit -m "docs(specs): adopt spec 13 (nav/credits/feedback) as canonical"
```

---

### Task 1: Add overflow-menu shadow tokens

**Files:**
- Modify: `lib/presentation/theme/design_tokens.dart` (inside `class Glows`, after `moonGlowDark`)

- [ ] **Step 1: Add the constants**

Append inside `class Glows { … }`, after the `moonGlowDark` list:

```dart
  static const List<BoxShadow> overflowMenuDark = [
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> overflowMenuLight = [
    BoxShadow(
      color: Color(0x1F2A1E14),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];
```

- [ ] **Step 2: Verify analyzer clean**

Run: `flutter analyze lib/presentation/theme/design_tokens.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/theme/design_tokens.dart
git commit -m "feat(tokens): add overflow-menu shadow (dark/light)"
```

---

### Task 2: Topbar icon glyphs (search, bookmark, overflow)

**Files:**
- Create: `lib/presentation/shared/widgets/topbar_icons.dart`
- Reference pattern: `lib/presentation/shared/widgets/scaffold_with_nav_bar.dart:135-199` (`_NavIconPainter`)
- Path data source: `New Design/mockups/screen-13-navigation-credits-feedback.html` — find the three trailing `<svg>` elements in the Home-topbar frame; copy each `<path d="...">` / primitives.

- [ ] **Step 1: Create the painter file**

Mirror the established `_NavIconPainter` approach (22-unit viewBox, `u = size/viewBox`,
round caps/joins, stroke width × `u`). Lift the exact geometry from the mockup SVGs —
do NOT invent shapes. Structure:

```dart
import 'package:flutter/material.dart';

enum TopBarGlyph { search, bookmark, overflow }

/// Stroke glyphs for the Home/Library topbar, matching the screen-13 mockup
/// SVGs (20-unit viewBox, stroke-width 1.6). Same technique as the bottom-nav
/// `_NavIconPainter`.
class TopBarIcon extends StatelessWidget {
  const TopBarIcon({
    super.key,
    required this.glyph,
    required this.color,
    this.size = 20,
  });

  final TopBarGlyph glyph;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _TopBarIconPainter(glyph, color)),
      );
}

class _TopBarIconPainter extends CustomPainter {
  const _TopBarIconPainter(this.glyph, this.color);
  final TopBarGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 20.0; // mockup viewBox is 20×20
    Offset p(double x, double y) => Offset(x * u, y * u);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * u
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (glyph) {
      case TopBarGlyph.search:
        // <circle> + handle line — copy cx/cy/r + line coords from mockup SVG
        // e.g. circle(9,9,6) + line(13.5,13.5 → 18,18)
        canvas.drawCircle(p(9, 9), 6 * u, stroke);
        canvas.drawLine(p(13.5, 13.5), p(18, 18), stroke);
      case TopBarGlyph.bookmark:
        // folded-bookmark path from mockup: M5 3 h10 v15 l-5 -4 l-5 4 z
        final path = Path()
          ..moveTo(5 * u, 3 * u)
          ..lineTo(15 * u, 3 * u)
          ..lineTo(15 * u, 18 * u)
          ..lineTo(10 * u, 14 * u)
          ..lineTo(5 * u, 18 * u)
          ..close();
        canvas.drawPath(path, stroke);
      case TopBarGlyph.overflow:
        for (final cx in const [4.0, 10.0, 16.0]) {
          canvas.drawCircle(p(cx, 10), 1.6 * u, Paint()..color = color);
        }
    }
  }

  @override
  bool shouldRepaint(_TopBarIconPainter old) =>
      old.glyph != glyph || old.color != color;
}
```

> If the mockup's path differs from the comments above, the mockup wins — adjust
> the coordinates to match it exactly. The comments are the expected shape, not a
> licence to approximate.

- [ ] **Step 2: Verify analyzer clean**

Run: `flutter analyze lib/presentation/shared/widgets/topbar_icons.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/shared/widgets/topbar_icons.dart
git commit -m "feat(nav): topbar search/bookmark/overflow glyphs"
```

---

### Task 3: Shared OverflowMenu (scrim + animated popover)

**Files:**
- Create: `lib/presentation/shared/widgets/overflow_menu.dart`
- Spec: `.claude/screen_specs/13_navigation_credits_feedback_spec.md` A.3 + roadmap §3.6 (5 items)

- [ ] **Step 1: Write the failing widget test**

`test/navigation/overflow_menu_test.dart` — uses `MaterialApp.router` from the
start because the menu rows call `context.push`, which requires a `GoRouter`
(a bare `MaterialApp` would fail at the first item tap):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/presentation/shared/widgets/overflow_menu.dart';

void main() {
  testWidgets('overflow menu lists 5 items and scrim dismisses', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (context, __) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showOverflowMenu(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      for (final p in ['/settings', '/festivals', '/chat', '/feedback',
          '/credits'])
        GoRoute(path: p, builder: (_, __) => Scaffold(body: Text('at $p'))),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Festivals & Calendar'), findsOneWidget);
    expect(find.text('Ask the Pandit'), findsOneWidget);
    expect(find.text('Send feedback'), findsOneWidget);
    expect(find.text('About this app'), findsOneWidget);

    // Tap scrim (top-left, away from the top-right popover) to dismiss.
    await tester.tapAt(const Offset(10, 400));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsNothing);
  });
}
```

- [ ] **Step 2: Run it — expect FAIL** (`showOverflowMenu` undefined)

Run: `flutter test test/navigation/overflow_menu_test.dart`
Expected: compile error / FAIL.

- [ ] **Step 3: Implement `overflow_menu.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

/// One overflow item.
class _Item {
  const _Item(this.label, this.route, this.draw);
  final String label;
  final String route;
  final void Function(Canvas, Size, Color) draw;
}

/// Shows the shared 5-item overflow menu (spec 13 A.3 + roadmap §3.6).
/// 55% black scrim, 220 px popover anchored top-right, 180 ms scale+fade.
Future<void> showOverflowMenu(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      barrierDismissible: true,
      barrierLabel: 'Dismiss menu',
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) => const _OverflowMenu(),
      transitionsBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            alignment: Alignment.topRight,
            scale: Tween(begin: 0.98, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

class _OverflowMenu extends StatelessWidget {
  const _OverflowMenu();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final bg = isDark ? DColors.surface2 : Colors.white;
    final border = isDark ? DColors.divider : LColors.divider;
    final sep = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final text1 = isDark ? DColors.text1 : LColors.text1;

    const items = <_Item>[
      _Item('Settings', '/settings', _drawGear),
      _Item('Festivals & Calendar', '/festivals', _drawCalendar),
      _Item('Ask the Pandit', '/chat', _drawOm),
      _Item('Send feedback', '/feedback', _drawPlane),
      _Item('About this app', '/credits', _drawInfo),
    ];

    return Stack(
      children: [
        // Transparent full-screen layer; barrier handles dismiss.
        const Positioned.fill(child: SizedBox.expand()),
        Positioned(
          right: 16,
          top: 80,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 220,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: border),
                boxShadow:
                    isDark ? Glows.overflowMenuDark : Glows.overflowMenuLight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < items.length; i++)
                    _Row(
                      item: items[i],
                      saffron: saffron,
                      text1: text1,
                      border: i == items.length - 1 ? null : sep,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.item,
    required this.saffron,
    required this.text1,
    required this.border,
  });
  final _Item item;
  final Color saffron;
  final Color text1;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        context.push(item.route);
      },
      child: Container(
        decoration: BoxDecoration(
          border: border == null
              ? null
              : Border(bottom: BorderSide(color: border!)),
        ),
        padding:
            const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CustomPaint(
                painter: _GlyphPainter(item.draw, saffron.withValues(alpha: 0.7)),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              item.label,
              style: AppText.rowLabel(color: text1).copyWith(
                fontFamily: Fonts.sans,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.draw, this.color);
  final void Function(Canvas, Size, Color) draw;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) => draw(canvas, size, color);
  @override
  bool shouldRepaint(_GlyphPainter old) => old.color != color;
}

// Minimal 16-unit stroke glyphs. Refine to match the mockup overflow-menu
// frame icons if they differ; geometry below is the expected shape.
Paint _s(Color c, double u) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.5 * u
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

void _drawGear(Canvas c, Size s, Color col) {
  final u = s.width / 16;
  c.drawCircle(Offset(8 * u, 8 * u), 5 * u, _s(col, u));
  c.drawCircle(Offset(8 * u, 8 * u), 2 * u, _s(col, u));
}

void _drawCalendar(Canvas c, Size s, Color col) {
  final u = s.width / 16;
  c.drawRRect(
    RRect.fromLTRBR(2 * u, 3 * u, 14 * u, 14 * u, Radius.circular(u)),
    _s(col, u),
  );
  c.drawLine(Offset(2 * u, 6 * u), Offset(14 * u, 6 * u), _s(col, u));
}

void _drawOm(Canvas c, Size s, Color col) {
  final u = s.width / 16;
  final tp = TextPainter(
    text: TextSpan(
      text: 'ॐ',
      style: TextStyle(
        fontFamily: Fonts.deva,
        fontSize: 13 * u,
        color: col,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(c, Offset((s.width - tp.width) / 2, (s.height - tp.height) / 2));
}

void _drawPlane(Canvas c, Size s, Color col) {
  final u = s.width / 16;
  final path = Path()
    ..moveTo(2 * u, 8 * u)
    ..lineTo(14 * u, 2 * u)
    ..lineTo(9 * u, 14 * u)
    ..lineTo(7 * u, 9 * u)
    ..close();
  c.drawPath(path, _s(col, u));
}

void _drawInfo(Canvas c, Size s, Color col) {
  final u = s.width / 16;
  c.drawCircle(Offset(8 * u, 8 * u), 6 * u, _s(col, u));
  c.drawLine(Offset(8 * u, 7 * u), Offset(8 * u, 11 * u), _s(col, u));
  c.drawCircle(Offset(8 * u, 4.5 * u), 0.4 * u, Paint()..color = col);
}
```

- [ ] **Step 4: Run the test — expect PASS**

Run: `flutter test test/navigation/overflow_menu_test.dart`
Expected: PASS (5 labels found; scrim tap dismisses).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/shared/widgets/overflow_menu.dart test/navigation/overflow_menu_test.dart
git commit -m "feat(nav): shared 5-item overflow menu with scrim + scale-fade"
```

---

### Task 4: Coming-soon stub for `/feedback` and `/chat`

**Files:**
- Create: `lib/presentation/shared/pages/coming_soon_page.dart`

These two destinations get real screens in S3 (Feedback) and S6 (AI-chat general).
S1 ships a minimal back-button scaffold so the menu is spec-complete and the routes
resolve. This is dev scaffolding reachable only via the brand-new menu (no regression
of existing behaviour).

- [ ] **Step 1: Implement the stub**

```dart
import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

/// TEMPORARY. Replaced by the real screen in its subsystem (S3 / S6).
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          Center(
            child: Text(
              '$title\n(coming soon)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Fonts.serif,
                fontStyle: FontStyle.italic,
                fontSize: 15,
                height: 1.5,
                color: text2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Analyzer clean**

Run: `flutter analyze lib/presentation/shared/pages/coming_soon_page.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/shared/pages/coming_soon_page.dart
git commit -m "chore(nav): temp coming-soon stub for /feedback and /chat"
```

---

### Task 5: Router restructure — routes out of shell + 2 new routes

**Files:**
- Modify: `lib/core/router/app_routes.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: any caller that does `context.go(...)` to a moved route (Step 0)

- [ ] **Step 0: Convert `go` → `push` for the four moved routes (do this FIRST)**

Once `/bookmarks` `/festivals` `/settings` `/credits` leave the ShellRoute, a
`context.go('/settings')` REPLACES the whole stack (no way back) instead of pushing
within the shell. Find every caller:

```bash
grep -rn "context\.go\|GoRouter\.of([^)]*)\.go\|\.go('" lib/ \
  | grep -E "/bookmarks|/festivals|/settings|/credits"
```

For each hit targeting one of the four moved routes, change `.go(` → `.push(` so the
destination is pushed and back returns to the opener. Settings rows that link to
`/credits` are the most likely offenders; also check the home first-day CTA and any
settings entry points. Leave `go` calls to `/home` `/learn` `/browse` (tab roots)
unchanged. Verify with `flutter analyze` after.

- [ ] **Step 1: Add route constants**

In `app_routes.dart`, add inside `class AppRoutes`:

```dart
  // Feedback (real screen lands in S3)
  static const String feedback = '/feedback';

  // General AI chat — no verse anchor (real screen lands in S6)
  static const String chatGeneral = '/chat';
```

- [ ] **Step 2: Add imports to `app_router.dart`**

After the existing `coming` imports block (top of file), add:

```dart
import 'package:sanatan_guide/presentation/shared/pages/coming_soon_page.dart';
```

- [ ] **Step 3: Move 4 routes OUT of the ShellRoute and add 2 new routes**

In `app_router.dart`, the `ShellRoute.routes` list currently has 7 children
(`/home`, `/learn`, `/festivals`, `/bookmarks`, `/browse`, `/settings`, `/credits`).
Replace so the ShellRoute keeps ONLY the three tab roots:

Replace the `ShellRoute(...)` block's `routes:` with:

```dart
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: '/learn',
            builder: (_, __) => const LearningPathPage(),
          ),
          GoRoute(
            path: AppRoutes.browse,
            builder: (_, __) => const ScriptureLibraryPage(),
          ),
        ],
```

Then, immediately AFTER the `GoRoute(path: AppRoutes.search, …)` block and BEFORE the
`ShellRoute(`, add these five root-level routes (root navigator, fade-slide-up like
`/search`):

```dart
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.bookmarks,
        pageBuilder: (_, state) =>
            _fadeSlideUpTransition(state, const BookmarksPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.festivals,
        pageBuilder: (_, state) =>
            _fadeSlideUpTransition(state, const FestivalCalendarPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings',
        pageBuilder: (_, state) =>
            _fadeSlideUpTransition(state, const SettingsPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/credits',
        pageBuilder: (_, state) =>
            _fadeSlideUpTransition(state, const CreditsPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.feedback,
        pageBuilder: (_, state) => _fadeSlideUpTransition(
          state,
          const ComingSoonPage(title: 'Send feedback'),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.chatGeneral,
        pageBuilder: (_, state) => _fadeSlideUpTransition(
          state,
          const ComingSoonPage(title: 'Ask the Pandit'),
        ),
      ),
```

(Existing `import` lines for `BookmarksPage`, `FestivalCalendarPage`, `SettingsPage`,
`CreditsPage` are already present — keep them.)

- [ ] **Step 4: Fix bottom-nav index mapping**

In `scaffold_with_nav_bar.dart`, `_selectedIndex` currently maps `/bookmarks` → tab 2.
Bookmarks/festivals are no longer in the shell, so that branch is dead. Replace
`_selectedIndex` body with:

```dart
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/learn')) return 1;
    if (location.startsWith('/browse')) return 2;
    return 0;
```

Remove the now-unused `import 'package:sanatan_guide/core/router/app_routes.dart';`
ONLY if no other reference remains in the file (check first; `_go` uses
`AppRoutes.browse` — so KEEP the import).

- [ ] **Step 5: Analyzer + full test suite**

Run: `flutter analyze`
Expected: `No issues found!`
Run: `flutter test`
Expected: all green (no test should depend on bookmarks/festivals being in-shell).

- [ ] **Step 6: Commit**

```bash
git add lib/core/router/app_routes.dart lib/core/router/app_router.dart \
  lib/presentation/shared/widgets/scaffold_with_nav_bar.dart \
  $(git diff --name-only)   # any go→push caller files from Step 0
git commit -m "feat(nav): scope bottom nav to 3 tabs; add /feedback + /chat routes"
```

---

### Task 6: HomeTopBar + LibraryTopBarActions widgets

**Files:**
- Create: `lib/presentation/shared/widgets/heritage_top_bar.dart`
- Spec: spec 13 A.1 (Home) + A.2 (Library)

- [ ] **Step 1: Implement**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/presentation/shared/widgets/overflow_menu.dart';
import 'package:sanatan_guide/presentation/shared/widgets/topbar_icons.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.glyph, required this.onTap, required this.color});
  final TopBarGlyph glyph;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: TopBarIcon(glyph: glyph, color: color)),
        ),
      );
}

/// Home topbar: सनातन brand + Search / Bookmark / ⋯  (spec 13 A.1).
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final ink = isDark ? DColors.text2 : LColors.text2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 16, 14),
      child: Row(
        children: [
          Text(
            'सनातन',
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontSize: 22,
              color: saffron,
            ),
          ),
          const Spacer(),
          _IconBtn(
            glyph: TopBarGlyph.search,
            color: ink,
            onTap: () => context.push('/search'),
          ),
          _IconBtn(
            glyph: TopBarGlyph.bookmark,
            color: ink,
            onTap: () => context.push('/bookmarks'),
          ),
          _IconBtn(
            glyph: TopBarGlyph.overflow,
            color: ink,
            onTap: () => showOverflowMenu(context),
          ),
        ],
      ),
    );
  }
}

/// Library trailing actions: Bookmark + ⋯ (search is the inline field). A.2.
class LibraryTopBarActions extends StatelessWidget {
  const LibraryTopBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? DColors.text2 : LColors.text2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconBtn(
          glyph: TopBarGlyph.bookmark,
          color: ink,
          onTap: () => context.push('/bookmarks'),
        ),
        _IconBtn(
          glyph: TopBarGlyph.overflow,
          color: ink,
          onTap: () => showOverflowMenu(context),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Widget test**

`test/navigation/home_top_bar_test.dart` — pump `HomeTopBar` inside
`MaterialApp.router` with a `GoRouter` containing no-op routes for `/search`,
`/bookmarks`, and the 5 overflow paths. Assert: brand `सनातन` renders; tapping the
overflow icon shows `Settings` text; tapping search navigates to `/search`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_top_bar.dart';

void main() {
  testWidgets('HomeTopBar shows brand + opens overflow', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const Scaffold(body: HomeTopBar())),
      for (final p in ['/search', '/bookmarks', '/settings', '/festivals',
          '/chat', '/feedback', '/credits'])
        GoRoute(path: p, builder: (_, __) => Scaffold(body: Text('at $p'))),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    expect(find.text('सनातन'), findsOneWidget);

    await tester.tap(find.byType(InkResponse).last); // overflow
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Run test — expect PASS**

Run: `flutter test test/navigation/home_top_bar_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/shared/widgets/heritage_top_bar.dart test/navigation/home_top_bar_test.dart
git commit -m "feat(nav): HomeTopBar + LibraryTopBarActions"
```

---

### Task 7: Mount HomeTopBar in HomePage

**Files:**
- Modify: `lib/presentation/features/home/pages/home_page.dart`

The page is a `Scaffold` with no app bar; brand currently lives inside
`PanchangBlock`. Mount `HomeTopBar` as a fixed strip above the scroll view, inside
`SafeArea`. The greeting/panchang stays in `PanchangBlock` (do not duplicate the
brand — `PanchangBlock` shows the greeting line, not the `सनातन` wordmark; verify
by reading `panchang_block.dart` and, if `PanchangBlock` already renders `सनातन`,
remove it there so it appears once, in the topbar).

- [ ] **Step 1: Add import**

```dart
import 'package:sanatan_guide/presentation/shared/widgets/heritage_top_bar.dart';
```

- [ ] **Step 2: Wrap body**

Replace the `child: SafeArea(bottom: false, child: SingleChildScrollView(` region so
the column is `[ HomeTopBar(), Expanded(child: SingleChildScrollView(...)) ]`:

```dart
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const HomeTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.xxl,
                    0,
                    Spacing.xxl,
                    Spacing.xxxl,
                  ),
                  child: Column(
                    children: isFirstDay
                        ? [
                            const PanchangBlock(isFirstDay: true),
                            const VerseHeroCard(isFirstDay: true),
                            const SizedBox(height: 28),
                            _FirstDayCta(isDark: isDark),
                            const SizedBox(height: 18),
                            _BrowseLibraryLink(isDark: isDark),
                          ]
                        : const [
                            PanchangBlock(),
                            VerseHeroCard(),
                            SizedBox(height: 24),
                            ContinueStrip(),
                            PathStrip(),
                            FestivalPill(),
                          ],
                  ),
                ),
              ),
            ],
          ),
        ),
```

(The `RefreshIndicator` stays the outer wrapper; only the inner `SafeArea` child
changes from a bare `SingleChildScrollView` to `Column[topbar, Expanded(scroll)]`.
Pull-to-refresh still works because the scrollable is the Expanded child.)

- [ ] **Step 3: Reconcile brand duplication (audit fix, brief §5.2 #5)**

Read `lib/presentation/features/home/widgets/panchang_block.dart`. If it renders the
`सनातन` wordmark, remove that line so the brand shows once (in `HomeTopBar`). If it
only renders the time-of-day greeting (no name — verify the brief §2.4 "no name"
fix is already satisfied here; per memory the spec-built home likely has no name),
leave it. Note the finding in the commit message.

- [ ] **Step 4: Analyzer + widget test**

Run: `flutter analyze lib/presentation/features/home/pages/home_page.dart`
Expected: `No issues found!`
Add/extend a Home widget test asserting `find.text('सनातन')` is present exactly once
and `find.byType(HomeTopBar)` findsOneWidget.

Run: `flutter test test/` (home-related tests)
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/home/pages/home_page.dart lib/presentation/features/home/widgets/panchang_block.dart test/
git commit -m "feat(home): mount HomeTopBar (brand + search/bookmark/overflow)"
```

---

### Task 8: Library trailing actions

**Files:**
- Modify: `lib/presentation/features/scripture_reader/pages/scripture_library_page.dart`

The page already has an inline `_SearchBar` (line ~95) inside a `SafeArea`/`body`.
Brief A.2: Library topbar = inline search field + Bookmark + ⋯ (no separate search
icon).

- [ ] **Step 1: Read the header region**

Read `scripture_library_page.dart:80-160` to locate the row/column that hosts
`_SearchBar`. The search field should sit in a `Row` with `Expanded(child: _SearchBar(...))`
and `LibraryTopBarActions()` trailing.

- [ ] **Step 2: Add import + wrap the search bar**

```dart
import 'package:sanatan_guide/presentation/shared/widgets/heritage_top_bar.dart';
```

Wrap the existing `_SearchBar(...)` so it becomes:

```dart
Row(
  children: [
    Expanded(child: _SearchBar(onChanged: ...)), // keep existing args verbatim
    const SizedBox(width: 4),
    const LibraryTopBarActions(),
  ],
)
```

Preserve the existing `_SearchBar` constructor arguments exactly as they are in the
file — only wrap it.

- [ ] **Step 3: Analyzer + visual/widget check**

Run: `flutter analyze lib/presentation/features/scripture_reader/pages/scripture_library_page.dart`
Expected: `No issues found!`
Widget test: pump `ScriptureLibraryPage` (with required ProviderScope overrides as
existing library tests do — copy their setup) and assert the bookmark + overflow
icons render in the header (`find.byType(LibraryTopBarActions)` findsOneWidget).

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/scripture_reader/pages/scripture_library_page.dart test/
git commit -m "feat(library): add bookmark + overflow trailing actions"
```

---

### Task 9: Bookmarks back-arrow (out-of-shell chrome)

**Files:**
- Modify: `lib/presentation/features/bookmarks/pages/bookmarks_page.dart`

Bookmarks now lives outside the bottom-nav shell. It already has a custom
`_TopBar(isDark:)`. Read `_TopBar` in this file. Per spec 07 it shows
"पोथी · Your collection" + count + a search action. It must also have a back
affordance now (previously bottom nav provided the way back).

- [ ] **Step 1: Inspect `_TopBar`**

Find the `class _TopBar` (or `_TopBar` widget) in `bookmarks_page.dart`. Determine
if it has a leading back control.

- [ ] **Step 2: Add a back chevron if absent**

If `_TopBar` has no back control, add a leading `MockupBackChevron` (existing widget
in `lib/presentation/shared/widgets/mockup_icons.dart`) wrapped in an `InkResponse`
that calls `Navigator.of(context).maybePop()`, placed before the
"पोथी · Your collection" title, matching the drill-down topbar pattern used by
Chapter List / Verse List (read one of those pages for the exact back-chevron
placement + hit target, and mirror it).

- [ ] **Step 3: Analyzer + test**

Run: `flutter analyze lib/presentation/features/bookmarks/pages/bookmarks_page.dart`
Expected: `No issues found!`
Run: `flutter test` — full suite green.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/bookmarks/pages/bookmarks_page.dart
git commit -m "fix(bookmarks): back-arrow now that screen is out of nav shell"
```

---

### Task 10: Acceptance walk + visual verification

Per memory `feedback_verify_acceptance_criteria` (walk each numbered bullet literally)
and `feedback_run_or_test_visual_changes` (analyzer-clean misses layout bugs — run/pump).

- [ ] **Step 1: Full gate**

Run: `flutter analyze`  → `No issues found!`
Run: `flutter test`     → all green

- [ ] **Step 2: Walk spec 13 §A.5 acceptance, literally**

For each bullet, confirm against running app or a widget test:
- [ ] Home topbar shows brand + 3 icons (search, bookmark, ⋯)
- [ ] Library topbar shows inline search field + 2 icons (bookmark, ⋯)
- [ ] Search icon → `/search`
- [ ] Bookmark icon → `/bookmarks`
- [ ] ⋯ opens overflow menu with backdrop scrim
- [ ] Menu items route: Settings→`/settings`, Festivals→`/festivals`,
      Ask the Pandit→`/chat`, Feedback→`/feedback`, About→`/credits`
- [ ] Tap scrim dismisses menu
- [ ] Drill-down screens (Chapter/Verse/Verse Detail/AI Chat) still have
      back-button only — NO topbar icons leaked in (visually confirm one)
- [ ] Bottom nav appears ONLY on `/home`, `/learn`, `/browse` — open
      `/settings`, `/bookmarks`, `/festivals`, `/credits` and confirm NO bottom nav

- [ ] **Step 3: Visual check, both themes**

Run the app (`flutter run`) or pump goldens: open the overflow menu in dark AND
light; verify popover bg (`surface2` / white), border, shadow, 180 ms scale-fade,
top-right anchor (right 16, top 80), and that the 5 rows + dividerSoft separators
match the screen-13 mockup "Overflow menu open" frame.

- [ ] **Step 4: Update the roadmap status line**

Edit `docs/superpowers/plans/2026-05-17-design-completion-roadmap.md`: mark S1 row
as ✅ DONE in the subsystem table.

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "test(nav): acceptance walk for navigation keystone (S1 complete)"
```

---

## Self-review notes (done at plan-write time)

- **Spec coverage:** spec 13 §A (A.1–A.5) fully mapped to Tasks 3–10; the 5-item
  overflow (roadmap §3.6) supersedes spec's 3-item A.3 — encoded in Task 0 Step 2
  note + Task 3 items list. Credits/Feedback screen bodies (spec 13 Parts B/C) are
  intentionally OUT of this plan (S2/S3) — S1 only makes them reachable.
- **Placeholder scan:** icon path data is delegated to "lift from mockup" with exact
  source file + expected shape — this is a precise instruction, not a vague TODO.
  The coming-soon stub is explicitly temporary and tracked to S3/S6.
- **Type consistency:** `showOverflowMenu(BuildContext)`, `HomeTopBar`,
  `LibraryTopBarActions`, `TopBarIcon`/`TopBarGlyph`, `ComingSoonPage(title:)`,
  `AppRoutes.feedback`/`chatGeneral` used identically across Tasks 3–10.
- **Risk:** Task 7 brand-duplication and Task 9 back-arrow are conditional on reading
  the live file first — steps say "read, then act", not "assume".
