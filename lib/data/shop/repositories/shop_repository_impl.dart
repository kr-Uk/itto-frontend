import 'package:itto/domain/shop/entities/knot_balance.dart';
import 'package:itto/domain/shop/entities/knot_package.dart';
import 'package:itto/domain/shop/entities/purchase_result.dart';
import 'package:itto/domain/shop/entities/subscription.dart';
import 'package:itto/domain/shop/repositories/shop_repository.dart';
import 'package:itto/data/shop/datasources/shop_remote_datasource.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource remoteDataSource;

  ShopRepositoryImpl({required this.remoteDataSource});

  @override
  Future<KnotBalance> getKnots() async {
    final model = await remoteDataSource.getKnots();
    return model.toEntity();
  }

  @override
  Future<List<KnotPackage>> getPackages() async {
    final models = await remoteDataSource.getPackages();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<PurchaseResult> purchase({
    required int packageId,
    required String receiptToken,
    required String store,
  }) async {
    final model = await remoteDataSource.purchase(
      packageId: packageId,
      receiptToken: receiptToken,
      store: store,
    );
    return model.toEntity();
  }

  @override
  Future<SubscriptionInfo> getSubscription() async {
    final model = await remoteDataSource.getSubscription();
    return model.toEntity();
  }

  @override
  Future<void> subscribe({
    required String receiptToken,
    required String store,
  }) =>
      remoteDataSource.subscribe(receiptToken: receiptToken, store: store);

  @override
  Future<void> cancelSubscription() => remoteDataSource.cancelSubscription();
}
