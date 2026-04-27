import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itto/core/theme/app_colors.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 1; // home is the default

  // 채팅 · 홈 · 알림 · 설정 (matches prototype tab order)
  static const _routes = ['/chat', '/home', '/notifications', '/settings'];

  void _onTap(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
      context.go(_routes[index]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    final idx = _routes.indexWhere((r) => location.startsWith(r));
    if (idx != -1 && idx != _currentIndex) {
      setState(() => _currentIndex = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <_TabSpec>[
      _TabSpec(label: '채팅', builder: _chatIcon),
      _TabSpec(label: '홈', builder: _homeIcon),
      _TabSpec(label: '알림', builder: _notiIcon),
      _TabSpec(label: '설정', builder: _settingsIcon),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 78,
          decoration: const BoxDecoration(
            color: AppColors.tabBarBackground,
            border: Border(
              top: BorderSide(color: Color(0x0FFFFFFF), width: 0.5),
            ),
          ),
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(items.length, (i) {
              final isActive = i == _currentIndex;
              final color = isActive
                  ? AppColors.accent
                  : AppColors.textSecondary;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onTap(i),
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      items[i].builder(color),
                      const SizedBox(height: 6),
                      Text(
                        items[i].label,
                        style: TextStyle(color: color, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _chatIcon(Color c) => CustomPaint(
    size: const Size(22, 22),
    painter: _ChatBubblePainter(color: c),
  );
  Widget _homeIcon(Color c) =>
      Icon(Icons.home_rounded, color: c, size: 24);
  Widget _notiIcon(Color c) => CustomPaint(
    size: const Size(20, 22),
    painter: _BellPainter(color: c),
  );
  Widget _settingsIcon(Color c) =>
      Icon(Icons.settings, color: c, size: 22);
}

class _TabSpec {
  final String label;
  final Widget Function(Color color) builder;
  _TabSpec({required this.label, required this.builder});
}

class _ChatBubblePainter extends CustomPainter {
  final Color color;
  _ChatBubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round;
    final s = size.width / 22;
    final path = Path()
      ..moveTo(3 * s, 10 * s)
      ..cubicTo(3 * s, 6.7 * s, 6.6 * s, 4 * s, 11 * s, 4 * s)
      ..cubicTo(15.4 * s, 4 * s, 19 * s, 6.7 * s, 19 * s, 10 * s)
      ..cubicTo(19 * s, 13.3 * s, 15.4 * s, 16 * s, 11 * s, 16 * s)
      ..cubicTo(10 * s, 16 * s, 9 * s, 15.9 * s, 8.1 * s, 15.6 * s)
      ..lineTo(4 * s, 18 * s)
      ..lineTo(5.4 * s, 14.5 * s)
      ..cubicTo(4 * s, 13.3 * s, 3 * s, 11.7 * s, 3 * s, 10 * s)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChatBubblePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _BellPainter extends CustomPainter {
  final Color color;
  _BellPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width / 20;
    final h = size.height / 22;
    final body = Path()
      ..moveTo(10 * w, 2 * h)
      ..cubicTo(13.3 * w, 2 * h, 16 * w, 4.7 * h, 16 * w, 8 * h)
      ..lineTo(16 * w, 11 * h)
      ..lineTo(17.5 * w, 14 * h)
      ..lineTo(2.5 * w, 14 * h)
      ..lineTo(4 * w, 11 * h)
      ..lineTo(4 * w, 8 * h)
      ..cubicTo(4 * w, 4.7 * h, 6.7 * w, 2 * h, 10 * w, 2 * h)
      ..close();
    canvas.drawPath(body, paint);
    final handle = Path()
      ..moveTo(8 * w, 18 * h)
      ..cubicTo(8 * w, 19 * h, 9 * w, 20 * h, 10 * w, 20 * h)
      ..cubicTo(11 * w, 20 * h, 12 * w, 19 * h, 12 * w, 18 * h);
    canvas.drawPath(handle, paint);
  }

  @override
  bool shouldRepaint(covariant _BellPainter oldDelegate) =>
      oldDelegate.color != color;
}
