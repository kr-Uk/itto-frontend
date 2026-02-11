import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';


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

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/login');
      }
    });
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
