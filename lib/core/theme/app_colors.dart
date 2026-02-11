import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  static const Color primary = Color(0xFF9B7BFF);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color accent = Color(0xFFB794F6);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color divider = Color(0xFF2D2D2D);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color gradientStart = Color(0xFFE8A0BF);
  static const Color gradientEnd = Color(0xFFB794F6);
  static const Color chatBubbleReceived = Color(0xFF2A2A2A);
  static const Color chatBubbleSent = Color(0xFF3A3A3A);
  static const Color unreadBadge = Color(0xFF9B7BFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF9B7BFF), Color(0xFFB794F6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
