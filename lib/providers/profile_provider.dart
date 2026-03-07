import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/achievement_model.dart';
import '../services/offline_storage_service.dart';
import '../core/utils/score_utils.dart';

/// Player profile state.
class ProfileProvider extends ChangeNotifier {
  final OfflineStorageService _storage;

  UserModel? _user;
  List<AchievementModel> _achievements = [];

  ProfileProvider({required OfflineStorageService storage})
      : _storage = storage;

  UserModel? get user => _user;
  List<AchievementModel> get achievements => List.unmodifiable(_achievements);
  int get level => _user != null ? ScoreUtils.levelFromXp(_user!.xp) : 1;
  double get xpProgress =>
      _user != null ? ScoreUtils.xpProgress(_user!.xp) : 0;

  /// Load profile from local storage.
  void loadProfile() {
    _user = _storage.getCurrentUser();
    _loadAchievements();
    notifyListeners();
  }

  /// Update the user profile locally.
  Future<void> updateUser(UserModel user) async {
    _user = user;
    await _storage.saveUser(user);
    notifyListeners();
  }

  /// Add distance from a completed run.
  Future<void> addRunDistance(double distanceKm, int xpEarned) async {
    if (_user == null) return;

    _user = _user!.copyWith(
      totalDistance: _user!.totalDistance + distanceKm,
      xp: _user!.xp + xpEarned,
      level: ScoreUtils.levelFromXp(_user!.xp + xpEarned),
      longestRunKm: distanceKm > _user!.longestRunKm
          ? distanceKm
          : _user!.longestRunKm,
    );
    await _storage.saveUser(_user!);
    notifyListeners();
  }

  /// Increment streak.
  Future<void> incrementStreak() async {
    if (_user == null) return;
    _user = _user!.copyWith(streakCount: _user!.streakCount + 1);
    await _storage.saveUser(_user!);
    notifyListeners();
  }

  /// Reset streak.
  Future<void> resetStreak() async {
    if (_user == null) return;
    _user = _user!.copyWith(streakCount: 0);
    await _storage.saveUser(_user!);
    notifyListeners();
  }

  void _loadAchievements() {
    final userAchievements = _user?.achievements ?? [];
    _achievements = AchievementModel.all.map((a) {
      if (userAchievements.contains(a.id)) {
        return a.copyWith(unlocked: true);
      }
      return a;
    }).toList();
  }
}
