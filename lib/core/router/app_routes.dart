abstract final class AppRoutes {
  // Root
  static const String splash = '/';
  static const String home = '/home';

  // Browse (Bhagavad Gita chapters + verse list)
  // Verse detail is outside the shell — no NavBar during reading
  static const String browse = '/browse';
  static const String browseScripture = '/browse/:scriptureId';
  static const String browseChapter =
      '/browse/:scriptureId/chapter/:chapterNum';
  static const String verseDetail = '/browse/:scriptureId/verse/:verseId';

  /// Saved bookmarks (shell route — same tab stack as Browse).
  static const String bookmarks = '/bookmarks';

  // Learning
  static const String learningPath = '/learn';
  static const String moduleReader = '/learn/:moduleId'; // outside shell

  // Festivals (shell tab)
  static const String festivals = '/festivals';

  // Search
  static const String search = '/search';

  // Settings (future)
  static const String settings = '/settings';

  // Feedback (real screen lands in S3)
  static const String feedback = '/feedback';

  // General AI chat — no verse anchor (real screen lands in S6)
  static const String chatGeneral = '/chat';
}
