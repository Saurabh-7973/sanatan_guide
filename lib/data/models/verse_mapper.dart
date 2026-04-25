import 'dart:convert';

import 'package:sanatan_guide/data/datasources/local/app_database.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';

/// Maps between Drift-generated DB types and domain entities.
/// Called exclusively inside ScriptureRepository — never in UI.
abstract final class VerseMapper {
  /// Maps [VersesTableData] (from Drift) → domain [Verse].
  static Verse fromTableData(VersesTableData data) {
    return Verse(
      id: data.id,
      chapterNum: data.chapterNum,
      verseNum: data.verseNum,
      scripture: ScriptureX.fromCode(data.scripture),
      sanskrit: data.sanskrit,
      transliteration: data.transliteration,
      hindi: data.hindi,
      english: data.english,
      wordMeanings: _parseWordMeanings(data.wordMeaning),
      noteText: data.noteText,
      bookNum: data.bookNum,
      chapterLabel: data.chapterLabel,
      translation: data.translation,
      isBookmarked: data.isBookmarked,
      readCount: data.readCount,
      createdAt: data.createdAt,
    );
  }

  static List<WordMeaning>? _parseWordMeanings(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) {
        final map = e as Map<String, dynamic>;
        return WordMeaning(
          word: map['word'] as String,
          meaning: map['meaning'] as String,
          transliteration: map['transliteration'] as String?,
        );
      }).toList();
    } catch (_) {
      return null; // Malformed JSON — return null, not crash
    }
  }
}
