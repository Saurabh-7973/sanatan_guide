// lib/presentation/features/settings/pages/settings_page.dart
//
// Settings — heritage spec 11 (S4). Visual restyle of the working 7-provider
// settings screen onto the heritage language: WarmBackdrop, AppText.sectionLabel
// headers with hairlines, restrained rows, iron-red Reset section. Every
// provider and behavior is preserved; only the presentation changed.

import 'dart:async';

// `kDefaultFontSize` is also exported by material.dart (14.0); we need the
// app's reading-font default (16.0) from font_size_provider.
import 'package:flutter/material.dart' hide kDefaultFontSize;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sanatan_guide/core/services/analytics_service.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/domain/entities/user_experience_level.dart';
import 'package:sanatan_guide/l10n/generated/app_localizations.dart';
import 'package:sanatan_guide/presentation/features/onboarding/providers/user_experience_level_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/font_size_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/locale_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/notification_time_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/theme_mode_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

const _kPrivacyUrl =
    'https://gist.github.com/Saurabh-7973/96cf400ffbbbece5ece2d5d4c3f0a16c';
const _kTermsUrl =
    'https://gist.github.com/Saurabh-7973/04966e0f9717bba119ddf13e951d3df5';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final text1 = isDark ? DColors.text1 : LColors.text1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SafeArea(
            child: Column(
              children: [
                // Fixed topbar — content scrolls below it, no overlay
                // collision (the Credits-screen idiom). A transparent pinned
                // AppBar previously let scrolled rows bleed through the title.
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 6, 20, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: text1),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.settingsTitle,
                        style: AppText.settingsTitle(color: text1),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32),
                    children: [
                      // ── Appearance ──────────────────────────────────────────
                      _SectionHeader(
                        title: l10n.settingsSectionAppearance,
                        isDark: isDark,
                      ),
                      const _ThemeRow(),

                      // ── Reading ─────────────────────────────────────────────
                      _SectionHeader(
                        title: l10n.settingsSectionReading,
                        isDark: isDark,
                      ),
                      const _FontSizeRow(),
                      const _LanguageRow(),
                      const _ExperienceRow(),

                      // ── Notifications ───────────────────────────────────────
                      _SectionHeader(
                        title: l10n.settingsSectionNotifications,
                        isDark: isDark,
                      ),
                      const _NotificationTimeRow(),
                      _Row(
                        isDark: isDark,
                        icon: Icons.celebration_outlined,
                        title: 'Festival alerts',
                        subtitle: 'Day before each major parva',
                        trailing: const _SoonTag(),
                      ),

                      // ── Data ────────────────────────────────────────────────
                      _SectionHeader(
                        title: l10n.settingsSectionData,
                        isDark: isDark,
                      ),
                      _Row(
                        isDark: isDark,
                        icon: Icons.folder_outlined,
                        title: 'Storage',
                        subtitle: 'Scripture library bundled with the app',
                      ),
                      _Row(
                        isDark: isDark,
                        icon: Icons.ios_share_outlined,
                        title: 'Export bookmarks',
                        subtitle: 'Save your saved verses to a file',
                        trailing: const _SoonTag(),
                      ),
                      const _ClearHistoryRow(),

                      // ── About ───────────────────────────────────────────────
                      _SectionHeader(
                        title: l10n.settingsSectionAbout,
                        isDark: isDark,
                      ),
                      const _AppVersionRow(),
                      _Row(
                        isDark: isDark,
                        icon: Icons.auto_stories_outlined,
                        title: 'Credits & attributions',
                        trailing: _Chevron(isDark: isDark),
                        onTap: () => context.push('/credits'),
                      ),
                      _Row(
                        isDark: isDark,
                        icon: Icons.privacy_tip_outlined,
                        title: l10n.settingsPrivacyPolicy,
                        trailing: _ExternalIcon(isDark: isDark),
                        onTap: () => launchUrl(
                          Uri.parse(_kPrivacyUrl),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      _Row(
                        isDark: isDark,
                        icon: Icons.description_outlined,
                        title: l10n.settingsTermsOfService,
                        trailing: _ExternalIcon(isDark: isDark),
                        onTap: () => launchUrl(
                          Uri.parse(_kTermsUrl),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      _Row(
                        isDark: isDark,
                        icon: Icons.feedback_outlined,
                        title: 'Send feedback',
                        trailing: _Chevron(isDark: isDark),
                        onTap: () => context.push('/feedback'),
                      ),

                      // ── Reset ───────────────────────────────────────────────
                      _SectionHeader(
                          title: 'Reset', isDark: isDark, danger: true),
                      const _ResetRow(),
                    ],
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

// ── Heritage shell widgets ─────────────────────────────────────────────────

/// Section header: uppercase `sectionLabel` + 1px hairline (Credits idiom).
/// `danger` tints the label iron-red for the Reset section.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.isDark,
    this.danger = false,
  });

  final String title;
  final bool isDark;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? DColors.text3 : LColors.text3;
    final iron = isDark ? DColors.ironRedBright : LColors.ironRedBright;
    final divider = isDark ? DColors.divider : LColors.divider;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 4),
      padding: const EdgeInsets.only(bottom: 8),
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(color: divider))),
      child: Text(
        title.toUpperCase(),
        style: AppText.sectionLabel(color: danger ? iron : base),
      ),
    );
  }
}

/// Generic row: leading icon + title (+ optional subtitle) + trailing widget.
class _Row extends StatelessWidget {
  const _Row({
    required this.isDark,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final bool isDark;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final iron = isDark ? DColors.ironRedBright : LColors.ironRedBright;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final fg = danger ? iron : text1;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: danger ? iron : saffron),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: Fonts.sans,
                      fontFamilyFallback: AppFontFallback.latin,
                      fontSize: 14,
                      color: fg,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: Fonts.serif,
                        fontFamilyFallback: AppFontFallback.latin,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: text2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

/// Right-pointing chevron for rows that open another screen.
class _Chevron extends StatelessWidget {
  const _Chevron({required this.isDark});
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    return Icon(Icons.chevron_right_rounded, size: 18, color: text3);
  }
}

/// External-link glyph for rows that open a browser.
class _ExternalIcon extends StatelessWidget {
  const _ExternalIcon({required this.isDark});
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    return Icon(Icons.open_in_new_rounded, size: 16, color: text3);
  }
}

/// Honest "not yet available" tag for deferred rows — not a fake control.
class _SoonTag extends StatelessWidget {
  const _SoonTag();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    return Text('SOON', style: AppText.sectionLabel(color: text3));
  }
}

// ── Appearance: theme toggle ───────────────────────────────────────────────

class _ThemeRow extends ConsumerWidget {
  const _ThemeRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final icon = themeMode == ThemeMode.dark
        ? Icons.dark_mode_rounded
        : themeMode == ThemeMode.light
            ? Icons.light_mode_rounded
            : Icons.brightness_auto_rounded;
    return _Row(
      isDark: isDark,
      icon: icon,
      title: 'Theme',
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

// ── Reading: font size slider ──────────────────────────────────────────────

class _FontSizeRow extends ConsumerWidget {
  const _FontSizeRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final fontSize = ref.watch(fontSizeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Row(
          isDark: isDark,
          icon: Icons.format_size_rounded,
          title: 'Reading font size',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Row(
            children: [
              Text(
                'A',
                style: TextStyle(
                  fontFamily: Fonts.serif,
                  fontFamilyFallback: AppFontFallback.latin,
                  fontSize: 13,
                  color: text3,
                ),
              ),
              Expanded(
                child: Slider(
                  value: fontSize,
                  min: kMinFontSize,
                  max: kMaxFontSize,
                  divisions: ((kMaxFontSize - kMinFontSize) / 2).round(),
                  activeColor: saffron,
                  onChanged: (v) =>
                      ref.read(fontSizeProvider.notifier).setFontSize(v),
                ),
              ),
              Text(
                'A',
                style: TextStyle(
                  fontFamily: Fonts.serif,
                  fontFamilyFallback: AppFontFallback.latin,
                  fontSize: 22,
                  color: text3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Reading: translation language ──────────────────────────────────────────

/// Brief §2.4 / §6: v1 ships English only. Row is static — no chevron,
/// no tap, no picker. localeProvider stays wired for v2 (Hindi UI alongside
/// Hindi content); the picker UI returns when Hindi content ships.
class _LanguageRow extends ConsumerWidget {
  const _LanguageRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    return _Row(
      isDark: isDark,
      icon: Icons.translate_rounded,
      title: l10n.settingsLanguage,
      subtitle: l10n.settingsLanguageEnglish,
    );
  }
}

// ── Reading: scripture experience level ────────────────────────────────────

class _ExperienceRow extends ConsumerWidget {
  const _ExperienceRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final level = ref.watch(userExperienceLevelProvider);
    return _Row(
      isDark: isDark,
      icon: Icons.school_outlined,
      title: 'Scripture experience',
      subtitle: level.displayTitle,
      trailing: _Chevron(isDark: isDark),
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
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final text1 = isDark ? DColors.text1 : LColors.text1;
          final text2 = isDark ? DColors.text2 : LColors.text2;
          final text3 = isDark ? DColors.text3 : LColors.text3;
          final saffron = isDark ? DColors.saffron : LColors.saffron;
          final current = refSheet.watch(userExperienceLevelProvider);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                    child: Text(
                      'SCRIPTURE EXPERIENCE',
                      style: AppText.sectionLabel(color: text3),
                    ),
                  ),
                  for (final UserExperienceLevel l
                      in UserExperienceLevel.values)
                    ListTile(
                      selected: current == l,
                      title: Text(
                        l.displayTitle,
                        style: TextStyle(
                          fontFamily: Fonts.sans,
                          fontFamilyFallback: AppFontFallback.latin,
                          fontSize: 14,
                          color: text1,
                        ),
                      ),
                      subtitle: Text(
                        l.displaySubtitle,
                        style: TextStyle(
                          fontFamily: Fonts.serif,
                          fontFamilyFallback: AppFontFallback.latin,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: text2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: current == l
                          ? Icon(Icons.check_circle, color: saffron)
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

// ── Notifications: daily verse reminder ────────────────────────────────────

class _NotificationTimeRow extends ConsumerWidget {
  const _NotificationTimeRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final time = ref.watch(notificationTimeProvider);
    return _Row(
      isDark: isDark,
      icon: Icons.notifications_outlined,
      title: 'Daily verse reminder',
      trailing: TextButton(
        onPressed: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time,
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme:
                    Theme.of(context).colorScheme.copyWith(primary: saffron),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            ref.read(notificationTimeProvider.notifier).setTime(picked);
          }
        },
        child: Text(
          time.format(context),
          style: TextStyle(
            fontFamily: Fonts.sans,
            fontFamilyFallback: AppFontFallback.latin,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: saffron,
          ),
        ),
      ),
    );
  }
}

// ── Data: clear reading history ────────────────────────────────────────────

class _ClearHistoryRow extends ConsumerWidget {
  const _ClearHistoryRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _Row(
      isDark: isDark,
      icon: Icons.delete_outline_rounded,
      title: 'Clear reading history',
      subtitle: 'Resets streaks and read counts',
      onTap: () => _showConfirmDialog(context, ref),
    );
  }

  Future<void> _showConfirmDialog(BuildContext context, WidgetRef ref) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iron = isDark ? DColors.ironRedBright : LColors.ironRedBright;
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
            style: TextButton.styleFrom(foregroundColor: iron),
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

// ── About: app version ─────────────────────────────────────────────────────

class _AppVersionRow extends StatelessWidget {
  const _AppVersionRow();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data;
        final text = version != null
            ? 'v${version.version} (${version.buildNumber})'
            : '...';
        return _Row(
          isDark: isDark,
          icon: Icons.info_outline_rounded,
          title: 'Sanatan Guide',
          trailing: Text(text, style: AppText.meta(color: text3)),
        );
      },
    );
  }
}

// ── Reset: restore defaults ────────────────────────────────────────────────

class _ResetRow extends ConsumerWidget {
  const _ResetRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _Row(
      isDark: isDark,
      icon: Icons.restart_alt_rounded,
      title: 'Reset all settings',
      subtitle: 'Restore theme, font, language, and reminders to defaults',
      danger: true,
      onTap: () => _showResetDialog(context, ref),
    );
  }

  Future<void> _showResetDialog(BuildContext context, WidgetRef ref) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iron = isDark ? DColors.ironRedBright : LColors.ironRedBright;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset all settings?'),
        content: const Text(
          'Theme, reading font size, language, daily reminder time, and '
          'scripture experience will return to their defaults. Your '
          'bookmarks, notes, and reading history are not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: iron),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    // Each notifier setter persists to SharedPreferences; reset is durable.
    // No analytics event here — reset is a bulk restore, not a user toggle.
    await ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
    await ref.read(fontSizeProvider.notifier).setFontSize(kDefaultFontSize);
    await ref.read(localeProvider.notifier).setLocale(null);
    await ref
        .read(notificationTimeProvider.notifier)
        .setTime(const TimeOfDay(hour: 7, minute: 0));
    await ref
        .read(userExperienceLevelProvider.notifier)
        .setLevel(UserExperienceLevel.regular);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings reset')),
      );
    }
  }
}
