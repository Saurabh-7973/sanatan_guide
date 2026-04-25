@Tags(['tool'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../tool/seed_shankara_commentary.dart' as seed;

/// Verifies the PD allowlist in [seed.runSeed]:
///   - accepts qualifying rows (GRETIL + archive.org + PD license),
///   - rejects bad host / bad license / empty text / missing field,
///   - never double-inserts on re-run,
///   - dry-run writes nothing.
void main() {
  late Database db;

  setUp(() => db = sqlite3.openInMemory());
  tearDown(() => db.dispose());

  Map<String, dynamic> validEntry({
    String id = 'shankara_gita_2.47',
    String verseId = 'BG.2.47',
    String? textSanskrit = 'कर्मण्येवाधिकारस्ते ...',
    String? textEnglish,
    String sourceUrl =
        'https://archive.org/details/bhagavadgitawith00shan',
    String license = 'public_domain',
    String tradition = 'advaita',
  }) =>
      {
        'id': id,
        'verse_id': verseId,
        'tradition': tradition,
        'author': 'Adi Shankaracharya',
        'text_sanskrit': textSanskrit,
        'text_english': textEnglish,
        'translator': 'A. Mahadeva Sastri',
        'source_url': sourceUrl,
        'license': license,
      };

  group('seed_shankara_commentary allowlist', () {
    test('accepts a PD archive.org entry', () {
      final (:inserted, :skipped, :rejected) = seed.runSeed(
        db: db,
        entries: [validEntry()],
      );
      expect(inserted, 1);
      expect(skipped, 0);
      expect(rejected, isEmpty);

      final rows = db.select('SELECT * FROM commentaries');
      expect(rows, hasLength(1));
      expect(rows.first['tradition'], 'advaita');
      expect(rows.first['license'], 'public_domain');
    });

    test('accepts a GRETIL Sanskrit-only entry', () {
      final (:inserted, :rejected, skipped: _) = seed.runSeed(
        db: db,
        entries: [
          validEntry(
            id: 'shankara_gita_2.47_sa',
            sourceUrl:
                'http://gretil.sub.uni-goettingen.de/gretil/sa_zaGkaragItAbhASya.xml',
          ),
        ],
      );
      expect(rejected, isEmpty);
      expect(inserted, 1);
    });

    test('rejects a non-allowlisted host', () {
      final (:inserted, :rejected, skipped: _) = seed.runSeed(
        db: db,
        entries: [
          validEntry(
            sourceUrl: 'https://somemodernpublisher.example.com/gita',
          ),
        ],
      );
      expect(inserted, 0);
      expect(rejected, hasLength(1));
      expect(rejected.first.reason, contains('allowlist'));
    });

    test('rejects a non-PD license', () {
      final (:inserted, :rejected, skipped: _) = seed.runSeed(
        db: db,
        entries: [validEntry(license: 'all_rights_reserved')],
      );
      expect(inserted, 0);
      expect(rejected.single.reason, contains('PD/CC-permitted'));
    });

    test('rejects an entry where both Sanskrit and English are empty', () {
      final (:inserted, :rejected, skipped: _) = seed.runSeed(
        db: db,
        entries: [validEntry(textSanskrit: null, textEnglish: null)],
      );
      expect(inserted, 0);
      expect(rejected.single.reason, contains('empty'));
    });

    test('rejects an entry missing required field', () {
      final bad = validEntry()..remove('author');
      final (:inserted, :rejected, skipped: _) = seed.runSeed(
        db: db,
        entries: [bad],
      );
      expect(inserted, 0);
      expect(rejected.single.reason, contains('author'));
    });

    test('rejects unknown tradition string', () {
      final (:inserted, :rejected, skipped: _) = seed.runSeed(
        db: db,
        entries: [validEntry(tradition: 'nondualism-lite')],
      );
      expect(inserted, 0);
      expect(rejected.single.reason, contains('tradition'));
    });

    test('re-run with same id skips instead of double-inserting', () {
      seed.runSeed(db: db, entries: [validEntry()]);
      final (:inserted, :skipped, :rejected) = seed.runSeed(
        db: db,
        entries: [validEntry()],
      );
      expect(inserted, 0);
      expect(skipped, 1);
      expect(rejected, isEmpty);
      expect(db.select('SELECT COUNT(*) c FROM commentaries').first['c'], 1);
    });

    test('dry-run writes nothing but reports planned inserts', () {
      final (:inserted, :rejected, skipped: _) = seed.runSeed(
        db: db,
        entries: [validEntry()],
        dryRun: true,
      );
      expect(inserted, 1);
      expect(rejected, isEmpty);
      expect(db.select('SELECT COUNT(*) c FROM commentaries').first['c'], 0);
    });

    test('mixed batch: good + bad are partitioned correctly', () {
      final (:inserted, :rejected, skipped: _) = seed.runSeed(
        db: db,
        entries: [
          validEntry(id: 'ok_1'),
          validEntry(
            id: 'bad_host',
            sourceUrl: 'https://malicious.example.com/x',
          ),
          validEntry(id: 'ok_2', verseId: 'BG.3.19'),
          validEntry(id: 'bad_license', license: 'proprietary'),
        ],
      );
      expect(inserted, 2);
      expect(rejected, hasLength(2));
      expect(
        db.select('SELECT COUNT(*) c FROM commentaries').first['c'],
        2,
      );
    });
  });
}
