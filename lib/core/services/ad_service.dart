import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';

const bool _kAdsEnabled =
    bool.fromEnvironment('ADS_ENABLED', defaultValue: false);

const String _kNativeAdUnitId = String.fromEnvironment(
  'NATIVE_AD_UNIT_ID',
  defaultValue: 'ca-app-pub-3940256099942544/2247696110',
);

const String _kInterstitialAdUnitId = String.fromEnvironment(
  'INTERSTITIAL_AD_UNIT_ID',
  defaultValue: 'ca-app-pub-3940256099942544/1033173712',
);

const String _kAppOpenAdUnitId = String.fromEnvironment(
  'APP_OPEN_AD_UNIT_ID',
  defaultValue: 'ca-app-pub-3940256099942544/9257395921', // Google test
);

abstract final class AdService {
  static bool get isEnabled => _kAdsEnabled;

  static Future<void> initialize() async {
    if (!_kAdsEnabled) {
      AppLogger.instance.i('AdService: ads disabled (ADS_ENABLED=false)');
      return;
    }
    await MobileAds.instance.initialize();
    AppLogger.instance.i('AdService: MobileAds initialized');
  }

  static String get nativeAdUnitId => _kNativeAdUnitId;
  static String get interstitialAdUnitId => _kInterstitialAdUnitId;
  static String get appOpenAdUnitId => _kAppOpenAdUnitId;
}
