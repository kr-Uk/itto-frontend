import 'package:itto/data/common/models/page_response.dart';
import 'package:itto/domain/notification/entities/notification_item.dart';
import 'package:itto/domain/notification/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase({required this.repository});

  Future<PageResponse<NotificationItem>> execute({
    int page = 0,
    int size = 20,
  }) =>
      repository.getList(page: page, size: size);
}
