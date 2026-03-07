import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/run_provider.dart';
import '../../providers/map_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/streak_badge.dart';
import '../../widgets/stamina_bar.dart';
import '../../widgets/nearby_players_indicator.dart';
import '../../widgets/map_search_bar.dart';
import '../../widgets/map_filter_chips.dart';
import '../running/running_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Modern Map Style (Silver/Night hybrid)
  static const String _mapStyle = '''
  [
    {
      "featureType": "all",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#7c93a3"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#e9e9e9"}]
    },
    {
      "featureType": "landscape",
      "elementType": "geometry",
      "stylers": [{"color": "#f5f5f5"}]
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
    _pulseAnimation = Tween(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().loadTerritories();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
              target: LatLng(24.9333, 67.0500), // Default to Karachi based on screenshot
              zoom: 14,
            ),
            onMapCreated: (controller) {
              controller.setMapStyle(_mapStyle);
              mapProvider.setMapController(controller);
            },
            markers: _buildMarkers(mapProvider),
            polylines: _buildPolylines(mapProvider),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // ── Search & Filters ─────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: Column(
              children: [
                MapSearchBar(
                  onSearch: (query) {
                    // Implement search logic or just show SnackBar for now
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Searching for "$query"...')),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const MapFilterChips(),
              ],
            ),
          ),

          // ── Status Indicators ────────────────────────────
          if (!connProvider.isOnline) _buildOfflineBanner(),
          if (connProvider.pendingSyncCount > 0) _buildSyncBadge(connProvider),

          // ── Top-right Controls ───────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 140, // Pushed down by search/filters
            right: 16,
            child: _buildSideControls(mapProvider),
          ),

          // ── Bottom HUD ───────────────────────────────────
          if (!runProvider.isRunning) _buildBottomHud(context, mapProvider),

          // ── Running overlay ──────────────────────────────
          if (runProvider.isRunning) const RunningScreen(),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(MapProvider map) {
    final markers = <Marker>{};

    // Nearby Runners Markers
    if (map.showRunners) {
      for (final runner in map.nearbyRunners) {
        if (runner.lastLat != null && runner.lastLng != null) {
          markers.add(
            Marker(
              markerId: MarkerId('runner_${runner.id}'),
              position: LatLng(runner.lastLat!, runner.lastLng!),
              infoWindow: InfoWindow(title: runner.username, snippet: 'Running Nearby'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
          );
        }
      }
    }

    // Territory Owner Markers
    if (map.showTerritories) {
      for (final territory in map.visibleTerritories) {
        if (territory.polylinePath.isNotEmpty) {
          final start = territory.polylinePath.first;
          markers.add(
            Marker(
              markerId: MarkerId('territory_${territory.id}'),
              position: LatLng(start[0], start[1]),
              infoWindow: InfoWindow(
                title: territory.ownerUsername,
                snippet: 'Territory Strength: ${territory.strengthPercent.toStringAsFixed(0)}%',
              ),
              onTap: () => map.selectTerritory(territory),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
            ),
          );
        }
      }
    }

    return markers;
  }

  Set<Polyline> _buildPolylines(MapProvider map) {
    final polylines = <Polyline>{};

    if (map.showTerritories) {
      for (final territory in map.visibleTerritories) {
        polylines.add(
          Polyline(
            polylineId: PolylineId(territory.id),
            points: territory.polylinePath.map((p) => LatLng(p[0], p[1])).toList(),
            color: territory.ownerId == 'me' ? AppColors.playerTrail : AppColors.otherPlayerTrail(territory.colorIndex),
            width: 5,
            geodesic: true,
            onTap: () => map.selectTerritory(territory),
            consumeTapEvents: true,
          ),
        );
      }
    }

    return polylines;
  }

  Widget _buildOfflineBanner() {
    return Positioned(
      top: 140,
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
            const SizedBox(width: 6),
            Text('Offline', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncBadge(ConnectivityProvider conn) {
    return Positioned(
      top: 140,
      right: 80,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('${conn.pendingSyncCount} syncing', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSideControls(MapProvider map) {
    return Column(
      children: [
        _mapButton(Icons.my_location_rounded, () => map.animateToUser()),
        const SizedBox(height: 8),
        _mapButton(
          map.showHeatmap ? Icons.layers_rounded : Icons.layers_outlined,
          () => map.toggleHeatmap(),
        ),
        const SizedBox(height: 8),
        _mapButton(Icons.leaderboard_rounded, () {
          // Future: Navigate to leaderboard
        }),
      ],
    );
  }

  Widget _mapButton(IconData icon, VoidCallback onTap) {
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: onTap,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.accent,
      elevation: 4,
      child: Icon(icon, size: 20),
    );
  }

  Widget _buildBottomHud(BuildContext context, MapProvider map) {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StreakBadge(streakDays: 7),
              NearbyPlayersIndicator(count: map.nearbyPlayersCount),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => context.read<RunProvider>().startRun('me'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 8,
              ),
              child: const Text('START RUN', style: TextStyle(color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
