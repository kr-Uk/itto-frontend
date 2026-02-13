# FCM 토큰 등록 연동
> 날짜: 2026-02-13

## 작업 요약
- FCM 토큰을 백엔드에 등록하는 3가지 누락 경로(로그인, 회원가입, 토큰 갱신)를 연결
- FcmService에 토큰 갱신 콜백 메커니즘 추가
- 기존 SplashScreen의 등록 로직은 유지하면서 보완

## 변경 범위

| 파일 | 변경 내용 |
|------|----------|
| `lib/core/services/fcm_service.dart` | `setOnTokenRefresh()` 콜백 등록 메서드 추가, 갱신 리스너에서 콜백 호출 |
| `lib/features/auth/screens/login_screen.dart` | 기존 사용자 로그인 성공 시 `registerFcmToken()` 호출 추가 |
| `lib/features/auth/screens/signup/steps/welcome_step.dart` | 신규 사용자 가입 완료 시 `registerFcmToken()` 호출 추가 |
| `lib/features/notification/providers/notification_provider.dart` | 등록 성공 후 토큰 갱신 콜백 설정 로직 추가 |

## 핵심 개념 설명

### 1. FCM (Firebase Cloud Messaging) 이란?
Google이 제공하는 **무료 푸시 알림 서비스**입니다. 서버가 사용자 기기에 메시지를 보내려면:
1. 기기가 Firebase에서 **FCM 토큰** (고유 주소)을 발급받음
2. 이 토큰을 **우리 백엔드 서버에 등록**
3. 서버가 푸시를 보낼 때 이 토큰을 Firebase에 전달
4. Firebase가 해당 기기로 메시지 전송

```
서버 → Firebase Cloud Messaging → 기기 (FCM 토큰으로 식별)
```

### 2. FCM 토큰의 특징
- **기기마다 다름**: 같은 사용자도 기기별로 다른 토큰을 가짐
- **갱신됨**: Firebase가 보안/효율 이유로 토큰을 주기적으로 변경
- **만료됨**: 오래 미사용 기기의 토큰은 무효화
- **앱 재설치 시 변경**: 앱을 삭제 후 다시 설치하면 새 토큰 발급

### 3. 토큰 등록이 필요한 시점
```
앱 시작 (SplashScreen)      → 기존 사용자 자동 로그인 시 등록
로그인 성공 (LoginScreen)    → 기존 사용자 수동 로그인 시 등록
회원가입 완료 (WelcomeStep)  → 신규 사용자 가입 직후 등록
토큰 갱신 (FcmService)       → Firebase가 토큰을 변경할 때 자동 재등록
```

### 4. 콜백(Callback) 패턴
FcmService는 **싱글톤**이라 Provider에 접근할 수 없습니다. 그래서 "나중에 호출해줄 함수"를 미리 등록해두는 **콜백 패턴**을 사용합니다:

```dart
// FcmService (싱글톤 - Provider 접근 불가)
class FcmService {
  void Function(String)? _onTokenRefreshCallback;

  void setOnTokenRefresh(void Function(String) callback) {
    _onTokenRefreshCallback = callback;  // 함수를 저장해둠
  }

  // Firebase가 토큰 갱신 시 → 저장해둔 함수를 호출
  messaging.onTokenRefresh.listen((newToken) {
    _onTokenRefreshCallback?.call(newToken);
  });
}

// NotificationProvider (Provider - API 호출 가능)
fcmService.setOnTokenRefresh((newToken) {
  _service.updateFcmToken(fcmToken: newToken, deviceId: deviceId);
});
```

### 5. 백엔드 FCM 토큰 저장 구조
```
fcm_tokens 테이블
├── fcm_token_id (PK)
├── user_id (FK → users)
├── token (FCM 토큰, VARCHAR 500)
├── device_id (기기 고유 ID, VARCHAR 200)
├── created_at
└── updated_at

UNIQUE(user_id, device_id)  ← 한 기기당 하나의 토큰만 유지
```

같은 기기에서 재등록하면 **UPDATE**, 새 기기면 **INSERT**됩니다.

## 코드 설명

### 로그인 시 FCM 등록 (login_screen.dart)
```dart
if (success) {
  if (authProvider.isNewUser) {
    context.go('/signup');
    // 신규 사용자는 아직 프로필 미완성 → 가입 완료 후 등록
  } else {
    // 기존 사용자 → 즉시 FCM 토큰 등록
    context.read<NotificationProvider>().registerFcmToken();
    context.go('/home');
  }
}
```
- 신규 사용자(`isNewUser`)는 회원가입 완료 시점에 등록하므로 여기서는 건너뜀
- 기존 사용자는 바로 `registerFcmToken()` 호출

### 토큰 갱신 자동 재등록 (notification_provider.dart)
```dart
Future<void> registerFcmToken() async {
  // 1. FCM 토큰 + 기기 ID 획득
  final token = fcmService.fcmToken;
  final deviceId = fcmService.deviceId;

  // 2. 백엔드에 등록
  await _service.updateFcmToken(fcmToken: token, deviceId: deviceId);

  // 3. 이후 토큰이 갱신되면 자동으로 재등록되도록 콜백 설정
  fcmService.setOnTokenRefresh((newToken) {
    _service.updateFcmToken(fcmToken: newToken, deviceId: deviceId);
  });
}
```
- `registerFcmToken()`이 한 번 호출되면, 이후 토큰 갱신 시 자동으로 백엔드에 재등록
- deviceId는 기기가 바뀌지 않는 한 동일하므로 클로저에서 캡처

### 백엔드 API (PUT /api/v1/fcm/token)
```json
// Request
{
  "fcmToken": "dGVzdF90b2tlbi...",
  "deviceId": "a1b2c3d4e5f6"
}

// Response (성공)
{
  "success": true,
  "message": "FCM 토큰이 등록되었습니다"
}
```

## 새로 배울 수 있는 것
1. **FCM 토큰 라이프사이클**: 발급 → 등록 → 갱신 → 만료, 각 단계별 처리 방법
2. **싱글톤과 Provider 간 통신**: 콜백 패턴으로 의존성 역전 (DI 없이 느슨한 결합)
3. **멀티 디바이스 지원**: user_id + device_id 복합 유니크로 기기별 토큰 관리
4. **비동기 fire-and-forget**: `registerFcmToken()`을 await 없이 호출 (실패해도 앱 동작에 지장 없음)

## 리스크 및 주의사항
1. **토큰 무효화 처리 없음**: 서버에서 푸시 전송 실패 시 무효 토큰을 삭제하는 로직 미구현
2. **로그아웃 시 토큰 삭제 없음**: 로그아웃해도 서버에 FCM 토큰이 남아있음 → 다른 사용자가 같은 기기로 로그인하면 중복 가능
3. **콜백 중복 설정**: `registerFcmToken()`이 여러 번 호출되면 콜백이 덮어씌워지지만, 이전 콜백의 deviceId가 달라지는 경우는 없으므로 문제 없음
4. **오프라인 상태**: 네트워크 없이 로그인하면 FCM 등록 실패 → 다음 앱 재실행 시 SplashScreen에서 재시도
