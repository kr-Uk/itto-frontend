import 'package:flutter/foundation.dart';
import 'package:itto/core/network/api_exception.dart';
import 'package:itto/core/services/fcm_service.dart';
import 'package:itto/domain/notification/entities/notification_item.dart';
import 'package:itto/domain/notification/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _totalElements = 0;
  int _currentPage = 0;

  NotificationProvider({required NotificationRepository repository})
      : _repository = repository;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) _currentPage = 0;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.getList(page: _currentPage);
      if (_currentPage == 0) {
        _notifications = result.content;
      } else {
        _notifications = [..._notifications, ...result.content];
      }
      _totalElements = result.totalElements;
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_notifications.length >= _totalElements) return;
    _currentPage++;
    await loadNotifications();
  }

  Future<void> markAsRead(List<int> ids) async {
    try {
      await _repository.markRead(ids);
      _notifications = _notifications.map((n) {
        if (ids.contains(n.id)) {
          return NotificationItem(
            id: n.id,
            type: n.type,
            title: n.title,
            message: n.message,
            isRead: true,
            deepLink: n.deepLink,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      await _repository.deleteAll();
      _notifications = [];
      _totalElements = 0;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
    }
  }

  Future<void> registerFcmToken() async {
    try {
      final fcmService = FcmService.instance;
      final token = fcmService.fcmToken;
      final deviceId = fcmService.deviceId;

      if (token == null || deviceId == null) {
        debugPrint('FCM 토큰 등록 실패: 토큰 또는 기기 ID가 없음');
        return;
      }

      await _repository.updateFcmToken(fcmToken: token, deviceId: deviceId);
      debugPrint('FCM 토큰 등록 성공');

      fcmService.setOnTokenRefresh((newToken) {
        _repository
            .updateFcmToken(fcmToken: newToken, deviceId: deviceId)
            .then((_) {
              debugPrint('FCM 토큰 갱신 → 백엔드 재등록 성공');
            })
            .catchError((e) {
              debugPrint('FCM 토큰 갱신 → 백엔드 재등록 실패: $e');
            });
      });
    } on ApiException catch (e) {
      debugPrint('FCM 토큰 등록 실패: ${e.message}');
    } catch (e) {
      debugPrint('FCM 토큰 등록 중 예외 발생: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
