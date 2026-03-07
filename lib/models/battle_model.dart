/// Capture / battle event between players.
class BattleModel {
  final String id;
  final String attackerId;
  final String attackerUsername;
  final String defenderId;
  final String defenderUsername;
  final String territoryId;
  final BattleResult result;
  final DateTime timestamp;
  final double attackerDistance; // meters run by attacker
  final double territoryStrength; // strength at time of battle

  BattleModel({
    required this.id,
    required this.attackerId,
    this.attackerUsername = 'Unknown',
    required this.defenderId,
    this.defenderUsername = 'Unknown',
    required this.territoryId,
    required this.result,
    required this.timestamp,
    this.attackerDistance = 0,
    this.territoryStrength = 0,
  });

  static DateTime _parseDate(dynamic value) {
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  factory BattleModel.fromJson(Map<String, dynamic> json) {
    return BattleModel(
      id: json['id'] as String,
      attackerId: json['attacker_id'] as String,
      attackerUsername: json['attacker_username'] as String? ?? 'Unknown',
      defenderId: json['defender_id'] as String,
      defenderUsername: json['defender_username'] as String? ?? 'Unknown',
      territoryId: json['territory_id'] as String,
      result: BattleResult.values.firstWhere(
        (e) => e.name == json['result'],
        orElse: () => BattleResult.captured,
      ),
      timestamp: _parseDate(json['timestamp']),
      attackerDistance:
          (json['attacker_distance'] as num?)?.toDouble() ?? 0,
      territoryStrength:
          (json['territory_strength'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attacker_id': attackerId,
      'attacker_username': attackerUsername,
      'defender_id': defenderId,
      'defender_username': defenderUsername,
      'territory_id': territoryId,
      'result': result.name,
      'timestamp': timestamp.toIso8601String(),
      'attacker_distance': attackerDistance,
      'territory_strength': territoryStrength,
    };
  }
}

enum BattleResult {
  captured,
  defended,
  abandoned, // owner offline, instant capture
}
