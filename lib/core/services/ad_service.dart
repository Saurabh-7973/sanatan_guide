import 'package:sanatan_guide/core/utils/app_logger.dart';

/// v1 ships without ads. The google_mobile_ads dep was removed to drop
/// ~5MB from the APK and remove the upstream deprecated-API warnings
/// from release builds. The public surface is preserved as no-op stubs
/// so feature code paths that gate on AdService.isEnabled still compile.
///
/// Re-introducing ads in v1.1 is a single change: re-add the package,
/// re-import google_mobile_ads here + in AppOpenAdService, restore the
/// MobileAds.initialize call below. Manifest meta-data + proguard rules
/// also need to come back. See commit history for the prior content.
abstract final class AdService {
  static bool get isEnabled => false;

  static Future<void> initialize() async {
    AppLogger.instance.i('AdService: ads dropped from v1 build');
  }

  static String get nativeAdUnitId => '';
  static String get interstitialAdUnitId => '';
  static String get appOpenAdUnitId => '';
}
