import 'package:itto/domain/shop/entities/knot_package.dart';

class KnotPackageModel {
  final int id;
  final String name;
  final int price;
  final int knots;
  final int firstPurchaseKnots;
  final bool isFirstPurchaseUsed;

  const KnotPackageModel({
    required this.id,
    required this.name,
    required this.price,
    required this.knots,
    required this.firstPurchaseKnots,
    required this.isFirstPurchaseUsed,
  });

  factory KnotPackageModel.fromJson(Map<String, dynamic> json) =>
      KnotPackageModel(
        id: json['id'] as int,
        name: json['name'] as String,
        price: json['price'] as int,
        knots: json['knots'] as int,
        firstPurchaseKnots: json['firstPurchaseKnots'] as int? ?? 0,
        isFirstPurchaseUsed: json['isFirstPurchaseUsed'] as bool? ?? false,
      );

  KnotPackage toEntity() => KnotPackage(
        id: id,
        name: name,
        price: price,
        knots: knots,
        firstPurchaseKnots: firstPurchaseKnots,
        isFirstPurchaseUsed: isFirstPurchaseUsed,
      );
}
