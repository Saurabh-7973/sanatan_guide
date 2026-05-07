import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-bookmark personal notes to SharedPreferences. Keyed by
/// `note_<verseId>`. v1 storage path until/if a Drift migration adds a
/// `note` column to the bookmarks table.
abstract final class BookmarkNotesService {
  static String _key(String verseId) => 'note_$verseId';

  static Future<String?> get(String verseId) async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key(verseId));
    if (v == null || v.trim().isEmpty) return null;
    return v;
  }

  static Future<void> set(String verseId, String? note) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = note?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await prefs.remove(_key(verseId));
    } else {
      await prefs.setString(_key(verseId), trimmed);
    }
  }
}
