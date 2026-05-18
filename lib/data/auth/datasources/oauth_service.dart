import 'dart:io' show Platform;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
    // iOS는 native 다이얼로그, Android는 Apple ID web flow.
    // Android는 Apple Developer 콘솔에서 Service ID + Return URL 등록이 필요하며
    // .env에 APPLE_SERVICE_ID / APPLE_REDIRECT_URI가 있어야 동작한다.
    WebAuthenticationOptions? webOptions;
    if (!Platform.isIOS && !Platform.isMacOS) {
      final serviceId = dotenv.env['APPLE_SERVICE_ID'];
      final redirectUri = dotenv.env['APPLE_REDIRECT_URI'];
      if (serviceId == null || serviceId.isEmpty ||
          redirectUri == null || redirectUri.isEmpty) {
        throw const AppleAuthSetupException(
          'Android에서 Apple 로그인을 사용하려면 APPLE_SERVICE_ID / APPLE_REDIRECT_URI 환경변수가 필요합니다.',
        );
      }
      webOptions = WebAuthenticationOptions(
        clientId: serviceId,
        redirectUri: Uri.parse(redirectUri),
      );
    }

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: webOptions,
      );

      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) return null;

      return OAuthResult(token: identityToken, provider: 'APPLE');
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    try {
      await kakao.UserApi.instance.logout();
    } catch (_) {}
  }
}

class AppleAuthSetupException implements Exception {
  final String message;
  const AppleAuthSetupException(this.message);

  @override
  String toString() => message;
}
