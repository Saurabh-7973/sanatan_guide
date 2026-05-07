import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's recent search queries to SharedPreferences.
/// Capped at 20 entries; most-recent-first ordering preserved on add.
abstract final class RecentSearchesService {
  static const _kKey = 'recent_searches_v1';
  static const _maxEntries = 20;

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.whereType<String>().toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  /// Pushes [query] to the front of the list (deduplicated, case-insensitive
  /// match against existing entries). Trims trailing entries to [_maxEntries].
  static Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = await load();
    final lc = trimmed.toLowerCase();
    final filtered = existing
        .where((e) => e.toLowerCase() != lc)
        .toList(growable: true);
    filtered.insert(0, trimmed);
    if (filtered.length > _maxEntries) {
      filtered.removeRange(_maxEntries, filtered.length);
    }
    await prefs.setString(_kKey, jsonEncode(filtered));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}
