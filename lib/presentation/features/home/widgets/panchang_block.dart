import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sanatan_guide/domain/entities/script_style.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/script_style_provider.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';
import 'package:sanatan_guide/core/utils/panchang_utils.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

/// Top-of-screen block: time-aware greeting + panchang line (scripted per the
/// user's [ScriptStyle]) + Vikram Samvat year + Gregorian date + 88 px rule.
class PanchangBlock extends ConsumerWidget {
  const PanchangBlock({
    super.key,
    this.greetingName,
    this.isFirstDay = false,
    this.now,
  });

  final String? greetingName;
  final bool isFirstDay;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final cream = isDark ? DColors.cream : LColors.text1;

    final script = ref.watch(scriptStyleProvider);

    final today = now ?? DateTime.now();
    final greeting = isFirstDay ? 'Welcome' : greetingForTimeOfDay(today);
    final greetingLine =
        greetingName == null ? greeting : '$greeting, $greetingName';

    final hindu = PanchangUtils.getHinduDate(today);
    final tithi = PanchangUtils.getTithiForDate(today);
    final vara = PanchangUtils.getVaraForDate(today);

    final monthDeva = PanchangUtils.monthDeva(hindu.monthName);
    final tithiDeva = PanchangUtils.tithiDeva(tithi.tithiName);
    final pakshaDeva = PanchangUtils.pakshaDeva(tithi.paksha);
    final varaDeva = PanchangUtils.varaDeva(vara.varaName);

    final latinLine = '${PanchangUtils.monthIast(hindu.monthName)}  ·  '
        '${PanchangUtils.pakshaIast(tithi.paksha)} '
        '${PanchangUtils.tithiIast(tithi.tithiName)}  ·  '
        '${PanchangUtils.varaIast(vara.varaName)}';

    final vsLine = isFirstDay
        ? 'DAY ONE  ·  VS ${hindu.vikramSamvatYear}'
        : 'VIKRAM SAMVAT ${hindu.vikramSamvatYear}';
    // Gregorian date alongside the Vikram Samvat year so users can match the
    // two calendars at a glance (requested by beta testers).
    final gregorianLine = DateFormat('d MMMM yyyy').format(today);

    return Padding(
      padding: const EdgeInsets.only(top: Spacing.md),
      child: Column(
        children: [
          Text(
            greetingLine,
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontStyle: FontStyle.italic,
              fontSize: 17,
              letterSpacing: 0.17,
              color: text2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          if (script.showsDevanagari)
            _PanchangLine(
              month: monthDeva,
              paksha: pakshaDeva,
              tithi: tithiDeva,
              vara: varaDeva,
              cream: cream,
              saffron: saffron,
            ),
          if (script.showsLatin) ...[
            if (script.showsDevanagari) const SizedBox(height: 4),
            Text(
              latinLine,
              textAlign: TextAlign.center,
              style: TextStyle(
                // IAST diacritics need the Devanāgarī face (Lora/Outfit tofu).
                fontFamily: Fonts.deva,
                fontFamilyFallback: AppFontFallback.deva,
                fontSize: script.showsDevanagari ? 11.5 : 14,
                letterSpacing: 0.3,
                height: 1.0,
                color: script.showsDevanagari ? text2 : cream,
              ),
            ),
          ],
          const SizedBox(height: 5),
          Text(
            vsLine,
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontFamilyFallback: AppFontFallback.latin,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.76,
              color: saffron,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            gregorianLine,
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontFamilyFallback: AppFontFallback.latin,
              fontSize: 11,
              letterSpacing: 0.4,
              color: text2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 88,
            child: BindingLine(isDark: isDark, diamondSize: 5, sideGap: 6),
          ),
        ],
      ),
    );
  }
}

class _PanchangLine extends StatelessWidget {
  const _PanchangLine({
    required this.month,
    required this.paksha,
    required this.tithi,
    required this.vara,
    required this.cream,
    required this.saffron,
  });

  final String month;
  final String paksha;
  final String tithi;
  final String vara;
  final Color cream;
  final Color saffron;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: Fonts.deva,
      fontFamilyFallback: AppFontFallback.deva,
      fontSize: 14,
      letterSpacing: 0.84,
      height: 1.0,
      color: cream,
    );

    // The mockup separates panchang segments with a 4 px saffron dot, not a
    // type-coloured "·" glyph (which renders larger and in the text colour).
    WidgetSpan dot() => WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(shape: BoxShape.circle, color: saffron),
            ),
          ),
        );

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: month),
          dot(),
          TextSpan(text: '$paksha $tithi'),
          dot(),
          TextSpan(text: vara),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
