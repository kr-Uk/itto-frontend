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
}
