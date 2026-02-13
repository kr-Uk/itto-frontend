import '../../../core/network/api_client.dart';
import '../models/auth_models.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<LoginResponse> login(LoginRequest request) async {
    final json = await _client.post('/auth/login', data: request.toJson());
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return LoginResponse.fromJson(data);
  }

  Future<TokenResponse> refresh(String refreshToken) async {
    final json = await _client.post('/auth/refresh', data: {'refreshToken': refreshToken});
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return TokenResponse.fromJson(data);
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }

  Future<void> withdraw({String? reason}) async {
    await _client.post('/auth/withdraw', data: {
      if (reason != null) 'reason': reason,
    });
  }
}
