import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sanatan_guide/core/services/connectivity_provider.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

/// Top-of-page banner shown only when there is no network. Heritage tone
/// (iron-red dot, text-1 label, divider hairline) so it reads as a calm
/// notice rather than a Material SnackBar. Use on any screen that talks to
/// Gemini (Pandit chat, verse-detail explain, word-gloss) so the user knows
/// the failure is connectivity, not the app.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider).value;
    // Hide while we don't have a definitive reading (first frame).
    if (online == null || online) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iron = isDark ? DColors.ironRedBright : LColors.ironRedBright;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final divider = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final fill = iron.withValues(alpha: isDark ? 0.10 : 0.06);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: fill,
        border: Border(bottom: BorderSide(color: divider, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: iron, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You’re offline — saved verses still readable.',
              style: TextStyle(
                fontFamily: Fonts.serif,
                fontFamilyFallback: AppFontFallback.latin,
                fontStyle: FontStyle.italic,
                fontSize: 12.5,
                height: 1.3,
                color: text1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
