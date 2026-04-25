import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/constants/bhagavad_gita_chapters.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/utils/nav_logger.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_browser_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_progress_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

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
  @override
  String get screenName =>
      'VerseListPage(${widget.scriptureId} ch:${widget.chapterNum})';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      chapterVersesProvider(
        widget.scriptureId,
        widget.chapterNum,
        widget.bookNum,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        title: _VerseListAppBarTitle(
          scriptureId: widget.scriptureId,
          chapterNum: widget.chapterNum,
          bookNum: widget.bookNum,
          versesAsync: state,
        ),
      ),
      body: state.when(
        loading: () => const VerseListShimmer(),
        error: (e, _) => ErrorStateWidget(
          onRetry: () => ref.invalidate(
            chapterVersesProvider(
              widget.scriptureId,
              widget.chapterNum,
              widget.bookNum,
            ),
          ),
        ),
        data: (either) => either.fold(
          (failure) => Center(
            child: Text(failure.message),
          ),
          (verses) {
            final sorted = [...verses]
              ..sort((a, b) => a.verseNum.compareTo(b.verseNum));
            return _VerseList(
              verses: sorted,
              scriptureId: widget.scriptureId,
              chapterNum: widget.chapterNum,
              bookNum: widget.bookNum,
            );
          },
        ),
      ),
    );
  }
}

class _VerseListAppBarTitle extends StatelessWidget {
  const _VerseListAppBarTitle({
    required this.scriptureId,
    required this.chapterNum,
    required this.bookNum,
    required this.versesAsync,
  });

  final String scriptureId;
  final int chapterNum;
  final int? bookNum;
  final AsyncValue<Either<Failure, List<Verse>>> versesAsync;

  @override
  Widget build(BuildContext context) {
    if (scriptureId == 'bhagavad_gita') {
      final chapter = BhagavadGitaChapters.byNumber(chapterNum);
      final subtitle = versesAsync.maybeWhen(
        data: (either) => either.fold(
          (_) => chapter.englishName,
          (List<Verse> verses) {
            final n = verses.length;
            return '${chapter.englishName} · $n ${n == 1 ? 'verse' : 'verses'}';
          },
        ),
        orElse: () => chapter.englishName,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            chapter.sanskritName,
            style: context.ts.sanskritMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: context.ts.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    final displayName = ScriptureX.fromCode(scriptureId).displayName;
    String withCount(String base, int? n) {
      if (n == null) return base;
      return '$base · $n ${n == 1 ? 'verse' : 'verses'}';
    }

    final subtitle = versesAsync.maybeWhen(
      data: (Either<Failure, List<Verse>> either) => either.fold(
        (_) => bookNum != null
            ? 'Book $bookNum · Section $chapterNum'
            : 'Section $chapterNum',
        (List<Verse> verses) {
          final n = verses.length;
          final label = verses.isNotEmpty ? verses.first.chapterLabel : null;
          if (label != null && label.isNotEmpty) {
            return withCount(label, n);
          }
          final base = bookNum != null
              ? 'Book $bookNum · Section $chapterNum'
              : 'Section $chapterNum';
          return withCount(base, n);
        },
      ),
      orElse: () => bookNum != null
          ? 'Book $bookNum · Section $chapterNum'
          : 'Section $chapterNum',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayName,
          style: context.ts.labelLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          subtitle,
          style: context.ts.caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _VerseList extends ConsumerWidget {
  const _VerseList({
    required this.verses,
    required this.scriptureId,
    required this.chapterNum,
    required this.bookNum,
  });

  final List<Verse> verses;
  final String scriptureId;
  final int chapterNum;
  final int? bookNum;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readAsync = ref.watch(
      chapterReadCountProvider(scriptureId, chapterNum, bookNum),
    );
    final read = readAsync.value ?? 0;
    final total = verses.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.md,
            AppSpacing.pagePadding,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$read of $total verses read',
                    style: context.ts.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (total > 0)
                    Text(
                      '${(read / total * 100).round()}%',
                      style: context.ts.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: read == total && total > 0
                            ? AppColors.saffron
                            : AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total > 0 ? read / total : 0,
                  minHeight: 6,
                  backgroundColor: isDark ? AppColors.borderDark : AppColors.divider,
                  color: read == total && total > 0
                      ? AppColors.success
                      : AppColors.saffron,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: verses.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final verse = verses[index];
              return _VerseRow(
                verse: verse,
                scriptureId: scriptureId,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VerseRow extends ConsumerWidget {
  const _VerseRow({
    required this.verse,
    required this.scriptureId,
  });

  final Verse verse;
  final String scriptureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skLine = verse.sanskrit.split('\n').first.trim();
    final enLine = verse.english?.split('\n').first.trim() ?? '';
    final sanskritPreview = skLine.isNotEmpty
        ? skLine
        : (enLine.isNotEmpty ? enLine : 'Text not available for this verse');
    final previewIsPlaceholder = skLine.isEmpty && enLine.isEmpty;
    final allIds = ref.watch(bookmarkedIdsProvider).value ?? const {};
    final bookmarked = allIds.contains(verse.id);
    final isRead = verse.readCount > 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.xs,
      ),
      leading: SizedBox(
        width: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${verse.verseNum}',
              style: context.ts.labelSmall.copyWith(
                color: isRead ? AppColors.saffron : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRead)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.saffron,
                ),
              ),
          ],
        ),
      ),
      title: Semantics(
        label: 'Sanskrit verse: ${verse.transliteration ?? verse.id}',
        child: Text(
          sanskritPreview,
          style: previewIsPlaceholder
              ? context.ts.caption.copyWith(color: AppColors.textSecondary)
              : context.ts.sanskritMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: enLine.isNotEmpty
          ? Text(
              enLine,
              style: context.ts.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : (verse.noteText != null && verse.noteText!.isNotEmpty)
              ? Text(
                  'Has a note',
                  style: context.ts.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border,
              color: bookmarked ? AppColors.saffron : AppColors.textSecondary,
              size: 22,
            ),
            tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark verse',
            onPressed: () async {
              final dao = await ref.read(bookmarksDaoProvider.future);
              await dao.toggleBookmark(verse.id);
            },
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ],
      ),
      onTap: () => context.push(
        '/browse/$scriptureId/verse/${verse.id}',
      ),
    );
  }
}
