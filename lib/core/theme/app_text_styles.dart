import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for Territory Run.
///
/// Uses Inter font family via GoogleFonts for consistency.
class AppTextStyles {
  AppTextStyles._();

  // ── Display ─────────────────────────────────────────────
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  // ── Headlines ───────────────────────────────────────────
  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Titles ──────────────────────────────────────────────
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Body ────────────────────────────────────────────────
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ── Labels ──────────────────────────────────────────────
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  // ── HUD Stats (top bar) ────────────────────────────────
  static TextStyle hudStatValue = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle hudStatLabel = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  // ── Territory Popup ────────────────────────────────────
  static TextStyle territoryPopupTitle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle territoryPopupSubtitle = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // ── Run HUD (large, readable stats) ────────────────────
  static TextStyle runTimer = GoogleFonts.inter(
    fontSize: 52,
    fontWeight: FontWeight.w700,
    letterSpacing: -2,
    color: AppColors.textPrimary,
  );

  static TextStyle runStat = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle runStatLabel = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  // ── Leaderboard rank ───────────────────────────────────
  static TextStyle rankNumber = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
  );

  static TextStyle score = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.xpGold,
  );
}
