import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

/// Scripture Library — Śruti / Smṛti taxonomy in 6 families.
///
/// Rows not cards. Vedas get a 2×2 grid (3:2 aspect, Sulba Sutra brick).
/// Sticky family headers on scroll. Inline search replaces family list
/// when active. Tamil rendered in Tamil script.
class ScriptureLibraryPage extends ConsumerStatefulWidget {
  const ScriptureLibraryPage({super.key});

  @override
  ConsumerState<ScriptureLibraryPage> createState() =>
      _ScriptureLibraryPageState();
}

class _ScriptureLibraryPageState extends ConsumerState<ScriptureLibraryPage> {
  String _query = '';
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onQueryChanged(String v) =>
      setState(() => _query = v.trim().toLowerCase());

  void _clearQuery() {
    _ctrl.clear();
    _focus.unfocus();
    setState(() => _query = '');
  }

  // ── Indian-format comma grouping (1,33,613 not 133,613)
  static String _indianFormat(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    for (var i = rest.length; i > 0; i -= 2) {
      final start = i - 2 < 0 ? 0 : i - 2;
      buf.write(rest.substring(start, i));
      if (start > 0) buf.write(',');
    }
    final reversed = buf.toString().split(',').reversed.join(',');
    return '$reversed,$last3';
  }

  static int _totalVerses() {
    final fromFamilies = _kFamilies
        .expand((f) => f.scriptures)
        .fold(0, (sum, s) => sum + s.verseCount);
    final fromVedas = _kVedas.fold(0, (sum, s) => sum + s.verseCount);
    return fromFamilies + fromVedas + _kMukhyaUpanishads.verseCount;
  }

  static int _totalScriptures() {
    final fromFamilies =
        _kFamilies.fold(0, (sum, f) => sum + f.scriptures.length);
    return fromFamilies + _kVedas.length + 1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? DColors.bg : LColors.bg;

    // Worst-case header height (used by every pinned family delegate). Sized
    // for a two-line description + Devanāgarī name + English/meta row +
    // gaps, with the text-driven blocks scaled by the user's text-size
    // setting so the accessibility path doesn't clip.
    final textScaler = MediaQuery.textScalerOf(context);
    final headerHeight = 46.0 + textScaler.scale(88.0);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _Header(isDark: isDark)),
            SliverToBoxAdapter(
              child: _SearchBar(
                isDark: isDark,
                controller: _ctrl,
                focus: _focus,
                query: _query,
                onChanged: _onQueryChanged,
                onClear: _clearQuery,
              ),
            ),
            if (_query.isEmpty) ...[
              const SliverPadding(padding: EdgeInsets.only(top: 32)),
              for (var i = 0; i < _kFamilies.length; i++) ...[
                if (i > 0)
                  const SliverPadding(padding: EdgeInsets.only(top: 32)),
                SliverMainAxisGroup(
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _FamilyHeaderDelegate(
                        family: _kFamilies[i],
                        isDark: isDark,
                        height: headerHeight,
                      ),
                    ),
                    if (_kFamilies[i].kind == _FamilyKind.shruti)
                      _VedasGridSliver(isDark: isDark)
                    else
                      SliverList.builder(
                        itemCount: _kFamilies[i].scriptures.length,
                        itemBuilder: (context, j) {
                          return _ScriptureRow(
                            isDark: isDark,
                            scripture: _kFamilies[i].scriptures[j],
                            isLast: j == _kFamilies[i].scriptures.length - 1,
                            family: _kFamilies[i],
                          );
                        },
                      ),
                    if (_kFamilies[i].kind == _FamilyKind.shruti)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _ScriptureRow(
                            isDark: isDark,
                            scripture: _kMukhyaUpanishads,
                            isLast: true,
                            family: _kFamilies[i],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ] else
              _SearchResultsSliver(
                isDark: isDark,
                query: _query,
                onTap: (id) => _openScripture(context, id),
              ),
          ],
        ),
      ),
    );
  }
}

void _openScripture(BuildContext context, String id) {
  if (_kSingleChapterBrowse.contains(id)) {
    context.push('/browse/$id/chapter/1');
  } else {
    context.push('/browse/$id');
  }
}

const _kSingleChapterBrowse = {
  'mandukya_upanishad',
  'isha_upanishad',
  'kena_upanishad',
  'mundaka_upanishad',
  'katha_upanishad',
  'vishnu_sahasranama',
  'prashna_upanishad',
  'taittiriya_upanishad',
  'aitareya_upanishad',
  'shvetashvatara_upanishad',
  'kaushitaki_upanishad',
  'maitrayani_upanishad',
};

// ============================================================
// Header — title + Indian-format stats line
// ============================================================
class _Header extends StatelessWidget {
  const _Header({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final saffron = isDark ? DColors.saffron : LColors.saffron;

    final verses = _ScriptureLibraryPageState._indianFormat(
        _ScriptureLibraryPageState._totalVerses());
    final scriptures = _ScriptureLibraryPageState._totalScriptures();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Library',
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontSize: 32,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.64,
              height: 1,
              color: text1,
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: Fonts.sans,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.76,
                color: text3,
              ),
              children: [
                TextSpan(
                  text: verses,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    color: saffron,
                  ),
                ),
                const TextSpan(text: '  VERSES'),
                TextSpan(
                  text: '   ·   ',
                  style: TextStyle(color: saffron),
                ),
                TextSpan(
                  text: '$scriptures',
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    color: saffron,
                  ),
                ),
                const TextSpan(text: '  SCRIPTURES'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SearchBar — 44 px rounded 28, saffron focus
// ============================================================
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.isDark,
    required this.controller,
    required this.focus,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final bool isDark;
  final TextEditingController controller;
  final FocusNode focus;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? DColors.surface : LColors.surface;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final isFocused = focus.hasFocus || query.isNotEmpty;

    return AnimatedBuilder(
      animation: focus,
      builder: (context, _) {
        final borderColor = isFocused ? saffron : dividerSoft;
        final iconColor = isFocused ? saffron : text3;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: iconColor),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focus,
                    onChanged: onChanged,
                    cursorColor: saffron,
                    style: TextStyle(
                      fontFamily: Fonts.sans,
                      fontSize: 14,
                      letterSpacing: 0.14,
                      color: text1,
                    ),
                    decoration: InputDecoration(
                      // The app's inputDecorationTheme supplies a filled,
                      // rounded OutlineInputBorder; without overriding every
                      // border slot (not just `border`) it paints a second box
                      // inside this pill.
                      isCollapsed: true,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      hintText: 'Find a scripture...',
                      hintStyle: TextStyle(
                        fontFamily: Fonts.sans,
                        fontSize: 14,
                        letterSpacing: 0.14,
                        color: text3,
                      ),
                    ),
                  ),
                ),
                if (query.isNotEmpty)
                  GestureDetector(
                    onTap: onClear,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(Icons.close, size: 14, color: saffron),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// _FamilyHeaderDelegate — sticky pinned header w/ blur
// ============================================================
class _FamilyHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FamilyHeaderDelegate({
    required this.family,
    required this.isDark,
    required this.height,
  });

  final _Family family;
  final bool isDark;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  bool shouldRebuild(_FamilyHeaderDelegate oldDelegate) =>
      oldDelegate.family != family ||
      oldDelegate.isDark != isDark ||
      oldDelegate.height != height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;
    final bgTint = isDark
        ? const Color.fromRGBO(15, 15, 15, 0.85)
        : const Color.fromRGBO(253, 250, 246, 0.9);

    // The built widget MUST fill the full `maxExtent`: a persistent header
    // whose child is shorter than maxExtent produces an invalid SliverGeometry
    // (layoutExtent > paintExtent) and the whole CustomScrollView refuses to
    // render — i.e. a blank Library page.
    return SizedBox.expand(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: ColoredBox(
            color: bgTint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        family.devaName,
                        style: TextStyle(
                          fontFamily: family.kind == _FamilyKind.tamil
                              ? Fonts.sans
                              : Fonts.deva,
                          fontSize: 22,
                          height: 1,
                          letterSpacing: 0.44,
                          color: saffron,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              family.englishLabel,
                              style: TextStyle(
                                fontFamily: Fonts.serif,
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.13,
                                color: text1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            family.metaLabel,
                            style: TextStyle(
                              fontFamily: Fonts.sans,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.98,
                              color: text3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: Text(
                          family.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: Fonts.serif,
                            fontStyle: FontStyle.italic,
                            fontSize: 12.5,
                            height: 1.5,
                            color: text2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content-width hairline — matches the 24 px gutter that
                // contains the title/subtitle/meta block.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(height: 1, color: divider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// _VedasGridSliver — 2×2 grid, 3:2 aspect (Sulba brick)
// ============================================================
class _VedasGridSliver extends StatelessWidget {
  const _VedasGridSliver({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 3 / 2,
        ),
        itemCount: _kVedas.length,
        itemBuilder: (context, i) {
          return _VedaCell(isDark: isDark, scripture: _kVedas[i]);
        },
      ),
    );
  }
}

class _VedaCell extends StatelessWidget {
  const _VedaCell({required this.isDark, required this.scripture});

  final bool isDark;
  final _Scripture scripture;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? DColors.surface : LColors.surface;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return GestureDetector(
      onTap: () => _openScripture(context, scripture.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: dividerSoft, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  scripture.devaName,
                  style: TextStyle(
                    fontFamily: Fonts.deva,
                    fontSize: 16,
                    height: 1.2,
                    color: cream,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scripture.englishName,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: text1,
                  ),
                ),
              ],
            ),
            Text(
              '${_indianFmtStatic(scripture.verseCount)}  ${scripture.unitLabel}',
              style: TextStyle(
                fontFamily: Fonts.sans,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.4,
                color: text3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// _ScriptureRow — flat row with 8 px family-color diamond glyph
// ============================================================
class _ScriptureRow extends StatelessWidget {
  const _ScriptureRow({
    required this.isDark,
    required this.scripture,
    required this.isLast,
    required this.family,
  });

  final bool isDark;
  final _Scripture scripture;
  final bool isLast;
  final _Family family;

  Color _glyphColor() {
    return switch (family.kind) {
      _FamilyKind.shruti => isDark ? DColors.saffron : LColors.saffron,
      _FamilyKind.itihasa ||
      _FamilyKind.purana ||
      _FamilyKind.dharmasastra =>
        isDark ? DColors.ironRed : LColors.ironRed,
      _FamilyKind.darshana =>
        isDark ? const Color(0xFFC9A467) : const Color(0xFFA47B30),
      _FamilyKind.tamil =>
        isDark ? const Color(0xFFB07642) : const Color(0xFF8B5226),
    };
  }

  @override
  Widget build(BuildContext context) {
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final saffron = isDark ? DColors.saffron : LColors.saffron;

    final isTamilScript = family.kind == _FamilyKind.tamil;

    // Align diamond + chevron with the English-line center per the mockup:
    // Hindi (17·1.2 = 20.4) + 3 gap + (English-line 15·1.25 = 18.75) / 2.
    // Glyph (12 h) lands at top inset 20.4 + 3 + (18.75 − 12) / 2 ≈ 27.
    // Chevron (14 h) lands at top inset 20.4 + 3 + (18.75 − 14) / 2 ≈ 26.
    const diamondSize = 12.0;
    const diamondTop = 27.0;
    const chevronTop = 26.0;

    return InkWell(
      onTap: () => _openScripture(context, scripture.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: diamondTop),
                  child: Transform.rotate(
                    angle: 0.785398,
                    child: Container(
                      width: diamondSize,
                      height: diamondSize,
                      color: _glyphColor(),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        scripture.devaName,
                        style: TextStyle(
                          fontFamily: isTamilScript ? Fonts.sans : Fonts.deva,
                          fontSize: isTamilScript ? 15 : 17,
                          height: 1.2,
                          letterSpacing: 0.085,
                          color: cream,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        scripture.englishName,
                        style: TextStyle(
                          fontFamily: Fonts.serif,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.075,
                          height: 1.25,
                          color: text1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontFamily: Fonts.sans,
                            // Outfit lacks the dot-below Tamil-romanisation
                            // letters (ḷ, ṟ) used in names like "Tiruvaḷḷuvar";
                            // fall back to Lora for the full IAST set.
                            fontFamilyFallback: const [Fonts.serif],
                            fontSize: 11,
                            height: 1.4,
                            color: text3,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '${_indianFmtStatic(scripture.verseCount)} ${scripture.unitLabel}',
                              style: TextStyle(
                                fontFamily: Fonts.serif,
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                                color: text2,
                              ),
                            ),
                            if (scripture.subdivision != null)
                              TextSpan(text: '  ·  ${scripture.subdivision}'),
                            if (scripture.versesRead > 0)
                              TextSpan(
                                text:
                                    '  ·  ${scripture.versesRead} verse${scripture.versesRead == 1 ? '' : 's'} read',
                                style: TextStyle(
                                  color: saffron,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: chevronTop),
                  child: _MockupChevron(
                    color: text3.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          // Content-width hairline — matches the 24 px gutter the row text
          // sits in, not the screen edges.
          if (!isLast)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(height: 1, color: dividerSoft),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// Diacritic-insensitive normalization for IAST + casefolding
// ============================================================
//
// "gi" should match "Gītā". Approach: strip every IAST combining-mark and the
// pre-composed diacritic letters down to their bare ASCII form, then casefold.
// We do the normalization on a per-codeunit basis (cheap) instead of pulling in
// a full Unicode NFD library, since the corpus is bounded and the substitution
// table is short.

const Map<String, String> _iastMap = {
  // Long vowels and macron-bearing vowels
  'ā': 'a', 'Ā': 'a',
  'ī': 'i', 'Ī': 'i',
  'ū': 'u', 'Ū': 'u',
  'ē': 'e', 'Ē': 'e',
  'ō': 'o', 'Ō': 'o',
  // Vocalic r / l
  'ṛ': 'r', 'Ṛ': 'r',
  'ṝ': 'r', 'Ṝ': 'r',
  'ḷ': 'l', 'Ḷ': 'l',
  'ḹ': 'l', 'Ḹ': 'l',
  // Anusvāra, visarga
  'ṃ': 'm', 'Ṃ': 'm',
  'ḥ': 'h', 'Ḥ': 'h',
  // Sibilants, retroflex, palatal
  'ś': 's', 'Ś': 's',
  'ṣ': 's', 'Ṣ': 's',
  'ṭ': 't', 'Ṭ': 't',
  'ḍ': 'd', 'Ḍ': 'd',
  'ṇ': 'n', 'Ṇ': 'n',
  'ñ': 'n', 'Ñ': 'n',
  'ṅ': 'n', 'Ṅ': 'n',
  // Tamil-romanisation extras
  'ṟ': 'r', 'Ṟ': 'r',
};

/// Lowercase ASCII fold of [s] for case- and diacritic-insensitive match.
String _foldDiacritics(String s) {
  final buf = StringBuffer();
  for (final ch in s.characters) {
    final mapped = _iastMap[ch];
    buf.write((mapped ?? ch).toLowerCase());
  }
  return buf.toString();
}

/// Finds [q] (already folded) in the folded form of [text] and returns the
/// index *in the original `text`*. -1 when no match.
int _foldedIndexOf(String text, String q) {
  if (q.isEmpty) return -1;
  // Build the folded form once + a parallel map: foldedIndex -> originalIndex.
  // Each original character maps to its first folded codeunit; the IAST table
  // is one-to-one so length stays equal.
  final originalIndex = <int>[];
  final folded = StringBuffer();
  var i = 0;
  for (final ch in text.characters) {
    final mapped = _iastMap[ch] ?? ch;
    for (final _ in mapped.toLowerCase().codeUnits) {
      originalIndex.add(i);
    }
    folded.write(mapped.toLowerCase());
    i += ch.length;
  }
  final hit = folded.toString().indexOf(q);
  if (hit < 0) return -1;
  return originalIndex[hit];
}

/// Length of the original-string span that corresponds to a folded match of
/// length [qLen] starting at original index [origIdx]. Walks character-by-
/// character so combined characters get included whole.
int _foldedSpanLength(String text, int origIdx, int qLen) {
  var consumed = 0;
  var taken = 0;
  for (final ch in text.substring(origIdx).characters) {
    if (consumed >= qLen) break;
    final mapped = _iastMap[ch] ?? ch;
    consumed += mapped.length;
    taken += ch.length;
  }
  return taken;
}

// ============================================================
// SearchResults — sliver list shown in place of family list
// ============================================================
class _SearchResultsSliver extends StatelessWidget {
  const _SearchResultsSliver({
    required this.isDark,
    required this.query,
    required this.onTap,
  });

  final bool isDark;
  final String query;
  final ValueChanged<String> onTap;

  List<_SearchMatch> _findMatches() {
    final q = _foldDiacritics(query);
    final out = <_SearchMatch>[];
    for (final family in _kFamilies) {
      final scriptures = family.kind == _FamilyKind.shruti
          ? [..._kVedas, _kMukhyaUpanishads]
          : family.scriptures;
      for (final s in scriptures) {
        final inEn = _foldDiacritics(s.englishName).contains(q);
        final inDeva = s.devaName.contains(query);
        final inAlias =
            s.aliases.any((a) => _foldDiacritics(a).contains(q));
        if (inEn || inDeva || inAlias) {
          out.add(_SearchMatch(scripture: s, family: family));
        }
      }
    }
    out.sort((a, b) {
      int score(_SearchMatch m) {
        final en = _foldDiacritics(m.scripture.englishName);
        if (en.startsWith(q)) return 0;
        if (en.contains(q)) return 1;
        if (m.scripture.devaName.contains(query)) return 2;
        return 3;
      }

      return score(a).compareTo(score(b));
    });
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final matches = _findMatches();
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;

    if (matches.isEmpty) {
      return SliverToBoxAdapter(
        child: _EmptyResults(query: query, isDark: isDark),
      );
    }

    return SliverList.builder(
      itemCount: matches.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
            child: Text(
              '${matches.length} ${matches.length == 1 ? 'RESULT' : 'RESULTS'}',
              style: TextStyle(
                fontFamily: Fonts.sans,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.2,
                color: text3,
              ),
            ),
          );
        }
        final m = matches[i - 1];
        return _SearchResultRow(
          match: m,
          query: query,
          saffron: saffron,
          text1: text1,
          text2: text2,
          text3: text3,
          divider: dividerSoft,
          onTap: () => onTap(m.scripture.id),
        );
      },
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({
    required this.match,
    required this.query,
    required this.saffron,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.divider,
    required this.onTap,
  });

  final _SearchMatch match;
  final String query;
  final Color saffron;
  final Color text1;
  final Color text2;
  final Color text3;
  final Color divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scripture = match.scripture;
    final family = match.family;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: divider, width: 1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              child: Text(
                scripture.devaName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: family.kind == _FamilyKind.tamil
                      ? Fonts.sans
                      : Fonts.deva,
                  fontSize: 14,
                  color: text3,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _highlighted(
                    scripture.englishName,
                    query.toLowerCase(),
                    saffron,
                    text1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${family.shortLabel}  ·  ${_indianFmtStatic(scripture.verseCount)} ${scripture.unitLabel.toUpperCase()}',
                    style: TextStyle(
                      fontFamily: Fonts.sans,
                      fontSize: 10,
                      letterSpacing: 1.6,
                      color: text3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _MockupChevron(color: text3.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  static Widget _highlighted(String text, String query, Color hl, Color base) {
    final baseStyle = TextStyle(
      fontFamily: Fonts.serif,
      fontSize: 14,
      color: base,
    );
    final hlStyle = baseStyle.copyWith(
      color: hl,
      fontWeight: FontWeight.w500,
    );
    if (query.isEmpty) return Text(text, style: baseStyle);

    final q = _foldDiacritics(query);
    final idx = _foldedIndexOf(text, q);
    if (idx < 0) return Text(text, style: baseStyle);
    final span = _foldedSpanLength(text, idx, q.length);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, idx), style: baseStyle),
          TextSpan(text: text.substring(idx, idx + span), style: hlStyle),
          TextSpan(text: text.substring(idx + span), style: baseStyle),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.query, required this.isDark});

  final String query;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final cream = isDark ? DColors.cream : LColors.text1;

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
          decoration: BoxDecoration(
            border: Border.all(
              color: cream.withValues(alpha: 0.15),
              width: 1,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(Radii.card),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '॥',
                style: TextStyle(
                  fontFamily: Fonts.deva,
                  fontSize: 28,
                  color: saffron,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'No scripture matches "$query"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: Fonts.serif,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  color: text1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try a different spelling — Devanāgarī or Roman both work.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: Fonts.serif,
                  fontSize: 13,
                  height: 1.5,
                  color: text2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Data — 6 families + scripture catalog
// ============================================================

String _indianFmtStatic(int n) => _ScriptureLibraryPageState._indianFormat(n);

enum _FamilyKind { shruti, itihasa, purana, darshana, dharmasastra, tamil }

class _Family {
  const _Family({
    required this.kind,
    required this.devaName,
    required this.englishLabel,
    required this.metaLabel,
    required this.description,
    required this.shortLabel,
    required this.scriptures,
  });

  final _FamilyKind kind;
  final String devaName;
  final String englishLabel;
  final String metaLabel;
  final String description;
  final String shortLabel;
  final List<_Scripture> scriptures;
}

class _Scripture {
  const _Scripture({
    required this.id,
    required this.devaName,
    required this.englishName,
    required this.verseCount,
    required this.unitLabel,
    this.subdivision,
    this.aliases = const [],
    this.versesRead = 0,
  });

  final String id;
  final String devaName;
  final String englishName;
  final int verseCount;
  final String unitLabel; // verses / mantras / sūtras / couplets
  final String? subdivision; // e.g. "18 chapters", "7 kāṇḍas"
  final List<String> aliases;
  final int versesRead;
}

class _SearchMatch {
  const _SearchMatch({required this.scripture, required this.family});
  final _Scripture scripture;
  final _Family family;
}

const _kVedas = <_Scripture>[
  _Scripture(
    id: 'rigveda',
    devaName: 'ऋग्वेद',
    englishName: 'Ṛg Veda',
    verseCount: 10552,
    unitLabel: 'mantras',
    aliases: ['rig', 'rigveda'],
  ),
  _Scripture(
    id: 'samaveda',
    devaName: 'सामवेद',
    englishName: 'Sāma Veda',
    verseCount: 1875,
    unitLabel: 'mantras',
    aliases: ['sama', 'samaveda'],
  ),
  _Scripture(
    id: 'yajurveda',
    devaName: 'यजुर्वेद',
    englishName: 'Yajur Veda',
    verseCount: 1975,
    unitLabel: 'mantras',
    aliases: ['yajur', 'yajurveda'],
  ),
  _Scripture(
    id: 'atharvaveda',
    devaName: 'अथर्ववेद',
    englishName: 'Atharva Veda',
    verseCount: 5977,
    unitLabel: 'mantras',
    aliases: ['atharva', 'atharvaveda'],
  ),
];

const _kMukhyaUpanishads = _Scripture(
  // Routes to Isha Upanishad as the canonical entry-point until a dedicated
  // /library/upanishads collection page exists.
  id: 'isha_upanishad',
  devaName: 'मुख्य उपनिषद् ११',
  englishName: 'The Mukhya Upaniṣads',
  verseCount: 1876,
  unitLabel: 'verses',
  subdivision: '11 principal texts',
  aliases: ['upanishad', 'upanishads', 'mukhya'],
);

const _kFamilies = <_Family>[
  _Family(
    kind: _FamilyKind.shruti,
    devaName: 'श्रुति',
    englishLabel: 'Śruti — that which is heard',
    metaLabel: '5 TEXTS',
    shortLabel: 'ŚRUTI',
    description:
        'The earliest, eternal revelations — the Vedas and principal Upaniṣads.',
    scriptures: [], // Vedas grid + Mukhya row rendered separately
  ),
  _Family(
    kind: _FamilyKind.itihasa,
    devaName: 'इतिहास',
    englishLabel: 'Itihāsa — the great epics',
    metaLabel: '3 TEXTS',
    shortLabel: 'ITIHĀSA',
    description: 'Stories that happened — Rāma, the Pāṇḍavas, the Gītā within.',
    scriptures: [
      _Scripture(
        id: 'bhagavad_gita',
        devaName: 'भगवद्गीता',
        englishName: 'Bhagavad Gītā',
        verseCount: 700,
        unitLabel: 'verses',
        subdivision: '18 chapters',
        aliases: ['gita', 'geeta', 'bhagavad'],
        versesRead: 1,
      ),
      _Scripture(
        id: 'ramayana',
        devaName: 'रामायण',
        englishName: 'Rāmāyaṇa',
        verseCount: 18761,
        unitLabel: 'verses',
        subdivision: '7 kāṇḍas',
        aliases: ['rama', 'ramayana'],
      ),
      _Scripture(
        id: 'mahabharata',
        devaName: 'महाभारत',
        englishName: 'Mahābhārata',
        verseCount: 72770,
        unitLabel: 'verses',
        subdivision: '18 parvas',
        aliases: ['maha', 'mahabharata'],
      ),
    ],
  ),
  _Family(
    kind: _FamilyKind.purana,
    devaName: 'पुराण',
    englishLabel: 'Purāṇa — old tales of gods and worlds',
    metaLabel: '2 TEXTS',
    shortLabel: 'PURĀṆA',
    description: 'Cosmology, devotion, and the līlās of the divine.',
    scriptures: [
      _Scripture(
        id: 'bhagavata_purana',
        devaName: 'श्रीमद्भागवतम्',
        englishName: 'Bhāgavata Purāṇa',
        verseCount: 14031,
        unitLabel: 'verses',
        subdivision: '12 cantos',
        aliases: ['bhagavata', 'srimad'],
      ),
      _Scripture(
        id: 'vishnu_purana',
        devaName: 'विष्णुपुराण',
        englishName: 'Viṣṇu Purāṇa',
        verseCount: 6000,
        unitLabel: 'verses',
        subdivision: '6 aṁśas',
        aliases: ['vishnu'],
      ),
    ],
  ),
  _Family(
    kind: _FamilyKind.darshana,
    devaName: 'दर्शन',
    englishLabel: 'Darśana — philosophy in sūtra form',
    metaLabel: '2 TEXTS',
    shortLabel: 'DARŚANA',
    description:
        'The condensed teachings — yoga, vedānta, and the schools of thought.',
    scriptures: [
      _Scripture(
        id: 'yoga_sutras',
        devaName: 'योगसूत्र',
        englishName: 'Yoga Sūtras of Patañjali',
        verseCount: 195,
        unitLabel: 'sūtras',
        subdivision: '4 pādas',
        aliases: ['yoga', 'patanjali'],
      ),
      _Scripture(
        id: 'brahma_sutras',
        devaName: 'ब्रह्मसूत्र',
        englishName: 'Brahma Sūtras',
        verseCount: 555,
        unitLabel: 'sūtras',
        subdivision: '4 adhyāyas',
        aliases: ['brahma'],
      ),
    ],
  ),
  _Family(
    kind: _FamilyKind.dharmasastra,
    devaName: 'धर्मशास्त्र',
    englishLabel: 'Dharmaśāstra — codes of right living',
    metaLabel: '2 TEXTS',
    shortLabel: 'DHARMAŚĀSTRA',
    description:
        'Law, ethics, and the conduct of life across the four āśramas.',
    scriptures: [
      _Scripture(
        id: 'manusmriti',
        devaName: 'मनुस्मृति',
        englishName: 'Manusmṛti',
        verseCount: 2684,
        unitLabel: 'verses',
        subdivision: '12 chapters',
        aliases: ['manu'],
      ),
      _Scripture(
        id: 'arthashastra',
        devaName: 'अर्थशास्त्र',
        englishName: 'Arthaśāstra',
        verseCount: 5348,
        unitLabel: 'verses',
        subdivision: '15 books',
        aliases: ['artha', 'kautilya'],
      ),
    ],
  ),
  _Family(
    kind: _FamilyKind.tamil,
    devaName: 'தமிழ் சாஸ்திரம்',
    englishLabel: 'Tamil sacred corpus',
    metaLabel: '1 TEXT',
    shortLabel: 'TAMIL',
    description: 'The southern stream — ethics in couplets, devotion in song.',
    scriptures: [
      _Scripture(
        id: 'tirukkural',
        devaName: 'திருக்குறள்',
        englishName: 'Tirukkuṟaḷ',
        verseCount: 1330,
        unitLabel: 'couplets',
        subdivision: 'Tiruvaḷḷuvar',
        aliases: ['kural', 'tirukkural'],
      ),
    ],
  ),
];

// ============================================================
// _MockupChevron — 8×14 stroke chevron matching screen-03 SVG
// ============================================================
class _MockupChevron extends StatelessWidget {
  const _MockupChevron({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 8,
      height: 14,
      child: CustomPaint(painter: _MockupChevronPainter(color: color)),
    );
  }
}

class _MockupChevronPainter extends CustomPainter {
  const _MockupChevronPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    final path = Path()
      ..moveTo(1, 1)
      ..lineTo(7, 7)
      ..lineTo(1, 13);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_MockupChevronPainter old) => old.color != color;
}
