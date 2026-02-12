import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/purple_button.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          SizedBox(
            width: 260,
            height: 260,
            child: CustomPaint(
              painter: _CelebrationPainter(),
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 56,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '환영합니다.',
            style: GoogleFonts.notoSansKr(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '이토로 스쳐간 인연들을 찾아보세요!',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(flex: 3),
          PurpleButton(
            text: '시작하기',
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _CelebrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 16; i++) {
      final angle = i * pi / 8;
      final innerRadius = 85.0 + (i % 3) * 5;
      final outerRadius = 105.0 + (i % 2) * 15;

      paint.color = i % 2 == 0
          ? AppColors.primary.withValues(alpha: 0.5)
          : AppColors.gradientStart.withValues(alpha: 0.4);

      final start = Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      final end = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );

      canvas.drawLine(start, end, paint);
    }

    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4 + pi / 8;
      const radius = 115.0;
      final dotCenter = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      paint.color = i % 2 == 0
          ? AppColors.primary.withValues(alpha: 0.3)
          : AppColors.gradientStart.withValues(alpha: 0.3);
      canvas.drawCircle(dotCenter, 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
