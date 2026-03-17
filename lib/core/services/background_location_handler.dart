import 'dart:convert';
import 'dart:io';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Headless 모드에서 사용할 기본 API base URL 상수.
/// dotenv가 로드된 경우 환경변수에서 읽고, 아니면 기본값을 사용합니다.
const String _fallbackBaseUrl = 'https://api.hguitto.site/api/v1';

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
    // TODO: FlutterSecureStorage는 background isolate에서 동작하지 않을 수 있음.
    //  Android에서는 encryptedSharedPreferences 옵션으로 동작 가능하나,
    //  iOS headless 모드에서는 keychain 접근이 제한될 수 있으므로 테스트 필요.
    //  문제 발생 시 SharedPreferences로 fallback하거나,
    //  foreground에서 토큰을 SharedPreferences에 동기화하는 방식을 고려.
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final accessToken = await secureStorage.read(key: 'access_token');
    if (accessToken == null || accessToken.isEmpty) return;

    final timestamp = DateTime.now().toIso8601String();

    // dotenv에서 API base URL을 가져옴 (Headless에서 dotenv 미로드 시 기본값 사용)
    final baseUrl = dotenv.env['API_BASE_URL'] ?? _fallbackBaseUrl;

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
