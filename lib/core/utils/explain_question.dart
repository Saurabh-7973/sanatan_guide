import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';

/// Builds a *specific* one-line question to seed the "Explain this verse"
/// affordance — not a generic "Ask AI about this verse".
///
/// Templated for now (build #8): keyed off the verse's first word-meaning
/// when available, else off the scripture + coordinate. A curated per-verse
/// question bank is a later content task.
String explainQuestion(Verse verse) {
  final firstWord = verse.wordMeanings?.isNotEmpty == true
      ? verse.wordMeanings!.first
      : null;
  if (firstWord != null) {
    return 'What does "${firstWord.word}" mean here, and why does '
        '${verse.scripture.displayName} open this verse with it?';
  }
  return 'What is ${verse.scripture.displayName} '
      '${verse.chapterNum}.${verse.verseNum} really saying?';
}

/// 2–3 short follow-up prompts shown under a completed explanation; each
/// taps through into AI Chat with the verse anchored.
List<String> explainFollowups(Verse verse) {
  final words = verse.wordMeanings ?? const [];
  return [
    if (words.length > 1) 'What does "${words[1].word}" mean in this context?',
    'How does this verse connect to the rest of ${verse.scripture.displayName}?',
    'Who is speaking here, and to whom?',
  ].take(3).toList(growable: false);
}
