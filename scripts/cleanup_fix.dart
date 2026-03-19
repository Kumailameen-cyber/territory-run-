import 'dart:io';

void main() async {
  final mapScreenPath = 'screens/map/map_screen.dart';
  String out = await File(mapScreenPath).readAsString();

  // Fix currentPath -> livePoints
  out = out.replaceAll(
    'if (run.isRunning && run.currentPath.isNotEmpty) {\\n      final runPoints = run.currentPath.map((loc) => LatLng(loc.latitude, loc.longitude)).toList();',
    'if (run.isRunning && run.livePoints.isNotEmpty) {\\n      final runPoints = run.livePoints.map((loc) => LatLng(loc[0], loc[1])).toList();',
  );
  // Just in case formatting changed it:
  out = out.replaceAll(
    'if (run.isRunning && run.currentPath.isNotEmpty) {\n      final runPoints = run.currentPath\n          .map((loc) => LatLng(loc.latitude, loc.longitude))\n          .toList();',
    'if (run.isRunning && run.livePoints.isNotEmpty) {\n      final runPoints = run.livePoints\n          .map((loc) => LatLng(loc[0], loc[1]))\n          .toList();',
  );

  // Remove the old _buildTerritoryPopup
  int startIdx = out.indexOf('  // ══════════════════════════════════════════════════════════\\n  // TERRITORY INFO POPUP');
  if (startIdx == -1) startIdx = out.indexOf('  // TERRITORY INFO POPUP');
  
  int endIdx = out.indexOf('  Color _powerColor(double fraction) {');

  if (startIdx != -1 && endIdx != -1) {
    // Find back to the comment
    int trueStart = out.lastIndexOf('  // ════', startIdx);
    if (trueStart == -1) trueStart = startIdx;

    final newPopup = '''
  // ══════════════════════════════════════════════════════════
  // TERRITORY INFO POPUP
  // ══════════════════════════════════════════════════════════
  /// Builds a futuristic, glassmorphic card displaying real-world stats for the 
  /// selected territory (e.g., owner, strength, capture history).
  Widget _buildTerritoryPopup(TerritoryModel t) {
    final colorIndex = t.colorIndex;
    final borderColor = AppColors.territoryColor(colorIndex);
    final power = t.strengthPercent.toInt();

    return Positioned(
      bottom: 140,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: _glowAnimation.value * 0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  children: [
                    const Text('👑 ', style: TextStyle(fontSize: 18)),
                    Expanded(
                      child: Text(
                        'Territory Leader: \${t.ownerUsername}',
                        style: AppTextStyles.territoryPopupTitle,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.read<MapProvider>().selectTerritory(null),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // ── Details ──
                Row(
                  children: [
                    Text(
                      'Captures: \${t.captureCount}',
                      style: AppTextStyles.territoryPopupSubtitle,
                    ),
                    const Text(' • ', style: TextStyle(color: AppColors.textSecondary)),
                    const Text('📏 ', style: TextStyle(fontSize: 12)),
                    Text(
                      'Distance: \${t.lengthM.toStringAsFixed(0)}m',
                      style: AppTextStyles.territoryPopupSubtitle,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Power Bar ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Power', style: AppTextStyles.labelMedium),
                    Text(
                      '\$power%',
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
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.powerBarStart,
                          AppColors.powerBarMid,
                          AppColors.powerBarEnd,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: (power / 100).clamp(0.0, 1.0),
                          child: Container(
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
                        // Grey out unfilled portion
                        if (power < 100)
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            width: MediaQuery.of(context).size.width *
                                (1 - (power / 100)).clamp(0.0, 1.0),
                            child: Container(color: Colors.grey.withValues(alpha: 0.2)),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

''';
    out = out.substring(0, trueStart) + newPopup + out.substring(endIdx);
  }

  await File(mapScreenPath).writeAsString(out);
  print('Successfully patched the map_screen errors.');
}
