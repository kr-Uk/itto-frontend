# 회원가입 분기 로직 구현
> 날짜: 2026-02-19

## 작업 요약
- 로그인 상태 + 프로필 완성 여부 + 인증 승인 상태에 따른 5가지 라우팅 분기 구현
- 승인 대기(VerificationPendingScreen)와 승인 거부/재인증(VerificationRejectedScreen) 화면 생성
- 스플래시 화면에서 프로필 API 호출하여 자동 로그인 시에도 정확한 분기 처리

## 변경 범위

| 파일 | 변경 내용 |
|------|----------|
| `lib/features/auth/screens/verification_pending_screen.dart` | **신규** - 승인 대기 화면 (상태 확인 + 로그아웃) |
| `lib/features/auth/screens/verification_rejected_screen.dart` | **신규** - 승인 거부/재인증 화면 (셀카 촬영 + 재제출) |
| `lib/core/router/app_router.dart` | `/verification-pending`, `/verification-rejected` 라우트 추가 |
| `lib/features/splash/screens/splash_screen.dart` | 프로필 API 호출 + 5가지 분기 로직 |
| `lib/features/auth/screens/login_screen.dart` | 로그인 후 verificationStatus 기반 분기 |

## 핵심 개념 설명

### 1. 5가지 분기 조건

| # | 조건 | 라우트 |
|---|------|--------|
| 1 | 로그인O + 프로필O + 승인O (APPROVED) | `/home` |
| 2 | 로그인O + 프로필O + 승인 대기 (PENDING) | `/verification-pending` |
| 3 | 로그인O + 프로필X (isNewUser=true) | `/signup` |
| 4 | 로그인X (토큰 없음) | `/login` |
| 5 | 로그인O + 프로필O + 승인X (REJECTED/NONE) | `/verification-rejected` |

### 2. 자동 로그인 vs 소셜 로그인의 차이

**소셜 로그인** (LoginScreen)에서는 백엔드 `/auth/login` 응답에 `isNewUser`와 `verificationStatus`가 포함되어 바로 분기할 수 있습니다.

**자동 로그인** (SplashScreen)에서는 토큰만 저장되어 있으므로, `GET /profile/me` API를 추가로 호출하여 프로필 완성 여부와 인증 상태를 확인합니다.

```dart
// 스플래시 - 자동 로그인 분기
final profile = profileProvider.myProfile;
if (profile == null) → '/login' (토큰 만료)
if (profile.nickname.isEmpty) → '/signup' (프로필 미완성)
switch (profile.verificationStatus) {
  case 'APPROVED': → '/home'
  case 'PENDING': → '/verification-pending'
  default: → '/verification-rejected'
}
```

### 3. 백엔드 isNewUser 판단 기준

```java
// User.java
public boolean isProfileComplete() {
    return this.nickname != null && this.gender != null && this.birthDate != null;
}

// AuthService.java
boolean isNewUser = !user.isProfileComplete();
```

닉네임, 성별, 생년월일이 모두 설정되어야 프로필이 "완성"된 것으로 판단합니다.

### 4. verificationStatus 상태 머신

```
NONE → (셀카 제출) → PENDING → (관리자 승인) → APPROVED
                                (관리자 거부) → REJECTED → (재제출) → PENDING
```

## 코드 설명

### 스플래시 화면 분기 로직
```dart
// 기존: 토큰만 확인
if (authProvider.isLoggedIn) {
  context.go('/home'); // ← 인증 상태 무시!
}

// 수정 후: 프로필 API 호출 → 5가지 분기
if (!authProvider.isLoggedIn) → '/login'
await profileProvider.loadMyProfile();
if (profile == null) → '/login' // 토큰 만료
if (profile.nickname.isEmpty) → '/signup' // 프로필 미완성
switch (verificationStatus) → 적절한 화면
```

### 승인 대기 화면의 상태 확인
```dart
Future<void> _checkStatus(BuildContext context) async {
  await profileProvider.loadMyProfile();
  switch (profile.verificationStatus) {
    case 'APPROVED': context.go('/home');      // 승인됨 → 홈
    case 'REJECTED': context.go('/verification-rejected'); // 거부됨
    default: SnackBarUtils.showInfo(...);       // 아직 대기 중
  }
}
```

### 재인증 화면의 셀카 촬영
```dart
final photo = await picker.pickImage(
  source: ImageSource.camera,
  preferredCameraDevice: CameraDevice.front, // 전면 카메라
);
final success = await profileProvider.reverify(photo.path);
if (success) context.go('/verification-pending'); // 제출 → 대기로 이동
```

## 새로 배울 수 있는 것
- 앱 시작 시 여러 조건을 조합한 라우팅 분기 패턴
- 자동 로그인과 소셜 로그인에서 서로 다른 데이터 소스로 같은 분기 로직 적용
- `switch` expression을 활용한 깔끔한 상태 분기 (Dart 3 패턴 매칭)
- 상태 확인 → 화면 전환의 비동기 패턴 (`context.mounted` 체크 필수)

## 리스크 및 주의사항
- 자동 로그인 시 프로필 API 추가 호출로 스플래시 시간이 약간 늘어날 수 있음
- 네트워크 오프라인 상태에서 프로필 API 실패 시 `/login`으로 이동됨 → 오프라인 대응 필요 시 별도 처리
- `verificationStatus == 'NONE'`은 프로필 완성 후 인증 미제출 상태 → 재인증 화면으로 안내
