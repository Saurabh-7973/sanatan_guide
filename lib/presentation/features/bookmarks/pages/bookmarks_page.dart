import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sanatan_guide/core/utils/devanagari.dart';
import 'package:sanatan_guide/core/utils/nav_logger.dart';
import 'package:sanatan_guide/data/datasources/local/daos/bookmarks_dao.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmark_sort_provider.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
import 'package:sanatan_guide/presentation/shared/widgets/mockup_icons.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

class BookmarksPage extends ConsumerStatefulWidget {
  const BookmarksPage({super.key});

  @override
  ConsumerState<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends ConsumerState<BookmarksPage>
    with NavLoggerMixin<BookmarksPage> {
  @override
  String get screenName => 'BookmarksPage';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(enrichedBookmarksProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(intensity: 0.6),
          SafeArea(
            child: Column(
              children: [
                _TopBar(isDark: isDark),
                Expanded(
                  child: state.when(
                    loading: () => _LoadingBody(isDark: isDark),
                    error: (_, __) => Center(
                      child: ErrorStateWidget(
                        onRetry: () =>
                            ref.invalidate(enrichedBookmarksProvider),
                      ),
                    ),
                    data: (bookmarks) {
                      if (bookmarks.isEmpty) {
                        return _EmptyBody(isDark: isDark);
                      }
                      return _PopulatedBody(
                        bookmarks: bookmarks,
                        isDark: isDark,
                      );
                    },
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

// ─────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text1 = isDark ? DColors.text1 : LColors.text1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 14),
      child: Row(
        children: [
          IconButton(
            iconSize: 20,
            color: text1,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            icon: const MockupBackChevron(),
          ),
          const Spacer(),
          IconButton(
            iconSize: 18,
            color: text1,
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Pothī header
// ─────────────────────────────────────────────────────────────────────────

class _PothiHeader extends StatelessWidget {
  const _PothiHeader({
    required this.totalVerses,
    required this.scriptureCount,
    required this.isDark,
    this.metaShimmer = false,
  });

  final int totalVerses;
  final int scriptureCount;
  final bool isDark;
  final bool metaShimmer;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'पोथी',
                style: TextStyle(
                  fontFamily: Fonts.deva,
                  fontFamilyFallback: AppFontFallback.deva,
                  fontSize: 26,
                  height: 1,
                  letterSpacing: 0.005 * 26,
                  // Mockup `.pothi-deva` uses saffron, not cream — the
                  // Devanāgarī word is the saffron-highlighted anchor that
                  // sets the page's read tone.
                  color: saffron,
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Text(
                  'Your collection',
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.015 * 22,
                    height: 1,
                    color: text1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (totalVerses > 0 || metaShimmer) ...[
            const SizedBox(height: 12),
            if (metaShimmer)
              Container(
                width: 220,
                height: 10,
                decoration: BoxDecoration(
                  color: saffron.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(2),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 800.ms, begin: 0.5)
            else
              DefaultTextStyle(
                style: TextStyle(
                  fontFamily: Fonts.sans,
                  fontFamilyFallback: AppFontFallback.latin,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.16 * 11,
                  color: text3,
                ),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _italicNum('$totalVerses', saffron),
                    const Text('  VERSES SAVED'),
                    _Sep(saffron: saffron),
                    const Text('FROM '),
                    _italicNum('$scriptureCount', saffron),
                    const Text('  SCRIPTURES'),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _italicNum(String text, Color color) => Text(
        text,
        style: TextStyle(
          fontFamily: Fonts.serif,
          fontFamilyFallback: AppFontFallback.latin,
          fontStyle: FontStyle.italic,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: color,
        ),
      );
}

class _Sep extends StatelessWidget {
  const _Sep({required this.saffron});
  final Color saffron;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(color: saffron, shape: BoxShape.circle),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Sort bar
// ─────────────────────────────────────────────────────────────────────────

class _SortBar extends ConsumerWidget {
  const _SortBar({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;
    final sort = ref.watch(bookmarkSortProvider);

    Widget tab(String label, BookmarkSort value) {
      final active = sort == value;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref
            .read(bookmarkSortProvider.notifier)
            .select(value),
        child: Container(
          padding: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? saffron : Colors.transparent,
                width: 1.5,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontFamilyFallback: AppFontFallback.latin,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.16 * 11,
              color: active ? text1 : text3,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: divider, width: 1)),
      ),
      child: Row(
        children: [
          tab('RECENT', BookmarkSort.recent),
          const SizedBox(width: 18),
          tab('BY SCRIPTURE', BookmarkSort.byScripture),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Populated body
// ─────────────────────────────────────────────────────────────────────────

class _PopulatedBody extends ConsumerWidget {
  const _PopulatedBody({required this.bookmarks, required this.isDark});

  final List<EnrichedBookmark> bookmarks;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scriptureCount = bookmarks
        .map((b) => b.scriptureCode)
        .where((c) => c != null)
        .toSet()
        .length;
    final sort = ref.watch(bookmarkSortProvider);

    return Column(
      children: [
        _PothiHeader(
          totalVerses: bookmarks.length,
          scriptureCount: scriptureCount,
          isDark: isDark,
        ),
        _SortBar(isDark: isDark),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: sort == BookmarkSort.recent
                ? _RecentLeaves(
                    key: const ValueKey('recent'),
                    bookmarks: bookmarks,
                    isDark: isDark,
                  )
                : _GroupedLeaves(
                    key: const ValueKey('grouped'),
                    bookmarks: bookmarks,
                    isDark: isDark,
                  ),
          ),
        ),
      ],
    );
  }
}

class _RecentLeaves extends StatelessWidget {
  const _RecentLeaves({
    super.key,
    required this.bookmarks,
    required this.isDark,
  });

  final List<EnrichedBookmark> bookmarks;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: bookmarks.length,
      itemBuilder: (context, i) {
        final entry = _resolveEntry(bookmarks[i]);
        return _LeafCard(
          bookmark: bookmarks[i],
          entry: entry,
          showShortCode: true,
          isDark: isDark,
        )
            .animate(delay: Duration(milliseconds: 25 * (i.clamp(0, 5))))
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.02, end: 0, duration: 350.ms);
      },
    );
  }
}

class _GroupedLeaves extends StatelessWidget {
  const _GroupedLeaves({
    super.key,
    required this.bookmarks,
    required this.isDark,
  });

  final List<EnrichedBookmark> bookmarks;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final groups = <Scripture, List<EnrichedBookmark>>{};
    for (final b in bookmarks) {
      final s = _scriptureFromCode(b.scriptureCode);
      if (s == null) continue;
      groups.putIfAbsent(s, () => []).add(b);
    }
    final ordered = groups.entries.toList()
      ..sort((a, b) {
        final c = b.value.length.compareTo(a.value.length);
        if (c != 0) return c;
        return b.value.first.savedAt.compareTo(a.value.first.savedAt);
      });

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final entry in ordered) ...[
          _GroupHeader(scripture: entry.key, count: entry.value.length, isDark: isDark),
          for (final b in entry.value)
            _LeafCard(
              bookmark: b,
              entry: _resolveEntry(b),
              showShortCode: false,
              isDark: isDark,
            ),
        ],
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.scripture,
    required this.count,
    required this.isDark,
  });

  final Scripture scripture;
  final int count;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    // Mockup `.group-header`: padding 26 24 8, no border-bottom, deva size
    // 16 in saffron, en in serif italic text-2 12, count sans 9.5 0.24em
    // uppercase text-3. The old version added a divider line which the
    // mockup explicitly omits — user flagged the extra rule.
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: scripture.devaName,
                  style: TextStyle(
                    fontFamily: Fonts.deva,
                    fontFamilyFallback: AppFontFallback.deva,
                    fontSize: 16,
                    height: 1,
                    color: saffron,
                  ),
                ),
                const TextSpan(text: '   '),
                TextSpan(
                  text: scripture.displayName,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: text2,
                  ),
                ),
              ]),
            ),
          ),
          Text(
            '$count VERSES',
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontFamilyFallback: AppFontFallback.latin,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.24 * 9.5,
              color: text3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Leaf card
// ─────────────────────────────────────────────────────────────────────────

class _LeafCard extends StatelessWidget {
  const _LeafCard({
    required this.bookmark,
    required this.entry,
    required this.showShortCode,
    required this.isDark,
  });

  final EnrichedBookmark bookmark;
  final _LeafEntry entry;
  final bool showShortCode;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final surface = isDark ? DColors.surface : LColors.surface;
    final divider = isDark ? DColors.divider : LColors.divider;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;

    // Personal note — the same `verses.note_text` the verse detail screen
    // writes; a note saved while reading now shows on its bookmark.
    final note = bookmark.noteText;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          splashColor: Colors.transparent,
          highlightColor: saffron.withValues(alpha: 0.04),
          onTap: () =>
              context.push('/browse/${entry.scriptureCode}/verse/${bookmark.verseId}'),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: -10,
                  child: _LeafBinding(divider: divider, saffron: saffron),
                ),
                // Inset the knot 4 px from the right so the rotated diamond
                // doesn't clip against the card's 4-px borderRadius corner —
                // the user reported the right diamond reading "half-cut".
                Positioned(
                  top: -2,
                  right: 4,
                  child: _KnotMark(saffron: saffron),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Per screen-07 mockup `.leaf-coord`: Devanāgarī coord in
                    // cream + the rest of the meta line (BG · CHAPTER 2) in
                    // saffron, sans, uppercase, 0.24em tracking. Was a flat
                    // text3 line before — read as muted noise.
                    _LeafCoordLine(
                      coordDeva: entry.coordPartsDeva.isEmpty
                          ? '—'
                          : entry.coordPartsDeva.join('·'),
                      shortCode: showShortCode ? entry.shortCode : '',
                      unitLabel: entry.unitLabel,
                      saffron: saffron,
                      cream: cream,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      entry.sanskritPreview,
                      style: TextStyle(
                        fontFamily: Fonts.deva,
                        fontFamilyFallback: AppFontFallback.deva,
                        fontSize: 16,
                        height: 1.55,
                        letterSpacing: 0.005 * 16,
                        color: cream,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entry.englishPreview != null &&
                        entry.englishPreview!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        '"${entry.englishPreview}"',
                        style: TextStyle(
                          fontFamily: Fonts.serif,
                          fontFamilyFallback: AppFontFallback.latin,
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                          height: 1.45,
                          color: text2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (note != null) ...[
                      const SizedBox(height: 14),
                      // Mockup `.leaf-note`: 1px dashed top border (not
                      // solid), saffron pencil glyph @ 60% opacity, text-1
                      // italic body — was a solid divider + Material edit
                      // icon before.
                      _DashedTopRule(color: dividerSoft),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Opacity(
                              opacity: 0.6,
                              child: SizedBox(
                                width: 11,
                                height: 11,
                                child: CustomPaint(
                                  painter: _LeafNotePencilPainter(color: saffron),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              note,
                              style: TextStyle(
                                fontFamily: Fonts.serif,
                                fontFamilyFallback: AppFontFallback.latin,
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                                height: 1.5,
                                color: text1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Per mockup `.scripture-glyph`: 5×5 saffron
                            // circle (border-radius:50%), not a rotated
                            // square. Keeps the footer typographically
                            // distinct from the leaf-binding diamond.
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: saffron,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.scriptureName.toUpperCase(),
                              style: TextStyle(
                                fontFamily: Fonts.sans,
                                fontFamilyFallback: AppFontFallback.latin,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.14 * 9.5,
                                color: text3,
                              ),
                            ),
                          ],
                        ),
                        if (showShortCode)
                          Text(
                            _relativeDate(bookmark.savedAt),
                            style: TextStyle(
                              fontFamily: Fonts.sans,
                              fontFamilyFallback: AppFontFallback.latin,
                              fontSize: 10.5,
                              letterSpacing: 0.04 * 10.5,
                              color: text3,
                            ),
                          )
                        else
                          Text(
                            'Saved ${_relativeDate(bookmark.savedAt).toLowerCase()}',
                            style: TextStyle(
                              fontFamily: Fonts.sans,
                              fontFamilyFallback: AppFontFallback.latin,
                              fontSize: 10.5,
                              letterSpacing: 0.04 * 10.5,
                              color: text3,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 1-px dashed top rule for the leaf-note section.
class _DashedTopRule extends StatelessWidget {
  const _DashedTopRule({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(painter: _BookmarkDashedPainter(color: color)),
    );
  }
}

class _BookmarkDashedPainter extends CustomPainter {
  const _BookmarkDashedPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    const dash = 3.0;
    const gap = 3.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_BookmarkDashedPainter old) => old.color != color;
}

/// Mockup `.leaf-note-icon` glyph: 11×11 viewBox, pencil/quill path,
/// 1.2-px stroke, rounded joins. SVG path: M2 9l1.5-1.5L8 3 9.5 1.5l-1-1L7 2 2.5 6.5 1 8l1 1z.
class _LeafNotePencilPainter extends CustomPainter {
  const _LeafNotePencilPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 11.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * u
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(2 * u, 9 * u)
      ..lineTo(3.5 * u, 7.5 * u)
      ..lineTo(8 * u, 3 * u)
      ..lineTo(9.5 * u, 1.5 * u)
      ..lineTo(8.5 * u, 0.5 * u)
      ..lineTo(7 * u, 2 * u)
      ..lineTo(2.5 * u, 6.5 * u)
      ..lineTo(1 * u, 8 * u)
      ..lineTo(2 * u, 9 * u)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LeafNotePencilPainter old) => old.color != color;
}

/// Saffron `.leaf-coord` meta line. Devanāgarī coord (`२·४७`) sits in cream;
/// `· BG · CHAPTER 2` follows in saffron, sans, 0.24em tracking, 9.5 px.
class _LeafCoordLine extends StatelessWidget {
  const _LeafCoordLine({
    required this.coordDeva,
    required this.shortCode,
    required this.unitLabel,
    required this.saffron,
    required this.cream,
  });

  final String coordDeva;
  final String shortCode;
  final String unitLabel;
  final Color saffron;
  final Color cream;

  @override
  Widget build(BuildContext context) {
    final saffronStyle = TextStyle(
      fontFamily: Fonts.sans,
      fontFamilyFallback: AppFontFallback.latin,
      fontSize: 9.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.24 * 9.5,
      color: saffron,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: coordDeva,
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontFamilyFallback: AppFontFallback.deva,
              fontSize: 11,
              height: 1.0,
              color: cream,
              letterSpacing: 0,
            ),
          ),
          if (shortCode.isNotEmpty)
            TextSpan(text: '  ·  $shortCode', style: saffronStyle),
          TextSpan(text: '  ·  $unitLabel', style: saffronStyle),
        ],
      ),
    );
  }
}

class _LeafBinding extends StatelessWidget {
  const _LeafBinding({required this.divider, required this.saffron});
  final Color divider;
  final Color saffron;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: Row(
        children: [
          const SizedBox(width: 18),
          Expanded(child: Container(height: 1, color: divider)),
          const SizedBox(width: 10),
          Transform.rotate(
            angle: 0.785, // 45°
            child: Container(
              width: 5,
              height: 5,
              // Mockup `.leaf-binding .hole` colours the diamond saffron, not
              // divider — the saffron mark is what makes the row read as a
              // binding-hole rather than a hairline crack in the divider.
              color: saffron,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: divider)),
          const SizedBox(width: 18),
        ],
      ),
    );
  }
}

class _KnotMark extends StatelessWidget {
  const _KnotMark({required this.saffron});
  final Color saffron;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: Center(
        child: Transform.rotate(
          angle: 0.785,
          child: Container(
            width: 7,
            height: 7,
            color: saffron,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Empty + loading
// ─────────────────────────────────────────────────────────────────────────

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final divider = isDark ? DColors.divider : LColors.divider;

    return Column(
      children: [
        _PothiHeader(
          totalVerses: 0,
          scriptureCount: 0,
          isDark: isDark,
        ),
        const Spacer(),
        SizedBox(
          width: 120,
          height: 100,
          child: CustomPaint(
            painter: _ThreeLeafPainter(thread: divider, leaf: saffron),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.04, end: 0, duration: 500.ms),
        const SizedBox(height: 28),
        Text(
          'Your pothī awaits',
          style: TextStyle(
            fontFamily: Fonts.serif,
            fontFamilyFallback: AppFontFallback.latin,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 1.3,
            color: cream,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Save a verse, and it joins your collection — like a leaf bound in your own bundle. Add a note about why it spoke to you.',
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontSize: 13,
              height: 1.55,
              color: text2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 28),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.go('/browse'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BEGIN READING',
                  style: TextStyle(
                    fontFamily: Fonts.sans,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.18 * 11,
                    color: saffron,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: saffron,
                ),
              ],
            ),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _ThreeLeafPainter extends CustomPainter {
  _ThreeLeafPainter({required this.thread, required this.leaf});
  final Color thread;
  final Color leaf;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = Offset(size.width / 2, size.height / 2);
    final threadPaint = Paint()
      ..color = thread
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(mid.dx, 4),
      Offset(mid.dx, size.height - 4),
      threadPaint,
    );

    void drawLeaf(double yFrac, double angle, double scale) {
      final cy = size.height * yFrac;
      canvas.save();
      canvas.translate(mid.dx, cy);
      canvas.rotate(angle);
      final leafPaint = Paint()
        ..color = leaf.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill;
      final w = 36 * scale;
      final h = 14 * scale;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        Radius.circular(h / 2),
      );
      canvas.drawRRect(rect, leafPaint);
      // central diamond hole
      canvas.drawCircle(
        Offset.zero,
        2,
        Paint()..color = thread,
      );
      canvas.restore();
    }

    drawLeaf(0.25, -0.18, 1.0);
    drawLeaf(0.55, 0.12, 1.0);
    drawLeaf(0.82, -0.09, 1.0);
  }

  @override
  bool shouldRepaint(covariant _ThreeLeafPainter oldDelegate) =>
      oldDelegate.thread != thread || oldDelegate.leaf != leaf;
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final divider = isDark ? DColors.divider : LColors.divider;
    final surface = isDark ? DColors.surface : LColors.surface;
    final shimmer = saffron.withValues(alpha: 0.08);

    return Column(
      children: [
        _PothiHeader(
          totalVerses: 0,
          scriptureCount: 0,
          isDark: isDark,
          metaShimmer: true,
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: divider, width: 1)),
          ),
          child: Row(
            children: [
              Text(
                'RECENT',
                style: TextStyle(
                  fontFamily: Fonts.sans,
                  fontFamilyFallback: AppFontFallback.latin,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.16 * 11,
                  color: isDark ? DColors.text1 : LColors.text1,
                ),
              ),
              const SizedBox(width: 18),
              Text(
                'BY SCRIPTURE',
                style: TextStyle(
                  fontFamily: Fonts.sans,
                  fontFamilyFallback: AppFontFallback.latin,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.16 * 11,
                  color: isDark ? DColors.text3 : LColors.text3,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: 3,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: -10,
                      child: _LeafBinding(divider: divider, saffron: saffron),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        _bar(150, 9, shimmer),
                        const SizedBox(height: 12),
                        _bar(double.infinity, 14, shimmer, fraction: 0.9),
                        const SizedBox(height: 8),
                        _bar(double.infinity, 11, shimmer, fraction: 0.8),
                        const SizedBox(height: 4),
                        _bar(double.infinity, 11, shimmer, fraction: 0.6),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bar(double width, double height, Color color, {double? fraction}) {
    final core = Container(
      height: height,
      width: fraction == null ? width : null,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 800.ms, begin: 0.5);
    if (fraction != null) {
      return FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fraction,
        child: core,
      );
    }
    return core;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────

class _LeafEntry {
  const _LeafEntry({
    required this.scripture,
    required this.scriptureCode,
    required this.scriptureName,
    required this.shortCode,
    required this.unitLabel,
    required this.coordPartsDeva,
    required this.sanskritPreview,
    required this.englishPreview,
  });

  final Scripture? scripture;
  final String scriptureCode;
  final String scriptureName;
  final String shortCode;
  final String unitLabel;
  final List<String> coordPartsDeva;
  final String sanskritPreview;
  final String? englishPreview;
}

_LeafEntry _resolveEntry(EnrichedBookmark b) {
  Scripture? scripture;
  try {
    if (b.scriptureCode != null) {
      scripture = ScriptureX.fromCode(b.scriptureCode!);
    }
  } on ArgumentError {
    scripture = null;
  }
  final coordParts = <int>[
    if (b.bookNum != null) b.bookNum!,
    if (b.chapterNum != null) b.chapterNum!,
    if (b.verseNum != null) b.verseNum!,
  ];
  final sanskrit = b.sanskritPreview?.split('\n').first.trim() ?? '';
  final english = b.englishPreview?.split('\n').first.trim();
  final unitName = _unitNameFor(scripture);
  final unitNum = b.bookNum ?? b.chapterNum ?? 0;
  return _LeafEntry(
    scripture: scripture,
    scriptureCode: b.scriptureCode ?? 'bhagavad_gita',
    scriptureName: scripture?.displayName ?? 'Scripture',
    shortCode: scripture?.shortCode ?? '',
    unitLabel: unitNum > 0
        ? '$unitName $unitNum'.toUpperCase()
        : unitName.toUpperCase(),
    coordPartsDeva: coordParts.map(arabicToDevanagari).toList(),
    sanskritPreview: sanskrit.isEmpty ? '—' : sanskrit,
    englishPreview: (english == null || english.isEmpty) ? null : english,
  );
}

/// Singular form of the scripture's unit (Chapter, Canto, Maṇḍala, …).
String _unitNameFor(Scripture? s) {
  if (s == null) return 'Chapter';
  return switch (s.unitLabel) {
    'cantos' => 'Skanda',
    'maṇḍalas' => 'Maṇḍala',
    'kāṇḍas' => 'Kāṇḍa',
    'pādas' => 'Pāda',
    'upadeśas' => 'Upadeśa',
    'adhyāyas' => 'Adhyāya',
    'parvas' => 'Parva',
    _ => 'Chapter',
  };
}

Scripture? _scriptureFromCode(String? code) {
  if (code == null) return null;
  try {
    return ScriptureX.fromCode(code);
  } on ArgumentError {
    return null;
  }
}

String _relativeDate(DateTime savedAt) {
  final now = DateTime.now();
  final diff = now.difference(savedAt);
  if (diff.inMinutes < 1) return 'JUST NOW';
  if (diff.inHours < 1) return '${diff.inMinutes} MIN AGO';
  if (diff.inHours < 24) return '${diff.inHours} HR AGO';
  if (diff.inDays == 1) return 'YESTERDAY';
  if (diff.inDays < 30) return '${diff.inDays} DAYS AGO';
  return DateFormat('d MMM yyyy').format(savedAt).toUpperCase();
}
