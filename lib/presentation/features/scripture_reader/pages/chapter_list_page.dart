import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/constants/bhagavad_gita_chapters.dart';
import 'package:sanatan_guide/core/router/app_routes.dart';
import 'package:sanatan_guide/core/utils/nav_logger.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/domain/entities/chapter_outline.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_browser_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_progress_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

String _scriptureBrowseTitle(String scriptureId) {
  try {
    return ScriptureX.fromCode(scriptureId).displayName;
  } on ArgumentError {
    return 'Scripture';
  }
}

String _outlinePrimaryTitle(ChapterOutline outline, String scriptureId) {
  final label = outline.chapterLabel?.trim();
  if (label != null && label.isNotEmpty) return label;
  if (outline.bookNum != null) {
    return 'Book ${outline.bookNum} · Chapter ${outline.chapterNum}';
  }
  return switch (scriptureId) {
    'rigveda' => 'Mandala ${outline.chapterNum}',
    'atharvaveda' => 'Kanda ${outline.chapterNum}',
    _ => 'Chapter ${outline.chapterNum}',
  };
}

class ChapterListPage extends StatefulWidget {
  const ChapterListPage({super.key, required this.scriptureId});

  final String scriptureId;

  static const singleChapter = {
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
  State<ChapterListPage> createState() => _ChapterListPageState();
}

class _ChapterListPageState extends State<ChapterListPage>
    with NavLoggerMixin<ChapterListPage> {
  @override
  String get screenName => 'ChapterListPage(${widget.scriptureId})';

  @override
  Widget build(BuildContext context) {
    final scriptureId = widget.scriptureId;
    if (ChapterListPage.singleChapter.contains(scriptureId)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _scriptureBrowseTitle(scriptureId),
            style: context.ts.displayMedium,
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_rounded),
              color: AppColors.warmGrey50,
              tooltip: 'Saved verses',
              onPressed: () => context.go(AppRoutes.bookmarks),
            ),
          ],
        ),
        body: _SingleChapterVerseList(scriptureId: scriptureId),
      );
    }

    final Widget body = switch (scriptureId) {
      'bhagavad_gita' => const _BgChapterList(),
      'yoga_sutras' => const _YogaSutrasPadaList(),
      'hatha_yoga_pradipika' => const _HYPChapterList(),
      'manusmriti' => const _ManuChapterList(),
      'mahanirvana_tantra' => const _MNTChapterList(),
      'brahma_sutras' => const _BSAdhyayaList(),
      'rigveda' ||
      'atharvaveda' ||
      'mahabharata' ||
      'ramayana' ||
      'bhagavata_purana' ||
      'arthashastra' ||
      'chandogya_upanishad' ||
      'brihadaranyaka_upanishad' ||
      'tirukkural' =>
        _OutlineChapterList(scriptureId: scriptureId),
      'samaveda' => const _SamavedaList(),
      'yajurveda' => const _YajurvedaList(),
      'vishnu_purana' => const _VishnuPuranaList(),
      'devi_bhagavata_purana' => const _DeviBhagavataList(),
      'markandeya_purana' => const _MarkandeyaList(),
      _ => Center(
          child: Text(
            'Coming soon',
            style: context.ts.bodyMedium,
          ),
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _scriptureBrowseTitle(scriptureId),
          style: context.ts.displayMedium,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_rounded),
            color: AppColors.warmGrey50,
            tooltip: 'Saved verses',
            onPressed: () => context.go(AppRoutes.bookmarks),
          ),
        ],
      ),
      body: body,
    );
  }
}

// ── Bhagavad Gita — editorial vertical list with dot ladder ──────────────

class _BgChapterList extends ConsumerWidget {
  const _BgChapterList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const chapters = BhagavadGitaChapters.all;

    // Collect read counts for dot ladder (all 18 chapters)
    final readCounts = [
      for (final ch in chapters)
        ref
            .watch(chapterReadCountProvider('bhagavad_gita', ch.number, null))
            .value ??
            0,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DotLadder(chapters: chapters, readCounts: readCounts),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              0,
              AppSpacing.sm,
              0,
              AppSpacing.xxxl,
            ),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return _ChapterRow(
                chapter: chapter,
                readCount: readCounts[index],
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Dot ladder — 18 circles showing overall progress ─────────────────────

class _DotLadder extends StatelessWidget {
  const _DotLadder({required this.chapters, required this.readCounts});

  final List<BgChapter> chapters;
  final List<int> readCounts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.md,
        AppSpacing.pagePadding,
        AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < chapters.length; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            _Dot(
              filled: readCounts[i] > 0,
              complete: readCounts[i] >= chapters[i].verseCount,
            ),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.filled, required this.complete});
  final bool filled;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (complete) {
      color = AppColors.saffron;
    } else if (filled) {
      color = AppColors.saffron.withValues(alpha: 0.45);
    } else {
      color = AppColors.warmGrey10;
    }
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: filled
            ? null
            : Border.all(color: AppColors.borderFaint, width: 0.5),
      ),
    );
  }
}

// ── Single chapter row — editorial list ──────────────────────────────────

class _ChapterRow extends ConsumerWidget {
  const _ChapterRow({
    required this.chapter,
    required this.readCount,
    required this.index,
  });

  final BgChapter chapter;
  final int readCount;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = readCount / chapter.verseCount;

    return InkWell(
      onTap: () =>
          context.push('/browse/bhagavad_gita/chapter/${chapter.number}'),
      child: Container(
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Chapter number — large Lora w300
            SizedBox(
              width: 44,
              child: Text(
                '${chapter.number}',
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: AppColors.warmGrey50,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Sanskrit name + English theme
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    chapter.sanskritName,
                    style: context.ts.sanskritSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chapter.theme,
                    style: context.ts.caption.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Circular progress arc
            _ChapterArc(progress: progress, isDark: isDark),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index.clamp(0, 9) * 30))
        .fadeIn(duration: 180.ms)
        .slideX(begin: 0.02, end: 0, duration: 180.ms, curve: Curves.easeOut);
  }
}

// ── Circular arc progress indicator ──────────────────────────────────────

class _ChapterArc extends StatelessWidget {
  const _ChapterArc({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) {
      return SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          value: 0,
          strokeWidth: 2,
          backgroundColor:
              isDark ? AppColors.borderDark : AppColors.border,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saffron),
        ),
      );
    }
    return SizedBox(
      width: 28,
      height: 28,
      child: CircularProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        strokeWidth: 2.5,
        backgroundColor: isDark ? AppColors.borderDark : AppColors.border,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saffron),
      ),
    );
  }
}

class _YogaSutrasPadaList extends StatelessWidget {
  const _YogaSutrasPadaList();

  static const List<(int, String, String, int)> _padas = [
    (
      1,
      'Samadhi Pada',
      'On Contemplation — the nature of Yoga and the states of the mind.',
      51,
    ),
    (
      2,
      'Sadhana Pada',
      'On Practice — Kriya Yoga, the five afflictions, and the eight limbs.',
      55,
    ),
    (
      3,
      'Vibhuti Pada',
      'On Powers — Dharana, Dhyana, Samadhi, and the extraordinary attainments.',
      55,
    ),
    (
      4,
      'Kaivalya Pada',
      'On Liberation — the nature of the mind, Karma, and final independence.',
      34,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.lg,
      ),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: _padas.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.listItemSpacing),
      itemBuilder: (context, index) {
        final (num, title, desc, count) = _padas[index];
        return InkWell(
          onTap: () => context.push(
            '/browse/yoga_sutras/chapter/$num',
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.warmGrey10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$num',
                    style: context.ts.labelLarge.copyWith(
                      color: AppColors.warmGrey80,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.ts.labelLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        desc,
                        style: context.ts.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    Text('${count}v', style: context.ts.caption),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HYPChapterList extends StatelessWidget {
  const _HYPChapterList();

  static const List<(int, String, String, int)> _chapters = [
    (
      1,
      'Chapter I — Asanas',
      'The foundation of Hatha Yoga — postures, their benefits, and preparation for higher practice.',
      67,
    ),
    (
      2,
      'Chapter II — Pranayama',
      'The breath is life. Eight Kumbhakas, Nadi purification, and Kundalini awakening.',
      78,
    ),
    (
      3,
      'Chapter III — Mudras',
      'Gestures and locks — Maha Mudra, Bandhas, and the awakening of Kundalini Shakti.',
      130,
    ),
    (
      4,
      'Chapter IV — Samadhi',
      'The culmination — Raja Yoga, Laya, Nada, and liberation through dissolution of the mind.',
      114,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.lg,
      ),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: _chapters.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.listItemSpacing),
      itemBuilder: (context, index) {
        final (num, title, desc, count) = _chapters[index];
        return InkWell(
          onTap: () => context.push(
            '/browse/hatha_yoga_pradipika/chapter/$num',
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.warmGrey10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$num',
                    style: context.ts.labelLarge.copyWith(
                      color: AppColors.warmGrey80,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.ts.labelLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        desc,
                        style: context.ts.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    Text('${count}v', style: context.ts.caption),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ManuChapterList extends StatelessWidget {
  const _ManuChapterList();

  static const List<(int, String, String, int)> _chapters = [
    (
      1,
      'Chapter I — Creation',
      'Key verses · Origin of the world, nature of Brahman, and sources of dharma.',
      119
    ),
    (
      2,
      'Chapter II — Education',
      'Key verses · Initiation, the student, study of the Veda, twice-born duties.',
      249
    ),
    (
      3,
      'Chapter III — Marriage',
      'Key verses · Marriage laws, the householder, and the five great sacrifices.',
      286
    ),
    (
      4,
      'Chapter IV — Livelihood',
      'Key verses · Occupations, private morals, and the conduct of virtuous men.',
      260
    ),
    (
      5,
      'Chapter V — Purification',
      'Key verses · Dietary laws, purification rites, and the status of women.',
      169
    ),
    (
      6,
      'Chapter VI — Ascetic',
      'Key verses · The forest dweller, the wandering ascetic, and the path to liberation.',
      97
    ),
    (
      7,
      'Chapter VII — Governance',
      'Key verses · The duties of the king, ministers, councils, and the conduct of war.',
      226
    ),
    (
      8,
      'Chapter VIII — Civil Law',
      'Key verses · The eighteen grounds of litigation, evidence, punishments, and contracts.',
      420
    ),
    (
      9,
      'Chapter IX — Family Law',
      'Key verses · Inheritance, property, the duties of husband and wife, and the king\'s justice.',
      336
    ),
    (
      10,
      'Chapter X — Mixed Castes',
      'Key verses · Origins of mixed castes, their occupations, and the summary of all dharma.',
      131
    ),
    (
      11,
      'Chapter XI — Penances',
      'Key verses · Sins, expiations, atonements, and the power of Japa.',
      265
    ),
    (
      12,
      'Chapter XII — Liberation',
      'Key verses · Transmigration of souls, the three qualities, supreme good, and final liberation.',
      126
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.lg,
      ),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: _chapters.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.listItemSpacing),
      itemBuilder: (context, index) {
        final (num, title, desc, count) = _chapters[index];
        return InkWell(
          onTap: () => context.push('/browse/manusmriti/chapter/$num'),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.warmGrey10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$num',
                    style: context.ts.labelLarge.copyWith(
                      color: AppColors.warmGrey80,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.ts.labelLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        desc,
                        style: context.ts.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    Text('${count}v', style: context.ts.caption),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MNTChapterList extends StatelessWidget {
  const _MNTChapterList();

  static const List<(int, String, String)> _chapters = [
    (
      1,
      'Chapter I — Hymn to Brahman',
      'Salutation to Brahman as Sat-Chit-Ananda, and to the Devi as supreme Shakti.'
    ),
    (
      2,
      'Chapter II — Brahman and Shakti',
      'Shiva declares the supreme eternal knowledge. Brahman is real, the world is illusion.'
    ),
    (
      3,
      'Chapter III — Qualifications of Disciples',
      'The marks of an excellent aspirant, the ideal Guru, and the devoted disciple.'
    ),
    (
      4,
      'Chapter IV — Brahma Mantra and Initiation',
      'OM, the Gayatri, and the eternal Brahma Mantra. The necessity of initiation.'
    ),
    (
      5,
      'Chapter V — Rules for Brahma Sadhana',
      'Rising in Brahma Muhurta, Japa, compassion, purity, and truthful conduct.'
    ),
    (
      6,
      'Chapter VI — Worship and Purification',
      'Purity of feeling is the foundation of all worship, Japa, and sacred rites.'
    ),
    (
      7,
      'Chapter VII — Panchatattva and Worship',
      'The five M\'s and their symbolic interpretation. Knowledge is supreme liberation.'
    ),
    (
      8,
      'Chapter VIII — Kulachara',
      'The highest Agama. The Kulina sees Self in all beings equally, beyond all rules.'
    ),
    (
      9,
      'Chapter IX — Hymn to Adya Kali',
      'The great hymn to Kali — Mother of creation, preservation, and dissolution.'
    ),
    (
      10,
      'Chapter X — The Ten Samskaras',
      'The ten purificatory rites from birth to marriage that make a man twice-born.'
    ),
    (
      11,
      'Chapter XI — Funeral Rites',
      'Death is certain for all. The eternal Self is never born and never dies.'
    ),
    (
      12,
      'Chapter XII — Prayaschitta',
      'Expiation through Brahma Jnana. Varnashrama conduct as the path to Vishnu.'
    ),
    (
      13,
      'Chapter XIII — Duties of Householder',
      'The guest is Narayana. The king rules for subjects, not for himself.'
    ),
    (
      14,
      'Chapter XIV — Liberation',
      '"I am Brahman." The knower of Brahman becomes Brahman. OM TAT SAT.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.lg,
      ),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: _chapters.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.listItemSpacing),
      itemBuilder: (context, index) {
        final (num, title, desc) = _chapters[index];
        return InkWell(
          onTap: () => context.push(
            '/browse/mahanirvana_tantra/chapter/$num',
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.warmGrey10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$num',
                    style: context.ts.labelLarge.copyWith(
                      color: AppColors.warmGrey80,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.ts.labelLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        desc,
                        style: context.ts.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BSAdhyayaList extends StatelessWidget {
  const _BSAdhyayaList();

  static const List<(int, String, String, int)> _adhyayas = [
    (
      1,
      'Adhyaya I — Samanvaya',
      'Reconciliation — Brahman is the sole cause of the universe. "Now, therefore, the inquiry into Brahman."',
      134
    ),
    (
      2,
      'Adhyaya II — Avirodha',
      'Non-conflict — Refutation of Sankhya, Vaisheshika, and other opposing schools.',
      157
    ),
    (
      3,
      'Adhyaya III — Sadhana',
      'Means of Attainment — The nature of the soul, meditation, and the path to Brahman.',
      186
    ),
    (
      4,
      'Adhyaya IV — Phala',
      'Fruits of Knowledge — Liberation, the path after death, and non-return of the liberated soul.',
      78
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.lg,
      ),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: _adhyayas.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.listItemSpacing),
      itemBuilder: (context, index) {
        final (num, title, desc, count) = _adhyayas[index];
        return InkWell(
          onTap: () => context.push('/browse/brahma_sutras/chapter/$num'),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.warmGrey10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$num',
                    style: context.ts.labelLarge.copyWith(
                      color: AppColors.warmGrey80,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.ts.labelLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        desc,
                        style: context.ts.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    Text('${count}v', style: context.ts.caption),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OutlineChapterList extends ConsumerWidget {
  const _OutlineChapterList({required this.scriptureId});

  final String scriptureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(chapterOutlinesProvider(scriptureId));

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: AppSpacing.lg),
        child: ChapterListShimmer(rowCount: 8),
      ),
      error: (_, __) => const ErrorStateWidget(
        message: 'Could not load chapters.',
      ),
      data: (List<ChapterOutline> outlines) {
        if (outlines.isEmpty) {
          return Center(
            child: Text(
              'No chapters yet',
              style: context.ts.bodyMedium,
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.lg,
          ),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemCount: outlines.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.listItemSpacing),
          itemBuilder: (context, index) {
            final outline = outlines[index];
            final primary = _outlinePrimaryTitle(outline, scriptureId);
            return _OutlineChapterRowTile(
              outline: outline,
              title: primary,
              onTap: () => context.push(
                browseChapterPath(
                  scriptureCode: scriptureId,
                  chapterNum: outline.chapterNum,
                  bookNum: outline.bookNum,
                ),
              ),
            )
                .animate(
                  delay: Duration(milliseconds: index.clamp(0, 8) * 40),
                )
                .fadeIn(duration: 200.ms)
                .slideY(
                  begin: 0.04,
                  end: 0,
                  duration: 200.ms,
                  curve: Curves.easeOutCubic,
                );
          },
        );
      },
    );
  }
}

class _SamavedaList extends StatelessWidget {
  const _SamavedaList();
  static const List<(int, String, String)> _sections = [
    (
      1,
      'Prapathaka I — Agni',
      'Hymns to Agni, the sacred fire. The opening verses sung at every Soma sacrifice.'
    ),
    (
      2,
      'Prapathaka II — Soma and Indra',
      'The Soma hymns sung for Indra. OM — the lord of truth comes to the feast.'
    ),
    (
      3,
      'Prapathaka III — Soma Pavamana',
      'Purified Soma flows for Indra. Svaha — all divine.'
    ),
    (
      4,
      'Prapathaka IV — Songs of Praise',
      'Songs of praise to Indra. Wondrous gifts and the king of immortality.'
    ),
    (
      5,
      'Prapathaka V — The OM Invocation',
      'OM — the supreme invocation. Soma pressed for the All-Divine.'
    ),
  ];
  @override
  Widget build(BuildContext context) =>
      _buildVedaList(context, _sections, 'samaveda');
}

class _YajurvedaList extends StatelessWidget {
  const _YajurvedaList();
  static const List<(int, String, String)> _sections = [
    (
      1,
      'Kanda I — Sacrificial Formulas',
      'For food, for strength. From falsehood I step to truth. The sacred waters.'
    ),
    (
      2,
      'Kanda II — Soma Sacrifice',
      'King Soma called for shelter. Agni is head of heaven and lord of earth.'
    ),
    (
      3,
      'Kanda III — The Satarudriya',
      'The 108 names of Rudra. Reverence to the blue-throated, to Pashupati, to Shiva.'
    ),
  ];
  @override
  Widget build(BuildContext context) =>
      _buildVedaList(context, _sections, 'yajurveda');
}

class _VishnuPuranaList extends StatelessWidget {
  const _VishnuPuranaList();
  static const List<(int, String, String)> _amshas = [
    (
      1,
      'Amsha I — Creation',
      'Parashara teaches Maitreya. From Vishnu the universe arises and into Vishnu it dissolves.'
    ),
    (
      2,
      'Amsha II — Cosmology',
      'Seven continents and seven seas. Bharatavarsha — the land of action where karma bears fruit.'
    ),
    (
      3,
      'Amsha III — Dharma and Vedas',
      'Vyasa divides the Vedas fourfold. Vishnu alone is all the world and the supreme state.'
    ),
    (
      4,
      'Amsha IV — Dynasties of Kings',
      'The Solar dynasty from Manu through Ikshvaku to Raghu, Aja, Dasharatha, and Ramachandra.'
    ),
    (
      5,
      'Amsha V — Life of Krishna',
      'Birth in Mathura, childhood in Gokula, slaying of Kamsa, and the Bhagavad Gita at Kurukshetra.'
    ),
    (
      6,
      'Amsha VI — Liberation',
      'Signs of Kali Yuga. Hari\'s name alone is the way. All the world is pervaded by Vishnu.'
    ),
  ];
  @override
  Widget build(BuildContext context) =>
      _buildVedaList(context, _amshas, 'vishnu_purana');
}

class _DeviBhagavataList extends StatelessWidget {
  const _DeviBhagavataList();
  static const List<(int, String, String)> _skandas = [
    (
      1,
      'Skanda I — Supremacy of the Devi',
      'She alone is Maya, Vidya, and supreme Nature. The gods act only by her power.'
    ),
    (
      3,
      'Skanda III — Slaying of Mahishasura',
      'The Devi slays Mahishasura. The gods praise her as consciousness in all beings.'
    ),
    (
      5,
      'Skanda V — Devi Gita',
      '"I alone am Brahman." The Devi teaches the supreme knowledge of her own nature.'
    ),
    (
      7,
      'Skanda VII — Durga Saptashati',
      'The great hymn to Durga — refuge for the poor, destroyer of suffering and fear.'
    ),
    (
      12,
      'Skanda XII — Liberation',
      'Daily recitation grants liberation. All the world is full of Shakti.'
    ),
  ];
  @override
  Widget build(BuildContext context) =>
      _buildVedaList(context, _skandas, 'devi_bhagavata_purana');
}

class _MarkandeyaList extends StatelessWidget {
  const _MarkandeyaList();
  static const List<(int, String, String)> _chapters = [
    (
      1,
      'Chapter I — Jaimini and the Birds',
      'Jaimini questions the birds in the Vindhyas. The four Purusharthas declared.'
    ),
    (
      2,
      'Chapter II — Dharma and the Yugas',
      'Dharma declines across the four ages. In Kali, kirtan and Vishnu\'s name alone suffice.'
    ),
    (
      3,
      'Chapter III — Devi Mahatmya',
      'Namo Devi Mahadevi. Sarva-mangala-mangalye. The great hymns of Chandi.'
    ),
    (
      4,
      'Chapter IV — Markandeya and Shiva',
      'The Maha Mrityunjaya Mantra. Shiva-bhakti conquers death and opens the door to liberation.'
    ),
  ];
  @override
  Widget build(BuildContext context) =>
      _buildVedaList(context, _chapters, 'markandeya_purana');
}

Widget _buildVedaList(BuildContext context,
    List<(int, String, String)> sections, String scriptureId) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return ListView.separated(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.pagePadding,
      vertical: AppSpacing.lg,
    ),
    physics: const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
    itemCount: sections.length,
    separatorBuilder: (_, __) =>
        const SizedBox(height: AppSpacing.listItemSpacing),
    itemBuilder: (context, index) {
      final (num, title, desc) = sections[index];
      return InkWell(
        onTap: () => context.push('/browse/$scriptureId/chapter/$num'),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warmGrey10,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$num',
                  style: context.ts.labelLarge.copyWith(
                    color: AppColors.warmGrey80,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.ts.labelLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      desc,
                      style: context.ts.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _OutlineChapterRowTile extends StatelessWidget {
  const _OutlineChapterRowTile({
    required this.outline,
    required this.title,
    this.onTap,
  });

  final ChapterOutline outline;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.warmGrey10,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${outline.chapterNum}',
              style: context.ts.labelLarge.copyWith(
                color: AppColors.warmGrey80,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.ts.labelLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );

    final onTapResolved = onTap;
    if (onTapResolved == null) {
      return card;
    }
    return InkWell(
      onTap: onTapResolved,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: card,
    );
  }
}

class _SingleChapterVerseList extends ConsumerWidget {
  const _SingleChapterVerseList({required this.scriptureId});

  final String scriptureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chapterVersesProvider(scriptureId, 1, null));

    return state.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: AppSpacing.lg),
        child: VerseListShimmer(rowCount: 8),
      ),
      error: (e, _) => ErrorStateWidget(
        onRetry: () => ref.invalidate(
          chapterVersesProvider(scriptureId, 1, null),
        ),
      ),
      data: (either) => either.fold(
        (failure) => ErrorStateWidget(message: failure.message),
        (verses) {
          final sorted = [...verses]
            ..sort((a, b) => a.verseNum.compareTo(b.verseNum));
          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
              vertical: AppSpacing.lg,
            ),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => Divider(
              color: Theme.of(context).colorScheme.outlineVariant,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final verse = sorted[index];
              return _SingleChapterVerseRow(
                verse: verse,
                scriptureId: scriptureId,
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}

class _SingleChapterVerseRow extends ConsumerWidget {
  const _SingleChapterVerseRow({
    required this.verse,
    required this.scriptureId,
    required this.index,
  });

  final Verse verse;
  final String scriptureId;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skLine = verse.sanskrit.split('\n').first.trim();
    final enLine = verse.english?.split('\n').first.trim() ?? '';
    final sanskritPreview = skLine.isNotEmpty
        ? skLine
        : (enLine.isNotEmpty ? enLine : 'Text not available for this verse');
    final previewIsPlaceholder = skLine.isEmpty && enLine.isEmpty;
    final bookmarked = ref.watch(isBookmarkedProvider(verse.id)).value ?? false;
    final compact = compactVerseLocationLabel(verse);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/browse/$scriptureId/verse/${verse.id}'),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border(
              left: BorderSide(
                color: bookmarked ? AppColors.saffron : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    compact,
                    style: context.ts.caption.copyWith(
                      color: AppColors.warmGrey80,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Semantics(
                      label:
                          'Sanskrit verse: ${verse.transliteration ?? verse.id}',
                      child: Text(
                        sanskritPreview,
                        style: previewIsPlaceholder
                            ? context.ts.caption.copyWith(
                                color: AppColors.textSecondary,
                              )
                            : context.ts.sanskritMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              if (enLine.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  enLine,
                  style: context.ts.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate(
          delay: Duration(milliseconds: index.clamp(0, 8) * 40),
        )
        .fadeIn(duration: 200.ms)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: 200.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
