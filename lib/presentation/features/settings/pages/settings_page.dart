import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sanatan_guide/presentation/features/settings/pages/credits_page.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/core/services/analytics_service.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/domain/entities/user_experience_level.dart';
import 'package:sanatan_guide/presentation/features/onboarding/providers/user_experience_level_provider.dart';
import 'package:sanatan_guide/l10n/generated/app_localizations.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/font_size_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/locale_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/notification_time_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/theme_mode_provider.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.settingsTitle, style: context.ts.displayMedium),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SafeArea(
            top: false,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.paddingOf(context).top,
                bottom: AppSpacing.xxl,
              ),
              children: [
                _SectionHeader(title: l10n.settingsSectionAppearance),
                const _ThemeTile(),
                const _FontSizeTile(),
                const _SoftDivider(),
                _SectionHeader(title: l10n.settingsSectionLanguage),
                const _LanguageTile(),
                const _SoftDivider(),
                _SectionHeader(title: l10n.settingsSectionNotifications),
                const _NotificationTimeTile(),
                const _SoftDivider(),
                _SectionHeader(title: l10n.settingsSectionData),
                const _ClearHistoryTile(),
                const _SoftDivider(),
                _SectionHeader(title: l10n.settingsSectionReading),
                const _ExperienceLevelTile(),
                const _SoftDivider(),
                _SectionHeader(title: l10n.settingsSectionAbout),
                const _AppVersionTile(),
                const _CreditsTile(),
                _LinkTile(
                  title: l10n.settingsPrivacyPolicy,
                  icon: Icons.privacy_tip_outlined,
                  url:
                      'https://gist.github.com/Saurabh-7973/96cf400ffbbbece5ece2d5d4c3f0a16c',
                ),
                _LinkTile(
                  title: l10n.settingsTermsOfService,
                  icon: Icons.description_outlined,
                  url:
                      'https://gist.github.com/Saurabh-7973/04966e0f9717bba119ddf13e951d3df5',
                ),
                const _FeedbackTile(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.sm,
      ),
      child: Divider(height: 1, thickness: 1, color: AppColors.border),
    );
  }
}

// ── Section header ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.lg,
        AppSpacing.pagePadding,
        AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: context.ts.sectionLabel,
      ),
    );
  }
}

// ── Theme toggle ────────────────────────────────────────────────────────

class _ThemeTile extends ConsumerWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
      ),
      leading: Icon(
        themeMode == ThemeMode.dark
            ? Icons.dark_mode_rounded
            : themeMode == ThemeMode.light
                ? Icons.light_mode_rounded
                : Icons.brightness_auto_rounded,
        color: AppColors.warmGrey50,
      ),
      title: Text('Theme', style: context.ts.bodyMedium),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.brightness_auto, size: 18),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode, size: 18),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode, size: 18),
          ),
        ],
        selected: {themeMode},
        onSelectionChanged: (selection) {
          final mode = selection.first;
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
          AnalyticsService.darkModeToggled(enabled: mode == ThemeMode.dark);
        },
        showSelectedIcon: false,
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

// ── Font size slider ────────────────────────────────────────────────────

/// Language picker. `null` → follow device; `en`/`hi` → forced locale.
class _LanguageTile extends ConsumerWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final currentLabel = switch (current?.languageCode) {
      null => l10n.settingsLanguageSystem,
      'en' => l10n.settingsLanguageEnglish,
      'hi' => l10n.settingsLanguageHindi,
      final code => code,
    };
    return ListTile(
      leading: const Icon(Icons.translate_rounded),
      title: Text(l10n.settingsLanguage, style: context.ts.bodyLarge),
      subtitle: Text(currentLabel, style: context.ts.caption),
      onTap: () async {
        final chosen = await showDialog<Locale?>(
          context: context,
          builder: (ctx) {
            return SimpleDialog(
              title: Text(l10n.settingsLanguage),
              children: [
                _LanguageChoice(
                  label: l10n.settingsLanguageSystem,
                  value: null,
                  selected: current == null,
                ),
                _LanguageChoice(
                  label: l10n.settingsLanguageEnglish,
                  value: const Locale('en'),
                  selected: current?.languageCode == 'en',
                ),
                _LanguageChoice(
                  label: l10n.settingsLanguageHindi,
                  value: const Locale('hi'),
                  selected: current?.languageCode == 'hi',
                ),
              ],
            );
          },
        );
        if (!context.mounted) return;
        // Dialog returns the wrapped sentinel; treat Locale('_none_') as null.
        if (chosen?.languageCode == '_none_') {
          await ref.read(localeProvider.notifier).setLocale(null);
        } else if (chosen != null) {
          await ref.read(localeProvider.notifier).setLocale(chosen);
        }
      },
    );
  }
}

class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({
    required this.label,
    required this.value,
    required this.selected,
  });

  final String label;
  final Locale? value;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () =>
          Navigator.pop(context, value ?? const Locale('_none_')),
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 20,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: context.ts.bodyLarge),
        ],
      ),
    );
  }
}

class _FontSizeTile extends ConsumerWidget {
  const _FontSizeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
      ),
      leading: const Icon(Icons.format_size_rounded, color: AppColors.warmGrey50),
      title: Text('Reading font size', style: context.ts.bodyMedium),
      subtitle: Row(
        children: [
          const Text('A', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Expanded(
            child: Slider(
              value: fontSize,
              min: kMinFontSize,
              max: kMaxFontSize,
              divisions: ((kMaxFontSize - kMinFontSize) / 2).round(),
              activeColor: AppColors.saffron,
              onChanged: (v) {
                ref.read(fontSizeProvider.notifier).setFontSize(v);
              },
            ),
          ),
          const Text('A', style: TextStyle(fontSize: 22, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Notification time picker ────────────────────────────────────────────

class _NotificationTimeTile extends ConsumerWidget {
  const _NotificationTimeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = ref.watch(notificationTimeProvider);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
      ),
      leading: const Icon(Icons.notifications_outlined, color: AppColors.warmGrey50),
      title: Text('Daily verse reminder', style: context.ts.bodyMedium),
      trailing: TextButton(
        onPressed: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time,
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: AppColors.saffron,
                    ),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            ref
                .read(notificationTimeProvider.notifier)
                .setTime(picked);
          }
        },
        child: Text(
          time.format(context),
          style: context.ts.bodyMedium.copyWith(
            color: AppColors.saffron,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Clear reading history ───────────────────────────────────────────────

class _ClearHistoryTile extends ConsumerWidget {
  const _ClearHistoryTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
      ),
      leading: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary),
      title: Text('Clear reading history', style: context.ts.bodyMedium),
      subtitle: Text(
        'Resets streaks and read counts',
        style: context.ts.caption,
      ),
      onTap: () => _showConfirmDialog(context, ref),
    );
  }

  Future<void> _showConfirmDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear reading history?'),
        content: const Text(
          'This will reset your streak, read counts, and reading history. '
          'Bookmarks and notes will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await StreakService.instance.clearAllHistory();
      ref.invalidate(currentStreakProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reading history cleared')),
        );
      }
    }
  }
}

// ── Scripture experience level ───────────────────────────────────────────

class _ExperienceLevelTile extends ConsumerWidget {
  const _ExperienceLevelTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(userExperienceLevelProvider);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
      ),
      leading: const Icon(Icons.school_outlined, color: AppColors.warmGrey50),
      title: Text('Scripture experience', style: context.ts.bodyMedium),
      subtitle: Text(level.displayTitle, style: context.ts.caption),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: AppColors.textSecondary,
      ),
      onTap: () => _showExperienceSheet(context, ref),
    );
  }

  Future<void> _showExperienceSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Consumer(
        builder: (context, refSheet, _) {
          final current = refSheet.watch(userExperienceLevelProvider);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      AppSpacing.sm,
                      AppSpacing.pagePadding,
                      AppSpacing.md,
                    ),
                    child: Text(
                      'Scripture experience',
                      style: context.ts.labelLarge,
                    ),
                  ),
                  for (final UserExperienceLevel l
                      in UserExperienceLevel.values)
                    ListTile(
                      selected: current == l,
                      title: Text(l.displayTitle, style: context.ts.bodyMedium),
                      subtitle: Text(
                        l.displaySubtitle,
                        style: context.ts.caption,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: current == l
                          ? const Icon(Icons.check_circle, color: AppColors.saffron)
                          : null,
                      onTap: () async {
                        await refSheet
                            .read(userExperienceLevelProvider.notifier)
                            .setLevel(l);
                        unawaited(
                          AnalyticsService.experienceLevelSet(
                            level: l.name,
                            source: 'settings',
                          ),
                        );
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── App version ─────────────────────────────────────────────────────────

class _AppVersionTile extends StatelessWidget {
  const _AppVersionTile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data;
        final text = version != null
            ? 'v${version.version} (${version.buildNumber})'
            : '...';

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
          ),
          leading: const Icon(Icons.info_outline_rounded, color: AppColors.warmGrey50),
          title: Text('Sanatan Guide', style: context.ts.bodyMedium),
          trailing: Text(text, style: context.ts.caption),
        );
      },
    );
  }
}

// ── Link tile ───────────────────────────────────────────────────────────

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.title,
    required this.icon,
    required this.url,
  });

  final String title;
  final IconData icon;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
      ),
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: context.ts.bodyMedium),
      trailing: const Icon(Icons.open_in_new, size: 18, color: AppColors.textSecondary),
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
    );
  }
}

// ── Feedback tile ───────────────────────────────────────────────────────

class _FeedbackTile extends StatelessWidget {
  const _FeedbackTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
      ),
      leading: const Icon(Icons.feedback_outlined, color: AppColors.warmGrey50),
      title: Text('Send Feedback', style: context.ts.bodyMedium),
      trailing: const Icon(Icons.mail_outline, size: 18, color: AppColors.textSecondary),
      onTap: () => launchUrl(
        Uri(
          scheme: 'mailto',
          path: 'saurabh7973business@gmail.com',
          queryParameters: {'subject': 'Sanatan Guide Feedback'},
        ),
        mode: LaunchMode.externalApplication,
      ),
    );
  }
}

// ── Credits tile ─────────────────────────────────────────────────────────

class _CreditsTile extends StatelessWidget {
  const _CreditsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
      ),
      leading: const Icon(Icons.auto_stories_outlined, color: AppColors.textSecondary),
      title: Text('Credits & Attributions', style: context.ts.bodyMedium),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const CreditsPage()),
      ),
    );
  }
}
