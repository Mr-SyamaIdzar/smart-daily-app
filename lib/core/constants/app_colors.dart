import 'package:flutter/material.dart';

/// Semua konstanta warna aplikasi dipusatkan di sini.
/// Gunakan AppColors.xxx di seluruh codebase — jangan hardcode hex di widget.
abstract class AppColors {
  // === Primary Palette (Claude Orange Style) ===
  static const Color primary = Color(0xFFD97706);       // Warm Orange 600
  static const Color primaryLight = Color(0xFFF59E0B);  // Amber 500
  static const Color primaryDark = Color(0xFF92400E);   // Orange Brown 800

  // === Secondary Palette ===
  static const Color secondary = Color(0xFFFFEDD5);     // Soft warm background
  static const Color secondaryLight = Color(0xFFFFF7ED);
  static const Color secondaryDark = Color(0xFFFB923C);

  // === Surface & Background ===
  static const Color background = Color(0xFFFFFBF5);    // Warm off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFFF3E0);

  // === Text Colors ===
  static const Color textPrimary = Color(0xFF1C1917);   // Warm dark
  static const Color textSecondary = Color(0xFF78716C);
  static const Color textHint = Color(0xFFA8A29E);

  // === Status Colors ===
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0EA5E9);

  // === Border & Divider ===
  static const Color border = Color(0xFFFED7AA);
  static const Color divider = Color(0xFFFFEDD5);

  // === Gradient ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFF7C2D12)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}