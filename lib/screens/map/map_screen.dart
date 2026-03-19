import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/run_provider.dart';
import '../../providers/map_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../models/territory_model.dart';
import '../running/running_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Modern clean map style
  static const String _mapStyle = '''
  [
    {
      "featureType": "all",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#7c93a3"}, {"lightness": -10}]
    },
    {
      "featureType": "water",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#e0e8f0"}]
    },
    {
      "featureType": "landscape",
      "elementType": "geometry",
      "stylers": [{"color": "#f0f2f5"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#ffffff"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#e0e4e8"}]
    },
    {
      "featureType": "poi",
      "elementType": "geometry",
      "stylers": [{"color": "#e8ecf0"}]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().loadTerritories();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final runProvider = context.watch<RunProvider>();
    final mapProvider = context.watch<MapProvider>();
    final connProvider = context.watch<ConnectivityProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Google Map ──────────────────────────────────
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(24.8155, 67.0345),
              zoom: 15.5,
            ),
            style: _mapStyle,
            onMapCreated: (controller) {
              mapProvider.setMapController(controller);
            },
            polygons: _buildTerritoryPolygons(mapProvider),
            polylines: _buildPolylines(mapProvider, runProvider),
            markers: _buildMarkers(mapProvider),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (_) => mapProvider.selectTerritory(null),
          ),

          // ── Top Stats Bar ──────────────────────────────
          _buildTopStatsBar(context),

          // ── Status Indicators ──────────────────────────
          if (!connProvider.isOnline) _buildOfflineBanner(),

          // ── Side Controls ──────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 100,
            right: 16,
            child: _buildSideControls(mapProvider),
          ),

          // ── Territory Info Popup ───────────────────────
          if (mapProvider.selectedTerritory != null)
            _buildTerritoryPopup(mapProvider.selectedTerritory!),

          // ── START RUN Button ───────────────────────────
          if (!runProvider.isRunning) _buildStartRunButton(context),

          // ── Running overlay ────────────────────────────
          if (runProvider.isRunning) const RunningScreen(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // TOP STATS BAR
  // ══════════════════════════════════════════════════════════
  Widget _buildTopStatsBar(BuildContext context) {
    final runProvider = context.watch<RunProvider>();
    final mapProvider = context.watch<MapProvider>();

    // Calculate today's distance
    final today = DateTime.now();
    final todaysDistance = runProvider.runHistory
        .where((r) =>
            r.startTime.year == today.year &&
            r.startTime.month == today.month &&
            r.startTime.day == today.day)
        .fold(0.0, (sum, item) => sum + item.distance);

    // Count user territories
    final myTerritories =
        mapProvider.visibleTerritories.where((t) => t.ownerId == 'me').length;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 8,
              20,
              12,
            ),
            decoration: BoxDecoration(
              color: AppColors.glassSurface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // ── Running shoe icon + Today's Distance ──
                _statChip(
                  icon: Icons.directions_run,
                  iconColor: AppColors.startButtonTeal,
                  label: "Today's Distance",
                  value: '${(todaysDistance / 1000).toStringAsFixed(1)} km',
                  flex: 3,
                ),
                const SizedBox(width: 12),

                // ── Territories ──
                _statChip(
                  icon: Icons.emoji_events,
                  iconColor: AppColors.xpGold,
                  label: 'Territories',
                  value: myTerritories.toString(),
                  flex: 2,
                ),
                const SizedBox(width: 12),

                // ── Streak ──
                _statChip(
                  icon: Icons.local_fire_department,
                  iconColor: AppColors.streakFlame,
                  label: 'Streak',
                  value: '0', // Placeholder until user model is expanded
                  flex: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.hudStatLabel,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: AppTextStyles.hudStatValue.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // TERRITORY POLYGONS
  // ══════════════════════════════════════════════════════════
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
            points:
                territory.polylinePath.map((p) => LatLng(p[0], p[1])).toList(),
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

  // ══════════════════════════════════════════════════════════
  // MAP POLYLINES (active run trail + existing territories)
  // ══════════════════════════════════════════════════════════
  /// Builds the active run trail polylines using the RunProvider's current path.
  /// This creates the futuristic glowing green trail behind the runner in real-time.
  /// Builds the active run trail polylines using the RunProvider's current path.
  /// This creates the futuristic glowing green trail behind the runner in real-time.
  Set<Polyline> _buildPolylines(MapProvider map, RunProvider run) {
    final polylines = <Polyline>{};

    if (run.isRunning && run.livePoints.isNotEmpty) {
      final runPoints =
          run.livePoints.map((loc) => LatLng(loc[0], loc[1])).toList();
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

    // Assuming context.read<RunProvider>() is accessible or state maintains it.
    // For simplicity, we assume RunProvider provides currentPath.
    // Since we don't have runProvider directly in the signature, we can fetch it here or modify the signature.
    // Actually, let's keep it simple. The run_tab_screen or running_screen handles the live run UI overlay.
    // If we wanted the live trail here, we'd pass runProvider to _buildPolylines.

    // We removed demoRunTrail, so currently polylines are empty unless a run is active.
    return polylines;
  }

  Set<Marker> _buildMarkers(MapProvider map) {
    final markers = <Marker>{};

    if (map.showRunners) {
      for (final runner in map.nearbyRunners) {
        if (runner.lastLat != null && runner.lastLng != null) {
          markers.add(
            Marker(
              markerId: MarkerId('runner_${runner.id}'),
              position: LatLng(runner.lastLat!, runner.lastLng!),
              infoWindow:
                  InfoWindow(title: runner.username, snippet: 'Running Nearby'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure),
            ),
          );
        }
      }
    }

    return markers;
  }

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
                  color: borderColor.withValues(
                      alpha: _glowAnimation.value * 0.15),
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
                        'Territory Leader: ${t.ownerUsername}',
                        style: AppTextStyles.territoryPopupTitle,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          context.read<MapProvider>().selectTerritory(null),
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
                      'Captures: ${t.captureCount}',
                      style: AppTextStyles.territoryPopupSubtitle,
                    ),
                    const Text(' • ',
                        style: TextStyle(color: AppColors.textSecondary)),
                    const Text('📏 ', style: TextStyle(fontSize: 12)),
                    Text(
                      'Distance: ${t.lengthM.toStringAsFixed(0)}m',
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
                            child: Container(
                                color: Colors.grey.withValues(alpha: 0.2)),
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

  Color _powerColor(double fraction) {
    if (fraction > 0.7) return AppColors.powerBarEnd;
    if (fraction > 0.4) return AppColors.powerBarMid;
    return AppColors.powerBarStart;
  }

  // ══════════════════════════════════════════════════════════
  // START RUN BUTTON
  // ══════════════════════════════════════════════════════════
  Widget _buildStartRunButton(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.startButtonGlow,
                    blurRadius: 24 * _pulseAnimation.value,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SizedBox(
                width: 220,
                height: 64,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00C9A7),
                        Color(0xFF00D2B4),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<RunProvider>().startRun('me'),
                    icon: const Icon(Icons.play_arrow_rounded,
                        size: 32, color: Colors.white),
                    label: Text(
                      'START RUN',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.5,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SIDE CONTROLS
  // ══════════════════════════════════════════════════════════
  Widget _buildSideControls(MapProvider map) {
    return Column(
      children: [
        _mapButton(Icons.my_location_rounded, () => map.animateToUser()),
        const SizedBox(height: 8),
        _mapButton(
          map.showHeatmap ? Icons.layers_rounded : Icons.layers_outlined,
          () => map.toggleHeatmap(),
        ),
      ],
    );
  }

  Widget _mapButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FloatingActionButton.small(
        heroTag: null,
        onPressed: onTap,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        child: Icon(icon, size: 20),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // OFFLINE BANNER
  // ══════════════════════════════════════════════════════════
  Widget _buildOfflineBanner() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 90,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 16, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Offline',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
