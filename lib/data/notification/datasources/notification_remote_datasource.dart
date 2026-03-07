import 'package:itto/core/network/api_client.dart';
import 'package:itto/data/common/models/page_response.dart';
import 'package:itto/data/notification/models/notification_item_model.dart';

class NotificationRemoteDataSource {
  final ApiClient _client;

  NotificationRemoteDataSource(this._client);

  Future<PageResponse<NotificationItemModel>> getList({
    int page = 0,
    int size = 20,
  }) async {
    final json = await _client.get(
      '/notifications',
      queryParameters: {'page': page, 'size': size},
    );
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return parsePageResponse(data, NotificationItemModel.fromJson);
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
