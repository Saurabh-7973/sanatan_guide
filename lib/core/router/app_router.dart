import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/router/app_routes.dart';
import 'package:sanatan_guide/core/services/notification_service.dart';
import 'package:sanatan_guide/core/services/onboarding_service.dart';
import 'package:sanatan_guide/presentation/features/onboarding/pages/onboarding_page.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/pages/bookmarks_page.dart';
import 'package:sanatan_guide/presentation/features/festivals/pages/festival_calendar_page.dart';
import 'package:sanatan_guide/presentation/features/home/pages/home_page.dart';
import 'package:sanatan_guide/presentation/features/learning_path/pages/learning_path_page.dart';
import 'package:sanatan_guide/presentation/features/learning_path/pages/module_reader_page.dart';
import 'package:sanatan_guide/presentation/features/search/pages/search_page.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/pages/chapter_list_page.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/pages/scripture_library_page.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/pages/verse_chat_page.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/pages/verse_detail_page.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/pages/verse_list_page.dart';
import 'package:sanatan_guide/presentation/features/settings/pages/credits_page.dart';
import 'package:sanatan_guide/presentation/features/settings/pages/feedback_page.dart';
import 'package:sanatan_guide/presentation/features/settings/pages/settings_page.dart';
import 'package:sanatan_guide/presentation/shared/pages/coming_soon_page.dart';
import 'package:sanatan_guide/presentation/shared/widgets/scaffold_with_nav_bar.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart' as dt;
import 'package:shimmer/shimmer.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

/// Global [GoRouter]. Not auto-dispose — same lifetime as [ProviderScope].
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final deepLink = NotificationService.pendingDeepLink;
      if (deepLink != null && deepLink.isNotEmpty) {
        NotificationService.pendingDeepLink = null;
        return deepLink;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const _SplashPage(),
      ),
      GoRoute(
        path: '/learn/:moduleId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (ctx, state) {
          final moduleId = state.pathParameters['moduleId']!;
          return _slideTransition(
            state,
            ModuleReaderPage(moduleId: moduleId),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/browse/:scriptureId/verse/:verseId',
        pageBuilder: (ctx, state) {
          final verseId = state.pathParameters['verseId']!;
          return _fadeSlideUpTransition(
            state,
            VerseDetailPage(verseId: verseId),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/browse/:scriptureId/verse/:verseId/chat',
        pageBuilder: (ctx, state) {
          final verseId = state.pathParameters['verseId']!;
          return _slideTransition(
            state,
            VerseChatPage(verseId: verseId),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/browse/:scriptureId/chapter/:chapterNum',
        pageBuilder: (ctx, state) {
          final scriptureId = state.pathParameters['scriptureId']!;
          final chapterNum = int.parse(state.pathParameters['chapterNum']!);
          final bookStr = state.uri.queryParameters['book'];
          final bookNum = bookStr != null ? int.tryParse(bookStr) : null;
          return _slideTransition(
            state,
            VerseListPage(
              scriptureId: scriptureId,
              chapterNum: chapterNum,
              bookNum: bookNum,
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/browse/:scriptureId',
        pageBuilder: (ctx, state) {
          final scriptureId = state.pathParameters['scriptureId']!;
          return _slideTransition(
            state,
            ChapterListPage(scriptureId: scriptureId),
          );
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.search,
        pageBuilder: (_, state) => _fadeSlideUpTransition(
          state,
          const SearchPage(),
        ),
      ),
      // ── Out of the bottom-nav shell (brief §3.1: nav only on the 3 tab
      //    roots). Pushed on the root navigator → back-button chrome. ──
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.bookmarks,
        pageBuilder: (_, state) =>
            _fadeSlideUpTransition(state, const BookmarksPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.festivals,
        pageBuilder: (_, state) =>
            _fadeSlideUpTransition(state, const FestivalCalendarPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.settings,
        pageBuilder: (_, state) =>
            _fadeSlideUpTransition(state, const SettingsPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/credits',
        pageBuilder: (_, state) =>
            _fadeSlideUpTransition(state, const CreditsPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.feedback,
        pageBuilder: (_, state) =>
            _fadeSlideUpTransition(state, const FeedbackPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.chatGeneral,
        pageBuilder: (_, state) => _fadeSlideUpTransition(
          state,
          const ComingSoonPage(title: 'Ask the Pandit'),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: '/learn',
            builder: (_, __) => const LearningPathPage(),
          ),
          GoRoute(
            path: AppRoutes.browse,
            builder: (_, __) => const ScriptureLibraryPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
});

class _SplashPage extends ConsumerStatefulWidget {
  const _SplashPage();

  @override
  ConsumerState<_SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<_SplashPage> {
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    // Read the onboarding flag first so the shimmer can match the screen the
    // user is about to land on (Home skeleton vs Onboarding skeleton).
    final isComplete = await OnboardingService.isComplete();
    if (!mounted) return;
    setState(() => _onboardingComplete = isComplete);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    if (isComplete) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_onboardingComplete) {
        true => const _HomeSplashShimmer(),
        false => const _OnboardingSplashShimmer(),
        // Brief gap (~one prefs read) before we know which skeleton to draw;
        // native splash is still fading so a blank Scaffold is invisible here.
        null => const SizedBox.shrink(),
      },
    );
  }
}

// ── Page transitions ──────────────────────────────────────────────────────

const _kTransitionDuration = Duration(milliseconds: 300);
const _kTransitionCurve = Curves.easeOutCubic;

CustomTransitionPage<void> _slideTransition(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: _kTransitionDuration,
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: _kTransitionCurve,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _fadeSlideUpTransition(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: _kTransitionDuration,
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: _kTransitionCurve,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

// ── Splash shimmers ───────────────────────────────────────────────────────

/// Skeleton matching screen-11 onboarding (Welcome step) so first-launch users
/// don't see a flash of the Home shimmer before the onboarding page renders.
class _OnboardingSplashShimmer extends StatelessWidget {
  const _OnboardingSplashShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.surfaceDark : AppColors.surfaceVariant,
      highlightColor: isDark ? AppColors.surfaceElevated : AppColors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: dt.Spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: dt.Spacing.xxxl),
              // Invocation (॥ श्री गणेशाय नमः ॥)
              const Center(
                child: ShimmerLine(height: 12, width: 140, borderRadius: 4),
              ),
              const SizedBox(height: dt.Spacing.xl),
              // Two step dots
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerLine(height: 6, width: 6, borderRadius: 3),
                  SizedBox(width: 10),
                  ShimmerLine(height: 6, width: 6, borderRadius: 3),
                ],
              ),
              const SizedBox(height: dt.Spacing.xxl),
              // ॐ glyph block
              const Center(
                child: ShimmerLine(height: 68, width: 68, borderRadius: 14),
              ),
              const SizedBox(height: dt.Spacing.lg),
              // Sanatan Guide title
              const Center(
                child: ShimmerLine(height: 28, width: 200, borderRadius: 6),
              ),
              const SizedBox(height: 10),
              // Two-line tagline
              const Center(
                child: ShimmerLine(height: 14, width: 280, borderRadius: 4),
              ),
              const SizedBox(height: dt.Spacing.xs),
              const Center(
                child: ShimmerLine(height: 14, width: 200, borderRadius: 4),
              ),
              const SizedBox(height: 22),
              // Binding ornament
              const Center(
                child: ShimmerLine(height: 4, width: 64, borderRadius: 2),
              ),
              const SizedBox(height: dt.Spacing.xxxl),
              // Section label
              const Center(
                child: ShimmerLine(height: 11, width: 140, borderRadius: 4),
              ),
              const SizedBox(height: dt.Spacing.sm),
              // Question line
              const Center(
                child: ShimmerLine(height: 18, width: 260, borderRadius: 4),
              ),
              const SizedBox(height: dt.Spacing.xl),
              // Three level cards
              for (var i = 0; i < 3; i++) ...const [
                ShimmerLine(height: 78, borderRadius: 12),
                SizedBox(height: 10),
              ],
              const Spacer(),
              // Continue button
              const ShimmerLine(height: 52, borderRadius: 26),
              const SizedBox(height: dt.Spacing.md),
              // Skip text
              const Center(
                child: ShimmerLine(height: 12, width: 96, borderRadius: 4),
              ),
              const SizedBox(height: dt.Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSplashShimmer extends StatelessWidget {
  const _HomeSplashShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.sizeOf(context).width;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.surfaceDark : AppColors.surfaceVariant,
      highlightColor: isDark ? AppColors.surfaceElevated : AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HomeTopBar (सनातन brand + search/bookmark/⋯) ──────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 16, 14),
              child: Row(
                children: [
                  const ShimmerLine(height: 22, width: 62, borderRadius: 6),
                  const Spacer(),
                  for (var i = 0; i < 3; i++)
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: ShimmerLine(
                          height: 20,
                          width: 20,
                          borderRadius: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Greeting + panchang (PanchangBlock) ───────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                4,
                AppSpacing.pagePadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLine(height: 22, width: 160, borderRadius: 6),
                  SizedBox(height: 6),
                  ShimmerLine(height: 11, width: 110, borderRadius: 4),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  AppSpacing.xl,
                  AppSpacing.pagePadding,
                  AppSpacing.xxxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Verse of the Day card ─────────────────────────────
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ShimmerLine(
                                  height: 10, width: 110, borderRadius: 4),
                              Spacer(),
                              ShimmerLine(
                                  height: 12, width: 60, borderRadius: 4),
                            ],
                          ),
                          SizedBox(height: AppSpacing.lg),
                          Center(
                              child: ShimmerLine(
                                  height: 22, width: 240, borderRadius: 6)),
                          SizedBox(height: AppSpacing.sm),
                          Center(
                              child: ShimmerLine(
                                  height: 22, width: 180, borderRadius: 6)),
                          SizedBox(height: AppSpacing.lg),
                          ShimmerLine(height: 14, borderRadius: 4),
                          SizedBox(height: AppSpacing.xs),
                          ShimmerLine(height: 14, width: 260, borderRadius: 4),
                          SizedBox(height: AppSpacing.md),
                          ShimmerLine(height: 11, width: 140, borderRadius: 4),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Panchang row ──────────────────────────────────────
                    Row(
                      children: [
                        const ShimmerLine(
                            height: 22, width: 22, borderRadius: 11),
                        const SizedBox(width: AppSpacing.sm),
                        ShimmerLine(
                            height: 14, width: w * 0.55, borderRadius: 4),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // ── Festival row ──────────────────────────────────────
                    Row(
                      children: [
                        const ShimmerLine(
                            height: 22, width: 22, borderRadius: 11),
                        const SizedBox(width: AppSpacing.sm),
                        ShimmerLine(
                            height: 14, width: w * 0.38, borderRadius: 4),
                        const Spacer(),
                        const ShimmerLine(
                            height: 12, width: 56, borderRadius: 4),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Learning progress ─────────────────────────────────
                    const ShimmerLine(height: 13, width: 100, borderRadius: 4),
                    const SizedBox(height: AppSpacing.sm),
                    const ShimmerLine(height: 6, borderRadius: 3),
                    const SizedBox(height: AppSpacing.xs),
                    const ShimmerLine(height: 11, width: 80, borderRadius: 4),

                    const SizedBox(height: AppSpacing.sm),

                    // ── Continue reading row ──────────────────────────────
                    Row(
                      children: [
                        const ShimmerLine(
                            height: 18, width: 18, borderRadius: 9),
                        const SizedBox(width: AppSpacing.sm),
                        ShimmerLine(
                            height: 13, width: w * 0.55, borderRadius: 4),
                        const Spacer(),
                        const ShimmerLine(
                            height: 12, width: 12, borderRadius: 2),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Streak footer ─────────────────────────────────────
                    const ShimmerLine(height: 13, width: 180, borderRadius: 4),
                  ],
                ),
              ),
            ),

            // ── Bottom nav (matches ScaffoldWithNavBar) ──────────────────
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 4),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShimmerLine(
                                  height: 22,
                                  width: 22,
                                  borderRadius: 11,
                                ),
                                SizedBox(height: 5),
                                ShimmerLine(
                                  height: 9,
                                  width: 34,
                                  borderRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
