# 프로필 재인증 UI + 채팅 사진 전송 + 닉네임 중복 체크
> 날짜: 2026-02-19

## 작업 요약
- 프로필 편집 화면에 셀카 재인증 요청 기능 추가
- 채팅에서 사진을 Firebase Storage에 업로드 후 실제 이미지로 표시하도록 개선
- 회원가입/프로필 수정 시 닉네임 중복 체크 로직 추가 (백엔드)

## 변경 범위

### 프론트엔드
| 파일 | 변경 내용 |
|------|----------|
| `lib/features/settings/screens/profile_edit_screen.dart` | 재인증 섹션 UI + 카메라 촬영 → reverify 호출 |
| `lib/features/profile/providers/profile_provider.dart` | `reverify(filePath)` 메서드 추가 |
| `lib/features/chat/services/chat_service.dart` | `uploadImage()` - Firebase Storage 업로드 메서드 |
| `lib/features/chat/providers/chat_provider.dart` | `sendImageMessage()` - 업로드 후 메시지 전송 |
| `lib/features/chat/screens/chat_room_screen.dart` | 실제 이미지 업로드 + CachedNetworkImage 표시 |
| `pubspec.yaml` | `firebase_storage` 패키지 추가 |

### 백엔드
| 파일 | 변경 내용 |
|------|----------|
| `UserRepository.java` | `existsByNicknameAndUserIdNot()` 메서드 추가 |
| `SignupService.java` | `saveProfile()`에 닉네임 중복 체크 추가 |
| `ProfileService.java` | `updateMyProfile()`에 닉네임 중복 체크 추가 |

## 핵심 개념 설명

### 1. Firebase Storage 이미지 업로드
Firebase Storage는 Firebase가 제공하는 파일 저장 서비스입니다. 채팅 이미지를 클라우드에 업로드하고, 다운로드 URL을 받아 Firestore 메시지에 저장합니다.

```dart
// 업로드 경로: chat_images/{chatRoomId}/{timestamp}_{filename}
final ref = _storage.ref().child('chat_images/$chatRoomId/$fileName');
await ref.putFile(File(filePath));
return await ref.getDownloadURL(); // https://firebasestorage.googleapis.com/...
```

흐름: 이미지 선택 → Firebase Storage 업로드 → 다운로드 URL 획득 → Firestore 메시지로 전송

### 2. CachedNetworkImage
네트워크 이미지를 로컬에 캐싱하여 같은 이미지를 다시 다운로드하지 않습니다. `placeholder`(로딩 중)와 `errorWidget`(실패 시)을 지정할 수 있어 UX가 좋습니다.

```dart
CachedNetworkImage(
  imageUrl: message.text,       // Firebase Storage URL
  width: 200,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.broken_image),
)
```

### 3. JPA 파생 쿼리 (Derived Query)
Spring Data JPA는 메서드 이름만으로 SQL을 자동 생성합니다:

```java
// SELECT count(*) > 0 FROM users WHERE nickname = ? AND user_id != ?
boolean existsByNicknameAndUserIdNot(String nickname, Long userId);
```

`And`로 조건을 연결하고, `Not`으로 부정 조건을 만듭니다. 본인의 닉네임은 제외하고 중복을 체크합니다.

### 4. image_picker + 확인 다이얼로그 패턴
카메라로 셀카를 찍은 후, 바로 업로드하지 않고 확인 다이얼로그를 표시하여 사용자에게 한 번 더 확인을 받습니다. 이렇게 하면 실수로 촬영된 사진이 업로드되는 것을 방지합니다.

## 코드 설명

### ChatService.uploadImage
```dart
Future<String> uploadImage({
  required String chatRoomId,
  required String filePath,
}) async {
  // 타임스탬프 + 파일명으로 고유 경로 생성
  final fileName = '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
  final ref = _storage.ref().child('chat_images/$chatRoomId/$fileName');
  await ref.putFile(File(filePath));   // 파일 업로드
  return await ref.getDownloadURL();   // 다운로드 URL 반환
}
```

### 닉네임 중복 체크 (본인 제외)
```java
// SignupService.saveProfile()
if (userRepository.existsByNicknameAndUserIdNot(request.getNickname(), userId)) {
    throw new BusinessException(ErrorCode.NICKNAME_DUPLICATE);
}
```
`existsByNicknameAndUserIdNot`은 해당 닉네임을 가진 **다른** 유저가 있는지 확인합니다. 본인이 같은 닉네임으로 다시 저장할 때는 통과됩니다.

## 새로 배울 수 있는 것
- Firebase Storage와 Firestore를 조합한 이미지 채팅 구현 패턴
- CachedNetworkImage를 활용한 채팅 이미지 캐싱
- JPA 파생 쿼리에서 `Not` 조건을 사용하여 본인 제외 로직 구현
- image_picker의 ImageSource.camera를 활용한 셀카 촬영

## 리스크 및 주의사항
- Firebase Storage 보안 규칙이 인증된 사용자만 업로드할 수 있도록 설정되어 있어야 합니다
- 대용량 이미지는 업로드 전 압축하는 것이 좋습니다 (현재 미적용)
- 닉네임 중복 체크는 동시성 이슈가 있을 수 있으나, unique constraint가 DB에 없어 race condition 가능성 존재
