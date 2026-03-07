class LoginResult {
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;
  final String verificationStatus;

  const LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
    required this.verificationStatus,
  });
}
