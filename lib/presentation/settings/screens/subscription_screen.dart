import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/widgets/itto_app_bar.dart';
import 'package:itto/presentation/common/widgets/itto_dialog.dart';
import 'package:itto/presentation/common/utils/snackbar_utils.dart';
import 'package:itto/domain/shop/entities/subscription.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shopChangeNotifierProvider).loadSubscription();
    });
  }

  static String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  void _showSubscribeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => IttoDialog(
        title: '프리미엄을 구독하시겠습니까?',
        subtitle: '매달 광고 제거 + 추가 혜택을 받을 수 있습니다.',
        cancelText: '취소',
        confirmText: '구독하기',
        icon: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 32,
          ),
        ),
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: () async {
          Navigator.of(ctx).pop();
          final success = await ref.read(shopChangeNotifierProvider).subscribe();
          if (context.mounted) {
            if (success) {
              SnackBarUtils.showSuccess(context, '프리미엄 구독이 시작되었습니다!');
            } else {
              SnackBarUtils.showError(context, '구독에 실패했습니다.');
            }
          }
        },
      ),
    );
  }

  void _showCancelSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => IttoDialog(
        title: '구독을 해지하시겠습니까?',
        subtitle: '해지하면 프리미엄 혜택이 중단됩니다.',
        cancelText: '취소',
        confirmText: '해지하기',
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: () async {
          Navigator.of(ctx).pop();
          final success = await ref
              .read(shopChangeNotifierProvider)
              .cancelSubscription();
          if (context.mounted) {
            if (success) {
              SnackBarUtils.showSuccess(context, '구독이 해지되었습니다.');
            } else {
              SnackBarUtils.showError(context, '구독 해지에 실패했습니다.');
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(title: '구독하기'),
      body: Consumer(builder: (context, ref, _) { final shopProvider = ref.watch(shopChangeNotifierProvider);
          if (shopProvider.isLoading && shopProvider.subscription == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final sub = shopProvider.subscription;
          if (sub == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: sub.isPremium
                ? _buildSubscribedView(sub)
                : _buildNotSubscribedView(),
          );
        },
      ),
    );
  }

  Widget _buildNotSubscribedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Premium icon
        Center(
          child: ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 64,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Pricing
        Center(
          child: Column(
            children: [
              Text(
                '₩${_formatPrice(9900)}',
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 16,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '런칭특가 ₩${_formatPrice(6900)}/월',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Benefits
        const Text(
          '프리미엄 혜택',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _BenefitItem(icon: Icons.favorite, text: '우연→필연 전환 월6회'),
        const SizedBox(height: 12),
        _BenefitItem(icon: Icons.send, text: '인연 신청 무제한'),
        const SizedBox(height: 12),
        _BenefitItem(icon: Icons.restore, text: '지난 인연 복원 월3회'),
        const SizedBox(height: 12),
        _BenefitItem(icon: Icons.block, text: '광고 제거'),
        const SizedBox(height: 40),

        // Subscribe button
        GestureDetector(
          onTap: () => _showSubscribeDialog(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '프리미엄 구독하기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSubscribedView(SubscriptionInfo sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Premium active card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '프리미엄 구독 중',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (sub.plan != null)
                Text(
                  sub.plan!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (sub.expiresAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  '만료: ${sub.expiresAt}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showCancelSubscriptionDialog(context),
                child: const Text(
                  '구독 취소',
                  style: TextStyle(color: AppColors.error, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Benefits (still shown when subscribed)
        const Text(
          '프리미엄 혜택',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _BenefitItem(icon: Icons.favorite, text: '우연→필연 전환 월6회'),
        const SizedBox(height: 12),
        _BenefitItem(icon: Icons.send, text: '인연 신청 무제한'),
        const SizedBox(height: 12),
        _BenefitItem(icon: Icons.restore, text: '지난 인연 복원 월3회'),
        const SizedBox(height: 12),
        _BenefitItem(icon: Icons.block, text: '광고 제거'),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
