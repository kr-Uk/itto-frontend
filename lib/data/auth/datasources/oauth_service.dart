import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:itto/domain/auth/services/oauth_service.dart';

class OAuthServiceImpl implements OAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '',
  );

  @override
  Future<OAuthResult?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) return null;

    return OAuthResult(token: idToken, provider: 'GOOGLE');
  }

  @override
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

  @override
  Future<OAuthResult?> signInWithApple() async {
    // TODO: sign_in_with_apple 패키지 추가 후 구현
    return null;
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    try {
      await kakao.UserApi.instance.logout();
    } catch (_) {}
  }
}
