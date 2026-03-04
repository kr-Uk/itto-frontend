import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/utils/snackbar_utils.dart';
import '../../../../shared/widgets/itto_dialog.dart';
import '../../../relationship/providers/relationship_provider.dart';
import '../../../relationship/models/relationship_models.dart';

class InyeonTab extends StatelessWidget {
  const InyeonTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RelationshipProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.getByStatus('INYEON').isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final items = provider.getByStatus('INYEON');

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 48,
                  color: AppColors.textTertiary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  '아직 인연이 없어요.',
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
                  '나의 인연 ${items.length}',
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
                  '인연의 프로필을 확인해 보세요.',
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
                    child: _InyeonProfileCard(item: item),
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

class _InyeonProfileCard extends StatelessWidget {
  final RelationshipItem item;

  const _InyeonProfileCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final hashtags = item.hobbies.map((h) => '#${h.name}').toList();

    return GestureDetector(
      onTap: () => context.push('/profile/${item.otherUser.userId}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 420,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo or gradient placeholder
              _buildPhoto(),
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
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.otherUser.nickname,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.destinyBadge) ...[
                            const SizedBox(width: 8),
                            Container(
                              key: const Key('destiny_badge'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFEE5A9E),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '운명',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
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
                      _ActionButtons(item: item),
                    ],
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

class _ActionButtons extends StatelessWidget {
  final RelationshipItem item;

  const _ActionButtons({required this.item});

  Future<void> _onChatTap(BuildContext context) async {
    final chatRoomId = item.chatRoomId;
    if (chatRoomId != null && chatRoomId.isNotEmpty) {
      context.push('/chat/$chatRoomId?name=${item.otherUser.nickname}');
    } else {
      SnackBarUtils.showError(context, '아직 채팅방이 생성되지 않았습니다.');
    }
  }

  Future<void> _onDeleteTap(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => IttoDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.primary,
          size: 36,
        ),
        title: '관계를 끝내시겠습니까?',
        subtitle: '이 작업은 되돌릴 수 없습니다.',
        cancelText: '취소',
        confirmText: '끝내기',
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final provider = context.read<RelationshipProvider>();
    final success = await provider.deleteRelationship(item.relationshipId);

    if (!context.mounted) return;

    if (success) {
      SnackBarUtils.showSuccess(context, '관계가 종료되었습니다.');
    } else {
      SnackBarUtils.showError(context, provider.error ?? '관계 종료에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Chat button
        Expanded(
          child: GestureDetector(
            onTap: () => _onChatTap(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '채팅하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Delete button
        GestureDetector(
          onTap: () => _onDeleteTap(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
