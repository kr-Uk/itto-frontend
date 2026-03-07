class KnotPackage {
  final int id;
  final String name;
  final int price;
  final int knots;
  final int firstPurchaseKnots;
  final bool isFirstPurchaseUsed;

  const KnotPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.knots,
    required this.firstPurchaseKnots,
    required this.isFirstPurchaseUsed,
  });
}
