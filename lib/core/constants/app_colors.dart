import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary purple palette
  static const Color primary = Color(0xFF6D3FC8);
  static const Color primaryLight = Color(0xFF8D5CF6);
  static const Color primaryDark = Color(0xFF45227E);
  static const Color primarySurface = Color(0xFFF2ECFF);

  // Accent
  static const Color accent = Color(0xFFB083F0);
  static const Color accentLight = Color(0xFFE9D8FD);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAF8FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFEAE5F4);

  // Text
  static const Color textPrimary = Color(0xFF181125);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textHint = Color(0xFF9CA3AF);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSurface = Color(0xFFDBEAFE);

  // Order status colors
  static const Color statusPlaced = Color(0xFF3B82F6);
  static const Color statusAccepted = Color(0xFF8B5CF6);
  static const Color statusPreparing = Color(0xFFF59E0B);
  static const Color statusReady = Color(0xFF22C55E);
  static const Color statusDelivering = Color(0xFF06B6D4);
  static const Color statusDelivered = Color(0xFF22C55E);
  static const Color statusCancelled = Color(0xFFEF4444);

  // Divider & border
  static const Color divider = Color(0xFFEAE5F4);
  static const Color border = Color(0xFFE7E1F2);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C3FC5), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFB083F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
