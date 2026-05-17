// lib/presentation/features/settings/pages/feedback_page.dart
//
// Send Feedback — heritage spec 13 Part C. Fixed back-bar (no overlay), exact
// mockup kind glyphs, transparent borderless textarea, uppercase Send with
// paper-plane. State A (pick kind) → State B (compose) → mailto.

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sanatan_guide/presentation/shared/widgets/mockup_icons.dart';
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
  bool _attachDeviceInfo = true;
  bool _allowReply = false;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(
            () => _version = 'v${info.version} · build ${info.buildNumber}');
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
        ..write(
            'Locale: ${WidgetsBinding.instance.platformDispatcher.locale}');
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
      setState(() => _kind = null);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                  child: Row(
                    children: [
                      InkResponse(
                        onTap: _back,
                        radius: 22,
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Center(child: MockupBackChevron()),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Expanded(
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
                          onToggleReply: (v) =>
                              setState(() => _allowReply = v),
                          onSend: _send,
                        ),
                ),
              ],
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
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;
    final sep = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        _Hero(
          isDark: isDark,
          title: 'Send feedback',
          prose: 'We read every message. The app is built and maintained by '
              'one person — your reports and ideas shape what comes next.',
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: divider))),
          child: Text('WHAT KIND OF FEEDBACK?',
              style: AppText.sectionLabel(color: text3)),
        ),
        for (var i = 0; i < FeedbackKind.values.length; i++)
          _KindRow(
            kind: FeedbackKind.values[i],
            isDark: isDark,
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
    required this.isDark,
    required this.border,
    required this.onTap,
  });
  final FeedbackKind kind;
  final bool isDark;
  final Color? border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: border == null
              ? null
              : Border(bottom: BorderSide(color: border!)),
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
              child: Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CustomPaint(
                    painter: _KindGlyphPainter(kind: kind, color: saffron),
                  ),
                ),
              ),
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
            const SizedBox(width: 10),
            Opacity(
              opacity: 0.4,
              child: SizedBox(
                width: 10,
                height: 14,
                child: CustomPaint(painter: _ChevronPainter(color: text3)),
              ),
            ),
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
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              _Hero(
                  isDark: isDark, title: kind.title, prose: kind.composeProse),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CustomPaint(
                              painter: _PillDocPainter(color: onSaffron),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            // Mockup pill uses the concise label ("Text
                            // error"), not the long row title.
                            kind.mailTag,
                            style: TextStyle(
                              fontFamily: Fonts.sans,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.66,
                              color: onSaffron,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        version.toUpperCase(),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.metaLabel(color: text3),
                      ),
                    ),
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
                  // Kill the global inputDecorationTheme box leak — the mockup
                  // textarea is transparent + borderless.
                  isCollapsed: true,
                  filled: false,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
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
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Opacity(
            opacity: hasText ? 1 : 0.4,
            child: Material(
              color: saffron,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: hasText ? onSend : null,
                child: SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SEND',
                        style: TextStyle(
                          fontFamily: Fonts.sans,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.82,
                          color: onSaffron,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 13,
                        height: 13,
                        child: CustomPaint(
                          painter: _SendPlanePainter(color: onSaffron),
                        ),
                      ),
                    ],
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
          border:
              topBorder ? Border(top: BorderSide(color: divider)) : null,
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
              child:
                  value ? Icon(Icons.check, size: 13, color: onSaffron) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: Fonts.sans,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
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

// ── Exact mockup glyph painters ───────────────────────────────────────────

Paint _stroke(Color c, double u, [double w = 1.4]) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w * u
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

class _KindGlyphPainter extends CustomPainter {
  const _KindGlyphPainter({required this.kind, required this.color});
  final FeedbackKind kind;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 14.0; // mockup kind svg viewBox 14
    Offset p(double x, double y) => Offset(x * u, y * u);
    final s = _stroke(color, u);
    switch (kind) {
      case FeedbackKind.bug:
        // circle r5.5 + M7 4.5v3 M7 9.5v0.5
        canvas.drawCircle(p(7, 7), 5.5 * u, s);
        canvas.drawLine(p(7, 4.5), p(7, 7.5), s);
        canvas.drawLine(p(7, 9.5), p(7, 10), s);
      case FeedbackKind.idea:
        // star
        final pts = [
          [7.0, 1.5],
          [8.7, 5.0],
          [12.5, 5.5],
          [9.7, 8.2],
          [10.4, 12.0],
          [7.0, 10.2],
          [3.6, 12.0],
          [4.3, 8.2],
          [1.5, 5.5],
          [5.3, 5.0],
        ];
        final path = Path()..moveTo(pts[0][0] * u, pts[0][1] * u);
        for (final pt in pts.skip(1)) {
          path.lineTo(pt[0] * u, pt[1] * u);
        }
        path.close();
        canvas.drawPath(path, s);
      case FeedbackKind.textError:
        // doc rect + 2 lines
        canvas.drawPath(
          Path()
            ..moveTo(2 * u, 3.5 * u)
            ..lineTo(12 * u, 3.5 * u)
            ..lineTo(12 * u, 10.5 * u)
            ..lineTo(2 * u, 10.5 * u)
            ..close(),
          s,
        );
        canvas.drawLine(p(4.5, 6), p(9.5, 6), s);
        canvas.drawLine(p(4.5, 8), p(7.5, 8), s);
      case FeedbackKind.other:
        // speech blob + dash
        canvas.drawPath(
          Path()
            ..moveTo(3 * u, 7 * u)
            ..cubicTo(3 * u, 9 * u, 5 * u, 11 * u, 7 * u, 11 * u)
            ..cubicTo(9 * u, 11 * u, 11 * u, 9 * u, 11 * u, 7 * u)
            ..cubicTo(11 * u, 5 * u, 9 * u, 3 * u, 7 * u, 3 * u)
            ..cubicTo(5 * u, 3 * u, 3 * u, 5 * u, 3 * u, 7 * u)
            ..close(),
          s,
        );
        canvas.drawLine(p(5.5, 7), p(8.5, 7), s);
    }
  }

  @override
  bool shouldRepaint(_KindGlyphPainter o) =>
      o.kind != kind || o.color != color;
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final ux = size.width / 10.0;
    final uy = size.height / 14.0;
    canvas.drawPath(
      Path()
        ..moveTo(2 * ux, 1 * uy)
        ..lineTo(8 * ux, 7 * uy)
        ..lineTo(2 * ux, 13 * uy),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * ux
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter o) => o.color != color;
}

class _PillDocPainter extends CustomPainter {
  const _PillDocPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 10.0; // mockup pill icon viewBox 10
    final s = _stroke(color, u, 1.3);
    canvas.drawPath(
      Path()
        ..moveTo(2 * u, 2.5 * u)
        ..lineTo(8 * u, 2.5 * u)
        ..lineTo(8 * u, 7.5 * u)
        ..lineTo(2 * u, 7.5 * u)
        ..close(),
      s,
    );
    // Two text lines inside the doc: M3.5 4.5h3 M3.5 6h2
    canvas.drawLine(Offset(3.5 * u, 4.5 * u), Offset(6.5 * u, 4.5 * u), s);
    canvas.drawLine(Offset(3.5 * u, 6 * u), Offset(5.5 * u, 6 * u), s);
  }

  @override
  bool shouldRepaint(_PillDocPainter o) => o.color != color;
}

class _SendPlanePainter extends CustomPainter {
  const _SendPlanePainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 13.0; // mockup send svg viewBox 13
    canvas.drawPath(
      Path()
        ..moveTo(2 * u, 6.5 * u)
        ..lineTo(11 * u, 2 * u)
        ..lineTo(8.5 * u, 13 * u)
        ..lineTo(5.5 * u, 8 * u)
        ..lineTo(2 * u, 6.5 * u)
        ..close(),
      _stroke(color, u, 1.5),
    );
  }

  @override
  bool shouldRepaint(_SendPlanePainter o) => o.color != color;
}
