import 'package:itto/domain/notification/entities/notification_item.dart';

class NotificationItemModel {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? deepLink;
  final int? referenceId;
  final String createdAt;

  const NotificationItemModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.deepLink,
    this.referenceId,
    required this.createdAt,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) =>
      NotificationItemModel(
        id: json['id'] as int,
        type: json['type'] as String,
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        isRead: json['isRead'] as bool? ?? false,
        deepLink: json['deepLink'] as String?,
        referenceId: json['referenceId'] as int?,
        createdAt: json['createdAt'] as String? ?? '',
      );

  NotificationItem toEntity() => NotificationItem(
        id: id,
        type: type,
        title: title,
        message: message,
        isRead: isRead,
        deepLink: deepLink,
        referenceId: referenceId,
        createdAt: createdAt,
      );
}
