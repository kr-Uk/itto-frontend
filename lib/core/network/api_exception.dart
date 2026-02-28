class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? code;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.code,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;

  /// 사용자에게 표시할 친화적 메시지.
  /// 에러 코드 매핑 우선 → 없으면 서버 메시지 그대로 사용.
  String get userMessage => _codeMessages[code] ?? message;

  @override
  String toString() => 'ApiException($statusCode, $message, $code)';

  /// 백엔드 ErrorCode → 사용자 친화적 한국어 메시지
  static const _codeMessages = <String, String>{
    // 공통
    'BAD_REQUEST': '잘못된 요청입니다.',
    'UNAUTHORIZED': '로그인이 필요합니다.',
    'FORBIDDEN': '접근 권한이 없습니다.',
    'NOT_FOUND': '요청한 정보를 찾을 수 없습니다.',
    'CONFLICT': '이미 처리된 요청입니다.',
    'INTERNAL_ERROR': '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',

    // 인증
    'INVALID_TOKEN': '인증 정보가 유효하지 않습니다. 다시 로그인해주세요.',
    'EXPIRED_TOKEN': '인증이 만료되었습니다. 다시 로그인해주세요.',
    'INVALID_REFRESH_TOKEN': '세션이 만료되었습니다. 다시 로그인해주세요.',
    'OAUTH_VERIFICATION_FAILED': '소셜 로그인에 실패했습니다. 다시 시도해주세요.',
    'UNSUPPORTED_PROVIDER': '지원하지 않는 로그인 방식입니다.',

    // 유저
    'USER_NOT_FOUND': '사용자를 찾을 수 없습니다.',
    'USER_ALREADY_WITHDRAWN': '이미 탈퇴한 계정입니다.',

    // 회원가입
    'NICKNAME_TOO_SHORT': '닉네임은 최소 2자 이상이어야 해요.',
    'NICKNAME_TOO_LONG': '닉네임은 최대 8자까지 가능해요.',
    'NICKNAME_PROFANITY': '부적절한 닉네임입니다. 다른 닉네임을 사용해주세요.',
    'NICKNAME_DUPLICATE': '이미 사용 중인 닉네임이에요.',
    'AGE_RESTRICTION': '만 19세 이상만 가입할 수 있어요.',
    'HOBBY_MIN': '관심사를 최소 1개 이상 선택해주세요.',
    'HOBBY_MAX': '관심사는 최대 5개까지 선택할 수 있어요.',
    'HOBBY_NOT_FOUND': '선택한 관심사를 찾을 수 없습니다.',
    'PHOTO_MIN': '사진을 최소 1장 이상 등록해주세요.',
    'PHOTO_MAX': '사진은 최대 6장까지 등록할 수 있어요.',
    'PROFILE_INCOMPLETE': '프로필 정보를 먼저 완성해주세요.',
    'TERMS_NOT_AGREED': '이용약관에 동의해주세요.',
    'FILE_UPLOAD_FAILED': '파일 업로드에 실패했습니다. 다시 시도해주세요.',

    // 프로필
    'MIN_PHOTO_REQUIRED': '프로필 사진이 최소 1장 필요합니다.',
    'PHOTO_NOT_FOUND': '사진을 찾을 수 없습니다.',

    // 차단
    'ALREADY_BLOCKED': '이미 차단한 사용자입니다.',
    'CANNOT_BLOCK_SELF': '자기 자신은 차단할 수 없어요.',
    'BLOCK_NOT_FOUND': '차단 정보를 찾을 수 없습니다.',

    // 관계
    'RELATIONSHIP_NOT_FOUND': '인연 정보를 찾을 수 없습니다.',
    'NOT_PILYEON': '필연 상태에서만 가능한 기능이에요.',
    'NOT_UYEON': '우연 상태에서만 가능한 기능이에요.',
    'NOT_PENDING': '인연 요청 대기 상태가 아닙니다.',
    'NOT_PAST': '지난 인연 상태에서만 가능합니다.',
    'NOT_INYEON': '인연 상태에서만 가능한 기능이에요.',
    'ALREADY_PENDING': '이미 인연 요청을 보냈어요.',
    'NOT_RELATIONSHIP_MEMBER': '해당 인연의 참여자가 아닙니다.',
    'INSUFFICIENT_KNOTS': '매듭이 부족합니다. 상점에서 충전해주세요.',
    'ENCOUNTER_NOT_FOUND': '만남 정보를 찾을 수 없습니다.',

    // 위치
    'EXCLUDED_AREA_NOT_FOUND': '제외 지역을 찾을 수 없습니다.',
    'EXCLUDED_AREA_LIMIT': '제외 지역은 최대 3개까지 등록할 수 있어요.',

    // 결제
    'INVALID_RECEIPT': '영수증 검증에 실패했습니다. 다시 시도해주세요.',

    // 본인인증
    'IDENTITY_ALREADY_VERIFIED': '이미 본인인증이 완료되었습니다.',
    'IDENTITY_NOT_FOUND': '본인인증 요청을 찾을 수 없습니다.',
    'IDENTITY_DUPLICATE_CI': '이미 가입된 본인인증 정보입니다. 다른 계정으로 로그인해주세요.',
    'IDENTITY_VERIFICATION_FAILED': '본인인증에 실패했습니다. 다시 시도해주세요.',
    'IDENTITY_CRYPTO_ERROR': '본인인증 처리 중 오류가 발생했습니다.',

    // 네트워크 (ApiClient에서 생성)
    'TIMEOUT': '서버 응답이 느립니다. 잠시 후 다시 시도해주세요.',
    'NETWORK_ERROR': '네트워크 연결을 확인해주세요.',
    'SERVER_DOWN': '서버 점검 중입니다. 잠시 후 다시 시도해주세요.',
  };
}
