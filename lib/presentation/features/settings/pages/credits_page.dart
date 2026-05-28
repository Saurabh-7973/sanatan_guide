// lib/presentation/features/settings/pages/credits_page.dart
//
// Credits & Attributions — heritage spec 13 Part B. Fixed back-bar (no overlay,
// no collision), sūtra-numbered domain sections, saffron <em> term, exact
// external-link arrow, uppercase letter-spaced meta, Bṛhadāraṇyaka footer.

import 'package:flutter/material.dart';
import 'package:sanatan_guide/core/constants/content_credits.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/shared/widgets/mockup_icons.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';
import 'package:url_launcher/url_launcher.dart';

/// One render row, source-agnostic (scripture or tool).
class _Row {
  const _Row({
    required this.title,
    required this.description,
    required this.meta,
    required this.linksOut,
    this.term,
    this.url,
  });
  final String? term;
  final String title;
  final String description;
  final String meta;
  final bool linksOut;
  final Uri? url;
}

/// Lift the first plausible https domain out of a free-text meta/source line.
/// Returns null when no domain is present (rows that don't link out).
Uri? _deriveUrl(String text) {
  final m = RegExp(r'[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?'
          r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?)+')
      .firstMatch(text);
  if (m == null) return null;
  final host = m.group(0)!;
  if (!host.contains('.')) return null;
  // Skip noise like "1.4.14" or file extensions
  if (RegExp(r'^\d').hasMatch(host)) return null;
  return Uri.parse('https://$host');
}

/// Per-scripture deep-link override. When a row's [scriptureId] maps to an
/// entry here, the credit row tap opens this URL instead of the bare host
/// derived from [ScriptureCredit.source]. Without this, every row that
/// names "sacred-texts.com" lands on the same homepage — see audit doc.
///
/// Add entries as authoritative source URLs are verified. Falsy default
/// keeps the bare-host fallback rather than blocking the tap entirely.
const Map<String, String> _scriptureSourceUrls = <String, String>{
  // Examples — verify the path before un-commenting. Left empty for v1.
  // 'bhagavad_gita': 'https://vedabase.io/en/library/bg/',
  // 'rigveda': 'https://www.sacred-texts.com/hin/rigveda/',
  // 'bhagavata_purana': 'https://vedabase.io/en/library/sb/',
};

/// Pick the best URL for a credit row: per-scripture override if present,
/// else the bare host parsed from [source].
Uri? _resolveCreditUrl({required String scriptureId, required String source}) {
  final override = _scriptureSourceUrls[scriptureId];
  if (override != null && override.isNotEmpty) return Uri.parse(override);
  return _deriveUrl(source);
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
              description: c.licenseNote == null
                  ? c.translators.join(' · ')
                  : '${c.translators.join(' · ')}. ${c.licenseNote}',
              meta: '${c.source} · ${c.licenseLabel}',
              linksOut: c.source.contains('.'),
              url: _resolveCreditUrl(
                scriptureId: c.scriptureId,
                source: c.source,
              ),
            ))
        .toList();
    if (rows.isNotEmpty) sections.add(_Section(s.catalogTitle, rows));
  }
  sections.add(_Section(
    'Tools used in preparing this app',
    appToolCredits
        .map((t) => _Row(
              term: t.term,
              title: t.title,
              description: t.description,
              meta: t.meta,
              linksOut: t.linksOut,
              url: t.linksOut ? _deriveUrl(t.meta) : null,
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
    final sections = _buildSections();

    final blocks = <Widget>[
      _Hero(isDark: isDark),
      const SizedBox(height: 26),
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
      blocks.add(const SizedBox(height: 26));
    }
    blocks.add(_LineageFooter(isDark: isDark));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SafeArea(
            child: Column(
              children: [
                // Fixed topbar (mockup .credits-topbar: flex-shrink:0, no
                // title) — content scrolls BELOW it, no overlay collision.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                  child: Row(
                    children: [
                      InkResponse(
                        onTap: () => Navigator.of(context).maybePop(),
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
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32),
                    children: blocks,
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
  const _Hero({required this.isDark});
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('श्रद्धा · WITH GRATITUDE',
              style: AppText.sectionLabel(color: saffron)),
          const SizedBox(height: 6),
          Text(
            'Credits & Attributions',
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontSize: 26,
              fontWeight: FontWeight.w500,
              height: 1.15,
              letterSpacing: -0.52,
              color: text1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Every verse in this app comes from a real academic source. '
            'Nothing is invented. The texts are public domain; the '
            'digitisation work that made them readable is not. We '
            'acknowledge it here.',
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontStyle: FontStyle.italic,
              fontSize: 14,
              height: 1.6,
              color: text2,
            ),
          ),
        ],
      ),
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
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: divider)),
      ),
      child:
          Text(title.toUpperCase(), style: AppText.sectionLabel(color: text3)),
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

    final hasUrl = row.url != null;
    final body = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: SizedBox(
              width: 16,
              child: Text(
                numeral,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: Fonts.deva,
                  fontFamilyFallback: AppFontFallback.deva,
                  fontSize: 14,
                  height: 1.2,
                  color: saffron,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(children: [
                    if (row.term != null)
                      TextSpan(
                        text: '${row.term} ',
                        style: TextStyle(
                          fontFamily: Fonts.deva,
                          fontFamilyFallback: AppFontFallback.deva,
                          fontWeight: FontWeight.w500,
                          color: saffron,
                        ),
                      ),
                    TextSpan(text: row.title),
                  ]),
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    letterSpacing: -0.075,
                    color: text1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  row.description,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontStyle: FontStyle.italic,
                    fontSize: 12.5,
                    height: 1.5,
                    color: text2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  row.meta.toUpperCase(),
                  style: TextStyle(
                    fontFamily: Fonts.sans,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.71, // 0.18em at 9.5px
                    color: text3,
                  ),
                ),
              ],
            ),
          ),
          if (row.linksOut)
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 4),
              child: Opacity(
                opacity: 0.4,
                child: SizedBox(
                  width: 11,
                  height: 11,
                  child: CustomPaint(
                    painter: _ExternalArrowPainter(color: text3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final container = Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: showDivider ? Border(bottom: BorderSide(color: sep)) : null,
      ),
      child: hasUrl
          ? InkWell(
              onTap: () => _openUrl(context, row.url!),
              child: body,
            )
          : body,
    );
    return container;
  }
}

Future<void> _openUrl(BuildContext context, Uri url) async {
  final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open ${url.host}')),
    );
  }
}

/// Mockup `.credit-link-arrow`: 11×11, paths M4 1h6v6 + M10 1L4 7, sw 1.4.
class _ExternalArrowPainter extends CustomPainter {
  const _ExternalArrowPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 11.0;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * u
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final corner = Path()
      ..moveTo(4 * u, 1 * u)
      ..lineTo(10 * u, 1 * u)
      ..lineTo(10 * u, 7 * u);
    canvas.drawPath(corner, p);
    canvas.drawLine(Offset(10 * u, 1 * u), Offset(4 * u, 7 * u), p);
  }

  @override
  bool shouldRepaint(_ExternalArrowPainter old) => old.color != color;
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
      margin: const EdgeInsets.fromLTRB(24, 28, 24, 0),
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
              fontFamilyFallback: AppFontFallback.deva,
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
              fontFamilyFallback: AppFontFallback.latin,
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
