import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/itto_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(
        title: '설정',
        showBack: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Profile section --
            _SectionLabel(label: '내 프로필'),
            const SizedBox(height: 8),
            _ProfileCard(
              onTap: () => context.push('/profile/edit'),
            ),
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
                  onTap: () {},
                ),
                _SettingsItemData(
                  title: '알림',
                  onTap: () {},
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
                  onTap: () {},
                ),
                _SettingsItemData(
                  title: '구독하기',
                  onTap: () => context.push('/settings/currency'),
                ),
                _SettingsItemData(
                  title: '도움받기',
                  onTap: () {},
                ),
                _SettingsItemData(
                  title: '정보',
                  onTap: () {},
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
              child: const Icon(
                Icons.person,
                color: AppColors.textTertiary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            // Name and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '치맛이',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '남남남',
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
  }
}

// ---------------------------------------------------------------------------
// Highlighted settings item (with purple border accent)
// ---------------------------------------------------------------------------

class _HighlightedSettingsItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _HighlightedSettingsItem({
    required this.title,
    required this.onTap,
  });

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

  const _SettingsItemData({required this.title, required this.onTap});
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

  const _SettingsRow({
    required this.title,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
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
                style: const TextStyle(
                  color: AppColors.textPrimary,
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
