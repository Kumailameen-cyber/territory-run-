import '../core/constants/game_constants.dart';
import '../core/utils/geo_utils.dart';

/// Privacy service — protects user home location and run endpoints.
class PrivacyService {
  PrivacyService();

  /// User-defined private zones (lat, lng, radius in meters).
  final List<PrivateZone> _privateZones = [];

  /// Add a private zone (e.g., home, workplace).
  void addPrivateZone(double lat, double lng, {double radiusM = 200}) {
    _privateZones.add(PrivateZone(
      latitude: lat,
      longitude: lng,
      radiusM: radiusM,
    ));
  }

  void removePrivateZone(int index) {
    if (index < _privateZones.length) {
      _privateZones.removeAt(index);
    }
  }

  List<PrivateZone> get privateZones => List.unmodifiable(_privateZones);

  /// Strip the first and last [privacyBlurRadiusM] from a run path
  /// before publishing to the server.
  List<List<double>> blurRunEndpoints(List<List<double>> path) {
    if (path.length < 3) return [];

    final blurDistance = GameConstants.privacyBlurRadiusM;
    final blurred = <List<double>>[];

    // Find the first point beyond the blur radius from start.
    double accDist = 0;
    int startIdx = 0;
    for (int i = 1; i < path.length; i++) {
      accDist += GeoUtils.distanceM(
        path[i - 1][0], path[i - 1][1],
        path[i][0], path[i][1],
      );
      if (accDist >= blurDistance) {
        startIdx = i;
        break;
      }
    }

    // Find the last point beyond the blur radius from end.
    accDist = 0;
    int endIdx = path.length - 1;
    for (int i = path.length - 2; i >= 0; i--) {
      accDist += GeoUtils.distanceM(
        path[i][0], path[i][1],
        path[i + 1][0], path[i + 1][1],
      );
      if (accDist >= blurDistance) {
        endIdx = i;
        break;
      }
    }

    if (startIdx >= endIdx) return [];

    for (int i = startIdx; i <= endIdx; i++) {
      blurred.add(path[i]);
    }

    return blurred;
  }

  /// Check if a point is within any private zone.
  bool isInPrivateZone(double lat, double lng) {
    for (final zone in _privateZones) {
      final dist = GeoUtils.distanceM(lat, lng, zone.latitude, zone.longitude);
      if (dist <= zone.radiusM) return true;
    }
    return false;
  }

  /// Remove points from a path that fall within private zones.
  List<List<double>> filterPrivateZones(List<List<double>> path) {
    return path.where((pt) => !isInPrivateZone(pt[0], pt[1])).toList();
  }
}

/// A user-defined private zone.
class PrivateZone {
  final double latitude;
  final double longitude;
  final double radiusM;

  const PrivateZone({
    required this.latitude,
    required this.longitude,
    this.radiusM = 200,
  });
}
