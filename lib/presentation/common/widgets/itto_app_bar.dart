import 'package:flutter/material.dart';
import 'package:itto/core/theme/app_colors.dart';

class IttoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const IttoAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: showBack
          ? IconButton(
              icon: const _BackChevron(),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              splashRadius: 22,
            )
          : null,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }
}

class _BackChevron extends StatelessWidget {
  const _BackChevron();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(11, 20),
      painter: _ChevronPainter(),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width, 1)
      ..lineTo(1, size.height / 2)
      ..lineTo(size.width, size.height - 1);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
