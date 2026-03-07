import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/territory_model.dart';

/// Territory detail modal bottom sheet.
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.terrain_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Territory',
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Owned by ${territory.ownerUsername}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (territory.isNeutral)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neutralTrail.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Neutral',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Strength bar ─────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Strength', style: AppTextStyles.labelMedium),
                  Text(
                    '${territory.strength.toStringAsFixed(1)} km',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (territory.strength / 10).clamp(0, 1),
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    territory.isNeutral
                        ? AppColors.neutralTrail
                        : AppColors.playerTrail,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Stats grid ───────────────────────────────────
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
          const SizedBox(height: 20),

          // ── Created timestamp ─────────────────────────────
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Created ${_formatDate(territory.createdAt)}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Capture button ───────────────────────────────
          if (!territory.isNeutral)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Start a run targeting this territory.
                },
                icon: const Icon(Icons.directions_run),
                label: const Text('Challenge this Territory'),
              ),
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
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.titleSmall),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    return '${diff.inMinutes} min ago';
  }
}
