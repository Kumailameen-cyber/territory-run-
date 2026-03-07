import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/game_constants.dart';
import '../core/utils/geo_utils.dart';
import '../core/utils/polyline_utils.dart';
import '../core/utils/score_utils.dart';
import '../models/run_model.dart';
import '../models/sync_queue_item.dart';
import '../services/gps_service.dart';
import '../services/offline_storage_service.dart';

/// Manages the active run state and run history.
class RunProvider extends ChangeNotifier {
  final GpsService _gpsService;
  final OfflineStorageService _storage;

  static const _uuid = Uuid();

  RunModel? _activeRun;
  List<List<double>> _livePoints = [];
  StreamSubscription<GpsPosition>? _gpsSub;
  Timer? _timerTick;
  Duration _elapsed = Duration.zero;
  double _currentSpeedKmh = 0;

  RunProvider({
    required GpsService gpsService,
    required OfflineStorageService storage,
  })  : _gpsService = gpsService,
        _storage = storage;

  // ── Getters ─────────────────────────────────────────────
  RunModel? get activeRun => _activeRun;
  bool get isRunning => _activeRun != null;
  List<List<double>> get livePoints => List.unmodifiable(_livePoints);
  Duration get elapsed => _elapsed;
  double get currentSpeedKmh => _currentSpeedKmh;

  double get liveDistanceM {
    return GeoUtils.pathDistanceM(_livePoints);
  }

  double get liveDistanceKm => liveDistanceM / 1000;

  String get paceFormatted {
    if (liveDistanceKm <= 0) return '--:--';
    final paceMinutes = _elapsed.inSeconds / 60 / liveDistanceKm;
    final mins = paceMinutes.floor();
    final secs = ((paceMinutes - mins) * 60).round();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String get timerFormatted {
    final hours = _elapsed.inHours;
    final mins = _elapsed.inMinutes % 60;
    final secs = _elapsed.inSeconds % 60;
    if (hours > 0) {
      return '$hours:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Run history from local storage.
  List<RunModel> get runHistory => _storage.getAllRuns();

  // ── Actions ─────────────────────────────────────────────

  /// Start a new run.
  void startRun(String userId) {
    _activeRun = RunModel(
      id: _uuid.v4(),
      userId: userId,
      startTime: DateTime.now(),
    );
    _livePoints = [];
    _elapsed = Duration.zero;
    _currentSpeedKmh = 0;

    // Start GPS stream.
    final stream = _gpsService.startTracking();
    _gpsSub = stream.listen(_onGpsPoint);

    // Start timer.
    _timerTick = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = DateTime.now().difference(_activeRun!.startTime);
      notifyListeners();
    });

    notifyListeners();
  }

  void _onGpsPoint(GpsPosition pos) {
    _livePoints.add(pos.toLatLng());

    // Calculate live speed.
    if (_livePoints.length >= 2) {
      final prev = _livePoints[_livePoints.length - 2];
      final timeDelta = GameConstants.gpsIntervalMs / 1000.0;
      _currentSpeedKmh = GeoUtils.speedKmh(
        prev[0], prev[1],
        pos.latitude, pos.longitude,
        timeDelta,
      );
    }

    notifyListeners();
  }

  /// Stop the active run and save it.
  Future<RunModel?> stopRun() async {
    if (_activeRun == null) return null;

    _gpsService.stopTracking();
    _gpsSub?.cancel();
    _timerTick?.cancel();

    final finishedRun = _activeRun!.copyWith(
      distance: liveDistanceM,
      pathCoordinates: List.from(_livePoints),
      endTime: DateTime.now(),
      averageSpeedKmh: liveDistanceKm > 0
          ? liveDistanceKm / (_elapsed.inSeconds / 3600)
          : 0,
      encodedPolyline:
          _livePoints.isNotEmpty ? PolylineUtils.encode(_livePoints) : null,
      xpEarned: ScoreUtils.xpFromRun(
        distanceKm: liveDistanceKm,
        isExploration: false, // determined by territory engine
        currentStreak: 0, // injected from user profile
      ),
    );

    // Save locally.
    await _storage.saveRun(finishedRun);

    // Queue for sync.
    await _storage.enqueue(SyncQueueItem(
      id: _uuid.v4(),
      action: SyncAction.create,
      collection: 'runs',
      documentId: finishedRun.id,
      data: finishedRun.toJson(),
      createdAt: DateTime.now(),
    ));

    _activeRun = null;
    _livePoints = [];
    notifyListeners();

    return finishedRun;
  }

  /// Discard the current run.
  void discardRun() {
    _gpsService.stopTracking();
    _gpsSub?.cancel();
    _timerTick?.cancel();
    _activeRun = null;
    _livePoints = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _gpsSub?.cancel();
    _timerTick?.cancel();
    _gpsService.dispose();
    super.dispose();
  }
}
