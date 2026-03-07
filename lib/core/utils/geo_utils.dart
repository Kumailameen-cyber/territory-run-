import 'dart:math';

/// Geospatial utilities — Haversine distance, grid snapping, bearing.
class GeoUtils {
  GeoUtils._();

  static const double _earthRadiusM = 6371000;

  /// Haversine distance between two lat/lng points in meters.
  static double distanceM(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusM * c;
  }

  /// Speed in km/h between two points given time delta in seconds.
  static double speedKmh(
    double lat1, double lng1,
    double lat2, double lng2,
    double timeDeltaSeconds,
  ) {
    if (timeDeltaSeconds <= 0) return double.infinity;
    final distM = distanceM(lat1, lng1, lat2, lng2);
    return (distM / 1000) / (timeDeltaSeconds / 3600);
  }

  /// Snap a lat/lng to the nearest district grid cell center.
  /// Grid cells are [gridSizeM] x [gridSizeM].
  static (double lat, double lng) snapToGrid(
    double lat, double lng,
    double gridSizeM,
  ) {
    // Approximate degrees per meter at this latitude.
    final degPerMeterLat = 1 / 111320.0;
    final degPerMeterLng = 1 / (111320.0 * cos(_toRadians(lat)));

    final gridLat = gridSizeM * degPerMeterLat;
    final gridLng = gridSizeM * degPerMeterLng;

    final snappedLat = (lat / gridLat).round() * gridLat;
    final snappedLng = (lng / gridLng).round() * gridLng;

    return (snappedLat, snappedLng);
  }

  /// Generate a district ID from lat/lng by snapping to grid.
  static String districtId(double lat, double lng, double gridSizeM) {
    final (sLat, sLng) = snapToGrid(lat, lng, gridSizeM);
    return '${sLat.toStringAsFixed(6)}_${sLng.toStringAsFixed(6)}';
  }

  /// Calculate bearing from point 1 to point 2 in degrees.
  static double bearing(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    final dLng = _toRadians(lng2 - lng1);
    final y = sin(dLng) * cos(_toRadians(lat2));
    final x = cos(_toRadians(lat1)) * sin(_toRadians(lat2)) -
        sin(_toRadians(lat1)) * cos(_toRadians(lat2)) * cos(dLng);
    return (_toDegrees(atan2(y, x)) + 360) % 360;
  }

  /// Total distance of a path of [lat, lng] points in meters.
  static double pathDistanceM(List<List<double>> points) {
    double total = 0;
    for (int i = 1; i < points.length; i++) {
      total += distanceM(
        points[i - 1][0], points[i - 1][1],
        points[i][0], points[i][1],
      );
    }
    return total;
  }

  static double _toRadians(double deg) => deg * pi / 180;
  static double _toDegrees(double rad) => rad * 180 / pi;
}
