import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sanatan_guide/core/services/ad_service.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';

/// Manages the App Open Ad lifecycle.
///
/// Usage:
///   - Call preload() once after AdService.initialize()
///   - Call showIfReady() when the splash navigation completes
///   - The ad auto-disposes after being shown
///
/// The ad is only shown once per cold start — not on every resume.
/// This avoids the aggressive pattern that annoys users.
final class AppOpenAdService {
  AppOpenAdService._();
  static final AppOpenAdService instance = AppOpenAdService._();

  AppOpenAd? _ad;
  bool _isLoaded = false;
  bool _hasShownThisSession = false;

  /// Pre-loads the ad in the background. Call once after AdService.initialize().
  Future<void> preload() async {
    if (!AdService.isEnabled) return;
    if (_hasShownThisSession) return;

    await AppOpenAd.load(
      adUnitId: AdService.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoaded = true;
          AppLogger.instance.i('AppOpenAdService: ad loaded');
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _isLoaded = false;
          AppLogger.instance.w(
            'AppOpenAdService: failed to load — ${error.message}',
          );
        },
      ),
    );
  }

  /// Shows the ad if loaded and not yet shown this session.
  /// Safe to call even if the ad isn't ready — silently does nothing.
  Future<void> showIfReady() async {
    if (!AdService.isEnabled) return;
    if (!_isLoaded || _ad == null) return;
    if (_hasShownThisSession) return;

    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        _isLoaded = false;
        AppLogger.instance.i('AppOpenAdService: ad dismissed');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _ad = null;
        _isLoaded = false;
        AppLogger.instance.w(
          'AppOpenAdService: failed to show — ${error.message}',
        );
      },
    );

    _hasShownThisSession = true;
    await _ad!.show();
    AppLogger.instance.i('AppOpenAdService: ad shown');
  }

  /// Disposes the loaded ad without showing. Call if no longer needed.
  void dispose() {
    _ad?.dispose();
    _ad = null;
    _isLoaded = false;
  }
}
