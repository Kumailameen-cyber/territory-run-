import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitors network connectivity state.
///
/// Exposes [isOnline] and a stream for connectivity transitions.
class ConnectivityService {
  ConnectivityService();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _sub;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Start monitoring connectivity.
  Future<void> initialize() async {
    // Check initial state.
    final results = await _connectivity.checkConnectivity();
    _isOnline = _hasConnection(results);

    // Listen for changes.
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = _hasConnection(results);

      if (wasOnline != _isOnline) {
        debugPrint('[Connectivity] ${_isOnline ? "Online" : "Offline"}');
        _controller.add(_isOnline);
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
