class LoginRequest {
  final String firebaseIdToken;
  final String provider; // KAKAO, APPLE, GOOGLE
  final String? fcmToken;

  const LoginRequest({
    required this.firebaseIdToken,
    required this.provider,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() => {
        'firebaseIdToken': firebaseIdToken,
        'provider': provider,
        if (fcmToken != null) 'fcmToken': fcmToken,
      };
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;
  final String verificationStatus;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
    required this.verificationStatus,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        isNewUser: json['isNewUser'] as bool? ?? false,
        verificationStatus: json['verificationStatus'] as String? ?? 'NONE',
      );
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}
