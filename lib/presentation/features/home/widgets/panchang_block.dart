import 'package:flutter/material.dart';
import 'package:sanatan_guide/core/utils/panchang_utils.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

/// Top-of-screen block: time-aware greeting + Devanāgarī panchang line +
/// Vikram Samvat year + 88 px IncisedRule.
class PanchangBlock extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final cream = isDark ? DColors.cream : LColors.text1;

    final today = now ?? DateTime.now();
    final greeting = isFirstDay
        ? 'Welcome'
        : greetingForTimeOfDay(today);
    final greetingLine =
        greetingName == null ? greeting : '$greeting, $greetingName';

    final hindu = PanchangUtils.getHinduDate(today);
    final tithi = PanchangUtils.getTithiForDate(today);
    final vara = PanchangUtils.getVaraForDate(today);

    final monthDeva = PanchangUtils.monthDeva(hindu.monthName);
    final tithiDeva = PanchangUtils.tithiDeva(tithi.tithiName);
    final pakshaDeva = PanchangUtils.pakshaDeva(tithi.paksha);
    final varaDeva = PanchangUtils.varaDeva(vara.varaName);

    final vsLine = isFirstDay
        ? 'DAY ONE  ·  VS ${hindu.vikramSamvatYear}'
        : 'VIKRAM SAMVAT ${hindu.vikramSamvatYear}';

    return Padding(
      padding: const EdgeInsets.only(top: Spacing.md),
      child: Column(
        children: [
          Text(
            greetingLine,
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontStyle: FontStyle.italic,
              fontSize: 17,
              letterSpacing: 0.17,
              color: text2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          _PanchangLine(
            month: monthDeva,
            paksha: pakshaDeva,
            tithi: tithiDeva,
            vara: varaDeva,
            cream: cream,
            saffron: saffron,
          ),
          const SizedBox(height: 5),
          Text(
            vsLine,
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.76,
              color: saffron,
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
      fontSize: 14,
      letterSpacing: 0.84,
      height: 1.0,
      color: cream,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            '$month  ·  $paksha $tithi  ·  $vara',
            style: base,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
