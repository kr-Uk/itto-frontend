import 'package:itto/domain/shop/entities/subscription.dart';
import 'package:itto/domain/shop/repositories/shop_repository.dart';

class ManageSubscriptionUseCase {
  final ShopRepository repository;

  ManageSubscriptionUseCase({required this.repository});

  Future<SubscriptionInfo> getSubscription() => repository.getSubscription();

  Future<void> subscribe({
    required String receiptToken,
    required String store,
  }) =>
      repository.subscribe(receiptToken: receiptToken, store: store);

  Future<void> cancel() => repository.cancelSubscription();
}
