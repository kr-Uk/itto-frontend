import 'package:itto/domain/settings/entities/notification_settings.dart';

class NotificationSettingsModel {
  final bool chatNotification;
  final bool relationshipNotification;
  final bool statsNotification;
  final bool marketingNotification;

  const NotificationSettingsModel({
    required this.chatNotification,
    required this.relationshipNotification,
    required this.statsNotification,
    required this.marketingNotification,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) =>
      NotificationSettingsModel(
        chatNotification: json['chatNotification'] as bool? ?? true,
        relationshipNotification:
            json['relationshipNotification'] as bool? ?? true,
        statsNotification: json['statsNotification'] as bool? ?? true,
        marketingNotification: json['marketingNotification'] as bool? ?? false,
      );

  factory NotificationSettingsModel.fromEntity(
    NotificationSettings entity,
  ) =>
      NotificationSettingsModel(
        chatNotification: entity.chatNotification,
        relationshipNotification: entity.relationshipNotification,
        statsNotification: entity.statsNotification,
        marketingNotification: entity.marketingNotification,
      );

  Map<String, dynamic> toJson() => {
        'chatNotification': chatNotification,
        'relationshipNotification': relationshipNotification,
        'statsNotification': statsNotification,
        'marketingNotification': marketingNotification,
      };

  NotificationSettings toEntity() => NotificationSettings(
        chatNotification: chatNotification,
        relationshipNotification: relationshipNotification,
        statsNotification: statsNotification,
        marketingNotification: marketingNotification,
      );
}
