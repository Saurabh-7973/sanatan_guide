import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/data/datasources/local/daos/bookmarks_dao.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/shared/widgets/verse_preview_tile.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(enrichedBookmarksProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('Saved Verses'),
        centerTitle: false,
        actions: [
          if (bookmarksAsync.value != null && bookmarksAsync.value!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Badge(
                label: Text('${bookmarksAsync.value!.length}'),
                backgroundColor: AppColors.saffron,
                child: const Icon(Icons.bookmark_rounded),
              ),
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.paddingOf(context).top,
              ),
              child: bookmarksAsync.when(
                loading: () => const BookmarkShimmer(),
                error: (e, _) => ErrorStateWidget(
                  onRetry: () => ref.invalidate(enrichedBookmarksProvider),
                ),
                data: (bookmarks) {
                  if (bookmarks.isEmpty) return const _EmptyState();
                  return _BookmarkList(bookmarks: bookmarks);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: isDark ? 0.18 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 36,
                color: tint,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Saved verses appear here',
              style: context.ts.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap the bookmark icon on any verse\nto keep it close.',
              style: context.ts.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () => context.go('/browse'),
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              label: const Text('Browse the library'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.saffron,
                foregroundColor: AppColors.onSaffron,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bookmark list ────────────────────────────────────────────────────────

class _BookmarkList extends ConsumerWidget {
  const _BookmarkList({required this.bookmarks});
  final List<EnrichedBookmark> bookmarks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.sm,
        AppSpacing.pagePadding,
        AppSpacing.xxl,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: bookmarks.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final bm = bookmarks[index];
        return _SwipeableTile(bookmark: bm, ref: ref);
      },
    );
  }
}

class _SwipeableTile extends StatelessWidget {
  const _SwipeableTile({required this.bookmark, required this.ref});

  final EnrichedBookmark bookmark;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(bookmark.verseId),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.pagePadding),
        color: AppColors.error.withValues(alpha: 0.12),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
        ),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) async {
        final dao = await ref.read(bookmarksDaoProvider.future);
        await dao.toggleBookmark(bookmark.verseId);
        ref.invalidate(enrichedBookmarksProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bookmark removed'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: VersePreviewTile(
        locationLabel: bookmark.verseId,
        sanskritPreview: bookmark.sanskritPreview
            ?.split('\n')
            .first
            .trim(),
        savedAt: bookmark.savedAt,
        onTap: () {
          final code = bookmark.scriptureCode ??
              scriptureCodeFromVerseId(bookmark.verseId);
          context.push('/browse/$code/verse/${bookmark.verseId}');
        },
      ),
    );
  }
}

