import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Heatmap overlay service.
///
/// Aggregates GPS data and produces a color-mapped overlay for the map widget.
class HeatmapService {
  HeatmapService();

  /// Calculate heatmap data for a given viewport.
  ///
  /// Returns a list of heatmap points with normalized intensity (0.0–1.0).
  List<HeatmapPoint> calculateHeatmap({
    required double northLat,
    required double southLat,
    required double eastLng,
    required double westLng,
    required List<List<double>> allRunPoints,
    int gridResolution = 20,
  }) {
    if (allRunPoints.isEmpty) return [];

    final latStep = (northLat - southLat) / gridResolution;
    final lngStep = (eastLng - westLng) / gridResolution;

    // Count points per grid cell.
    final grid = <String, int>{};
    for (final pt in allRunPoints) {
      if (pt[0] < southLat ||
          pt[0] > northLat ||
          pt[1] < westLng ||
          pt[1] > eastLng) { continue; }

      final row = ((pt[0] - southLat) / latStep).floor();
      final col = ((pt[1] - westLng) / lngStep).floor();
      final key = '${row}_$col';
      grid[key] = (grid[key] ?? 0) + 1;
    }

    if (grid.isEmpty) return [];

    // Normalize intensities.
    final maxCount = grid.values.reduce((a, b) => a > b ? a : b);
    final points = <HeatmapPoint>[];

    for (final entry in grid.entries) {
      final parts = entry.key.split('_');
      final row = int.parse(parts[0]);
      final col = int.parse(parts[1]);
      final intensity = entry.value / maxCount;

      points.add(HeatmapPoint(
        latitude: southLat + (row + 0.5) * latStep,
        longitude: westLng + (col + 0.5) * lngStep,
        intensity: intensity,
        color: AppColors.heatmapColor(intensity),
      ));
    }

    return points;
  }
}

/// A single heatmap data point.
class HeatmapPoint {
  final double latitude;
  final double longitude;
  final double intensity; // 0.0 – 1.0
  final Color color;

  const HeatmapPoint({
    required this.latitude,
    required this.longitude,
    required this.intensity,
    required this.color,
  });
}
