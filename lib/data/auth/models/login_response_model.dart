import 'package:itto/domain/auth/entities/login_result.dart';

class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;
  final String verificationStatus;

  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
    required this.verificationStatus,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        isNewUser: json['isNewUser'] as bool? ?? false,
        verificationStatus:
            json['verificationStatus'] as String? ?? 'NONE',
      );

  LoginResult toEntity() => LoginResult(
        accessToken: accessToken,
        refreshToken: refreshToken,
        isNewUser: isNewUser,
        verificationStatus: verificationStatus,
      );
}
