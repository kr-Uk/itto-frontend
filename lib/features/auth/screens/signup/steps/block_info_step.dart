import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/purple_button.dart';

class BlockInfoStep extends StatelessWidget {
  final VoidCallback onNext;

  const BlockInfoStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            '만나고 싶지 않은 인연은\n언제든지 차단\n가능해요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '차단된 사용자에게는 회원님의 프로필이\n노출되지 않아요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.accent.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.block_outlined,
                size: 52,
                color: AppColors.primary,
              ),
            ),
          ),
          const Spacer(),
          PurpleButton(
            text: '다음',
            onPressed: onNext,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
