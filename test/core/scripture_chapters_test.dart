import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/core/constants/scripture_chapters.dart';

/// Guards against the curated chapter metadata drifting away from what the
/// bundled DB actually ships. The Rigveda rollup once read 10,552 (canonical)
/// while the DB holds 9,508 — producing a header that lied about the content.
/// These counts are pinned to the bundled DB (verified via
/// `SELECT chapter_num, COUNT(DISTINCT chapter_label), COUNT(*)`); if the DB is
/// ever expanded, update both the metadata and these expectations together.
void main() {
  group('Rigveda chapter metadata matches bundled DB', () {
    final rigveda = scriptureChaptersFor('rigveda')!;

    test('sums to 9,508 verses across 10 maṇḍalas', () {
      final verses =
          rigveda.fold<int>(0, (sum, m) => sum + (m.verseCount ?? 0));
      expect(rigveda.length, 10);
      expect(verses, 9508);
    });

    test('sums to 1,027 hymns (suktas)', () {
      final suktas =
          rigveda.fold<int>(0, (sum, m) => sum + (m.chapterCount ?? 0));
      expect(suktas, 1027);
    });
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
