import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/purple_button.dart';

class IntroStep extends StatefulWidget {
  final VoidCallback onNext;

  const IntroStep({super.key, required this.onNext});

  @override
  State<IntroStep> createState() => _IntroStepState();
}

class _IntroStepState extends State<IntroStep> {
  final TextEditingController _controller = TextEditingController();
  static const int _maxLength = 15;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            '나를 한 문장으로\n소개해 보세요!',
            style: GoogleFonts.notoSansKr(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '언제든 변경할 수 있어요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          TextField(
            controller: _controller,
            maxLength: _maxLength,
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '소개를 입력해 주세요',
              hintStyle: GoogleFonts.notoSansKr(
                fontSize: 16,
                color: AppColors.textTertiary,
              ),
              counterText: '최대 $_maxLength자',
              counterStyle: GoogleFonts.notoSansKr(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '너무 어렵다면, 지금 쓰지 않아도 괜찮아요.',
                style: GoogleFonts.notoSansKr(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          PurpleButton(
            text: '다음',
            enabled: true,
            onPressed: widget.onNext,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
