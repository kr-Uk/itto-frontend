import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/itto_app_bar.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  // Mock marker data
  static const List<_MapMarker> _markers = [
    _MapMarker(label: '인연 1', x: 0.3, y: 0.35),
    _MapMarker(label: '인연 2', x: 0.55, y: 0.5),
    _MapMarker(label: '인연 3', x: 0.7, y: 0.3),
    _MapMarker(label: '인연 4', x: 0.25, y: 0.65),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(title: '인연 위치 찾기'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // -- Map placeholder --
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.divider,
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Grid lines for visual effect
                        CustomPaint(
                          size: Size(
                              constraints.maxWidth, constraints.maxHeight),
                          painter: _GridPainter(),
                        ),

                        // Center label
                        const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                color: AppColors.textTertiary,
                                size: 48,
                              ),
                              SizedBox(height: 12),
                              Text(
                                '지도가 여기에 표시됩니다',
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'google_maps_flutter 연동 필요',
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Placeholder markers
                        for (final marker in _markers)
                          Positioned(
                            left: constraints.maxWidth * marker.x - 18,
                            top: constraints.maxHeight * marker.y - 40,
                            child: _MarkerWidget(label: marker.label),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // -- Info bar --
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '주변 ${_markers.length}명의 인연이 발견되었어요',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Map marker widget (purple pin)
// ---------------------------------------------------------------------------

class _MarkerWidget extends StatelessWidget {
  final String label;

  const _MarkerWidget({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 3),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Pin triangle
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinTrianglePainter(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pin triangle painter
// ---------------------------------------------------------------------------

class _PinTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Grid painter for map background
// ---------------------------------------------------------------------------

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    // Vertical lines
    for (double x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Map marker data model
// ---------------------------------------------------------------------------

class _MapMarker {
  final String label;
  final double x; // 0.0 - 1.0 fraction of container width
  final double y; // 0.0 - 1.0 fraction of container height

  const _MapMarker({
    required this.label,
    required this.x,
    required this.y,
  });
}
