import 'package:uuid/uuid.dart';
import '../core/constants/game_constants.dart';
import '../core/utils/geo_utils.dart';
import '../core/utils/polyline_utils.dart';
import '../models/territory_model.dart';
import '../models/battle_model.dart';
import '../models/run_model.dart';

/// Core gameplay engine — territory creation, capture, and decay.
class TerritoryEngine {
  TerritoryEngine();

  static const _uuid = Uuid();

  /// Create a territory from a completed run.
  ///
  /// Returns null if the run is too short.
  TerritoryModel? createTerritory({
    required RunModel run,
    required String districtId,
    required bool isExplorationZone,
  }) {
    if (run.distance < GameConstants.minTerritoryDistanceM) {
      return null;
    }

    // Base strength = distance in km.
    double strength = run.distanceKm;

    // Exploration bonus.
    if (isExplorationZone) {
      strength *= GameConstants.explorationBonus;
    }

    return TerritoryModel(
      id: _uuid.v4(),
      ownerId: run.userId,
      polylinePath: run.pathCoordinates,
      strength: strength,
      createdAt: DateTime.now(),
      districtId: districtId,
      encodedPolyline: PolylineUtils.encode(run.pathCoordinates),
      lengthM: run.distance,
    );
  }

  /// Attempt to capture an existing territory.
  ///
  /// Rules:
  /// - If owner is offline → instant capture.
  /// - If owner is online → challenger must run more than territory strength.
  CaptureResult attemptCapture({
    required TerritoryModel territory,
    required RunModel challengerRun,
    required bool ownerOnline,
  }) {
    // Check intersection — challenger's path must overlap the territory.
    final overlapRatio = PolylineUtils.overlapRatio(
      territory.polylinePath,
      challengerRun.pathCoordinates,
    );

    if (overlapRatio < 0.1) {
      return CaptureResult(
        success: false,
        battle: null,
        reason: 'Insufficient path overlap (${(overlapRatio * 100).toStringAsFixed(0)}%)',
      );
    }

    // Owner offline → instant capture.
    if (!ownerOnline) {
      final battle = BattleModel(
        id: _uuid.v4(),
        attackerId: challengerRun.userId,
        defenderId: territory.ownerId,
        territoryId: territory.id,
        result: BattleResult.abandoned,
        timestamp: DateTime.now(),
        attackerDistance: challengerRun.distance,
        territoryStrength: territory.strength,
      );

      return CaptureResult(
        success: true,
        battle: battle,
        updatedTerritory: territory.copyWith(
          ownerId: challengerRun.userId,
          strength: challengerRun.distanceKm,
          captureCount: territory.captureCount + 1,
        ),
      );
    }

    // Owner online → must exceed territory strength.
    final challengerStrength = challengerRun.distanceKm;
    final captured = challengerStrength > territory.strength;

    final battle = BattleModel(
      id: _uuid.v4(),
      attackerId: challengerRun.userId,
      defenderId: territory.ownerId,
      territoryId: territory.id,
      result: captured ? BattleResult.captured : BattleResult.defended,
      timestamp: DateTime.now(),
      attackerDistance: challengerRun.distance,
      territoryStrength: territory.strength,
    );

    return CaptureResult(
      success: captured,
      battle: battle,
      updatedTerritory: captured
          ? territory.copyWith(
              ownerId: challengerRun.userId,
              strength: challengerStrength,
              captureCount: territory.captureCount + 1,
            )
          : null,
      reason: captured ? null : 'Territory strength (${territory.strength.toStringAsFixed(1)}) exceeds your run (${challengerStrength.toStringAsFixed(1)} km)',
    );
  }

  /// Apply daily decay to a territory.
  ///
  /// Returns null if territory should be removed (strength ≤ 0).
  TerritoryModel? applyDecay(TerritoryModel territory) {
    final daysSinceDecay =
        DateTime.now().difference(territory.lastDecayAt).inDays;
    if (daysSinceDecay < 1) return territory;

    final newStrength = territory.strength *
        (1 - GameConstants.decayPercentPerDay) * daysSinceDecay;

    if (newStrength <= 0) return null;

    return territory.copyWith(
      strength: newStrength,
      lastDecayAt: DateTime.now(),
    );
  }

  /// Find territories that intersect with a given path.
  List<TerritoryModel> findIntersecting(
    List<List<double>> path,
    List<TerritoryModel> territories,
  ) {
    return territories.where((t) {
      return PolylineUtils.intersects(path, t.polylinePath);
    }).toList();
  }

  /// Check if a location is in an exploration zone (no existing territories nearby).
  bool isExplorationZone(
    double lat, double lng,
    List<TerritoryModel> nearbyTerritories, {
    double radiusM = 200,
  }) {
    for (final t in nearbyTerritories) {
      for (final pt in t.polylinePath) {
        if (GeoUtils.distanceM(lat, lng, pt[0], pt[1]) < radiusM) {
          return false;
        }
      }
    }
    return true;
  }
}

/// Result of a capture attempt.
class CaptureResult {
  final bool success;
  final BattleModel? battle;
  final TerritoryModel? updatedTerritory;
  final String? reason;

  const CaptureResult({
    required this.success,
    this.battle,
    this.updatedTerritory,
    this.reason,
  });
}
