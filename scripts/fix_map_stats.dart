import 'dart:io';

void main() async {
  final mapPath = 'screens/map/map_screen.dart';
  String out = await File(mapPath).readAsString();

  final topStatsStart = out.indexOf('  Widget _buildTopStatsBar(BuildContext context) {');
  final topStatsEnd = out.indexOf('  Widget _statChip({');

  if (topStatsStart != -1 && topStatsEnd != -1) {
    String newTopBar = '''
  Widget _buildTopStatsBar(BuildContext context) {
    final runProvider = context.watch<RunProvider>();
    final mapProvider = context.watch<MapProvider>();
    
    // Calculate today's distance
    final today = DateTime.now();
    final todaysDistance = runProvider.runHistory
        .where((r) => r.startTime.year == today.year && r.startTime.month == today.month && r.startTime.day == today.day)
        .fold(0.0, (sum, item) => sum + item.distance);
    
    // Count user territories
    final myTerritories = mapProvider.visibleTerritories.where((t) => t.ownerId == 'me').length;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 8,
              20,
              12,
            ),
            decoration: BoxDecoration(
              color: AppColors.glassSurface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // ── Running shoe icon + Today's Distance ──
                _statChip(
                  icon: Icons.directions_run,
                  iconColor: AppColors.startButtonTeal,
                  label: "Today's Distance",
                  value: '\${(todaysDistance / 1000).toStringAsFixed(1)} km',
                  flex: 3,
                ),
                const SizedBox(width: 12),

                // ── Territories ──
                _statChip(
                  icon: Icons.emoji_events,
                  iconColor: AppColors.xpGold,
                  label: 'Territories',
                  value: myTerritories.toString(),
                  flex: 2,
                ),
                const SizedBox(width: 12),

                // ── Streak ──
                _statChip(
                  icon: Icons.local_fire_department,
                  iconColor: AppColors.streakFlame,
                  label: 'Streak',
                  value: '0', // Placeholder until user model is expanded
                  flex: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

''';
    out = out.substring(0, topStatsStart) + newTopBar + out.substring(topStatsEnd);
    await File(mapPath).writeAsString(out);
    print('Successfully updated map top stats bar to use real data.');
  } else {
    print('Failed to find replace indices.');
  }
}
