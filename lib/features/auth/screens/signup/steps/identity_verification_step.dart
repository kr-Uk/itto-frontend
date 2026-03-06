import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/purple_button.dart';
import '../../../providers/signup_provider.dart';

class IdentityVerificationStep extends StatefulWidget {
  final VoidCallback onNext;

  const IdentityVerificationStep({super.key, required this.onNext});

  @override
  State<IdentityVerificationStep> createState() =>
      _IdentityVerificationStepState();
}

class _IdentityVerificationStepState extends State<IdentityVerificationStep> {
  bool _isVerifying = false;

  Future<void> _startVerification() async {
    setState(() => _isVerifying = true);

    if (AppConfig.isDevMode) {
      // DEV 모드: mock 데이터로 본인인증 통과
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.read<SignupProvider>().setIdentityResult(
              name: '테스트유저',
              phone: '01012345678',
              gender: 'MALE',
              birthDate: '1995-01-01',
            );
      }
    } else {
      // TODO: NICE 본인인증 SDK 연동
    }

    if (mounted) setState(() => _isVerifying = false);
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
            '본인인증을\n진행해 주세요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '안전한 서비스를 위해 본인인증이 필요해요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'NICE 본인인증',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '휴대폰 번호로 본인 확인을 진행합니다.',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '인증 결과로 성별과 생년월일이 자동 입력됩니다.',
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
          const Spacer(),
          Consumer<SignupProvider>(
            builder: (context, provider, _) {
              if (provider.identityVerified) {
                return PurpleButton(text: '다음', onPressed: widget.onNext);
              }
              return PurpleButton(
                text: _isVerifying ? '인증 중...' : '본인인증 시작',
                enabled: !_isVerifying,
                onPressed: _startVerification,
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
