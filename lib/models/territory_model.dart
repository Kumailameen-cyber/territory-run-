/// A territory claimed by running.
class TerritoryModel {
  final String id;
  final String ownerId;
  final String ownerUsername;
  final List<List<double>> polylinePath; // [[lat, lng], …]
  final double strength;
  final DateTime createdAt;
  final String districtId;
  final String? encodedPolyline;
  final double lengthM; // total path length in meters
  final int captureCount; // times this territory changed hands
  final DateTime lastDecayAt;
  final int colorIndex; // for consistent trail color

  TerritoryModel({
    required this.id,
    required this.ownerId,
    this.ownerUsername = 'Unknown',
    required this.polylinePath,
    required this.strength,
    required this.createdAt,
    required this.districtId,
    this.encodedPolyline,
    this.lengthM = 0,
    this.captureCount = 0,
    DateTime? lastDecayAt,
    this.colorIndex = 0,
  }) : lastDecayAt = lastDecayAt ?? createdAt;

  /// Whether this territory is neutral (zero strength).
  bool get isNeutral => strength <= 0;

  /// Strength as a percentage (0–100) for display.
  double get strengthPercent => (strength * 100).clamp(0, 100);

  static DateTime _parseDate(dynamic value) {
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  factory TerritoryModel.fromJson(Map<String, dynamic> json) {
    return TerritoryModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      ownerUsername: json['owner_username'] as String? ?? 'Unknown',
      polylinePath: (json['polyline_path'] as List?)
              ?.map((e) => List<double>.from(e as List))
              .toList() ??
          [],
      strength: (json['strength'] as num?)?.toDouble() ?? 0,
      createdAt: _parseDate(json['created_at']),
      districtId: json['district_id'] as String,
      encodedPolyline: json['encoded_polyline'] as String?,
      lengthM: (json['length_m'] as num?)?.toDouble() ?? 0,
      captureCount: json['capture_count'] as int? ?? 0,
      lastDecayAt: json['last_decay_at'] != null
          ? _parseDate(json['last_decay_at'])
          : null,
      colorIndex: json['color_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'owner_username': ownerUsername,
      'polyline_path': polylinePath,
      'strength': strength,
      'created_at': createdAt.toIso8601String(),
      'district_id': districtId,
      'encoded_polyline': encodedPolyline,
      'length_m': lengthM,
      'capture_count': captureCount,
      'last_decay_at': lastDecayAt.toIso8601String(),
      'color_index': colorIndex,
    };
  }

  TerritoryModel copyWith({
    String? ownerId,
    String? ownerUsername,
    double? strength,
    int? captureCount,
    DateTime? lastDecayAt,
  }) {
    return TerritoryModel(
      id: id,
      ownerId: ownerId ?? this.ownerId,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      polylinePath: polylinePath,
      strength: strength ?? this.strength,
      createdAt: createdAt,
      districtId: districtId,
      encodedPolyline: encodedPolyline,
      lengthM: lengthM,
      captureCount: captureCount ?? this.captureCount,
      lastDecayAt: lastDecayAt ?? this.lastDecayAt,
      colorIndex: colorIndex,
    );
  }
}
