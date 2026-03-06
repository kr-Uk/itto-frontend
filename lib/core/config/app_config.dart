import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.hguitto.site/api/v1';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);

  /// dev 모드: 본인인증/결제 등을 바이패스합니다.
  /// .env 파일에 DEV_MODE=true 를 추가하면 활성화됩니다.
  static bool get isDevMode =>
      dotenv.env['DEV_MODE']?.toLowerCase() == 'true';
}
