import 'package:itto/core/network/api_client.dart';
import 'package:itto/data/auth/models/login_response_model.dart';
import 'package:itto/data/auth/models/token_response_model.dart';

class AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSource(this._client);

  Future<LoginResponseModel> login(Map<String, dynamic> data) async {
    final json = await _client.post('/auth/login', data: data);
    final responseData = json['data'] as Map<String, dynamic>? ?? json;
    return LoginResponseModel.fromJson(responseData);
  }

  Future<TokenResponseModel> refresh(String refreshToken) async {
    final json = await _client.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return TokenResponseModel.fromJson(data);
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }

  Future<void> withdraw({String? reason}) async {
    await _client.post(
      '/auth/withdraw',
      data: {if (reason != null) 'reason': reason},
    );
  }
}
