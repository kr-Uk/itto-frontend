import 'package:itto/domain/notification/repositories/notification_repository.dart';

class MarkNotificationsReadUseCase {
  final NotificationRepository repository;

  MarkNotificationsReadUseCase({required this.repository});

  Future<void> execute(List<int> notificationIds) =>
      repository.markRead(notificationIds);
}
