import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/territory_model.dart';

/// Territory detail modal bottom sheet — neon futuristic style.
class TerritoryScreen extends StatelessWidget {
  final TerritoryModel territory;

  const TerritoryScreen({super.key, required this.territory});

  /// Show as a modal bottom sheet.
  static void show(BuildContext context, TerritoryModel territory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TerritoryScreen(territory: territory),
    );
  }

  @override
  Widget build(BuildContext context) {
    final power = (territory.strength * 10).clamp(0, 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.territoryColor(territory.colorIndex)
                .withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ───────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // ── Header ───────────────────────────────────────
          Row(
            children: [
              const Text('👑 ', style: TextStyle(fontSize: 20)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Territory Leader: ${territory.ownerUsername}',
                      style: AppTextStyles.territoryPopupTitle,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Level ${(territory.strength * 5).round().clamp(1, 10)}',
                          style: AppTextStyles.territoryPopupSubtitle,
                        ),
                        const Text(
                          ' • ',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const Text('🔥 ', style: TextStyle(fontSize: 12)),
                        Text(
                          'Streak: ${territory.captureCount} days',
                          style: AppTextStyles.territoryPopupSubtitle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Power Bar ───────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Power', style: AppTextStyles.labelMedium),
              Text(
                '$power%',
                style: AppTextStyles.labelLarge.copyWith(
                  color: _powerColor(power / 100),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  color: AppColors.surfaceVariant,
                ),
                FractionallySizedBox(
                  widthFactor: power / 100,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.powerBarStart,
                          power > 50
                              ? AppColors.powerBarMid
                              : AppColors.powerBarStart,
                          power > 80
                              ? AppColors.powerBarEnd
                              : AppColors.powerBarMid,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Last Defended ───────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Last Defended: ${_formatDate(territory.lastDecayAt)}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Stats Row ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _statTile(
                  Icons.straighten,
                  '${(territory.lengthM / 1000).toStringAsFixed(2)} km',
                  'Length',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statTile(
                  Icons.swap_horiz,
                  '${territory.captureCount}',
                  'Captures',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statTile(
                  Icons.grid_view_rounded,
                  territory.districtId.split('_').first,
                  'District',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Action Buttons ─────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                  label: const Text('View Stats'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.challengeGradientStart,
                        AppColors.challengeGradientEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Start a run targeting this territory.
                    },
                    icon: const Text('⚡', style: TextStyle(fontSize: 14)),
                    label: const Text('Challenge'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.startButtonTeal),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.titleSmall),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  Color _powerColor(double fraction) {
    if (fraction > 0.7) return AppColors.powerBarEnd;
    if (fraction > 0.4) return AppColors.powerBarMid;
    return AppColors.powerBarStart;
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}
