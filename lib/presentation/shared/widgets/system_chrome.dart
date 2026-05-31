// lib/presentation/shared/widgets/system_chrome.dart
//
// App-wide heritage system chrome (brief Screen 16). Replaces Material's
// default SnackBar — which the brief explicitly forbids — with a heritage
// toast: a centered pill at the bottom, saffron binding-diamond + Lora
// message + optional UNDO action, sliding up over 240ms and auto-dismissing
// after 3.5s. A new toast cancels the previous one (no queue).

import 'dart:async';

import 'package:flutter/material.dart';
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
