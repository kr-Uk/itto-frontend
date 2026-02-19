# 홈 탭 폴리싱 + 채팅 읽음 표시 + Foreground 푸시 배너
> 날짜: 2026-02-19

## 작업 요약
- Foreground 푸시 알림 수신 시 인앱 배너(슬라이드 다운 오버레이) 표시 구현
- 채팅 메시지 버블에 상대방 읽음("읽음") 인디케이터 추가
- 필연 탭에 "프로필 보기" + "인연 요청" 버튼 분리, 지난인연 탭에 프로필 보기 탭 추가

## 변경 범위

| 파일 | 변경 내용 |
|------|----------|
| `lib/core/services/fcm_service.dart` | `onForegroundMessageCallback` 콜백 추가 |
| `lib/core/router/app_router.dart` | `_rootNavigatorKey` → `rootNavigatorKey` (외부 접근 가능) |
| `lib/app.dart` | StatefulWidget 변환 + 인앱 알림 배너 오버레이 구현 |
| `lib/features/chat/screens/chat_room_screen.dart` | `_MessageBubble`에 `isRead` + "읽음" 텍스트 표시 |
| `lib/features/home/screens/tabs/pilyeon_tab.dart` | "프로필 보기" / "인연 요청" 버튼 분리 |
| `lib/features/home/screens/tabs/past_inyeon_tab.dart` | 카드 탭 → 프로필 상세 보기 |

## 핵심 개념 설명

### 1. OverlayEntry (인앱 알림 배너)

Flutter의 `Overlay`는 다른 위젯들 위에 떠 있는 레이어입니다. `OverlayEntry`를 삽입하면 어떤 화면 위에서든 위젯을 표시할 수 있습니다.

```dart
// Navigator의 overlay를 가져와서 entry 삽입
final overlay = rootNavigatorKey.currentState?.overlay;
overlay?.insert(overlayEntry);

// 제거
overlayEntry.remove();
```

이 방식은 `ScaffoldMessenger`의 `SnackBar`나 `MaterialBanner`보다 유연합니다:
- 위치, 애니메이션을 자유롭게 커스텀 가능
- 라우터 키만 있으면 어디서든 호출 가능

### 2. FCM Foreground 메시지 → UI 브릿지

FCM의 `onMessage` 리스너는 `BuildContext`가 없는 서비스 레이어에서 동작합니다. UI에 전달하려면 콜백 패턴을 사용합니다:

```dart
// 서비스 (context 없음)
void Function(RemoteMessage)? onForegroundMessageCallback;

// 앱 루트 (context 있음)
FcmService.instance.onForegroundMessageCallback = _showBanner;
```

### 3. SlideTransition (애니메이션)

`SlideTransition`은 위젯을 특정 방향으로 슬라이드시키는 암시적 애니메이션입니다.

```dart
// 위에서 아래로 슬라이드
Tween<Offset>(
  begin: const Offset(0, -1), // 화면 위 바깥
  end: Offset.zero,           // 원래 위치
)
```

### 4. Firestore readBy (읽음 처리)

1:1 채팅에서 메시지의 `readBy` 배열을 활용합니다:
- 메시지 전송 시: `readBy: [senderId]` (보낸 사람만)
- 상대방이 채팅방 입장 시: `readBy: [senderId, otherUserId]` (arrayUnion)
- `readBy.length >= 2` → 상대방이 읽음

```dart
final isRead = isSent && message.readBy.length >= 2;
```

## 코드 설명

### 인앱 알림 배너
```dart
void _showNotificationBanner(RemoteMessage message) {
  // 이전 배너 제거 후 새 배너 삽입
  _notificationOverlay?.remove();

  _notificationOverlay = OverlayEntry(
    builder: (context) => _InAppNotificationBanner(
      title: notification.title ?? '',
      body: notification.body ?? '',
      deepLink: message.data['deepLink'],  // 탭 시 해당 화면으로 이동
      onDismiss: () => _notificationOverlay?.remove(),
    ),
  );

  overlay.insert(_notificationOverlay!);

  // 4초 후 자동 제거
  Future.delayed(const Duration(seconds: 4), () {
    _notificationOverlay?.remove();
  });
}
```

### 읽음 표시 UI
```dart
// 메시지 시간 표시 영역에 "읽음" 추가
if (isSent && isRead) ...[
  Text('읽음', style: TextStyle(
    color: AppColors.primary,  // 보라색으로 강조
    fontSize: 11,
  )),
  SizedBox(width: 4),
],
Text(_formatMessageTime(message.createdAt), ...),
```

### 필연 탭 버튼 분리
```dart
// 기존: 카드 전체 탭 → 인연 요청 다이얼로그
// 변경: 2개 버튼으로 분리
Row(
  children: [
    Expanded(child: "프로필 보기" 버튼 → context.push('/profile/$userId')),
    Expanded(child: "인연 요청" 버튼 → _showRequestInyeonDialog()),
  ],
)
```

## 새로 배울 수 있는 것
- Flutter `Overlay` 시스템을 활용한 전역 UI 컴포넌트 (알림 배너, 툴팁 등)
- 서비스 레이어 → UI 레이어 통신 패턴 (콜백 기반)
- Firestore의 `arrayUnion`을 활용한 읽음 처리 패턴
- `SlideTransition` + `AnimationController`로 커스텀 애니메이션

## 리스크 및 주의사항
- 인앱 배너의 `Future.delayed`로 자동 제거 시, 이미 수동 제거된 경우 null 체크 필요 (구현됨)
- `readBy.length >= 2` 방식은 1:1 채팅에서만 정확함, 그룹 채팅 지원 시 로직 변경 필요
- `rootNavigatorKey`를 public으로 변경했으므로 외부에서 잘못 사용하지 않도록 주의
- 배너의 deepLink 탭 시 GoRouter.push()를 사용하므로, 유효하지 않은 경로면 에러 발생 가능
