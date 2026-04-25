import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/services/analytics_service.dart';
import 'package:sanatan_guide/core/services/onboarding_service.dart';
import 'package:sanatan_guide/domain/entities/user_experience_level.dart';
import 'package:sanatan_guide/presentation/features/onboarding/providers/user_experience_level_provider.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _step = 0;
  UserExperienceLevel? _selectedLevel;

  Future<void> _skipToHome() async {
    await OnboardingService.markComplete();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic result) async {
        if (_step == 1) {
          setState(() => _step = 0);
        } else {
          await _skipToHome();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: _step == 1
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _step = 0),
                )
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Skip',
                  onPressed: _skipToHome,
                ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
              vertical: AppSpacing.lg,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, animation) {
                final isForward = child.key == const ValueKey(1);
                final offset = isForward
                    ? const Offset(0.12, 0)
                    : const Offset(-0.12, 0);
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: offset,
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _step == 0
                  ? _buildExperienceStep(key: const ValueKey(0))
                  : _buildPathStep(key: const ValueKey(1)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceStep({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Text(
          '🕉',
          style: TextStyle(fontSize: 48),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Welcome to\nSanatan Guide',
          style: context.ts.displayLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'How familiar are you with Hindu scriptures?',
          style: context.ts.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        _LevelCard(
          level: UserExperienceLevel.beginner,
          emoji: '🌱',
          selected: _selectedLevel == UserExperienceLevel.beginner,
          onTap: () => setState(
            () => _selectedLevel = UserExperienceLevel.beginner,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _LevelCard(
          level: UserExperienceLevel.regular,
          emoji: '🪔',
          selected: _selectedLevel == UserExperienceLevel.regular,
          onTap: () =>
              setState(() => _selectedLevel = UserExperienceLevel.regular),
        ),
        const SizedBox(height: AppSpacing.md),
        _LevelCard(
          level: UserExperienceLevel.scholar,
          emoji: '📜',
          selected: _selectedLevel == UserExperienceLevel.scholar,
          onTap: () =>
              setState(() => _selectedLevel = UserExperienceLevel.scholar),
        ),
        const Spacer(),
        FilledButton(
          onPressed: _selectedLevel == null ? null : _onExperienceContinue,
          child: const Text('Continue'),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildPathStep({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Text(
          'Where would you like to begin?',
          style: context.ts.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'You can always change this later from the library.',
          style: context.ts.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        _PathCard(
          emoji: '🌱',
          title: 'Complete Beginner',
          subtitle: 'I know little about Hinduism',
          onTap: () => _selectPath(destination: '/learn/mod_01'),
        ),
        const SizedBox(height: AppSpacing.md),
        _PathCard(
          emoji: '🪔',
          title: 'Curious Hindu',
          subtitle: 'I grew up Hindu but want to learn deeper',
          onTap: () => _selectPath(destination: '/learn/mod_03'),
        ),
        const SizedBox(height: AppSpacing.md),
        _PathCard(
          emoji: '📖',
          title: 'Serious Seeker',
          subtitle: 'I want to read the scriptures directly',
          onTap: () =>
              _selectPath(destination: '/browse/bhagavad_gita/chapter/1'),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => _selectPath(destination: '/home'),
          child: Text(
            'Skip for now',
            style: context.ts.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onExperienceContinue() async {
    final level = _selectedLevel;
    if (level == null) return;
    await ref.read(userExperienceLevelProvider.notifier).setLevel(level);
    unawaited(
      AnalyticsService.experienceLevelSet(
        level: level.name,
        source: 'onboarding',
      ),
    );
    if (mounted) setState(() => _step = 1);
  }

  Future<void> _selectPath({required String destination}) async {
    unawaited(AnalyticsService.onboardingPathSelected(destination));
    await OnboardingService.markComplete();
    if (!mounted) return;
    // Always land on home first so back-stack is established.
    // Then push the chosen destination on top — back button returns to home.
    context.go('/home');
    if (destination != '/home') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.push(destination);
      });
    }
  }
}

// ── Level card (step 1) ───────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final UserExperienceLevel level;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppColors.saffron
        : (Theme.of(context).brightness == Brightness.dark
            ? AppColors.borderDark
            : AppColors.border);
    final fill = selected
        ? AppColors.saffron.withValues(alpha: 0.08)
        : Theme.of(context).colorScheme.surface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.displayTitle,
                    style: context.ts.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(level.displaySubtitle, style: context.ts.caption),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.saffron, size: 22)
            else
              Icon(
                Icons.circle_outlined,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Path card (step 2) ──────────────────────────────────────────────────────

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.ts.labelMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: context.ts.caption),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
