// lib/core/utils/daily_reading_suggestion_resolver.dart
//
// Panchang-aware "what to read today" (CURRENT_SPRINT task 52).

import 'package:flutter/foundation.dart';
import 'package:sanatan_guide/core/utils/panchang_utils.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';

/// One concrete verse to surface from the weekday / vara theme.
@immutable
final class DailyReadingSuggestion {
  const DailyReadingSuggestion({
    required this.scripture,
    required this.verseId,
    required this.title,
    required this.subtitle,
  });

  final Scripture scripture;
  final String verseId;
  final String title;
  final String subtitle;

  String get scriptureCode => scripture.code;
}

/// Maps [date]'s civil weekday to a themed reading (verse ids match seeded DB).
DailyReadingSuggestion dailyReadingSuggestionFor(DateTime date) {
  final vara = PanchangUtils.getVaraForDate(date);
  final dayTag = '${vara.emoji} ${vara.varaName}';

  switch (date.weekday) {
    case DateTime.monday:
      return DailyReadingSuggestion(
        scripture: Scripture.shvetashvataraUpanishad,
        verseId: 'SU.1.1',
        title: 'Shvetashvatara Upanishad',
        subtitle: '$dayTag · ${vara.deity} — auspicious for Shiva-oriented study',
      );
    case DateTime.tuesday:
      return DailyReadingSuggestion(
        scripture: Scripture.ramayana,
        verseId: 'RAM.1.1.1',
        title: 'Ramayana',
        subtitle: '$dayTag · ${vara.deity} — strength and devotion',
      );
    case DateTime.wednesday:
      return DailyReadingSuggestion(
        scripture: Scripture.vishnuSahasranama,
        verseId: 'VS.1.1',
        title: 'Vishnu Sahasranama',
        subtitle: '$dayTag · ${vara.deity} — names of the all-pervading Lord',
      );
    case DateTime.thursday:
      return DailyReadingSuggestion(
        scripture: Scripture.yogaSutras,
        verseId: 'YS.1.1',
        title: 'Yoga Sutras',
        subtitle: '$dayTag · ${vara.deity} — classical darshana of the mind',
      );
    case DateTime.friday:
      return DailyReadingSuggestion(
        scripture: Scripture.deviBhagavataPurana,
        verseId: 'DB.1.1',
        title: 'Devi Bhagavata Purana',
        subtitle: '$dayTag · ${vara.deity} — abundance and sacred feminine',
      );
    case DateTime.saturday:
      return DailyReadingSuggestion(
        scripture: Scripture.bhagavadGita,
        verseId: 'BG.2.1',
        title: 'Bhagavad Gita · Sankhya Yoga',
        subtitle: '$dayTag · ${vara.deity} — dharma and steady resolve',
      );
    case DateTime.sunday:
      return DailyReadingSuggestion(
        scripture: Scripture.rigveda,
        verseId: 'RV.3.62',
        title: 'Rigveda · Gayatri',
        subtitle: '$dayTag · illumination and Surya tradition',
      );
    default:
      return DailyReadingSuggestion(
        scripture: Scripture.bhagavadGita,
        verseId: 'BG.1.1',
        title: 'Bhagavad Gita',
        subtitle: dayTag,
      );
  }
}
