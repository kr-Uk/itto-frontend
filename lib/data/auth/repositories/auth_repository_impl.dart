import 'package:itto/domain/auth/entities/auth_token.dart';
import 'package:itto/domain/auth/entities/login_result.dart';
import 'package:itto/domain/auth/repositories/auth_repository.dart';
import 'package:itto/data/auth/datasources/auth_remote_datasource.dart';
import 'package:itto/data/auth/models/login_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<LoginResult> login({
    required String oauthToken,
    required String provider,
    String? fcmToken,
  }) async {
    final request = LoginRequestModel(
      oauthToken: oauthToken,
      provider: provider,
      fcmToken: fcmToken,
    );
    final model = await remoteDataSource.login(request.toJson());
    return model.toEntity();
  }

  @override
  Future<AuthToken> refresh(String refreshToken) async {
    final model = await remoteDataSource.refresh(refreshToken);
    return model.toEntity();
  }

  @override
  Future<void> logout() => remoteDataSource.logout();

  @override
  Future<void> withdraw({String? reason}) =>
      remoteDataSource.withdraw(reason: reason);
}
