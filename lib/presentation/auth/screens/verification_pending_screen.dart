import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/utils/snackbar_utils.dart';

/// 얼굴 인증 승인 대기 화면
/// 프로필 설정은 완료했지만, 관리자의 얼굴 인증 승인을 기다리는 상태에서 표시됩니다.
class VerificationPendingScreen extends ConsumerWidget {
  const VerificationPendingScreen({super.key});

  Future<void> _checkStatus(BuildContext context, WidgetRef ref) async {
    final profileProvider = ref.read(profileChangeNotifierProvider);
    await profileProvider.loadMyProfile();

    if (!context.mounted) return;

    final profile = profileProvider.myProfile;
    if (profile == null) return;

    switch (profile.verificationStatus) {
      case 'APPROVED':
        ref.read(notificationChangeNotifierProvider).registerFcmToken();
        context.go('/home');
      case 'REJECTED':
        context.go('/verification-rejected');
      default:
        SnackBarUtils.showInfo(context, '아직 심사 중입니다. 잠시만 기다려주세요.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(profileChangeNotifierProvider).isLoading;

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
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                '승인 대기 중',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              const Text(
                '프로필 인증이 검토 중입니다.\n승인이 완료되면 앱을 사용할 수 있습니다.\n보통 24시간 이내에 완료됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),

              const Spacer(flex: 2),

              // Refresh button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: isLoading ? null : () => _checkStatus(context, ref),
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
                          : const Text(
                              '승인 상태 확인',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
