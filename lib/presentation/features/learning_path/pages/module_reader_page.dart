import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/services/ad_service.dart';
import 'package:sanatan_guide/core/services/analytics_service.dart';
import 'package:sanatan_guide/core/services/review_service.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/domain/entities/learning_module.dart';
import 'package:sanatan_guide/presentation/features/learning_path/providers/learning_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/sacred_ornaments.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class ModuleReaderPage extends ConsumerStatefulWidget {
  const ModuleReaderPage({super.key, required this.moduleId});

  final String moduleId;

  @override
  ConsumerState<ModuleReaderPage> createState() => _ModuleReaderPageState();
}

class _ModuleReaderPageState extends ConsumerState<ModuleReaderPage> {
  int? _currentIndex;
  InterstitialAd? _interstitialAd;
  late final String _moduleId = widget.moduleId;
  // Stored in didChangeDependencies so dispose() can invalidate safely
  // without touching ref (forbidden by Riverpod 3.x during unmount).
  ProviderContainer? _container;

  @override
  void initState() {
    super.initState();
    if (AdService.isEnabled) _preloadInterstitial();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container = ProviderScope.containerOf(context, listen: false);
  }

  void _preloadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdService.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (mounted) {
            _interstitialAd = ad;
          } else {
            ad.dispose();
          }
        },
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
    _container?.invalidate(modulesProvider);
    _container?.invalidate(moduleDetailProvider(_moduleId));
  }

  List<_CardData> _buildCardSequence(ModuleDetail detail) {
    final cards = <_CardData>[];

    for (final card in detail.cards) {
      cards.add(
        _CardData(
          type: _CardType.content,
          title: card.cardTitle,
          body: card.content,
          sequence: card.sequence,
        ),
      );
    }

    if (detail.anchorVerseId != null) {
      cards.add(
        _CardData(
          type: _CardType.anchor,
          title: 'Key Verse',
          body: detail.anchorVerseNote ?? '',
          verseId: detail.anchorVerseId,
        ),
      );
    }

    if (detail.reflectionQuestion != null) {
      cards.add(
        _CardData(
          type: _CardType.reflection,
          title: 'Reflect',
          body: detail.reflectionQuestion!,
        ),
      );
    }

    cards.add(
      _CardData(
        type: _CardType.completion,
        title: detail.module.title,
        body: '',
      ),
    );

    return cards;
  }

  Future<void> _advance(ModuleDetail detail, List<_CardData> cards) async {
    final isLastCard = _currentIndex == cards.length - 1;

    if (isLastCard) {
      void navigateBack() {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/learn');
        }
      }

      if (AdService.isEnabled && _interstitialAd != null) {
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            if (context.mounted) navigateBack();
          },
          onAdFailedToShowFullScreenContent: (ad, _) {
            ad.dispose();
            if (context.mounted) navigateBack();
          },
        );
        await _interstitialAd!.show();
        _interstitialAd = null;
      } else {
        if (context.mounted) navigateBack();
      }
      return;
    }

    if (_currentIndex! < detail.cards.length) {
      final repo = await ref.read(learningRepositoryProvider.future);
      final result = await repo.markCardRead(
        moduleId: widget.moduleId,
        cardSequence: _currentIndex! + 1,
        totalCards: detail.cards.length,
      );
      result.fold((_) {}, (_) {});
    }

    // Record streak for any module card advance
    await StreakService.recordReadingToday();
    ref.invalidate(currentStreakProvider);
    ref.invalidate(readHistoryProvider);

    if (_currentIndex == cards.length - 2) {
      final useCase = await ref.read(completeModuleUseCaseProvider.future);
      final done = await useCase.execute(widget.moduleId);
      done.fold((_) {}, (_) {
        ref.invalidate(modulesProvider);
        ref.invalidate(moduleDetailProvider(widget.moduleId));
        AnalyticsService.moduleCompleted(widget.moduleId);
        unawaited(
          ReviewService.maybeRequestReview(ReviewTrigger.moduleCompleted),
        );
      });
    }

    setState(() => _currentIndex = _currentIndex! + 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(moduleDetailProvider(widget.moduleId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(child: PeepalTreeBackdrop()),
          ),
          state.when(
        loading: () => const ModuleReaderShimmer(),
        error: (e, _) => const ErrorStateWidget(),
        data: (either) => either.fold(
          (failure) => ErrorStateWidget(message: failure.message),
          (detail) {
            final cards = _buildCardSequence(detail);
            if (cards.isEmpty) return const Center(child: Text('No cards for this module.'));

            if (_currentIndex == null) {
              final read = detail.module.cardsRead;
              if (detail.module.isCompleted) {
                // Already completed — land on completion card so user can
                // review book recs / "Read in App" without replaying all cards.
                _currentIndex = cards.length - 1;
              } else if (read <= 0) {
                _currentIndex = 0;
              } else {
                // Resume at the next unread card (cardsRead is 1-based sequence
                // of the last card the user tapped through, so index = cardsRead).
                // Clamp in case extras (anchor/reflection/completion) were counted.
                _currentIndex = read.clamp(0, cards.length - 1);
              }
            }

            final currentIdx = _currentIndex!;
            if (currentIdx >= cards.length) {
              return const Center(child: Text('No cards for this module.'));
            }

            final card = cards[currentIdx];
            final isLast = currentIdx == cards.length - 1;
            final progress = (currentIdx + 1) / cards.length;

            return GestureDetector(
              onTap: () => _advance(detail, cards),
              behavior: HitTestBehavior.opaque,
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Module title ──────────────────────────────────────────
                          Row(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                                tooltip: 'Close',
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/learn');
                                  }
                                },
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  detail.module.title,
                                  style: context.ts.captionHighlight,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${_currentIndex! + 1} / ${cards.length}',
                                style: context.ts.caption,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          // ── Progress bar ──────────────────────────────────────────
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: isDark ? AppColors.borderDark : AppColors.border,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.saffron,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: KeyedSubtree(
                          key: ValueKey<int>(_currentIndex!),
                          child: _buildCard(context, card, detail),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: Text(
                          'Tap anywhere to continue',
                          style: context.ts.caption.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    _CardData card,
    ModuleDetail detail,
  ) {
    return switch (card.type) {
      _CardType.content => _ContentCard(card: card),
      _CardType.anchor => _AnchorCard(card: card),
      _CardType.reflection => _ReflectionCard(card: card),
      _CardType.completion => _CompletionCard(module: detail.module),
    };
  }
}

enum _CardType { content, anchor, reflection, completion }

class _CardData {
  const _CardData({
    required this.type,
    required this.title,
    required this.body,
    this.sequence,
    this.verseId,
  });

  final _CardType type;
  final String title;
  final String body;
  final int? sequence;
  final String? verseId;
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.card});

  final _CardData card;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Text(card.title, style: context.ts.cardLabel),
          const SizedBox(height: AppSpacing.lg),
          Text(card.body, style: context.ts.bodyLarge),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _AnchorCard extends StatelessWidget {
  const _AnchorCard({required this.card});

  final _CardData card;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? Colors.transparent : AppColors.saffronFaint,
      child: Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.deepRedMuted,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Text(
              'KEY VERSE',
              style: context.ts.cardLabel.copyWith(
                color: AppColors.deepRed,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(card.body, style: context.ts.bodyLarge),
          if (card.verseId != null) ...[
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              icon: const Icon(Icons.menu_book_outlined, size: 16),
              label: Text('Read ${card.verseId} in the Gita'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.saffron,
                side: const BorderSide(color: AppColors.saffron),
              ),
              onPressed: () => context.push(
                '/browse/bhagavad_gita/verse/${card.verseId}',
              ),
            ),
          ],
          const Spacer(flex: 3),
        ],
      ),
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({required this.card});

  final _CardData card;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? Colors.transparent : AppColors.warmGrey10,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Spacer(flex: 2),
            const Icon(
              Icons.self_improvement_outlined,
              color: AppColors.warmGrey50,
              size: 36,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Reflect', style: context.ts.cardLabel),
            const SizedBox(height: AppSpacing.md),
            Text(
              card.body,
              style: context.ts.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Sit with this question. Tap to continue when ready.',
              style: context.ts.caption.copyWith(color: AppColors.textHint),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.module});

  final LearningModule module;

  // Book recommendations per module — matched to actual module titles.
  // We use Amazon Search URLs so they never break.
  static const Map<String, List<_BookRec>> _books = {
    // mod_01: What is Sanatan Dharma?
    'mod_01': [
      _BookRec(
        title: 'Complete Works Vol. 1',
        author: 'Swami Vivekananda',
        url: 'https://www.amazon.in/s?k=Complete+Works+Vol+1+Swami+Vivekananda',
      ),
      _BookRec(
        title: 'The Essentials of Hinduism',
        author: 'Swami Bhaskarananda',
        url: 'https://www.amazon.in/s?k=Essentials+of+Hinduism+Swami+Bhaskarananda',
      ),
    ],
    // mod_02: The Five Core Concepts
    'mod_02': [
      _BookRec(
        title: 'The Essentials of Hinduism',
        author: 'Swami Bhaskarananda',
        url: 'https://www.amazon.in/s?k=Essentials+of+Hinduism+Swami+Bhaskarananda',
      ),
      _BookRec(
        title: 'An Introduction to Hindu Philosophy',
        author: 'Subhash Kak',
        url: 'https://www.amazon.in/s?k=Introduction+to+Hindu+Philosophy+Subhash+Kak',
      ),
    ],
    // mod_03: The Trimurti and Major Deities
    'mod_03': [
      _BookRec(
        title: 'Hindu Gods and Goddesses',
        author: 'Swami Harshananda',
        url: 'https://www.amazon.in/s?k=Hindu+Gods+and+Goddesses+Swami+Harshananda',
      ),
      _BookRec(
        title: 'Myths and Symbols in Indian Art and Civilization',
        author: 'Heinrich Zimmer',
        url: 'https://www.amazon.in/s?k=Myths+Symbols+Indian+Art+Civilization+Zimmer',
      ),
    ],
    // mod_04: Sacred Symbols and Their Meanings
    'mod_04': [
      _BookRec(
        title: 'Symbolism in Hinduism',
        author: 'Swami Chinmayananda',
        url: 'https://www.amazon.in/s?k=Symbolism+in+Hinduism+Swami+Chinmayananda',
      ),
      _BookRec(
        title: 'Hindu Symbols and Their Meanings',
        author: 'Swami Sivananda',
        url: 'https://www.amazon.in/s?k=Hindu+Symbols+Meanings+Swami+Sivananda',
      ),
    ],
    // mod_05: Festivals and Their Dharmic Logic
    'mod_05': [
      _BookRec(
        title: 'Festivals of India',
        author: 'Shakti M. Gupta',
        url: 'https://www.amazon.in/s?k=Festivals+of+India+Shakti+M.+Gupta',
      ),
      _BookRec(
        title: 'Hindu Fasts and Festivals',
        author: 'Swami Sivananda',
        url: 'https://www.amazon.in/s?k=Hindu+Fasts+and+Festivals+Swami+Sivananda',
      ),
    ],
    // mod_06: Daily Practice: Dinacharya
    'mod_06': [
      _BookRec(
        title: 'The Complete Book of Ayurvedic Home Remedies',
        author: 'Dr. Vasant Lad',
        url: 'https://www.amazon.in/s?k=Complete+Book+Ayurvedic+Home+Remedies+Vasant+Lad',
      ),
      _BookRec(
        title: 'Daily Life in Ancient India',
        author: 'Jeannine Auboyer',
        url: 'https://www.amazon.in/s?k=Daily+Life+Ancient+India+Auboyer',
      ),
    ],
    // mod_07: The Four Ashramas
    'mod_07': [
      _BookRec(
        title: 'The Hindu Way of Life',
        author: 'S. Radhakrishnan',
        url: 'https://www.amazon.in/s?k=Hindu+Way+of+Life+Radhakrishnan',
      ),
      _BookRec(
        title: 'The Stages of Life',
        author: 'Thomas Armstrong',
        url: 'https://www.amazon.in/s?k=The+Stages+of+Life+Thomas+Armstrong',
      ),
    ],
    // mod_08: The Four Purusharthas
    'mod_08': [
      _BookRec(
        title: 'The Hindu View of Life',
        author: 'S. Radhakrishnan',
        url: 'https://www.amazon.in/s?k=Hindu+View+of+Life+Radhakrishnan',
      ),
      _BookRec(
        title: 'The Aims of Life',
        author: 'Patrick Olivelle',
        url: 'https://www.amazon.in/s?k=Aims+of+Life+Dharma+Artha+Kama+Moksha+Olivelle',
      ),
    ],
    // mod_09: The 4 Vedas — Structure & Essence
    'mod_09': [
      _BookRec(
        title: 'The Rig Veda: An Anthology',
        author: 'Wendy Doniger',
        url: 'https://www.amazon.in/s?k=The+Rig+Veda+An+Anthology+Wendy+Doniger',
      ),
      _BookRec(
        title: 'The Vedas: An Introduction',
        author: 'Roshen Dalal',
        url: 'https://www.amazon.in/s?k=The+Vedas+An+Introduction+Roshen+Dalal',
      ),
    ],
    // mod_10: The 10 Mukhya Upanishads
    'mod_10': [
      _BookRec(
        title: 'The Upanishads',
        author: 'Eknath Easwaran',
        url: 'https://www.amazon.in/s?k=The+Upanishads+Eknath+Easwaran',
      ),
      _BookRec(
        title: 'The Principal Upanishads',
        author: 'S. Radhakrishnan',
        url: 'https://www.amazon.in/s?k=The+Principal+Upanishads+S+Radhakrishnan',
      ),
    ],
    // mod_11: Bhagavad Gita — Full 18-Chapter Study
    'mod_11': [
      _BookRec(
        title: 'The Bhagavad Gita',
        author: 'Eknath Easwaran',
        url: 'https://www.amazon.in/s?k=The+Bhagavad+Gita+Eknath+Easwaran',
      ),
      _BookRec(
        title: 'Bhagavad Gita As It Is',
        author: 'A.C. Bhaktivedanta Swami',
        url: 'https://www.amazon.in/s?k=Bhagavad+Gita+As+It+Is',
      ),
    ],
    // mod_12: Ramayana — The Dharma of Rama
    'mod_12': [
      _BookRec(
        title: 'Ramayana',
        author: 'C. Rajagopalachari',
        url: 'https://www.amazon.in/s?k=Ramayana+C+Rajagopalachari',
      ),
      _BookRec(
        title: 'Valmiki Ramayana (abridged)',
        author: 'Arshia Sattar',
        url: 'https://www.amazon.in/s?k=Valmiki+Ramayana+abridged+Arshia+Sattar',
      ),
    ],
    // mod_13: Mahabharata — The War Within
    'mod_13': [
      _BookRec(
        title: 'Mahabharata',
        author: 'C. Rajagopalachari',
        url: 'https://www.amazon.in/s?k=Mahabharata+C.+Rajagopalachari',
      ),
      _BookRec(
        title: 'The Difficulty of Being Good',
        author: 'Gurcharan Das',
        url: 'https://www.amazon.in/s?k=The+Difficulty+of+Being+Good+Gurcharan+Das',
      ),
    ],
    // mod_14: The 18 Mahapuranas — A Guide
    'mod_14': [
      _BookRec(
        title: 'Srimad Bhagavatam (abridged)',
        author: 'Kamala Subramaniam',
        url: 'https://www.amazon.in/s?k=Srimad+Bhagavatam+Kamala+Subramaniam',
      ),
      _BookRec(
        title: 'The Puranas: An Encyclopaedia',
        author: 'Swami Harshananda',
        url: 'https://www.amazon.in/s?k=Puranas+Encyclopaedia+Swami+Harshananda',
      ),
    ],
    // mod_15: The 4 Paths of Yoga
    'mod_15': [
      _BookRec(
        title: 'Raja Yoga',
        author: 'Swami Vivekananda',
        url: 'https://www.amazon.in/s?k=Raja+Yoga+Swami+Vivekananda',
      ),
      _BookRec(
        title: 'Bhakti Yoga',
        author: 'Swami Vivekananda',
        url: 'https://www.amazon.in/s?k=Bhakti+Yoga+Swami+Vivekananda',
      ),
    ],
    // mod_16: Ayurveda — Science of Life
    'mod_16': [
      _BookRec(
        title: 'Ayurveda: The Science of Self-Healing',
        author: 'Dr. Vasant Lad',
        url: 'https://www.amazon.in/s?k=Ayurveda+The+Science+of+Self-Healing+Vasant+Lad',
      ),
      _BookRec(
        title: 'The Complete Book of Ayurvedic Home Remedies',
        author: 'Dr. Vasant Lad',
        url: 'https://www.amazon.in/s?k=The+Complete+Book+of+Ayurvedic+Home+Remedies',
      ),
    ],
    // mod_17: Sanskrit Starter — 30 Days of Devanagari
    'mod_17': [
      _BookRec(
        title: 'Teach Yourself Sanskrit',
        author: 'Michael Coulson',
        url: 'https://www.amazon.in/s?k=Teach+Yourself+Sanskrit+Michael+Coulson',
      ),
      _BookRec(
        title: 'The Sanskrit Heritage Site',
        author: 'Gérard Huet',
        url: 'https://www.amazon.in/s?k=Sanskrit+language+learning+Devanagari+beginners',
      ),
    ],
  };

  // Deep-link into a related scripture already available in the app.
  // Modules without a direct scripture counterpart are omitted.
  static const Map<String, ({String label, String route})> _scriptureLinks = {
    'mod_09': (label: 'Read the Rigveda', route: '/browse/rigveda'),
    'mod_10': (label: 'Read the Upanishads', route: '/browse/katha_upanishad'),
    'mod_11': (label: 'Read the Bhagavad Gita', route: '/browse/bhagavad_gita'),
    'mod_12': (label: 'Read the Ramayana', route: '/browse/ramayana'),
    'mod_13': (label: 'Read the Mahabharata', route: '/browse/mahabharata'),
    'mod_14': (label: 'Read the Bhagavata Purana', route: '/browse/bhagavata_purana'),
    'mod_15': (label: 'Read the Yoga Sutras', route: '/browse/yoga_sutras'),
  };

  @override
  Widget build(BuildContext context) {
    // Trigger success haptic when completion screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Haptics.vibrate(HapticsType.success);
      } catch (_) {}
    });
    final recs = _books[module.id] ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: 64,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Module Complete',
            style: context.ts.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            module.title,
            style: context.ts.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (recs.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            Divider(color: isDark ? AppColors.dividerDark : AppColors.divider),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.warmGrey50,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Continue learning',
                  style: context.ts.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Recommended books for this module',
              style: context.ts.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...recs.map((rec) => _BookCard(rec: rec)),
          ],
          const SizedBox(height: AppSpacing.xxl),
          if (_scriptureLinks[module.id] case final link?) ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.auto_stories_outlined, size: 18),
              label: Text(link.label),
              onPressed: () => context.go(link.route),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          ElevatedButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/learn');
              }
            },
            child: const Text('Back to Learning Path'),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Book recommendation card ──────────────────────────────────────────────

class _BookRec {
  const _BookRec({
    required this.title,
    required this.author,
    required this.url,
  });

  final String title;
  final String author;
  final String url;
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.rec});

  final _BookRec rec;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(rec.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.borderDark
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: AppSpacing.xxl,
                height: AppSpacing.xxl,
                decoration: BoxDecoration(
                  color: AppColors.warmGrey10,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.book_outlined,
                  color: AppColors.warmGrey50,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rec.title, style: context.ts.labelMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      rec.author,
                      style: context.ts.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.open_in_new_rounded,
                color: AppColors.warmGrey50,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
