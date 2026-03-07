/// Achievement definitions and tracking.
class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedAt;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
    this.unlockedAt,
  });

  AchievementModel copyWith({bool? unlocked, DateTime? unlockedAt}) {
    return AchievementModel(
      id: id,
      title: title,
      description: description,
      icon: icon,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  /// All available achievements.
  static const List<AchievementModel> all = [
    AchievementModel(
      id: 'first_territory',
      title: 'First Territory',
      description: 'Claim your first territory',
      icon: '🏁',
    ),
    AchievementModel(
      id: 'runner_5k',
      title: '5K Runner',
      description: 'Complete a 5 km run',
      icon: '🏃',
    ),
    AchievementModel(
      id: 'runner_10k',
      title: '10K Runner',
      description: 'Complete a 10 km run',
      icon: '🏅',
    ),
    AchievementModel(
      id: 'city_explorer',
      title: 'City Explorer',
      description: 'Run in 10 different districts',
      icon: '🗺️',
    ),
    AchievementModel(
      id: 'district_champion',
      title: 'District Champion',
      description: 'Control an entire district',
      icon: '🏆',
    ),
    AchievementModel(
      id: 'territories_100',
      title: 'Territory Lord',
      description: 'Capture 100 territories',
      icon: '👑',
    ),
    AchievementModel(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Maintain a 7-day running streak',
      icon: '🔥',
    ),
    AchievementModel(
      id: 'streak_30',
      title: 'Monthly Machine',
      description: 'Maintain a 30-day running streak',
      icon: '⚡',
    ),
    AchievementModel(
      id: 'night_runner',
      title: 'Night Runner',
      description: 'Complete a run after 9 PM',
      icon: '🌙',
    ),
    AchievementModel(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Complete a run before 6 AM',
      icon: '🌅',
    ),
    AchievementModel(
      id: 'distance_100',
      title: 'Centurion',
      description: 'Run a total of 100 km',
      icon: '💯',
    ),
    AchievementModel(
      id: 'first_capture',
      title: 'Conqueror',
      description: 'Capture another player\'s territory',
      icon: '⚔️',
    ),
  ];
}
