import 'package:flutter/foundation.dart';
import 'package:itto/core/network/api_client.dart';
import 'package:itto/core/network/api_exception.dart';
import 'package:itto/core/storage/token_storage.dart';
import 'package:itto/domain/auth/repositories/auth_repository.dart';
import 'package:itto/domain/auth/services/oauth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final OAuthService _oauthService;
  final TokenStorage _tokenStorage;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  String _verificationStatus = 'NONE';
  bool _isNewUser = false;

  AuthProvider({
    required AuthRepository authRepository,
    required OAuthService oauthService,
    required TokenStorage tokenStorage,
  }) : _authRepository = authRepository,
       _oauthService = oauthService,
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

  Future<bool> loginWithGoogle() async {
    return _loginWithProvider('GOOGLE', () async => (await _oauthService.signInWithGoogle())?.token);
  }

  Future<bool> loginWithApple() async {
    return _loginWithProvider('APPLE', () async => (await _oauthService.signInWithApple())?.token);
  }

  Future<bool> loginWithKakao() async {
    return _loginWithProvider('KAKAO', () async => (await _oauthService.signInWithKakao())?.token);
  }

  Future<bool> _loginWithProvider(
    String provider,
    Future<String?> Function() firebaseSignIn,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final oauthToken = await firebaseSignIn();
      if (oauthToken == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await _authRepository.login(
        oauthToken: oauthToken,
        provider: provider,
      );
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

  Future<bool> login({required String oauthToken, required String provider}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(
        oauthToken: oauthToken,
        provider: provider,
      );
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
      await _authRepository.logout();
    } catch (_) {}
    try {
      await _oauthService.signOut();
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
      await _authRepository.withdraw(reason: reason);
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
