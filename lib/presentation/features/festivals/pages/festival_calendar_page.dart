// lib/presentation/features/festivals/pages/festival_calendar_page.dart
//
// Festivals — a daily pañcāṅga almanac (S7). Heritage rebuild of
// New Design/screen-08-festivals.html: a "Today's Panchāṅga" banner, a
// tradition filter strip, and a day-row almanac grouped under sticky lunar
// month headers. Every row's tithi / nakṣatra is computed by the verified
// engine in core/panchanga/. Festivals that already passed this year keep a
// compact "Earlier this year" list so no festival is unreachable.
//
// Two pañcāṅga sources, deliberately split:
//   • core/panchanga/ — the verified engine; authoritative for the row data
//     (tithi, nakṣatra, yoga, karaṇa) that devotees act on.
//   • PanchangUtils  — the approximate synodic model already shipped on Home;
//     used here only for the month-header *label* (lunar month + VS year),
//     which is not religiously load-bearing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sanatan_guide/core/panchanga/panchanga.dart';
import 'package:sanatan_guide/core/panchanga/panchanga_names.dart';
import 'package:sanatan_guide/core/utils/panchang_utils.dart';
import 'package:sanatan_guide/data/festivals/festival_data_2026.dart';
import 'package:sanatan_guide/domain/entities/festival.dart';
import 'package:sanatan_guide/presentation/features/festivals/pages/festival_detail_page.dart';
import 'package:sanatan_guide/presentation/features/festivals/providers/festival_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

const List<String> _varaAbbr = [
  'MON',
  'TUE',
  'WED',
  'THU',
  'FRI',
  'SAT',
  'SUN',
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
const List<String> _weekdaysFull = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const List<String> _monthsShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _ymd(DateTime d) => '${d.year}-${d.month}-${d.day}';

/// The Festivals tab — a daily pañcāṅga almanac.
class FestivalCalendarPage extends ConsumerWidget {
  const FestivalCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final festivalsAsync = ref.watch(festivalsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SafeArea(
            child: festivalsAsync.when(
              loading: () => const _AlmanacShimmer(),
              error: (_, __) => _AlmanacView(festivals: festivals2026),
              data: (festivals) => _AlmanacView(festivals: festivals),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Almanac data model ──────────────────────────────────────────────────────

/// One day of the almanac window with its computed pañcāṅga.
class _DayCell {
  const _DayCell(this.date, this.panchanga);

  final DateTime date;
  final Panchanga panchanga;
}

/// A run of consecutive days sharing one lunar month.
class _LunarSegment {
  _LunarSegment(this.monthDeva, this.monthIast, this.vsYear);

  final String monthDeva;
  final String monthIast;
  final int vsYear;
  final List<_DayCell> days = [];
}

// ── Almanac view ────────────────────────────────────────────────────────────

class _AlmanacView extends StatefulWidget {
  const _AlmanacView({required this.festivals});

  final List<Festival> festivals;

  @override
  State<_AlmanacView> createState() => _AlmanacViewState();
}

class _AlmanacViewState extends State<_AlmanacView> {
  /// Selected filter; `null` means "All".
  FestivalCategory? _filter;

  late final DateTime _today;
  late final DateTime _windowStart;
  late final Panchanga _todayPanchanga;
  late final List<_LunarSegment> _segments;
  late final Map<String, List<Festival>> _festByDay;
  late final List<Festival> _earlier;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _windowStart = DateTime(now.year, now.month, 1);
    final windowEnd = DateTime(now.year, 12, 31);
    _todayPanchanga = computePanchanga(
      DateTime(now.year, now.month, now.day, 6),
    );

    // Index festivals by calendar day.
    _festByDay = {};
    for (final f in widget.festivals) {
      _festByDay.putIfAbsent(_ymd(f.date), () => []).add(f);
    }

    // Festivals that already passed this year, kept reachable below.
    _earlier = widget.festivals
        .where((f) => f.date.isBefore(_windowStart))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Build the day cells and group them into amānta-month segments — a
    // tithi index that drops below the previous day's has crossed a new
    // moon into the next lunar month. Each segment is named (adhika-aware)
    // by the verified engine.
    _segments = [];
    for (var d = _windowStart;
        !d.isAfter(windowEnd);
        d = d.add(const Duration(days: 1))) {
      final cell =
          _DayCell(d, computePanchanga(DateTime(d.year, d.month, d.day, 6)));
      if (_segments.isEmpty ||
          cell.panchanga.tithiIndex <
              _segments.last.days.last.panchanga.tithiIndex) {
        final lm = lunarMonthOf(d);
        final name = lunarMonthNames[lm.index];
        _segments.add(
          _LunarSegment(
            lm.isAdhika ? 'अधिक ${name.deva}' : name.deva,
            lm.isAdhika ? 'Adhika ${name.iast}' : name.iast,
            PanchangUtils.getHinduDate(d).vikramSamvatYear,
          ),
        );
      }
      _segments.last.days.add(cell);
    }
  }

  /// Festivals shown on [date] given the active filter.
  List<Festival> _festivalsOn(DateTime date) {
    final all = _festByDay[_ymd(date)] ?? const [];
    if (_filter == null) return all;
    return all.where((f) => f.category == _filter).toList();
  }

  void _openFestival(Festival festival) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FestivalDetailPage(festival: festival),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final earlier = _filter == null
        ? _earlier
        : _earlier.where((f) => f.category == _filter).toList();

    return Column(
      children: [
        const _Header(),
        _PanchangaBanner(
          panchanga: _todayPanchanga,
          date: _today,
          isDark: isDark,
        ),
        _FilterStrip(
          selected: _filter,
          isDark: isDark,
          onSelect: (c) => setState(() => _filter = c),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: _buildSlivers(isDark, earlier),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSlivers(bool isDark, List<Festival> earlier) {
    final slivers = <Widget>[];
    var anyRows = false;

    for (final seg in _segments) {
      final visible = _filter == null
          ? seg.days
          : seg.days.where((c) => _festivalsOn(c.date).isNotEmpty).toList();
      if (visible.isEmpty) continue;
      anyRows = true;
      slivers.add(
        SliverPersistentHeader(
          pinned: true,
          delegate: _MonthHeaderDelegate(segment: seg, isDark: isDark),
        ),
      );
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final cell = visible[i];
              return _DayRow(
                cell: cell,
                festivals: _festivalsOn(cell.date),
                isToday: cell.date == _today,
                isDark: isDark,
                onTapFestival: _openFestival,
              );
            },
            childCount: visible.length,
          ),
        ),
      );
    }

    if (earlier.isNotEmpty) {
      anyRows = true;
      slivers.add(
        SliverToBoxAdapter(child: _EarlierHeader(isDark: isDark)),
      );
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _EarlierRow(
              festival: earlier[i],
              isDark: isDark,
              onTap: () => _openFestival(earlier[i]),
            ),
            childCount: earlier.length,
          ),
        ),
      );
    }

    if (!anyRows) {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No festivals in this category.',
                style: TextStyle(
                  fontFamily: Fonts.serif,
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                  color: isDark ? DColors.text2 : LColors.text2,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      slivers.add(
        SliverToBoxAdapter(child: _Disclaimer(isDark: isDark)),
      );
    }
    return slivers;
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text1 = isDark ? DColors.text1 : LColors.text1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 24, 6),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, size: 22, color: text1),
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'पञ्चाङ्ग',
                  style: TextStyle(
                    fontFamily: Fonts.deva,
                    fontSize: 16,
                    color: isDark ? DColors.saffron : LColors.saffron,
                  ),
                ),
                TextSpan(
                  text: '  ·  Almanac',
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    color: text1,
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

// ── Panchāṅga banner ────────────────────────────────────────────────────────

class _PanchangaBanner extends StatelessWidget {
  const _PanchangaBanner({
    required this.panchanga,
    required this.date,
    required this.isDark,
  });

  final Panchanga panchanga;
  final DateTime date;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;

    final greg = '${_weekdaysShort[date.weekday - 1]}, ${date.day} '
        '${_monthsShort[date.month - 1]} ${date.year}';

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: isDark ? DColors.surface : LColors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(
          color: isDark ? DColors.divider : LColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S PANCHANGA",
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.66,
              color: saffron,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  panchanga.tithiLabelDeva,
                  style: TextStyle(
                    fontFamily: Fonts.deva,
                    fontSize: 22,
                    height: 1.0,
                    color: cream,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                greg,
                style: TextStyle(
                  fontFamily: Fonts.serif,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  color: text2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: dividerSoft)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _BannerCell(
                    label: 'Vara',
                    value: panchanga.vara.deva,
                    en: _weekdaysFull[date.weekday - 1],
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _BannerCell(
                    label: 'Nakshatra',
                    value: panchanga.nakshatra.deva,
                    en: panchanga.nakshatra.iast,
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _BannerCell(
                    label: 'Yoga',
                    value: panchanga.yoga.deva,
                    en: panchanga.yoga.iast,
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _BannerCell(
                    label: 'Karana',
                    value: panchanga.karana.deva,
                    en: panchanga.karana.iast,
                    isDark: isDark,
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

class _BannerCell extends StatelessWidget {
  const _BannerCell({
    required this.label,
    required this.value,
    required this.en,
    required this.isDark,
  });

  final String label;
  final String value;
  final String en;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
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
            letterSpacing: 1.5,
            color: text3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontFamily: Fonts.deva,
            fontSize: 13,
            height: 1.1,
            color: cream,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          en,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: Fonts.deva,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: text3,
          ),
        ),
      ],
    );
  }
}

// ── Filter strip ────────────────────────────────────────────────────────────

class _FilterStrip extends StatelessWidget {
  const _FilterStrip({
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  final FestivalCategory? selected;
  final bool isDark;
  final ValueChanged<FestivalCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          _FilterPill(
            label: 'All',
            active: selected == null,
            isDark: isDark,
            onTap: () => onSelect(null),
          ),
          for (final c in FestivalCategory.values)
            _FilterPill(
              label: c.pluralLabel,
              active: selected == c,
              isDark: isDark,
              onTap: () => onSelect(c),
            ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.active,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final glow = isDark ? DColors.saffronGlow : LColors.saffronGlow;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final text2 = isDark ? DColors.text2 : LColors.text2;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? glow : Colors.transparent,
            borderRadius: BorderRadius.circular(Radii.pill),
            border: Border.all(color: active ? saffron : dividerSoft),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              color: active ? saffron : text2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sticky lunar-month header ───────────────────────────────────────────────

class _MonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  _MonthHeaderDelegate({required this.segment, required this.isDark});

  final _LunarSegment segment;
  final bool isDark;

  @override
  double get minExtent => 46;

  @override
  double get maxExtent => 46;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final bg = (isDark ? DColors.bg : LColors.bg).withValues(alpha: 0.94);
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      alignment: Alignment.bottomLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            segment.monthDeva,
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontSize: 19,
              height: 1.0,
              color: saffron,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            segment.monthIast,
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontSize: 12.5,
              color: text2,
            ),
          ),
          const Spacer(),
          Text(
            'VS ${segment.vsYear}',
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.8,
              color: text3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_MonthHeaderDelegate old) =>
      old.segment.monthDeva != segment.monthDeva ||
      old.segment.vsYear != segment.vsYear ||
      old.isDark != isDark;
}

// ── Day row ─────────────────────────────────────────────────────────────────

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.cell,
    required this.festivals,
    required this.isToday,
    required this.isDark,
    required this.onTapFestival,
  });

  final _DayCell cell;
  final List<Festival> festivals;
  final bool isToday;
  final bool isDark;
  final ValueChanged<Festival> onTapFestival;

  @override
  Widget build(BuildContext context) {
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final p = cell.panchanga;

    final body = Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerSoft)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: _DateColumn(cell: cell, isToday: isToday, isDark: isDark),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: _MoonPhase(
              tithiIndex: p.tithiIndex,
              paksha: p.paksha,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DayBody(
              panchanga: p,
              festivals: festivals,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );

    final row = Stack(
      children: [
        festivals.isEmpty
            ? body
            : InkWell(onTap: () => onTapFestival(festivals.first), child: body),
        if (isToday)
          Positioned(
            left: 12,
            top: 13,
            bottom: 13,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: saffron,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
    return row;
  }
}

class _DateColumn extends StatelessWidget {
  const _DateColumn({
    required this.cell,
    required this.isToday,
    required this.isDark,
  });

  final _DayCell cell;
  final bool isToday;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return Column(
      children: [
        Text(
          '${cell.date.day}',
          style: TextStyle(
            fontFamily: Fonts.serif,
            fontSize: 19,
            height: 1.0,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
            color: isToday ? saffron : text1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _varaAbbr[cell.date.weekday - 1],
          style: TextStyle(
            fontFamily: Fonts.sans,
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: text3,
          ),
        ),
      ],
    );
  }
}

class _DayBody extends StatelessWidget {
  const _DayBody({
    required this.panchanga,
    required this.festivals,
    required this.isDark,
  });

  final Panchanga panchanga;
  final List<Festival> festivals;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${panchanga.paksha.iast.toUpperCase()}  ',
                style: TextStyle(
                  fontFamily: Fonts.deva,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  color: text3,
                ),
              ),
              TextSpan(
                text: panchanga.tithi.deva,
                style: TextStyle(
                  fontFamily: Fonts.deva,
                  fontSize: 13,
                  color: text1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${panchanga.nakshatra.deva}  ',
                style: TextStyle(
                  fontFamily: Fonts.deva,
                  fontSize: 11,
                  color: text2,
                ),
              ),
              TextSpan(
                text: panchanga.nakshatra.iast,
                style: TextStyle(
                  fontFamily: Fonts.deva,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: text3,
                ),
              ),
            ],
          ),
        ),
        for (final f in festivals) _DayFestival(festival: f, isDark: isDark),
      ],
    );
  }
}

class _DayFestival extends StatelessWidget {
  const _DayFestival({required this.festival, required this.isDark});

  final Festival festival;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final ironRed = isDark ? DColors.ironRedBright : LColors.ironRed;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: dividerSoft)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(
                festival.sanskritName,
                style: TextStyle(
                  fontFamily: Fonts.deva,
                  fontSize: 14,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                  color: ironRed,
                ),
              ),
              Text(
                festival.name,
                style: TextStyle(
                  fontFamily: Fonts.serif,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  height: 1.25,
                  color: text1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${festival.category.label} · ${festival.deity}'.toUpperCase(),
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.7,
              color: text3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Moon-phase glyph ────────────────────────────────────────────────────────

/// A 16 px lunar disc filled in proportion to the tithi — empty at Amāvāsyā,
/// full at Pūrṇimā, lit on the right while waxing and the left while waning.
class _MoonPhase extends StatelessWidget {
  const _MoonPhase({
    required this.tithiIndex,
    required this.paksha,
    required this.isDark,
  });

  final int tithiIndex;
  final Paksha paksha;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lit = isDark ? DColors.cream : LColors.text1;
    final dark = isDark ? DColors.text3 : LColors.text3;
    final waxing = paksha == Paksha.shukla;
    final fraction =
        (waxing ? (tithiIndex + 1) / 15.0 : (29 - tithiIndex) / 15.0)
            .clamp(0.0, 1.0);
    final outline = fraction >= 0.99 ? lit : dark;

    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        children: [
          ClipOval(
            child: Align(
              alignment: waxing ? Alignment.centerRight : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraction,
                heightFactor: 1,
                child: ColoredBox(color: lit),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: outline),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Earlier-this-year section ───────────────────────────────────────────────

class _EarlierHeader extends StatelessWidget {
  const _EarlierHeader({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        'EARLIER THIS YEAR',
        style: AppText.sectionLabel(
          color: isDark ? DColors.text3 : LColors.text3,
        ),
      ),
    );
  }
}

class _EarlierRow extends StatelessWidget {
  const _EarlierRow({
    required this.festival,
    required this.isDark,
    required this.onTap,
  });

  final Festival festival;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final ironRed = isDark ? DColors.ironRedBright : LColors.ironRed;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: dividerSoft)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                '${festival.date.day} '
                '${_monthsShort[festival.date.month - 1]}',
                style: TextStyle(
                  fontFamily: Fonts.sans,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: text3,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    festival.name,
                    style: TextStyle(
                      fontFamily: Fonts.serif,
                      fontSize: 14.5,
                      color: text1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    festival.sanskritName,
                    style: TextStyle(
                      fontFamily: Fonts.deva,
                      fontSize: 12,
                      color: ironRed,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: text3),
          ],
        ),
      ),
    );
  }
}

// ── Disclaimer ──────────────────────────────────────────────────────────────

class _Disclaimer extends StatelessWidget {
  const _Disclaimer({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Text(
        'Panchanga is computed for your device timezone. Consult your local '
        'pandit for regional variations.',
        style: TextStyle(
          fontFamily: Fonts.sans,
          fontSize: 10.5,
          height: 1.5,
          color: isDark ? DColors.text3 : LColors.text3,
        ),
      ),
    );
  }
}

// ── Loading state ───────────────────────────────────────────────────────────

class _AlmanacShimmer extends StatefulWidget {
  const _AlmanacShimmer();

  @override
  State<_AlmanacShimmer> createState() => _AlmanacShimmerState();
}

class _AlmanacShimmerState extends State<_AlmanacShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? DColors.saffronGlow : LColors.saffronGlow;

    Widget box(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(2),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Header(),
        FadeTransition(
          opacity: Tween<double>(begin: 0.4, end: 0.9).animate(_ctrl),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                box(180, 20),
                const SizedBox(height: 24),
                for (var i = 0; i < 7; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Row(
                      children: [
                        box(28, 28),
                        const SizedBox(width: 16),
                        box(16, 16),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              box(160, 12),
                              const SizedBox(height: 6),
                              box(110, 9),
                            ],
                          ),
                        ),
                      ],
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
