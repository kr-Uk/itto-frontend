import 'package:flutter/material.dart';
import 'package:itto/core/theme/app_colors.dart';

/// Decorative 두 가닥의 인연 곡선이 화면 위/아래로 흐르는 배경.
/// Prototype 의 IttoCurve SVG 와 동일한 path 를 따라 그린다.
class IttoCurve extends StatelessWidget {
  final double opacity;
  final IttoCurveVariant variant;

  const IttoCurve({
    super.key,
    this.opacity = 1.0,
    this.variant = IttoCurveVariant.both,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: SizedBox.expand(
          child: CustomPaint(painter: _IttoCurvePainter(variant: variant)),
        ),
      ),
    );
  }
}

enum IttoCurveVariant { both, top, bottom }

class _IttoCurvePainter extends CustomPainter {
  final IttoCurveVariant variant;
  _IttoCurvePainter({required this.variant});

  @override
  void paint(Canvas canvas, Size size) {
    // viewBox 0 0 414 600 → scale to size.
    final sx = size.width / 414;
    final sy = size.height / 600;

    final shader = AppColors.curveGradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    if (variant == IttoCurveVariant.both || variant == IttoCurveVariant.top) {
      final top = Path()
        ..moveTo(-50 * sx, 230 * sy)
        ..quadraticBezierTo(207 * sx, 70 * sy, 470 * sx, 240 * sy);
      canvas.drawPath(top, paint);
    }
    if (variant == IttoCurveVariant.both ||
        variant == IttoCurveVariant.bottom) {
      final bottom = Path()
        ..moveTo(-50 * sx, 320 * sy)
        ..quadraticBezierTo(207 * sx, 480 * sy, 470 * sx, 300 * sy);
      canvas.drawPath(bottom, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _IttoCurvePainter oldDelegate) =>
      oldDelegate.variant != variant;
}
