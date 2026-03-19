import 'dart:io';

void main() async {
  final mapScreenPath = 'screens/map/map_screen.dart';
  final mapContent = await File(mapScreenPath).readAsString();

  // 1. Remove _selectedTerritoryIndex
  String out = mapContent.replaceAll(
    '  // Selected territory index for popup (-1 = none)\n  int _selectedTerritoryIndex = -1;\n',
    '',
  );

  // 2. Remove _demoTerritories and _demoRunTrail
  final demoDataStart = out.indexOf('  // ── Demo territory data ──────────────────────────────────');
  final demoDataEnd = out.indexOf('  @override\n  void initState() {');
  if (demoDataStart != -1 && demoDataEnd != -1) {
    out = out.substring(0, demoDataStart) + out.substring(demoDataEnd);
  }

  // 3. Update GoogleMap parameters
  out = out.replaceAll(
    'polygons: _buildTerritoryPolygons(),',
    'polygons: _buildTerritoryPolygons(mapProvider),',
  );
  out = out.replaceAll(
    'onTap: (_) => setState(() => _selectedTerritoryIndex = -1),',
    'onTap: (_) => mapProvider.selectTerritory(null),',
  );

  out = out.replaceAll(
    'if (_selectedTerritoryIndex >= 0) _buildTerritoryPopup(),',
    'if (mapProvider.selectedTerritory != null) _buildTerritoryPopup(mapProvider.selectedTerritory!),',
  );

  // 4. Update _buildTerritoryPolygons
  final polyStart = out.indexOf('  Set<Polygon> _buildTerritoryPolygons() {');
  final polyEnd = out.indexOf('  // ══════════════════════════════════════════════════════════\n  // MAP POLYLINES');
  
  final newBuildingPolygons = '''
  /// Builds the territory polygons from the MapProvider's visible territories.
  /// This dynamically generates realistic boundaries based on actual user runs.
  Set<Polygon> _buildTerritoryPolygons(MapProvider map) {
    final polygons = <Polygon>{};

    if (map.showTerritories) {
      for (final territory in map.visibleTerritories) {
        final colorIndex = territory.colorIndex;
        final borderColor = territory.ownerId == 'me' 
            ? AppColors.territoryGreen 
            : AppColors.territoryColor(colorIndex);
        final fillColor = AppColors.territoryFill(colorIndex);

        polygons.add(
          Polygon(
            polygonId: PolygonId(territory.id),
            points: territory.polylinePath.map((p) => LatLng(p[0], p[1])).toList(),
            strokeWidth: 3,
            strokeColor: borderColor,
            fillColor: fillColor,
            consumeTapEvents: true,
            onTap: () {
              map.selectTerritory(territory);
            },
          ),
        );
      }
    }

    return polygons;
  }

''';
  if (polyStart != -1 && polyEnd != -1) {
    out = out.substring(0, polyStart) + newBuildingPolygons + out.substring(polyEnd);
  }

  // 5. Update _buildPolylines and remove existing user territories as polylines
  final polylineStart = out.indexOf('  Set<Polyline> _buildPolylines(MapProvider map) {');
  final polylineEnd = out.indexOf('  Set<Marker> _buildMarkers(MapProvider map) {');
  
  final newPolylines = '''
  /// Builds the active run trail polylines using the RunProvider's current path.
  /// This creates the futuristic glowing green trail behind the runner in real-time.
  Set<Polyline> _buildPolylines(MapProvider map) {
    final polylines = <Polyline>{};

    // Note: To get the active run path, we would typically pass RunProvider into this method.
    // Assuming context.read<RunProvider>() is accessible or state maintains it.
    // For simplicity, we assume RunProvider provides currentPath.
    // Since we don't have runProvider directly in the signature, we can fetch it here or modify the signature.
    // Actually, let's keep it simple. The run_tab_screen or running_screen handles the live run UI overlay.
    // If we wanted the live trail here, we'd pass runProvider to _buildPolylines.
    
    // We removed demoRunTrail, so currently polylines are empty unless a run is active.
    return polylines;
  }

''';
  if (polylineStart != -1 && polylineEnd != -1) {
    out = out.substring(0, polylineStart) + newPolylines + out.substring(polylineEnd);
  }

  // Need to fix _buildPolylines to take RunProvider
  out = out.replaceAll(
    'polylines: _buildPolylines(mapProvider),',
    'polylines: _buildPolylines(mapProvider, runProvider),',
  );

  out = out.replaceAll(
    'Set<Polyline> _buildPolylines(MapProvider map) {\n    final polylines = <Polyline>{};\n\n    // Note: To get the active run path, we would typically pass RunProvider into this method.',
    '''
  /// Builds the active run trail polylines using the RunProvider's current path.
  /// This creates the futuristic glowing green trail behind the runner in real-time.
  Set<Polyline> _buildPolylines(MapProvider map, RunProvider run) {
    final polylines = <Polyline>{};

    if (run.isRunning && run.currentPath.isNotEmpty) {
      final runPoints = run.currentPath.map((loc) => LatLng(loc.latitude, loc.longitude)).toList();
      // Outer glow line
      polylines.add(
        Polyline(
          polylineId: const PolylineId('run_trail_glow'),
          points: runPoints,
          color: AppColors.activeRunTrailGlow,
          width: 10,
          geodesic: true,
        ),
      );
      // Core line
      polylines.add(
        Polyline(
          polylineId: const PolylineId('run_trail_core'),
          points: runPoints,
          color: AppColors.activeRunTrail,
          width: 4,
          geodesic: true,
        ),
      );
    }
'''
  );

  // 6. Update _buildTerritoryPopup
  final popupStart = out.indexOf('  Widget _buildTerritoryPopup() {');
  final popupEnd = out.indexOf('  // ══════════════════════════════════════════════════════════\n  // RUN BUTTON');
  
  final newPopup = '''
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
  if (popupStart != -1 && popupEnd != -1) {
    out = out.substring(0, popupStart) + newPopup + out.substring(popupEnd);
  }

  // Import to include TerritoryModel.
  if (!out.contains("import '../../models/territory_model.dart';")) {
    out = out.replaceFirst(
      "import '../../providers/connectivity_provider.dart';", 
      "import '../../providers/connectivity_provider.dart';\nimport '../../models/territory_model.dart';"
    );
  }

  await File(mapScreenPath).writeAsString(out);
  print('Successfully stripped demo data and refactored map_screen.dart to use true data providers.');
}
