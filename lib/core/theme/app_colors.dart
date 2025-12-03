import 'package:flutter/material.dart';

/// App color constants following the design system
class AppColors {
  // Primary Colors
  // static const Color primary = Color(0xFF1976D2); // Blue
  static const Color primaryLight = Color(0xFFBBDEFB);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primary = Color(0xFFFFA726); // Orange

  // Gradient Colors
  static const Color yellow = Color(0xFFFFEB3B); // Yellow
  static const LinearGradient orangeYellowGradient = LinearGradient(
    colors: [Color(0xFFFFA726), Color(0xFFFFEB3B)], // Orange to Yellow
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary Colors
  static const Color secondary = Color(0xff0000FF); //dark blue
  static const Color secondaryLight = Color(0xFFFFE0B2);
  static const Color secondaryDark = Color(0xFFC7780);

  // Status Colors
  static const Color error = Color(0xFFD32F2F); // Red
  static const Color success = Color(0xFF388E3C); // Green
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color warning = Color(0xFFF57C00); // Orange
  static const Color info = Color(0xFF1976D2); // Blue

  // Background Colors
  static const Color background = Color(0xFFF5F5F5); // Light Grey
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceDim = Color(0xFFFAFAFA);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Dark Grey
  static const Color textSecondary = Color(0xFF757575); // Medium Grey
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Badge Colors
  static const Color statusNew = Color(0xFF2196F3); // Blue
  static const Color statusInProgress = Color(0xFFFFA726); // Orange
  static const Color statusSuccess = Color(0xFF4CAF50); // Green
  static const Color statusFailed = Color(0xFFF44336); // Red
  static const Color statusPending = Color(0xFF9E9E9E); // Grey
  static const Color statusSent = Color(0xFF2196F3); // Blue

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFFBDBDBD);

  // Divider
  static const Color divider = Color(0xFFE0E0E0);

  // Shadow
  static const Color shadow = Color(0x1F000000);
}
