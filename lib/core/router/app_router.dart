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
import 'package:sanatan_guide/presentation/features/settings/pages/settings_page.dart';
import 'package:sanatan_guide/presentation/shared/widgets/scaffold_with_nav_bar.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';
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
            path: AppRoutes.festivals,
            builder: (_, __) => const FestivalCalendarPage(),
          ),
          GoRoute(
            path: AppRoutes.bookmarks,
            builder: (_, __) => const BookmarksPage(),
          ),
          GoRoute(
            path: AppRoutes.browse,
            builder: (_, __) => const ScriptureLibraryPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsPage(),
          ),
          GoRoute(
            path: '/credits',
            builder: (_, __) => const CreditsPage(),
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate(context, ref);
    });
  }

  Future<void> _navigate(BuildContext context, WidgetRef ref) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final isComplete = await OnboardingService.isComplete();
    if (context.mounted) {
      if (isComplete) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _HomeSplashShimmer(),
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

// ── Splash shimmer ────────────────────────────────────────────────────────

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
            // ── AppBar (64px toolbar) ─────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pagePadding, 16,
                AppSpacing.pagePadding, 0,
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
                  AppSpacing.pagePadding, AppSpacing.xl,
                  AppSpacing.pagePadding, AppSpacing.xxxl,
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
                              ShimmerLine(height: 10, width: 110, borderRadius: 4),
                              Spacer(),
                              ShimmerLine(height: 12, width: 60, borderRadius: 4),
                            ],
                          ),
                          SizedBox(height: AppSpacing.lg),
                          Center(child: ShimmerLine(height: 22, width: 240, borderRadius: 6)),
                          SizedBox(height: AppSpacing.sm),
                          Center(child: ShimmerLine(height: 22, width: 180, borderRadius: 6)),
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
                        const ShimmerLine(height: 22, width: 22, borderRadius: 11),
                        const SizedBox(width: AppSpacing.sm),
                        ShimmerLine(height: 14, width: w * 0.55, borderRadius: 4),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // ── Festival row ──────────────────────────────────────
                    Row(
                      children: [
                        const ShimmerLine(height: 22, width: 22, borderRadius: 11),
                        const SizedBox(width: AppSpacing.sm),
                        ShimmerLine(height: 14, width: w * 0.38, borderRadius: 4),
                        const Spacer(),
                        const ShimmerLine(height: 12, width: 56, borderRadius: 4),
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
                        const ShimmerLine(height: 18, width: 18, borderRadius: 9),
                        const SizedBox(width: AppSpacing.sm),
                        ShimmerLine(height: 13, width: w * 0.55, borderRadius: 4),
                        const Spacer(),
                        const ShimmerLine(height: 12, width: 12, borderRadius: 2),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Streak footer ─────────────────────────────────────
                    const ShimmerLine(height: 13, width: 180, borderRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
