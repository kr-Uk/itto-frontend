import 'package:flutter/foundation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/fcm_service.dart';
import '../models/notification_models.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;

  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _totalElements = 0;
  int _currentPage = 0;

  NotificationProvider({required NotificationService service})
      : _service = service;

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
      final result = await _service.getList(page: _currentPage);
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
      await _service.markRead(ids);
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
      await _service.deleteAll();
      _notifications = [];
      _totalElements = 0;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
    }
  }

  /// FCM 토큰을 백엔드에 등록 + 토큰 갱신 콜백 설정
  Future<void> registerFcmToken() async {
    try {
      final fcmService = FcmService.instance;
      final token = fcmService.fcmToken;
      final deviceId = fcmService.deviceId;

      if (token == null || deviceId == null) {
        debugPrint('FCM 토큰 등록 실패: 토큰 또는 기기 ID가 없음');
        return;
      }

      await _service.updateFcmToken(
        fcmToken: token,
        deviceId: deviceId,
      );
      debugPrint('FCM 토큰 등록 성공');

      // 토큰 갱신 시 자동 재등록 콜백 설정
      fcmService.setOnTokenRefresh((newToken) {
        _service.updateFcmToken(
          fcmToken: newToken,
          deviceId: deviceId,
        ).then((_) {
          debugPrint('FCM 토큰 갱신 → 백엔드 재등록 성공');
        }).catchError((e) {
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
