import '../../../core/network/api_client.dart';
import '../../../shared/models/page_response.dart';
import '../models/notification_models.dart';

class NotificationService {
  final ApiClient _client;

  NotificationService(this._client);

  Future<PageResponse<NotificationItem>> getList({
    int page = 0,
    int size = 20,
  }) async {
    final json = await _client.get(
      '/notifications',
      queryParameters: {'page': page, 'size': size},
    );
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return PageResponse.fromJson(data, NotificationItem.fromJson);
  }

  Future<void> markRead(List<int> notificationIds) async {
    await _client.put(
      '/notifications/read',
      data: {'notificationIds': notificationIds},
    );
  }

  Future<void> deleteAll() async {
    await _client.delete('/notifications');
  }

  Future<void> updateFcmToken({
    required String fcmToken,
    required String deviceId,
  }) async {
    await _client.put(
      '/fcm/token',
      data: {'fcmToken': fcmToken, 'deviceId': deviceId},
    );
  }
}
