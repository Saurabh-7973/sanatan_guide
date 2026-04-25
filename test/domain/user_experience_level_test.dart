import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/domain/entities/user_experience_level.dart';

void main() {
  group('UserExperienceLevel.fromStorage', () {
    test('parses known values', () {
      expect(UserExperienceLevel.fromStorage('beginner'), UserExperienceLevel.beginner);
      expect(UserExperienceLevel.fromStorage('regular'), UserExperienceLevel.regular);
      expect(UserExperienceLevel.fromStorage('scholar'), UserExperienceLevel.scholar);
    });

    test('null or unknown → null', () {
      expect(UserExperienceLevel.fromStorage(null), isNull);
      expect(UserExperienceLevel.fromStorage(''), isNull);
      expect(UserExperienceLevel.fromStorage('nope'), isNull);
    });
  });
}
