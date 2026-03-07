/// A single running session.
class RunModel {
  final String id;
  final String userId;
  final double distance; // meters
  final List<List<double>> pathCoordinates; // [[lat, lng], …]
  final DateTime startTime;
  final DateTime? endTime;
  final double averageSpeedKmh;
  final int stepCount;
  final String? encodedPolyline; // compressed for storage
  final bool synced; // whether uploaded to Firestore
  final int xpEarned;

  RunModel({
    required this.id,
    required this.userId,
    this.distance = 0,
    this.pathCoordinates = const [],
    required this.startTime,
    this.endTime,
    this.averageSpeedKmh = 0,
    this.stepCount = 0,
    this.encodedPolyline,
    this.synced = false,
    this.xpEarned = 0,
  });

  /// Duration of the run.
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Distance in kilometers.
  double get distanceKm => distance / 1000;

  /// Pace in min/km.
  double get paceMinPerKm {
    if (distanceKm <= 0) return 0;
    return duration.inSeconds / 60 / distanceKm;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  factory RunModel.fromJson(Map<String, dynamic> json) {
    return RunModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      pathCoordinates: (json['path_coordinates'] as List?)
              ?.map((e) => List<double>.from(e as List))
              .toList() ??
          [],
      startTime: _parseDate(json['start_time']),
      endTime: json['end_time'] != null
          ? _parseDate(json['end_time'])
          : null,
      averageSpeedKmh:
          (json['average_speed_kmh'] as num?)?.toDouble() ?? 0,
      stepCount: json['step_count'] as int? ?? 0,
      encodedPolyline: json['encoded_polyline'] as String?,
      synced: json['synced'] as bool? ?? true,
      xpEarned: json['xp_earned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'distance': distance,
      'path_coordinates': pathCoordinates,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'average_speed_kmh': averageSpeedKmh,
      'step_count': stepCount,
      'encoded_polyline': encodedPolyline,
      'synced': synced,
      'xp_earned': xpEarned,
    };
  }

  RunModel copyWith({
    double? distance,
    List<List<double>>? pathCoordinates,
    DateTime? endTime,
    double? averageSpeedKmh,
    int? stepCount,
    String? encodedPolyline,
    bool? synced,
    int? xpEarned,
  }) {
    return RunModel(
      id: id,
      userId: userId,
      distance: distance ?? this.distance,
      pathCoordinates: pathCoordinates ?? this.pathCoordinates,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      averageSpeedKmh: averageSpeedKmh ?? this.averageSpeedKmh,
      stepCount: stepCount ?? this.stepCount,
      encodedPolyline: encodedPolyline ?? this.encodedPolyline,
      synced: synced ?? this.synced,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }
}
