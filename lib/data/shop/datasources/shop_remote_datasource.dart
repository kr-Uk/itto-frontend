import 'package:itto/core/network/api_client.dart';
import 'package:itto/data/shop/models/knot_balance_model.dart';
import 'package:itto/data/shop/models/knot_package_model.dart';
import 'package:itto/data/shop/models/purchase_response_model.dart';
import 'package:itto/data/shop/models/subscription_model.dart';

class ShopRemoteDataSource {
  final ApiClient _client;

  ShopRemoteDataSource(this._client);

  Future<KnotBalanceModel> getKnots() async {
    final json = await _client.get('/shop/knots');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return KnotBalanceModel.fromJson(data);
  }

  Future<List<KnotPackageModel>> getPackages() async {
    final json = await _client.get('/shop/packages');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return (data['packages'] as List<dynamic>?)
            ?.map((e) => KnotPackageModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<PurchaseResponseModel> purchase({
    required int packageId,
    required String receiptToken,
    required String store,
  }) async {
    final json = await _client.post(
      '/shop/purchase',
      data: {
        'packageId': packageId,
        'receiptToken': receiptToken,
        'store': store,
      },
    );
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return PurchaseResponseModel.fromJson(data);
  }

  Future<SubscriptionInfoModel> getSubscription() async {
    final json = await _client.get('/shop/subscription');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return SubscriptionInfoModel.fromJson(data);
  }

  Future<void> subscribe({
    required String receiptToken,
    required String store,
  }) async {
    await _client.post(
      '/shop/subscription',
      data: {'receiptToken': receiptToken, 'store': store},
    );
  }

  Future<void> cancelSubscription() async {
    await _client.delete('/shop/subscription');
  }
}
