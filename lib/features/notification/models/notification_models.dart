class NotificationItem {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? deepLink;
  final int? referenceId;
  final String createdAt;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.deepLink,
    this.referenceId,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as int,
        type: json['type'] as String,
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        isRead: json['isRead'] as bool? ?? false,
        deepLink: json['deepLink'] as String?,
        referenceId: json['referenceId'] as int?,
        createdAt: json['createdAt'] as String? ?? '',
      );
}
