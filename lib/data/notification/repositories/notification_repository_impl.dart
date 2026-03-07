import 'package:itto/data/common/models/page_response.dart';
import 'package:itto/domain/notification/entities/notification_item.dart';
import 'package:itto/domain/notification/repositories/notification_repository.dart';
import 'package:itto/data/notification/datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PageResponse<NotificationItem>> getList({
    int page = 0,
    int size = 20,
  }) async {
    final result = await remoteDataSource.getList(page: page, size: size);
    return PageResponse(
      content: result.content.map((m) => m.toEntity()).toList(),
      page: result.page,
      size: result.size,
      totalElements: result.totalElements,
      totalPages: result.totalPages,
    );
  }

  @override
  Future<void> markRead(List<int> notificationIds) =>
      remoteDataSource.markRead(notificationIds);

  @override
  Future<void> deleteAll() => remoteDataSource.deleteAll();

  @override
  Future<void> updateFcmToken({
    required String fcmToken,
    required String deviceId,
  }) =>
      remoteDataSource.updateFcmToken(fcmToken: fcmToken, deviceId: deviceId);
}
