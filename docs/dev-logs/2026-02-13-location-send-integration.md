# 위치 전송 연동 완성
> 날짜: 2026-02-13

## 작업 요약
- 위치 전송 기능의 누락 부분(OS 권한 요청, 권한 체크, h3Index 정리)을 보완하여 end-to-end 연동 완성
- 백엔드에서 h3Index를 optional로 변경 (서버가 lat/lng로 직접 계산하므로 클라이언트 전송 불필요)
- 회원가입 시 OS 위치 권한 요청, 매칭 토글 시 권한 재확인 로직 추가

## 변경 범위

### 백엔드
| 파일 | 변경 내용 |
|------|----------|
| `LocationRequest.java` | h3Index에서 `@NotBlank` 제거 → optional 필드로 변경 |

### 프론트엔드
| 파일 | 변경 내용 |
|------|----------|
| `location_permission_step.dart` | OS 위치 권한 요청 (`Permission.location` + `Permission.locationAlways`) 추가 |
| `location_provider.dart` | `_ensureLocationPermission()` 메서드 추가, `toggleMatching()`에 권한 체크, `_onLocation()`에서 h3Index 제거 |
| `location_service.dart` | `sendLocation()`에서 h3Index 파라미터 제거 |
| `background_location_handler.dart` | headless 모드 전송에서 h3Index 제거 |
| `home_screen.dart` | 토글 실패 시 SnackBar 에러 표시 추가 |

## 핵심 개념 설명

### 1. 위치 권한 단계 (Android)
Android에서 위치 권한은 3단계로 나뉩니다:
- **포그라운드 위치** (`ACCESS_FINE_LOCATION`): 앱이 화면에 있을 때만 위치 수집
- **백그라운드 위치** (`ACCESS_BACKGROUND_LOCATION`): 앱이 백그라운드에 있을 때도 위치 수집
- **항상 허용** (`locationAlways`): 앱이 종료되어도 위치 수집 (Android 10+)

```dart
// 1단계: 포그라운드 위치 권한 요청 (필수)
final locationStatus = await Permission.location.request();

// 2단계: 백그라운드 위치 권한 요청 (선택 - 앱 종료 후 추적에 필요)
final bgStatus = await Permission.locationAlways.request();
```

Android 10(API 29)부터는 포그라운드 권한을 먼저 받은 후에만 백그라운드 권한을 요청할 수 있습니다.

### 2. flutter_background_geolocation 동작 흐름
```
앱 포그라운드     앱 백그라운드     앱 종료
    ↓                ↓               ↓
onLocation()    onLocation()    headlessTask()
    ↓                ↓               ↓
_onLocation()   _onLocation()   _sendLocationToServer()
    ↓                ↓               ↓
LocationService  LocationService  HttpClient (직접)
    ↓                ↓               ↓
POST /location   POST /location  POST /location
```

- **포그라운드/백그라운드**: Provider → LocationService → ApiClient(Dio) 사용
- **앱 종료 후 (Headless)**: Provider/Dio 사용 불가 → `dart:io.HttpClient`로 직접 HTTP 요청

### 3. H3 인덱스를 서버에서 계산하는 이유
- 클라이언트에 H3 라이브러리를 추가하면 앱 크기 증가 (네이티브 바이너리 필요)
- 서버가 lat/lng를 받아 `h3.latLngToCellAddress(lat, lng, 9)` 로 직접 계산
- 클라이언트는 좌표만 전송하면 되므로 구현이 단순

### 4. permission_handler 패키지
Flutter에서 OS 권한을 요청하는 통합 패키지:
```dart
// 권한 상태 확인
PermissionStatus status = await Permission.location.status;

// 권한 요청 (OS 다이얼로그 표시)
status = await Permission.location.request();

// 상태 체크
status.isGranted          // 허용됨
status.isDenied           // 거부됨 (다시 요청 가능)
status.isPermanentlyDenied // 영구 거부 (설정에서만 변경 가능)

// 설정 화면으로 이동 (영구 거부 시)
openAppSettings();
```

## 코드 설명

### toggleMatching 권한 체크 흐름
```dart
Future<bool> toggleMatching(bool enabled) async {
  // 1. 활성화 요청 시에만 권한 체크 (비활성화는 권한 불필요)
  if (enabled) {
    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) {
      notifyListeners(); // UI에 에러 상태 반영
      return false;
    }
  }

  // 2. 서버에 토글 상태 전송
  final response = await _service.toggle(enabled);
  _isMatchingEnabled = response.enabled;

  // 3. 위치 추적 시작/중지
  if (_isMatchingEnabled) {
    await startLocationTracking();
  } else {
    await stopLocationTracking();
  }
}
```

### 회원가입 시 권한 요청 순서
```dart
// LocationPermissionStep._handleNext()
// 1. 포그라운드 위치 권한 (필수)
final locationStatus = await Permission.location.request();
if (!locationStatus.isGranted) → 에러 표시, 진행 중단

// 2. 백그라운드 위치 권한 (선택)
final bgStatus = await Permission.locationAlways.request();
if (!bgStatus.isGranted) → 경고만 출력, 계속 진행

// 3. 약관 저장 API 호출
await provider.saveTerms();
```

## 새로 배울 수 있는 것
1. **Android 위치 권한 3단계 구조**: Fine → Background → Always, 순차적 요청 필수
2. **Headless 모드의 제약**: Provider/Dio 등 Flutter 프레임워크 기능 사용 불가, 순수 Dart 코드만 사용
3. **서버 측 H3 계산 전략**: 클라이언트 부담을 줄이고, 단일 진실 소스(서버)에서 계산
4. **permission_handler의 영구 거부 처리**: `isPermanentlyDenied` 시 `openAppSettings()` 사용

## 리스크 및 주의사항
1. **백그라운드 권한 거부 시**: 앱이 포그라운드일 때만 위치가 전송됨 → 매칭 정확도 저하
2. **Android 12+ 대략적 위치**: 사용자가 "대략적 위치"만 허용하면 accuracy가 낮아짐
3. **배터리 최적화**: 일부 제조사(삼성, 화웨이 등)의 배터리 최적화가 백그라운드 서비스를 강제 종료할 수 있음
4. **iOS 미지원**: 현재 Android만 테스트됨, iOS는 별도 권한 흐름 필요 (Info.plist 설정)
5. **토큰 만료**: Headless 모드에서 access_token이 만료되면 위치 전송 실패 (refresh 로직 없음)
