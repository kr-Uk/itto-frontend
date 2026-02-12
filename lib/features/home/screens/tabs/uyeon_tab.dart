import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/mock_profiles.dart';

class UyeonTab extends StatelessWidget {
  const UyeonTab({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = MockProfiles.uyeonProfiles;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text(
              '오늘 마주친 우연 ${profiles.length}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              '한번 스쳐간 인연, 두번 더 만나면 인연이 될 수 있어요.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final profile = profiles[index];
                return _UyeonThumbnailCard(profile: profile);
              },
              childCount: profiles.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class _UyeonThumbnailCard extends StatelessWidget {
  final ProfileData profile;

  const _UyeonThumbnailCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo placeholder with gradient (simulating a blurred/mosaic image)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: profile.photoGradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          // Mosaic/blur simulation overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: CustomPaint(
                painter: _MosaicPainter(
                  baseColor: profile.photoGradientColors.first,
                ),
              ),
            ),
          ),
          // Lock icon centered
          Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.45),
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          // Bottom info overlay: 닉네임 + 취미 + 한줄소개
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (profile.hashtags.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      profile.hashtags.join(' '),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (profile.intro.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      profile.intro,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a simple mosaic/pixelation effect to simulate blurred photos.
class _MosaicPainter extends CustomPainter {
  final Color baseColor;

  _MosaicPainter({required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    const blockSize = 20.0;
    final rng = baseColor.value;

    for (double x = 0; x < size.width; x += blockSize) {
      for (double y = 0; y < size.height; y += blockSize) {
        // Create pseudo-random color variation based on position
        final seed = ((x * 7 + y * 13 + rng) % 255).toInt();
        final variation = (seed % 60) - 30;
        final r = (baseColor.r * 255 + variation).clamp(0, 255).toInt();
        final g = (baseColor.g * 255 + variation ~/ 2).clamp(0, 255).toInt();
        final b = (baseColor.b * 255 - variation).clamp(0, 255).toInt();

        final paint = Paint()
          ..color = Color.fromARGB(80, r, g, b)
          ..style = PaintingStyle.fill;

        canvas.drawRect(
          Rect.fromLTWH(x, y, blockSize, blockSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MosaicPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor;
  }
}
