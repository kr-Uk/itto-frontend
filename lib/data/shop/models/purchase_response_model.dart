import 'package:itto/domain/shop/entities/purchase_result.dart';

class PurchaseResponseModel {
  final int knotsAdded;
  final int totalKnots;
  final bool isFirstPurchaseBonus;
  final String message;

  const PurchaseResponseModel({
    required this.knotsAdded,
    required this.totalKnots,
    required this.isFirstPurchaseBonus,
    required this.message,
  });

  factory PurchaseResponseModel.fromJson(Map<String, dynamic> json) =>
      PurchaseResponseModel(
        knotsAdded: json['knotsAdded'] as int? ?? 0,
        totalKnots: json['totalKnots'] as int? ?? 0,
        isFirstPurchaseBonus: json['isFirstPurchaseBonus'] as bool? ?? false,
        message: json['message'] as String? ?? '',
      );

  PurchaseResult toEntity() => PurchaseResult(
        knotsAdded: knotsAdded,
        totalKnots: totalKnots,
        isFirstPurchaseBonus: isFirstPurchaseBonus,
        message: message,
      );
}
