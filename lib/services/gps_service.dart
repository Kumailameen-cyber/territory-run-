import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/game_constants.dart';
import '../core/utils/geo_utils.dart';

/// GPS tracking service with anti-cheat validation.
///
/// Provides a filtered stream of validated GPS positions.
class GpsService {
  GpsService();

  StreamController<GpsPosition>? _controller;
  Timer? _gpsTimer;
  GpsPosition? _lastPosition;
  bool _isTracking = false;
  int _stableCount = 0;

  bool get isTracking => _isTracking;
  GpsPosition? get lastPosition => _lastPosition;

  /// Start tracking GPS at configured intervals.
  Stream<GpsPosition> startTracking() {
    _controller = StreamController<GpsPosition>.broadcast();
    _isTracking = true;
    _stableCount = 0;

    // Determine interval based on stability.
    _scheduleNextUpdate();

    return _controller!.stream;
  }

  void _scheduleNextUpdate() {
    if (!_isTracking) return;

    final intervalMs = _stableCount > 5
        ? GameConstants.gpsStableIntervalMs
        : GameConstants.gpsIntervalMs;

    _gpsTimer = Timer(Duration(milliseconds: intervalMs), () {
      _fetchAndValidate();
      _scheduleNextUpdate();
    });
  }

  Future<void> _fetchAndValidate() async {
    try {
      // In production, this calls Geolocator.getCurrentPosition().
      // Using platform channel — the actual implementation wraps:
      //   final pos = await Geolocator.getCurrentPosition(
      //     desiredAccuracy: LocationAccuracy.high,
      //   );
      // For now, this is a placeholder that services/providers override.
      final position = await _getPlatformPosition();
      if (position == null) return;

      // ── Anti-cheat validation ──────────────────────────
      if (_lastPosition != null) {
        final timeDelta =
            position.timestamp.difference(_lastPosition!.timestamp).inMilliseconds / 1000.0;

        // Speed check.
        final speed = GeoUtils.speedKmh(
          _lastPosition!.latitude, _lastPosition!.longitude,
          position.latitude, position.longitude,
          timeDelta,
        );
        if (speed > GameConstants.maxSpeedKmh) {
          debugPrint('[AntiCheat] Speed violation: ${speed.toStringAsFixed(1)} km/h');
          return; // Discard point.
        }

        // Teleport check.
        final dist = GeoUtils.distanceM(
          _lastPosition!.latitude, _lastPosition!.longitude,
          position.latitude, position.longitude,
        );
        if (dist > GameConstants.teleportThresholdM &&
            timeDelta < GameConstants.teleportTimeThresholdS) {
          debugPrint('[AntiCheat] Teleport detected: ${dist.toStringAsFixed(0)}m in ${timeDelta.toStringAsFixed(1)}s');
          return;
        }

        // Minimum distance filter (avoid clustering).
        if (dist < GameConstants.minPointDistanceM) {
          _stableCount++;
          return;
        }

        _stableCount = 0;
      }

      _lastPosition = position;
      _controller?.add(position);
    } catch (e) {
      debugPrint('[GPS] Error: $e');
    }
  }

  /// Stop tracking.
  void stopTracking() {
    _isTracking = false;
    _gpsTimer?.cancel();
    _controller?.close();
    _controller = null;
  }

  /// Platform GPS call (to be implemented with Geolocator).
  Future<GpsPosition?> _getPlatformPosition() async {
    // Placeholder — in real app:
    // final pos = await Geolocator.getCurrentPosition(...);
    // return GpsPosition(
    //   latitude: pos.latitude,
    //   longitude: pos.longitude,
    //   accuracy: pos.accuracy,
    //   timestamp: DateTime.now(),
    // );
    return null;
  }

  void dispose() {
    stopTracking();
  }
}

/// A validated GPS position.
class GpsPosition {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  const GpsPosition({
    required this.latitude,
    required this.longitude,
    this.accuracy = 0,
    required this.timestamp,
  });

  List<double> toLatLng() => [latitude, longitude];
}
