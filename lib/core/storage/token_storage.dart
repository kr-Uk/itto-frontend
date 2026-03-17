// 토큰 저장소 — FlutterSecureStorage 기반 access/refresh 토큰 관리.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _keyAccess = 'access_token'; // 저장소에서 accessToken을 찾을 때 쓰는 키(이름표)
  static const _keyRefresh =
      'refresh_token'; // 저장소에서 refreshToken을 찾을 때 쓰는 키(이름표)

  final FlutterSecureStorage _secureStorage;

  TokenStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  /// 저장된 accessToken(접근 토큰)을 가져옵니다
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _keyAccess);
  }

  /// 저장된 refreshToken(갱신 토큰)을 가져옵니다
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _keyRefresh);
  }

  /// 서버에서 받은 토큰 두 개를 기기에 저장합니다 (로그인 성공 시 호출)
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _keyAccess, value: accessToken);
    await _secureStorage.write(key: _keyRefresh, value: refreshToken);
  }

  /// 저장된 토큰을 모두 삭제합니다 (로그아웃 시 호출)
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _keyAccess);
    await _secureStorage.delete(key: _keyRefresh);
  }

  /// 토큰이 저장되어 있는지 확인합니다 (자동 로그인 판단에 사용)
  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
