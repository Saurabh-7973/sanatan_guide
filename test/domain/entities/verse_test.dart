import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';

void main() {
  group('Verse entity', () {
    late Verse testVerse;

    setUp(() {
      testVerse = Verse(
        id: 'BG.1.1',
        chapterNum: 1,
        verseNum: 1,
        scripture: Scripture.bhagavadGita,
        sanskrit: 'धृतराष्ट्र उवाच',
        english: 'Dhritarashtra said:',
        createdAt: DateTime(2024, 1, 1),
      );
    });

    test('equality — two Verses with same fields are equal', () {
      final verse2 = testVerse.copyWith();
      expect(verse2, equals(testVerse));
    });

    test('copyWith — changes only specified fields', () {
      final bookmarked = testVerse.copyWith(isBookmarked: true);
      expect(bookmarked.isBookmarked, isTrue);
      expect(bookmarked.id, equals(testVerse.id));
      expect(bookmarked.sanskrit, equals(testVerse.sanskrit));
    });

    test('default values — isBookmarked false, readCount 0', () {
      expect(testVerse.isBookmarked, isFalse);
      expect(testVerse.readCount, equals(0));
    });

    test('nullable fields — transliteration and hindi are null by default', () {
      expect(testVerse.transliteration, isNull);
      expect(testVerse.hindi, isNull);
    });
  });

  group('Scripture enum', () {
    test('fromCode roundtrip — code converts back to enum', () {
      for (final scripture in Scripture.values) {
        final code = scripture.code;
        final parsed = ScriptureX.fromCode(code);
        expect(parsed, equals(scripture));
      }
    });

    test('fromCode — unknown code throws ArgumentError', () {
      expect(
        () => ScriptureX.fromCode('unknown_scripture'),
        throwsArgumentError,
      );
    });
  });
}
