import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/purple_button.dart';

class FaceVerificationStep extends StatefulWidget {
  final VoidCallback onNext;

  const FaceVerificationStep({super.key, required this.onNext});

  @override
  State<FaceVerificationStep> createState() => _FaceVerificationStepState();
}

class _FaceVerificationStepState extends State<FaceVerificationStep> {
  bool _verified = false;

  void _startVerification() {
    // TODO: 실제 카메라 촬영 및 얼굴 인증 구현
    // 현재는 바로 인증 완료 처리
    setState(() => _verified = true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _verified ? Icons.check_circle : Icons.person,
              size: 64,
              color: _verified ? AppColors.success : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            '안전한 이토를 위해\n본인 인증이 필요해요.',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansKr(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const Spacer(flex: 3),
          PurpleButton(
            text: _verified ? '다음' : '실시간 얼굴 인증하기',
            onPressed: _verified ? widget.onNext : _startVerification,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
