import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/data/datasources/local/daos/bookmarks_dao.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
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
      appBar: AppBar(
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
      body: bookmarksAsync.when(
        loading: () => const BookmarkShimmer(),
        error: (e, _) => ErrorStateWidget(
          onRetry: () => ref.invalidate(enrichedBookmarksProvider),
        ),
        data: (bookmarks) {
          if (bookmarks.isEmpty) return const _EmptyState();
          return _BookmarkList(bookmarks: bookmarks);
        },
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '—',
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: 72,
                color: AppColors.warmGrey50,
                height: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Your saved verses will\nappear here',
              style: context.ts.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bookmark any verse to keep it\nclose, like a flower at the altar.',
              style: context.ts.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton.icon(
              onPressed: () => context.go('/browse'),
              icon: const Icon(Icons.menu_book_outlined, size: 18),
              label: const Text('Browse the library'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.saffron,
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

