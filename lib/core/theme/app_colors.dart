import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Background tones (prototype palette) ──────────────
  static const Color background = Color(0xFF262626);
  static const Color surface = Color(0xFF1F1F1F);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  static const Color card = Color(0xFF181818);
  static const Color cardBackground = Color(0xFF1F1F1F);
  static const Color tabBarBackground = Color(0xFF1A1A1A);

  // ─── Brand accent ──────────────────────────────────────
  static const Color primary = Color(0xFFA78BFA);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color accent = Color(0xFFA78BFA);

  // ─── Text ──────────────────────────────────────────────
  static const Color textPrimary = Colors.white;
  static const Color textMid = Color(0xFFC8C8C8);
  static const Color textSecondary = Color(0xFF9D9D9D);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color pillText = Color(0xFF3D2D52);

  // ─── Lines ─────────────────────────────────────────────
  static const Color divider = Color(0x1AFFFFFF); // rgba(255,255,255,0.1)
  static const Color dividerSoft = Color(0x14FFFFFF);

  // ─── Status ────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);

  // ─── Chat ──────────────────────────────────────────────
  static const Color chatBubbleReceived = Color(0xFF2A2A2A);
  static const Color chatBubbleSent = Color(0xFF3A3A3A);
  static const Color unreadBadge = Color(0xFFA78BFA);

  // ─── Pill gradient (peach → lavender → purple) ────────
  // Matches prototype: linear-gradient(135deg, #FBE3CF 0%, #DAC8F0 60%, #B8A3E5 100%)
  static const LinearGradient pillGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
    colors: [Color(0xFFFBE3CF), Color(0xFFDAC8F0), Color(0xFFB8A3E5)],
  );

  // ─── Itto curve gradient (peach → lavender → deep) ────
  static const LinearGradient curveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [Color(0xFFE8B89C), Color(0xFFC9A4D8), Color(0xFF7A6FBF)],
  );

  // ─── Legacy aliases (kept so existing code keeps compiling) ──
  static const Color gradientStart = Color(0xFFFBE3CF);
  static const Color gradientEnd = Color(0xFFB8A3E5);

  static const LinearGradient primaryGradient = pillGradient;
  static const LinearGradient buttonGradient = pillGradient;
}
