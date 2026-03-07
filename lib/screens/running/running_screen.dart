import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/run_provider.dart';

/// Active run HUD — draggable bottom sheet overlay on the map.
class RunningScreen extends StatelessWidget {
  const RunningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.15,
      maxChildSize: 0.55,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                children: [
                  // ── Drag handle ──────────────────────────
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Timer ────────────────────────────────
                  Consumer<RunProvider>(
                    builder: (_, run, __) {
                      return Text(
                        run.timerFormatted,
                        style: AppTextStyles.runTimer,
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'DURATION',
                    style: AppTextStyles.runStatLabel.copyWith(
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Stats row ────────────────────────────
                  Consumer<RunProvider>(
                    builder: (_, run, __) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statColumn(
                            run.liveDistanceKm.toStringAsFixed(2),
                            'DISTANCE (KM)',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.divider,
                          ),
                          _statColumn(
                            run.paceFormatted,
                            'PACE (MIN/KM)',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.divider,
                          ),
                          _statColumn(
                            run.currentSpeedKmh.toStringAsFixed(1),
                            'SPEED (KM/H)',
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Territory capture progress ──────────
                  _buildCaptureProgress(),
                  const SizedBox(height: 16),

                  // ── Live info chips ─────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _infoChip(
                        Icons.local_fire_department,
                        'Day 7',
                        AppColors.streakFlame,
                      ),
                      const SizedBox(width: 12),
                      _infoChip(
                        Icons.leaderboard,
                        '#12 in city',
                        AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Energy indicator ────────────────────
                  _buildEnergyBar(),
                  const SizedBox(height: 24),

                  // ── Stop button ─────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _showStopDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.stop_rounded,
                              size: 24, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'STOP RUN',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.runStat),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.runStatLabel),
      ],
    );
  }

  Widget _buildCaptureProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Capturing Trail...',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.playerTrail,
              ),
            ),
            Text(
              '65%',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.playerTrail,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.65,
            minHeight: 6,
            backgroundColor: AppColors.accentSurface,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.playerTrail),
          ),
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt, size: 18, color: AppColors.staminaFull),
            const SizedBox(width: 6),
            Text(
              'Energy',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.72,
            minHeight: 8,
            backgroundColor: AppColors.surfaceVariant,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.staminaFull),
          ),
        ),
      ],
    );
  }

  void _showStopDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Run?'),
        content: Consumer<RunProvider>(
          builder: (_, run, __) {
            return Text(
              'You\'ve run ${run.liveDistanceKm.toStringAsFixed(2)} km in ${run.timerFormatted}. Save this run?',
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<RunProvider>().discardRun();
            },
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<RunProvider>().stopRun();
            },
            child: const Text('Save Run'),
          ),
        ],
      ),
    );
  }
}
