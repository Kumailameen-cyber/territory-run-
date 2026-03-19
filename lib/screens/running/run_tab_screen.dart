import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Placeholder Run tab screen — will be replaced with full functionality later.
class RunTabScreen extends StatelessWidget {
  const RunTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Run', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Your running history and quick-start',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),

              // ── Quick Start Card ────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.startButtonTeal,
                      AppColors.startButtonTealDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.startButtonGlow,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.directions_run,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ready to Run?',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Start a run from the Map tab to claim territory',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Recent Runs Header ──────────────────────────
              Text('Recent Runs', style: AppTextStyles.titleLarge),
              const SizedBox(height: 16),

              // ── Placeholder run cards ───────────────────────
              _buildRunCard('Today', '2.1 km', '12:34', '6\'02"/km'),
              const SizedBox(height: 12),
              _buildRunCard('Yesterday', '3.4 km', '20:15', '5\'58"/km'),
              const SizedBox(height: 12),
              _buildRunCard('Mar 9', '1.8 km', '10:45', '5\'55"/km'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRunCard(String date, String distance, String time, String pace) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.startButtonTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_run,
              color: AppColors.startButtonTeal,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: AppTextStyles.titleSmall),
                const SizedBox(height: 2),
                Text('$distance • $time', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Text(
            pace,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.startButtonTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
