import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/itto_app_bar.dart';
import '../../../shared/widgets/itto_dialog.dart';
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
    });
  }

  void _showPurchaseDialog(BuildContext context, KnotPackage pkg) {
    showDialog(
      context: context,
      builder: (ctx) => IttoDialog(
        title: '${pkg.knots}매듭을 구매할까요?',
        subtitle: '${formatPrice(pkg.price)}원이 결제됩니다.',
        cancelText: '취소',
        confirmText: '확인',
        icon: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: const Icon(Icons.favorite, color: Colors.white, size: 32),
        ),
        onConfirm: () {
          Navigator.of(ctx).pop(true);
          context.read<ShopProvider>().purchase(pkg.id);
        },
      ),
    );
  }

  static String formatPrice(int price) {
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
                        color: AppColors.primary,
                      ),
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
                  _UsageRow(amount: '30개', description: '우연을 인연으로 풀기'),
                  SizedBox(height: 8),
                  _UsageRow(amount: '30개', description: '지난 인연 다시 만나기'),
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
// Purchase card with package name and first-purchase badge
// ---------------------------------------------------------------------------

class _PurchaseCard extends StatelessWidget {
  final KnotPackage package;
  final VoidCallback onTap;

  const _PurchaseCard({required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final showFirstPurchaseBadge = !package.isFirstPurchaseUsed;

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
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.primaryGradient.createShader(bounds),
              child: const Icon(Icons.favorite, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (showFirstPurchaseBadge) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '첫 구매 2배',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    showFirstPurchaseBadge
                        ? '${package.knots} → ${package.firstPurchaseKnots} 매듭'
                        : '${package.knots} 매듭',
                    style: TextStyle(
                      color: showFirstPurchaseBadge
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\u20A9${_CurrencyScreenState.formatPrice(package.price)}',
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

  const _UsageRow({required this.amount, required this.description});

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
