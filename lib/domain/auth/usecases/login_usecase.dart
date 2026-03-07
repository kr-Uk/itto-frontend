import 'package:itto/domain/auth/entities/login_result.dart';
import 'package:itto/domain/auth/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<LoginResult> execute({
    required String oauthToken,
    required String provider,
    String? fcmToken,
  }) =>
      repository.login(
        oauthToken: oauthToken,
        provider: provider,
        fcmToken: fcmToken,
      );
}
