import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';

// Minimal Verse factory for testing — only id and verseNum matter here
Verse _verse({required String id, int verseNum = 1, int chapterNum = 1}) =>
    Verse(
      id: id,
      scripture: ScriptureX.fromCode(scriptureCodeFromVerseId(id)),
      chapterNum: chapterNum,
      verseNum: verseNum,
      sanskrit: '',
      english: null,
      hindi: null,
      transliteration: null,
      chapterLabel: null,
      isBookmarked: false,
      readCount: 0,
      noteText: null,
      wordMeanings: null,
      bookNum: null,
      createdAt: DateTime(2024),
    );

void main() {
  group('getVerseLabel', () {
    test('Rigveda — Mandala · Hymn · Verse', () {
      expect(
        getVerseLabel(_verse(id: 'RV.1.1.1')),
        'Mandala 1 · Hymn 1 · Verse 1',
      );
      expect(
        getVerseLabel(_verse(id: 'RV.10.129.6')),
        'Mandala 10 · Hymn 129 · Verse 6',
      );
    });

    test('Atharvaveda — Kaanda · Sukta · Verse', () {
      expect(
        getVerseLabel(_verse(id: 'AV.1.1.1')),
        'Kaanda 1 · Sukta 1 · Verse 1',
      );
      expect(
        getVerseLabel(_verse(id: 'AV.20.143.5')),
        'Kaanda 20 · Sukta 143 · Verse 5',
      );
    });

    test('Chandogya — Prapathaka · Khanda · Verse', () {
      expect(
        getVerseLabel(_verse(id: 'CU.6.9.1')),
        'Prapathaka 6 · Khanda 9 · Verse 1',
      );
    });

    test('Brihadaranyaka — Adhyaya · Brahmana · Verse', () {
      expect(
        getVerseLabel(_verse(id: 'BAU.3.4.1')),
        'Adhyaya 3 · Brahmana 4 · Verse 1',
      );
    });

    test('Mahabharata — Parva · Chapter · Verse', () {
      expect(
        getVerseLabel(_verse(id: 'MBH.6.25.1')),
        'Parva 6 · Chapter 25 · Verse 1',
      );
    });

    test('Ramayana — Kanda · Sarga · Verse', () {
      expect(
        getVerseLabel(_verse(id: 'RAM.1.1.1')),
        'Kanda 1 · Sarga 1 · Verse 1',
      );
    });

    test('Bhagavata Purana — Skanda · Chapter · Verse', () {
      expect(
        getVerseLabel(_verse(id: 'BP.10.1.1')),
        'Skanda 10 · Chapter 1 · Verse 1',
      );
    });

    test('Arthashastra — Book · Chapter · Verse', () {
      expect(
        getVerseLabel(_verse(id: 'KAS.1.1.1')),
        'Book 1 · Chapter 1 · Verse 1',
      );
    });

    test('Tirukkural — Kural number', () {
      expect(getVerseLabel(_verse(id: 'TK.1')), 'Kural 1');
      expect(getVerseLabel(_verse(id: 'TK.133')), 'Kural 133');
    });

    test('Yajurveda — Adhyaya · Verse', () {
      expect(
        getVerseLabel(_verse(id: 'YV.1.1')),
        'Adhyaya 1 · Verse 1',
      );
    });

    test('Samaveda — Verse number only', () {
      expect(getVerseLabel(_verse(id: 'SV.42')), 'Verse 42');
    });

    test('Bhagavad Gita — Chapter · Verse', () {
      expect(
        getVerseLabel(_verse(id: 'BG.2.47')),
        'Chapter 2 · Verse 47',
      );
    });

    test('Unknown prefix — falls back to verseNum', () {
      expect(
        getVerseLabel(_verse(id: 'XX.1.1', verseNum: 5)),
        'Verse 5',
      );
    });
  });

  group('scriptureCodeFromVerseId', () {
    final cases = {
      'BG.1.1': 'bhagavad_gita',
      'RV.1.1.1': 'rigveda',
      'SV.1': 'samaveda',
      'YV.1.1': 'yajurveda',
      'AV.1.1.1': 'atharvaveda',
      'CU.1.1.1': 'chandogya_upanishad',
      'BAU.1.1.1': 'brihadaranyaka_upanishad',
      'MBH.1.1.1': 'mahabharata',
      'RAM.1.1.1': 'ramayana',
      'BP.1.1.1': 'bhagavata_purana',
      'KAS.1.1.1': 'arthashastra',
      'TK.1': 'tirukkural',
    };

    for (final entry in cases.entries) {
      test('${entry.key} → ${entry.value}', () {
        expect(scriptureCodeFromVerseId(entry.key), entry.value);
      });
    }
  });

  group('browseChapterPath', () {
    test('without bookNum', () {
      expect(
        browseChapterPath(scriptureCode: 'rigveda', chapterNum: 1),
        '/browse/rigveda/chapter/1',
      );
    });

    test('with bookNum', () {
      expect(
        browseChapterPath(
          scriptureCode: 'mahabharata',
          chapterNum: 25,
          bookNum: 6,
        ),
        '/browse/mahabharata/chapter/25?book=6',
      );
    });
  });

  group('browseVersePath', () {
    test('correct path format', () {
      expect(
        browseVersePath(scriptureCode: 'rigveda', verseId: 'RV.1.1.1'),
        '/browse/rigveda/verse/RV.1.1.1',
      );
    });
  });

  group('compareVerseIds', () {
    test('Bhagavad Gita verses keep ascending order', () {
      expect(compareVerseIds('BG.1.1', 'BG.1.2'), lessThan(0));
      expect(compareVerseIds('BG.1.2', 'BG.1.1'), greaterThan(0));
    });

    test('numeric, not lexical — BG.2.47 sorts after BG.2.9', () {
      expect(compareVerseIds('BG.2.47', 'BG.2.9'), greaterThan(0));
    });

    test('Rigveda sukta boundary — RV.1.1.9 before RV.1.2.1', () {
      expect(compareVerseIds('RV.1.1.9', 'RV.1.2.1'), lessThan(0));
    });

    test('Rigveda numeric — RV.1.1.10 after RV.1.1.9', () {
      expect(compareVerseIds('RV.1.1.10', 'RV.1.1.9'), greaterThan(0));
    });

    test('identical ids compare equal', () {
      expect(compareVerseIds('RV.1.1.1', 'RV.1.1.1'), 0);
    });

    test('sorting a scrambled Rigveda chapter yields reading order', () {
      final ids = ['RV.1.2.1', 'RV.1.1.10', 'RV.1.1.2', 'RV.1.1.1']
        ..sort(compareVerseIds);
      expect(ids, ['RV.1.1.1', 'RV.1.1.2', 'RV.1.1.10', 'RV.1.2.1']);
    });
  });
}
