import 'package:flutter/foundation.dart';

/// Tradition-awareness grouping for the Festivals almanac filter strip.
///
/// A festival is filed by its *defining* observance: a celebratory parva, a
/// fasting vrat, or a tradition-specific regional day.
enum FestivalCategory {
  majorParva('Major parva', 'Major parvas'),
  vrat('Vrat', 'Vrats'),
  regional('Regional', 'Regional');

  const FestivalCategory(this.label, this.pluralLabel);

  /// Singular label for the per-festival almanac meta line.
  final String label;

  /// Plural label for the filter-strip pill.
  final String pluralLabel;
}

@immutable
class Festival {
  const Festival({
    required this.id,
    required this.name,
    required this.sanskritName,
    required this.date,
    required this.shortDesc,
    required this.explainer,
    required this.deity,
    required this.emoji,
    required this.category,
    required this.howToObserve,
  });

  final String id;
  final String name;
  final String sanskritName;
  final DateTime date;
  final String shortDesc;
  final String explainer;
  final String deity;
  final String emoji;
  final FestivalCategory category;

  /// Ordered list of practical observance steps shown on the detail page.
  final List<String> howToObserve;

  bool get isPast => date.isBefore(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      );

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
