import 'package:itto/domain/shop/entities/knot_balance.dart';
import 'package:itto/domain/shop/entities/knot_package.dart';
import 'package:itto/domain/shop/entities/purchase_result.dart';
import 'package:itto/domain/shop/entities/subscription.dart';

abstract class ShopRepository {
  Future<KnotBalance> getKnots();
  Future<List<KnotPackage>> getPackages();
  Future<PurchaseResult> purchase({
    required int packageId,
    required String receiptToken,
    required String store,
  });
  Future<SubscriptionInfo> getSubscription();
  Future<void> subscribe({
    required String receiptToken,
    required String store,
  });
  Future<void> cancelSubscription();
}
