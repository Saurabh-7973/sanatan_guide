/// User self-assessed comfort with scripture (onboarding + Settings).
enum UserExperienceLevel {
  beginner,
  regular,
  scholar;

  String get storageValue => name;

  String get displayTitle => switch (this) {
        UserExperienceLevel.beginner => 'Beginner',
        UserExperienceLevel.regular => 'Regular',
        UserExperienceLevel.scholar => 'Scholar',
      };

  String get displaySubtitle => switch (this) {
        UserExperienceLevel.beginner =>
          'New to Hindu scriptures — guided paths help most',
        UserExperienceLevel.regular =>
          'Comfortable with basics — mix learning and reading',
        UserExperienceLevel.scholar => 'Prefer direct texts and deeper study',
      };

  static UserExperienceLevel? fromStorage(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final v in UserExperienceLevel.values) {
      if (v.name == raw) return v;
    }
    return null;
  }
}
