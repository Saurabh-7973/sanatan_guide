import 'dart:math' as math;

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
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

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
  final _verseRowKeys = <int, GlobalKey>{};

  @override
  String get screenName =>
      'VerseListPage(${widget.scriptureId} ch:${widget.chapterNum})';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToVerse(int verseNum) {
    final key = _verseRowKeys[verseNum];
    final ctx = key?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      alignment: 0.05,
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
          icon: const Icon(Icons.chevron_left_rounded),
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
                    return _LoadedBody(
                      verses: sorted,
                      scriptureId: widget.scriptureId,
                      chapterNum: widget.chapterNum,
                      bookNum: widget.bookNum,
                      isDark: isDark,
                      scrollController: _scrollController,
                      verseRowKeys: _verseRowKeys,
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
    required this.verseRowKeys,
    required this.onJump,
  });

  final List<Verse> verses;
  final String scriptureId;
  final int chapterNum;
  final int? bookNum;
  final bool isDark;
  final ScrollController scrollController;
  final Map<int, GlobalKey> verseRowKeys;
  final void Function(int verseNum) onJump;

  Verse? get _nextUnread =>
      verses.firstWhereOrNull((v) => v.readCount == 0);

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
        ListView(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _ChapterHeader(
              scriptureId: scriptureId,
              chapterNum: chapterNum,
              read: read,
              total: total,
              isDark: isDark,
            ),
            if (next != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                child: _ResumeAnchor(
                  scriptureId: scriptureId,
                  verse: next,
                  isDark: isDark,
                ),
              ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _VersesLabel(isDark: isDark),
            ),
            ...List.generate(verses.length, (i) {
              final v = verses[i];
              final key = verseRowKeys.putIfAbsent(v.verseNum, GlobalKey.new);
              return Padding(
                key: key,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _VerseRow(
                  verse: v,
                  scriptureId: scriptureId,
                  isDark: isDark,
                ),
              )
                  .animate(delay: Duration(milliseconds: 40 + 20 * math.min(i, 9)))
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.02, end: 0, duration: 350.ms);
            }),
          ],
        ),
        if (showJumper)
          Positioned(
            right: 8,
            top: 70,
            bottom: 30,
            child: _VerseJumper(
              verseCount: total,
              isDark: isDark,
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
                    height: 1.1,
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

    final incipit = verse.sanskrit.split('\n').first.trim();

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
                child: LeafThread(isDark: isDark),
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
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: saffron.withValues(alpha: 0.7),
                  ),
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

    final skLine = verse.sanskrit.split('\n').first.trim();
    final enLine = verse.english?.split('\n').first.trim() ?? '';
    final sanskritDisplay = skLine.isNotEmpty ? skLine : '—';

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
                width: 38,
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: DandaCoord.multipart(
                    parts: [verse.verseNum],
                    isDark: isDark,
                    fontSize: 14,
                    colorOverride: dandaColor,
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
                      sanskritDisplay,
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

class _VerseJumper extends StatelessWidget {
  const _VerseJumper({
    required this.verseCount,
    required this.isDark,
    required this.onTap,
  });

  final int verseCount;
  final bool isDark;
  final void Function(int verseNum) onTap;

  int get _step {
    if (verseCount >= 500) return 50;
    if (verseCount >= 200) return 20;
    return 10;
  }

  List<int> get _markers {
    final step = _step;
    final raw = <int>[1];
    var n = step;
    while (n <= verseCount && raw.length < 8) {
      raw.add(n);
      n += step;
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final surface = isDark
        ? DColors.surface.withValues(alpha: 0.6)
        : LColors.surface.withValues(alpha: 0.85);
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final markers = _markers;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropOverlay(
        color: surface,
        child: Container(
          width: 22,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final n in markers)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(n),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      arabicToDevanagari(n),
                      style: TextStyle(
                        fontFamily: Fonts.deva,
                        fontSize: 11,
                        height: 1,
                        color: text3,
                      ),
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

class BackdropOverlay extends StatelessWidget {
  const BackdropOverlay({super.key, required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color),
      child: child,
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

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
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
        const SizedBox(height: 14),
        _VersesLabel(isDark: isDark),
        for (int i = 0; i < 8; i++) _VerseRowSkeleton(color: shimmerColor),
      ],
    );
  }
}

class _VerseRowSkeleton extends StatelessWidget {
  const _VerseRowSkeleton({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 11, 0, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBar(width: 38, height: 18, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBar(widthFraction: 0.6, height: 14, color: color),
                const SizedBox(height: 6),
                _ShimmerBar(widthFraction: 0.8, height: 11, color: color),
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
