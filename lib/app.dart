import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
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
import 'screens/running/run_tab_screen.dart';
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
    RunTabScreen(),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.location_on, Icons.location_on_outlined, 'Map', 0),
                _navItem(Icons.play_arrow_rounded, Icons.play_arrow_outlined, 'Run', 1),
                _navItem(Icons.emoji_events, Icons.emoji_events_outlined, 'Ranks', 2),
                _navItem(Icons.person, Icons.person_outline, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.startButtonTeal.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              size: 24,
              color: isActive ? AppColors.startButtonTeal : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? AppColors.startButtonTeal : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (isActive && index == 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.startButtonTeal,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
