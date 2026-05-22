// lib/presentation/features/festivals/pages/festival_detail_page.dart
//
// Festival detail — heritage restyle of screen-08-festivals.html's detail
// frame. A tithi-anchored hero, a 2×2 panchāṅga data grid computed by the
// verified engine, the explainer prose, and the observance steps.

import 'package:flutter/material.dart';

import 'package:sanatan_guide/core/panchanga/panchanga.dart';
import 'package:sanatan_guide/core/utils/panchang_utils.dart';
import 'package:sanatan_guide/domain/entities/festival.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

const List<String> _monthsShort = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];

const List<String> _weekdaysShort = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

/// Full-screen detail for one [Festival], reached from the almanac.
class FestivalDetailPage extends StatelessWidget {
  const FestivalDetailPage({super.key, required this.festival});

  final Festival festival;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = festival.date;
    final panchanga = computePanchanga(
      DateTime(date.year, date.month, date.day, 6),
    );
    final hindu = PanchangUtils.getHinduDate(date);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? DColors.text1 : LColors.text1,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              0,
              kToolbarHeight + MediaQuery.paddingOf(context).top,
              0,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Hero(
                  festival: festival,
                  panchanga: panchanga,
                  hindu: hindu,
                  isDark: isDark,
                ),
                _DataGrid(
                  festival: festival,
                  panchanga: panchanga,
                  isDark: isDark,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('About the day', isDark: isDark),
                      const SizedBox(height: 10),
                      Text(
                        festival.explainer,
                        style: TextStyle(
                          fontFamily: Fonts.serif,
                          fontSize: 14.5,
                          height: 1.7,
                          color: isDark ? DColors.text1 : LColors.text1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel('How to observe', isDark: isDark),
                      const SizedBox(height: 6),
                      ...festival.howToObserve.asMap().entries.map(
                            (e) => _ObserveStep(
                              index: e.key + 1,
                              text: e.value,
                              isDark: isDark,
                            ),
                          ),
                      const SizedBox(height: 20),
                      _Disclaimer(isDark: isDark),
                    ],
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
    required this.festival,
    required this.panchanga,
    required this.hindu,
    required this.isDark,
  });

  final Festival festival;
  final Panchanga panchanga;
  final HinduDateInfo hindu;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final date = festival.date;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${PanchangUtils.monthIast(hindu.monthName)} · '
            '${panchanga.tithiLabelIast}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontSize: 11,
              letterSpacing: 1.5,
              color: saffron,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            festival.sanskritName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontSize: 32,
              height: 1.15,
              color: cream,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            festival.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontStyle: FontStyle.italic,
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: text1,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isDark ? DColors.surface : LColors.surface,
                borderRadius: BorderRadius.circular(Radii.card),
                border: Border.all(
                  color: isDark ? DColors.divider : LColors.divider,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    date.day.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontFamily: Fonts.serif,
                      fontSize: 24,
                      height: 1.0,
                      fontWeight: FontWeight.w500,
                      color: saffron,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_monthsShort[date.month - 1]} ${date.year}',
                        style: TextStyle(
                          fontFamily: Fonts.sans,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.9,
                          color: text3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${panchanga.vara.deva} · '
                        '${_weekdaysShort[date.weekday - 1]}',
                        style: TextStyle(
                          fontFamily: Fonts.deva,
                          fontSize: 13,
                          color: cream,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataGrid extends StatelessWidget {
  const _DataGrid({
    required this.festival,
    required this.panchanga,
    required this.isDark,
  });

  final Festival festival;
  final Panchanga panchanga;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final divider = isDark ? DColors.divider : LColors.divider;
    final brightFortnight = panchanga.paksha == Paksha.shukla;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: divider),
          bottom: BorderSide(color: divider),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DataCell(
                  label: 'Tithi',
                  value: panchanga.tithi.deva,
                  en: panchanga.tithi.iast,
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _DataCell(
                  label: 'Paksha',
                  value: panchanga.paksha.deva,
                  en: brightFortnight ? 'Bright fortnight' : 'Dark fortnight',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DataCell(
                  label: 'Nakshatra',
                  value: panchanga.nakshatra.deva,
                  en: panchanga.nakshatra.iast,
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _DataCell(
                  label: 'Tradition',
                  value: festival.category.label,
                  en: null,
                  valueIsSans: true,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({
    required this.label,
    required this.value,
    required this.en,
    required this.isDark,
    this.valueIsSans = false,
  });

  final String label;
  final String value;
  final String? en;
  final bool isDark;
  final bool valueIsSans;

  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final cream = isDark ? DColors.cream : LColors.text1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: Fonts.sans,
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.9,
            color: text3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: valueIsSans
              ? TextStyle(
                  fontFamily: Fonts.sans,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: cream,
                )
              : TextStyle(
                  fontFamily: Fonts.deva,
                  fontSize: 14,
                  height: 1.2,
                  color: cream,
                ),
        ),
        if (en != null) ...[
          const SizedBox(height: 2),
          Text(
            en!,
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              color: text2,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.isDark});

  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppText.sectionLabel(
        color: isDark ? DColors.saffron : LColors.saffron,
      ),
    );
  }
}

class _ObserveStep extends StatelessWidget {
  const _ObserveStep({
    required this.index,
    required this.text,
    required this.isDark,
  });

  final int index;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerSoft)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              index.toString(),
              style: TextStyle(
                fontFamily: Fonts.serif,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: saffron,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: Fonts.serif,
                fontSize: 13.5,
                height: 1.55,
                color: isDark ? DColors.text2 : LColors.text2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Panchanga values are computed for your device timezone. Consult your '
      'local pandit for regional variations.',
      style: TextStyle(
        fontFamily: Fonts.sans,
        fontSize: 10.5,
        height: 1.5,
        color: isDark ? DColors.text3 : LColors.text3,
      ),
    );
  }
}
