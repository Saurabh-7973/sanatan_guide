import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/constants/bhagavad_gita_chapters.dart';
import 'package:sanatan_guide/core/constants/scripture_chapters.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/core/utils/devanagari.dart';
import 'package:sanatan_guide/core/utils/nav_logger.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/domain/entities/chapter_outline.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_browser_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_progress_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/shared/widgets/mockup_icons.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

/// Single canonical chapter-list layout for every scripture.
///
/// Data sources, in priority order:
/// 1. [BhagavadGitaChapters.all] for Bhagavad Gītā (carries Devanāgarī
///    chapter title + theme + verseCount).
/// 2. [scriptureChaptersFor] for scriptures with curated chapter
///    metadata (Yoga Sūtras, HYP, Manusmṛti, Mahānirvāṇa, Brahma Sūtras,
///    Sāma/Yajur Veda, Vishnu/Devī/Mārkaṇḍeya Purāṇa).
/// 3. [chapterOutlinesProvider] for DB-driven outlines (Bhāgavata, Ṛgveda,
///    Atharvaveda, Mahābhārata, Rāmāyaṇa, Arthaśāstra, Chāndogya,
///    Bṛhadāraṇyaka, Tirukkural, Vishnu Sahasranāma).
class ChapterListPage extends ConsumerStatefulWidget {
  const ChapterListPage({super.key, required this.scriptureId});

  final String scriptureId;

  /// Scriptures that publish a single chapter — pushing into the chapter
  /// list is wasteful, so we redirect straight to the verse list.
  static const _singleChapter = {
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

  @override
  ConsumerState<ChapterListPage> createState() => _ChapterListPageState();
}

class _ChapterListPageState extends ConsumerState<ChapterListPage>
    with NavLoggerMixin<ChapterListPage> {
  @override
  String get screenName => 'ChapterListPage(${widget.scriptureId})';

  @override
  void initState() {
    super.initState();
    if (ChapterListPage._singleChapter.contains(widget.scriptureId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go(
          browseChapterPath(
            scriptureCode: widget.scriptureId,
            chapterNum: 1,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scripture = _safeFromCode(widget.scriptureId);

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
              child: scripture == null
                  ? Center(
                      child: Text(
                        'Coming soon',
                        style: AppText.rowSub(
                          color: isDark ? DColors.text2 : LColors.text2,
                        ),
                      ),
                    )
                  : _ScriptureChapterList(
                      scripture: scripture,
                      isDark: isDark,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Scripture? _safeFromCode(String code) {
    try {
      return ScriptureX.fromCode(code);
    } on ArgumentError {
      return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Resolve chapters from one of the three sources
// ─────────────────────────────────────────────────────────────────────────

class _ScriptureChapterList extends ConsumerWidget {
  const _ScriptureChapterList({
    required this.scripture,
    required this.isDark,
  });

  final Scripture scripture;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = scripture.code;

    // Bhagavad Gītā uses its own typed const list (richer than the generic
    // ChapterMeta — has sanskritName + theme).
    if (code == 'bhagavad_gita') {
      final entries = BhagavadGitaChapters.all
          .map(
            (c) => ChapterMeta(
              chapterNum: c.number,
              devaTitle: c.sanskritName,
              enTitle: c.englishName,
              subtitle: c.theme,
              verseCount: c.verseCount,
            ),
          )
          .toList(growable: false);
      return _LoadedBody(
        scripture: scripture,
        entries: entries,
        isDark: isDark,
      );
    }

    // Curated metadata table
    final curated = scriptureChaptersFor(code);
    if (curated != null) {
      return _LoadedBody(
        scripture: scripture,
        entries: curated,
        isDark: isDark,
      );
    }

    // Fallback to DB outlines
    final async = ref.watch(chapterOutlinesProvider(code));
    return async.when(
      loading: () => _LoadingBody(scripture: scripture, isDark: isDark),
      error: (_, __) => _ErrorBody(
        scriptureId: code,
        isDark: isDark,
      ),
      data: (outlines) {
        if (outlines.isEmpty) {
          return Center(
            child: Text(
              'No chapters yet',
              style: AppText.rowSub(
                color: isDark ? DColors.text2 : LColors.text2,
              ),
            ),
          );
        }
        final entries = outlines.map(_outlineToMeta(code)).toList();
        return _LoadedBody(
          scripture: scripture,
          entries: entries,
          isDark: isDark,
        );
      },
    );
  }
}

ChapterMeta Function(ChapterOutline) _outlineToMeta(String scriptureId) {
  return (o) {
    final label = o.chapterLabel?.trim();
    final fallback = switch (scriptureId) {
      'rigveda' => 'Maṇḍala ${o.chapterNum}',
      'atharvaveda' => 'Kāṇḍa ${o.chapterNum}',
      'mahabharata' => 'Parva ${o.chapterNum}',
      'ramayana' => 'Kāṇḍa ${o.chapterNum}',
      'bhagavata_purana' => 'Skanda ${o.chapterNum}',
      _ => 'Chapter ${o.chapterNum}',
    };
    return ChapterMeta(
      chapterNum: o.chapterNum,
      bookNum: o.bookNum,
      enTitle: (label != null && label.isNotEmpty) ? label : fallback,
    );
  };
}

// ─────────────────────────────────────────────────────────────────────────
// Loaded body — header + resume + chapter rows
// ─────────────────────────────────────────────────────────────────────────

class _LoadedBody extends ConsumerWidget {
  const _LoadedBody({
    required this.scripture,
    required this.entries,
    required this.isDark,
  });

  final Scripture scripture;
  final List<ChapterMeta> entries;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readCounts = [
      for (final e in entries)
        ref
                .watch(chapterReadCountProvider(
                  scripture.code,
                  e.chapterNum,
                  e.bookNum,
                ))
                .value ??
            0,
    ];

    final totalUnits = entries.length;
    final hasRollup = entries.any((e) => e.chapterCount != null);
    final totalChapters = hasRollup
        ? entries.fold<int>(0, (acc, e) => acc + (e.chapterCount ?? 0))
        : totalUnits;
    final totalVerses = entries.fold<int>(
      0,
      (acc, e) => acc + (e.verseCount ?? 0),
    );
    final readChapters = readCounts.fold<int>(
      0,
      (acc, n) => acc + (n > 0 ? 1 : 0),
    );

    final lastReadAsync = ref.watch(lastReadVerseProvider);
    final lastRead = lastReadAsync.value;
    final showResume =
        lastRead != null && lastRead.scriptureCode == scripture.code;
    final resumeChapter =
        showResume ? _resumeChapterFor(lastRead.verseId) : null;

    return Column(
      children: [
        // Pinned header — only the resume + chapter list scrolls.
        _ChapterListHeader(
          scripture: scripture,
          totalUnits: totalUnits,
          totalChapters: hasRollup ? totalChapters : null,
          totalVerses: totalVerses,
          readChapters: readChapters,
          isDark: isDark,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (showResume && resumeChapter != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: _ResumeRow(
                    scripture: scripture,
                    chapter: resumeChapter,
                    verseNum: _resumeVerseNumFor(lastRead.verseId),
                    isDark: isDark,
                  ),
                ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ChaptersLabel(scripture: scripture, isDark: isDark),
              ),
              ...List.generate(entries.length, (i) {
                final entry = entries[i];
                final read = i < readCounts.length ? readCounts[i] : 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _ChapterRow(
                    entry: entry,
                    scripture: scripture,
                    readCount: read,
                    isDark: isDark,
                  ),
                )
                    .animate(
                      delay: Duration(
                        milliseconds: 60 + 30 * math.min(i, 7),
                      ),
                    )
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.025, end: 0, duration: 400.ms);
              }),
            ],
          ),
        ),
      ],
    );
  }

  ChapterMeta? _resumeChapterFor(String verseId) {
    final parts = verseId.split('.');
    if (parts.length < 2) return entries.firstOrNull;
    final ch = int.tryParse(parts[1]);
    if (ch == null) return entries.firstOrNull;
    for (final e in entries) {
      if (e.chapterNum == ch) return e;
    }
    return entries.firstOrNull;
  }

  int? _resumeVerseNumFor(String verseId) {
    final parts = verseId.split('.');
    if (parts.length < 3) return null;
    return int.tryParse(parts[2]);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────

class _ChapterListHeader extends StatelessWidget {
  const _ChapterListHeader({
    required this.scripture,
    required this.totalUnits,
    required this.totalChapters,
    required this.totalVerses,
    required this.readChapters,
    required this.isDark,
  });

  final Scripture scripture;
  // Top-level unit count (e.g. 12 cantos, 18 chapters, 10 maṇḍalas).
  final int totalUnits;
  // Aggregate chapter count when the unit is a canto/skanda rollup; null when
  // the unit IS a chapter (so we don't show "18 chapters · 18 chapters").
  final int? totalChapters;
  final int totalVerses;
  final int readChapters;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cream = isDark ? DColors.cream : LColors.text1;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final unit = scripture.unitLabel;

    final parts = <(String, String)>[
      ('$totalUnits', unit.toUpperCase()),
      if (totalChapters != null && totalChapters! > 0)
        (_fmt(totalChapters!), 'CHAPTERS'),
      if (totalVerses > 0) (_fmt(totalVerses), 'VERSES'),
      if (readChapters > 0) ('$readChapters', 'READ'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scripture.devaName,
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontFamilyFallback: AppFontFallback.deva,
              fontSize: 22,
              height: 1.1,
              letterSpacing: 0.01 * 22,
              color: cream,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            scripture.scholarlySubtitle,
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontStyle: FontStyle.italic,
              fontSize: 14,
              color: text2,
            ),
          ),
          const SizedBox(height: 8),
          DefaultTextStyle(
            style: TextStyle(
              fontFamily: Fonts.sans,
              // Outfit lacks uppercase IAST glyphs (Ṇ, Ḍ, Ṣ, Ṭ, …);
              // fall back to Lora so "KĀṆḌAS", "MAṆḌALAS" etc. don't
              // render with tofu boxes in the toUpperCase() output.
              fontFamilyFallback: const <String>[
                Fonts.serif,
                'NotoSansDevanagari',
                'serif',
              ],
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.22 * 10,
              color: text3,
            ),
            child: _MetaLine(parts: parts, saffron: saffron),
          ),
        ],
      ),
    );
  }

  static String _fmt(int n) {
    // Indian grouping (lakh/crore) — matches the home/library stats line.
    final s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    for (var i = 0; i < rest.length; i++) {
      buf.write(rest[i]);
      final remain = rest.length - i - 1;
      if (remain > 0 && remain % 2 == 0) buf.write(',');
    }
    return '$buf,$last3';
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.parts, required this.saffron});
  final List<(String, String)> parts;
  final Color saffron;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0) {
        children.add(_Sep(saffron: saffron));
      }
      final (num, label) = parts[i];
      children.add(
        Text(
          num,
          style: TextStyle(
            fontFamily: Fonts.serif,
            fontFamilyFallback: AppFontFallback.latin,
            fontStyle: FontStyle.italic,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            color: saffron,
          ),
        ),
      );
      children.add(const SizedBox(width: 4));
      children.add(Text(label));
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
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
// Resume row
// ─────────────────────────────────────────────────────────────────────────

class _ResumeRow extends StatelessWidget {
  const _ResumeRow({
    required this.scripture,
    required this.chapter,
    required this.verseNum,
    required this.isDark,
  });

  final Scripture scripture;
  final ChapterMeta chapter;
  final int? verseNum;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final divider = isDark ? DColors.divider : LColors.divider;
    final gradStart = saffron.withValues(alpha: isDark ? 0.07 : 0.06);
    final gradMid = saffron.withValues(alpha: isDark ? 0.02 : 0.015);

    final unitLabelSingular = switch (scripture.unitLabel) {
      'cantos' => 'Canto',
      'maṇḍalas' => 'Maṇḍala',
      'kāṇḍas' => 'Kāṇḍa',
      'pādas' => 'Pāda',
      'upadeśas' => 'Upadeśa',
      'adhyāyas' => 'Adhyāya',
      'parvas' => 'Parva',
      _ => 'Chapter',
    };

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        splashColor: Colors.transparent,
        highlightColor: saffron.withValues(alpha: 0.04),
        onTap: () => context.push(
          browseChapterPath(
            scriptureCode: scripture.code,
            chapterNum: chapter.chapterNum,
            bookNum: chapter.bookNum,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: divider, width: 1),
            gradient: LinearGradient(
              colors: [gradStart, gradMid, Colors.transparent],
              stops: const [0, 0.6, 1],
            ),
          ),
          // Stack lives OUTSIDE any inner padding so `left: 0` lands at the
          // card's actual left edge — not 22 px inside it where the content
          // padding starts.
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 12,
                bottom: 12,
                child: LeafThread(isDark: isDark, pulseOnce: true),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 18, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'CONTINUE READING',
                            style: TextStyle(
                              fontFamily: Fonts.sans,
                              fontFamilyFallback: AppFontFallback.latin,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.24 * 9.5,
                              color: saffron,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chapter.devaTitle ?? chapter.enTitle,
                            style: TextStyle(
                              fontFamily: chapter.devaTitle != null
                                  ? Fonts.deva
                                  : Fonts.serif,
                              fontSize: 16,
                              height: 1.2,
                              color: cream,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _resumeMetaText(unitLabelSingular),
                            style: TextStyle(
                              fontFamily: Fonts.sans,
                              fontFamilyFallback: const [Fonts.serif],
                              fontSize: 11.5,
                              color: text2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MockupResumeArrow(
                      color: saffron.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _resumeMetaText(String unit) {
    final ch = chapter.chapterNum;
    final total = chapter.verseCount;
    if (verseNum != null && total != null) {
      return '$unit $ch · verse $verseNum of $total';
    }
    if (verseNum != null) {
      return '$unit $ch · verse $verseNum';
    }
    return '$unit $ch';
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────

class _ChaptersLabel extends StatelessWidget {
  const _ChaptersLabel({required this.scripture, required this.isDark});
  final Scripture scripture;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: divider, width: 1)),
      ),
      child: Text(
        'ALL ${scripture.unitLabel.toUpperCase()}',
        style: TextStyle(
          fontFamily: Fonts.sans,
          fontFamilyFallback: const [Fonts.serif],
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
// Chapter row
// ─────────────────────────────────────────────────────────────────────────

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({
    required this.entry,
    required this.scripture,
    required this.readCount,
    required this.isDark,
  });

  final ChapterMeta entry;
  final Scripture scripture;
  final int readCount;
  final bool isDark;

  bool get _isComplete =>
      entry.verseCount != null &&
      entry.verseCount! > 0 &&
      readCount >= entry.verseCount!;

  bool get _isStarted => readCount > 0;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;

    final numColor = _isComplete ? text3 : saffron;
    final devaTitleColor = _isComplete ? text2 : cream;

    final percent = entry.verseCount != null && entry.verseCount! > 0
        ? readCount / entry.verseCount!
        : 0.0;

    final readingMins = entry.verseCount != null
        ? math.max(1, (entry.verseCount! * 15 / 60).round())
        : 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: saffron.withValues(alpha: 0.04),
        onTap: () => context.push(
          browseChapterPath(
            scriptureCode: scripture.code,
            chapterNum: entry.chapterNum,
            bookNum: entry.bookNum,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: dividerSoft, width: 1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Numeral block
              SizedBox(
                width: 38,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      arabicToDevanagari(entry.chapterNum),
                      style: TextStyle(
                        fontFamily: Fonts.deva,
                        fontFamilyFallback: AppFontFallback.deva,
                        fontSize: 22,
                        height: 1,
                        color: numColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${scripture.unitCode} ${entry.chapterNum}',
                      style: TextStyle(
                        fontFamily: Fonts.sans,
                        fontFamilyFallback: AppFontFallback.latin,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.16 * 9,
                        color: text3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (entry.devaTitle != null) ...[
                      Text(
                        entry.devaTitle!,
                        style: TextStyle(
                          fontFamily: Fonts.deva,
                          fontFamilyFallback: AppFontFallback.deva,
                          fontSize: 16,
                          height: 1.25,
                          letterSpacing: 0.005 * 16,
                          color: devaTitleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      entry.enTitle,
                      style: TextStyle(
                        fontFamily: Fonts.serif,
                        fontFamilyFallback: AppFontFallback.latin,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        color: text1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _MetaText(
                      entry: entry,
                      readCount: readCount,
                      readingMins: readingMins,
                      isComplete: _isComplete,
                      isStarted: _isStarted,
                      saffron: saffron,
                      text2: text2,
                      text3: text3,
                    ),
                    if (_isStarted && entry.verseCount != null) ...[
                      const SizedBox(height: 6),
                      _Hairline(
                        progress: percent,
                        track: dividerSoft,
                        fill: saffron,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ChapterRowArrow(
                isComplete: _isComplete,
                saffron: saffron,
                text3: text3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({
    required this.entry,
    required this.readCount,
    required this.readingMins,
    required this.isComplete,
    required this.isStarted,
    required this.saffron,
    required this.text2,
    required this.text3,
  });

  final ChapterMeta entry;
  final int readCount;
  final int readingMins;
  final bool isComplete;
  final bool isStarted;
  final Color saffron;
  final Color text2;
  final Color text3;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    final hasVerseCount = entry.verseCount != null && entry.verseCount! > 0;
    final hasSubtitle = entry.subtitle != null && entry.subtitle!.isNotEmpty;
    final base = TextStyle(
      fontFamily: Fonts.sans,
      fontFamilyFallback: AppFontFallback.latin,
      fontSize: 11,
      height: 1.4,
      color: text3,
    );

    if (hasVerseCount) {
      spans.add(
        TextSpan(
          text: '${_fmt(entry.verseCount!)} verses',
          style: base.copyWith(
            fontFamily: Fonts.serif,
            fontFamilyFallback: AppFontFallback.latin,
            fontStyle: FontStyle.italic,
            fontSize: 11.5,
            color: text2,
          ),
        ),
      );
      if (isComplete) {
        spans.add(TextSpan(text: ' · ', style: base));
        spans.add(
          TextSpan(
            text: 'complete',
            style: base.copyWith(
              fontWeight: FontWeight.w500,
              color: saffron,
            ),
          ),
        );
      } else if (entry.chapterCount != null && entry.chapterCount! > 0) {
        // Canto-rollup row — chapter count is more informative than a
        // ~minutes-to-read estimate against thousands of verses.
        spans.add(TextSpan(text: ' ·  ', style: base));
        spans.add(
          TextSpan(
            text: '${entry.chapterCount} chapters',
            style: base,
          ),
        );
      } else {
        if (readingMins > 0) {
          spans.add(TextSpan(text: ' ·  ~$readingMins min', style: base));
        }
        if (isStarted) {
          spans.add(TextSpan(text: ' · ', style: base));
          spans.add(
            TextSpan(
              text: '$readCount of ${entry.verseCount} read',
              style: base.copyWith(
                fontWeight: FontWeight.w500,
                color: saffron,
              ),
            ),
          );
        }
      }
    } else if (hasSubtitle) {
      spans.add(TextSpan(text: entry.subtitle, style: base));
    }

    if (spans.isEmpty) return const SizedBox.shrink();
    return Text.rich(
      TextSpan(children: spans),
      maxLines: hasVerseCount ? 1 : 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  static String _fmt(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    for (var i = 0; i < rest.length; i++) {
      buf.write(rest[i]);
      final remain = rest.length - i - 1;
      if (remain > 0 && remain % 2 == 0) buf.write(',');
    }
    return '$buf,$last3';
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({
    required this.progress,
    required this.track,
    required this.fill,
  });
  final double progress;
  final Color track;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(1),
      child: SizedBox(
        height: 1.5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: track),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(color: fill),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterRowArrow extends StatelessWidget {
  const _ChapterRowArrow({
    required this.isComplete,
    required this.saffron,
    required this.text3,
  });

  final bool isComplete;
  final Color saffron;
  final Color text3;

  @override
  Widget build(BuildContext context) {
    if (isComplete) {
      return Icon(Icons.check_circle_outline_rounded, size: 14, color: saffron);
    }
    return MockupRowChevron(color: text3.withValues(alpha: 0.4));
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Loading + error
// ─────────────────────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.scripture, required this.isDark});

  final Scripture scripture;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final shimmer = saffron.withValues(alpha: 0.08);
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      children: [
        _ChapterListHeader(
          scripture: scripture,
          totalUnits: 0,
          totalChapters: null,
          totalVerses: 0,
          readChapters: 0,
          isDark: isDark,
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _ChaptersLabel(scripture: scripture, isDark: isDark),
        ),
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: _ChapterRowSkeleton(color: shimmer),
          ),
      ],
    );
  }
}

class _ChapterRowSkeleton extends StatelessWidget {
  const _ChapterRowSkeleton({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget bar(double widthFraction, double height) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: widthFraction,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 800.ms, begin: 0.5),
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bar(0.6, 14),
              const SizedBox(height: 6),
              bar(0.8, 11),
              const SizedBox(height: 6),
              bar(0.4, 9),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends ConsumerWidget {
  const _ErrorBody({required this.scriptureId, required this.isDark});

  final String scriptureId;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorStateWidget(
      onRetry: () => ref.invalidate(chapterOutlinesProvider(scriptureId)),
    );
  }
}
