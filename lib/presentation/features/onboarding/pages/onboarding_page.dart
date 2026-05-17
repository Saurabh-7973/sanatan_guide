import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/services/analytics_service.dart';
import 'package:sanatan_guide/core/services/onboarding_service.dart';
import 'package:sanatan_guide/domain/entities/user_experience_level.dart';
import 'package:sanatan_guide/presentation/features/onboarding/providers/daily_reminder_provider.dart';
import 'package:sanatan_guide/presentation/features/onboarding/providers/user_experience_level_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _step = 0;
  UserExperienceLevel? _selectedLevel;

  Future<void> _finishOnboarding({
    required bool reminderEnabled,
    TimeOfDay? reminderTime,
  }) async {
    final notifier = ref.read(dailyReminderProvider.notifier);
    await notifier.setEnabled(reminderEnabled);
    if (reminderEnabled && reminderTime != null) {
      await notifier.setTime(reminderTime);
    }
    unawaited(
      AnalyticsService.onboardingReminderChosen(
        enabled: reminderEnabled,
        hour: reminderTime?.hour,
        minute: reminderTime?.minute,
      ),
    );
    await OnboardingService.markComplete();
    if (mounted) context.go('/home');
  }

  Future<void> _skipFromWelcome() async {
    await ref
        .read(userExperienceLevelProvider.notifier)
        .setLevel(UserExperienceLevel.regular);
    if (mounted) setState(() => _step = 1);
  }

  Future<void> _continueFromWelcome() async {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? DColors.bg : LColors.bg;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (_step == 1) setState(() => _step = 0);
      },
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Same dawn wash the migrated screens use; the mockup's screen
            // background is a faint saffron radial over the cream base.
            const WarmBackdrop(),
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: child,
                    ),
                  );
                },
                child: _step == 0
                    ? _WelcomeStep(
                        key: const ValueKey('welcome'),
                        isDark: isDark,
                        selectedLevel: _selectedLevel,
                        onSelect: (level) =>
                            setState(() => _selectedLevel = level),
                        onContinue: _continueFromWelcome,
                        onSkip: _skipFromWelcome,
                      )
                    : _ReminderStep(
                        key: const ValueKey('reminder'),
                        isDark: isDark,
                        onEnable: (time) => _finishOnboarding(
                          reminderEnabled: true,
                          reminderTime: time,
                        ),
                        onSkip: () => _finishOnboarding(reminderEnabled: false),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Welcome step
// ============================================================
class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({
    super.key,
    required this.isDark,
    required this.selectedLevel,
    required this.onSelect,
    required this.onContinue,
    required this.onSkip,
  });

  final bool isDark;
  final UserExperienceLevel? selectedLevel;
  final ValueChanged<UserExperienceLevel> onSelect;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  static const _levelCopy = {
    UserExperienceLevel.beginner:
        'New to the texts. Start with Foundations and gentle commentary.',
    UserExperienceLevel.regular:
        'Comfortable with the basics. Read directly with optional commentary.',
    UserExperienceLevel.scholar:
        'Read texts and transliteration directly. Commentary only when asked.',
  };

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return _FillableScrollColumn(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: Spacing.xxxl),
            Center(
              child: Text(
                '॥ श्री गणेशाय नमः ॥',
                style: AppText.invocation(saffronColor: saffron)
                    .copyWith(color: saffron.withValues(alpha: 0.5)),
              ),
            ),
            const SizedBox(height: Spacing.xl),
            _StepDots(active: 0, isDark: isDark),
            const SizedBox(height: Spacing.xxl),
            Center(
              child: Text(
                'ॐ',
                style: TextStyle(
                  fontFamily: Fonts.deva,
                  fontSize: 68,
                  color: saffron,
                  height: 1,
                  shadows: isDark
                      ? const [
                          Shadow(
                            color: Color(0x4DE8820C),
                            blurRadius: 24,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Center(
              child: Text(
                'Sanatan Guide',
                style: AppText.screenTitle(color: text1).copyWith(fontSize: 32),
              ),
            ),
            const SizedBox(height: Spacing.sm + 2),
            Center(
              child: Padding(
                // The mockup's tagline sits in a slightly narrower column than
                // the hero block, which is what makes it break right after the
                // comma onto a second line.
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                child: Text(
                  'A reader for Hindu scripture — fully offline, with deep textual care.',
                  style: AppText.subtitle(color: text2)
                      .copyWith(fontSize: 15, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: Spacing.xl + 2),
            Center(
              child: SizedBox(
                width: 64,
                child: BindingLine(isDark: isDark, diamondSize: 4, sideGap: 5),
              ),
            ),
            const SizedBox(height: Spacing.xxxl),
            Text(
              'TELL US WHERE TO BEGIN',
              style: AppText.sectionLabel(color: text3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'How familiar are you with the scriptures?',
              style: AppText.subtitle(color: text1).copyWith(
                  fontSize: 18, fontWeight: FontWeight.w500, height: 1.35),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xl),
            for (final level in UserExperienceLevel.values) ...[
              _LevelCard(
                level: level,
                description: _levelCopy[level]!,
                selected: selectedLevel == level,
                isDark: isDark,
                onTap: () => onSelect(level),
              ),
              const SizedBox(height: Spacing.sm + 2),
            ],
            const Spacer(),
            _PrimaryButton(
              label: 'Continue',
              isDark: isDark,
              enabled: selectedLevel != null,
              trailing: const Icon(Icons.arrow_forward, size: 14),
              onTap: onContinue,
            ),
            const SizedBox(height: Spacing.md),
            Center(
              child: TextButton(
                onPressed: onSkip,
                child: Text(
                  'SKIP FOR NOW',
                  style: AppText.textButton(color: text3),
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Reminder step
// ============================================================
class _ReminderStep extends StatefulWidget {
  const _ReminderStep({
    super.key,
    required this.isDark,
    required this.onEnable,
    required this.onSkip,
  });

  final bool isDark;
  final ValueChanged<TimeOfDay> onEnable;
  final VoidCallback onSkip;

  @override
  State<_ReminderStep> createState() => _ReminderStepState();
}

class _ReminderStepState extends State<_ReminderStep> {
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);

  bool get _isAm => _time.hour < 12;

  int get _displayHour {
    final h = _time.hour % 12;
    return h == 0 ? 12 : h;
  }

  void _setPeriod(bool am) {
    if (am == _isAm) return;
    setState(() {
      _time = TimeOfDay(
        hour: am ? (_time.hour - 12) : (_time.hour + 12),
        minute: _time.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final surface = isDark ? DColors.surface : LColors.surface;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;

    return _FillableScrollColumn(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: Spacing.xxxl + Spacing.lg),
            _StepDots(active: 1, isDark: isDark),
            const SizedBox(height: Spacing.xxxl + Spacing.xxxl),
            Center(child: _BellGlyph(saffron: saffron)),
            const SizedBox(height: Spacing.xl),
            Center(
              child: Text(
                'A verse a day',
                style: AppText.screenTitle(color: text1).copyWith(fontSize: 26),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Center(
              child: Text(
                'A short morning notification with one verse — chosen for the day. '
                'You can change or silence it any time.',
                style: AppText.subtitle(color: text2).copyWith(fontSize: 14.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: Spacing.xxxl),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(Radii.card),
                border: Border.all(color: divider, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'REMIND ME AT',
                    style: AppText.sectionLabel(color: text3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _pickTime,
                    child: Text(
                      '$_displayHour : ${_time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontFamily: Fonts.serif,
                        fontSize: 38,
                        fontWeight: FontWeight.w500,
                        height: 1,
                        color: saffron,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PeriodToggle(
                    isAm: _isAm,
                    isDark: isDark,
                    inactiveBg: dividerSoft,
                    saffron: saffron,
                    text3: text3,
                    onChanged: _setPeriod,
                  ),
                ],
              ),
            ),
            const Spacer(),
            _PrimaryButton(
              label: 'Enable reminder',
              isDark: isDark,
              enabled: true,
              onTap: () => widget.onEnable(_time),
            ),
            const SizedBox(height: Spacing.md),
            Center(
              child: TextButton(
                onPressed: widget.onSkip,
                child: Text(
                  'NOT NOW',
                  style: AppText.textButton(color: text3),
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Fillable scroll column
// ============================================================

/// Wraps onboarding step content so it pins its bottom actions to the foot of
/// the viewport on tall screens but scrolls gracefully on short ones — instead
/// of a `RenderFlex` overflow when the content is taller than the screen.
class _FillableScrollColumn extends StatelessWidget {
  const _FillableScrollColumn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(child: child),
          ),
        );
      },
    );
  }
}

// ============================================================
// Step dots
// ============================================================
class _StepDots extends StatelessWidget {
  const _StepDots({required this.active, required this.isDark});

  final int active;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final inactive = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 2; i++) ...[
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == active ? saffron : inactive,
            ),
          ),
          if (i == 0) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

// ============================================================
// Level card
// ============================================================
class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.description,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final UserExperienceLevel level;
  final String description;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final surface = isDark ? DColors.surface : LColors.surface;
    final divider = isDark ? DColors.divider : LColors.divider;
    final softDivider = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(
            color: selected ? divider : softDivider,
            width: 1,
          ),
        ),
        // Stack OUTSIDE inner padding so `left: 0` lands on the card's real
        // left edge (not clipped by Stack.hardEdge). Start mark on every
        // card, like the continue card; pulse only the selected one.
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 12,
              bottom: 12,
              child: LeafThread(
                isDark: isDark,
                pulseOnce: selected,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 18, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.displayTitle,
                          style: AppText.moduleTitle(color: text1)
                              .copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: AppText.moduleDesc(color: text2)
                              .copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  _Radio(
                    selected: selected,
                    saffron: saffron,
                    inactive: text3,
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

class _Radio extends StatelessWidget {
  const _Radio({
    required this.selected,
    required this.saffron,
    required this.inactive,
  });

  final bool selected;
  final Color saffron;
  final Color inactive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? saffron : inactive,
          width: 1.5,
        ),
      ),
      child: Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: selected ? 1 : 0,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: saffron,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Bell glyph (reminder hero)
// ============================================================
class _BellGlyph extends StatelessWidget {
  const _BellGlyph({required this.saffron});

  final Color saffron;

  @override
  Widget build(BuildContext context) {
    // Mockup: a 64px ring at 40% over an 80px halo at 15%, 22px bell inside.
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: saffron.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: saffron.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
          ),
          Icon(
            Icons.notifications_none,
            size: 22,
            color: saffron,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// AM/PM toggle
// ============================================================
class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({
    required this.isAm,
    required this.isDark,
    required this.inactiveBg,
    required this.saffron,
    required this.text3,
    required this.onChanged,
  });

  final bool isAm;
  final bool isDark;
  final Color inactiveBg;
  final Color saffron;
  final Color text3;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _periodButton(label: 'AM', active: isAm, onTap: () => onChanged(true)),
        const SizedBox(width: 6),
        _periodButton(
            label: 'PM', active: !isAm, onTap: () => onChanged(false)),
      ],
    );
  }

  Widget _periodButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final glow = isDark ? DColors.saffronGlow : LColors.saffronGlow;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? glow : inactiveBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: AppText.pill(color: active ? saffron : text3)
              .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.66),
        ),
      ),
    );
  }
}

// ============================================================
// Primary button
// ============================================================
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.isDark,
    required this.enabled,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final bool isDark;
  final bool enabled;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final fg = isDark ? const Color(0xFF1A1208) : Colors.white;
    final bgColor = enabled ? saffron : saffron.withValues(alpha: 0.4);
    return SizedBox(
      height: 50,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(Radii.button),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(Radii.button),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppText.primaryButton(color: fg),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: Spacing.sm),
                  IconTheme(
                    data: IconThemeData(color: fg, size: 14),
                    child: trailing!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
