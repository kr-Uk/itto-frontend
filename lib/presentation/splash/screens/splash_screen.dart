import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:itto/core/di/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
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
    final authProv = ref.read(authChangeNotifierProvider);
    await authProv.checkLoginStatus();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Force update check
    final needsForceUpdate = await _checkForceUpdate();
    if (needsForceUpdate) return;

    if (!mounted) return;

    if (!authProv.isLoggedIn) {
      context.go('/login');
      return;
    }

    final profileProv = ref.read(profileChangeNotifierProvider);
    await profileProv.loadMyProfile();

    if (!mounted) return;

    final profile = profileProv.myProfile;
    if (profile == null) {
      context.go('/login');
      return;
    }

    if (profile.nickname.isEmpty ||
        profile.gender.isEmpty ||
        profile.birthDate.isEmpty) {
      context.go('/signup');
      return;
    }

    switch (profile.verificationStatus) {
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

  Future<bool> _checkForceUpdate() async {
    try {
      final systemRepository = ref.read(systemRepositoryProvider);
      final versionInfo = await systemRepository.checkVersion();
      final packageInfo = await PackageInfo.fromPlatform();

      final currentVersion = packageInfo.version;
      if (_isVersionLowerThan(currentVersion, versionInfo.minVersion)) {
        if (mounted) {
          _showForceUpdateDialog(versionInfo.updateUrl);
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

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
                launchUrl(
                  Uri.parse(updateUrl),
                  mode: LaunchMode.externalApplication,
                );
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
            Positioned.fill(child: CustomPaint(painter: _CurvedLinePainter())),
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

    final path = Path();
    path.moveTo(centerX - 120, centerY + 80);
    path.cubicTo(centerX - 80, centerY + 20, centerX - 40, centerY - 60, centerX, centerY - 40);
    path.cubicTo(centerX + 30, centerY - 25, centerX + 40, centerY + 15, centerX + 10, centerY + 20);
    path.cubicTo(centerX - 10, centerY + 24, centerX + 20, centerY - 10, centerX + 50, centerY - 50);
    path.cubicTo(centerX + 80, centerY - 90, centerX + 100, centerY - 20, centerX + 120, centerY + 80);
    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path2 = Path();
    path2.moveTo(centerX - 140, centerY + 100);
    path2.cubicTo(centerX - 60, centerY, centerX + 60, centerY - 80, centerX + 140, centerY + 100);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
