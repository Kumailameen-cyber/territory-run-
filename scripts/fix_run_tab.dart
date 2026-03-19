import 'dart:io';

void main() async {
  final runTabPath = 'screens/running/run_tab_screen.dart';
  String out = await File(runTabPath).readAsString();

  // 1. Add imports
  if (!out.contains("import 'package:provider/provider.dart';")) {
    out = out.replaceFirst(
      "import '../../core/theme/app_text_styles.dart';",
      "import '../../core/theme/app_text_styles.dart';\nimport 'package:provider/provider.dart';\nimport 'package:intl/intl.dart';\nimport '../../providers/run_provider.dart';"
    );
  }

  // 2. Wrap padding in SingleChildScrollView
  out = out.replaceFirst(
    '      body: SafeArea(\n        child: Padding(',
    '      body: SafeArea(\n        child: SingleChildScrollView(\n          child: Padding('
  );
  
  out = out.replaceFirst(
    '            ], // Column children\n          ),\n        ),\n      ),\n    );', // Guessing structure, better use indexOf
    ''
  ); // Let's use string manipulation safely

  int bodyIdx = out.indexOf('      body: SafeArea(');
  int widgetEnd = out.indexOf('  Widget _buildRunCard');
  if (bodyIdx != -1 && widgetEnd != -1) {
    // We can rebuild the whole build method to be safe
    String newBuildMethod = '''
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('Run', style: AppTextStyles.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  'Your running history and quick-start',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 32),

                // ── Quick Start Card ────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.startButtonTeal,
                        AppColors.startButtonTealDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.startButtonGlow,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.directions_run,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ready to Run?',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Start a run from the Map tab to claim territory',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Recent Runs Header ──────────────────────────
                Text('Recent Runs', style: AppTextStyles.titleLarge),
                const SizedBox(height: 16),

                // ── Dynamic run cards ───────────────────────
                Consumer<RunProvider>(
                  builder: (context, runProvider, child) {
                    final runs = runProvider.runHistory;
                    if (runs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: Text(
                          'No runs yet. Start exploring!',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    // Sort by most recent
                    final sortedRuns = runs.toList()..sort((a, b) => b.startTime.compareTo(a.startTime));
                    final recentRuns = sortedRuns.take(5).toList();

                    return Column(
                      children: recentRuns.map((run) {
                        final date = DateFormat('MMM d, yyyy').format(run.startTime);
                        final distance = '\${(run.distance / 1000).toStringAsFixed(2)} km';
                        
                        final duration = run.endTime != null ? run.endTime!.difference(run.startTime) : const Duration();
                        final mm = duration.inMinutes.toString().padLeft(2, '0');
                        final ss = (duration.inSeconds % 60).toString().padLeft(2, '0');
                        final time = '\$mm:\$ss';
                        
                        String paceStr = '--\\'--" / km';
                        if (run.distance > 0 && duration.inSeconds > 0) {
                          final paceMinutes = (duration.inSeconds / 60) / (run.distance / 1000);
                          final pMin = paceMinutes.floor();
                          final pSec = ((paceMinutes - pMin) * 60).round();
                          paceStr = '\$pMin\\'\${pSec.toString().padLeft(2, '0')}" / km';
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildRunCard(date, distance, time, paceStr),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 32), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
''';
    int buildStart = out.indexOf('  @override');
    out = out.substring(0, buildStart) + newBuildMethod + out.substring(widgetEnd);
  }

  await File(runTabPath).writeAsString(out);
  print('Successfully patched run_tab_screen.dart');
}
