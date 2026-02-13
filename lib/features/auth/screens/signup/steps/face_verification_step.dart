import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/utils/snackbar_utils.dart';
import '../../../../../shared/widgets/purple_button.dart';
import '../../../providers/signup_provider.dart';

class FaceVerificationStep extends StatefulWidget {
  final VoidCallback onNext;

  const FaceVerificationStep({super.key, required this.onNext});

  @override
  State<FaceVerificationStep> createState() => _FaceVerificationStepState();
}

class _FaceVerificationStepState extends State<FaceVerificationStep> {
  bool _verified = false;
  String? _capturedImagePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _startVerification() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (photo != null) {
        setState(() {
          _capturedImagePath = photo.path;
          _verified = true;
        });

        // Update SignupProvider with the captured image path
        if (mounted) {
          context.read<SignupProvider>().verificationFilePath = photo.path;
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, '카메라를 실행하는 중 오류가 발생했습니다: ${e.toString()}');
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImagePath = null;
      _verified = false;
    });
    context.read<SignupProvider>().verificationFilePath = null;
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
            child: _capturedImagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_capturedImagePath!),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
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
          if (_verified && _capturedImagePath != null) ...[
            PurpleButton(
              text: '다시 찍기',
              onPressed: _retakePhoto,
            ),
            const SizedBox(height: 12),
          ],
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
