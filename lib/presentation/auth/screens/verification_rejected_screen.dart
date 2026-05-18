import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/utils/snackbar_utils.dart';
import 'package:itto/presentation/common/widgets/itto_dialog.dart';

/// 얼굴 인증 거부/미인증 화면
/// 얼굴 인증이 거부(REJECTED)되었거나 아직 제출하지 않은(NONE) 상태에서 표시됩니다.
/// 사용자는 셀카를 촬영하여 재인증을 요청할 수 있습니다.
class VerificationRejectedScreen extends ConsumerWidget {
  const VerificationRejectedScreen({super.key});

  Future<void> _handleReverify(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (photo == null || !context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const IttoDialog(
        title: '인증 사진을 제출하시겠습니까?',
        subtitle: '촬영한 셀카로 본인 인증을 진행합니다.',
        confirmText: '제출',
        cancelText: '취소',
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final profileProvider = ref.read(profileChangeNotifierProvider);
    final success = await profileProvider.reverify(photo.path);

    if (!context.mounted) return;

    if (success) {
      SnackBarUtils.showSuccess(context, '인증 사진이 제출되었습니다');
      context.go('/verification-pending');
    } else {
      SnackBarUtils.showError(context, profileProvider.error ?? '제출에 실패했습니다');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(profileChangeNotifierProvider).isLoading;
    final profile = ref.watch(profileChangeNotifierProvider).myProfile;
    final isRejected = profile?.verificationStatus == 'REJECTED';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isRejected ? AppColors.error : AppColors.primary)
                      .withValues(alpha: 0.15),
                ),
                child: Icon(
                  isRejected
                      ? Icons.cancel_outlined
                      : Icons.verified_user_outlined,
                  size: 48,
                  color: isRejected ? AppColors.error : AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                isRejected ? '인증이 거부되었습니다' : '본인 인증이 필요합니다',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                isRejected
                    ? '제출하신 사진이 인증 기준에 맞지 않습니다.\n아래 버튼을 눌러 셀카를 다시 촬영해주세요.'
                    : '앱을 사용하려면 본인 인증이 필요합니다.\n아래 버튼을 눌러 셀카를 촬영해주세요.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              // Tips
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '인증 사진 촬영 팁',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    _TipRow(text: '정면을 바라보며 얼굴이 잘 보이게'),
                    _TipRow(text: '밝은 곳에서 촬영'),
                    _TipRow(text: '모자, 마스크, 선글라스 미착용'),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Re-verify button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: isLoading ? null : () => _handleReverify(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isRejected ? '셀카 다시 촬영' : '셀카 촬영하기',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Logout button
              TextButton(
                onPressed: () async {
                  await ref.read(authChangeNotifierProvider).logout();
                  if (context.mounted) context.go('/login');
                },
                child: const Text(
                  '로그아웃',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;
  const _TipRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 14, color: AppColors.success),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
