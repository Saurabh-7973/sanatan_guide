import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/domain/entities/commentary.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/commentary_formatting.dart';

Commentary _make({
  String? translator,
  String license = 'public_domain',
  String tradition = 'advaita',
}) =>
    Commentary(
      id: 'x',
      verseId: 'BG.2.47',
      tradition: tradition,
      author: 'Adi Shankaracharya',
      sourceUrl: 'https://archive.org/...',
      license: license,
      createdAt: DateTime(2024, 1, 1),
      translator: translator,
    );

void main() {
  group('commentaryTraditionLabel', () {
    test('maps known codes to human labels', () {
      expect(commentaryTraditionLabel('advaita'), 'Advaita Vedanta');
      expect(commentaryTraditionLabel('vishishtadvaita'), 'Vishishtadvaita');
      expect(commentaryTraditionLabel('dvaita'), 'Dvaita');
    });

    test('falls back to the raw code for unknown traditions', () {
      expect(commentaryTraditionLabel('shaiva_siddhanta'), 'shaiva_siddhanta');
    });
  });

  group('commentaryProvenanceLine', () {
    test('public-domain + named translator produces attribution sentence', () {
      expect(
        commentaryProvenanceLine(_make(translator: 'A. Mahadeva Sastri')),
        'Translation: A. Mahadeva Sastri. Public domain.',
      );
    });

    test('no translator (Sanskrit-only) still states license', () {
      expect(commentaryProvenanceLine(_make()), 'Public domain.');
    });

    test('empty translator string is treated as null', () {
      expect(commentaryProvenanceLine(_make(translator: '')), 'Public domain.');
    });

    test('CC license is formatted in human-readable form', () {
      expect(
        commentaryProvenanceLine(
          _make(translator: 'Jane Doe', license: 'cc_by_sa'),
        ),
        'Translation: Jane Doe. License: CC-BY-SA.',
      );
    });
  });
}
