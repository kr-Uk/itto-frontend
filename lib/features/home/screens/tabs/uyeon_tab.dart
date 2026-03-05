import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/utils/snackbar_utils.dart';
import '../../../../shared/widgets/itto_dialog.dart';
import '../../../relationship/providers/relationship_provider.dart';
import '../../../relationship/models/relationship_models.dart';

class UyeonTab extends StatelessWidget {
  const UyeonTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RelationshipProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.getByStatus('UYEON').isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final items = provider.getByStatus('UYEON');

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.explore_outlined,
                  size: 48,
                  color: AppColors.textTertiary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  '아직 우연이 없어요.',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Text(
                  '오늘 마주친 우연 ${items.length}',
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
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  return _UyeonThumbnailCard(item: item);
                }, childCount: items.length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        );
      },
    );
  }
}

class _UyeonThumbnailCard extends StatelessWidget {
  final RelationshipItem item;

  const _UyeonThumbnailCard({required this.item});

  void _showConvertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => IttoDialog(
        title: "'${item.otherUser.nickname}'님의\n프로필을 확인할까요?",
        subtitle: '매듭 30개를 사용합니다.',
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
          ),
          child: const Icon(Icons.lock_open, color: Colors.white, size: 24),
        ),
        cancelText: '취소',
        confirmText: '확인하기',
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: () async {
          Navigator.of(ctx).pop();
          final provider = context.read<RelationshipProvider>();
          final success = await provider.convertTopilyeon(item.relationshipId);
          if (context.mounted) {
            if (success) {
              SnackBarUtils.showSuccess(context, '프로필이 공개되었습니다!');
            } else {
              SnackBarUtils.showError(context, provider.error ?? '요청에 실패했습니다.');
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hashtags = item.hobbies.map((h) => '#${h.name}').toList();

    return GestureDetector(
      onTap: () => _showConvertDialog(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo or gradient placeholder (simulating a blurred/mosaic image)
            _buildPhoto(),
            // Mosaic/blur simulation overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
                child: CustomPaint(
                  painter: _MosaicPainter(baseColor: AppColors.gradientStart),
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
            // Bottom info overlay
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
                      item.otherUser.nickname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hashtags.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        hashtags.join(' '),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
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
      ),
    );
  }

  Widget _buildPhoto() {
    final photoUrl = item.otherUser.representativePhoto;
    if (photoUrl != null && photoUrl.isNotEmpty && !item.otherUser.isMosaic) {
      return CachedNetworkImage(
        imageUrl: photoUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildGradientPlaceholder(),
        errorWidget: (context, url, error) => _buildGradientPlaceholder(),
      );
    }
    return _buildGradientPlaceholder();
  }

  Widget _buildGradientPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
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
    final rng = baseColor.toARGB32();

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

        canvas.drawRect(Rect.fromLTWH(x, y, blockSize, blockSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MosaicPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor;
  }
}
