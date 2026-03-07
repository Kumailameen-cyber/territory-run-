import 'package:flutter/material.dart';
import '../core/utils/score_utils.dart';

/// Leaderboard state.
class LeaderboardProvider extends ChangeNotifier {
  List<LeaderboardEntry> _entries = [];
  LeaderboardFilter _filter = LeaderboardFilter.global;
  bool _isLoading = false;
  DateTime? _lastUpdated;

  List<LeaderboardEntry> get entries => List.unmodifiable(_entries);
  LeaderboardFilter get filter => _filter;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;

  /// Set the active filter tab.
  void setFilter(LeaderboardFilter filter) {
    _filter = filter;
    notifyListeners();
    refresh();
  }

  /// Refresh leaderboard data.
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    // In production, this queries Firestore.
    // For now, use mock data.
    await Future.delayed(const Duration(milliseconds: 500));

    _entries = _generateMockEntries();
    _lastUpdated = DateTime.now();
    _isLoading = false;
    notifyListeners();
  }

  /// Get current player's rank.
  int? getRank(String userId) {
    final idx = _entries.indexWhere((e) => e.userId == userId);
    return idx >= 0 ? idx + 1 : null;
  }

  List<LeaderboardEntry> _generateMockEntries() {
    return [
      LeaderboardEntry(
        userId: 'u1',
        username: 'SpeedRunner42',
        score: 14280,
        totalDistanceKm: 127.4,
        territoriesOwned: 34,
        districtsControlled: 5,
        streakDays: 14,
        rank: 1,
      ),
      LeaderboardEntry(
        userId: 'u2',
        username: 'TrailBlazer',
        score: 12150,
        totalDistanceKm: 98.2,
        territoriesOwned: 28,
        districtsControlled: 4,
        streakDays: 21,
        rank: 2,
      ),
      LeaderboardEntry(
        userId: 'u3',
        username: 'MileHunter',
        score: 10890,
        totalDistanceKm: 85.6,
        territoriesOwned: 22,
        districtsControlled: 3,
        streakDays: 7,
        rank: 3,
      ),
      LeaderboardEntry(
        userId: 'u4',
        username: 'UrbanExplorer',
        score: 9340,
        totalDistanceKm: 72.1,
        territoriesOwned: 19,
        districtsControlled: 2,
        streakDays: 12,
        rank: 4,
      ),
      LeaderboardEntry(
        userId: 'u5',
        username: 'NightSprinter',
        score: 8120,
        totalDistanceKm: 64.8,
        territoriesOwned: 15,
        districtsControlled: 2,
        streakDays: 5,
        rank: 5,
      ),
    ];
  }
}

/// Leaderboard filter tabs.
enum LeaderboardFilter { global, city, friends, streaks }

/// A single leaderboard row.
class LeaderboardEntry {
  final String userId;
  final String username;
  final double score;
  final double totalDistanceKm;
  final int territoriesOwned;
  final int districtsControlled;
  final int streakDays;
  final int rank;
  final String? avatarUrl;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.score,
    required this.totalDistanceKm,
    required this.territoriesOwned,
    required this.districtsControlled,
    required this.streakDays,
    required this.rank,
    this.avatarUrl,
  });

  String get formattedScore => ScoreUtils.formatScore(score);
}
