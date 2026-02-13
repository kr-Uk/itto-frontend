/// ==========================================================================
/// [Firebase 인증 서비스 - firebase_auth_service.dart]
///
/// 소셜 로그인(구글, 애플, 카카오)을 처리하는 파일입니다.
///
/// [소셜 로그인 흐름 전체 요약]
/// 카카오/구글/애플 로그인은 모두 비슷한 흐름을 따릅니다:
///
/// 1. 사용자가 "카카오로 로그인" 버튼을 누릅니다
/// 2. 카카오/구글/애플의 로그인 화면이 뜹니다 (ID, 비밀번호 입력)
/// 3. 로그인 성공 → 해당 서비스에서 "이 사람 맞아요"라는 증명서(credential)를 줍니다
/// 4. 이 증명서를 Firebase에 제출하면, Firebase가 확인 후 ID Token(신분증)을 발급합니다
/// 5. 이 Firebase ID Token을 우리 백엔드 서버에 보내면, 서버가 확인 후 자체 JWT 토큰을 발급합니다
///
/// [Firebase란?]
/// 구글이 제공하는 앱 개발 플랫폼입니다.
/// 여기서는 "통합 인증 창구" 역할을 합니다.
/// 카카오, 구글, 애플 등 다양한 소셜 로그인을 Firebase 하나로 통합 관리합니다.
///
/// [nonce란?]
/// 카카오 로그인에서 사용하는 일회용 보안 코드입니다.
/// "이 로그인 요청은 아까 그 요청의 응답이 맞다"를 확인하는 용도로,
/// 중간에 누군가 응답을 바꿔치기하는 것을 방지합니다.
/// ==========================================================================

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase 인증 객체
  final GoogleSignIn _googleSignIn = GoogleSignIn( // Google 로그인 SDK 객체
    serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '',
  );

  /// 현재 Firebase에 로그인된 사용자 정보 (없으면 null)
  User? get currentUser => _auth.currentUser;

  /// 구글 로그인 처리
  /// 흐름: 구글 로그인 화면 표시 → 구글 인증 정보 획득 → Firebase에 제출 → Firebase ID Token 반환
  /// 사용자가 로그인을 취소하면 null을 반환합니다
  Future<String?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn(); // 구글 로그인 팝업 표시
    if (googleUser == null) return null; // 사용자가 취소한 경우

    final googleAuth = await googleUser.authentication; // 구글에서 인증 정보 받기
    final credential = GoogleAuthProvider.credential( // Firebase용 인증서 만들기
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential); // Firebase에 인증서 제출
    return await userCredential.user?.getIdToken(); // Firebase ID Token(신분증) 발급받아 반환
  }

  /// 애플 로그인 처리
  /// 흐름: 애플 로그인 화면 표시 → Firebase에 직접 인증 → Firebase ID Token 반환
  /// (애플은 Firebase가 직접 처리하므로 구글보다 코드가 간단합니다)
  Future<String?> signInWithApple() async {
    final appleProvider = AppleAuthProvider()
      ..addScope('email') // 이메일 정보 요청
      ..addScope('fullName'); // 이름 정보 요청

    final userCredential = await _auth.signInWithProvider(appleProvider);
    return await userCredential.user?.getIdToken();
  }

  /// 카카오 로그인 처리
  /// 흐름: nonce 생성 → 카카오 로그인 → 카카오 ID Token 획득 → Firebase에 제출 → Firebase ID Token 반환
  ///
  /// [OIDC란?]
  /// OpenID Connect의 약자로, "이 사람이 누구인지" 증명하는 표준 방식입니다.
  /// 카카오가 OIDC 방식으로 ID Token을 발급하면, Firebase가 이를 검증합니다.
  Future<String?> signInWithKakao() async {
    /// 보안용 일회용 코드(nonce) 생성 - 요청과 응답이 같은 건인지 확인하는 용도
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce); // nonce를 암호화(SHA-256)하여 카카오에 전송

    kakao.OAuthToken kakaoToken;

    /// 카카오톡 앱이 설치되어 있으면 카카오톡으로 로그인,
    /// 없으면 웹 브라우저 카카오 계정으로 로그인
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

    /// 카카오에서 받은 ID Token을 Firebase용 인증서로 변환
    /// 'oidc.kakao'는 Firebase 콘솔에 등록한 카카오 OIDC Provider 이름
    final credential = OAuthProvider('oidc.kakao').credential(
      idToken: idToken,
      rawNonce: rawNonce, // 원본 nonce를 함께 보내 검증
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return await userCredential.user?.getIdToken();
  }

  /// 모든 소셜 로그인에서 로그아웃 처리
  /// 구글, 카카오, Firebase 순서로 로그아웃합니다 (카카오는 실패해도 무시)
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    try {
      await kakao.UserApi.instance.logout();
    } catch (_) {}
    await _auth.signOut();
  }

  /// 현재 Firebase에 로그인된 사용자의 ID Token을 가져옵니다
  /// forceRefresh가 true이면 만료 여부와 관계없이 새 토큰을 발급받습니다
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await _auth.currentUser?.getIdToken(forceRefresh);
  }

  /// 보안용 랜덤 문자열(nonce)을 생성합니다 - 카카오 로그인 보안 검증에 사용
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// 문자열을 SHA-256 알고리즘으로 암호화합니다 (원본 → 암호화된 문자열, 복원 불가)
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
