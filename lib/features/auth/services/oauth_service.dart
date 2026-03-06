/// ==========================================================================
/// [OAuth 인증 서비스 - oauth_service.dart]
///
/// 소셜 로그인(구글, 애플, 카카오)을 처리하는 파일입니다.
/// Firebase Auth를 거치지 않고, 각 소셜 로그인 SDK에서 직접 토큰을 획득합니다.
///
/// [소셜 로그인 흐름]
/// 1. 사용자가 소셜 로그인 버튼 클릭
/// 2. 해당 SDK에서 직접 토큰(ID Token 또는 Access Token) 획득
/// 3. 이 토큰을 백엔드 서버에 전송 → 서버가 직접 검증 후 JWT 발급
/// ==========================================================================

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
/// OAuth 로그인 결과를 담는 클래스
class OAuthResult {
  final String token;
  final String provider;

  const OAuthResult({required this.token, required this.provider});
}

class OAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '',
  );

  /// 구글 로그인 처리
  /// Google ID Token을 직접 획득하여 반환합니다.
  Future<OAuthResult?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) return null;

    return OAuthResult(token: idToken, provider: 'GOOGLE');
  }

  /// 카카오 로그인 처리
  /// Kakao Access Token을 직접 획득하여 반환합니다.
  Future<OAuthResult?> signInWithKakao() async {
    kakao.OAuthToken kakaoToken;

    if (await kakao.isKakaoTalkInstalled()) {
      kakaoToken = await kakao.UserApi.instance.loginWithKakaoTalk();
    } else {
      kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount();
    }

    return OAuthResult(
      token: kakaoToken.accessToken,
      provider: 'KAKAO',
    );
  }

  /// 애플 로그인 처리 (iOS 전용 - 추후 sign_in_with_apple 패키지 추가 시 구현)
  Future<OAuthResult?> signInWithApple() async {
    // TODO: sign_in_with_apple 패키지 추가 후 구현
    return null;
  }

  /// 모든 소셜 로그인에서 로그아웃 처리
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    try {
      await kakao.UserApi.instance.logout();
    } catch (_) {}
  }
}
