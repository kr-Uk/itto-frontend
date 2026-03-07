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
}
