import 'package:itto/domain/common/entities/page_response.dart';
import 'package:itto/domain/notification/entities/notification_item.dart';

abstract class NotificationRepository {
  Future<PageResponse<NotificationItem>> getList({int page, int size});
  Future<void> markRead(List<int> notificationIds);
  Future<void> deleteAll();
  Future<void> updateFcmToken({
    required String fcmToken,
    required String deviceId,
  });
}
