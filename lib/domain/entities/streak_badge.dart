// lib/domain/entities/streak_badge.dart

/// Represents an earned streak badge shown on the Home screen.
enum StreakBadge {
  firstFlame(minStreak: 1, emoji: '🕯️', label: 'First Flame'),
  steadySeeker(minStreak: 3, emoji: '🔥', label: 'Steady Seeker'),
  devotedReader(minStreak: 7, emoji: '⚡', label: 'Devoted Reader'),
  sadhaka(minStreak: 30, emoji: '🌟', label: 'Sadhaka'),
  tapasvi(minStreak: 100, emoji: '💎', label: 'Tapasvi');

  const StreakBadge({
    required this.minStreak,
    required this.emoji,
    required this.label,
  });

  final int minStreak;
  final String emoji;
  final String label;

  /// Returns the highest badge earned for [streak], or null if streak == 0.
  static StreakBadge? forStreak(int streak) {
    if (streak <= 0) return null;
    StreakBadge? best;
    for (final badge in StreakBadge.values) {
      if (streak >= badge.minStreak) best = badge;
    }
    return best;
  }
}
