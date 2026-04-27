import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/widgets/itto_curve.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  int _step = 0; // 0,1,2 for splashA/B/C

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _runSplashSequence();
  }

  Future<void> _runSplashSequence() async {
    // Run auth/version checks in parallel with the 3-step animation.
    final navFuture = _checkLoginAndDecide();

    for (int i = 1; i <= 2; i++) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      _controller.reset();
      setState(() => _step = i);
      _controller.forward();
    }
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final destination = await navFuture;
    if (!mounted || destination == null) return;
    context.go(destination);
  }

  Future<String?> _checkLoginAndDecide() async {
    final authProv = ref.read(authChangeNotifierProvider);
    await authProv.checkLoginStatus();

    if (!mounted) return null;
    final needsForceUpdate = await _checkForceUpdate();
    if (needsForceUpdate) return null;

    if (!authProv.isLoggedIn) return '/login';

    final profileProv = ref.read(profileChangeNotifierProvider);
    await profileProv.loadMyProfile();

    final profile = profileProv.myProfile;
    if (profile == null) return '/login';

    if (profile.nickname.isEmpty ||
        profile.gender.isEmpty ||
        profile.birthDate.isEmpty) {
      return '/signup';
    }

    switch (profile.verificationStatus) {
      case 'APPROVED':
      case 'NONE':
        ref.read(notificationChangeNotifierProvider).registerFcmToken();
        return '/home';
      case 'PENDING':
        return '/verification-pending';
      default:
        return '/verification-rejected';
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
    final lines = ['한 번 마주치면 우연,', '두 번 마주치면 필연,', '세 번부터는 인연'];
    final lineMargins = [80.0, 215.0, 235.0];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Curve background — A: top only, B/C: both
          Positioned.fill(
            child: IttoCurve(
              variant: _step == 0
                  ? IttoCurveVariant.top
                  : IttoCurveVariant.both,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Text(
                  'Itto',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 84,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -3,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: lineMargins[_step]),
                FadeTransition(
                  opacity: _fadeIn,
                  child: Text(
                    lines[_step],
                    style: const TextStyle(
                      color: Color(0xFFE8E8E8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                if (_step == 2)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Text(
                      '스친 인연을, 이토로 잇다',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
