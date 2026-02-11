import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/itto_dialog.dart';
import '../../models/mock_profiles.dart';

class PilyeonTab extends StatelessWidget {
  const PilyeonTab({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = MockProfiles.pilyeonProfiles;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text(
              '오늘 마주친 필연 ${profiles.length}',
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
              '한 번 더 만나면 인연이 될 수 있어요.',
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
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final profile = profiles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _PilyeonProfileCard(profile: profile),
                );
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

class _PilyeonProfileCard extends StatelessWidget {
  final ProfileData profile;

  const _PilyeonProfileCard({required this.profile});

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => IttoDialog(
        title: "'${profile.name}'님은 아직 필연이 아닙니다.",
        subtitle: '인연을 맺기 위해서는 매듭이 필요해요.',
        icon: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceLight,
          ),
          child: const Icon(
            Icons.lock_rounded,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ),
        cancelText: '취소',
        confirmText: '구매하기',
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLockedDialog(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 420,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo placeholder with gradient
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
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
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
                        '${profile.name} | ${profile.intro}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: profile.hashtags.map((tag) {
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
