import 'package:itto/domain/auth/entities/auth_token.dart';

class TokenResponseModel {
  final String accessToken;
  final String refreshToken;

  const TokenResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) =>
      TokenResponseModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );

  AuthToken toEntity() => AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
}
