class KnotBalance {
  final int knots;
  final int freeConvertRemaining;
  final int freeRequestRemaining;
  final int freeRestoreRemaining;

  const KnotBalance({
    required this.knots,
    required this.freeConvertRemaining,
    required this.freeRequestRemaining,
    required this.freeRestoreRemaining,
  });

  factory KnotBalance.fromJson(Map<String, dynamic> json) => KnotBalance(
    knots: json['knots'] as int? ?? 0,
    freeConvertRemaining: json['freeConvertRemaining'] as int? ?? 0,
    freeRequestRemaining: json['freeRequestRemaining'] as int? ?? 0,
    freeRestoreRemaining: json['freeRestoreRemaining'] as int? ?? 0,
  );
}

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

  factory KnotPackage.fromJson(Map<String, dynamic> json) => KnotPackage(
    id: json['id'] as int,
    name: json['name'] as String,
    price: json['price'] as int,
    knots: json['knots'] as int,
    firstPurchaseKnots: json['firstPurchaseKnots'] as int? ?? 0,
    isFirstPurchaseUsed: json['isFirstPurchaseUsed'] as bool? ?? false,
  );
}

class PurchaseResponse {
  final int knotsAdded;
  final int totalKnots;
  final bool isFirstPurchaseBonus;
  final String message;

  const PurchaseResponse({
    required this.knotsAdded,
    required this.totalKnots,
    required this.isFirstPurchaseBonus,
    required this.message,
  });

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) =>
      PurchaseResponse(
        knotsAdded: json['knotsAdded'] as int? ?? 0,
        totalKnots: json['totalKnots'] as int? ?? 0,
        isFirstPurchaseBonus: json['isFirstPurchaseBonus'] as bool? ?? false,
        message: json['message'] as String? ?? '',
      );
}

class SubscriptionInfo {
  final bool isPremium;
  final String? plan;
  final int? price;
  final String? startedAt;
  final String? expiresAt;
  final bool isPromotion;
  final SubscriptionBenefits? benefits;

  const SubscriptionInfo({
    required this.isPremium,
    this.plan,
    this.price,
    this.startedAt,
    this.expiresAt,
    this.isPromotion = false,
    this.benefits,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) =>
      SubscriptionInfo(
        isPremium: json['isPremium'] as bool? ?? false,
        plan: json['plan'] as String?,
        price: json['price'] as int?,
        startedAt: json['startedAt'] as String?,
        expiresAt: json['expiresAt'] as String?,
        isPromotion: json['isPromotion'] as bool? ?? false,
        benefits: json['benefits'] != null
            ? SubscriptionBenefits.fromJson(
                json['benefits'] as Map<String, dynamic>,
              )
            : null,
      );
}

class SubscriptionBenefits {
  final int convertPerMonth;
  final bool unlimitedRequests;
  final int freeRestorePerMonth;
  final bool adFree;

  const SubscriptionBenefits({
    required this.convertPerMonth,
    required this.unlimitedRequests,
    required this.freeRestorePerMonth,
    required this.adFree,
  });

  factory SubscriptionBenefits.fromJson(Map<String, dynamic> json) =>
      SubscriptionBenefits(
        convertPerMonth: json['convertPerMonth'] as int? ?? 0,
        unlimitedRequests: json['unlimitedRequests'] as bool? ?? false,
        freeRestorePerMonth: json['freeRestorePerMonth'] as int? ?? 0,
        adFree: json['adFree'] as bool? ?? false,
      );
}
