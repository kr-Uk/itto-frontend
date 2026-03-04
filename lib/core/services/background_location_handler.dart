import 'dart:convert';
import 'dart:io';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:shared_preferences/shared_preferences.dart';

/// 앱이 종료된 상태에서도 위치 이벤트를 처리하는 headless task.
/// main()에서 BackgroundGeolocation.registerHeadlessTask()로 등록해야 함.
@pragma('vm:entry-point')
void backgroundGeolocationHeadlessTask(bg.HeadlessEvent headlessEvent) async {
  switch (headlessEvent.name) {
    case bg.Event.LOCATION:
      final bg.Location location = headlessEvent.event;
      await _sendLocationToServer(location);
      break;
  }
}

/// Headless 모드에서는 Provider/Dio 사용 불가 → dart:io HttpClient로 직접 전송
Future<void> _sendLocationToServer(bg.Location location) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    if (accessToken == null || accessToken.isEmpty) return;

    final timestamp = DateTime.now().toIso8601String();

    final baseUrl =
        prefs.getString('api_base_url') ?? 'https://api.hguitto.site/api/v1';

    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('$baseUrl/location'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Authorization', 'Bearer $accessToken');
    request.write(
      jsonEncode({
        'latitude': location.coords.latitude,
        'longitude': location.coords.longitude,
        'accuracy': location.coords.accuracy,
        'timestamp': timestamp,
      }),
    );

    final response = await request.close();
    // 응답 바디를 소비하여 커넥션 해제
    await response.drain();
    client.close();
  } catch (_) {
    // Headless 모드에서는 에러를 조용히 무시
  }
}
