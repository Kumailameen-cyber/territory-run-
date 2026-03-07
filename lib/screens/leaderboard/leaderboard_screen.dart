import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/leaderboard_provider.dart';

/// Global / City / Friends / Streaks leaderboard.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final filters = LeaderboardFilter.values;
        context.read<LeaderboardProvider>().setFilter(
              filters[_tabController.index],
            );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'City'),
            Tab(text: 'Friends'),
            Tab(text: 'Streaks'),
          ],
        ),
      ),
      body: Consumer<LeaderboardProvider>(
        builder: (context, lb, _) {
          if (lb.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: lb.entries.length,
            itemBuilder: (context, index) {
              final entry = lb.entries[index];
              return _buildRankCard(entry, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildRankCard(LeaderboardEntry entry, int index) {
    final isTop3 = index < 3;
    final rankColors = [AppColors.gold, AppColors.silver, AppColors.bronze];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isTop3
            ? Border.all(
                color: rankColors[index].withValues(alpha: 0.4),
                width: 1.5,
              )
            : null,
        boxShadow: isTop3
            ? [
                BoxShadow(
                  color: rankColors[index].withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // ── Rank ─────────────────────────────────────────
          SizedBox(
            width: 40,
            child: isTop3
                ? Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          rankColors[index],
                          rankColors[index].withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '#${entry.rank}',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                : Text(
                    '#${entry.rank}',
                    style: AppTextStyles.rankNumber,
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 12),

          // ── Avatar ───────────────────────────────────────
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.accentSurface,
            child: Text(
              entry.username[0].toUpperCase(),
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // ── Name & stats ─────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.username, style: AppTextStyles.titleSmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _miniStat(Icons.directions_run,
                        '${entry.totalDistanceKm.toStringAsFixed(0)}km'),
                    const SizedBox(width: 12),
                    _miniStat(Icons.terrain,
                        '${entry.territoriesOwned}'),
                    const SizedBox(width: 12),
                    _miniStat(Icons.grid_view,
                        '${entry.districtsControlled}'),
                  ],
                ),
              ],
            ),
          ),

          // ── Score ────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(entry.formattedScore, style: AppTextStyles.score),
              const SizedBox(height: 2),
              Text('pts', style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(value, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
