import 'package:flutter/material.dart';

/// Territory Run color system.
/// 
/// All colors are centralized here — no ad-hoc hex values elsewhere.
class AppColors {
  AppColors._();

  // ── Map ──────────────────────────────────────────────────
  static const Color mapBackground = Color(0xFFFFFFFF);
  static const Color playerTrail = Color(0xFF2979FF);
  static const Color playerTrailGlow = Color(0x552979FF);
  static const Color neutralTrail = Color(0xFFBDBDBD);

  // ── Heatmap gradient ────────────────────────────────────
  static const Color heatLow = Color(0xFF4CAF50);
  static const Color heatMid = Color(0xFFFFEB3B);
  static const Color heatHigh = Color(0xFFF44336);

  // ── UI Accent ───────────────────────────────────────────
  static const Color accent = Color(0xFF1A237E);
  static const Color accentLight = Color(0xFF3949AB);
  static const Color accentSurface = Color(0xFFE8EAF6);

  // ── XP & Rewards ───────────────────────────────────────
  static const Color xpGold = Color(0xFFFFD600);
  static const Color xpGoldLight = Color(0xFFFFF9C4);

  // ── Surfaces ────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color divider = Color(0xFFE9ECEF);

  // ── Text ────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnAccent = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFE8EAF6);

  // ── Status ──────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Streak ──────────────────────────────────────────────
  static const Color streakFlame = Color(0xFFFF6B35);
  static const Color streakGlow = Color(0x55FF6B35);

  // ── Stamina ─────────────────────────────────────────────
  static const Color staminaFull = Color(0xFF10B981);
  static const Color staminaHalf = Color(0xFFF59E0B);
  static const Color staminaLow = Color(0xFFEF4444);

  // ── Leaderboard ─────────────────────────────────────────
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  /// Generate a unique trail color for other players based on index.
  static Color otherPlayerTrail(int index) {
    const palette = [
      Color(0xFFAB47BC), // purple
      Color(0xFFFF7043), // orange
      Color(0xFF26A69A), // teal
      Color(0xFFEC407A), // pink
      Color(0xFF66BB6A), // green
      Color(0xFFFFCA28), // amber
      Color(0xFF42A5F5), // light blue
      Color(0xFFEF5350), // red
    ];
    return palette[index % palette.length];
  }

  /// Interpolate heatmap color from green → yellow → red.
  static Color heatmapColor(double intensity) {
    assert(intensity >= 0 && intensity <= 1);
    if (intensity < 0.5) {
      return Color.lerp(heatLow, heatMid, intensity * 2)!;
    } else {
      return Color.lerp(heatMid, heatHigh, (intensity - 0.5) * 2)!;
    }
  }
}
