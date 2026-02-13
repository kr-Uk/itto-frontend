import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 앱 전체에서 통일된 SnackBar를 표시하기 위한 유틸리티.
class SnackBarUtils {
  SnackBarUtils._();

  /// 성공 메시지 (보라색 배경)
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppColors.primary);
  }

  /// 에러 메시지 (빨간 배경)
  static void showError(BuildContext context, String message) {
    _show(context, message, AppColors.error);
  }

  /// 정보 메시지 (회색 배경)
  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppColors.textSecondary);
  }

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
