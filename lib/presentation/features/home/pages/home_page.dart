import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/services/app_open_ad_service.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/presentation/features/festivals/providers/festival_provider.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/home_strips.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/panchang_block.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/verse_hero_card.dart';
import 'package:sanatan_guide/presentation/features/learning_path/providers/learning_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_top_bar.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

/// Home — the "Today" tab.
///
/// Steady state, top to bottom:
///   PanchangBlock      greeting + Devanāgarī panchang + VS year + incised rule
///   VerseHeroCard      palm-leaf manuscript verse-of-day
///   ContinueStrip      last-read + 8 progress beads (hidden if no history)
///   PathStrip          next learning module (hidden if all complete)
///   FestivalPill       upcoming festival w/ moon glyph + days countdown
///
/// First-day state (no reading history yet): the panchang/verse card switch
/// to their "Welcome" / "Your first verse" framing and the strips are replaced
/// by a "Where will you begin?" Foundations CTA + a browse-the-library link.
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

  Future<void> _refresh() async {
    ref.invalidate(verseOfDayProvider);
    ref.invalidate(modulesProvider);
    ref.invalidate(festivalsProvider);
    await ref.read(verseOfDayProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final bg = isDark ? DColors.bg : LColors.bg;
    final surface = isDark ? DColors.surface : LColors.surface;

    // First day = onboarding done but nothing read yet. Stay in steady state
    // until we actually know there's no history (don't flash the CTA).
    final lastReadAsync = ref.watch(lastReadVerseProvider);
    final isFirstDay = lastReadAsync.hasValue && lastReadAsync.value == null;

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        color: saffron,
        backgroundColor: surface,
        onRefresh: _refresh,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const HomeTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.xxl,
                    0,
                    Spacing.xxl,
                    Spacing.xxxl,
                  ),
                  child: Column(
                    children: isFirstDay
                        ? [
                            const PanchangBlock(isFirstDay: true),
                            const VerseHeroCard(isFirstDay: true),
                            const SizedBox(height: 28),
                            _FirstDayCta(isDark: isDark),
                            const SizedBox(height: 18),
                            _BrowseLibraryLink(isDark: isDark),
                          ]
                        : const [
                            PanchangBlock(),
                            VerseHeroCard(),
                            SizedBox(height: 24),
                            ContinueStrip(),
                            PathStrip(),
                            FestivalPill(),
                          ],
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

// ============================================================
// _FirstDayCta — "Where will you begin?" Foundations card
// ============================================================
class _FirstDayCta extends StatelessWidget {
  const _FirstDayCta({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final surface = isDark ? DColors.surface : LColors.surface;
    final divider = isDark ? DColors.divider : LColors.divider;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final onSaffron = isDark ? const Color(0xFF1A1208) : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: divider, width: 1),
      ),
      child: Column(
        children: [
          Text(
            '॥ श्री गणेशाय नमः ॥',
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontFamilyFallback: AppFontFallback.deva,
              fontSize: 14,
              letterSpacing: 0.56,
              color: saffron,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Where will you begin?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              height: 1.35,
              color: text1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Eight foundation modules introduce the essentials. '
            'Or step directly into a scripture.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontStyle: FontStyle.italic,
              fontSize: 14,
              height: 1.55,
              color: text2,
            ),
          ),
          const SizedBox(height: 22),
          Material(
            color: saffron,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: () => context.go('/learn'),
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                child: Text(
                  'OPEN FOUNDATIONS',
                  style: TextStyle(
                    fontFamily: Fonts.sans,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.04,
                    color: onSaffron,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// _BrowseLibraryLink — "OR BROWSE THE LIBRARY →"
// ============================================================
class _BrowseLibraryLink extends StatelessWidget {
  const _BrowseLibraryLink({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    return GestureDetector(
      onTap: () => context.go('/browse'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          'OR BROWSE THE LIBRARY  →',
          style: TextStyle(
            fontFamily: Fonts.sans,
            fontFamilyFallback: AppFontFallback.latin,
            fontSize: 11,
            letterSpacing: 1.76,
            color: text3,
          ),
        ),
      ),
    );
  }
}
