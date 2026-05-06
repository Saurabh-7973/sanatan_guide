import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanatan_guide/core/services/app_open_ad_service.dart';
import 'package:sanatan_guide/presentation/features/festivals/providers/festival_provider.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/home_strips.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/panchang_block.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/verse_hero_card.dart';
import 'package:sanatan_guide/presentation/features/learning_path/providers/learning_provider.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

/// Home — the "Today" tab.
///
/// Top to bottom:
///   PanchangBlock      greeting + Devanāgarī panchang + VS year + incised rule
///   VerseHeroCard      palm-leaf manuscript verse-of-day
///   ContinueStrip      last-read + 8 progress beads (hidden if no history)
///   PathStrip          next learning module (hidden if all complete)
///   FestivalPill       upcoming festival w/ moon glyph + days countdown
///
/// No sunrise, no painters, no almanac tiles, no streak line — those were
/// the old "Temple Dawn" direction. The Devanāgarī panchang line and the
/// verse hero card carry the visual heritage.
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

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        color: saffron,
        backgroundColor: surface,
        onRefresh: _refresh,
        child: const SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              Spacing.xxl,
              0,
              Spacing.xxl,
              Spacing.xxxl,
            ),
            child: Column(
              children: [
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
      ),
    );
  }
}
