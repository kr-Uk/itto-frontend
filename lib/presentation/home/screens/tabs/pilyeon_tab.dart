import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/utils/snackbar_utils.dart';
import 'package:itto/presentation/common/widgets/itto_dialog.dart';
import 'package:itto/domain/relationship/entities/relationship.dart';

class PilyeonTab extends ConsumerWidget {
  const PilyeonTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(builder: (context, ref, _) { final provider = ref.watch(relationshipChangeNotifierProvider);
        final pilyeonItems = provider.getByStatus('PILYEON');
        final pendingItems = provider.getByStatus('PENDING');
        final allItems = [...pendingItems, ...pilyeonItems];

        if (provider.isLoading && allItems.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (allItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 48,
                  color: AppColors.textTertiary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  '아직 필연이 없어요.',
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
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 4),
                child: Text(
                  '오늘 마주친 필연 ${allItems.length}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Text(
                  '한 번 더 마주치면 인연이 될 수 있어요.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = allItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _PilyeonProfileCard(item: item),
                  );
                }, childCount: allItems.length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        );
      },
    );
  }
}

class _PilyeonProfileCard extends ConsumerWidget {
  final Relationship item;

  const _PilyeonProfileCard({required this.item});

  void _showRequestInyeonDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => IttoDialog(
        title: "'${item.otherUser.nickname}'님에게\n인연을 요청하시겠습니까?",
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
          ),
          child: const Icon(Icons.favorite, color: Colors.white, size: 24),
        ),
        cancelText: '취소',
        confirmText: '요청하기',
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: () async {
          Navigator.of(ctx).pop();
          final provider = ref.read(relationshipChangeNotifierProvider);
          final success = await provider.requestInyeon(item.relationshipId);
          if (context.mounted) {
            if (success) {
              SnackBarUtils.showSuccess(context, '인연 요청을 보냈습니다.');
            } else {
              SnackBarUtils.showError(context, '요청에 실패했습니다.');
            }
          }
        },
      ),
    );
  }

  String _formatRemainingTime(String expiresAt) {
    try {
      final expiry = DateTime.parse(expiresAt);
      final now = DateTime.now();
      final diff = expiry.difference(now);
      if (diff.isNegative) return '만료됨';
      if (diff.inHours > 0) return '${diff.inHours}시간 남음';
      if (diff.inMinutes > 0) return '${diff.inMinutes}분 남음';
      return '곧 만료';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hashtags = item.hobbies.map((h) => '#${h.name}').toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 420,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo or gradient placeholder
            _buildPhoto(),
            // Lock overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            // Expiry countdown badge
            if (item.expiresAt != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatRemainingTime(item.expiresAt!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            // Bottom dark overlay with profile info
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.4, 1.0],
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hashtags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: hashtags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push(
                              '/profile/${item.otherUser.userId}',
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  '프로필 보기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (item.status == 'PENDING')
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  '요청 대기중',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showRequestInyeonDialog(context, ref),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.buttonGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    '인연 요청',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photoUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
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
          size: 80,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
