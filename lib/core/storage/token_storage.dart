/// ==========================================================================
/// [토큰 저장소 - token_storage.dart]
///
/// 로그인 후 서버에서 받은 "토큰(출입증)"을 스마트폰에 안전하게 저장하고,
/// 필요할 때 꺼내 쓰는 역할을 합니다.
///
/// [토큰(Token)이란?]
/// 로그인에 성공하면 서버가 발급해주는 "디지털 출입증"입니다.
/// 이후 서버에 요청할 때마다 이 출입증을 보여줘야 "아, 이 사람은 로그인한 사용자구나"
/// 하고 서버가 인식합니다.
///
/// [두 종류의 토큰]
/// - accessToken (접근 토큰): 실제로 서버에 보여주는 출입증. 유효기간이 짧습니다 (보통 30분~1시간).
/// - refreshToken (갱신 토큰): accessToken이 만료되었을 때 새 accessToken을 발급받기 위한 토큰.
///   유효기간이 길어서(보통 7~30일) 이 기간 동안은 재로그인 없이 자동 갱신됩니다.
///
/// [SharedPreferences란?]
/// 스마트폰 내부에 간단한 텍스트 데이터를 저장하는 공간입니다.
/// 앱을 껐다 켜도 데이터가 유지됩니다. (메모장에 적어놓는 것과 비슷)
/// ==========================================================================

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
