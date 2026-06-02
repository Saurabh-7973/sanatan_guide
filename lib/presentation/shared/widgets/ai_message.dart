// lib/presentation/shared/widgets/ai_message.dart
//
// AI-response presentation + Play AI-policy compliance furniture, shared by
// all three AI surfaces (Ask the Pandit, verse-anchored chat, Explain card):
//   * a visible "AI-generated" label on every response,
//   * a Report action on every response (flag mechanism Play requires),
//   * the standard AI-limitations disclaimer ([AiDisclaimer]).

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'package:sanatan_guide/core/services/analytics_service.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';
import 'package:sanatan_guide/presentation/shared/widgets/ai_rich_prose.dart';
import 'package:sanatan_guide/presentation/shared/widgets/system_chrome.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

/// Exact disclaimer string required by the audit. Keep verbatim.
const String kAiDisclaimer =
    'AI responses may contain errors. Always refer to traditional commentaries.';

/// Records a user's report of an AI response. Routes to Crashlytics (a
/// non-fatal record so flagged content surfaces in Firebase), an analytics
/// event, and the local log — then always confirms to the user with a toast,
/// so the mechanism never appears to do nothing even when collection is
/// opted out or disabled in debug.
Future<void> reportAiContent(
  BuildContext context, {
  required String text,
  required String surface,
}) async {
  final excerpt = text.length > 500 ? '${text.substring(0, 500)}…' : text;
  try {
    await FirebaseCrashlytics.instance.recordError(
      'AI content reported by user',
      StackTrace.current,
      reason: 'ai_content_report[$surface]',
      information: [excerpt],
      fatal: false,
    );
  } catch (_) {
    // Crashlytics may be disabled (debug / opt-out) — fall through.
  }
  AnalyticsService.aiContentReported(surface: surface);
  AppLogger.instance.w('AI content reported ($surface): $excerpt');
  if (context.mounted) {
    showHeritageToast(context, 'Thank you — reported for review.');
  }
}

/// An AI response with its compliance footer: the rendered prose, an
/// "AI-generated" label, and a Report action. Use everywhere an AI reply
/// is shown.
class AiMessage extends StatelessWidget {
  const AiMessage({
    super.key,
    required this.isDark,
    required this.text,
    required this.surface,
    this.italic = true,
    this.fontSize = 14.5,
    this.height = 1.75,
    this.horizontalPadding = 4,
    this.color,
  });

  final bool isDark;
  final String text;

  /// Which AI surface this is, for report attribution: 'pandit',
  /// 'verse_chat', or 'explain'.
  final String surface;

  final bool italic;
  final double fontSize;
  final double height;
  final double horizontalPadding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiRichProse(
          isDark: isDark,
          text: text,
          italic: italic,
          fontSize: fontSize,
          height: height,
          horizontalPadding: horizontalPadding,
          color: color,
        ),
        const SizedBox(height: 6),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: _Footer(isDark: isDark, text: text, surface: surface),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.isDark,
    required this.text,
    required this.surface,
  });

  final bool isDark;
  final String text;
  final String surface;

  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final saffron = isDark ? DColors.saffron : LColors.saffron;

    return Row(
      children: [
        Icon(Icons.auto_awesome_outlined, size: 12, color: text3),
        const SizedBox(width: 5),
        Text(
          'AI-generated',
          style: TextStyle(
            fontFamily: Fonts.sans,
            fontFamilyFallback: AppFontFallback.latin,
            fontSize: 11,
            height: 1,
            letterSpacing: 0.2,
            color: text3,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () =>
              reportAiContent(context, text: text, surface: surface),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Row(
              children: [
                Icon(Icons.outlined_flag, size: 12, color: saffron),
                const SizedBox(width: 4),
                Text(
                  'Report',
                  style: TextStyle(
                    fontFamily: Fonts.sans,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontSize: 11,
                    height: 1,
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w500,
                    color: saffron,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The standard AI-limitations disclaimer line. Shown once per AI surface
/// (near the input on chat screens; below the Explain card).
class AiDisclaimer extends StatelessWidget {
  const AiDisclaimer({super.key, required this.isDark, this.padding});

  final bool isDark;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Text(
        kAiDisclaimer,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: Fonts.sans,
          fontFamilyFallback: AppFontFallback.latin,
          fontSize: 11,
          height: 1.4,
          letterSpacing: 0.1,
          color: text3,
        ),
      ),
    );
  }
}
