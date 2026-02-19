import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notification/providers/notification_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../system/services/system_service.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkLoginStatus();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 강제 업데이트 체크
    final needsForceUpdate = await _checkForceUpdate();
    if (needsForceUpdate) return; // 다이얼로그가 표시되므로 네비게이션 중단

    if (!mounted) return;

    if (!authProvider.isLoggedIn) {
      context.go('/login');
      return;
    }

    // 토큰 있음 → 프로필 API로 현재 상태 확인
    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.loadMyProfile();

    if (!mounted) return;

    final profile = profileProvider.myProfile;
    if (profile == null) {
      // 프로필 로드 실패 (토큰 만료 등) → 로그인으로
      context.go('/login');
      return;
    }

    // 프로필 완성 여부 확인
    if (profile.nickname.isEmpty ||
        profile.gender.isEmpty ||
        profile.birthDate.isEmpty) {
      context.go('/signup');
      return;
    }

    // 프로필 완성 → 인증 상태에 따라 분기
    switch (profile.verificationStatus) {
      case 'APPROVED':
        context.read<NotificationProvider>().registerFcmToken();
        context.go('/home');
      case 'PENDING':
        context.go('/verification-pending');
      default: // NONE, REJECTED
        context.go('/verification-rejected');
    }
  }

  /// 서버에서 최소 버전을 확인하고, 현재 앱이 너무 오래됐으면 업데이트 강제
  Future<bool> _checkForceUpdate() async {
    try {
      final tokenStorage = TokenStorage();
      final apiClient = ApiClient.getInstance(tokenStorage: tokenStorage);
      final systemService = SystemService(apiClient);
      final versionInfo = await systemService.checkVersion();
      final packageInfo = await PackageInfo.fromPlatform();

      final currentVersion = packageInfo.version;
      if (_isVersionLowerThan(currentVersion, versionInfo.minVersion)) {
        if (mounted) {
          _showForceUpdateDialog(versionInfo.updateUrl);
        }
        return true;
      }
    } catch (_) {
      // 버전 체크 실패 시 무시하고 진행
    }
    return false;
  }

  /// 시맨틱 버전 비교: current < required 이면 true
  bool _isVersionLowerThan(String current, String required) {
    final c = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final r = required.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (int i = 0; i < 3; i++) {
      final cv = i < c.length ? c[i] : 0;
      final rv = i < r.length ? r[i] : 0;
      if (cv < rv) return true;
      if (cv > rv) return false;
    }
    return false;
  }

  void _showForceUpdateDialog(String? updateUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('업데이트 필요'),
        content: const Text('새로운 버전이 출시되었습니다.\n앱을 업데이트해야 계속 사용할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              if (updateUrl != null && updateUrl.isNotEmpty) {
                launchUrl(Uri.parse(updateUrl), mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('업데이트'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeIn,
        child: Stack(
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
            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                ],
              ),
            ),
          ],
        ),
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
    final centerY = size.height / 2;

    // Draw a flowing curved line with a loop
    final path = Path();
    path.moveTo(centerX - 120, centerY + 80);

    // First curve going up
    path.cubicTo(
      centerX - 80,
      centerY + 20,
      centerX - 40,
      centerY - 60,
      centerX,
      centerY - 40,
    );

    // Loop curve
    path.cubicTo(
      centerX + 30,
      centerY - 25,
      centerX + 40,
      centerY + 15,
      centerX + 10,
      centerY + 20,
    );

    // Continue after loop
    path.cubicTo(
      centerX - 10,
      centerY + 24,
      centerX + 20,
      centerY - 10,
      centerX + 50,
      centerY - 50,
    );

    // Final curve going down
    path.cubicTo(
      centerX + 80,
      centerY - 90,
      centerX + 100,
      centerY - 20,
      centerX + 120,
      centerY + 80,
    );

    canvas.drawPath(path, paint);

    // Second decorative curve (lighter)
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
