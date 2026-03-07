import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/widgets/purple_button.dart';
import 'package:itto/presentation/auth/screens/signup/tutorial_screen.dart';

class VerificationWaitingStep extends StatelessWidget {
  final VoidCallback onNext;

  const VerificationWaitingStep({super.key, required this.onNext});

  void _openTutorial(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TutorialScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: onNext,
              child: Text(
                '건너뛰기',
                style: GoogleFonts.notoSansKr(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          const Spacer(flex: 2),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person,
                  size: 56,
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            '조금만 기다려주세요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '승인이 완료되면, 알림을 보내드릴게요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(flex: 3),
          Text(
            '기다리시는 동안, 미리 앱 사용법을 익힐 수 있어요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          PurpleButton(
            text: '튜토리얼 보기',
            onPressed: () => _openTutorial(context),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
