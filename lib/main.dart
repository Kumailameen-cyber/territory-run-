import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'services/offline_storage_service.dart';
import 'services/connectivity_service.dart';
import 'services/firestore_service.dart';
import 'services/sync_service.dart';
import 'services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

/// Application entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── ERROR HANDLING ──────────────────────────────────────
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('🔥 Flutter Error: ${details.exception}');
  };

  try {
    debugPrint('🚀 Starting Territory Run...');

    // Initialize Firebase
    debugPrint('📦 Initializing Firebase...');
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase Initialized');
    } catch (e) {
      debugPrint('⚠️ Firebase Initialization warning: $e');
    }

    // Lock orientation to portrait (Mobile only)
    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      
      // Transparent status bar
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ));
    }

    // ── Initialize services ─────────────────────────────────
    debugPrint('🛠️ Initializing Services...');
    
    // 1. Local DB.
    final storage = OfflineStorageService();
    await storage.initialize();

    // 2. Connectivity.
    final connectivity = ConnectivityService();
    await connectivity.initialize();

    // 3. Sync service.
    final firestore = FirestoreService();
    final syncService = SyncService(
      storage: storage,
      firestore: firestore,
      connectivity: connectivity,
    );
    syncService.initialize();

    // 4. Notifications (Skip on Web for now to prevent hangs)
    if (!kIsWeb) {
      debugPrint('🔔 Initializing Notifications...');
      try {
        final notifications = NotificationService();
        await notifications.initialize();
        debugPrint('✅ Notifications Ready');
      } catch (e) {
        debugPrint('⚠️ Notifications Initialization warning: $e');
      }
    } else {
      debugPrint('ℹ️ Skipping Background Notifications on Web');
    }
    
    debugPrint('✅ Services Ready');

    // ── Launch app ──────────────────────────────────────────
    runApp(TerritoryRunApp(
      storage: storage,
      connectivity: connectivity,
      syncService: syncService,
    ));
    
    debugPrint('🏁 App Launched');
  } catch (e, stack) {
    debugPrint('❌ CRITICAL INITIALIZATION ERROR: $e');
    debugPrint(stack.toString());
    
    // Fallback UI if everything fails
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF0F172A), // Sleek dark blue
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Failed to start app:\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please check your internet connection.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
