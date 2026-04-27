import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/utils/snackbar_utils.dart';
import 'package:itto/presentation/common/widgets/itto_curve.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  Future<void> _handleLogin(
    BuildContext context,
    WidgetRef ref,
    String provider,
  ) async {
    final authProv = ref.read(authChangeNotifierProvider);

    bool success;
    switch (provider) {
      case 'GOOGLE':
        success = await authProv.loginWithGoogle();
        break;
      case 'APPLE':
        success = await authProv.loginWithApple();
        break;
      case 'KAKAO':
        success = await authProv.loginWithKakao();
        break;
      default:
        return;
    }

    if (!context.mounted) return;

    if (success) {
      if (authProv.isNewUser) {
        context.go('/signup');
      } else {
        switch (authProv.verificationStatus) {
          case 'APPROVED':
          case 'NONE':
            ref.read(notificationChangeNotifierProvider).registerFcmToken();
            context.go('/home');
          case 'PENDING':
            context.go('/verification-pending');
          default:
            context.go('/verification-rejected');
        }
      }
    } else if (authProv.error != null) {
      SnackBarUtils.showError(context, authProv.error!);
      authProv.clearError();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authChangeNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: IttoCurve(opacity: 0.35)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 140),
                Text(
                  'Itto',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 90,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -3,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '스친 인연을, 이토로 잇다',
                  style: TextStyle(
                    color: Color(0xFFD8D8D8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 80),
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            _SocialButton(
                              label: '카카오로 시작하기',
                              backgroundColor: const Color(0xFFFEE500),
                              foregroundColor: const Color(0xFF191919),
                              icon: Image.asset(
                                'assets/images/kakao.png',
                                width: 20,
                                height: 18,
                              ),
                              onTap: () =>
                                  _handleLogin(context, ref, 'KAKAO'),
                            ),
                            const SizedBox(height: 12),
                            _SocialButton(
                              label: '구글로 시작하기',
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF111111),
                              icon: Image.asset(
                                'assets/images/google.png',
                                width: 18,
                                height: 18,
                              ),
                              onTap: () =>
                                  _handleLogin(context, ref, 'GOOGLE'),
                            ),
                            const SizedBox(height: 12),
                            _SocialButton(
                              label: 'Apple로 시작하기',
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                                width: 1,
                              ),
                              icon: Image.asset(
                                'assets/images/apple1.png',
                                width: 16,
                                height: 20,
                              ),
                              onTap: () =>
                                  _handleLogin(context, ref, 'APPLE'),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final BoxBorder? border;
  final Widget icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.border,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

