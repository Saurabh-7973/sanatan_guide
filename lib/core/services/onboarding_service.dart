import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanatan_guide/core/constants/preferences_keys.dart';

part 'onboarding_service.g.dart';

@riverpod
Future<bool> onboardingComplete(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(PrefsKeys.onboardingComplete) ?? false;
}

final class OnboardingService {
  OnboardingService._();

  /// Whether the user has finished onboarding (path pick or skip).
  static Future<bool> isComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefsKeys.onboardingComplete) ?? false;
  }

  /// Mark onboarding as done. Call after path selection or skip.
  static Future<void> markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.onboardingComplete, true);
  }

  /// For testing only — resets onboarding so it shows again.
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.onboardingComplete);
    await prefs.remove(PrefsKeys.userExperienceLevel);
  }
}
