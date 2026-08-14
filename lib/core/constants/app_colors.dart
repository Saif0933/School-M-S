import 'package:flutter/material.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Symbosys SMS — Premium Color Palette
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppColors {
  AppColors._();

  // ─── Brand Primary ───────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B85FF);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primarySurface = Color(0x1A6C63FF);

  // ─── Brand Secondary ─────────────────────────
  static const Color secondary = Color(0xFF06D6A0);
  static const Color secondaryLight = Color(0xFF34E4B8);
  static const Color secondaryDark = Color(0xFF04B886);

  // ─── Accent Colors ───────────────────────────
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentAmber = Color(0xFFFFBE0B);
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentPink = Color(0xFFE040FB);

  // ─── Dark Theme Colors ───────────────────────
  static const Color darkBg = Color(0xFF0F0F23);
  static const Color darkSurface = Color(0xFF1A1A36);
  static const Color darkCard = Color(0xFF232347);
  static const Color darkCardHover = Color(0xFF2D2D5A);
  static const Color darkBorder = Color(0xFF2E2E52);
  static const Color darkDivider = Color(0xFF1E1E3F);

  // ─── Light Theme Colors ──────────────────────
  static const Color lightBg = Color(0xFFF8F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardHover = Color(0xFFF0F1F5);
  static const Color lightBorder = Color(0xFFE2E4EB);
  static const Color lightDivider = Color(0xFFEEEFF3);

  // ─── Text Colors ─────────────────────────────
  static const Color darkTextPrimary = Color(0xFFF1F1F8);
  static const Color darkTextSecondary = Color(0xFFA0A0C0);
  static const Color darkTextTertiary = Color(0xFF6B6B90);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF5A5A78);
  static const Color lightTextTertiary = Color(0xFF9A9AB0);

  // ─── Semantic Colors ─────────────────────────
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFBE0B);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF00D4FF);

  // ─── Gradients ───────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF06D6A0), Color(0xFF04B886)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFE040FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF232347), Color(0xFF1A1A36)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sidebarGradient = LinearGradient(
    colors: [Color(0xFF0F0F23), Color(0xFF1A1A36)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Stat Card Gradients ─────────────────────
  static const LinearGradient statStudents = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8B85FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient statStaff = LinearGradient(
    colors: [Color(0xFF06D6A0), Color(0xFF34E4B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient statRevenue = LinearGradient(
    colors: [Color(0xFFFFBE0B), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient statAttendance = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Glass Effect Colors ─────────────────────
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassShadow = Color(0x1A000000);
}
