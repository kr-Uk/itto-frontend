# E2E 통합 테스트 구조 구축
> 날짜: 2026-02-13

## 작업 요약
- Flutter `integration_test` 프레임워크를 도입하여 E2E 자동 테스트 기반 구축
- UI 테스트(앱 시작/스플래시/로그인 화면) + API 테스트(공개 API/인증 에러/응답 형식) 작성
- 수동 E2E 테스트 체크리스트 9개 시나리오(50+ 항목) 정의
- 백엔드 API 라이브 서버 검증 완료 (hobbies 200, 인증 없이 403, 잘못된 토큰 401)

## 변경 범위

| 파일 | 역할 |
|------|------|
| `pubspec.yaml` | `integration_test` SDK 의존성 추가 |
| `integration_test/e2e_test.dart` | UI 자동 테스트 (앱 렌더링, 네비게이션 검증) |
| `integration_test/api_e2e_test.dart` | API 자동 테스트 (HTTP 요청/응답 검증) |
| `integration_test/E2E_CHECKLIST.md` | 수동 E2E 시나리오 체크리스트 |

## 핵심 개념 설명

### 1. 테스트의 3단계 피라미드
소프트웨어 테스트는 범위에 따라 3단계로 나뉩니다:

```
        /  E2E  \        ← 느리지만 실제 사용자 경험 검증 (전체 흐름)
       /  통합   \       ← 모듈 간 연결 검증 (API ↔ DB, Provider ↔ Service)
      /  단위     \      ← 빠르고 작은 단위 (함수 하나, 클래스 하나)
```

- **단위 테스트**: `isPointInPolygon()` 함수가 올바른 결과를 반환하는지
- **통합 테스트**: `LocationProvider.toggleMatching()` → `LocationService.toggle()` → 서버 호출이 연결되는지
- **E2E 테스트**: 사용자가 토글 스위치를 누르면 → 권한 요청 → 서버 통신 → UI 업데이트까지 전부 동작하는지

### 2. Flutter Integration Test란?
Flutter에서 제공하는 **실제 디바이스/에뮬레이터에서 앱을 실행하며 UI를 자동으로 조작하는 테스트 프레임워크**입니다.

```dart
// 일반 단위 테스트 (test/ 디렉토리)
test('1 + 1 = 2', () {
  expect(1 + 1, 2);  // 로직만 검증
});

// 통합 테스트 (integration_test/ 디렉토리)
testWidgets('로그인 버튼이 표시된다', (tester) async {
  await tester.pumpWidget(const IttoApp());     // 실제 앱 실행
  await tester.pumpAndSettle();                  // 애니메이션 완료 대기
  expect(find.text('TALK'), findsOneWidget);     // UI 요소 확인
  await tester.tap(find.text('TALK'));           // 버튼 탭 시뮬레이션
});
```

### 3. 테스트에서 쓰는 핵심 API

| 메서드 | 역할 | 예시 |
|--------|------|------|
| `tester.pumpWidget()` | 위젯을 화면에 렌더링 | `tester.pumpWidget(const IttoApp())` |
| `tester.pump()` | 한 프레임 진행 | 애니메이션 1프레임 진행 |
| `tester.pumpAndSettle()` | 모든 애니메이션 완료까지 대기 | 화면 전환 완료 대기 |
| `find.text()` | 텍스트로 위젯 찾기 | `find.text('Itto')` |
| `find.byType()` | 타입으로 위젯 찾기 | `find.byType(MaterialApp)` |
| `find.byIcon()` | 아이콘으로 위젯 찾기 | `find.byIcon(Icons.apple)` |
| `expect()` | 기대값 검증 (실패하면 테스트 실패) | `expect(find.text('Itto'), findsOneWidget)` |

### 4. 자동 테스트 vs 수동 테스트
모든 것을 자동화할 수 없는 이유:

| 항목 | 자동화 가능? | 이유 |
|------|:---------:|------|
| 앱 시작/렌더링 | O | 위젯 트리만 검증 |
| 로그인 화면 UI | O | 버튼/텍스트 존재 확인 |
| API 응답 형식 | O | HTTP 요청/응답 자동화 |
| **카카오 로그인** | **X** | OAuth 팝업이 WebView로 열림, 실제 계정 필요 |
| **사진 촬영** | **X** | 카메라 하드웨어 접근 |
| **위치 권한 다이얼로그** | **X** | OS 시스템 팝업은 Flutter가 제어 불가 |
| **푸시 알림 수신** | **X** | Firebase 서버 → 기기 전달 경로 |

그래서 **자동 + 수동 혼합 전략**이 현실적입니다.

### 5. `dart:io.HttpClient` vs `Dio`
통합 테스트에서 API를 직접 호출할 때는 `Dio` 대신 `dart:io.HttpClient`를 사용합니다:

```dart
// Dio (앱 코드에서 사용) - Provider, Interceptor 등 앱 인프라에 의존
final response = await _client.get('/hobbies');

// dart:io HttpClient (테스트에서 사용) - 외부 의존성 없이 독립 실행
final request = await client.getUrl(Uri.parse('$baseUrl/hobbies'));
final response = await request.close();
final body = await response.transform(utf8.decoder).join();
```

테스트는 **앱 코드에 의존하지 않고 독립적으로 API 동작을 검증**해야 하기 때문입니다.

## 코드 설명

### UI 테스트 핵심 (e2e_test.dart)
```dart
testWidgets('비로그인 상태에서 로그인 화면으로 이동한다', (tester) async {
  // 1. 앱 위젯 렌더링
  await tester.pumpWidget(const IttoApp());

  // 2. 스플래시 → 로그인 전환 대기 (2초 딜레이 + 애니메이션)
  await tester.pumpAndSettle(const Duration(seconds: 4));

  // 3. 로그인 화면 요소 확인
  expect(find.text('스친 인연을, 이토로 잇다'), findsOneWidget);
});
```
- `pumpAndSettle(Duration(seconds: 4))`: SplashScreen의 2초 딜레이 + 네비게이션 애니메이션 완료까지 충분히 대기
- 비로그인 상태에서는 `TokenStorage`에 토큰이 없으므로 자동으로 `/login` 경로로 이동

### API 테스트 핵심 (api_e2e_test.dart)
```dart
testWidgets('POST /auth/login - 잘못된 Firebase 토큰으로 401 반환', (tester) async {
  final result = await postJson('/auth/login', {
    'firebaseIdToken': 'invalid_token_for_testing',
    'provider': 'KAKAO',
  });

  // HTTP 상태 코드 검증
  expect(result.statusCode, 401);

  // 에러 응답 형식 검증
  expect(result.body['code'], 'FIREBASE_AUTH_FAILED');
  expect(result.body['message'], isNotEmpty);
});
```
- 실제 백엔드 서버(`https://api.hguitto.site`)에 HTTP 요청을 보내 응답을 검증
- 잘못된 토큰 → 401, 토큰 없음 → 403, 정상 → 200 등 시나리오별 확인

## 새로 배울 수 있는 것
1. **테스트 피라미드**: 단위 → 통합 → E2E, 각 레벨의 역할과 트레이드오프
2. **Flutter Integration Test**: `testWidgets`, `tester.pumpWidget`, `find.*`, `expect` 사용법
3. **자동화 한계 인식**: OAuth, 카메라, OS 팝업 등 자동화 불가 영역 → 수동 체크리스트 필요
4. **API 독립 테스트**: 앱 코드에 의존하지 않고 `dart:io`로 직접 HTTP 검증
5. **E2E 체크리스트 작성법**: 사용자 시나리오 기반으로 검증 항목 정의

## 리스크 및 주의사항
1. **Firebase 초기화 필요**: UI 테스트 실행 시 `Firebase.initializeApp()`이 필요하므로 에뮬레이터/실제 기기에서만 실행 가능
2. **네트워크 의존**: API 테스트는 백엔드 서버가 살아있어야 통과 → CI/CD에서는 목(mock) 서버 고려 필요
3. **플레이키 테스트**: 네트워크 지연, 애니메이션 타이밍 등으로 간헐적 실패 가능 → `pumpAndSettle` 타임아웃 조정
4. **테스트 격리**: 통합 테스트는 실제 DB를 사용하므로 테스트 데이터가 프로덕션에 영향을 줄 수 있음 → 테스트 계정 분리 권장
