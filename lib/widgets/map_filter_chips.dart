import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/map_provider.dart';

class MapFilterChips extends StatelessWidget {
  const MapFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final map = context.watch<MapProvider>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _filterChip(
            icon: Icons.map_outlined,
            label: 'Territories',
            isSelected: map.showTerritories,
            onTap: () => map.toggleTerritories(),
          ),
          const SizedBox(width: 8),
          _filterChip(
            icon: Icons.directions_run_rounded,
            label: 'Runners',
            isSelected: map.showRunners,
            onTap: () => map.toggleRunners(),
          ),
          const SizedBox(width: 8),
          _filterChip(
            icon: Icons.local_fire_department_outlined,
            label: 'Heatmap',
            isSelected: map.showHeatmap,
            onTap: () => map.toggleHeatmap(),
          ),
          const SizedBox(width: 8),
          _filterChip(
            icon: Icons.emoji_events_outlined,
            label: 'Leaderboard',
            onTap: () {
              // Navigation or toggle? Leaderboard is usually a screen.
            },
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
