// 토큰 저장소 — SharedPreferences 기반 access/refresh 토큰 관리.

import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _keyAccess = 'access_token'; // 저장소에서 accessToken을 찾을 때 쓰는 키(이름표)
  static const _keyRefresh =
      'refresh_token'; // 저장소에서 refreshToken을 찾을 때 쓰는 키(이름표)

  SharedPreferences? _prefs; // SharedPreferences 인스턴스를 캐싱(재사용)하기 위한 변수

  /// SharedPreferences 인스턴스를 가져옵니다 (처음 한 번만 생성, 이후 재사용)
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// 저장된 accessToken(접근 토큰)을 가져옵니다
  Future<String?> getAccessToken() async {
    final prefs = await _preferences;
    return prefs.getString(_keyAccess);
  }

  /// 저장된 refreshToken(갱신 토큰)을 가져옵니다
  Future<String?> getRefreshToken() async {
    final prefs = await _preferences;
    return prefs.getString(_keyRefresh);
  }

  /// 서버에서 받은 토큰 두 개를 기기에 저장합니다 (로그인 성공 시 호출)
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await _preferences;
    await prefs.setString(_keyAccess, accessToken);
    await prefs.setString(_keyRefresh, refreshToken);
  }

  /// 저장된 토큰을 모두 삭제합니다 (로그아웃 시 호출)
  Future<void> clearTokens() async {
    final prefs = await _preferences;
    await prefs.remove(_keyAccess);
    await prefs.remove(_keyRefresh);
  }

  /// 토큰이 저장되어 있는지 확인합니다 (자동 로그인 판단에 사용)
  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
