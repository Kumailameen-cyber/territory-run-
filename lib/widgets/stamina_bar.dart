import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Stamina / energy bar widget.
class StaminaBar extends StatelessWidget {
  /// Current stamina (0.0 – 1.0).
  final double value;

  const StaminaBar({super.key, required this.value});

  Color get _color {
    if (value > 0.6) return AppColors.staminaFull;
    if (value > 0.3) return AppColors.staminaHalf;
    return AppColors.staminaLow;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt, size: 16, color: _color),
            const SizedBox(width: 4),
            Text(
              'Energy',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(_color),
            ),
          ),
        ),
      ],
    );
  }
}
