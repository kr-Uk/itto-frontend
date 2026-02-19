import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  static FcmService get instance => _instance;

  FcmService._internal();

  String? _fcmToken;
  String? _deviceId;
  void Function(String newToken)? _onTokenRefreshCallback;

  /// Foreground 메시지 수신 시 호출되는 콜백 (앱 내 배너 표시용)
  void Function(RemoteMessage message)? onForegroundMessageCallback;

  String? get fcmToken => _fcmToken;
  String? get deviceId => _deviceId;

  /// 토큰 갱신 시 호출될 콜백 등록 (로그인 후 설정)
  void setOnTokenRefresh(void Function(String newToken) callback) {
    _onTokenRefreshCallback = callback;
  }

  /// FCM 초기화: 권한 요청, 토큰 획득, 토큰 갱신 리스너 등록
  Future<void> initialize() async {
    try {
      // 알림 권한 요청
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('FCM: 알림 권한 승인됨');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('FCM: 임시 알림 권한 승인됨');
      } else {
        debugPrint('FCM: 알림 권한 거부됨');
        return;
      }

      // FCM 토큰 획득
      _fcmToken = await messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // 기기 ID 획득
      _deviceId = await _getDeviceId();
      debugPrint('Device ID: $_deviceId');

      // 토큰 갱신 리스너 등록
      messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Token 갱신됨: $newToken');
        _onTokenRefreshCallback?.call(newToken);
      });

      // 메시지 핸들러 설정
      setupMessageHandlers();
    } catch (e) {
      debugPrint('FCM 초기화 실패: $e');
    }
  }

  /// 기기 ID 획득 (Android: androidId, iOS: identifierForVendor)
  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Android ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown-ios-device';
    }
    return 'unknown-device';
  }

  /// 메시지 핸들러 설정
  void setupMessageHandlers() {
    // Foreground 메시지 수신
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground 메시지 수신: ${message.notification?.title}');
      // 앱 내 알림 배너 표시
      onForegroundMessageCallback?.call(message);
    });

    // Background에서 알림 탭하여 앱 열기
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Background 알림 탭: ${message.notification?.title}');
      // TODO: 딥링크 처리 (message.data['deepLink'] 등)
      if (message.data.isNotEmpty) {
        debugPrint('데이터: ${message.data}');
      }
    });

    // Terminated 상태에서 알림 탭 처리는 main.dart에서 별도 처리 필요
    // FirebaseMessaging.instance.getInitialMessage()
  }
}
