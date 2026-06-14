// lib/presentation/features/settings/pages/settings_page.dart
//
// Settings — heritage spec 11 (S4). Visual restyle of the working 7-provider
// settings screen onto the heritage language: WarmBackdrop, AppText.sectionLabel
// headers with hairlines, restrained rows, iron-red Reset section. Every
// provider and behavior is preserved; only the presentation changed.

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

// `kDefaultFontSize` is also exported by material.dart (14.0); we need the
// app's reading-font default (16.0) from font_size_provider.
import 'package:flutter/material.dart' hide kDefaultFontSize;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sanatan_guide/core/services/analytics_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/domain/entities/script_style.dart';
import 'package:sanatan_guide/domain/entities/user_experience_level.dart';
import 'package:sanatan_guide/l10n/generated/app_localizations.dart';
import 'package:sanatan_guide/presentation/features/onboarding/providers/user_experience_level_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/font_size_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/locale_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/verse_detail_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/analytics_enabled_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/crashlytics_enabled_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/notification_time_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/script_style_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/theme_mode_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/system_chrome.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';
import 'package:sanatan_guide/presentation/shared/widgets/mockup_icons.dart';

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
                        icon: const MockupBackChevron(),
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
                      // ── Reading ─────────────────────────────────────────────
                      // Mockup screen-09 puts Theme under READING, not its
                      // own APPEARANCE section. Collapse Appearance into the
                      // first row of Reading per ditto.
                      _SectionHeader(
                        title: l10n.settingsSectionReading,
                        isDark: isDark,
                      ),
                      const _ThemeRow(),
                      const _FontSizeRow(),
                      const _LanguageRow(),
                      const _SanskritDisplayRow(),
                      const _AlmanacScriptRow(),
                      const _ExperienceRow(),

                      // ── Notifications ───────────────────────────────────────
                      _SectionHeader(
                        title: l10n.settingsSectionNotifications,
                        isDark: isDark,
                      ),
                      const _NotificationTimeRow(),
                      const _BatteryOptimizationRow(),
                      const _FestivalAlertsRow(),

                      // ── Data ────────────────────────────────────────────────
                      _SectionHeader(
                        title: l10n.settingsSectionData,
                        isDark: isDark,
                      ),
                      // screen-09 puts the size in the subtitle (size +
                      // offline reassurance), no trailing value, no icon.
                      _Row(
                        isDark: isDark,
                        title: 'Storage',
                        subtitle: '~65 MB · full library cached offline',
                      ),
                      // Export bookmarks deferred until v1.1 — the
                      // backing flow needs share_plus + a small JSON
                      // schema; tracking in V1_FINAL_AUDIT.
                      const _ClearHistoryRow(),

                      // ── Privacy ─────────────────────────────────────────────
                      _SectionHeader(
                        title: 'Privacy',
                        isDark: isDark,
                      ),
                      const _AnalyticsOptOutRow(),
                      const _CrashlyticsOptOutRow(),

                      // ── About ───────────────────────────────────────────────
                      _SectionHeader(
                        title: l10n.settingsSectionAbout,
                        isDark: isDark,
                      ),
                      _Row(
                        isDark: isDark,
                        title: 'Credits & attributions',
                        trailing: _Chevron(isDark: isDark),
                        onTap: () => context.push('/credits'),
                      ),
                      _Row(
                        isDark: isDark,
                        title: l10n.settingsPrivacyPolicy,
                        trailing: _ExternalIcon(isDark: isDark),
                        onTap: () {
                          AnalyticsService.externalLink(
                            host: Uri.parse(_kPrivacyUrl).host,
                            source: 'privacy',
                          );
                          launchUrl(
                            Uri.parse(_kPrivacyUrl),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                      _Row(
                        isDark: isDark,
                        title: l10n.settingsTermsOfService,
                        trailing: _ExternalIcon(isDark: isDark),
                        onTap: () {
                          AnalyticsService.externalLink(
                            host: Uri.parse(_kTermsUrl).host,
                            source: 'terms',
                          );
                          launchUrl(
                            Uri.parse(_kTermsUrl),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                      _Row(
                        isDark: isDark,
                        title: 'Send feedback',
                        trailing: _Chevron(isDark: isDark),
                        onTap: () => context.push('/feedback'),
                      ),

                      // ── Reset ───────────────────────────────────────────────
                      _SectionHeader(
                          title: 'Reset', isDark: isDark, danger: true),
                      const _ResetRow(),

                      const _BrandFooter(),
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
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final bool isDark;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    // screen-09 deliberately drops all per-row leading icons — the section
    // header carries the context. Icons remain only on the theme segmented
    // control and the external-link glyph (Privacy / Terms).
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

/// QA helper: 3 taps within 1.5 s on the version label fires a hard
/// Crashlytics test crash so we can verify the symbolication pipeline
/// on a real release build. Each tap shows a small toast so QA knows
/// the gesture is registering. Hidden by design — production users
/// won't discover the gesture by accident.
abstract final class _CrashTestCounter {
  static int _count = 0;
  static DateTime _firstAt = DateTime(2000);
  static const _window = Duration(milliseconds: 1500);

  static void bump(BuildContext context) {
    final now = DateTime.now();
    if (now.difference(_firstAt) > _window) {
      _count = 1;
      _firstAt = now;
    } else {
      _count += 1;
    }

    // Toast feedback so QA knows the tap registered. SnackBar is
    // cheap enough for a debug-only path.
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (_count < 3) {
      messenger?.removeCurrentSnackBar();
      messenger?.showSnackBar(
        SnackBar(
          content: Text('Crash test: tap ${3 - _count} more time(s) within 1.5 s'),
          duration: const Duration(milliseconds: 900),
        ),
      );
      return;
    }

    _count = 0;
    messenger?.removeCurrentSnackBar();
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Crash test fired — app will close. Reopen + wait 5 min for Crashlytics.'),
        duration: Duration(seconds: 2),
      ),
    );
    // Fire the hard native crash AFTER the SnackBar paints, so the
    // tester actually sees the confirmation before the process dies.
    // FirebaseCrashlytics.instance.crash() calls Process.killProcess
    // on Android — guarantees the report uploads on next launch.
    Future<void>.delayed(
      const Duration(milliseconds: 600),
      FirebaseCrashlytics.instance.crash,
    );
  }
}

/// Bottom-of-page footer with brand + version. Replaces the older
/// "Sanatan Guide" row that lived inside the About section — design
/// screen-09 places the version line at the very bottom of the
/// scroll, after every actionable row.
class _BrandFooter extends StatelessWidget {
  const _BrandFooter();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
      child: Column(
        children: [
          Text(
            'सनातन',
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontFamilyFallback: AppFontFallback.deva,
              fontSize: 22,
              color: saffron,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sanatan Guide',
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontStyle: FontStyle.italic,
              fontSize: 13,
              color: text3,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) {
              final version = snap.data;
              // Flutter's split-per-abi build offsets versionCode per ABI
              // (armv7 +1000, arm64 +2000, x86_64 +4000). The user-visible
              // build number is the pubspec `+N`, which is `versionCode %
              // 1000` on every ABI.
              final rawBuild = int.tryParse(version?.buildNumber ?? '');
              final displayBuild =
                  rawBuild == null ? version?.buildNumber : '${rawBuild % 1000}';
              final label = version == null
                  ? '...'
                  : 'V${version.version} · BUILD $displayBuild';
              final versionText = Text(
                label,
                style: TextStyle(
                  fontFamily: Fonts.sans,
                  fontFamilyFallback: AppFontFallback.latin,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.18 * 10.5,
                  color: text3,
                ),
              );
              // The triple-tap-to-crash QA gesture is debug-only — a
              // production user must never be able to crash the app by
              // tapping the version line. The Crashlytics symbolication
              // pipeline was already verified on release builds.
              if (!kDebugMode) return versionText;
              return GestureDetector(
                onTap: () => _CrashTestCounter.bump(context),
                child: versionText,
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Made in Bhārata',
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontFamilyFallback: AppFontFallback.latin,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.22 * 10,
              color: text3,
            ),
          ),
        ],
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
    return MockupRowChevron(color: text3);
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

// ── Appearance: theme toggle ───────────────────────────────────────────────

class _ThemeRow extends ConsumerWidget {
  const _ThemeRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    // screen-09 theme row: no leading icon, just the label + a compact
    // 3-segment icon control (Auto · Light · Dark). Active segment fills
    // saffron; that's the "something different" the previous tab-like
    // SegmentedButton lost.
    return _Row(
      isDark: isDark,
      title: 'Theme',
      trailing: _ThemeSegmented(current: themeMode, isDark: isDark),
    );
  }
}

/// The `.seg` icon segmented control from screen-09: a rounded surface
/// pill holding three 36×30 icon cells. The active cell fills saffron.
class _ThemeSegmented extends ConsumerWidget {
  const _ThemeSegmented({required this.current, required this.isDark});

  final ThemeMode current;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surface = isDark ? DColors.surface : LColors.surface;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dividerSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(ref, ThemeMode.system, Icons.brightness_auto_rounded, 'Auto'),
          const SizedBox(width: 2),
          _seg(ref, ThemeMode.light, Icons.light_mode_rounded, 'Light'),
          const SizedBox(width: 2),
          _seg(ref, ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
        ],
      ),
    );
  }

  Widget _seg(WidgetRef ref, ThemeMode mode, IconData icon, String tip) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final inactiveFg = isDark ? DColors.text3 : LColors.text3;
    final activeFg = isDark ? const Color(0xFF1A1208) : Colors.white;
    final active = current == mode;
    return Semantics(
      button: true,
      selected: active,
      label: tip,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // Analytics logged centrally in themeModeProvider.setThemeMode.
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
        },
        child: Container(
          width: 36,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? saffron : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, size: 16, color: active ? activeFg : inactiveFg),
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
          title: 'Reading font size',
          subtitle: 'Affects Sanskrit and translation text',
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
      title: l10n.settingsLanguage,
      subtitle: l10n.settingsLanguageEnglish,
    );
  }
}

// ── Reading: Sanskrit display (IAST toggle) ────────────────────────────────

class _SanskritDisplayRow extends ConsumerWidget {
  const _SanskritDisplayRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iast =
        ref.watch(transliterationEnabledProvider).asData?.value ?? false;
    return _Row(
      isDark: isDark,
      title: 'Sanskrit display',
      subtitle: iast ? 'Devanāgarī · IAST diacritics on' : 'Devanāgarī only',
      trailing: _Chevron(isDark: isDark),
      onTap: () => ref.read(transliterationEnabledProvider.notifier).toggle(),
    );
  }
}

// ── Reading: almanac / calendar script ─────────────────────────────────────
//
// Controls how the home panchang line scripts its Sanskrit names —
// Devanāgarī, Latin (IAST), or both. Requested by beta testers who wanted a
// Latin reading of the almanac. Defaults to Both.

class _AlmanacScriptRow extends ConsumerWidget {
  const _AlmanacScriptRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = ref.watch(scriptStyleProvider);
    return _Row(
      isDark: isDark,
      title: 'Almanac script',
      subtitle: style.displayTitle,
      trailing: _Chevron(isDark: isDark),
      onTap: () => _showScriptSheet(context, ref),
    );
  }

  Future<void> _showScriptSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Consumer(
        builder: (context, refSheet, _) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final text1 = isDark ? DColors.text1 : LColors.text1;
          final text3 = isDark ? DColors.text3 : LColors.text3;
          final saffron = isDark ? DColors.saffron : LColors.saffron;
          final current = refSheet.watch(scriptStyleProvider);
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
                      'ALMANAC SCRIPT',
                      style: AppText.sectionLabel(color: text3),
                    ),
                  ),
                  for (final ScriptStyle s in ScriptStyle.values)
                    ListTile(
                      selected: current == s,
                      title: Text(
                        s.displayTitle,
                        style: TextStyle(
                          fontFamily: Fonts.sans,
                          fontFamilyFallback: AppFontFallback.latin,
                          fontSize: 14,
                          color: text1,
                        ),
                      ),
                      trailing: current == s
                          ? Icon(Icons.check_circle, color: saffron)
                          : null,
                      onTap: () async {
                        await refSheet
                            .read(scriptStyleProvider.notifier)
                            .setStyle(s);
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

// ── Reading: scripture experience level ────────────────────────────────────

class _ExperienceRow extends ConsumerWidget {
  const _ExperienceRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final level = ref.watch(userExperienceLevelProvider);
    return _Row(
      isDark: isDark,
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

// ── Notifications: battery-optimisation exempt ────────────────────────────

class _BatteryOptimizationRow extends ConsumerStatefulWidget {
  const _BatteryOptimizationRow();
  @override
  ConsumerState<_BatteryOptimizationRow> createState() =>
      _BatteryOptimizationRowState();
}

class _BatteryOptimizationRowState
    extends ConsumerState<_BatteryOptimizationRow> {
  PermissionStatus? _status;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final s = await Permission.ignoreBatteryOptimizations.status;
    if (mounted) setState(() => _status = s);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final ironRedBright =
        isDark ? DColors.ironRedBright : LColors.ironRedBright;
    final granted = _status == PermissionStatus.granted;
    return _Row(
      isDark: isDark,
      title: 'Battery optimisation',
      subtitle: granted
          ? 'Reminder is exempt — fires reliably at the picked time'
          : 'Vendor doze may delay notifications. Tap to exempt.',
      trailing: granted
          ? Text(
              'EXEMPT',
              style: TextStyle(
                fontFamily: Fonts.sans,
                fontFamilyFallback: AppFontFallback.latin,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
                color: saffron,
              ),
            )
          : Text(
              'NEEDS FIX',
              style: TextStyle(
                fontFamily: Fonts.sans,
                fontFamilyFallback: AppFontFallback.latin,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
                color: ironRedBright,
              ),
            ),
      onTap: () async {
        if (granted) {
          await openAppSettings();
        } else {
          await Permission.ignoreBatteryOptimizations.request();
        }
        await _refresh();
      },
    );
  }
}

// ── Notifications: festival alerts toggle ─────────────────────────────────
//
// Persists the user's preference. The scheduling job that posts day-of
// festival notifications is wired separately; this switch is the gate
// the scheduler reads before firing — off by default.

class _FestivalAlertsRow extends ConsumerWidget {
  const _FestivalAlertsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final enabled = ref.watch(festivalAlertsEnabledProvider);
    return _Row(
      isDark: isDark,
      title: 'Festival alerts',
      subtitle: 'Day before each major parva',
      trailing: Switch(
        value: enabled,
        activeThumbColor: isDark ? const Color(0xFF1A1208) : Colors.white,
        activeTrackColor: saffron,
        onChanged: (v) =>
            ref.read(festivalAlertsEnabledProvider.notifier).setEnabled(v),
      ),
    );
  }
}

// ── Privacy: analytics opt-out ────────────────────────────────────────────
//
// Firebase Analytics + Crashlytics ship enabled by default. Letting the
// user flip Analytics off (Crashlytics stays — fatal crashes are still
// captured) is a Play Console "Data Safety" hygiene win and a privacy
// nicety. The provider both persists the choice and calls
// FirebaseAnalytics.setAnalyticsCollectionEnabled at the SDK level so
// no events leave the device when it's off.

class _AnalyticsOptOutRow extends ConsumerWidget {
  const _AnalyticsOptOutRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final enabled = ref.watch(analyticsEnabledProvider);
    return _Row(
      isDark: isDark,
      title: 'Anonymous usage analytics',
      subtitle:
          'Helps improve the app. No personal data is collected. Crash reports are unaffected.',
      trailing: Switch(
        value: enabled,
        activeThumbColor: isDark ? const Color(0xFF1A1208) : Colors.white,
        activeTrackColor: saffron,
        onChanged: (v) =>
            ref.read(analyticsEnabledProvider.notifier).setEnabled(v),
      ),
    );
  }
}

// ── Privacy: crashlytics opt-out ──────────────────────────────────────────
//
// Pairs with _AnalyticsOptOutRow. Defaults match the prior global policy
// (off in debug, on in release). The toggle still works in debug if a
// developer wants to test the flow; it just persists the choice.

class _CrashlyticsOptOutRow extends ConsumerWidget {
  const _CrashlyticsOptOutRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final enabled = ref.watch(crashlyticsEnabledProvider);
    return _Row(
      isDark: isDark,
      title: 'Crash reports',
      subtitle:
          'Sends a stack trace when the app crashes so we can fix it. No personal data.',
      trailing: Switch(
        value: enabled,
        activeThumbColor: isDark ? const Color(0xFF1A1208) : Colors.white,
        activeTrackColor: saffron,
        onChanged: (v) =>
            ref.read(crashlyticsEnabledProvider.notifier).setEnabled(v),
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
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final time = ref.watch(notificationTimeProvider);
    final enabled = ref.watch(notificationEnabledProvider);
    return _Row(
      isDark: isDark,
      title: 'Daily verse reminder',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time picker — disabled when reminder is off.
          Opacity(
            opacity: enabled ? 1 : 0.4,
            child: TextButton(
              onPressed: !enabled
                  ? null
                  : () async {
                      final picked = await showHeritageTimePicker(
                        context: context,
                        initial: time,
                      );
                      if (picked != null) {
                        ref
                            .read(notificationTimeProvider.notifier)
                            .setTime(picked);
                      }
                    },
              child: Text(
                time.format(context),
                style: TextStyle(
                  fontFamily: Fonts.sans,
                  fontFamilyFallback: AppFontFallback.latin,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: enabled ? saffron : text3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Toggle. Off → notification cancelled by verse-of-day provider.
          Switch(
            value: enabled,
            onChanged: (v) =>
                ref.read(notificationEnabledProvider.notifier).setEnabled(v),
            activeThumbColor: isDark ? const Color(0xFF1A1208) : Colors.white,
            activeTrackColor: saffron,
            inactiveThumbColor: text3,
            inactiveTrackColor:
                isDark ? DColors.dividerSoft : LColors.dividerSoft,
          ),
        ],
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
      title: 'Clear reading history',
      subtitle: 'Resets streaks and read counts',
      trailing: _Chevron(isDark: isDark),
      onTap: () => _showConfirmDialog(context, ref),
      danger: true,
    );
  }

  Future<void> _showConfirmDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showHeritageConfirmDialog(
      context,
      title: 'Clear reading history?',
      body: 'This will reset your streak, read counts, and reading history. '
          'Bookmarks and notes will be kept.',
      confirmLabel: 'Clear',
      isDangerous: true,
    );
    if (confirmed != true || !context.mounted) return;
    await StreakService.instance.clearAllHistory();
    ref.invalidate(currentStreakProvider);
    if (context.mounted) {
      showHeritageToast(context, 'Reading history cleared');
    }
  }
}

/// Heritage-toned time picker bottom sheet — replaces Material's
/// showTimePicker for the daily-reminder row. Two scroll wheels (hour
/// 0-23 + minute 0-59) inside a saffron-tinted center band, paired
/// Cancel + Save pill buttons. Returns the picked TimeOfDay, or null
/// on cancel.
Future<TimeOfDay?> showHeritageTimePicker({
  required BuildContext context,
  required TimeOfDay initial,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final saffron = isDark ? DColors.saffron : LColors.saffron;
  final surface = isDark ? DColors.surface : LColors.surface;
  final text1 = isDark ? DColors.text1 : LColors.text1;
  final text2 = isDark ? DColors.text2 : LColors.text2;
  final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;

  var hour = initial.hour;
  var minute = initial.minute;
  final hourCtrl = FixedExtentScrollController(initialItem: hour);
  final minuteCtrl = FixedExtentScrollController(initialItem: minute);

  final result = await showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Daily reminder',
              style: TextStyle(
                fontFamily: Fonts.serif,
                fontFamilyFallback: AppFontFallback.latin,
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: text1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pick the hour for your verse to arrive',
              style: TextStyle(
                fontFamily: Fonts.serif,
                fontFamilyFallback: AppFontFallback.latin,
                fontStyle: FontStyle.italic,
                fontSize: 12.5,
                color: text2,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center band — saffron-tinted, hairline borders.
                  IgnorePointer(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: saffron.withValues(alpha: isDark ? 0.08 : 0.06),
                        border: Border(
                          top: BorderSide(color: dividerSoft, width: 1),
                          bottom: BorderSide(color: dividerSoft, width: 1),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Wheel(
                        controller: hourCtrl,
                        count: 24,
                        initial: hour,
                        onChanged: (v) => hour = v,
                        formatter: (v) => v.toString().padLeft(2, '0'),
                        text1: text1,
                        text2: text2,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontFamily: Fonts.serif,
                            fontFamilyFallback: AppFontFallback.latin,
                            fontSize: 24,
                            color: text1,
                          ),
                        ),
                      ),
                      _Wheel(
                        controller: minuteCtrl,
                        count: 60,
                        initial: minute,
                        onChanged: (v) => minute = v,
                        formatter: (v) => v.toString().padLeft(2, '0'),
                        text1: text1,
                        text2: text2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: text2.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        fontFamily: Fonts.sans,
                        fontFamilyFallback: AppFontFallback.latin,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.12 * 12,
                        color: text2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Material(
                    color: saffron,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.of(ctx)
                          .pop(TimeOfDay(hour: hour, minute: minute)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'SAVE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: Fonts.sans,
                            fontFamilyFallback: AppFontFallback.latin,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.12 * 12,
                            color:
                                isDark ? const Color(0xFF1A1208) : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  hourCtrl.dispose();
  minuteCtrl.dispose();
  return result;
}

class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.controller,
    required this.count,
    required this.initial,
    required this.onChanged,
    required this.formatter,
    required this.text1,
    required this.text2,
  });

  final FixedExtentScrollController controller;
  final int count;
  final int initial;
  final void Function(int) onChanged;
  final String Function(int) formatter;
  final Color text1;
  final Color text2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 40,
        physics: const FixedExtentScrollPhysics(),
        perspective: 0.003,
        diameterRatio: 1.8,
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: count,
          builder: (_, i) => Center(
            child: Text(
              formatter(i),
              style: TextStyle(
                fontFamily: Fonts.sans,
                fontFamilyFallback: AppFontFallback.latin,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: i == initial ? text1 : text2,
              ),
            ),
          ),
        ),
      ),
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
      title: 'Reset all settings',
      subtitle: 'Restore theme, font, language, and reminders to defaults',
      trailing: _Chevron(isDark: isDark),
      danger: true,
      onTap: () => _showResetDialog(context, ref),
    );
  }

  Future<void> _showResetDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showHeritageConfirmDialog(
      context,
      title: 'Reset all settings?',
      body: 'Theme, reading font size, language, daily reminder time, and '
          'scripture experience will return to their defaults. Your '
          'bookmarks, notes, and reading history are not affected.',
      confirmLabel: 'Reset',
      isDangerous: true,
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
    await ref.read(scriptStyleProvider.notifier).setStyle(ScriptStyle.both);
    if (context.mounted) {
      showHeritageToast(context, 'Settings reset');
    }
  }
}
