import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/core/utils/daily_reading_suggestion_resolver.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';

void main() {
  group('dailyReadingSuggestionFor', () {
    test('Monday → Shvetashvatara', () {
      final d = DateTime(2026, 4, 13); // Monday
      final s = dailyReadingSuggestionFor(d);
      expect(s.scripture, Scripture.shvetashvataraUpanishad);
      expect(s.verseId, 'SU.1.1');
      expect(s.title, contains('Shvetashvatara'));
    });

    test('Tuesday → Ramayana', () {
      final d = DateTime(2026, 4, 14);
      final s = dailyReadingSuggestionFor(d);
      expect(s.scripture, Scripture.ramayana);
      expect(s.verseId, 'RAM.1.1.1');
    });

    test('Wednesday → Vishnu Sahasranama', () {
      final d = DateTime(2026, 4, 15);
      final s = dailyReadingSuggestionFor(d);
      expect(s.scripture, Scripture.vishnuSahasranama);
      expect(s.verseId, 'VS.1.1');
    });

    test('Thursday → Yoga Sutras', () {
      final d = DateTime(2026, 4, 16);
      final s = dailyReadingSuggestionFor(d);
      expect(s.scripture, Scripture.yogaSutras);
      expect(s.verseId, 'YS.1.1');
    });

    test('Friday → Devi Bhagavata', () {
      final d = DateTime(2026, 4, 17);
      final s = dailyReadingSuggestionFor(d);
      expect(s.scripture, Scripture.deviBhagavataPurana);
      expect(s.verseId, 'DB.1.1');
    });

    test('Saturday → Gita Ch.2', () {
      final d = DateTime(2026, 4, 18);
      final s = dailyReadingSuggestionFor(d);
      expect(s.scripture, Scripture.bhagavadGita);
      expect(s.verseId, 'BG.2.1');
    });

    test('Sunday → Rigveda Gayatri', () {
      final d = DateTime(2026, 4, 19);
      final s = dailyReadingSuggestionFor(d);
      expect(s.scripture, Scripture.rigveda);
      expect(s.verseId, 'RV.3.62');
    });
  });
}
