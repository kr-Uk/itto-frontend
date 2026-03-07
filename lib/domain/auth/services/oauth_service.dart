/// OAuth 로그인 결과를 담는 클래스
class OAuthResult {
  final String token;
  final String provider;

  const OAuthResult({required this.token, required this.provider});
}

/// OAuth 인증 서비스 인터페이스
abstract class OAuthService {
  Future<OAuthResult?> signInWithGoogle();
  Future<OAuthResult?> signInWithKakao();
  Future<OAuthResult?> signInWithApple();
  Future<void> signOut();
}
