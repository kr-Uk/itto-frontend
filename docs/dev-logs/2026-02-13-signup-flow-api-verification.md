# 회원가입 플로우 API 연동 검증
> 날짜: 2026-02-13

## 작업 요약
- 회원가입 플로우의 API 연동 상태를 전수 조사하여 **6개 API 모두 이미 정상 연동 완료**임을 확인
- SignupService → SignupProvider → UI (10개 Step) 전체 데이터 흐름 검증 완료
- 추가 구현 필요 없음 (코드 변경 0건)

## 변경 범위
변경된 파일 없음. 아래는 검증 대상 파일 목록:

### 서비스 레이어
| 파일 | 역할 |
|------|------|
| `lib/features/auth/services/signup_service.dart` | 백엔드 API 호출 (6개 엔드포인트) |
| `lib/features/auth/providers/signup_provider.dart` | 상태 관리 + 서비스 호출 (6개 메서드) |

### UI 레이어 (10개 Step)
| 파일 | 역할 |
|------|------|
| `signup_flow_screen.dart` | PageView 컨테이너 (10 Step 관리) |
| `steps/location_permission_step.dart` | Step 1: 위치 권한 요청 |
| `steps/nickname_step.dart` | Step 2: 닉네임 입력 |
| `steps/gender_step.dart` | Step 3: 성별 선택 |
| `steps/birthday_step.dart` | Step 4: 생년월일 입력 |
| `steps/hobby_step.dart` | Step 5: 취미 선택 (GET /hobbies 호출) |
| `steps/intro_step.dart` | Step 6: 자기소개 작성 → **배치 API 전송** |
| `steps/signup_photo_step.dart` | Step 7: 프로필 사진 업로드 |
| `steps/face_verification_step.dart` | Step 8: 얼굴 인증 셀카 업로드 |
| `steps/verification_waiting_step.dart` | Step 9: 인증 대기 화면 |
| `steps/welcome_step.dart` | Step 10: 완료 + completeSignup() 호출 |

## 핵심 개념 설명

### 1. 회원가입 플로우 아키텍처 (10-Step PageView 패턴)
회원가입처럼 여러 단계를 거치는 화면은 **PageView**를 사용하여 하나의 화면 안에서 스와이프/버튼으로 단계를 이동합니다.

```
SignupFlowScreen (PageView)
├── Step 1: 위치 권한
├── Step 2: 닉네임
├── Step 3: 성별
├── Step 4: 생년월일
├── Step 5: 취미
├── Step 6: 자기소개 → API 전송 (saveTerms + saveProfile)
├── Step 7: 사진 업로드 → API 전송 (uploadPhotos)
├── Step 8: 셀카 인증 → API 전송 (uploadVerification)
├── Step 9: 인증 대기
└── Step 10: 완료 → API 전송 (completeSignup)
```

### 2. 로컬 수집 → 배치 전송 패턴
모든 데이터를 매 단계마다 서버에 보내지 않고, **Step 2~5에서 로컬(Provider)에 데이터를 모아두고 Step 6에서 한 번에 전송**합니다.

- **장점**: 네트워크 요청 최소화, 중간 이탈 시 불완전 데이터 방지
- **구현**: SignupProvider에 `_nickname`, `_gender`, `_birthDate`, `_selectedHobbies` 등 임시 변수 보관

```dart
// Step 2 (닉네임) - 로컬 저장만
signupProvider.setNickname(nickname);

// Step 6 (자기소개) - 배치 전송
await signupProvider.saveProfile();
// 내부에서 _nickname, _gender, _birthDate, _hobbies, _introduction을 모아서
// POST /api/v1/signup/profile 호출
```

### 3. Multipart 파일 업로드 (Dio FormData)
사진/셀카 업로드는 JSON이 아닌 **multipart/form-data** 형식으로 전송합니다.

```dart
// signup_service.dart
Future<void> uploadPhotos(List<File> photos) async {
  final formData = FormData.fromMap({
    'photos': photos.map((f) =>
      MultipartFile.fromFileSync(f.path, filename: f.path.split('/').last)
    ).toList(),
  });
  await _dio.post('/signup/photos', data: formData);
}
```

- `MultipartFile.fromFileSync()`: 파일을 바이너리로 읽어 전송
- `FormData.fromMap()`: key-value 쌍을 multipart 형식으로 변환
- 서버에서는 `@RequestPart("photos") List<MultipartFile>` 로 수신

### 4. Provider 패턴으로 상태 관리
Flutter의 **Provider 패턴**은 React의 Context API와 유사합니다:

```
UI (Step Widget)
  ↓ context.read<SignupProvider>().setNickname("홍길동")
Provider (SignupProvider extends ChangeNotifier)
  ↓ notifyListeners()
UI (Consumer<SignupProvider>) → 자동 리빌드
```

- `context.read<T>()`: 1회 읽기 (이벤트 핸들러에서 사용)
- `context.watch<T>()`: 변경 감지 + 자동 리빌드 (build 메서드에서 사용)
- `Consumer<T>`: 특정 위젯만 리빌드 (성능 최적화)

## 코드 설명

### API 연동 전체 흐름 (6개 API)

```dart
// 1. GET /api/v1/hobbies - 취미 목록 조회 (Step 5에서 호출)
final hobbies = await signupProvider.fetchHobbies();

// 2. POST /api/v1/signup/terms - 약관 동의 저장 (Step 6에서 saveProfile 내부 호출)
await signupService.saveTerms(termsAgreed: true, privacyAgreed: true, ...);

// 3. POST /api/v1/signup/profile - 프로필 저장 (Step 6에서 호출)
await signupService.saveProfile(nickname, gender, birthDate, hobbies, intro);

// 4. POST /api/v1/signup/photos - 사진 업로드 (Step 7에서 호출)
await signupService.uploadPhotos(photoFiles);

// 5. POST /api/v1/signup/verification - 셀카 인증 (Step 8에서 호출)
await signupService.uploadVerification(selfieFile);

// 6. POST /api/v1/signup/complete - 가입 완료 (Step 10에서 호출)
await signupService.completeSignup();
```

### Step 6 (IntroStep) - 배치 전송의 핵심

```dart
// intro_step.dart (핵심 부분)
Future<void> _submitProfile() async {
  final provider = context.read<SignupProvider>();
  provider.setIntroduction(_introController.text);

  // saveTerms + saveProfile을 순차 호출
  final success = await provider.saveProfile();

  if (success && mounted) {
    widget.onNext(); // Step 7로 이동
  } else {
    SnackBarUtils.showError(context, provider.error ?? '저장 실패');
  }
}
```

`saveProfile()` 내부에서 `saveTerms()`를 먼저 호출한 뒤 `saveProfile()`을 호출하여
약관 동의 → 프로필 저장 순서를 보장합니다.

## 새로 배울 수 있는 것
1. **PageView 기반 멀티스텝 폼**: 회원가입, 온보딩 등 다단계 입력 UI 설계 패턴
2. **로컬 수집 → 배치 전송**: 네트워크 효율성과 데이터 무결성을 동시에 확보하는 방법
3. **Multipart 파일 업로드**: Dio를 사용한 이미지/파일 업로드 구현
4. **Provider 상태 관리**: ChangeNotifier + Consumer 패턴으로 반응형 UI 구현
5. **코드 검증의 중요성**: 구현 전에 기존 코드를 먼저 확인하여 불필요한 중복 작업 방지

## 리스크 및 주의사항
1. **오프라인 처리 없음**: 네트워크 끊김 시 중간 저장 데이터가 유실될 수 있음 (로컬 캐싱 미구현)
2. **사진 용량 제한**: 서버 측 `max-file-size` 설정에 의존 (현재 10MB) → 클라이언트 측 리사이징 미구현
3. **에러 복구**: API 호출 실패 시 재시도 로직 없음 (사용자가 수동으로 다시 시도해야 함)
4. **인증 대기 상태**: Step 9에서 폴링/푸시 알림으로 인증 완료를 감지하는 로직이 간소화되어 있음
5. **이전 세션 복구**: 앱 종료 후 재진입 시 이전 입력 데이터가 보존되지 않음 (SharedPreferences 미사용)
