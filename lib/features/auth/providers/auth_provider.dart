/// ==========================================================================
/// [인증 상태 관리 - auth_provider.dart]
///
/// 사용자의 로그인/로그아웃 상태를 관리하는 파일입니다.
/// 앱 전체에서 "지금 로그인되어 있는가?", "로그인 중인가?", "에러가 있는가?" 등의
/// 정보를 여러 화면에서 공유할 수 있도록 해줍니다.
///
/// [로그인 흐름 요약]
/// 1. 사용자가 카카오/구글/애플 로그인 버튼 클릭
/// 2. OAuth SDK에서 직접 토큰 획득 (Firebase 없이)
/// 3. 이 토큰을 우리 백엔드 서버에 전송
/// 4. 서버가 직접 검증 후 자체 JWT 토큰(출입증) 발급
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
  final AuthService _authService;
  final OAuthService _oAuthService;
  final TokenStorage _tokenStorage;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  String _verificationStatus = 'NONE';
  bool _isNewUser = false;

  AuthProvider({
    required AuthService authService,
    required OAuthService oAuthService,
    required TokenStorage tokenStorage,
  })  : _authService = authService,
        _oAuthService = oAuthService,
        _tokenStorage = tokenStorage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get verificationStatus => _verificationStatus;
  bool get isNewUser => _isNewUser;

  /// 앱 시작 시 기기에 저장된 토큰이 있는지 확인하여 로그인 상태를 판단합니다
  Future<void> checkLoginStatus() async {
    _isLoggedIn = await _tokenStorage.hasTokens();
    notifyListeners();
  }

  /// Google 소셜 로그인
  Future<bool> loginWithGoogle() async {
    return _loginWithProvider(_oAuthService.signInWithGoogle);
  }

  /// Apple 소셜 로그인
  Future<bool> loginWithApple() async {
    return _loginWithProvider(_oAuthService.signInWithApple);
  }

  /// Kakao 소셜 로그인
  Future<bool> loginWithKakao() async {
    return _loginWithProvider(_oAuthService.signInWithKakao);
  }

  /// 소셜 로그인 공통 로직
  Future<bool> _loginWithProvider(
    Future<OAuthResult?> Function() oAuthSignIn,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. OAuth SDK에서 직접 토큰 획득
      final result = await oAuthSignIn();
      if (result == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. 백엔드 로그인 API 호출
      final request = LoginRequest(
        oauthToken: result.token,
        provider: result.provider,
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
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {}
    try {
      await _oAuthService.signOut();
    } catch (_) {}
    await _tokenStorage.clearTokens();
    _isLoggedIn = false;
    ApiClient.reset();
    notifyListeners();
  }

  /// 회원 탈퇴 처리
  Future<void> withdraw({String? reason}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.withdraw(reason: reason);
      try {
        await _oAuthService.signOut();
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

  /// 에러 메시지를 초기화합니다
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
