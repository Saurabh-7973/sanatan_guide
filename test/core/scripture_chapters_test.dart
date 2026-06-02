import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/core/constants/scripture_chapters.dart';

/// Guards every curated *rollup* scripture (book/canto/maṇḍala level) against
/// drifting away from what the bundled DB actually ships. The metadata once
/// carried canonical counts the bundle doesn't contain — e.g. Rigveda 10,552
/// (DB 9,508) and Mahābhārata 83,049 / 18 parvas (DB 72,770 / 17) — producing
/// headers that lied about the content.
///
/// Expected values are the bundled DB's actuals, verified with:
///   SELECT COUNT(*) , COUNT(DISTINCT book_num) ...  (and per-maṇḍala for RV).
/// If the DB is ever expanded, update the metadata AND these numbers together.
void main() {
  // scriptureId -> (total verses, number of top-level rollup entries).
  const expected = <String, (int, int)>{
    'rigveda': (9508, 10),
    'mahabharata': (72770, 17),
    'ramayana': (18761, 7),
    'bhagavata_purana': (14031, 12),
    'arthashastra': (5371, 15),
  };

  expected.forEach((id, exp) {
    final (expVerses, expEntries) = exp;
    group('$id rollup matches bundled DB', () {
      final entries = scriptureChaptersFor(id)!;

      test('has $expEntries entries', () {
        expect(entries.length, expEntries);
      });

      test('verseCount sums to $expVerses', () {
        final sum =
            entries.fold<int>(0, (acc, m) => acc + (m.verseCount ?? 0));
        expect(sum, expVerses);
      });
    });
  });

  test('Rigveda sums to 1,027 hymns (suktas)', () {
    final suktas = scriptureChaptersFor('rigveda')!
        .fold<int>(0, (acc, m) => acc + (m.chapterCount ?? 0));
    expect(suktas, 1027);
  });

  test('selected-verses set is populated and lower-case ids', () {
    expect(kSelectedVersesScriptures, isNotEmpty);
    for (final id in kSelectedVersesScriptures) {
      expect(id, equals(id.toLowerCase()));
    }
    expect(isSelectedVersesScripture('manusmriti'), isTrue);
    expect(isSelectedVersesScripture('bhagavad_gita'), isFalse);
  });
}
