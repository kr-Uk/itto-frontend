import 'package:itto/domain/shop/entities/subscription.dart';

class SubscriptionInfoModel {
  final bool isPremium;
  final String? plan;
  final int? price;
  final String? startedAt;
  final String? expiresAt;
  final bool isPromotion;
  final SubscriptionBenefitsModel? benefits;

  const SubscriptionInfoModel({
    required this.isPremium,
    this.plan,
    this.price,
    this.startedAt,
    this.expiresAt,
    this.isPromotion = false,
    this.benefits,
  });

  factory SubscriptionInfoModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionInfoModel(
        isPremium: json['isPremium'] as bool? ?? false,
        plan: json['plan'] as String?,
        price: json['price'] as int?,
        startedAt: json['startedAt'] as String?,
        expiresAt: json['expiresAt'] as String?,
        isPromotion: json['isPromotion'] as bool? ?? false,
        benefits: json['benefits'] != null
            ? SubscriptionBenefitsModel.fromJson(
                json['benefits'] as Map<String, dynamic>,
              )
            : null,
      );

  SubscriptionInfo toEntity() => SubscriptionInfo(
        isPremium: isPremium,
        plan: plan,
        price: price,
        startedAt: startedAt,
        expiresAt: expiresAt,
        isPromotion: isPromotion,
        benefits: benefits?.toEntity(),
      );
}

class SubscriptionBenefitsModel {
  final int convertPerMonth;
  final bool unlimitedRequests;
  final int freeRestorePerMonth;
  final bool adFree;

  const SubscriptionBenefitsModel({
    required this.convertPerMonth,
    required this.unlimitedRequests,
    required this.freeRestorePerMonth,
    required this.adFree,
  });

  factory SubscriptionBenefitsModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionBenefitsModel(
        convertPerMonth: json['convertPerMonth'] as int? ?? 0,
        unlimitedRequests: json['unlimitedRequests'] as bool? ?? false,
        freeRestorePerMonth: json['freeRestorePerMonth'] as int? ?? 0,
        adFree: json['adFree'] as bool? ?? false,
      );

  SubscriptionBenefits toEntity() => SubscriptionBenefits(
        convertPerMonth: convertPerMonth,
        unlimitedRequests: unlimitedRequests,
        freeRestorePerMonth: freeRestorePerMonth,
        adFree: adFree,
      );
}
