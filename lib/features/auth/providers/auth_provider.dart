/// ==========================================================================
/// [인증 상태 관리 - auth_provider.dart]
///
/// 사용자의 로그인/로그아웃 상태를 관리하는 파일입니다.
/// 앱 전체에서 "지금 로그인되어 있는가?", "로그인 중인가?", "에러가 있는가?" 등의
/// 정보를 여러 화면에서 공유할 수 있도록 해줍니다.
///
/// [Provider 패턴이란?]
/// Flutter에서 화면(Widget)과 데이터(State)를 분리하는 설계 방식입니다.
/// 이 파일이 "데이터 관리자" 역할을 하고, 화면은 이 관리자에게 데이터를 요청합니다.
/// 데이터가 바뀌면 notifyListeners()를 호출하여 "데이터가 바뀌었어!" 하고 알려주면,
/// 이 데이터를 보고 있는 모든 화면이 자동으로 다시 그려집니다.
///
/// [ChangeNotifier란?]
/// Flutter에서 제공하는 클래스로, 데이터 변경 시 알림을 보내는 기능을 가집니다.
/// AuthProvider가 이것을 상속(extends)받아서 알림 기능을 사용합니다.
///
/// [로그인 흐름 요약]
/// 1. 사용자가 카카오/구글/애플 로그인 버튼 클릭
/// 2. Firebase를 통해 소셜 로그인 진행 → Firebase ID Token(신분증) 획득
/// 3. 이 ID Token을 우리 백엔드 서버에 전송
/// 4. 서버가 확인 후 자체 JWT 토큰(출입증) 발급
/// 5. 토큰을 기기에 저장 → 로그인 완료
/// ==========================================================================

import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../services/oauth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService; // 백엔드 서버와 인증 관련 통신을 하는 서비스
  final OAuthService _oauthService; // 소셜 로그인(구글/카카오/애플) 처리 서비스
  final TokenStorage _tokenStorage; // 로그인 토큰(출입증)을 기기에 저장/관리하는 저장소

  // ── 상태 변수들: 화면에서 이 값들을 읽어서 UI를 그립니다 ──
  bool _isLoggedIn = false; // 현재 로그인 되어있는지 여부
  bool _isLoading = false; // 로그인 처리 중인지 (로딩 스피너 표시용)
  String? _error; // 에러 메시지 (로그인 실패 시 화면에 표시)
  String _verificationStatus = 'NONE'; // 본인인증 상태
  bool _isNewUser = false; // 신규 사용자인지 (회원가입 화면으로 보내야 하는지)

  AuthProvider({
    required AuthService authService,
    required OAuthService oauthService,
    required TokenStorage tokenStorage,
  }) : _authService = authService,
       _oauthService = oauthService,
       _tokenStorage = tokenStorage;

  // ── Getter: 외부(화면)에서 상태 값을 읽을 수 있도록 공개하는 부분 ──
  // (private 변수 _isLoggedIn을 직접 접근 못하게 하고, 읽기만 허용)
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get verificationStatus => _verificationStatus;
  bool get isNewUser => _isNewUser;

  /// 앱 시작 시 기기에 저장된 토큰이 있는지 확인하여 로그인 상태를 판단합니다
  /// (토큰이 있으면 = 이전에 로그인했었다 = 자동 로그인)
  Future<void> checkLoginStatus() async {
    _isLoggedIn = await _tokenStorage.hasTokens();
    notifyListeners(); // "상태가 바뀌었으니 화면을 다시 그려!" 라고 알림
  }

  /// Google 소셜 로그인
  Future<bool> loginWithGoogle() async {
    return _loginWithProvider('GOOGLE', () async => (await _oauthService.signInWithGoogle())?.token);
  }

  /// Apple 소셜 로그인
  Future<bool> loginWithApple() async {
    return _loginWithProvider('APPLE', () async => (await _oauthService.signInWithApple())?.token);
  }

  /// Kakao 소셜 로그인 (Firebase OIDC provider 설정 필요)
  Future<bool> loginWithKakao() async {
    return _loginWithProvider('KAKAO', () async => (await _oauthService.signInWithKakao())?.token);
  }

  /// 소셜 로그인 공통 로직 - Google/Apple/Kakao 모두 이 메서드를 통해 로그인합니다
  /// [async/await란?] 서버 통신처럼 시간이 걸리는 작업을 기다렸다 결과를 받는 방식입니다.
  /// await를 만나면 그 작업이 끝날 때까지 기다렸다가 다음 줄로 넘어갑니다.
  Future<bool> _loginWithProvider(
    String provider,
    Future<String?> Function() firebaseSignIn,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. 소셜 로그인 → OAuth Token 획득
      final oauthToken = await firebaseSignIn();
      if (oauthToken == null) {
        // 사용자가 로그인 취소
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. 백엔드 로그인 API 호출
      final request = LoginRequest(
        oauthToken: oauthToken,
        provider: provider,
      );

      final response = await _authService.login(request);
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      _isLoggedIn = true;
      _isNewUser = response.isNewUser;
      _verificationStatus = response.verificationStatus;
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } catch (e) {
      _error = '로그인에 실패했습니다: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 백엔드 API 직접 호출 로그인 (테스트용)
  Future<bool> login(LoginRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(request);
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      _isLoggedIn = true;
      _isNewUser = response.isNewUser;
      _verificationStatus = response.verificationStatus;
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } catch (e) {
      _error = '로그인에 실패했습니다';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 로그아웃 처리
  /// 1. 백엔드 서버에 로그아웃 알림 (실패해도 진행)
  /// 2. Firebase 로그아웃 (실패해도 진행)
  /// 3. 기기에 저장된 토큰 삭제
  /// 4. API 클라이언트 초기화 (다음 로그인 시 새로 생성)
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {}
    try {
      await _oauthService.signOut();
    } catch (_) {}
    await _tokenStorage.clearTokens();
    _isLoggedIn = false;
    ApiClient.reset();
    notifyListeners();
  }

  /// 회원 탈퇴 처리 - 서버에서 계정을 삭제하고, 로컬 데이터도 정리합니다
  Future<void> withdraw({String? reason}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.withdraw(reason: reason);
      try {
        await _oauthService.signOut();
      } catch (_) {}
      await _tokenStorage.clearTokens();
      _isLoggedIn = false;
      ApiClient.reset();
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 에러 메시지를 초기화합니다 (화면에서 에러 팝업을 닫을 때 사용)
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
