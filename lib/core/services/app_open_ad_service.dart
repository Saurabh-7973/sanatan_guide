/// Stub kept after the google_mobile_ads dep was dropped from v1. Same
/// public surface as before so main.dart's preload call and the home-page
/// showIfReady call still compile without conditional code.
final class AppOpenAdService {
  AppOpenAdService._();
  static final AppOpenAdService instance = AppOpenAdService._();

  Future<void> preload() async {}
  Future<void> showIfReady() async {}
}
