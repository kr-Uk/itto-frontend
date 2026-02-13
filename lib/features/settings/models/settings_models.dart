class MatchingSettings {
  final String? genderFilter;
  final int ageRangeMin;
  final int ageRangeMax;

  const MatchingSettings({
    this.genderFilter,
    required this.ageRangeMin,
    required this.ageRangeMax,
  });

  factory MatchingSettings.fromJson(Map<String, dynamic> json) =>
      MatchingSettings(
        genderFilter: json['genderFilter'] as String?,
        ageRangeMin: json['ageRangeMin'] as int? ?? 20,
        ageRangeMax: json['ageRangeMax'] as int? ?? 35,
      );

  Map<String, dynamic> toJson() => {
        'genderFilter': genderFilter,
        'ageRangeMin': ageRangeMin,
        'ageRangeMax': ageRangeMax,
      };
}

class NotificationSettings {
  final bool chatNotification;
  final bool relationshipNotification;
  final bool statsNotification;
  final bool marketingNotification;

  const NotificationSettings({
    required this.chatNotification,
    required this.relationshipNotification,
    required this.statsNotification,
    required this.marketingNotification,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        chatNotification: json['chatNotification'] as bool? ?? true,
        relationshipNotification:
            json['relationshipNotification'] as bool? ?? true,
        statsNotification: json['statsNotification'] as bool? ?? true,
        marketingNotification: json['marketingNotification'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'chatNotification': chatNotification,
        'relationshipNotification': relationshipNotification,
        'statsNotification': statsNotification,
        'marketingNotification': marketingNotification,
      };
}
