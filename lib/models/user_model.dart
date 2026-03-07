/// Player profile model.
class UserModel {
  final String id;
  final String username;
  final int level;
  final double totalDistance;
  final String? teamId;
  final int xp;
  final int streakCount;
  final DateTime createdAt;
  final String? avatarUrl;
  final String? email;
  final List<String> achievements;
  final double longestRunKm;
  final int territoriesOwned;
  final double? lastLat;
  final double? lastLng;
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    this.level = 1,
    this.totalDistance = 0,
    this.teamId,
    this.xp = 0,
    this.streakCount = 0,
    required this.createdAt,
    this.avatarUrl,
    this.email,
    this.achievements = const [],
    this.longestRunKm = 0,
    this.territoriesOwned = 0,
    this.lastLat,
    this.lastLng,
    this.isActive = false,
  });

  static DateTime _parseDate(dynamic value) {
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    // Handle Firestore Timestamp
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Create from Firestore document.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      level: json['level'] as int? ?? 1,
      totalDistance: (json['total_distance'] as num?)?.toDouble() ?? 0,
      teamId: json['team_id'] as String?,
      xp: json['xp'] as int? ?? 0,
      streakCount: json['streak_count'] as int? ?? 0,
      createdAt: _parseDate(json['created_at']),
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String?,
      achievements: List<String>.from(json['achievements'] ?? []),
      longestRunKm: (json['longest_run_km'] as num?)?.toDouble() ?? 0,
      territoriesOwned: json['territories_owned'] as int? ?? 0,
      lastLat: (json['last_lat'] as num?)?.toDouble(),
      lastLng: (json['last_lng'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'level': level,
      'total_distance': totalDistance,
      'team_id': teamId,
      'xp': xp,
      'streak_count': streakCount,
      'created_at': createdAt.toIso8601String(),
      'avatar_url': avatarUrl,
      'email': email,
      'achievements': achievements,
      'longest_run_km': longestRunKm,
      'territories_owned': territoriesOwned,
      'last_lat': lastLat,
      'last_lng': lastLng,
      'is_active': isActive,
    };
  }

  UserModel copyWith({
    String? username,
    int? level,
    double? totalDistance,
    String? teamId,
    int? xp,
    int? streakCount,
    String? avatarUrl,
    List<String>? achievements,
    double? longestRunKm,
    int? territoriesOwned,
    double? lastLat,
    double? lastLng,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      level: level ?? this.level,
      totalDistance: totalDistance ?? this.totalDistance,
      teamId: teamId ?? this.teamId,
      xp: xp ?? this.xp,
      streakCount: streakCount ?? this.streakCount,
      createdAt: createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email,
      achievements: achievements ?? this.achievements,
      longestRunKm: longestRunKm ?? this.longestRunKm,
      territoriesOwned: territoriesOwned ?? this.territoriesOwned,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
      isActive: isActive ?? this.isActive,
    );
  }
}
