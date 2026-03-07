import 'package:flutter/material.dart';
import '../models/territory_model.dart';
import '../models/user_model.dart';
import '../services/heatmap_service.dart';
import '../services/offline_storage_service.dart';
import '../services/firestore_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

/// Map state — visible territories, heatmap, and nearby players.
class MapProvider extends ChangeNotifier {
  final OfflineStorageService _storage;
  final HeatmapService _heatmapService;
  final FirestoreService _firestore;

  GoogleMapController? _mapController;
  List<TerritoryModel> _visibleTerritories = [];
  List<HeatmapPoint> _heatmapPoints = [];
  List<UserModel> _nearbyRunners = [];
  int _nearbyPlayersCount = 0;
  
  bool _showTerritories = true;
  bool _showRunners = true;
  bool _showHeatmap = true;
  
  TerritoryModel? _selectedTerritory;

  StreamSubscription? _runnersSubscription;

  MapProvider({
    required OfflineStorageService storage,
    required HeatmapService heatmapService,
    required FirestoreService firestore,
  })  : _storage = storage,
        _heatmapService = heatmapService,
        _firestore = firestore {
    _initNearbyRunnersListener();
  }

  List<TerritoryModel> get visibleTerritories =>
      List.unmodifiable(_visibleTerritories);
  List<HeatmapPoint> get heatmapPoints =>
      List.unmodifiable(_heatmapPoints);
  List<UserModel> get nearbyRunners => List.unmodifiable(_nearbyRunners);
  int get nearbyPlayersCount => _nearbyPlayersCount;
  
  bool get showTerritories => _showTerritories;
  bool get showRunners => _showRunners;
  bool get showHeatmap => _showHeatmap;
  
  TerritoryModel? get selectedTerritory => _selectedTerritory;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void _initNearbyRunnersListener() {
    _runnersSubscription?.cancel();
    _runnersSubscription = _firestore.streamNearbyRunners().listen((runners) {
      _nearbyRunners = runners;
      _nearbyPlayersCount = runners.length;
      notifyListeners();
    });
  }

  /// Load territories from local cache.
  void loadTerritories() {
    _visibleTerritories = _storage.getAllTerritories();
    notifyListeners();
  }

  /// Update heatmap for the current viewport.
  void updateHeatmap({
    required double northLat,
    required double southLat,
    required double eastLng,
    required double westLng,
  }) {
    // Gather all run points from stored runs.
    final runs = _storage.getAllRuns();
    final allPoints = runs.expand((r) => r.pathCoordinates).toList();

    _heatmapPoints = _heatmapService.calculateHeatmap(
      northLat: northLat,
      southLat: southLat,
      eastLng: eastLng,
      westLng: westLng,
      allRunPoints: allPoints,
    );
    notifyListeners();
  }

  /// Toggle map layers.
  void toggleTerritories() {
    _showTerritories = !_showTerritories;
    notifyListeners();
  }

  void toggleRunners() {
    _showRunners = !_showRunners;
    notifyListeners();
  }

  void toggleHeatmap() {
    _showHeatmap = !_showHeatmap;
    notifyListeners();
  }

  /// Animate camera to user location.
  Future<void> animateToUser() async {
    if (_mapController == null) return;
    
    // In a real app, we'd get current GPS. For now, center on default or last known.
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(const LatLng(24.9333, 67.0500), 16),
    );
  }

  /// Update nearby players count (from Firestore listener).
  void setNearbyPlayersCount(int count) {
    _nearbyPlayersCount = count;
    notifyListeners();
  }

  /// Add a newly created territory to the visible set.
  void addTerritory(TerritoryModel territory) {
    _visibleTerritories.add(territory);
    notifyListeners();
  }

  /// Update an existing territory (e.g., after capture).
  void updateTerritory(TerritoryModel updated) {
    final idx = _visibleTerritories.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _visibleTerritories[idx] = updated;
      if (_selectedTerritory?.id == updated.id) {
        _selectedTerritory = updated;
      }
      notifyListeners();
    }
  }

  void selectTerritory(TerritoryModel? territory) {
    _selectedTerritory = territory;
    notifyListeners();
    if (territory != null && _mapController != null) {
      // Center map on territory start if needed
    }
  }

  @override
  void dispose() {
    _runnersSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
