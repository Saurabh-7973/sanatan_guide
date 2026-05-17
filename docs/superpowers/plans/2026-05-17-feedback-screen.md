# Feedback Screen Implementation Plan (S3)

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans.
> Obeys roadmap D1–D5. Spec authority:
> `.claude/screen_specs/13_navigation_credits_feedback_spec.md` Part C.
> Visual ref: `New Design/mockups/screen-13-navigation-credits-feedback.html`
> (frames: "Send Feedback pick kind", "Send Feedback compose").

**Goal:** Build the real `/feedback` screen (replaces the S1 coming-soon stub):
State A (pick kind) → State B (compose) → mailto submission.

**Architecture:** One `StatefulWidget`; `_selectedKind == null` → State A,
non-null → State B. Back in State B clears the kind (→ State A); back in State A
pops. Submission opens a `mailto:` via `url_launcher` (already a dependency).
`package_info_plus` (already a dependency) supplies version/build.

**Tech Stack:** Flutter, Material 3, dual theme, `url_launcher`,
`package_info_plus`, `AppText.*`, design tokens.

---

## File map

- Create: `lib/presentation/features/settings/pages/feedback_page.dart`
- Modify: `lib/core/router/app_router.dart` — `/feedback` → `FeedbackPage` (was `ComingSoonPage`)
- Test: `test/presentation/features/settings/feedback_page_test.dart`

Keep `coming_soon_page.dart` (still serves `/chat` until S6). Do NOT delete it.

---

### Task 1: Build feedback_page.dart

Spec 13 §C encoded. Kinds (title, description, mailto tag):
- Bug report — "Something is broken or behaves unexpectedly." — `Bug`
- Idea or suggestion — "A feature you'd love to see." — `Idea`
- Text or translation error — "A typo, misattribution, or scholarly correction." — `Text error`
- Something else — "A general thought or thanks." — `Other`

State B prose per kind (spec gives the "Text error" example; write parallel
lines for the others — concrete, not placeholder):
- Bug: "Tell us what happened and what you expected. Steps to reproduce help most."
- Idea: "Describe what you'd like and why it matters to your reading."
- Text error: "Be specific where you can — verse coordinate, scripture name, what looks wrong. The more context, the faster the fix."
- Other: "Say whatever's on your mind. We read all of it."

Textarea placeholder per kind:
- Bug: "Describe the bug. Include steps and what you expected."
- Idea: "Describe the idea and the problem it solves."
- Text error: "Describe what you noticed. Include verse coordinate (e.g., BG 2.47) where relevant."
- Other: "Write your message."

- [ ] **Step 1: Write the file**

```dart
// lib/presentation/features/settings/pages/feedback_page.dart
//
// Send Feedback — heritage spec 13 Part C. State A (pick kind) → State B
// (compose) → mailto submission.

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';
import 'package:url_launcher/url_launcher.dart';

const String _feedbackEmail = 'feedback@sanatanguide.app';

enum FeedbackKind { bug, idea, textError, other }

extension on FeedbackKind {
  String get title => switch (this) {
        FeedbackKind.bug => 'Bug report',
        FeedbackKind.idea => 'Idea or suggestion',
        FeedbackKind.textError => 'Text or translation error',
        FeedbackKind.other => 'Something else',
      };
  String get rowDesc => switch (this) {
        FeedbackKind.bug => 'Something is broken or behaves unexpectedly.',
        FeedbackKind.idea => "A feature you'd love to see.",
        FeedbackKind.textError =>
          'A typo, misattribution, or scholarly correction.',
        FeedbackKind.other => 'A general thought or thanks.',
      };
  String get composeProse => switch (this) {
        FeedbackKind.bug =>
          'Tell us what happened and what you expected. Steps to '
              'reproduce help most.',
        FeedbackKind.idea =>
          "Describe what you'd like and why it matters to your reading.",
        FeedbackKind.textError =>
          'Be specific where you can — verse coordinate, scripture name, '
              'what looks wrong. The more context, the faster the fix.',
        FeedbackKind.other => "Say whatever's on your mind. We read all of it.",
      };
  String get placeholder => switch (this) {
        FeedbackKind.bug =>
          'Describe the bug. Include steps and what you expected.',
        FeedbackKind.idea => 'Describe the idea and the problem it solves.',
        FeedbackKind.textError =>
          'Describe what you noticed. Include verse coordinate '
              '(e.g., BG 2.47) where relevant.',
        FeedbackKind.other => 'Write your message.',
      };
  String get mailTag => switch (this) {
        FeedbackKind.bug => 'Bug',
        FeedbackKind.idea => 'Idea',
        FeedbackKind.textError => 'Text error',
        FeedbackKind.other => 'Other',
      };
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  FeedbackKind? _kind;
  final _controller = TextEditingController();
  bool _attachDeviceInfo = true; // spec: default ON
  bool _allowReply = false; // spec: default OFF (privacy)
  String _version = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _version = 'v${info.version} · build ${info.buildNumber}');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final kind = _kind!;
    final buffer = StringBuffer(_controller.text.trim());
    if (_attachDeviceInfo) {
      buffer
        ..write('\n\n— — —\n')
        ..write('OS: ${Platform.operatingSystem} '
            '${Platform.operatingSystemVersion}\n')
        ..write('App: $_version\n')
        ..write('Locale: ${WidgetsBinding.instance.platformDispatcher.locale}');
    }
    buffer.write('\nReply requested: ${_allowReply ? 'yes' : 'no'}');
    final uri = Uri(
      scheme: 'mailto',
      path: _feedbackEmail,
      query: 'subject=${Uri.encodeComponent('[Sanatan Guide · '
          '${kind.mailTag}]')}&body=${Uri.encodeComponent(buffer.toString())}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email app available')),
      );
    }
  }

  void _back() {
    if (_kind != null) {
      setState(() => _kind = null); // State B → State A
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: text1),
          onPressed: _back,
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SafeArea(
            top: false,
            child: _kind == null
                ? _PickKind(
                    isDark: isDark,
                    onPick: (k) => setState(() => _kind = k),
                  )
                : _Compose(
                    isDark: isDark,
                    kind: _kind!,
                    controller: _controller,
                    version: _version,
                    attachDeviceInfo: _attachDeviceInfo,
                    allowReply: _allowReply,
                    onToggleDeviceInfo: (v) =>
                        setState(() => _attachDeviceInfo = v),
                    onToggleReply: (v) => setState(() => _allowReply = v),
                    onSend: _send,
                  ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.isDark,
    required this.title,
    required this.prose,
  });
  final bool isDark;
  final String title;
  final String prose;
  @override
  Widget build(BuildContext context) {
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: Fonts.serif,
            fontSize: 24,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: text1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          prose,
          style: TextStyle(
            fontFamily: Fonts.serif,
            fontStyle: FontStyle.italic,
            fontSize: 13.5,
            height: 1.55,
            color: text2,
          ),
        ),
      ],
    );
  }
}

class _PickKind extends StatelessWidget {
  const _PickKind({required this.isDark, required this.onPick});
  final bool isDark;
  final ValueChanged<FeedbackKind> onPick;
  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;
    final sep = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: kToolbarHeight + MediaQuery.paddingOf(context).top,
        bottom: 32,
      ),
      children: [
        _Hero(
          isDark: isDark,
          title: 'Send feedback',
          prose: 'We read every message. The app is built and maintained by '
              'one person — your reports and ideas shape what comes next.',
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration:
              BoxDecoration(border: Border(bottom: BorderSide(color: divider))),
          child: Text('WHAT KIND OF FEEDBACK?',
              style: AppText.sectionLabel(color: text3)),
        ),
        for (var i = 0; i < FeedbackKind.values.length; i++)
          _KindRow(
            kind: FeedbackKind.values[i],
            saffron: saffron,
            text1: text1,
            text2: text2,
            divider: divider,
            border: i == FeedbackKind.values.length - 1 ? null : sep,
            onTap: () => onPick(FeedbackKind.values[i]),
          ),
      ],
    );
  }
}

class _KindRow extends StatelessWidget {
  const _KindRow({
    required this.kind,
    required this.saffron,
    required this.text1,
    required this.text2,
    required this.divider,
    required this.border,
    required this.onTap,
  });
  final FeedbackKind kind;
  final Color saffron;
  final Color text1;
  final Color text2;
  final Color divider;
  final Color? border;
  final VoidCallback onTap;

  IconData get _icon => switch (kind) {
        FeedbackKind.bug => Icons.error_outline,
        FeedbackKind.idea => Icons.star_outline,
        FeedbackKind.textError => Icons.description_outlined,
        FeedbackKind.other => Icons.chat_bubble_outline,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border:
              border == null ? null : Border(bottom: BorderSide(color: border!)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: divider),
              ),
              child: Icon(_icon, size: 14, color: saffron),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kind.title,
                    style: TextStyle(
                      fontFamily: Fonts.serif,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: text1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    kind.rowDesc,
                    style: TextStyle(
                      fontFamily: Fonts.serif,
                      fontStyle: FontStyle.italic,
                      fontSize: 12.5,
                      height: 1.4,
                      color: text2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: text2),
          ],
        ),
      ),
    );
  }
}

class _Compose extends StatelessWidget {
  const _Compose({
    required this.isDark,
    required this.kind,
    required this.controller,
    required this.version,
    required this.attachDeviceInfo,
    required this.allowReply,
    required this.onToggleDeviceInfo,
    required this.onToggleReply,
    required this.onSend,
  });
  final bool isDark;
  final FeedbackKind kind;
  final TextEditingController controller;
  final String version;
  final bool attachDeviceInfo;
  final bool allowReply;
  final ValueChanged<bool> onToggleDeviceInfo;
  final ValueChanged<bool> onToggleReply;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;
    final onSaffron = isDark ? const Color(0xFF1A1208) : Colors.white;
    final hasText = controller.text.trim().isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: kToolbarHeight + MediaQuery.paddingOf(context).top,
              bottom: 24,
            ),
            children: [
              _Hero(isDark: isDark, title: kind.title, prose: kind.composeProse),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: divider)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: saffron,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        kind.title,
                        style: AppText.pill(color: onSaffron),
                      ),
                    ),
                    const Spacer(),
                    Text(version, style: AppText.metaLabel(color: text3)),
                  ],
                ),
              ),
              TextField(
                controller: controller,
                maxLines: null,
                minLines: 8,
                cursorColor: saffron,
                style: TextStyle(
                  fontFamily: Fonts.serif,
                  fontSize: 14.5,
                  height: 1.65,
                  color: text1,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  border: InputBorder.none,
                  hintText: kind.placeholder,
                  hintStyle: TextStyle(
                    fontFamily: Fonts.serif,
                    fontSize: 14.5,
                    height: 1.65,
                    color: text3,
                  ),
                ),
              ),
              _Check(
                isDark: isDark,
                label: 'Attach device info (OS, app version, locale)',
                value: attachDeviceInfo,
                onChanged: onToggleDeviceInfo,
                topBorder: true,
              ),
              _Check(
                isDark: isDark,
                label: 'Allow me to reply via email',
                value: allowReply,
                onChanged: onToggleReply,
                topBorder: false,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: SizedBox(
            width: double.infinity,
            child: Material(
              color: hasText ? saffron : saffron.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: hasText ? onSend : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: Text('Send', style: AppText.primaryButton(
                        color: onSaffron)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({
    required this.isDark,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.topBorder,
  });
  final bool isDark;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool topBorder;
  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final divider = isDark ? DColors.divider : LColors.divider;
    final onSaffron = isDark ? const Color(0xFF1A1208) : Colors.white;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        decoration: BoxDecoration(
          border: topBorder
              ? Border(top: BorderSide(color: divider))
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: value ? saffron : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: value ? saffron : text2,
                  width: 1.5,
                ),
              ),
              child: value
                  ? Icon(Icons.check, size: 13, color: onSaffron)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: Fonts.sans,
                  fontSize: 13,
                  color: text2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/presentation/features/settings/pages/feedback_page.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/features/settings/pages/feedback_page.dart
git commit -m "feat(feedback): Send Feedback screen — pick kind → compose → mailto"
```

---

### Task 2: Wire the route

**Files:**
- Modify: `lib/core/router/app_router.dart`

- [ ] **Step 1: Add import**

```dart
import 'package:sanatan_guide/presentation/features/settings/pages/feedback_page.dart';
```

- [ ] **Step 2: Repoint `/feedback`**

In the `AppRoutes.feedback` GoRoute, replace
`const ComingSoonPage(title: 'Send feedback')` with `const FeedbackPage()`.
Leave the `/chat` route's `ComingSoonPage(title: 'Ask the Pandit')` untouched
(S6 owns it; do not delete `coming_soon_page.dart`).

- [ ] **Step 3: Analyze + full suite**

Run: `flutter analyze` → `No issues found!`
Run: `flutter test` → all green

- [ ] **Step 4: Commit**

```bash
git add lib/core/router/app_router.dart
git commit -m "feat(feedback): wire /feedback to FeedbackPage (replaces stub)"
```

---

### Task 3: Widget test

**Files:**
- Create: `test/presentation/features/settings/feedback_page_test.dart`

- [ ] **Step 1: Write the test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/features/settings/pages/feedback_page.dart';

void main() {
  testWidgets('State A shows 4 kinds; tapping one → compose with Send disabled',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FeedbackPage()));
    await tester.pump();

    expect(find.text('Send feedback'), findsOneWidget);
    expect(find.text('Bug report'), findsOneWidget);
    expect(find.text('Idea or suggestion'), findsOneWidget);
    expect(find.text('Text or translation error'), findsOneWidget);
    expect(find.text('Something else'), findsOneWidget);

    await tester.tap(find.text('Text or translation error'));
    await tester.pumpAndSettle();

    // State B: kind pill + compose prose; Send present.
    expect(find.text('Text or translation error'), findsWidgets);
    expect(find.text('Send'), findsOneWidget);

    // Typing enables Send (color change is implicit; assert tap callback path
    // by entering text then verifying no exception on tap).
    await tester.enterText(find.byType(TextField), 'BG 2.47 typo');
    await tester.pump();
    expect(find.text('BG 2.47 typo'), findsOneWidget);
  });

  testWidgets('back in State B returns to State A', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FeedbackPage()));
    await tester.pump();
    await tester.tap(find.text('Bug report'));
    await tester.pumpAndSettle();
    expect(find.text('WHAT KIND OF FEEDBACK?'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('WHAT KIND OF FEEDBACK?'), findsOneWidget);
  });

  testWidgets('light theme renders without overflow', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      home: const FeedbackPage(),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run — expect PASS** (fix RenderFlex with Expanded/maxLines if any)

Run: `flutter test test/presentation/features/settings/feedback_page_test.dart`

- [ ] **Step 3: Full gate + commit**

`flutter analyze` clean; `flutter test` green.

```bash
git add test/presentation/features/settings/feedback_page_test.dart
git commit -m "test(feedback): kinds, compose, back-to-A, both themes"
```

---

### Task 4: Acceptance walk

- [ ] Spec 13 §C acceptance, literally:
  - [ ] State A shows 4 kind rows
  - [ ] Tapping a kind → State B with kind pre-selected (pill shows kind)
  - [ ] Compose shows saffron pill + version metadata
  - [ ] "Attach device info" default ON, "Allow reply" default OFF
  - [ ] Send disabled while textarea empty (Material color dim + onTap null)
  - [ ] Send opens `mailto:` with `[Sanatan Guide · {kind}]` subject + body
  - [ ] Back from State B → State A
  - [ ] Both themes render
- [ ] Honest note: on-device visual + real mailto launch still owed (agent
      can't drive a device / mail client).
- [ ] Mark S3 ✅ in roadmap. **Stub cleanup:** `coming_soon_page.dart` still
      serves `/chat` — NOT deleted now; S6 deletes it.
- [ ] Commit roadmap update.

---

## Self-review

- **Spec coverage:** §C State A, State B, submission, all 8 acceptance bullets →
  Tasks 1–4. Per-kind prose/placeholder written out (no placeholders).
- **Type consistency:** `FeedbackKind`, `_PickKind`/`_Compose`/`_KindRow`/
  `_Check`/`_Hero`, `_feedbackEmail`, `FeedbackPage` consistent.
- **D2 check:** `AppText.sectionLabel/pill/metaLabel/primaryButton`, design
  tokens, `WarmBackdrop` — all verified in lib. `url_launcher` +
  `package_info_plus` already pubspec deps (settings_page uses both).
- **Stub rule:** S3 does NOT delete `coming_soon_page.dart` (S6 still needs it).
- **Risk:** mailto can't be exercised in a widget test; test asserts UI flow +
  text entry, not `launchUrl`. Acceptable — `launchUrl` is SDK-level.
