import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/run_provider.dart';
import 'providers/map_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/connectivity_provider.dart';
import 'services/auth_service.dart';
import 'services/gps_service.dart';
import 'services/offline_storage_service.dart';
import 'services/connectivity_service.dart';
import 'services/sync_service.dart';
import 'services/heatmap_service.dart';
import 'services/firestore_service.dart';
import 'screens/map/map_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/profile/profile_screen.dart';

/// Territory Run application root.
class TerritoryRunApp extends StatelessWidget {
  final OfflineStorageService storage;
  final ConnectivityService connectivity;
  final SyncService syncService;

  const TerritoryRunApp({
    super.key,
    required this.storage,
    required this.connectivity,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final gpsService = GpsService();
    final heatmapService = HeatmapService();
    final firestoreService = FirestoreService();

    return MultiProvider(
      providers: [
        // ── Auth ─────────────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            storage: storage,
          )..restoreSession(),
        ),

        // ── Run ──────────────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => RunProvider(
            gpsService: gpsService,
            storage: storage,
          ),
        ),

        // ── Map ──────────────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => MapProvider(
            storage: storage,
            heatmapService: heatmapService,
            firestore: firestoreService,
          ),
        ),

        // ── Leaderboard ──────────────────────────────────
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),

        // ── Profile ──────────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(storage: storage)..loadProfile(),
        ),

        // ── Connectivity ─────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider(
            connectivity: connectivity,
            syncService: syncService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Territory Run',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isAuthenticated) {
              return const _MainNavigation();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

/// Bottom navigation wrapper for main screens.
class _MainNavigation extends StatefulWidget {
  const _MainNavigation();

  @override
  State<_MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<_MainNavigation> {
  int _currentIndex = 0;

  final _screens = const [
    MapScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_rounded),
            label: 'Ranks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
