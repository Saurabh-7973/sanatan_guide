import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/core/utils/coordinate_parser.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/presentation/shared/widgets/ai_rich_prose.dart';

/// Walks an AI-prose paragraph the same way [AiRichProse] does — regex
/// candidates, then [parseScriptureCoordinate] as the final arbiter, plus
/// the production "earlier-wins" overlap dedup so a parenthesised citation
/// and the bare one inside it don't both create chips.
class _Hit {
  _Hit(this.start, this.end, this.coord);
  final int start;
  final int end;
  final ScriptureCoordinate coord;
}

List<ScriptureCoordinate> _extractCitations(String paragraph) {
  final hits = <_Hit>[];
  for (final m in citationRe.allMatches(paragraph)) {
    final c = parseScriptureCoordinate(m.group(1)!.trim());
    if (c != null) hits.add(_Hit(m.start, m.end, c));
  }
  for (final m in bareCitationRe.allMatches(paragraph)) {
    final inner = m.group(1)!.trim();
    var c = parseScriptureCoordinate(inner);
    if (c == null) {
      final parts = inner.split(RegExp(r'\s+'));
      for (var i = 1; i < parts.length && c == null; i++) {
        c = parseScriptureCoordinate(parts.sublist(i).join(' '));
      }
    }
    if (c != null) hits.add(_Hit(m.start, m.end, c));
  }
  hits.sort((a, b) => a.start.compareTo(b.start));
  final dropped = <bool>[for (final _ in hits) false];
  for (var i = 0; i < hits.length; i++) {
    if (dropped[i]) continue;
    for (var j = i + 1; j < hits.length; j++) {
      if (hits[j].start < hits[i].end) dropped[j] = true;
    }
  }
  return [
    for (var i = 0; i < hits.length; i++)
      if (!dropped[i]) hits[i].coord
  ];
}

void main() {
  group('parenthesised citations', () {
    test('"(Bhagavad Gītā 2.47)" → BG 2.47', () {
      final coords = _extractCitations('See (Bhagavad Gītā 2.47) for context.');
      expect(coords, hasLength(1));
      expect(coords.first.scripture, Scripture.bhagavadGita);
      expect(coords.first.chapterNum, 2);
      expect(coords.first.verseNum, 47);
    });

    test('"(BG 11.37)" parses', () {
      final coords = _extractCitations('Reference (BG 11.37) here.');
      expect(coords.first.verseId, 'BG.11.37');
    });

    test('"(RV 1.1.1)" 3-level parses', () {
      final coords = _extractCitations('Opening (RV 1.1.1) of the Veda.');
      expect(coords.first.scripture, Scripture.rigveda);
      expect(coords.first.bookNum, 1);
    });

    test('rejects footnote-style "(1)"', () {
      expect(_extractCitations('See footnote (1) below.'), isEmpty);
    });

    test('rejects "(year 2024)"', () {
      expect(_extractCitations('Published (year 2024) recently.'), isEmpty);
    });
  });

  group('bare in-prose citations', () {
    test('bare "BG 2.47" at sentence start', () {
      final coords = _extractCitations('BG 2.47 is the famous verse.');
      expect(coords.first.verseId, 'BG.2.47');
    });

    test('bare "Bhagavad Gita 11.37" (multi-word alias)', () {
      final coords = _extractCitations('Bhagavad Gita 11.37 is famous.');
      expect(coords.first.verseId, 'BG.11.37');
    });

    test('bare "RV 1.1.1" — 3-level scripture parses', () {
      final coords = _extractCitations('See RV 1.1.1 nearby.');
      expect(coords.first.scripture, Scripture.rigveda);
    });

    test('preceding non-alias prose is stripped — "Per BG 2.47"', () {
      // Regex captures "Per BG 2.47" greedily; parser rejects "Per"-prefix,
      // production retries with shorter prefixes and lands on BG 2.47.
      final coords = _extractCitations('Per BG 2.47 the path.');
      expect(coords.first.verseId, 'BG.2.47');
    });

    test('"Krishna says 2.47" stays plain prose', () {
      expect(_extractCitations('Krishna says 2.47 something.'), isEmpty);
    });

    test('two bare BG citations side by side', () {
      final coords = _extractCitations('See BG 2.47 then BG 11.37 next.');
      expect(coords.length, greaterThanOrEqualTo(2));
      expect(coords[0].verseId, 'BG.2.47');
      expect(coords[1].verseId, 'BG.11.37');
    });

    test('Devanāgarī numerals work inside parens "(BG २.४७)"', () {
      final coords = _extractCitations('Quote (BG २.४७) here.');
      expect(coords.first.chapterNum, 2);
      expect(coords.first.verseNum, 47);
    });

    test('bare "BG २.४७" parses (Devanāgarī numerals)', () {
      // Regression — alias char-class used to swallow U+0966-U+096F, leaving
      // nothing for the numeric clause to match. Split-range fix in
      // ai_rich_prose.dart bareCitationRe.
      final coords = _extractCitations('BG २.४७ here.');
      expect(coords.first.chapterNum, 2);
      expect(coords.first.verseNum, 47);
    });
  });
}
