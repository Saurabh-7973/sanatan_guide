import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';

part 'verse.freezed.dart';

/// A single word's meaning from the word-by-word breakdown.
@freezed
sealed class WordMeaning with _$WordMeaning {
  const factory WordMeaning({
    required String word,
    required String meaning,
    String? transliteration,

    /// Optional grammar tag — case, number, gender, part of speech.
    /// Free-text, e.g. "noun · locative · neuter".
    String? grammar,
  }) = _WordMeaning;
}

@freezed
sealed class Verse with _$Verse {
  const factory Verse({
    /// Unique ID. Format: '{ScriptureCode}.{chapter}.{verse}' e.g. 'BG.1.1'
    required String id,
    required int chapterNum,
    required int verseNum,
    required Scripture scripture,

    /// Original Devanagari Sanskrit text. Never empty.
    required String sanskrit,

    /// IAST Roman transliteration. Null until loaded.
    String? transliteration,

    /// Hindi translation. Null if not yet populated.
    String? hindi,

    /// English translation. Null if not yet populated.
    String? english,

    /// Word-by-word meanings as a list. Null if not loaded.
    List<WordMeaning>? wordMeanings,

    /// User's personal note on this verse. Null if no note written.
    String? noteText,
    int? bookNum,
    String? chapterLabel,
    String? translation,
    @Default(false) bool isBookmarked,
    @Default(0) int readCount,
    required DateTime createdAt,
  }) = _Verse;

  /// Placeholder for skeleton / loading layouts.
  factory Verse.placeholder() => Verse(
        id: 'BG.2.47',
        sanskrit: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन',
        english: 'You have a right to perform your prescribed duties',
        chapterNum: 2,
        verseNum: 47,
        scripture: Scripture.bhagavadGita,
        isBookmarked: false,
        readCount: 0,
        createdAt: DateTime(2024),
      );
}
