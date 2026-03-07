import 'dart:math';

/// Google Encoded Polyline utilities + intersection detection.
class PolylineUtils {
  PolylineUtils._();

  /// Encode a list of [lat, lng] coordinates into a Google encoded polyline.
  static String encode(List<List<double>> points) {
    final buf = StringBuffer();
    int prevLat = 0;
    int prevLng = 0;

    for (final pt in points) {
      final lat = (pt[0] * 1e5).round();
      final lng = (pt[1] * 1e5).round();
      buf.write(_encodeValue(lat - prevLat));
      buf.write(_encodeValue(lng - prevLng));
      prevLat = lat;
      prevLng = lng;
    }
    return buf.toString();
  }

  /// Decode a Google encoded polyline into [lat, lng] pairs.
  static List<List<double>> decode(String encoded) {
    final points = <List<double>>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add([lat / 1e5, lng / 1e5]);
    }
    return points;
  }

  /// Check if two polylines intersect.
  ///
  /// Returns true if any segment of [pathA] crosses any segment of [pathB].
  static bool intersects(
    List<List<double>> pathA,
    List<List<double>> pathB,
  ) {
    for (int i = 0; i < pathA.length - 1; i++) {
      for (int j = 0; j < pathB.length - 1; j++) {
        if (_segmentsIntersect(
          pathA[i][0], pathA[i][1], pathA[i + 1][0], pathA[i + 1][1],
          pathB[j][0], pathB[j][1], pathB[j + 1][0], pathB[j + 1][1],
        )) {
          return true;
        }
      }
    }
    return false;
  }

  /// Calculate the overlap percentage of pathB that runs along pathA.
  /// Returns 0.0–1.0.
  static double overlapRatio(
    List<List<double>> pathA,
    List<List<double>> pathB, {
    double thresholdM = 15.0,
  }) {
    if (pathB.isEmpty) return 0;
    int overlapping = 0;
    for (final pt in pathB) {
      if (_isPointNearPath(pt, pathA, thresholdM)) {
        overlapping++;
      }
    }
    return overlapping / pathB.length;
  }

  // ── Private helpers ─────────────────────────────────────

  static String _encodeValue(int value) {
    int v = value < 0 ? ~(value << 1) : (value << 1);
    final buf = StringBuffer();
    while (v >= 0x20) {
      buf.writeCharCode((0x20 | (v & 0x1F)) + 63);
      v >>= 5;
    }
    buf.writeCharCode(v + 63);
    return buf.toString();
  }

  static bool _segmentsIntersect(
    double ax1, double ay1, double ax2, double ay2,
    double bx1, double by1, double bx2, double by2,
  ) {
    final d1 = _cross(bx1, by1, bx2, by2, ax1, ay1);
    final d2 = _cross(bx1, by1, bx2, by2, ax2, ay2);
    final d3 = _cross(ax1, ay1, ax2, ay2, bx1, by1);
    final d4 = _cross(ax1, ay1, ax2, ay2, bx2, by2);

    if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
        ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) {
      return true;
    }
    return false;
  }

  static double _cross(
    double ax, double ay, double bx, double by,
    double cx, double cy,
  ) {
    return (bx - ax) * (cy - ay) - (by - ay) * (cx - ax);
  }

  static bool _isPointNearPath(
    List<double> point,
    List<List<double>> path,
    double thresholdM,
  ) {
    for (int i = 0; i < path.length - 1; i++) {
      final dist = _pointToSegmentDistance(
        point[0], point[1],
        path[i][0], path[i][1],
        path[i + 1][0], path[i + 1][1],
      );
      if (dist <= thresholdM) return true;
    }
    return false;
  }

  /// Approximate point-to-segment distance in meters.
  static double _pointToSegmentDistance(
    double px, double py,
    double ax, double ay,
    double bx, double by,
  ) {
    final dx = bx - ax;
    final dy = by - ay;
    if (dx == 0 && dy == 0) {
      return _approxDistM(px, py, ax, ay);
    }
    var t = ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy);
    t = t.clamp(0.0, 1.0);
    return _approxDistM(px, py, ax + t * dx, ay + t * dy);
  }

  /// Fast approximate distance in meters (good for short distances).
  static double _approxDistM(double lat1, double lng1, double lat2, double lng2) {
    const metersPerDegLat = 111320.0;
    final metersPerDegLng = 111320.0 * cos(lat1 * pi / 180);
    final dLat = (lat2 - lat1) * metersPerDegLat;
    final dLng = (lng2 - lng1) * metersPerDegLng;
    return sqrt(dLat * dLat + dLng * dLng);
  }
}
