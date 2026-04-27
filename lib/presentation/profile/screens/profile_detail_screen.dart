import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/widgets/itto_app_bar.dart';
import 'package:itto/presentation/common/widgets/itto_dialog.dart';
import 'package:itto/presentation/common/utils/snackbar_utils.dart';
import 'package:itto/domain/block/entities/report_request.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  final int userId;

  const ProfileDetailScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileChangeNotifierProvider).loadOtherProfile(widget.userId);
    });
  }

  @override
  void dispose() {
    // Don't clear in dispose since provider outlives this widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: IttoAppBar(
        title: '프로필',
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'block') {
                _handleBlock(context);
              } else if (value == 'report') {
                _handleReport(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 20, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text(
                      '차단하기',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report, size: 20, color: AppColors.error),
                    SizedBox(width: 8),
                    Text(
                      '신고하기',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer(builder: (context, ref, _) { final provider = ref.watch(profileChangeNotifierProvider);
          if (provider.isLoading && provider.otherProfile == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final profile = provider.otherProfile;
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_off,
                    color: AppColors.textTertiary,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    provider.error ?? '프로필을 불러올 수 없습니다',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero photo — full bleed, with gradient overlay + nickname/age over photo
                if (profile.photos.isNotEmpty)
                  SizedBox(
                    height: 480,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        profile.photos.first.isMosaic
                            ? _buildMosaicPhoto()
                            : CachedNetworkImage(
                                imageUrl: profile.photos.first.url,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  color: AppColors.surfaceLight,
                                ),
                                errorWidget: (_, _, _) => Container(
                                  color: AppColors.surfaceLight,
                                  child: const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                        // Bottom gradient overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [
                                  Colors.black.withValues(alpha: 0.7),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.4],
                              ),
                            ),
                          ),
                        ),
                        // Name + last seen
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.age != null
                                    ? '${profile.nickname}, ${profile.age}'
                                    : profile.nickname,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (profile.encounterCount != null &&
                                  profile.encounterCount! > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '마주친 횟수 ${profile.encounterCount}회',
                                  style: const TextStyle(
                                    color: Color(0xFFD8D8D8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Introduction
                if (profile.introduction != null &&
                    profile.introduction!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '한 줄 소개',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          profile.introduction!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Hobbies
                if (profile.hobbies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '취미',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.hobbies.map((hobby) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                '#${hobby.name}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Additional photos
                if (profile.photos.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: profile.photos.length - 1,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, index) {
                          final photo = profile.photos[index + 1];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 120,
                              child: photo.isMosaic
                                  ? _buildMosaicPhoto()
                                  : CachedNetworkImage(
                                      imageUrl: photo.url,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, _, _) => Container(
                                        color: AppColors.surfaceLight,
                                        child: const Icon(
                                          Icons.image,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Encounter info + relationship actions
                Builder(
                  builder: (context) {
                    final relItem = ref
                        .read(relationshipChangeNotifierProvider)
                        .findByOtherUserId(widget.userId);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chat button for INYEON — peach→purple pill
                          if (relItem != null &&
                              relItem.chatRoomId != null &&
                              relItem.status == 'INYEON') ...[
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => context.push(
                                '/chat/${relItem.chatRoomId}?name=${relItem.otherUser.nickname}',
                              ),
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: AppColors.pillGradient,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x40A78BFA),
                                      blurRadius: 20,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  '대화 시작하기',
                                  style: TextStyle(
                                    color: AppColors.pillText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleBlock(BuildContext context) async {
    final profile = ref.read(profileChangeNotifierProvider).otherProfile;
    if (profile == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => IttoDialog(
        title: "'${profile.nickname}'님을 차단하시겠습니까?",
        subtitle: '차단하면 서로 매칭되지 않습니다.',
        confirmText: '차단',
        cancelText: '취소',
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final blockProvider = ref.read(blockChangeNotifierProvider);
    final success = await blockProvider.blockUser(widget.userId);

    if (!context.mounted) return;

    if (success) {
      SnackBarUtils.showSuccess(context, '차단되었습니다');
      context.pop();
    } else {
      SnackBarUtils.showError(context, blockProvider.error ?? '차단에 실패했습니다');
    }
  }

  Future<void> _handleReport(BuildContext context) async {
    final profile = ref.read(profileChangeNotifierProvider).otherProfile;
    if (profile == null) return;

    final category = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text(
          '신고 사유 선택',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        children:
            {
                  'INAPPROPRIATE_PHOTO': '부적절한 사진/프로필',
                  'HARASSMENT': '성희롱/스토킹',
                  'SPAM': '스팸/광고',
                  'PROFANITY': '욕설/혐오 발언',
                  'OTHER': '기타',
                }.entries
                .map(
                  (entry) => SimpleDialogOption(
                    onPressed: () => Navigator.of(context).pop(entry.key),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );

    if (category == null || !context.mounted) return;

    final blockProvider = ref.read(blockChangeNotifierProvider);
    final success = await blockProvider.report(
      ReportRequest(
        targetUserId: widget.userId,
        category: category,
        targetType: 'PROFILE',
      ),
    );

    if (!context.mounted) return;

    if (success) {
      SnackBarUtils.showSuccess(context, '신고가 접수되었습니다');
    } else {
      SnackBarUtils.showError(context, blockProvider.error ?? '신고에 실패했습니다');
    }
  }

  Widget _buildMosaicPhoto() {
    return Container(
      color: AppColors.surfaceLight,
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.person,
              size: 80,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.45),
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
