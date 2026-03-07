import 'package:itto/domain/shop/entities/purchase_result.dart';
import 'package:itto/domain/shop/repositories/shop_repository.dart';

class PurchaseKnotsUseCase {
  final ShopRepository repository;

  PurchaseKnotsUseCase({required this.repository});

  Future<PurchaseResult> execute({
    required int packageId,
    required String receiptToken,
    required String store,
  }) =>
      repository.purchase(
        packageId: packageId,
        receiptToken: receiptToken,
        store: store,
      );
}
