import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/snackbar_utils.dart';
import '../../notification/providers/notification_provider.dart';
import '../providers/auth_provider.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _handleLogin(BuildContext context, String provider) async {
    final authProvider = context.read<AuthProvider>();

    bool success;
    switch (provider) {
      case 'GOOGLE':
        success = await authProvider.loginWithGoogle();
        break;
      case 'APPLE':
        success = await authProvider.loginWithApple();
        break;
      case 'KAKAO':
        success = await authProvider.loginWithKakao();
        break;
      default:
        return;
    }

    if (!context.mounted) return;

    if (success) {
      if (authProvider.isNewUser) {
        context.go('/signup');
      } else {
        // 기존 사용자 로그인 → FCM 토큰 등록
        context.read<NotificationProvider>().registerFcmToken();
        context.go('/home');
      }
    } else if (authProvider.error != null) {
      SnackBarUtils.showError(context, authProvider.error!);
      authProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Gradient blob at bottom
          Positioned(
            bottom: -60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 320,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(160),
                  gradient: const RadialGradient(
                    colors: [
                      Color(0x66E8A0BF),
                      Color(0x33B794F6),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.5, 1.0],
                    radius: 0.8,
                  ),
                ),
              ),
            ),
          ),
          // Decorative curved line art
          Positioned.fill(
            child: CustomPaint(
              painter: _CurvedLinePainter(),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                // Logo and subtitle
                Text(
                  'Itto',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 60,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '스친 인연을, 이토로 잇다',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const Spacer(flex: 3),
                // Social login buttons
                Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: isLoading
                      ? const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialLoginButton(
                              backgroundColor: const Color(0xFFFEE500),
                              onTap: () => _handleLogin(context, 'KAKAO'),
                              child: Text(
                                'TALK',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            _SocialLoginButton(
                              backgroundColor: Colors.black,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              onTap: () => _handleLogin(context, 'APPLE'),
                              child: const Icon(
                                Icons.apple,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 24),
                            _SocialLoginButton(
                              backgroundColor: Colors.white,
                              onTap: () => _handleLogin(context, 'GOOGLE'),
                              child: Text(
                                'G',
                                style: GoogleFonts.roboto(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  height: 1.0,
                                ),
                              ),
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

class _SocialLoginButton extends StatelessWidget {
  final Color backgroundColor;
  final BoxBorder? border;
  final Widget child;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.backgroundColor,
    this.border,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _CurvedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final centerY = size.height * 0.42;

    final path = Path();
    path.moveTo(centerX - 120, centerY + 80);
    path.cubicTo(
      centerX - 80,
      centerY + 20,
      centerX - 40,
      centerY - 60,
      centerX,
      centerY - 40,
    );
    path.cubicTo(
      centerX + 30,
      centerY - 25,
      centerX + 40,
      centerY + 15,
      centerX + 10,
      centerY + 20,
    );
    path.cubicTo(
      centerX - 10,
      centerY + 24,
      centerX + 20,
      centerY - 10,
      centerX + 50,
      centerY - 50,
    );
    path.cubicTo(
      centerX + 80,
      centerY - 90,
      centerX + 100,
      centerY - 20,
      centerX + 120,
      centerY + 80,
    );
    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path2 = Path();
    path2.moveTo(centerX - 140, centerY + 100);
    path2.cubicTo(
      centerX - 60,
      centerY,
      centerX + 60,
      centerY - 80,
      centerX + 140,
      centerY + 100,
    );
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
