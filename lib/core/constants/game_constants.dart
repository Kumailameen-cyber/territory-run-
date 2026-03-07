/// All game tuning constants in one place.
///
/// Adjust these to balance gameplay without touching service logic.
class GameConstants {
  GameConstants._();

  // ── GPS ──────────────────────────────────────────────────
  /// Default GPS update interval (milliseconds).
  static const int gpsIntervalMs = 3000;

  /// Reduced interval when movement is stable.
  static const int gpsStableIntervalMs = 5000;

  /// Maximum speed in km/h before a point is flagged as cheating.
  static const double maxSpeedKmh = 20.0;

  /// Teleport threshold — discard GPS jumps > this many meters in < 2 seconds.
  static const double teleportThresholdM = 100.0;

  /// Minimum distance between recorded points (meters) to avoid clustering.
  static const double minPointDistanceM = 5.0;

  // ── Territory ───────────────────────────────────────────
  /// Daily decay percentage for territory strength.
  static const double decayPercentPerDay = 0.10;

  /// Bonus multiplier for first runner in a new area.
  static const double explorationBonus = 1.5;

  /// Minimum run distance (meters) to create a territory.
  static const double minTerritoryDistanceM = 100.0;

  /// Territory load radius from player position (meters).
  static const double territoryLoadRadiusM = 1000.0;

  // ── Districts ───────────────────────────────────────────
  /// District grid cell size in meters.
  static const double districtSizeM = 500.0;

  // ── Privacy ─────────────────────────────────────────────
  /// Radius to blur at start/end of runs (meters).
  static const double privacyBlurRadiusM = 100.0;

  // ── Scoring ─────────────────────────────────────────────
  static const double scoreDistanceWeight = 0.5;
  static const double scoreTerritoryWeight = 1.2;
  static const double scoreDistrictWeight = 10.0;
  static const double scoreStreakWeight = 2.0;

  // ── Streaks ─────────────────────────────────────────────
  /// Minimum run distance to count toward a streak (meters).
  static const double streakMinDistanceM = 500.0;

  // ── Anti-Cheat ──────────────────────────────────────────
  /// Maximum time gap for teleport detection (seconds).
  static const double teleportTimeThresholdS = 2.0;

  /// Step count tolerance (ratio) when validating GPS vs pedometer.
  static const double stepCountTolerance = 0.5;

  // ── Sync ────────────────────────────────────────────────
  /// Background sync interval (minutes).
  static const int backgroundSyncIntervalMin = 15;

  /// Maximum queued operations before forcing a sync attempt.
  static const int maxQueueBeforeForceSync = 50;

  // ── Map Caching ─────────────────────────────────────────
  /// Radius for pre-caching map tiles around home (meters).
  static const double tileCacheRadiusM = 1000.0;

  // ── XP ──────────────────────────────────────────────────
  /// Base XP per kilometer run.
  static const int xpPerKm = 100;

  /// XP required per level (multiplied by level number).
  static const int xpPerLevel = 500;
}
