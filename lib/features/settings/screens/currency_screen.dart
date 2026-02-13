import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/itto_app_bar.dart';
import '../../../shared/widgets/itto_dialog.dart';
import '../../../shared/utils/snackbar_utils.dart';
import '../../shop/providers/shop_provider.dart';
import '../../shop/models/shop_models.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopProvider = context.read<ShopProvider>();
      shopProvider.loadBalance();
      shopProvider.loadPackages();
      shopProvider.loadSubscription();
    });
  }

  void _showPurchaseDialog(BuildContext context, KnotPackage pkg) {
    showDialog(
      context: context,
      builder: (ctx) => IttoDialog(
        title: '${pkg.knots}매듭을 구매할까요?',
        subtitle: '${_formatPrice(pkg.price)}원이 결제됩니다.',
        cancelText: '취소',
        confirmText: '확인',
        icon: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: const Icon(
            Icons.favorite,
            color: Colors.white,
            size: 32,
          ),
        ),
        onConfirm: () {
          Navigator.of(ctx).pop(true);
          context.read<ShopProvider>().purchase(pkg.id);
        },
      ),
    );
  }

  static String _formatPrice(int price) {
    // Simple thousands separator
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
          final success =
              await context.read<ShopProvider>().subscribe();
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
          final success =
              await context.read<ShopProvider>().cancelSubscription();
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
      appBar: const IttoAppBar(title: '매듭 관리'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Balance card --
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Heart icon with gradient
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '나의 매듭',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<ShopProvider>(
                    builder: (context, shopProvider, _) {
                      final knots = shopProvider.knots;
                      return ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.primaryGradient.createShader(bounds),
                        child: Text(
                          '$knots 매듭',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // -- Subscription section --
            Consumer<ShopProvider>(
              builder: (context, shopProvider, _) {
                final sub = shopProvider.subscription;
                if (sub == null) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '구독 정보',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: sub.isPremium
                            ? Border.all(
                                color: AppColors.primary.withValues(alpha: 0.5))
                            : null,
                      ),
                      child: sub.isPremium
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.workspace_premium,
                                        color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '프리미엄 구독 중',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (sub.expiresAt != null)
                                  Text(
                                    '만료: ${sub.expiresAt}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                // Cancel button
                                GestureDetector(
                                  onTap: () =>
                                      _showCancelSubscriptionDialog(context),
                                  child: const Text(
                                    '구독 해지',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                const Text(
                                  '프리미엄을 구독하고 더 많은 혜택을 받아보세요',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () =>
                                      _showSubscribeDialog(context),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.buttonGradient,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '구독하기',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),

            // -- Purchase section --
            const Text(
              '구매하기',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Consumer<ShopProvider>(
              builder: (context, shopProvider, _) {
                if (shopProvider.isLoading && shopProvider.packages.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final pkg in shopProvider.packages) ...[
                      _PurchaseCard(
                        package: pkg,
                        onTap: () => _showPurchaseDialog(context, pkg),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // -- Usage info --
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '매듭 사용 안내',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  _UsageRow(amount: '20개', description: '우연을 인연으로 풀기'),
                  SizedBox(height: 8),
                  _UsageRow(amount: '150개', description: '지난 인연 다시 만나기'),
                  SizedBox(height: 8),
                  _UsageRow(amount: '250개', description: '한달 동안 광고 제거'),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Purchase card
// ---------------------------------------------------------------------------

class _PurchaseCard extends StatelessWidget {
  final KnotPackage package;
  final VoidCallback onTap;

  const _PurchaseCard({
    required this.package,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Heart icon
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.primaryGradient.createShader(bounds),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Amount and price
            Expanded(
              child: Text(
                '${package.knots} 매듭',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '\u20A9${_CurrencyScreenState._formatPrice(package.price)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Usage info row
// ---------------------------------------------------------------------------

class _UsageRow extends StatelessWidget {
  final String amount;
  final String description;

  const _UsageRow({
    required this.amount,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            amount,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
