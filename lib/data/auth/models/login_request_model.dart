class LoginRequestModel {
  final String oauthToken;
  final String provider;
  final String? fcmToken;

  const LoginRequestModel({
    required this.oauthToken,
    required this.provider,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() => {
        'oauthToken': oauthToken,
        'provider': provider,
        if (fcmToken != null) 'fcmToken': fcmToken,
      };
}
