import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanatan_guide/core/constants/preferences_keys.dart';
import 'package:sanatan_guide/domain/entities/user_experience_level.dart';

part 'user_experience_level_provider.g.dart';

@Riverpod(keepAlive: true)
class UserExperienceLevelNotifier extends _$UserExperienceLevelNotifier {
  @override
  UserExperienceLevel build() {
    _load();
    return UserExperienceLevel.regular;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(PrefsKeys.userExperienceLevel);
    final parsed = UserExperienceLevel.fromStorage(raw);
    if (parsed != null) {
      state = parsed;
    }
  }

  Future<void> setLevel(UserExperienceLevel level) async {
    state = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.userExperienceLevel, level.storageValue);
  }
}
