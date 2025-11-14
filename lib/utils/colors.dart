import 'package:flutter/material.dart';

/// App color palette with blue centered colors
class AppColors {
  // Primary Colors - Blue centered palette
  static const Color primary = Color(0xFF2196F3); // Material Blue
  static const Color primaryLight = Color(0xFF64B5F6); // Lighter Blue
  static const Color primaryDark = Color(0xFF1976D2); // Darker Blue

  // Secondary Colors - Complementary shades
  static const Color secondary = Color(0xFFE3F2FD); // Light Blue
  static const Color secondaryLight = Color(0xFFFFFFFF); // White
  static const Color secondaryDark = Color(0xFFBBDEFB); // Darker Light Blue

  // Accent Colors - Additional blue variations
  static const Color accent = Color(0xFF42A5F5); // Accent Blue
  static const Color accentLight = Color(0xFF90CAF9); // Soft Blue

  // Background Colors - Blue centered backgrounds
  static const Color background = Color(0xFFF5F5F5); // Light gray background
  static const Color cardBackground = Colors.white;
  static const Color surfaceLight = Color(0xFFE3F2FD); // Light blue surface

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  static const Color textWhite = Colors.white;

  // Status Colors - Blue-tinted status colors
  static const Color success = Color(0xFF4CAF50); // Material Green
  static const Color warning = Color(0xFFFF9800); // Material Orange
  static const Color error = Color(0xFFF44336); // Material Red
  static const Color info = Color(0xFF2196F3); // Material Blue

  // Medication Status Colors
  static const Color taken = Color(0xFF4CAF50); // Green
  static const Color missed = Color(0xFFF44336); // Red
  static const Color pending = Color(0xFFFF9800); // Orange
  static const Color skipped = Color(0xFF9E9E9E);

  // Feature-specific Colors - Blue centered shades
  static const Color aiAssistant = Color(0xFF2196F3); // Primary Blue
  static const Color consultation = Color(0xFF42A5F5); // Accent Blue
  static const Color emergency = Color(0xFFF44336); // Red
  static const Color reward = Color(0xFFFF9800); // Orange

  // Gradient Colors - Blue centered gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFE3F2FD)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadow Colors - Blue-tinted shadows
  static const Color shadowLight = Color(0x1A2196F3);
  static const Color shadowMedium = Color(0x332196F3);

  // Divider and Border Colors
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF5F5F5);
}
