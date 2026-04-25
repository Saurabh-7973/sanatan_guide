import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

Widget _shimmer(BuildContext context, {required Widget child}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Shimmer.fromColors(
    baseColor: isDark ? AppColors.surfaceDark : AppColors.surfaceVariant,
    highlightColor:
        isDark ? AppColors.surfaceElevated : AppColors.surface,
    child: child,
  );
}

/// Generic centered list of shimmer rows.
class CenteredListShimmer extends StatelessWidget {
  const CenteredListShimmer({super.key, this.rowCount = 6});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      context,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.lg,
        ),
        itemCount: rowCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, __) => const ShimmerLine(height: 14, borderRadius: 6),
      ),
    );
  }
}

class ShimmerLine extends StatelessWidget {
  const ShimmerLine({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = 4,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer list mimicking verse list rows (~8).
class VerseListShimmer extends StatelessWidget {
  const VerseListShimmer({super.key, this.rowCount = 8});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      context,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          AppSpacing.lg,
          AppSpacing.pagePadding,
          AppSpacing.xl,
        ),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: rowCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ShimmerLine(height: 12, width: 48, borderRadius: 4),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ShimmerLine(height: 14, borderRadius: 4),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              ShimmerLine(height: 12, borderRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer mimicking chapter list (~6 rows).
class ChapterListShimmer extends StatelessWidget {
  const ChapterListShimmer({super.key, this.rowCount = 6});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      context,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.lg,
        ),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: rowCount,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.listItemSpacing),
        itemBuilder: (_, index) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceElevated
                      : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLine(
                      height: 14,
                      width: MediaQuery.sizeOf(context).width * 0.45,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 6),
                    const ShimmerLine(height: 11, width: 80, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
        },
      ),
    );
  }
}

/// Shimmer for verse detail loading (title + text blocks).
class VerseDetailShimmer extends StatelessWidget {
  const VerseDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      context,
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ShimmerLine(height: 28, width: 120, borderRadius: 20),
            ),
            SizedBox(height: AppSpacing.xl),
            ShimmerLine(height: 20, borderRadius: 6),
            SizedBox(height: AppSpacing.sm),
            ShimmerLine(height: 20, borderRadius: 6),
            SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 120,
              child: ShimmerLine(height: 120, borderRadius: 8),
            ),
            SizedBox(height: AppSpacing.lg),
            ShimmerLine(height: 14, borderRadius: 4),
            SizedBox(height: AppSpacing.xs),
            ShimmerLine(height: 16, borderRadius: 4),
            SizedBox(height: AppSpacing.xs),
            ShimmerLine(height: 16, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// Shimmer for bookmark list (~4 tiles).
class BookmarkShimmer extends StatelessWidget {
  const BookmarkShimmer({super.key, this.tileCount = 4});

  final int tileCount;

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      context,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.pagePadding,
        ),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: tileCount,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.listItemSpacing),
        itemBuilder: (_, index) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
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
                  color: isDark
                      ? AppColors.surfaceElevated
                      : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLine(height: 14, borderRadius: 4),
                    const SizedBox(height: AppSpacing.xs),
                    ShimmerLine(
                      height: 12,
                      width: MediaQuery.sizeOf(context).width * 0.5,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        },
      ),
    );
  }
}

/// Single bookmark row while verse content loads.
class BookmarkRowShimmer extends StatelessWidget {
  const BookmarkRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    return _shimmer(
      context,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceElevated : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLine(height: 14, width: 160, borderRadius: 4),
                  SizedBox(height: AppSpacing.sm),
                  ShimmerLine(height: 12, borderRadius: 4),
                  SizedBox(height: AppSpacing.xs),
                  ShimmerLine(height: 12, width: 200, borderRadius: 4),
                  SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ShimmerLine(height: 10, width: 72, borderRadius: 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Learning path shimmer — timeline of 4 module cards.
class LearningPathShimmer extends StatelessWidget {
  const LearningPathShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      context,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          AppSpacing.lg,
          AppSpacing.pagePadding,
          AppSpacing.xl,
        ),
        itemCount: 5,
        itemBuilder: (_, i) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline dot
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceElevated : AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (i < 4)
                      Container(
                        width: 1,
                        height: 60,
                        color: isDark ? AppColors.surfaceElevated : AppColors.surfaceVariant,
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                // Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerLine(height: 13, width: 60, borderRadius: 4),
                        const SizedBox(height: AppSpacing.xs),
                        ShimmerLine(
                          height: 16,
                          width: MediaQuery.sizeOf(context).width * 0.5,
                          borderRadius: 4,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const ShimmerLine(height: 11, borderRadius: 4),
                        const SizedBox(height: AppSpacing.xs),
                        ShimmerLine(
                          height: 11,
                          width: MediaQuery.sizeOf(context).width * 0.4,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Module reader shimmer — card with text blocks + nav.
class ModuleReaderShimmer extends StatelessWidget {
  const ModuleReaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _shimmer(
      context,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Counter
            const Center(child: ShimmerLine(height: 12, width: 48, borderRadius: 20)),
            const SizedBox(height: AppSpacing.xl),
            // Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLine(height: 11, width: 80, borderRadius: 4),
                  SizedBox(height: AppSpacing.sm),
                  ShimmerLine(height: 18, width: 200, borderRadius: 4),
                  SizedBox(height: AppSpacing.lg),
                  ShimmerLine(height: 14, borderRadius: 4),
                  SizedBox(height: AppSpacing.xs),
                  ShimmerLine(height: 14, borderRadius: 4),
                  SizedBox(height: AppSpacing.xs),
                  ShimmerLine(height: 14, width: 220, borderRadius: 4),
                  SizedBox(height: AppSpacing.md),
                  ShimmerLine(height: 14, borderRadius: 4),
                  SizedBox(height: AppSpacing.xs),
                  ShimmerLine(height: 14, width: 180, borderRadius: 4),
                ],
              ),
            ),
            const Spacer(),
            // Nav row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerLine(height: 36, width: 100, borderRadius: 20),
                ShimmerLine(height: 36, width: 100, borderRadius: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// Festival calendar shimmer — header + calendar grid.
class FestivalShimmer extends StatelessWidget {
  const FestivalShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      context,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month header
            const ShimmerLine(height: 20, width: 140, borderRadius: 4),
            const SizedBox(height: AppSpacing.lg),
            // Weekday labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                7,
                (_) => const ShimmerLine(height: 10, width: 24, borderRadius: 4),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Calendar grid (5 rows × 7 cols)
            ...List.generate(5, (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  7,
                  (_) => const ShimmerLine(height: 32, width: 32, borderRadius: 6),
                ),
              ),
            )),
            const SizedBox(height: AppSpacing.xl),
            // Upcoming events
            const ShimmerLine(height: 13, width: 120, borderRadius: 4),
            const SizedBox(height: AppSpacing.md),
            ...List.generate(3, (_) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: ShimmerLine(height: 52, borderRadius: 8),
            )),
          ],
        ),
      ),
    );
  }
}

/// Scripture library shimmer — featured card + grid.
class ScriptureLibraryShimmer extends StatelessWidget {
  const ScriptureLibraryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      context,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured card
            const ShimmerLine(height: 160, borderRadius: 16),
            const SizedBox(height: AppSpacing.xl),
            // Section label
            const ShimmerLine(height: 11, width: 80, borderRadius: 4),
            const SizedBox(height: AppSpacing.md),
            // 2-col grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.1,
              ),
              itemCount: 8,
              itemBuilder: (_, __) => const ShimmerLine(height: 120, borderRadius: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Learning progress summary shimmer (home screen widget).
class LearningProgressShimmer extends StatelessWidget {
  const LearningProgressShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      context,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLine(height: 13, width: 100, borderRadius: 4),
          SizedBox(height: AppSpacing.sm),
          ShimmerLine(height: 6, borderRadius: 3),
          SizedBox(height: AppSpacing.xs),
          ShimmerLine(height: 11, width: 80, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Verse-of-day shimmer matching the borderless _VerseHero layout.
class VerseOfDayCardShimmer extends StatelessWidget {
  const VerseOfDayCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      context,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                ShimmerLine(height: 10, width: 110, borderRadius: 4),
                Spacer(),
                ShimmerLine(height: 12, width: 80, borderRadius: 4),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Center(
              child: ShimmerLine(height: 22, width: 240, borderRadius: 6),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Center(
              child: ShimmerLine(height: 22, width: 180, borderRadius: 6),
            ),
            const SizedBox(height: AppSpacing.lg),
            const ShimmerLine(height: 14, borderRadius: 4),
            const SizedBox(height: AppSpacing.xs),
            ShimmerLine(
              height: 14,
              width: MediaQuery.sizeOf(context).width * 0.75,
              borderRadius: 4,
            ),
            const SizedBox(height: AppSpacing.md),
            const ShimmerLine(height: 11, width: 140, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}
