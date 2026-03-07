import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/widgets/itto_app_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileChangeNotifierProvider).loadMyProfile();
    });
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '회원탈퇴',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '정말 탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authChangeNotifierProvider).withdraw();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('탈퇴', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(title: '설정', showBack: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Profile section --
            _SectionLabel(label: '내 프로필'),
            const SizedBox(height: 8),
            _ProfileCard(onTap: () => context.push('/profile/edit')),
            const SizedBox(height: 24),

            // -- Features section --
            _SectionLabel(label: '기능'),
            const SizedBox(height: 8),
            _HighlightedSettingsItem(
              title: '인연 범위 설정',
              onTap: () => context.push('/settings/range'),
            ),
            const SizedBox(height: 24),

            // -- Settings section --
            _SectionLabel(label: '설정'),
            const SizedBox(height: 8),
            _SettingsCard(
              items: [
                _SettingsItemData(
                  title: '회원정보',
                  onTap: () => context.push('/profile/edit'),
                ),
                _SettingsItemData(
                  title: '알림',
                  onTap: () => context.push('/settings/notifications'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // -- Info section --
            _SectionLabel(label: '정보'),
            const SizedBox(height: 8),
            _SettingsCard(
              items: [
                _SettingsItemData(
                  title: 'Itto 공유하기',
                  onTap: () {
                    SharePlus.instance.share(
                      ShareParams(
                        text:
                            '스친 인연을 이토로 잇다! Itto 앱을 만나보세요.\nhttps://play.google.com/store/apps/details?id=com.itto.app',
                      ),
                    );
                  },
                ),
                _SettingsItemData(
                  title: '매듭 관리',
                  onTap: () => context.push('/settings/currency'),
                ),
                _SettingsItemData(
                  title: '구독하기',
                  onTap: () => context.push('/settings/subscription'),
                ),
                _SettingsItemData(
                  title: '튜토리얼',
                  onTap: () => context.push('/tutorial'),
                ),
                _SettingsItemData(
                  title: '도움받기',
                  onTap: () {
                    launchUrl(
                      Uri.parse(
                        'mailto:support@hguitto.site?subject=[Itto] 문의사항',
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                _SettingsItemData(
                  title: '정보',
                  onTap: () async {
                    final info = await PackageInfo.fromPlatform();
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text(
                          'Itto',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        content: Text(
                          '버전 ${info.version} (${info.buildNumber})',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _SettingsItemData(
                  title: '로그아웃',
                  onTap: () async {
                    await ref.read(authChangeNotifierProvider).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
                _SettingsItemData(
                  title: '회원탈퇴',
                  onTap: () => _showWithdrawDialog(context),
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile card
// ---------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) { final profileProvider = ref.watch(profileChangeNotifierProvider);
        final profile = profileProvider.myProfile;
        final nickname = profile?.nickname ?? '...';
        final introduction = profile?.introduction ?? '';
        final representativePhoto = profile?.photos
            .where((p) => p.isRepresentative)
            .toList();
        final photoUrl =
            (representativePhoto != null && representativePhoto.isNotEmpty)
            ? representativePhoto.first.url
            : (profile?.photos.isNotEmpty == true
                  ? profile!.photos.first.url
                  : null);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceLight,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: photoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: photoUrl,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Icon(
                              Icons.person,
                              color: AppColors.textTertiary,
                              size: 28,
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.person,
                              color: AppColors.textTertiary,
                              size: 28,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: AppColors.textTertiary,
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                // Name and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nickname,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        introduction,
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                  size: 22,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Highlighted settings item (with purple border accent)
// ---------------------------------------------------------------------------

class _HighlightedSettingsItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _HighlightedSettingsItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grouped settings card
// ---------------------------------------------------------------------------

class _SettingsItemData {
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsItemData({
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingsItemData> items;

  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _SettingsRow(
              title: items[i].title,
              onTap: items[i].onTap,
              isFirst: i == 0,
              isLast: i == items.length - 1,
              isDestructive: items[i].isDestructive,
            ),
            if (i < items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: AppColors.divider,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;
  final bool isDestructive;

  const _SettingsRow({
    required this.title,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? Colors.red : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
