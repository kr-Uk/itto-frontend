import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FirebaseAuthService _firebaseAuthService;
  final TokenStorage _tokenStorage;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  String _verificationStatus = 'NONE';
  bool _isNewUser = false;

  AuthProvider({
    required AuthService authService,
    required FirebaseAuthService firebaseAuthService,
    required TokenStorage tokenStorage,
  })  : _authService = authService,
        _firebaseAuthService = firebaseAuthService,
        _tokenStorage = tokenStorage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get verificationStatus => _verificationStatus;
  bool get isNewUser => _isNewUser;

  Future<void> checkLoginStatus() async {
    _isLoggedIn = await _tokenStorage.hasTokens();
    notifyListeners();
  }

  /// Google 소셜 로그인
  Future<bool> loginWithGoogle() async {
    return _loginWithProvider('GOOGLE', _firebaseAuthService.signInWithGoogle);
  }

  /// Apple 소셜 로그인
  Future<bool> loginWithApple() async {
    return _loginWithProvider('APPLE', _firebaseAuthService.signInWithApple);
  }

  /// Kakao 소셜 로그인 (Firebase OIDC provider 설정 필요)
  Future<bool> loginWithKakao() async {
    return _loginWithProvider('KAKAO', _firebaseAuthService.signInWithKakao);
  }

  /// 소셜 로그인 공통 로직
  Future<bool> _loginWithProvider(
    String provider,
    Future<String?> Function() firebaseSignIn,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Firebase 소셜 로그인 → ID Token 획득
      final idToken = await firebaseSignIn();
      if (idToken == null) {
        // 사용자가 로그인 취소
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. 백엔드 로그인 API 호출
      final request = LoginRequest(
        firebaseIdToken: idToken,
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

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {}
    try {
      await _firebaseAuthService.signOut();
    } catch (_) {}
    await _tokenStorage.clearTokens();
    _isLoggedIn = false;
    ApiClient.reset();
    notifyListeners();
  }

  Future<void> withdraw({String? reason}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.withdraw(reason: reason);
      try {
        await _firebaseAuthService.signOut();
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
