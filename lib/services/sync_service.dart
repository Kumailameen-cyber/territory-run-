import 'dart:async';
import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';
import 'offline_storage_service.dart';
import 'firestore_service.dart';
import '../models/sync_queue_item.dart';

/// Syncs offline data to Firestore when connectivity is restored.
///
/// Maintains a FIFO queue of pending writes. Listens for connectivity changes
/// and drains the queue when online.
class SyncService {
  final OfflineStorageService _storage;
  final FirestoreService _firestore;
  final ConnectivityService _connectivity;

  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;

  SyncService({
    required OfflineStorageService storage,
    required FirestoreService firestore,
    required ConnectivityService connectivity,
  })  : _storage = storage,
        _firestore = firestore,
        _connectivity = connectivity;

  /// Start listening for connectivity changes.
  void initialize() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((online) {
      if (online) {
        debugPrint('[Sync] Online — starting queue drain');
        drainQueue();
      }
    });

    // If already online, drain immediately.
    if (_connectivity.isOnline) {
      drainQueue();
    }
  }

  /// Process all queued operations in order.
  Future<void> drainQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final queue = _storage.getPendingQueue();
      debugPrint('[Sync] Draining ${queue.length} queued operations');

      for (final item in queue) {
        if (!_connectivity.isOnline) {
          debugPrint('[Sync] Lost connectivity — pausing drain');
          break;
        }

        try {
          await _processItem(item);
          await _storage.removeFromQueue(item.id);
        } catch (e) {
          debugPrint('[Sync] Failed to process ${item.id}: $e');
          if (item.retryCount >= 3) {
            debugPrint('[Sync] Max retries reached, discarding ${item.id}');
            await _storage.removeFromQueue(item.id);
          } else {
            // Re-enqueue with incremented retry count.
            await _storage.enqueue(item.incrementRetry());
          }
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Process a single sync queue item.
  Future<void> _processItem(SyncQueueItem item) async {
    switch (item.action) {
      case SyncAction.create:
        await _firestore.createDocument(
            item.collection, item.documentId, item.data);
        break;
      case SyncAction.update:
        await _firestore.updateDocument(
            item.collection, item.documentId, item.data);
        break;
      case SyncAction.delete:
        await _firestore.deleteDocument(item.collection, item.documentId);
        break;
    }
  }

  /// Get count of pending operations.
  int get pendingCount => _storage.pendingQueueCount;

  /// Whether a sync is actively running.
  bool get isSyncing => _isSyncing;

  void dispose() {
    _connectivitySub?.cancel();
  }
}
