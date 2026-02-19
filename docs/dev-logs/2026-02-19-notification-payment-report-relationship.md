# 알림/결제/신고/관계 상세 기능 보완
> 날짜: 2026-02-19

## 작업 요약
- 알림 화면은 이미 완전 구현되어 있음을 확인 (NotificationScreen + BottomNavigationBar 연결)
- 구독/결제 API 호출 시 `store` 파라미터 누락 버그 수정 (APPLE/GOOGLE 자동 감지)
- 신고 기능: 카테고리 한글→enum 매핑 수정 + 채팅방에 신고/차단 메뉴 추가
- 프로필 상세 화면에 관계 기반 "채팅하기" 버튼 추가

## 변경 범위

| 파일 | 변경 내용 |
|------|----------|
| `lib/features/shop/services/shop_service.dart` | purchase(), subscribe()에 store 파라미터 추가 |
| `lib/features/shop/providers/shop_provider.dart` | Platform.isIOS로 store 자동 감지 |
| `lib/features/profile/screens/profile_detail_screen.dart` | 신고 카테고리 enum 매핑 + PROFILE targetType + 채팅 버튼 |
| `lib/features/chat/screens/chat_room_screen.dart` | AppBar에 차단/신고 PopupMenuButton 추가 |
| `lib/features/relationship/providers/relationship_provider.dart` | findByOtherUserId() 헬퍼 추가 |

## 핵심 개념 설명

### 1. Platform 감지 (dart:io)
Flutter에서 `Platform.isIOS`와 `Platform.isAndroid`로 현재 실행 플랫폼을 확인할 수 있습니다. 결제 API에서 어느 스토어(APPLE/GOOGLE)인지 자동으로 결정하는 데 사용합니다.

```dart
import 'dart:io';
String get _store => Platform.isIOS ? 'APPLE' : 'GOOGLE';
```

### 2. Enum 매핑 (프론트↔백엔드)
백엔드에서 `@Enumerated(EnumType.STRING)`으로 선언된 필드는 정확한 enum 이름을 요구합니다. 프론트엔드에서 한글 UI를 보여주되, API 전송 시 영문 enum 값을 사용해야 합니다.

```dart
// Map의 key = 백엔드 enum, value = UI 표시 텍스트
final categories = {
  'HARASSMENT': '성희롱/스토킹',
  'SPAM': '스팸/광고',
  'OTHER': '기타',
};
```

### 3. PopupMenuButton
Material Design의 더보기(⋮) 메뉴를 구현하는 위젯입니다. `onSelected` 콜백으로 선택된 값을 처리하고, `itemBuilder`에서 메뉴 항목을 정의합니다.

```dart
PopupMenuButton<String>(
  onSelected: (value) {
    if (value == 'block') _handleBlock();
    if (value == 'report') _handleReport();
  },
  itemBuilder: (context) => [
    const PopupMenuItem(value: 'block', child: Text('차단하기')),
    const PopupMenuItem(value: 'report', child: Text('신고하기')),
  ],
)
```

### 4. Provider에서 cross-feature 데이터 조회
ProfileDetailScreen에서 RelationshipProvider의 데이터를 조회하여 관계 기반 UI를 표시합니다. 이미 로드된 데이터를 재활용하므로 추가 API 호출 없이 동작합니다.

```dart
final relItem = context.read<RelationshipProvider>().findByOtherUserId(userId);
if (relItem?.status == 'INYEON') {
  // 채팅하기 버튼 표시
}
```

## 코드 설명

### store 파라미터 수정
```dart
// ShopService - 기존 (버그)
Future<void> subscribe(String receiptToken) async {
  await _client.post('/shop/subscription', data: {
    'receiptToken': receiptToken,
    // store 누락! → 400 Bad Request
  });
}

// ShopService - 수정 후
Future<void> subscribe({required String receiptToken, required String store}) async {
  await _client.post('/shop/subscription', data: {
    'receiptToken': receiptToken,
    'store': store,  // APPLE 또는 GOOGLE
  });
}
```

### 채팅방 신고 기능
채팅방에서 신고할 때는 `targetType: 'CHAT'`과 `chatRoomId`를 함께 전송합니다. 관리자가 해당 채팅방의 메시지 기록을 확인할 수 있도록 합니다.

## 새로 배울 수 있는 것
- `dart:io`의 `Platform` 클래스로 플랫폼별 분기 처리
- 백엔드 enum과 프론트 UI 텍스트의 매핑 패턴 (Map 활용)
- Provider 간 데이터 교차 참조 패턴
- PopupMenuButton을 활용한 AppBar 더보기 메뉴

## 리스크 및 주의사항
- `Platform.isIOS`는 웹에서 실행 시 에러 발생 → 웹 지원 필요 시 `kIsWeb` 분기 추가 필요
- 현재 `receiptToken`은 'test_receipt_token'으로 하드코딩됨 → 프로덕션에서는 in_app_purchase 플러그인 연동 필수
- 알림 화면은 완성되어 있지만 Foreground 메시지 수신 시 앱 내 알림 배너 표시는 TODO
