import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Streak badge displaying consecutive running days with a flame icon.
class StreakBadge extends StatelessWidget {
  final int streakDays;

  const StreakBadge({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.streakFlame.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.streakFlame.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 18,
            color: AppColors.streakFlame,
          ),
          const SizedBox(width: 6),
          Text(
            '$streakDays day${streakDays != 1 ? 's' : ''}',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.streakFlame,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
