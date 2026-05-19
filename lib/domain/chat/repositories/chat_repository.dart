import 'package:itto/domain/chat/entities/chat_message.dart';
import 'package:itto/domain/chat/entities/chat_room.dart';

/// Spring 백엔드 채팅 API (REST + STOMP) 추상화.
///
/// 채팅방은 ItteonRelationship 수락 시 백엔드가 자동 생성하므로
/// 클라이언트에서 별도의 ensure 호출은 필요 없다.
abstract class ChatRepository {
  /// 내 활성 채팅방 목록 (lastMessageAt DESC)
  Future<List<ChatRoom>> listRooms();

  /// 특정 채팅방 메시지 페이지 (page=0 이 최신)
  Future<List<ChatMessage>> getMessages(
    int chatRoomId, {
    int page = 0,
    int size = 30,
  });

  /// WS 연결 (앱 시작 / foreground 복귀 시 호출)
  Future<void> connect();

  /// WS 종료 (앱 background 진입 시 호출)
  Future<void> disconnect();

  /// 특정 채팅방 실시간 메시지 stream.
  /// 동일 채팅방을 여러 번 호출해도 동일 broadcast stream 을 반환한다.
  Stream<ChatMessage> subscribeToRoom(int chatRoomId);

  /// 특정 채팅방 구독 해제 (채팅 화면 떠날 때)
  Future<void> unsubscribeFromRoom(int chatRoomId);

  /// 메시지 전송 (WS publish). content 또는 imageUrl 중 하나 필수.
  Future<void> sendMessage({
    required int chatRoomId,
    String? content,
    String? imageUrl,
  });

  /// 상대 메시지를 모두 읽음 처리
  Future<int> markAsRead(int chatRoomId);

  /// 이미지 업로드 후 URL 반환
  Future<String> uploadImage({
    required int chatRoomId,
    required String filePath,
  });
}
