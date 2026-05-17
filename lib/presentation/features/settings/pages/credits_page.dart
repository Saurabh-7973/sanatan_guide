// lib/presentation/features/settings/pages/credits_page.dart
//
// Credits & Attributions — heritage spec 13 Part B. Sūtra-numbered domain
// sections + Bṛhadāraṇyaka lineage footer. Scripture data from contentCredits;
// tool data from appToolCredits.

import 'package:flutter/material.dart';
import 'package:sanatan_guide/core/constants/content_credits.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

/// One render row, source-agnostic (scripture or tool).
class _Row {
  const _Row({
    required this.title,
    required this.description,
    required this.meta,
    required this.linksOut,
  });
  final String title;
  final String description;
  final String meta;
  final bool linksOut;
}

class _Section {
  const _Section(this.title, this.rows);
  final String title;
  final List<_Row> rows;
}

List<_Section> _buildSections() {
  final sections = <_Section>[];
  for (final s in CreditCatalogSection.values) {
    final rows = contentCredits
        .where((c) => c.section == s)
        .map((c) => _Row(
              title: c.displayName,
              description: c.translators.join(' · '),
              meta: c.licenseNote == null
                  ? '${c.source} · ${c.licenseLabel}'
                  : '${c.source} · ${c.licenseLabel} · ${c.licenseNote}',
              linksOut: c.source.contains('.'),
            ))
        .toList();
    if (rows.isNotEmpty) sections.add(_Section(s.catalogTitle, rows));
  }
  sections.add(_Section(
    'Tools used in preparing this app',
    appToolCredits
        .map((t) => _Row(
              title: t.title,
              description: t.description,
              meta: t.meta,
              linksOut: t.linksOut,
            ))
        .toList(),
  ));
  return sections;
}

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final sections = _buildSections();

    final blocks = <Widget>[
      _Hero(isDark: isDark),
      const SizedBox(height: 28),
    ];
    var animIndex = 0;
    for (final section in sections) {
      blocks.add(_SectionHeader(title: section.title, isDark: isDark));
      for (var i = 0; i < section.rows.length; i++) {
        blocks.add(_FadeUp(
          index: animIndex++,
          child: _CreditRow(
            numeral: DandaCoord.toDevanagari(i + 1),
            row: section.rows[i],
            isDark: isDark,
            showDivider: i != section.rows.length - 1,
          ),
        ));
      }
      blocks.add(const SizedBox(height: 28));
    }
    blocks.add(_LineageFooter(isDark: isDark));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: text1),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SafeArea(
            top: false,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: kToolbarHeight + MediaQuery.paddingOf(context).top,
                bottom: 32,
              ),
              children: blocks,
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.isDark});
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('श्रद्धा · WITH GRATITUDE',
            style: AppText.sectionLabel(color: saffron)),
        const SizedBox(height: 12),
        Text(
          'Credits & Attributions',
          style: TextStyle(
            fontFamily: Fonts.serif,
            fontSize: 26,
            fontWeight: FontWeight.w500,
            height: 1.15,
            letterSpacing: -0.5,
            color: text1,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Every verse in this app comes from a real academic source. '
          'Nothing is invented. The texts are public domain; the '
          'digitisation work that made them readable is not. We '
          'acknowledge it here.',
          style: TextStyle(
            fontFamily: Fonts.serif,
            fontStyle: FontStyle.italic,
            fontSize: 14,
            height: 1.6,
            color: text2,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.isDark});
  final String title;
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: divider)),
      ),
      child: Text(title.toUpperCase(),
          style: AppText.sectionLabel(color: text3)),
    );
  }
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({
    required this.numeral,
    required this.row,
    required this.isDark,
    required this.showDivider,
  });
  final String numeral;
  final _Row row;
  final bool isDark;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final sep = isDark ? DColors.dividerSoft : LColors.dividerSoft;

    return Container(
      decoration: BoxDecoration(
        border:
            showDivider ? Border(bottom: BorderSide(color: sep)) : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 16,
            child: Text(
              numeral,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Fonts.deva,
                fontSize: 14,
                color: saffron,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    color: text1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  row.description,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontStyle: FontStyle.italic,
                    fontSize: 12.5,
                    height: 1.5,
                    color: text2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(row.meta, style: AppText.meta(color: text3, size: 9.5)),
              ],
            ),
          ),
          if (row.linksOut)
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 2),
              child: Icon(Icons.north_east,
                  size: 11, color: text3.withValues(alpha: 0.6)),
            ),
        ],
      ),
    );
  }
}

class _LineageFooter extends StatelessWidget {
  const _LineageFooter({required this.isDark});
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    final surface = isDark ? DColors.surface : LColors.surface;
    final divider = isDark ? DColors.divider : LColors.divider;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    return Container(
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: divider),
      ),
      child: Column(
        children: [
          BindingLine(isDark: isDark),
          const SizedBox(height: 18),
          Text(
            'सर्वे भवन्तु सुखिनः ।\nसर्वे सन्तु निरामयाः ॥',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontSize: 18,
              height: 1.4,
              color: saffron,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"May all be happy. May all be free of suffering."\n'
            '— Bṛhadāraṇyaka Upaniṣad 1.4.14',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontStyle: FontStyle.italic,
              fontSize: 12.5,
              height: 1.5,
              color: text2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fade-up entrance, 40 ms stagger (index capped so deep rows still animate).
class _FadeUp extends StatelessWidget {
  const _FadeUp({required this.index, required this.child});
  final int index;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final delayMs = index.clamp(0, 14) * 40;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + delayMs),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child:
            Transform.translate(offset: Offset(0, (1 - t) * 8), child: child),
      ),
      child: child,
    );
  }
}
