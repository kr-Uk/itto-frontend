import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/utils/snackbar_utils.dart';
import '../../../../shared/widgets/itto_dialog.dart';
import '../../../relationship/providers/relationship_provider.dart';
import '../../../relationship/models/relationship_models.dart';

class PastInyeonTab extends StatelessWidget {
  const PastInyeonTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RelationshipProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.getByStatus('PAST').isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final items = provider.getByStatus('PAST');

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: AppColors.textTertiary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  '아직 지난 인연이 없어요.',
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
                  '지난 인연 ${items.length}',
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
                  '매듭을 사용하여 지난 인연을 다시 만날 수 있어요.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _PastProfileCard(item: item),
                  );
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

class _PastProfileCard extends StatelessWidget {
  final RelationshipItem item;

  const _PastProfileCard({required this.item});

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => IttoDialog(
        title: "'${item.otherUser.nickname}'님과\n다시 만나시겠습니까?",
        subtitle: '매듭을 사용하여 인연을 복원합니다.',
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
          ),
          child: const Icon(Icons.refresh, color: Colors.white, size: 24),
        ),
        cancelText: '취소',
        confirmText: '다시 만나기',
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: () async {
          Navigator.of(ctx).pop();
          final provider = context.read<RelationshipProvider>();
          final success = await provider.restoreRelationship(
            item.relationshipId,
          );
          if (context.mounted) {
            if (success) {
              SnackBarUtils.showSuccess(context, '다시 만나기 요청을 보냈습니다.');
            } else {
              SnackBarUtils.showError(context, '요청에 실패했습니다.');
            }
            if (success) {
              provider.loadAllTabs();
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/profile/${item.otherUser.userId}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildPhoto(),
              Container(color: Colors.black.withValues(alpha: 0.3)),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.otherUser.nickname,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      GestureDetector(
                        onTap: () => _showRestoreDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Text(
                            '다시 만나기',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '지난 인연',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        color: Colors.black.withValues(alpha: 0.3),
        colorBlendMode: BlendMode.darken,
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
          colors: [
            AppColors.gradientStart.withValues(alpha: 0.5),
            AppColors.gradientEnd.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 48,
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
