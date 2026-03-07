import '../constants/game_constants.dart';

/// Leaderboard scoring calculations.
class ScoreUtils {
  ScoreUtils._();

  /// Calculate total leaderboard score.
  ///
  /// Formula: (distance × 0.5) + (territory × 1.2) + (districts × 10) + (streak × 2)
  static double calculateScore({
    required double totalDistanceKm,
    required double totalTerritoryStrength,
    required int districtsControlled,
    required int streakDays,
  }) {
    return (totalDistanceKm * GameConstants.scoreDistanceWeight) +
        (totalTerritoryStrength * GameConstants.scoreTerritoryWeight) +
        (districtsControlled * GameConstants.scoreDistrictWeight) +
        (streakDays * GameConstants.scoreStreakWeight);
  }

  /// Calculate XP earned from a run.
  static int xpFromRun({
    required double distanceKm,
    required bool isExploration,
    required int currentStreak,
  }) {
    int baseXp = (distanceKm * GameConstants.xpPerKm).round();

    // Exploration bonus.
    if (isExploration) {
      baseXp = (baseXp * GameConstants.explorationBonus).round();
    }

    // Streak bonus: +10% per streak day, capped at +100%.
    final streakMultiplier = 1.0 + (currentStreak * 0.1).clamp(0.0, 1.0);
    baseXp = (baseXp * streakMultiplier).round();

    return baseXp;
  }

  /// Calculate player level from total XP.
  static int levelFromXp(int totalXp) {
    int level = 1;
    int xpNeeded = GameConstants.xpPerLevel;
    int accumulated = 0;
    while (accumulated + xpNeeded <= totalXp) {
      accumulated += xpNeeded;
      level++;
      xpNeeded = GameConstants.xpPerLevel * level;
    }
    return level;
  }

  /// XP progress toward next level (0.0 – 1.0).
  static double xpProgress(int totalXp) {
    int level = 1;
    int accumulated = 0;
    int xpNeeded = GameConstants.xpPerLevel;
    while (accumulated + xpNeeded <= totalXp) {
      accumulated += xpNeeded;
      level++;
      xpNeeded = GameConstants.xpPerLevel * level;
    }
    final remaining = totalXp - accumulated;
    return remaining / xpNeeded;
  }

  /// Territory strength after decay over [days].
  static double strengthAfterDecay(double strength, int days) {
    return strength * 
        (1 - GameConstants.decayPercentPerDay) * days;
  }

  /// Format a score for display (e.g., "14,280").
  static String formatScore(double score) {
    final rounded = score.round();
    return rounded.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
