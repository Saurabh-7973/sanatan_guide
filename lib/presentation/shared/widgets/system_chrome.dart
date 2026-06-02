// lib/presentation/shared/widgets/system_chrome.dart
//
// App-wide heritage system chrome (brief Screen 16). Replaces Material's
// default SnackBar — which the brief explicitly forbids — with a heritage
// toast: a centered pill at the bottom, saffron binding-diamond + Lora
// message + optional UNDO action, sliding up over 240ms and auto-dismissing
// after 3.5s. A new toast cancels the previous one (no queue).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

/// Shows a heritage toast at the bottom of the screen. Pass [actionLabel] +
/// [onAction] for an UNDO-style affordance (e.g. after removing a bookmark).
void showHeritageToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  // New toast cancels the old one — no queue.
  _ToastHost._dismissCurrent();

  final isDark = Theme.of(context).brightness == Brightness.dark;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _HeritageToast(
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      isDark: isDark,
      onClosed: () {
        if (_ToastHost._current == entry) {
          entry.remove();
          _ToastHost._current = null;
        }
      },
    ),
  );
  _ToastHost._current = entry;
  overlay.insert(entry);
}

abstract final class _ToastHost {
  static OverlayEntry? _current;

  static void _dismissCurrent() {
    _current?.remove();
    _current = null;
  }
}

class _HeritageToast extends StatefulWidget {
  const _HeritageToast({
    required this.message,
    required this.isDark,
    required this.onClosed,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final bool isDark;
  final VoidCallback onClosed;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<_HeritageToast> createState() => _HeritageToastState();
}

class _HeritageToastState extends State<_HeritageToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _holdTimer = Timer(const Duration(milliseconds: 3500), _close);
  }

  Future<void> _close() async {
    _holdTimer?.cancel();
    if (!mounted) return;
    await _c.reverse();
    widget.onClosed();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final surface2 = isDark ? DColors.surface2 : LColors.surface2;
    final divider = isDark ? DColors.divider : LColors.divider;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    final curve = CurvedAnimation(
      parent: _c,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomInset + 60,
      child: IgnorePointer(
        ignoring: widget.onAction == null,
        child: FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.4),
              end: Offset.zero,
            ).animate(curve),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: surface2,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.rotate(
                        angle: 0.785398,
                        child: Container(width: 5, height: 5, color: saffron),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            fontFamily: Fonts.serif,
                            fontFamilyFallback: AppFontFallback.latin,
                            fontSize: 13.5,
                            height: 1.3,
                            color: text1,
                          ),
                        ),
                      ),
                      if (widget.actionLabel != null) ...[
                        const SizedBox(width: 12),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.onAction?.call();
                            _close();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: dividerSoft),
                              ),
                            ),
                            child: Text(
                              widget.actionLabel!.toUpperCase(),
                              style: TextStyle(
                                fontFamily: Fonts.sans,
                                fontFamilyFallback: AppFontFallback.latin,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.04 * 12,
                                color: saffron,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Centered heritage confirmation dialog (brief Screen 16). A 312px card with
/// the [BindingLine] motif at the top, a serif title + italic body, and two
/// equal-width flat text buttons split by a hairline. The destructive label
/// renders in iron-red; non-destructive in saffron. Fades + scales in 200ms
/// over a 55% scrim. Returns `true` on confirm, `false`/`null` on dismiss.
Future<bool?> showHeritageConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool isDangerous = false,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) => _HeritageDialog(
      title: title,
      body: body,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDangerous: isDangerous,
      isDark: isDark,
    ),
    transitionBuilder: (_, anim, __, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _HeritageDialog extends StatelessWidget {
  const _HeritageDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDangerous,
    required this.isDark,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDangerous;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surface2 = isDark ? DColors.surface2 : LColors.surface2;
    final divider = isDark ? DColors.divider : LColors.divider;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final iron = isDark ? DColors.ironRedBright : LColors.ironRedBright;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final accent = isDangerous ? iron : saffron;

    return Center(
      child: Material(
        color: surface2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: divider),
        ),
        child: SizedBox(
          width: 312,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: BindingLine(isDark: isDark, sideGap: 10),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.01 * 19,
                    color: cream,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
                child: Text(
                  body,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    height: 1.55,
                    color: text2,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: dividerSoft)),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _DialogButton(
                          label: cancelLabel,
                          color: text2,
                          weight: FontWeight.w500,
                          onTap: () => Navigator.of(context).pop(false),
                        ),
                      ),
                      Container(width: 1, color: dividerSoft),
                      Expanded(
                        child: _DialogButton(
                          label: confirmLabel,
                          color: accent,
                          weight: FontWeight.w600,
                          onTap: () => Navigator.of(context).pop(true),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.color,
    required this.weight,
    required this.onTap,
  });

  final String label;
  final Color color;
  final FontWeight weight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontFamilyFallback: AppFontFallback.latin,
              fontSize: 13,
              fontWeight: weight,
              letterSpacing: 0.04 * 13,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
