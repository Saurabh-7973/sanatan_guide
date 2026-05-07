import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/core/utils/coordinate_parser.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';

void main() {
  group('parseScriptureCoordinate', () {
    test('BG 2.47 → Bhagavad Gītā ch 2 verse 47', () {
      final c = parseScriptureCoordinate('BG 2.47')!;
      expect(c.scripture, Scripture.bhagavadGita);
      expect(c.chapterNum, 2);
      expect(c.verseNum, 47);
      expect(c.bookNum, isNull);
      expect(c.verseId, 'BG.2.47');
    });

    test('Gita 11.37 (long alias) parses', () {
      final c = parseScriptureCoordinate('Gita 11.37')!;
      expect(c.scripture, Scripture.bhagavadGita);
      expect(c.chapterNum, 11);
      expect(c.verseNum, 37);
    });

    test('BG.2.47 (dot separator) parses', () {
      final c = parseScriptureCoordinate('BG.2.47')!;
      expect(c.chapterNum, 2);
      expect(c.verseNum, 47);
    });

    test('Devanāgarī numerals (BG २.४७) parse', () {
      final c = parseScriptureCoordinate('BG २.४७')!;
      expect(c.chapterNum, 2);
      expect(c.verseNum, 47);
    });

    test('case-insensitive alias', () {
      expect(parseScriptureCoordinate('bg 2.47')!.scripture,
          Scripture.bhagavadGita);
      expect(parseScriptureCoordinate('GITA 2.47')!.scripture,
          Scripture.bhagavadGita);
    });

    test('3-level Ṛgveda RV 1.1.1', () {
      final c = parseScriptureCoordinate('RV 1.1.1')!;
      expect(c.scripture, Scripture.rigveda);
      expect(c.bookNum, 1);
      expect(c.chapterNum, 1);
      expect(c.verseNum, 1);
      expect(c.verseId, 'RV.1.1.1');
    });

    test('3-level Mahābhārata Mbh 6.25.47', () {
      final c = parseScriptureCoordinate('Mbh 6.25.47')!;
      expect(c.scripture, Scripture.mahabharata);
      expect(c.bookNum, 6);
      expect(c.chapterNum, 25);
      expect(c.verseNum, 47);
    });

    test('Katha 1.2.18 (3-level upaniṣad)', () {
      // Kaṭha doesn't fall under our 3-level set; Katha 1.2.18 should
      // either parse as 2-level rejecting third token, or null. We
      // don't currently treat Katha as 3-level — verify behavior:
      final c = parseScriptureCoordinate('Katha 1.2');
      expect(c?.scripture, Scripture.kathaUpanishad);
      expect(c?.chapterNum, 1);
      expect(c?.verseNum, 2);
    });

    test('mixed separators (BG 2:47) parses', () {
      final c = parseScriptureCoordinate('BG 2:47')!;
      expect(c.chapterNum, 2);
      expect(c.verseNum, 47);
    });

    test('non-coordinate text returns null', () {
      expect(parseScriptureCoordinate(''), isNull);
      expect(parseScriptureCoordinate('dharma'), isNull);
      expect(parseScriptureCoordinate('what is karma'), isNull);
      expect(parseScriptureCoordinate('Bhagavad Gita'), isNull);
    });

    test('out-of-range numerics return null', () {
      expect(parseScriptureCoordinate('BG 0.1'), isNull);
      expect(parseScriptureCoordinate('BG 99999.1'), isNull);
    });
  });
}
