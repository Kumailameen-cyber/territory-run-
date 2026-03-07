import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

/// Exposes connectivity state and sync queue status to widgets.
class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _connectivity;
  final SyncService _syncService;

  bool _isOnline = true;

  ConnectivityProvider({
    required ConnectivityService connectivity,
    required SyncService syncService,
  })  : _connectivity = connectivity,
        _syncService = syncService {
    _isOnline = _connectivity.isOnline;
    _connectivity.onConnectivityChanged.listen((online) {
      _isOnline = online;
      notifyListeners();
    });
  }

  bool get isOnline => _isOnline;
  int get pendingSyncCount => _syncService.pendingCount;
  bool get isSyncing => _syncService.isSyncing;

  /// Force a sync attempt.
  Future<void> forceSync() async {
    await _syncService.drainQueue();
    notifyListeners();
  }
}
