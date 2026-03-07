/// A 500m × 500m grid cell on the map.
class DistrictModel {
  final String id;
  final double centerLat;
  final double centerLng;
  final String? ownerTeam;
  final int territoryCount;
  final double heatmapValue; // 0.0 – 1.0
  final Map<String, double> teamStrengths; // teamId → total strength

  DistrictModel({
    required this.id,
    required this.centerLat,
    required this.centerLng,
    this.ownerTeam,
    this.territoryCount = 0,
    this.heatmapValue = 0,
    this.teamStrengths = const {},
  });

  /// The dominant team (highest total strength).
  String? get dominantTeam {
    if (teamStrengths.isEmpty) return null;
    return teamStrengths.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] as String,
      centerLat: (json['center_lat'] as num).toDouble(),
      centerLng: (json['center_lng'] as num).toDouble(),
      ownerTeam: json['owner_team'] as String?,
      territoryCount: json['territory_count'] as int? ?? 0,
      heatmapValue: (json['heatmap_value'] as num?)?.toDouble() ?? 0,
      teamStrengths: Map<String, double>.from(
        (json['team_strengths'] as Map?)?.map(
              (k, v) => MapEntry(k as String, (v as num).toDouble()),
            ) ??
            {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center_lat': centerLat,
      'center_lng': centerLng,
      'owner_team': ownerTeam,
      'territory_count': territoryCount,
      'heatmap_value': heatmapValue,
      'team_strengths': teamStrengths,
    };
  }
}
