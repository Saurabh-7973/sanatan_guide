import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanatan_guide/core/services/bookmark_notes_service.dart';

part 'bookmark_notes_provider.g.dart';

/// The user's personal note for a single bookmarked verse, or null when
/// no note is set. Backed by [BookmarkNotesService] (SharedPreferences).
@riverpod
Future<String?> bookmarkNote(Ref ref, String verseId) async {
  return BookmarkNotesService.get(verseId);
}
