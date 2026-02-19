# FCM 딥링크 + 차단 해제 UI + 알림 날짜 그룹핑 구현
> 날짜: 2026-02-19

## 작업 요약
- FCM 푸시 알림 탭 시 딥링크 네비게이션 처리 구현 (Background + Terminated 상태)
- 차단 목록에서 차단 해제 버튼 및 확인 다이얼로그 추가
- 알림 화면의 날짜별 그룹 섹션 헤더를 동적으로 생성하도록 개선

## 변경 범위
| 파일 | 역할 |
|------|------|
| `lib/core/services/fcm_service.dart` | 딥링크 콜백 추가, handleInitialMessage() 메서드 추가 |
| `lib/app.dart` | 딥링크 콜백 등록, Terminated 상태 초기 메시지 처리 |
| `lib/features/settings/screens/connection_range_screen.dart` | 차단 해제 버튼 + 확인 다이얼로그 추가 |
| `lib/features/notification/screens/notification_screen.dart` | 날짜별 그룹핑 로직 + 동적 섹션 헤더 |

## 핵심 개념 설명

### FCM 메시지 수신 3가지 상태
Flutter 앱이 FCM 푸시 알림을 받는 상황은 3가지로 나뉩니다:
1. **Foreground**: 앱이 화면에 보이는 상태 → `FirebaseMessaging.onMessage`로 처리 (인앱 배너 표시)
2. **Background**: 앱이 메모리에 있지만 화면에 안 보이는 상태 → `FirebaseMessaging.onMessageOpenedApp`으로 처리
3. **Terminated**: 앱이 완전히 종료된 상태 → `FirebaseMessaging.instance.getInitialMessage()`로 처리

Background/Terminated에서 사용자가 알림을 탭하면 `message.data['deepLink']`에 담긴 경로(예: `/chat/abc123`)로 네비게이션해야 합니다.

### 콜백 패턴으로 서비스-UI 분리
FcmService는 순수 서비스 클래스라서 GoRouter에 직접 접근할 수 없습니다. 대신 `onDeepLinkCallback`이라는 콜백 함수를 정의하고, UI 레이어(app.dart)에서 콜백을 등록하여 `appRouter.push(deepLink)`를 호출합니다. 이렇게 하면 서비스 계층이 UI 라이브러리에 의존하지 않습니다.

### Terminated 상태의 특수 처리
앱이 완전히 종료된 상태에서 알림을 탭하면, 앱이 처음부터 시작됩니다. 이때 `getInitialMessage()`를 호출해야 하는데, 라우터가 완전히 초기화된 후에 호출해야 합니다. `WidgetsBinding.instance.addPostFrameCallback`을 사용하여 첫 프레임 렌더링 후에 처리합니다.

## 코드 설명

### 1. FCM 딥링크 처리 (fcm_service.dart)
```dart
// 콜백 정의 - UI 레이어에서 네비게이션 함수를 등록
void Function(String deepLink)? onDeepLinkCallback;

// 메시지에서 딥링크 추출 후 콜백 호출
void _handleDeepLink(RemoteMessage message) {
  final deepLink = message.data['deepLink'] as String?;
  if (deepLink != null && deepLink.isNotEmpty) {
    onDeepLinkCallback?.call(deepLink);
  }
}

// Terminated 상태 처리
Future<void> handleInitialMessage() async {
  final message = await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) _handleDeepLink(message);
}
```

### 2. 차단 해제 다이얼로그 (connection_range_screen.dart)
```dart
Future<void> _showUnblockDialog(int blockId, String nickname) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => IttoDialog(
      title: "'$nickname'님의\n차단을 해제하시겠습니까?",
      subtitle: '해제하면 다시 서로 노출됩니다.',
      cancelText: '취소',
      confirmText: '해제하기',
    ),
  );
  if (confirmed != true || !mounted) return;
  // BlockProvider.unblock() 호출 → 서버 API DELETE /blocks/:id
  final success = await context.read<BlockProvider>().unblock(blockId);
}
```

### 3. 알림 날짜 그룹핑 (notification_screen.dart)
```dart
String _getDateGroupLabel(String createdAt) {
  final diff = today.difference(date).inDays;
  if (diff == 0) return '오늘';
  if (diff == 1) return '어제';
  if (diff < 7) return '이번 주';
  if (diff < 30) return '이번 달';
  return '이전';
}
```
알림 목록을 순회하면서 동일한 그룹 라벨끼리 묶고, 순서를 유지한 채 `_NotificationGroup` 리스트를 만들어 섹션별로 렌더링합니다.

## 새로 배울 수 있는 것
- FCM Background/Terminated 알림 처리의 차이와 각각의 API
- 콜백 패턴을 활용한 서비스-UI 분리 설계
- `addPostFrameCallback`으로 위젯 트리 초기화 이후 작업 실행
- `showDialog<bool>`로 사용자 확인을 받고 분기 처리하는 패턴
- 리스트 데이터를 날짜 기준으로 그룹핑하는 로직

## 리스크 및 주의사항
- FCM 딥링크는 서버에서 `data` 필드에 `deepLink` 키를 포함하여 보내야 동작합니다. 서버 측 FCM 전송 시 해당 필드가 없으면 네비게이션이 발생하지 않습니다.
- Terminated 상태의 `getInitialMessage()`는 앱 실행 시 단 한 번만 호출 가능하며, 두 번째 호출은 null을 반환합니다.
- 차단 해제는 서버에서 즉시 처리되며, 해제 후 상대방이 다시 노출될 수 있습니다.
- 알림 날짜 그룹핑은 서버에서 `createdAt`을 ISO 8601 형식으로 보내야 정상 파싱됩니다.
