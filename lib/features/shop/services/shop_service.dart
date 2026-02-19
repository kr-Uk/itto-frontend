import '../../../core/network/api_client.dart';
import '../models/shop_models.dart';

class ShopService {
  final ApiClient _client;

  ShopService(this._client);

  Future<KnotBalance> getKnots() async {
    final json = await _client.get('/shop/knots');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return KnotBalance.fromJson(data);
  }

  Future<List<KnotPackage>> getPackages() async {
    final json = await _client.get('/shop/packages');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return (data['packages'] as List<dynamic>?)
            ?.map((e) => KnotPackage.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<PurchaseResponse> purchase({
    required int packageId,
    required String receiptToken,
    required String store,
  }) async {
    final json = await _client.post('/shop/purchase', data: {
      'packageId': packageId,
      'receiptToken': receiptToken,
      'store': store,
    });
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return PurchaseResponse.fromJson(data);
  }

  Future<SubscriptionInfo> getSubscription() async {
    final json = await _client.get('/shop/subscription');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return SubscriptionInfo.fromJson(data);
  }

  Future<void> subscribe({
    required String receiptToken,
    required String store,
  }) async {
    await _client.post('/shop/subscription', data: {
      'receiptToken': receiptToken,
      'store': store,
    });
  }

  Future<void> cancelSubscription() async {
    await _client.delete('/shop/subscription');
  }
}
