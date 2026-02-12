import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '623933708995-976i07e45chjlgc3fagckup4k85c9boh.apps.googleusercontent.com',
  );

  User? get currentUser => _auth.currentUser;

  /// Google Sign-In → Firebase 인증 → ID Token 반환
  Future<String?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return await userCredential.user?.getIdToken();
  }

  /// Apple Sign-In → Firebase 인증 → ID Token 반환
  Future<String?> signInWithApple() async {
    final appleProvider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('fullName');

    final userCredential = await _auth.signInWithProvider(appleProvider);
    return await userCredential.user?.getIdToken();
  }

  /// Kakao SDK 로그인 → OIDC ID Token → Firebase credential → ID Token 반환
  Future<String?> signInWithKakao() async {
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);

    kakao.OAuthToken kakaoToken;

    // 카카오톡 설치 여부에 따라 로그인 방식 분기
    if (await kakao.isKakaoTalkInstalled()) {
      kakaoToken = await kakao.UserApi.instance.loginWithKakaoTalk(
        nonce: hashedNonce,
      );
    } else {
      kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount(
        nonce: hashedNonce,
      );
    }

    final idToken = kakaoToken.idToken;
    if (idToken == null) {
      throw Exception('카카오 OIDC ID Token을 받지 못했습니다. OpenID Connect 활성화를 확인해주세요.');
    }

    // Kakao OIDC ID Token → Firebase OAuthCredential
    final credential = OAuthProvider('oidc.kakao').credential(
      idToken: idToken,
      rawNonce: rawNonce,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return await userCredential.user?.getIdToken();
  }

  /// Firebase에서 로그아웃
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    try {
      await kakao.UserApi.instance.logout();
    } catch (_) {}
    await _auth.signOut();
  }

  /// 현재 Firebase ID Token 가져오기 (갱신 포함)
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await _auth.currentUser?.getIdToken(forceRefresh);
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
