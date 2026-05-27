import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanatan_guide/core/router/app_router.dart';
import 'package:sanatan_guide/core/services/ad_service.dart';
import 'package:sanatan_guide/core/services/analytics_service.dart';
import 'package:sanatan_guide/core/services/app_open_ad_service.dart';
import 'package:sanatan_guide/core/services/notification_service.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';
import 'package:sanatan_guide/firebase_options.dart';
import 'package:sanatan_guide/l10n/generated/app_localizations.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/locale_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/theme_mode_provider.dart';
import 'package:sanatan_guide/presentation/theme/app_theme.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keep the native splash visible until we explicitly remove it below.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Apply the user's persisted privacy preferences before any event or
  // crash report can leave the device. The Settings providers also wire
  // these, but reading the prefs here honours the persisted choice on
  // boot — not just after the user opens Settings.
  final prefs = await SharedPreferences.getInstance();
  // Crashlytics: default off in debug (dev noise), on in release.
  final crashlyticsEnabled =
      prefs.getBool('privacy_crashlytics_enabled') ?? !kDebugMode;
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(crashlyticsEnabled);
  // Analytics: default on for everyone, off only if the user opted out.
  final analyticsEnabled = prefs.getBool('privacy_analytics_enabled') ?? true;
  await AnalyticsService.setCollectionEnabled(analyticsEnabled);

  if (!kDebugMode) {
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await NotificationService.init();
  await AdService.initialize();
  // Pre-load the App Open Ad in the background.
  // It will be shown once when the splash completes.
  unawaited(AppOpenAdService.instance.preload());

  runApp(const ProviderScope(child: SanatanGuideApp()));
  // Dismiss the native splash once Flutter's first frame is drawn.
  FlutterNativeSplash.remove();
}

class SanatanGuideApp extends ConsumerStatefulWidget {
  const SanatanGuideApp({super.key});

  @override
  ConsumerState<SanatanGuideApp> createState() => _SanatanGuideAppState();
}

class _SanatanGuideAppState extends ConsumerState<SanatanGuideApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // After [MaterialApp.router] attaches, Android Activity is non-null for
    // flutter_local_notifications permission APIs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cold-start: NotificationService.init() may have queued a deep link
      // from getNotificationAppLaunchDetails(). Consume it now that the
      // router is attached.
      _consumePendingDeepLink();
      // Notification permission is no longer auto-requested at launch.
      // The native dialogs (POST_NOTIFICATIONS + SCHEDULE_EXACT_ALARM +
      // IGNORE_BATTERY_OPTIMIZATIONS) firing back-to-back on first open
      // felt hostile and didn't match the app's calm tone. Permission is
      // now requested only when the user explicitly opts in to the daily
      // reminder — in onboarding or via the Settings switch. Users who
      // never opt in never see the prompt.
    });
  }

  void _consumePendingDeepLink() {
    final deepLink = NotificationService.pendingDeepLink;
    if (deepLink == null || deepLink.isEmpty) return;
    NotificationService.pendingDeepLink = null;
    if (!mounted) return;
    AppLogger.instance.i('Applying pending deep link: $deepLink');
    ref.read(appRouterProvider).go(deepLink);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called whenever the app lifecycle changes.
  /// When resuming from background, check if a notification was tapped
  /// and navigate to the deep link if one is pending.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Defer until after the current frame so the router is ready.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _consumePendingDeepLink();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Sanatan Guide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      // App-wide: tapping anywhere outside a focused text field dismisses
      // the keyboard / drops focus.
      builder: (context, child) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          final focus = FocusManager.instance.primaryFocus;
          if (focus != null && focus.hasFocus) focus.unfocus();
        },
        child: child,
      ),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
