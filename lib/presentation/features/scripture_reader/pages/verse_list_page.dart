import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/constants/bhagavad_gita_chapters.dart';
import 'package:sanatan_guide/core/utils/devanagari.dart';
import 'package:sanatan_guide/core/utils/nav_logger.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_browser_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_progress_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/shared/widgets/mockup_icons.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

/// Returns the first line of [text] whose trimmed form is non-empty, or
/// an empty string if every line is blank. Useful when the canonical first
/// line is metadata / anuvāka heading and the actual content begins on the
/// second line (some Ṛgveda / Atharvaveda rows look like that).
String _firstNonBlankLine(String text) {
  for (final line in text.split('\n')) {
    final t = line.trim();
    if (t.isNotEmpty) return t;
  }
  return '';
}

class VerseListPage extends ConsumerStatefulWidget {
  const VerseListPage({
    super.key,
    required this.scriptureId,
    required this.chapterNum,
    this.bookNum,
  });

  final String scriptureId;
  final int chapterNum;
  final int? bookNum;

  @override
  ConsumerState<VerseListPage> createState() => _VerseListPageState();
}

class _VerseListPageState extends ConsumerState<VerseListPage>
    with NavLoggerMixin<VerseListPage> {
  final _scrollController = ScrollController();
  int _verseCount = 0;

  @override
  String get screenName =>
      'VerseListPage(${widget.scriptureId} ch:${widget.chapterNum})';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Offset-based jump: GlobalKey + ensureVisible collides under SliverList
  // recycling on large lists (Rigveda M1 = 1,839 rows). Approximate jump
  // is good enough for the rail; user can scroll-tune from there.
  void _scrollToVerse(int verseNum) {
    if (!_scrollController.hasClients || _verseCount == 0) return;
    final pos = _scrollController.position;
    final fraction = ((verseNum - 1) / _verseCount).clamp(0.0, 1.0);
    final target = pos.maxScrollExtent * fraction;
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(
      chapterVersesProvider(
        widget.scriptureId,
        widget.chapterNum,
        widget.bookNum,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const MockupBackChevron(),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/library');
            }
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(intensity: 0.6),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.paddingOf(context).top,
              ),
              child: state.when(
                loading: () => _LoadingBody(
                  scriptureId: widget.scriptureId,
                  chapterNum: widget.chapterNum,
                  isDark: isDark,
                ),
                error: (_, __) => _ErrorBody(
                  scriptureId: widget.scriptureId,
                  chapterNum: widget.chapterNum,
                  bookNum: widget.bookNum,
                  isDark: isDark,
                ),
                data: (either) => either.fold(
                  (failure) => Center(
                    child: Text(
                      failure.message,
                      style: AppText.rowSub(
                        color: isDark ? DColors.text2 : LColors.text2,
                      ),
                    ),
                  ),
                  (verses) {
                    final sorted = [...verses]
                      ..sort((a, b) => a.verseNum.compareTo(b.verseNum));
                    _verseCount = sorted.length;
                    return _LoadedBody(
                      verses: sorted,
                      scriptureId: widget.scriptureId,
                      chapterNum: widget.chapterNum,
                      bookNum: widget.bookNum,
                      isDark: isDark,
                      scrollController: _scrollController,
                      onJump: _scrollToVerse,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Loaded body — header + resume + verse list (+ optional jumper)
// ─────────────────────────────────────────────────────────────────────────

class _LoadedBody extends ConsumerWidget {
  const _LoadedBody({
    required this.verses,
    required this.scriptureId,
    required this.chapterNum,
    required this.bookNum,
    required this.isDark,
    required this.scrollController,
    required this.onJump,
  });

  final List<Verse> verses;
  final String scriptureId;
  final int chapterNum;
  final int? bookNum;
  final bool isDark;
  final ScrollController scrollController;
  final void Function(int verseNum) onJump;

  Verse? get _nextUnread =>
      verses.firstWhereOrNull((v) => v.readCount == 0);

  /// Decade-style section grouping for long chapters. ≤10 verses gets a single
  /// "ALL VERSES" label; bigger chapters get "Verses N — M" headers per group.
  /// Group size scales so we don't end up with 184 sub-headers on Ṛgveda M1.
  int get _groupSize {
    final n = verses.length;
    if (n <= 200) return 10;
    if (n <= 500) return 25;
    return 50;
  }

  List<Widget> _buildListSlivers() {
    if (verses.length <= 10) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(child: _VersesLabel(isDark: isDark)),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList.builder(
            itemCount: verses.length,
            itemBuilder: (context, i) => _verseTile(verses[i], i),
          ),
        ),
      ];
    }

    final size = _groupSize;
    final lastVerseNum = verses.last.verseNum;
    final entries = <_ListItem>[];
    var currentGroup = -1;
    for (var i = 0; i < verses.length; i++) {
      final v = verses[i];
      final group = (v.verseNum - 1) ~/ size;
      if (group != currentGroup) {
        final start = group * size + 1;
        // Clamp the decade's end to the actual last verse, so Karma Yoga
        // (43 verses) shows "VERSES 41 — 43" instead of "41 — 50".
        final end = ((group + 1) * size).clamp(start, lastVerseNum);
        entries.add(_HeaderItem(start, end));
        currentGroup = group;
      }
      entries.add(_VerseItem(v, i));
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList.builder(
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e = entries[i];
            return switch (e) {
              _HeaderItem(:final start, :final end) => _VerseSectionHeader(
                  start: start,
                  end: end,
                  isDark: isDark,
                ),
              _VerseItem(:final verse, :final index) =>
                _verseTile(verse, index),
            };
          },
        ),
      ),
    ];
  }

  Widget _verseTile(Verse v, int orderIndex) {
    final row = KeyedSubtree(
      key: ValueKey<int>(v.verseNum),
      child: _VerseRow(
        verse: v,
        scriptureId: scriptureId,
        isDark: isDark,
      ),
    );
    if (orderIndex < 10) {
      return row
          .animate(delay: Duration(milliseconds: 40 + 20 * orderIndex))
          .fadeIn(duration: 350.ms)
          .slideY(begin: 0.02, end: 0, duration: 350.ms);
    }
    return row;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readCount =
        ref.watch(chapterReadCountProvider(scriptureId, chapterNum, bookNum));
    final read = readCount.value ?? 0;
    final total = verses.length;
    final next = _nextUnread;
    final showJumper = total >= 40;

    return Stack(
      children: [
        // SliverList.builder lazily builds rows as they scroll into view.
        // Eager ListView(children: List.generate(verses.length, ...)) was
        // building 1,839 _VerseRow widgets + 1,839 .animate() controllers
        // upfront for Rigveda Maṇḍala 1, which hung the build and rendered
        // a blank "ALL VERSES" page.
        CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _ChapterHeader(
                scriptureId: scriptureId,
                chapterNum: chapterNum,
                read: read,
                total: total,
                isDark: isDark,
              ),
            ),
            if (next != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                  child: _ResumeAnchor(
                    scriptureId: scriptureId,
                    verse: next,
                    isDark: isDark,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            // Section breakdown: very long chapters interleave decade headers
            // ("Verses 11 — 20" + ‖११–२०‖) instead of a single ALL VERSES rule.
            ..._buildListSlivers(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
        if (showJumper)
          Positioned(
            right: 8,
            top: 70,
            bottom: 30,
            width: 140,
            child: _VerseJumper(
              verseCount: total,
              isDark: isDark,
              scrollController: scrollController,
              onTap: onJump,
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({
    required this.scriptureId,
    required this.chapterNum,
    required this.read,
    required this.total,
    required this.isDark,
  });

  final String scriptureId;
  final int chapterNum;
  final int read;
  final int total;
  final bool isDark;

  String? _devaTitle() {
    if (scriptureId == 'bhagavad_gita') {
      return BhagavadGitaChapters.byNumber(chapterNum).sanskritName;
    }
    return null;
  }

  String? _englishTitle() {
    if (scriptureId == 'bhagavad_gita') {
      return BhagavadGitaChapters.byNumber(chapterNum).englishName;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cream = isDark ? DColors.cream : LColors.text1;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final scripture = ScriptureX.fromCode(scriptureId);
    final percent = total > 0 ? ((read / total) * 100).floor() : 0;
    final deva = _devaTitle();
    final en = _englishTitle();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  deva ?? scripture.displayName,
                  style: TextStyle(
                    fontFamily: Fonts.deva,
                    fontSize: 18,
                    // 1.1 clipped the Devanāgarī top mātrā on the chapter
                    // title; Devanāgarī needs a taller line box.
                    height: 1.4,
                    letterSpacing: 0.005 * 18,
                    color: cream,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'CH $chapterNum · ${scripture.shortCode}',
                style: TextStyle(
                  fontFamily: Fonts.sans,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.22 * 9.5,
                  color: saffron,
                ),
              ),
            ],
          ),
          if (en != null) ...[
            const SizedBox(height: 6),
            Text(
              en,
              style: TextStyle(
                fontFamily: Fonts.serif,
                fontStyle: FontStyle.italic,
                fontSize: 13,
                color: text2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (read > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: SizedBox(
                height: 1.5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: dividerSoft),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: total > 0 ? read / total : 0,
                      child: Container(color: saffron),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$read',
                        style: TextStyle(color: saffron),
                      ),
                      TextSpan(
                        text: '  OF $total READ',
                        style: TextStyle(color: text3),
                      ),
                    ],
                    style: const TextStyle(
                      fontFamily: Fonts.sans,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.18 * 9,
                    ),
                  ),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontFamily: Fonts.sans,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.18 * 9,
                    color: text3,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Resume anchor (next unread verse)
// ─────────────────────────────────────────────────────────────────────────

class _ResumeAnchor extends StatelessWidget {
  const _ResumeAnchor({
    required this.scriptureId,
    required this.verse,
    required this.isDark,
  });

  final String scriptureId;
  final Verse verse;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final divider = isDark ? DColors.divider : LColors.divider;
    final gradStart = saffron.withValues(alpha: isDark ? 0.07 : 0.06);
    final gradMid = saffron.withValues(alpha: isDark ? 0.02 : 0.015);

    final rawIncipit = verse.sanskrit.split('\n').first.trim();
    // Empty Sanskrit shouldn't happen in practice (the field is required on
    // Verse), but guard the resume card so it doesn't render a blank row if
    // a verse upstream is mid-digitization.
    final incipit = rawIncipit.isNotEmpty ? rawIncipit : '—';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        splashColor: Colors.transparent,
        highlightColor: saffron.withValues(alpha: 0.04),
        onTap: () => context.push('/browse/$scriptureId/verse/${verse.id}'),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: divider, width: 1),
            gradient: LinearGradient(
              colors: [gradStart, gradMid, Colors.transparent],
              stops: const [0, 0.6, 1],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -20,
                top: 10,
                bottom: 10,
                child: LeafThread(isDark: isDark, pulseOnce: true),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CONTINUE',
                          style: TextStyle(
                            fontFamily: Fonts.sans,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.24 * 9,
                            color: saffron,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          incipit,
                          style: TextStyle(
                            fontFamily: Fonts.deva,
                            fontSize: 14,
                            height: 1.3,
                            color: cream,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Verse ${verse.verseNum} — next unread',
                          style: TextStyle(
                            fontFamily: Fonts.sans,
                            fontSize: 10.5,
                            color: text2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  MockupResumeArrow(color: saffron.withValues(alpha: 0.7)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Verses section label
// ─────────────────────────────────────────────────────────────────────────

class _VersesLabel extends StatelessWidget {
  const _VersesLabel({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: divider, width: 1)),
      ),
      child: Text(
        'ALL VERSES',
        style: TextStyle(
          fontFamily: Fonts.sans,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.28 * 9.5,
          color: text3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Sub-section header — "Verses 11 — 20" + ‖११–२०‖ for long chapters
// ─────────────────────────────────────────────────────────────────────────

sealed class _ListItem {
  const _ListItem();
}

class _HeaderItem extends _ListItem {
  const _HeaderItem(this.start, this.end);
  final int start;
  final int end;
}

class _VerseItem extends _ListItem {
  const _VerseItem(this.verse, this.index);
  final Verse verse;
  final int index;
}

class _VerseSectionHeader extends StatelessWidget {
  const _VerseSectionHeader({
    required this.start,
    required this.end,
    required this.isDark,
  });

  final int start;
  final int end;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final cream = isDark ? DColors.cream : LColors.text1;
    final divider = isDark ? DColors.divider : LColors.divider;
    final devaRange =
        '‖${arabicToDevanagari(start)}–${arabicToDevanagari(end)}‖';
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: divider, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'VERSES $start — $end',
              style: TextStyle(
                fontFamily: Fonts.sans,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.32 * 9,
                color: saffron,
              ),
            ),
          ),
          Text(
            devaRange,
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontSize: 13,
              height: 1.0,
              color: cream,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Verse row
// ─────────────────────────────────────────────────────────────────────────

class _VerseRow extends ConsumerWidget {
  const _VerseRow({
    required this.verse,
    required this.scriptureId,
    required this.isDark,
  });

  final Verse verse;
  final String scriptureId;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;

    final isRead = verse.readCount > 0;
    final allBookmarks = ref.watch(bookmarkedIdsProvider).value ?? const {};
    final isBookmarked = allBookmarks.contains(verse.id);

    final dandaColor = isRead && !isBookmarked ? text3 : saffron;
    final sanskritColor = isRead ? text2 : cream;

    // Pick the first non-blank Sanskrit line — some verses store a meta /
    // anuvāka header on the first line and the actual mantra on the second.
    final skLine = _firstNonBlankLine(verse.sanskrit);
    final enLine = _firstNonBlankLine(verse.english ?? '');
    // When Sanskrit isn't available, surface the translation as the primary
    // line (two lines, serif italic) instead of rendering an em-dash with a
    // cramped one-line preview below it.
    final translationOnly = skLine.isEmpty && enLine.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: saffron.withValues(alpha: 0.04),
        onTap: () => context.push('/browse/$scriptureId/verse/${verse.id}'),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 11, 0, 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: dividerSoft, width: 1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 42,
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: DandaCoord.multipart(
                    parts: [verse.verseNum],
                    isDark: isDark,
                    fontSize: 13,
                    colorOverride: dandaColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: translationOnly
                    ? Text(
                        enLine,
                        style: TextStyle(
                          fontFamily: Fonts.serif,
                          fontStyle: FontStyle.italic,
                          fontSize: 13.5,
                          height: 1.45,
                          color: sanskritColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            skLine,
                            style: TextStyle(
                              fontFamily: Fonts.deva,
                              fontSize: 14.5,
                              height: 1.4,
                              letterSpacing: 0.005 * 14.5,
                              color: sanskritColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (enLine.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              enLine,
                              style: TextStyle(
                                fontFamily: Fonts.serif,
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                                height: 1.4,
                                color: text3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 14,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _VerseStateGlyph(
                    isRead: isRead,
                    isBookmarked: isBookmarked,
                    saffron: saffron,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerseStateGlyph extends StatelessWidget {
  const _VerseStateGlyph({
    required this.isRead,
    required this.isBookmarked,
    required this.saffron,
  });

  final bool isRead;
  final bool isBookmarked;
  final Color saffron;

  @override
  Widget build(BuildContext context) {
    if (isBookmarked) {
      return Icon(Icons.bookmark_rounded, size: 14, color: saffron);
    }
    if (isRead) {
      return Icon(Icons.check_rounded, size: 14, color: saffron);
    }
    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Verse jumper (sticky right)
// ─────────────────────────────────────────────────────────────────────────

class _VerseJumper extends StatefulWidget {
  const _VerseJumper({
    required this.verseCount,
    required this.isDark,
    required this.scrollController,
    required this.onTap,
  });

  final int verseCount;
  final bool isDark;
  final ScrollController scrollController;
  final void Function(int verseNum) onTap;

  @override
  State<_VerseJumper> createState() => _VerseJumperState();
}

class _VerseJumperState extends State<_VerseJumper> {
  int? _activeIndex;
  int? _activeVerse; // verse number under the finger (interpolated).
  double? _dragY; // localY of last drag — drives the tooltip y-position.
  // Visible while scrolling or actively dragging the rail; fades out after
  // 1.4 s of idle. Mirrors the "scrollbar appears on scroll only" pattern.
  bool _visible = false;
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _idleTimer?.cancel();
    super.dispose();
  }

  void _onScroll() => _bumpVisibility();

  // Surface the rail on any interaction and tear it back down after idle.
  // Mirrors iOS-style scrollbars: visible only while in use.
  void _bumpVisibility() {
    if (!_visible) {
      setState(() => _visible = true);
    }
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _visible = false;
        _activeIndex = null;
        _activeVerse = null;
        _dragY = null;
      });
    });
  }


  int get _step {
    if (widget.verseCount >= 500) return 50;
    if (widget.verseCount >= 200) return 20;
    return 10;
  }

  List<int> get _markers {
    final step = _step;
    final raw = <int>[1];
    var n = step;
    while (n <= widget.verseCount && raw.length < 8) {
      raw.add(n);
      n += step;
    }
    return raw;
  }

  void _hit(double localY, double height, List<int> markers) {
    if (markers.isEmpty) return;
    final clamped = localY.clamp(0.0, height);
    final ratio = height > 0 ? clamped / height : 0.0;
    final idx = (ratio * markers.length).floor().clamp(0, markers.length - 1);
    // Jump to the *interpolated* verse the finger is over, not the nearest
    // decade marker. Otherwise dragging shows ‖२६‖ in the tooltip but the
    // list snaps to verse 21 because that's the closest decade.
    final verse = (ratio * widget.verseCount)
        .round()
        .clamp(1, widget.verseCount);
    _bumpVisibility();
    setState(() {
      _dragY = clamped;
      _activeIndex = idx;
      _activeVerse = verse;
    });
    widget.onTap(verse);
  }

  @override
  Widget build(BuildContext context) {
    final surface = widget.isDark
        ? DColors.surface.withValues(alpha: _activeIndex != null ? 0.85 : 0.6)
        : LColors.surface.withValues(alpha: 0.85);
    final text3 = widget.isDark ? DColors.text3 : LColors.text3;
    final saffron = widget.isDark ? DColors.saffron : LColors.saffron;
    final markers = _markers;
    final dragging = _activeIndex != null && _dragY != null;
    final railWidth = dragging ? 26.0 : 22.0;

    return IgnorePointer(
      ignoring: !_visible,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: Duration(milliseconds: _visible ? 160 : 400),
        curve: Curves.easeOut,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    width: railWidth,
                    color: surface,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragStart: (d) => _hit(
                            d.localPosition.dy,
                            constraints.maxHeight,
                            markers,
                          ),
                          onVerticalDragUpdate: (d) => _hit(
                            d.localPosition.dy,
                            constraints.maxHeight,
                            markers,
                          ),
                          onVerticalDragEnd: (_) =>
                              setState(() => _activeIndex = null),
                          onTapDown: (d) => _hit(
                            d.localPosition.dy,
                            constraints.maxHeight,
                            markers,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              for (var i = 0; i < markers.length; i++)
                                _JumperLabel(
                                  text: arabicToDevanagari(markers[i]),
                                  active: _activeIndex == i,
                                  activeColor: saffron,
                                  idleColor: text3,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (dragging)
              Positioned(
                right: railWidth + 8,
                top: (_dragY! - 18).clamp(0.0, double.infinity),
                child: _JumperTooltip(
                  verseNum: _activeVerse ?? markers[_activeIndex!],
                  saffron: saffron,
                  isDark: widget.isDark,
                ),
              ),
          ],
        ),
      ),
    );
  }

}

class _JumperTooltip extends StatelessWidget {
  const _JumperTooltip({
    required this.verseNum,
    required this.saffron,
    required this.isDark,
  });
  final int verseNum;
  final Color saffron;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final inkText = isDark ? const Color(0xFF1A1208) : DColors.cream;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: saffron,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: saffron.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '‖${arabicToDevanagari(verseNum)}‖',
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: inkText,
            ),
          ),
        ),
        SizedBox(
          width: 8,
          height: 10,
          child: CustomPaint(painter: _TooltipNotchPainter(color: saffron)),
        ),
      ],
    );
  }
}

class _TooltipNotchPainter extends CustomPainter {
  const _TooltipNotchPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_TooltipNotchPainter old) => old.color != color;
}

class _JumperLabel extends StatelessWidget {
  const _JumperLabel({
    required this.text,
    required this.active,
    required this.activeColor,
    required this.idleColor,
  });

  final String text;
  final bool active;
  final Color activeColor;
  final Color idleColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: active ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: Fonts.deva,
            fontSize: 11,
            height: 1,
            fontWeight: active ? FontWeight.w500 : FontWeight.w400,
            color: active ? activeColor : idleColor,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Loading + error
// ─────────────────────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({
    required this.scriptureId,
    required this.chapterNum,
    required this.isDark,
  });

  final String scriptureId;
  final int chapterNum;
  final bool isDark;

  // Skeleton-row widths per spec frame: bars sized 70–90% / 65–85% to mimic
  // varied verse incipits rather than a uniform grey block.
  static const _bodyWidths = <(double, double)>[
    (0.90, 0.75),
    (0.65, 0.80),
    (0.85, 0.70),
    (0.80, 0.65),
    (0.70, 0.85),
    (0.75, 0.70),
  ];

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final shimmerColor = saffron.withValues(alpha: 0.08);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        _ChapterHeader(
          scriptureId: scriptureId,
          chapterNum: chapterNum,
          read: 0,
          total: 0,
          isDark: isDark,
        ),
        Opacity(
          opacity: 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _ShimmerBar(
                widthFraction: 1,
                height: 1.5,
                color: shimmerColor,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ShimmerBar(width: 80, height: 8, color: shimmerColor),
                  _ShimmerBar(width: 30, height: 8, color: shimmerColor),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _VersesLabel(isDark: isDark),
        for (final widths in _bodyWidths)
          _VerseRowSkeleton(
            color: shimmerColor,
            divider: dividerSoft,
            primary: widths.$1,
            secondary: widths.$2,
          ),
      ],
    );
  }
}

class _VerseRowSkeleton extends StatelessWidget {
  const _VerseRowSkeleton({
    required this.color,
    required this.divider,
    required this.primary,
    required this.secondary,
  });
  final Color color;
  final Color divider;
  final double primary;
  final double secondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 11, 0, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: divider, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBar(width: 38, height: 14, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBar(widthFraction: primary, height: 13, color: color),
                const SizedBox(height: 6),
                _ShimmerBar(
                  widthFraction: secondary,
                  height: 10,
                  color: color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({
    this.width,
    this.widthFraction,
    required this.height,
    required this.color,
  });
  final double? width;
  final double? widthFraction;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 800.ms, begin: 0.5);
    if (widthFraction == null) return bar;
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFraction,
      child: bar,
    );
  }
}

class _ErrorBody extends ConsumerWidget {
  const _ErrorBody({
    required this.scriptureId,
    required this.chapterNum,
    required this.bookNum,
    required this.isDark,
  });

  final String scriptureId;
  final int chapterNum;
  final int? bookNum;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorStateWidget(
      onRetry: () => ref.invalidate(
        chapterVersesProvider(scriptureId, chapterNum, bookNum),
      ),
    );
  }
}

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
