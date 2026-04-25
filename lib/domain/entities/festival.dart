import 'package:flutter/foundation.dart';

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
