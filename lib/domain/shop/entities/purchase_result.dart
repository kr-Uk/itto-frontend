class PurchaseResult {
  final int knotsAdded;
  final int totalKnots;
  final bool isFirstPurchaseBonus;
  final String message;

  const PurchaseResult({
    required this.knotsAdded,
    required this.totalKnots,
    required this.isFirstPurchaseBonus,
    required this.message,
  });
}
