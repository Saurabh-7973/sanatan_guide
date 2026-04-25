import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/router/app_routes.dart';
import 'package:sanatan_guide/core/services/app_open_ad_service.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/almanac_tiles.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/dawn_horizon.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/festival_banner.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/home_app_bar.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/path_card.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/streak_line.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/verse_of_day_card.dart';
import 'package:sanatan_guide/presentation/features/learning_path/providers/learning_provider.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// Home screen — "Temple Dawn" direction.
///
/// Layered:
///   L0  Dawn background      → soft saffron radial glow from the top
///   L1  Horizon ornament     → sun arc + rays, sits behind the verse card
///   L2  Content list         → verse hero, almanac tiles, festival, path, streak
///
/// All existing providers are preserved (verseOfDayProvider, modulesProvider,
/// lastReadVerseProvider, currentStreakProvider, festivalsProvider). The
/// AppBar is replaced by a scrolling custom header so the dawn gradient
/// can reach the top edge of the screen.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppOpenAdService.instance.showIfReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppColors.bgDark : AppColors.cream,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── L0 Dawn background ──────────────────────────────────────
          const _DawnBackground(),

          // ── L2 Content (scrollable) ─────────────────────────────────
          RefreshIndicator(
            color: AppColors.saffron,
            backgroundColor: isDark
                ? AppColors.surfaceElevated
                : AppColors.surface,
            onRefresh: () async {
              ref.invalidate(verseOfDayProvider);
              ref.invalidate(modulesProvider);
              await ref.read(verseOfDayProvider.future);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Spacer for system status bar
                const SliverToBoxAdapter(child: SafeArea(bottom: false, child: SizedBox.shrink())),

                // Greeting + icon actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      AppSpacing.sm,
                      AppSpacing.pagePadding,
                      AppSpacing.xs,
                    ),
                    child: HomeAppBar(
                      onSearch: () => context.push(AppRoutes.search),
                      onSettings: () => context.push(AppRoutes.settings),
                    ),
                  ),
                ),

                // Sun horizon (sits in flow; the verse card crosses it)
                const SliverToBoxAdapter(
                  child: DawnHorizon(),
                ),

                // Verse hero
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      0,
                      AppSpacing.pagePadding,
                      0,
                    ),
                    child: VerseOfDayCard(),
                  ),
                ),

                // Celestial almanac (vāra · tithi · next parva)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      AppSpacing.lg,
                      AppSpacing.pagePadding,
                      0,
                    ),
                    child: AlmanacTiles(),
                  ),
                ),

                // Upcoming festival
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      AppSpacing.md,
                      AppSpacing.pagePadding,
                      0,
                    ),
                    child: FestivalBanner(),
                  ),
                ),

                // Path progress + continue reading
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      AppSpacing.md,
                      AppSpacing.pagePadding,
                      0,
                    ),
                    child: PathCard(),
                  ),
                ),

                // Streak
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      AppSpacing.lg,
                      AppSpacing.pagePadding,
                      AppSpacing.xxxl,
                    ),
                    child: StreakLine(),
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

/// Warm radial dawn glow — top-center fade into the scaffold colour.
/// Replaces the existing dark-mode-only glow with a palette-safe gradient
/// that works in both modes.
class _DawnBackground extends StatelessWidget {
  const _DawnBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tuned per mode: dark mode glow is slightly stronger to register
    // against #0F0F0F; light mode uses a whisper of saffron warmth.
    final List<Color> stops = isDark
        ? const [
            Color(0x38F4A830), // ~0.22 alpha saffronOnDark
            Color(0x0DF4A830), // ~0.05 alpha
            Color(0x00F4A830),
          ]
        : const [
            Color(0x38E8820C), // ~0.22 alpha saffron
            Color(0x12E8820C), // ~0.07 alpha
            Color(0x00E8820C),
          ];

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1.05),
            radius: 0.95,
            colors: stops,
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}
