import 'package:itto/domain/auth/entities/auth_token.dart';
import 'package:itto/domain/auth/entities/login_result.dart';

abstract class AuthRepository {
  Future<LoginResult> login({
    required String oauthToken,
    required String provider,
    String? fcmToken,
  });
  Future<AuthToken> refresh(String refreshToken);
  Future<void> logout();
  Future<void> withdraw({String? reason});
}
